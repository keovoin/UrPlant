import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/plant.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  final Map<String, dynamic>? plantData;
  const PlantDetailScreen({super.key, required this.plantId, this.plantData});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? _plant;
  UserPlant? _userPlant;
  bool _loading = true;
  List<Map<String, dynamic>> _recentDiscoverers = [];

  @override
  void initState() {
    super.initState();
    _loadPlant();
  }

  Future<void> _loadPlant() async {
    try {
      if (widget.plantData != null) {
        _plant = Plant.fromMap(widget.plantId, widget.plantData!);
      } else {
        final doc = await FirebaseFirestore.instance.collection('plants').doc(widget.plantId).get();
        if (doc.exists) {
          _plant = Plant.fromMap(widget.plantId, doc.data()!);
        }
      }

      if (_plant != null) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final upDoc = await FirebaseFirestore.instance
              .collection('user_plants')
              .doc('${uid}_${widget.plantId}')
              .get();
          if (upDoc.exists) _userPlant = UserPlant.fromMap(upDoc.data()!);
        }

        final discoverersSnap = await FirebaseFirestore.instance
            .collection('user_plants')
            .where('plant_id', isEqualTo: widget.plantId)
            .orderBy('unlocked_at', descending: true)
            .limit(5)
            .get();
        _recentDiscoverers = discoverersSnap.docs.map((d) => d.data()).toList();
      }
    } catch (e) {
      debugPrint('Load plant error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Column(children: [
              Container(height: 280, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
              const SizedBox(height: 20),
              Container(height: 24, width: 200, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 16, width: 160, color: Colors.white),
            ]),
          ),
        ),
      );
    }
    if (_plant == null) {
      final l0 = AppLocalizations.of(context);
      return Scaffold(
        backgroundColor: UrPlantTheme.canvas,
        appBar: AppBar(backgroundColor: UrPlantTheme.canvas, surfaceTintColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.eco_rounded, size: 56, color: UrPlantTheme.inkFaint.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(l0.plant_not_found,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: UrPlantTheme.inkSoft)),
          ]),
        ),
      );
    }

    final plant = _plant!;
    final isUnlocked = _userPlant != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320, pinned: true, backgroundColor: UrPlantTheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                isUnlocked && _userPlant!.photoUrl.isNotEmpty
                    ? Image.network(_userPlant!.photoUrl, fit: BoxFit.cover)
                    : (plant.thumbnailUrl.isNotEmpty
                        ? Image.network(plant.thumbnailUrl, fit: BoxFit.cover)
                        : Container(color: UrPlantTheme.surfaceCard,
                            child: Icon(Icons.eco, size: 80, color: UrPlantTheme.primaryAccent.withValues(alpha: 0.3)))),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 120,
                  decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, UrPlantTheme.primary.withValues(alpha: 0.7)])))),
                if (!isUnlocked) _lockedOverlay(),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plant.localizedName(false), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(plant.scientificName, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: UrPlantTheme.textTertiary)),
                  if (plant.nameKh.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(plant.nameKh, style: const TextStyle(fontSize: 16, color: UrPlantTheme.textSecondary))),
                ])),
                _modernRarityPill(plant.rarity),
              ]),
              const SizedBox(height: 16),
              if (_recentDiscoverers.isNotEmpty) ...[_recentDiscoverersSection(), const SizedBox(height: 16)],
              if (!isUnlocked) _lockedCard() else ...[
                if (plant.description.isNotEmpty) ...[_modernSection(l.detail_details), const SizedBox(height: 8),
                  Text(plant.description, style: const TextStyle(fontSize: 14, height: 1.7, color: UrPlantTheme.textSecondary)), const SizedBox(height: 24)],
                if (plant.origin.isNotEmpty) ...[_modernSection(l.detail_origin), const SizedBox(height: 8),
                  Text(plant.origin, style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary)), const SizedBox(height: 24)],
                if (plant.characteristics.isNotEmpty) ...[_modernSection(l.detail_characteristics), const SizedBox(height: 8),
                  Text(plant.characteristics, style: const TextStyle(fontSize: 14, height: 1.6, color: UrPlantTheme.textSecondary)), const SizedBox(height: 24)],
                if (plant.habitat.isNotEmpty) ...[_modernSection(l.detail_habitat), const SizedBox(height: 8),
                  Text(plant.habitat, style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary)), const SizedBox(height: 24)],
                if (plant.uses.isNotEmpty) ...[_modernSection(l.detail_uses), const SizedBox(height: 8),
                  Text(plant.uses, style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary)), const SizedBox(height: 24)],
                if (plant.care.isNotEmpty) ...[_modernSection(l.detail_care_guide), const SizedBox(height: 12),
                  ..._careTiles(plant.care), const SizedBox(height: 24)],
                if (_userPlant != null) ...[_modernSection(l.detail_discovery), const SizedBox(height: 8),
                  Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: UrPlantTheme.surfaceCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5))),
                    child: Row(children: [
                      _miniStat('Discovered', '${_userPlant!.unlockedAt.year}-${_userPlant!.unlockedAt.month.toString().padLeft(2,'0')}-${_userPlant!.unlockedAt.day.toString().padLeft(2,'0')}'),
                      Container(width: 1, height: 30, color: UrPlantTheme.divider), _miniStat('Sightings', '${_userPlant!.sightingCount}'),
                    ])), const SizedBox(height: 24)],
              ],
              const SizedBox(height: 20),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _recentDiscoverersSection() => Container(
    padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: UrPlantTheme.surfaceCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5))),
    child: Row(children: [
      SizedBox(width: (_recentDiscoverers.length.clamp(0, 4) * 24 + 4).toDouble(), height: 36, child: Stack(
        children: List.generate(_recentDiscoverers.length.clamp(0, 4), (i) => Positioned(left: i * 18.0,
          child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: UrPlantTheme.surface, width: 2), color: UrPlantTheme.primaryAccent.withValues(alpha: 0.2)),
            child: Center(child: Icon(Icons.person, size: 16, color: UrPlantTheme.primaryMedium.withValues(alpha: 0.6)))))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).detail_found_by(_recentDiscoverers.length), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: UrPlantTheme.textPrimary)),
        const SizedBox(height: 2), Text(AppLocalizations.of(context).detail_join_them, style: const TextStyle(fontSize: 11, color: UrPlantTheme.textTertiary))])),
    ]));

  Widget _miniStat(String label, String value) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
    Text(label, style: const TextStyle(fontSize: 11, color: UrPlantTheme.textTertiary))]));

  Widget _modernSection(String text) => Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: UrPlantTheme.ink, letterSpacing: -0.3));

  List<Widget> _careTiles(Map<String, dynamic> care) {
    const keys = ['water', 'sunlight', 'soil', 'temperature', 'humidity'];
    final labels = {'water': AppLocalizations.of(context).detail_water, 'sunlight': AppLocalizations.of(context).detail_sunlight, 'soil': AppLocalizations.of(context).detail_soil, 'temperature': AppLocalizations.of(context).detail_temperature, 'humidity': AppLocalizations.of(context).detail_humidity};
    return keys.where((k) => care[k] != null && care[k].toString().isNotEmpty).map((k) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      SizedBox(width: 120, child: Text(labels[k]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: UrPlantTheme.textPrimary))),
      Expanded(child: Text(care[k].toString(), style: const TextStyle(fontSize: 14, color: UrPlantTheme.textSecondary)))]))).toList();
  }

  Widget _modernRarityPill(String rarity) {
    Color c; String t;
    switch (rarity) { case 'rare': c = UrPlantTheme.rarityRare; t = 'Rare'; break; case 'special_rare': c = UrPlantTheme.raritySpecial; t = 'Special Rare'; break; default: c = UrPlantTheme.rarityNormal; t = 'Normal'; }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c)));
  }

  Widget _lockedCard() => Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: UrPlantTheme.surfaceCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5))),
    child: Column(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: UrPlantTheme.textTertiary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(Icons.lock_outline, size: 32, color: UrPlantTheme.textTertiary.withValues(alpha: 0.5))),
      const SizedBox(height: 16), Text(AppLocalizations.of(context).detail_locked_body, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: UrPlantTheme.textTertiary, height: 1.4))]));

  Widget _lockedOverlay() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle), child: const Icon(Icons.lock_outline, color: Colors.white, size: 36)),
    const SizedBox(height: 12), Text('Locked', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.w600))]));
}