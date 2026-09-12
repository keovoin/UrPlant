import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import '../../config/theme.dart';
import '../../data/services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../camera/camera_screen.dart';
import '../plant_detail/plant_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final IdentifyResult result;
  final Uint8List imageBytes;
  final String imagePath;
  const ResultScreen({super.key, required this.result, required this.imageBytes, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.isNewUnlock) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _confetti.play();
        HapticFeedback.mediumImpact();
      });
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
    final l = AppLocalizations.of(context);
    final isKh = Localizations.localeOf(context).languageCode == 'km';

    return Scaffold(
      backgroundColor: UrPlantTheme.canvas,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                        icon: const Icon(Icons.home_rounded, size: 18),
                        label: Text(l.nav_home),
                      ),
                      if (r.plant != null)
                        TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(
                                plantId: r.plant!['id'], plantData: r.plant),
                          )),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(l.common_view),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        StaggerIn(index: 0, child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(children: [
                            Image.memory(widget.imageBytes,
                                width: double.infinity, height: 250, fit: BoxFit.cover),
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(height: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Color(0x00000000), Color(0x4D000000)]))),
                            ),
                          ]),
                        )),
                        const SizedBox(height: 22),

                        if (r.isNewUnlock)
                          StaggerIn(index: 1, child: _hero('🎉', l.result_new_unlock, UrPlantTheme.primary))
                        else if (r.isDuplicate)
                          StaggerIn(index: 1, child: _hero('📸', l.result_duplicate, UrPlantTheme.info))
                        else if (r.error == 'low_confidence')
                          StaggerIn(index: 1, child: _lowConfidence(l))
                        else if (r.matchStatus == 'unmatched')
                          StaggerIn(index: 1, child: _unmatched(r, l))
                        else if (r.error != null)
                          StaggerIn(index: 1, child: _hero('⚠️', '${r.error}', UrPlantTheme.danger)),

                        if (r.safetyInfo != null &&
                            (r.safetyInfo!['poisonous'] == true ||
                             r.safetyInfo!['warning'] != null))
                          StaggerIn(index: 2, child: _safetyAlert(r.safetyInfo!, l, isKh)),

                        if (r.plant != null)
                          StaggerIn(index: 3, child: _plantInfo(r, l, isKh)),

                        if (r.achievementsEarned.isNotEmpty)
                          StaggerIn(index: 4, child: _achievements(r.achievementsEarned, l)),

                        const SizedBox(height: 26),
                        StaggerIn(index: 5, child: Column(children: [
                          ChunkyButton(
                            color: UrPlantTheme.primary,
                            edge: UrPlantTheme.primaryEdge,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const CameraScreen())),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.photo_camera_rounded, size: 20),
                              const SizedBox(width: 10),
                              Text(l.result_scan_another),
                            ]),
                          ),
                          const SizedBox(height: 12),
                          Row(children: [
                            if (r.plant != null) ...[
                              Expanded(child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  foregroundColor: UrPlantTheme.primaryDark,
                                  side: const BorderSide(color: UrPlantTheme.line, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  final name = r.plant!['name_en'] ?? '';
                                  final sci = r.plant!['scientific_name'] ?? '';
                                  SharePlus.instance.share(ShareParams(
                                    text: 'I identified "$name" ($sci) with UrPlant! 🌿',
                                    subject: 'Plant Discovery'));
                                },
                                icon: const Icon(Icons.share_rounded, size: 18),
                                label: Text(l.common_share),
                              )),
                              const SizedBox(width: 10),
                            ],
                            Expanded(child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                                foregroundColor: UrPlantTheme.inkSoft,
                                side: const BorderSide(color: UrPlantTheme.line, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                              child: Text(l.result_go_home),
                            )),
                          ]),
                        ])),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (r.isNewUnlock)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.05,
                colors: [
                  if (r.plant?['rarity'] == 'special_rare') UrPlantTheme.specialPurple,
                  if (r.plant?['rarity'] == 'rare') UrPlantTheme.rarityRare,
                  UrPlantTheme.primary,
                  UrPlantTheme.gold,
                  Colors.white,
                ],
                numberOfParticles: r.plant?['rarity'] == 'special_rare' ? 80 : 45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _hero(String emoji, String text, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 46)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Text(text, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
      ),
    ]),
  );

  Widget _xpBadge(int xp) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
    decoration: BoxDecoration(
      gradient: UrPlantTheme.goldGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x4DF4A82C), blurRadius: 10, offset: Offset(0, 4))],
    ),
    child: Text('+$xp XP', style: const TextStyle(
        fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
  );

  Widget _plantInfo(IdentifyResult r, AppLocalizations l, bool isKh) {
    final p = r.plant!;
    final rarity = (p['rarity'] ?? 'normal') as String;
    final (rc, rsym) = switch (rarity) {
      'rare' => (UrPlantTheme.rarityRare, '✦'),
      'special_rare' => (UrPlantTheme.specialPurple, '✦✦'),
      _ => (UrPlantTheme.rarityNormal, '★'),
    };
    final desc = (isKh && (p['description_kh'] ?? '').toString().isNotEmpty)
        ? p['description_kh'].toString()
        : (p['description_en'] ?? p['description'] ?? '').toString();
    final nameKh = (p['name_kh'] ?? '').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: UrPlantTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: rc.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x1414281B), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(rsym, style: TextStyle(fontSize: 15, color: rc, fontWeight: FontWeight.w900)),
          const SizedBox(width: 6),
          Flexible(child: Text(p['name_en'] ?? '',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: UrPlantTheme.ink),
              textAlign: TextAlign.center)),
        ]),
        const SizedBox(height: 3),
        Text(p['scientific_name'] ?? '',
            style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, color: UrPlantTheme.inkFaint)),
        if (nameKh.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 5),
            child: Text(nameKh, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: UrPlantTheme.inkSoft))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: rc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(rarity.replaceAll('_', ' '),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: rc)),
        ),
        if (r.xpEarned > 0) ...[
          const SizedBox(height: 14),
          _xpBadge(r.xpEarned),
        ],
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(desc, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.6, color: UrPlantTheme.inkSoft)),
        ],
      ]),
    );
  }

  Widget _lowConfidence(AppLocalizations l) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: UrPlantTheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: UrPlantTheme.line, width: 1.5),
    ),
    child: Column(children: [
      Container(
        width: 62, height: 62,
        decoration: const BoxDecoration(color: Color(0xFFFDECCB), shape: BoxShape.circle),
        child: const Icon(Icons.psychology_alt_rounded, size: 30, color: UrPlantTheme.goldEdge),
      ),
      const SizedBox(height: 12),
      Text(l.result_low_confidence_title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: UrPlantTheme.ink)),
      const SizedBox(height: 16),
      _tip(Icons.zoom_in_rounded, l.result_low_confidence_tip_1),
      _tip(Icons.wb_sunny_rounded, l.result_low_confidence_tip_2),
      _tip(Icons.center_focus_weak_rounded, l.result_low_confidence_tip_3),
      _tip(Icons.blur_off_rounded, l.result_low_confidence_tip_4),
    ]),
  );

  Widget _tip(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
            color: UrPlantTheme.primarySoft, borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 16, color: UrPlantTheme.primaryDark),
      ),
      const SizedBox(width: 11),
      Expanded(child: Text(text,
          style: const TextStyle(fontSize: 13.5, color: UrPlantTheme.inkSoft, fontWeight: FontWeight.w600))),
    ]),
  );

  Widget _unmatched(IdentifyResult r, AppLocalizations l) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: UrPlantTheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: UrPlantTheme.line, width: 1.5),
    ),
    child: Column(children: [
      Container(
        width: 62, height: 62,
        decoration: const BoxDecoration(color: Color(0xFFEAE2FE), shape: BoxShape.circle),
        child: const Icon(Icons.explore_rounded, size: 30, color: UrPlantTheme.specialPurple),
      ),
      const SizedBox(height: 12),
      Text(l.result_unmatched_title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: UrPlantTheme.ink)),
      const SizedBox(height: 8),
      Text((r.messageEn != null && r.messageEn!.isNotEmpty) ? r.messageEn! : l.result_unmatched_body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, color: UrPlantTheme.inkSoft, height: 1.5)),
      if (r.xpEarned > 0) ...[const SizedBox(height: 16), _xpBadge(r.xpEarned)],
    ]),
  );

  Widget _safetyAlert(Map<String, dynamic> safety, AppLocalizations l, bool isKh) {
    final poisonous = safety['poisonous'] == true;
    final edible = safety['edible'] == true;
    final medicinal = safety['medicinal'] == true;
    final invasive = safety['invasive'] == true;
    final warning = safety['warning'] as String?;
    final color = poisonous ? UrPlantTheme.danger : UrPlantTheme.gold;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, size: 22, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(
            poisonous ? l.result_safety_poisonous : l.result_safety_notice,
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: color),
          )),
        ]),
        if (warning != null && warning.isNotEmpty) ...[
          const SizedBox(height: 7),
          Text(warning, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: UrPlantTheme.inkSoft, height: 1.45)),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: [
          _tag(l.result_tag_poisonous, poisonous, UrPlantTheme.danger),
          _tag(l.result_tag_edible, edible, UrPlantTheme.success),
          _tag(l.result_tag_medicinal, medicinal, UrPlantTheme.info),
          _tag(l.result_tag_invasive, invasive, UrPlantTheme.specialPurple),
        ]),
      ]),
    );
  }

  Widget _tag(String label, bool active, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
    decoration: BoxDecoration(
      color: active ? color.withValues(alpha: 0.15) : const Color(0xFFEFF3EF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: active ? color.withValues(alpha: 0.4) : UrPlantTheme.line),
    ),
    child: Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w800,
        color: active ? color : UrPlantTheme.inkFaint)),
  );

  Widget _achievements(List<Map<String, dynamic>> items, AppLocalizations l) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: UrPlantTheme.goldGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x40C77F0E), blurRadius: 14, offset: Offset(0, 6))],
    ),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 22),
        const SizedBox(width: 9),
        Text(l.result_achievements_unlocked,
            style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 10),
      ...items.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 17),
          const SizedBox(width: 9),
          Expanded(child: Text(a['name'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
          if ((a['xp'] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('+${a['xp']} XP', style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
        ]),
      )),
    ]),
  );
}
