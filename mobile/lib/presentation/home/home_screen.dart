import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../data/models/plant.dart';
import '../camera/camera_screen.dart';
import '../encyclopedia/encyclopedia_screen.dart';
import '../plant_detail/plant_detail_screen.dart';
import '../shell/app_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: UrPlantTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('UrPlant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => ref.read(selectedTabProvider.notifier).state = 3,
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please sign in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time-based greeting
                  Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: 14,
                      color: UrPlantTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to discover?',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),

                  // Hero card — glassmorphic style
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: UrPlantTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: UrPlantTheme.primaryMedium.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Identify any plant instantly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Point your camera at a plant and let AI do the magic',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CameraScreen())),
                          icon: const Icon(Icons.camera_alt, size: 20),
                          label: const Text('Scan Plant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: UrPlantTheme.primaryMedium,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Quick Stats — modern pills
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _statsSkeleton();
                      final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      return Row(
                        children: [
                          _modernStatPill('Scans', '${data['total_scans'] ?? 0}', Icons.photo_camera_outlined),
                          const SizedBox(width: 10),
                          _modernStatPill('Collection', '${data['plants_unlocked'] ?? 0}', Icons.eco_outlined),
                          const SizedBox(width: 10),
                          _modernStatPill('Rare', '${data['rare_count'] ?? 0}', Icons.diamond_outlined),
                          const SizedBox(width: 10),
                          _modernStatPill('Earned', '${data['achievements_earned'] ?? 0}', Icons.emoji_events_outlined),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Section header
                  Row(
                    children: [
                      Text('Your Collection',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => ref.read(selectedTabProvider.notifier).state = 1,
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Collection cards
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_plants')
                        .where('user_id', isEqualTo: uid)
                        .orderBy('unlocked_at', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _collectionSkeleton();
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: UrPlantTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.eco, size: 48, color: UrPlantTheme.primaryAccent.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text('No plants yet',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: UrPlantTheme.textSecondary)),
                              const SizedBox(height: 4),
                              Text('Take your first photo to start your collection',
                                  style: TextStyle(fontSize: 13, color: UrPlantTheme.textTertiary)),
                            ],
                          ),
                        );
                      }
                      return SizedBox(
                        height: 172,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 14),
                          itemBuilder: (context, i) {
                            final up = UserPlant.fromMap(docs[i].data() as Map<String, dynamic>);
                            return _CollectionCard(userPlant: up);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _modernStatPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.6)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: UrPlantTheme.primaryLight),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: UrPlantTheme.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _statsSkeleton() {
    return Row(
      children: List.generate(4, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _collectionSkeleton() {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final UserPlant userPlant;
  const _CollectionCard({required this.userPlant});

  Color _rarityColor(String? r) {
    switch (r) {
      case 'rare':
        return UrPlantTheme.rarityRare;
      case 'special_rare':
        return UrPlantTheme.raritySpecial;
      default:
        return UrPlantTheme.rarityNormal;
    }
  }

  Color _rarityBg(String? r) {
    switch (r) {
      case 'rare':
        return const Color(0xFFEFF6FF);
      case 'special_rare':
        return const Color(0xFFFFFBF0);
      default:
        return UrPlantTheme.surfaceCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: userPlant.plantId))),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: _rarityBg(userPlant.rarity),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (userPlant.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(userPlant.thumbnailUrl, width: 130, height: 110, fit: BoxFit.cover),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Icon(Icons.eco, size: 48, color: _rarityColor(userPlant.rarity).withValues(alpha: 0.5)),
              ),
            const SizedBox(height: 6),
            _rarityBadge(userPlant.rarity),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _rarityBadge(String? r) {
    String icon = '★';
    Color color = UrPlantTheme.rarityNormal;
    if (r == 'rare') {
      icon = '✦';
      color = UrPlantTheme.rarityRare;
    }
    if (r == 'special_rare') {
      icon = '✦✦';
      color = UrPlantTheme.raritySpecial;
    }
    return Text(icon, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w700));
  }
}