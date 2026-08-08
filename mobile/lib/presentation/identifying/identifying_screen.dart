import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
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
  late AnimationController _spinCtrl;

  final _facts = [
    "Bamboo can grow up to 91cm in a single day!",
    "There are over 390,000 known plant species on Earth.",
    "The world's oldest tree is over 4,800 years old.",
    "A sunflower can have up to 2,000 seeds.",
    "Some plants can 'hear' running water and grow towards it.",
    "The Amazon produces 20% of the world's oxygen.",
  ];

  int _factIndex = 0;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startAnimation();
    _identify();
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
      if (mounted) {
        setState(() {
          _step = (_step + 1).clamp(0, 3);
          _factIndex = (_factIndex + 1) % _facts.length;
        });
        if (timer.tick > 12) {
          setState(() => _timeout = true);
          timer.cancel();
        }
      }
    });
  }

  Future<void> _identify() async {
    try {
      final result = await _apiService.identifyPlant(widget.imageBytes, null);
      _timer?.cancel();
      _spinCtrl.dispose();

      // Save to local history
      _saveToHistory(result);

      if (mounted) {
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
      }
    } catch (e) {
      _timer?.cancel();
      _spinCtrl.dispose();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: UrPlantTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User photo preview
              if (widget.imageBytes.length > 50)
                Opacity(
                  opacity: 0.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      widget.imageBytes,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 36),

              // Animated spinning leaf
              AnimatedBuilder(
                animation: _spinCtrl,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinCtrl.value * 2 * 3.14159,
                    child: const Icon(Icons.eco, size: 64, color: Colors.white),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'Identifying your plant...',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
              ),
              const SizedBox(height: 28),

              // Progress steps
              _modernStep(0, 'Analyzing image...'),
              _modernStep(1, 'Matching database...'),
              _modernStep(2, 'Gathering details...'),

              const Spacer(),

              // Fun fact card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Did you know?',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Text(
                      _facts[_factIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              if (_timeout)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Taking longer than expected...',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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
                ? const Icon(Icons.check, size: 14, color: UrPlantTheme.primaryMedium)
                : null,
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}