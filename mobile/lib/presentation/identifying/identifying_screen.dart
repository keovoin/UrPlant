import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_history_store.dart';
import '../result/result_screen.dart';

class IdentifyingScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String imagePath;
  const IdentifyingScreen({super.key, required this.imageBytes, required this.imagePath});

  @override
  State<IdentifyingScreen> createState() => _IdentifyingScreenState();
}

class _IdentifyingScreenState extends State<IdentifyingScreen>
    with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  int _step = 0;
  Timer? _timer;
  bool _timeout = false;
  bool _navigated = false;
  late AnimationController _spinCtrl;

  static const _factKeys = [
    'fact_bamboo', 'fact_species', 'fact_oldest_tree',
    'fact_sunflower', 'fact_hear_water', 'fact_amazon',
  ];

  int _factIndex = 0;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _startAnimation();
    _identify();
  }

  String _fact(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (_factKeys[_factIndex]) {
      case 'fact_bamboo': return l.fact_bamboo;
      case 'fact_species': return l.fact_species;
      case 'fact_oldest_tree': return l.fact_oldest_tree;
      case 'fact_sunflower': return l.fact_sunflower;
      case 'fact_hear_water': return l.fact_hear_water;
      default: return l.fact_amazon;
    }
  }

  void _saveToHistory(IdentifyResult result) {
    final plantJson = result.plant != null ? jsonEncode(result.plant) : null;
    final record = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      plantName: result.plant?['name_en'] ?? 'Unknown Plant',
      plantDataJson: plantJson,
      matchStatus: result.matchStatus,
      xpEarned: result.xpEarned,
    );
    LocalHistoryStore.saveScan(record);
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (!mounted) return;
      setState(() {
        _step = (_step + 1).clamp(0, 3);
        _factIndex = (_factIndex + 1) % _factKeys.length;
      });
      if (timer.tick > 12) {
        setState(() => _timeout = true);
        timer.cancel();
      }
    });
  }

  Future<void> _identify() async {
    try {
      final result = await _apiService.identifyPlant(widget.imageBytes, null);
      _timer?.cancel();
      if (!mounted || _navigated) return;
      _navigated = true;

      // Save to local history
      _saveToHistory(result);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imageBytes: widget.imageBytes,
            imagePath: widget.imagePath,
          ),
        ),
      );
    } catch (e) {
      _timer?.cancel();
      if (!mounted || _navigated) return;
      _navigated = true;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.error_generic), backgroundColor: UrPlantTheme.error),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Only dispose here — never inside _identify().
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final stepLabels = [l.identifying_step_analyze, l.identifying_step_match, l.identifying_step_details];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: UrPlantTheme.heroGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User photo preview inside a chunky polaroid tilt
              if (widget.imageBytes.length > 50)
                Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        widget.imageBytes,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Slow spinning leaf (no jitter; gentle)
              AnimatedBuilder(
                animation: _spinCtrl,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinCtrl.value * 2 * 3.14159,
                    child: const Icon(Icons.eco, size: 56, color: Colors.white),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                l.identifying_title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
              const SizedBox(height: 24),

              for (var i = 0; i < stepLabels.length; i++) _modernStep(i, stepLabels[i]),

              const Spacer(),

              // Fun fact card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Text(l.identifying_did_you_know,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _fact(context),
                        key: ValueKey(_factIndex),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.45),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              if (_timeout)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Text(l.identifying_slow, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _timer?.cancel();
                          if (mounted) Navigator.pop(context);
                        },
                        child: Text(l.common_cancel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernStep(int step, String text) {
    final active = _step >= step;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: active ? Colors.white : Colors.white38,
                width: 2,
              ),
            ),
            child: active
                ? const Icon(Icons.check, size: 14, color: UrPlantTheme.primaryDark)
                : null,
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
