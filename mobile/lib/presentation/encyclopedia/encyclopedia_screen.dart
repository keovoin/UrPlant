import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../data/models/plant.dart';
import '../plant_detail/plant_detail_screen.dart';

class EncyclopediaScreen extends StatefulWidget {
  const EncyclopediaScreen({super.key});

  @override
  State<EncyclopediaScreen> createState() => _EncyclopediaScreenState();
}

class _EncyclopediaScreenState extends State<EncyclopediaScreen> {
  String _search = '';
  String _rarityFilter = 'all';
  final _searchCtrl = TextEditingController();
  Set<String> _unlockedPlantIds = {};

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
    setState(() {
      _unlockedPlantIds = snapshot.docs.map((d) => d.data()['plant_id'] as String).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encyclopedia'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search plants...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Rarity filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _modernFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _modernFilterChip('★ Normal', 'normal'),
                const SizedBox(width: 8),
                _modernFilterChip('✦ Rare', 'rare'),
                const SizedBox(width: 8),
                _modernFilterChip('✦✦ Special', 'special_rare'),
              ],
            ),
          ),

          // Collection progress
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('plants')
                .where('verified', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length ?? 0;
              final unlocked = _unlockedPlantIds.length;
              final percent = total > 0 ? (unlocked / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: UrPlantTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                value: percent,
                                strokeWidth: 4,
                                backgroundColor: UrPlantTheme.divider,
                                color: UrPlantTheme.primaryLight,
                              ),
                            ),
                            Text(
                              '${(percent * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: UrPlantTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collection Progress',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: UrPlantTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$unlocked of $total plants unlocked',
                              style: const TextStyle(
                                fontSize: 12,
                                color: UrPlantTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Plant grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('plants')
                  .where('verified', isEqualTo: true)
                  .orderBy('name_en')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48,
                            color: UrPlantTheme.textTertiary.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text('Could not load plants',
                            style: TextStyle(color: UrPlantTheme.textSecondary)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) return _gridSkeleton();

                var plants = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nameEn = (data['name_en'] ?? '').toString().toLowerCase();
                  final nameKh = (data['name_kh'] ?? '').toString().toLowerCase();
                  final sci = (data['scientific_name'] ?? '').toString().toLowerCase();
                  final rarity = data['rarity'] ?? 'normal';

                  if (_search.isNotEmpty) {
                    if (!nameEn.contains(_search) &&
                        !nameKh.contains(_search) &&
                        !sci.contains(_search)) {
                      return false;
                    }
                  }

                  if (_rarityFilter != 'all' && rarity != _rarityFilter) return false;

                  return true;
                }).toList();

                if (plants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 64,
                            color: UrPlantTheme.primaryAccent.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No plants found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: UrPlantTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final doc = plants[index];
                    final plant =
                        Plant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                    final isUnlocked = _unlockedPlantIds.contains(doc.id);
                    return _plantCard(plant, isUnlocked);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernFilterChip(String label, String value) {
    final selected = _rarityFilter == value;
    Color color;
    switch (value) {
      case 'rare':
        color = UrPlantTheme.rarityRare;
        break;
      case 'special_rare':
        color = UrPlantTheme.raritySpecial;
        break;
      default:
        color = UrPlantTheme.primaryMedium;
    }

    return GestureDetector(
      onTap: () => setState(() => _rarityFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : UrPlantTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : UrPlantTheme.divider.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? color : UrPlantTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _plantCard(Plant plant, bool isUnlocked) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: plant.id)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 3,
              child: isUnlocked
                  ? (plant.thumbnailUrl.isNotEmpty
                      ? Image.network(plant.thumbnailUrl,
                          width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          color: UrPlantTheme.primaryAccent.withValues(alpha: 0.08),
                          child: Center(
                            child: Icon(Icons.eco, size: 40,
                                color: UrPlantTheme.primaryAccent.withValues(alpha: 0.4)),
                          ),
                        ))
                  : Container(
                      color: UrPlantTheme.surfaceCard,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_outline, size: 32,
                                color: UrPlantTheme.textTertiary.withValues(alpha: 0.5)),
                            const SizedBox(height: 6),
                            Text('Find to unlock',
                                style: TextStyle(
                                    fontSize: 10, color: UrPlantTheme.textTertiary)),
                          ],
                        ),
                      ),
                    ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.nameEn,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: UrPlantTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.scientificName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: UrPlantTheme.textTertiary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _rarityBadge(plant.rarity),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        t = '✦✦ Special';
        break;
      default:
        c = UrPlantTheme.rarityNormal;
        t = '★ Normal';
    }
    return Text(t,
        style: TextStyle(
            fontSize: 10, color: c, fontWeight: FontWeight.w700));
  }

  Widget _gridSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}