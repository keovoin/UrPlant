import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../data/models/plant.dart';
import '../../l10n/app_localizations.dart';
import '../plant_detail/plant_detail_screen.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _rarityFilter = 'all';
  Set<String> _unlockedPlantIds = {};
  // "All" here means every species that exists (verified or AI-logged), not
  // just admin-verified — otherwise the guide looked empty next to your journal.

  @override
  void initState() {
    super.initState();
    _loadUserPlants();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserPlants() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('user_plants')
        .where('user_id', isEqualTo: uid)
        .get();
    if (!mounted) return;
    setState(() {
      _unlockedPlantIds = snapshot.docs.map((d) {
        final pid = (d.data()['plant_id'] ?? '').toString();
        // legacy documents stored the raw scientific name — normalize
        return pid.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: UrPlantTheme.canvas,
      appBar: AppBar(
        backgroundColor: UrPlantTheme.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l.encyclopedia_title),
      ),
      body: Column(
        children: [
          // ── Search pill ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: l.encyclopedia_search,
                prefixIcon: const Icon(Icons.search_rounded, size: 21, color: UrPlantTheme.inkFaint),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 19),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Rarity bubbles ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: [
                _bubble(l.encyclopedia_filter_all, 'all', UrPlantTheme.ink, const Color(0xFFE8E8EC)),
                const SizedBox(width: 8),
                _bubble('★ ${l.encyclopedia_filter_normal}', 'normal',
                    UrPlantTheme.rarityNormal, UrPlantTheme.primarySoft),
                const SizedBox(width: 8),
                _bubble('✦ ${l.encyclopedia_filter_rare}', 'rare',
                    UrPlantTheme.rarityRare, const Color(0xFFDDEBFD)),
                const SizedBox(width: 8),
                _bubble('✦✦ ${l.encyclopedia_filter_special}', 'special_rare',
                    UrPlantTheme.specialPurple, const Color(0xFFEAE2FE)),
                const SizedBox(width: 8),
                _bubble(l.history_status_matched, 'unlocked',
                    UrPlantTheme.goldEdge, const Color(0xFFFBEEDA)),
              ]),
            ),
          ),

          // ── Collection progress ────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('plants').snapshots(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length ?? 0;
              final unlocked = _unlockedPlantIds.length;
              final percent = total > 0 ? (unlocked / total).clamp(0.0, 1.0) : 0.0;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: UrPlantTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: UrPlantTheme.line, width: 1.5),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Text('🌿', style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Flexible(child: Text(l.collection_progress_label,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800,
                              color: UrPlantTheme.inkSoft))),
                      const Spacer(),
                      Text('$unlocked / $total',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                              color: UrPlantTheme.primaryDark)),
                    ]),
                    const SizedBox(height: 8),
                    LayoutBuilder(builder: (context, box) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: Stack(children: [
                            Container(height: 10, color: UrPlantTheme.primarySoft),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: percent),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => Container(
                                height: 10,
                                width: box.maxWidth * v,
                                decoration: const BoxDecoration(
                                  gradient: UrPlantTheme.leafGradient,
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ]),
                ),
              );
            },
          ),

          // ── Plant grid ─────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('plants')
                  .orderBy('updated_at', descending: true)
                  .limit(300)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _errorState();
                }
                if (!snapshot.hasData) return _gridSkeleton();

                final plants = (snapshot.data!.docs).where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final id = doc.id.toLowerCase();
                  final nameEn = (data['name_en'] ?? '').toString().toLowerCase();
                  final nameKh = (data['name_kh'] ?? '').toString().toLowerCase();
                  final sci = (data['scientific_name'] ?? '').toString().toLowerCase();

                  if (_search.isNotEmpty &&
                      !nameEn.contains(_search) &&
                      !nameKh.contains(_search) &&
                      !sci.contains(_search) &&
                      !id.contains(_search.replaceAll(' ', '_'))) {
                    return false;
                  }
                  if (_rarityFilter == 'unlocked' && !_unlockedPlantIds.contains(id)) return false;
                  if (_rarityFilter != 'all' && _rarityFilter != 'unlocked' &&
                      (data['rarity'] ?? 'normal') != _rarityFilter) {
                    return false;
                  }
                  return true;
                }).toList();

                if (plants.isEmpty) return _emptyState(l);

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 130),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final doc = plants[index];
                    final plant = Plant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                    final isUnlocked = _unlockedPlantIds.contains(doc.id.toLowerCase());
                    return StaggerIn(
                      key: ValueKey(doc.id),
                      index: index % 8,
                      child: _plantCard(plant, isUnlocked, l),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String label, String value, Color color, Color softBg) {
    final selected = _rarityFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _rarityFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? color : UrPlantTheme.line, width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.35), offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : UrPlantTheme.inkSoft,
          )),
      ),
    );
  }

  Widget _plantCard(Plant plant, bool isUnlocked, AppLocalizations l) {
    final (c, star) = _rarity(plant.rarity);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: plant.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withValues(alpha: isUnlocked ? 0.4 : 0.18), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x1214281B), blurRadius: 10, offset: Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(children: [
                if (isUnlocked && plant.thumbnailUrl.isNotEmpty)
                  Image.network(plant.thumbnailUrl, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph(c))
                else if (isUnlocked)
                  _ph(c)
                else
                  Container(
                    color: UrPlantTheme.surfaceCard,
                    child: Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.lock_outline_rounded, size: 28,
                            color: UrPlantTheme.inkFaint.withValues(alpha: 0.55)),
                        const SizedBox(height: 5),
                        Text(l.encyclopedia_locked_hint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10, color: UrPlantTheme.inkFaint,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUnlocked ? c : UrPlantTheme.inkFaint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(star,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ),
              ]),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.localizedName(false),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w800, color: UrPlantTheme.ink),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text(plant.scientificName,
                      style: const TextStyle(
                          fontSize: 10.5, fontStyle: FontStyle.italic, color: UrPlantTheme.inkFaint),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    if (!isUnlocked && plant.totalUnlocks > 0)
                      Text('${plant.totalUnlocks} found',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              color: UrPlantTheme.inkFaint)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, String) _rarity(String r) {
    switch (r) {
      case 'rare': return (UrPlantTheme.rarityRare, '✦');
      case 'special_rare': return (UrPlantTheme.specialPurple, '✦✦');
      default: return (UrPlantTheme.rarityNormal, '★');
    }
  }

  Widget _ph(Color c) => Container(
    color: c.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: Icon(Icons.eco_rounded, color: c.withValues(alpha: 0.5), size: 34),
  );

  Widget _errorState() => Center(
    child: Column(children: [
      const SizedBox(height: 90),
      Icon(Icons.cloud_off_rounded, size: 44, color: UrPlantTheme.inkFaint.withValues(alpha: 0.5)),
      const SizedBox(height: 10),
      Text(AppLocalizations.of(context).common_error,
          style: const TextStyle(color: UrPlantTheme.inkSoft, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      TextButton(onPressed: () => setState(() {}),
        child: Text(AppLocalizations.of(context).common_retry)),
    ]),
  );

  Widget _emptyState(AppLocalizations l) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 68, height: 68,
          decoration: const BoxDecoration(color: UrPlantTheme.primarySoft, shape: BoxShape.circle),
          child: const Icon(Icons.eco_rounded, size: 30, color: UrPlantTheme.primaryDark),
        ),
        const SizedBox(height: 13),
        Text(l.encyclopedia_empty_title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: UrPlantTheme.ink)),
        const SizedBox(height: 5),
        Text(l.encyclopedia_empty_body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: UrPlantTheme.inkFaint, height: 1.4)),
      ]),
    ),
  );

  Widget _gridSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.70, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFFE6EFE7), highlightColor: Colors.white,
        child: Container(decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18))),
      ),
    );
  }
}
