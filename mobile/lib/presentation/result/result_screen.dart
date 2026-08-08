import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../config/theme.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_history_store.dart';
import '../camera/camera_screen.dart';
import '../plant_detail/plant_detail_screen.dart';
import 'package:confetti/confetti.dart';

class ResultScreen extends StatefulWidget {
  final IdentifyResult result;
  final Uint8List imageBytes;
  final String imagePath;
  const ResultScreen({super.key, required this.result, required this.imageBytes, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.isNewUnlock) {
      _confetti.play();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top nav bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home_outlined, size: 18),
                        label: const Text('Home'),
                      ),
                      if (r.plant != null)
                        TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(plantId: r.plant!['id'], plantData: r.plant),
                          )),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('View Detail'),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Photo with rounded corners
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Image.memory(
                                widget.imageBytes,
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Result banner
                        if (r.isNewUnlock)
                          _resultHero('🎉', 'New Plant Unlocked!', UrPlantTheme.primaryLight)
                        else if (r.isDuplicate)
                          _resultHero('📸', 'Already in your collection!', UrPlantTheme.rarityRare)
                        else if (r.error == 'low_confidence')
                          _lowConfidenceView()
                        else if (r.matchStatus == 'unmatched')
                          _unmatchedView(r)
                        else if (r.error != null)
                          _resultHero('⚠️', 'Error: ${r.error}', UrPlantTheme.error),

                        // Safety alert (shown prominently if poisonous or warnings exist)
                        if (r.safetyInfo != null && (r.safetyInfo!['poisonous'] == true || r.safetyInfo!['warning'] != null))
                          _safetyAlert(r.safetyInfo!),

                        if (r.plant != null) ...[
                          const SizedBox(height: 20),
                          _plantInfo(r),
                        ],

                        // Achievement toasts
                        if (r.achievementsEarned.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _achievementSection(r.achievementsEarned),
                        ],

                        const SizedBox(height: 28),

                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => const CameraScreen()));
                            },
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text('Scan Another Plant'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (r.plant != null)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Share via platform share sheet
                              },
                              icon: const Icon(Icons.share_outlined, size: 18),
                              label: const Text('Share'),
                            ),
                          ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                            child: const Text('Go Home'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay
          if (r.isNewUnlock)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  if (r.plant?['rarity'] == 'special_rare') UrPlantTheme.raritySpecial,
                  if (r.plant?['rarity'] == 'rare') UrPlantTheme.rarityRare,
                  UrPlantTheme.rarityNormal,
                  Colors.white,
                  UrPlantTheme.primaryLight,
                ],
                numberOfParticles: r.plant?['rarity'] == 'special_rare' ? 80 : 40,
              ),
            ),
        ],
      ),
    );
  }

  Widget _resultHero(String emoji, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _plantInfo(IdentifyResult r) {
    final p = r.plant!;
    final rarity = p['rarity'] ?? 'normal';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UrPlantTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(p['name_en'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(p['scientific_name'] ?? '',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: UrPlantTheme.textTertiary)),
          if (p['name_kh'] != null && p['name_kh'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(p['name_kh'],
                  style: const TextStyle(fontSize: 15, color: UrPlantTheme.textSecondary)),
            ),
          const SizedBox(height: 12),
          _rarityBadge(rarity),
          if (r.xpEarned > 0) ...[
            const SizedBox(height: 14),
            _xpBadge(r.xpEarned),
          ],
          if (p['description'] != null && p['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(p['description'],
                style: const TextStyle(fontSize: 14, height: 1.6, color: UrPlantTheme.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _rarityBadge(String rarity) {
    Color c;
    String t;
    switch (rarity) {
      case 'rare':
        c = UrPlantTheme.rarityRare;
        t = '✦ Rare';
        break;
      case 'special_rare':
        c = UrPlantTheme.raritySpecial;
        t = '✦✦ Special Rare';
        break;
      default:
        c = UrPlantTheme.rarityNormal;
        t = '★ Normal';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    );
  }

  Widget _xpBadge(int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        gradient: UrPlantTheme.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: UrPlantTheme.primaryLight.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Text('+$xp XP',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Widget _lowConfidenceView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UrPlantTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology_outlined, size: 48, color: UrPlantTheme.textTertiary),
          const SizedBox(height: 12),
          const Text("Couldn't Identify",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text('Try these tips for better results:',
              style: TextStyle(color: UrPlantTheme.textSecondary)),
          const SizedBox(height: 16),
          _tip(Icons.crop, 'Get closer to the plant'),
          _tip(Icons.wb_sunny_outlined, 'Ensure good lighting'),
          _tip(Icons.filter_vintage, 'Focus on leaves or flowers'),
          _tip(Icons.blur_off, 'Avoid blurry photos'),
        ],
      ),
    );
  }

  Widget _tip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: UrPlantTheme.primaryAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: UrPlantTheme.primaryMedium),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary))),
        ],
      ),
    );
  }

  Widget _safetyAlert(Map<String, dynamic> safety) {
    final poisonous = safety['poisonous'] == true;
    final edible = safety['edible'] == true;
    final medicinal = safety['medicinal'] == true;
    final warning = safety['warning'] as String?;
    final color = poisonous || (warning != null && warning.isNotEmpty)
        ? UrPlantTheme.error
        : UrPlantTheme.warning;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 22, color: color),
              const SizedBox(width: 8),
              Text(
                poisonous ? '⚠️ Potentially Poisonous' : '⚠️ Safety Notice',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          if (warning != null && warning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(warning, style: const TextStyle(fontSize: 13, color: UrPlantTheme.textSecondary, height: 1.4)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _safetyTag('Poisonous', poisonous, UrPlantTheme.error),
              const SizedBox(width: 6),
              _safetyTag('Edible', edible, UrPlantTheme.success),
              const SizedBox(width: 6),
              _safetyTag('Medicinal', medicinal, UrPlantTheme.rarityRare),
            ],
          ),
        ],
      ),
    );
  }

  Widget _safetyTag(String label, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: active ? color : UrPlantTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _achievementSection(List<Map<String, dynamic>> achievements) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: UrPlantTheme.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Achievements Unlocked!',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...achievements.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    a['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                if (a['xp'] != null && a['xp'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${a['xp']} XP',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _unmatchedView(IdentifyResult r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: UrPlantTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, size: 48, color: UrPlantTheme.warning),
          const SizedBox(height: 12),
          const Text('Plant Not in Database',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(
            r.messageEn ?? "We found something but it's not in our database yet.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text("We'll review it soon!",
              style: TextStyle(fontSize: 13, color: UrPlantTheme.textTertiary)),
          if (r.xpEarned > 0) ...[
            const SizedBox(height: 16),
            _xpBadge(r.xpEarned),
          ],
        ],
      ),
    );
  }
}