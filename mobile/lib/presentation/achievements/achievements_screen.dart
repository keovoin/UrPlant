import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: const Center(child: Text('Sign in to view achievements')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _modernFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _modernFilterChip('Earned', 'earned'),
                const SizedBox(width: 8),
                _modernFilterChip('Locked', 'locked'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadAchievements(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _listSkeleton();
                final achievements = snapshot.data!;
                if (achievements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64,
                            color: UrPlantTheme.textTertiary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('No achievements yet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                                color: UrPlantTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _achievementCard(achievements[index]),
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

  Future<List<Map<String, dynamic>>> _loadAchievements(String uid) async {
    try {
      final achSnapshot = await FirebaseFirestore.instance
          .collection('achievements')
          .orderBy('sort_order')
          .get();

      final userAchSnapshot = await FirebaseFirestore.instance
          .collection('user_achievements')
          .where('user_id', isEqualTo: uid)
          .get();

      final userAchievements = <String, Map<String, dynamic>>{};
      for (final doc in userAchSnapshot.docs) {
        userAchievements[doc.id.replaceFirst('${uid}_', '')] = doc.data();
      }

      final result = <Map<String, dynamic>>[];
      for (final doc in achSnapshot.docs) {
        final data = doc.data();
        final userData = userAchievements[doc.id];
        final earned = userData?['earned'] ?? false;
        final progress = userData?['progress'] ?? 0;
        final target = data['requirement_value'] ?? 0;

        if (_filter == 'earned' && !earned) continue;
        if (_filter == 'locked' && earned) continue;

        result.add({
          ...data,
          'achievement_id': doc.id,
          'earned': earned,
          'earned_at': userData?['earned_at'],
          'progress': progress,
          'progress_target': target,
        });
      }
      return result;
    } catch (e) {
      debugPrint('Load achievements error: $e');
      return [];
    }
  }

  Widget _modernFilterChip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? UrPlantTheme.primaryAccent.withValues(alpha: 0.12) : UrPlantTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? UrPlantTheme.primaryAccent.withValues(alpha: 0.4)
                : UrPlantTheme.divider.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? UrPlantTheme.primaryMedium : UrPlantTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _achievementCard(Map<String, dynamic> ach) {
    final earned = ach['earned'] == true;
    final progress = ach['progress'] ?? 0;
    final target = ach['progress_target'] ?? 0;
    final progressPercent = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final isHidden = ach['is_hidden'] == true && !earned;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: earned ? UrPlantTheme.surfaceCard : UrPlantTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: earned
              ? UrPlantTheme.primaryAccent.withValues(alpha: 0.3)
              : UrPlantTheme.divider.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: earned
                  ? UrPlantTheme.primaryLight.withValues(alpha: 0.1)
                  : UrPlantTheme.textTertiary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              earned ? Icons.emoji_events : Icons.lock_outline,
              color: earned ? UrPlantTheme.primaryLight
                  : UrPlantTheme.textTertiary.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHidden ? '???' : (ach['name_en'] ?? ''),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: earned ? UrPlantTheme.textPrimary : UrPlantTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                if (isHidden)
                  const Text('Keep exploring to reveal',
                      style: TextStyle(fontSize: 12, color: UrPlantTheme.textTertiary))
                else ...[
                  Text(
                    ach['description_en'] ?? '',
                    style: const TextStyle(fontSize: 12, color: UrPlantTheme.textSecondary, height: 1.3),
                  ),
                  if (!earned && target > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: UrPlantTheme.divider,
                              color: UrPlantTheme.primaryLight,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$progress/$target',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: UrPlantTheme.textTertiary),
                        ),
                      ],
                    ),
                  ],
                  if (earned && ach['earned_at'] != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: UrPlantTheme.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate((ach['earned_at'] as dynamic).toDate()),
                          style: const TextStyle(fontSize: 11, color: UrPlantTheme.primaryLight,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Earned check
          if (earned)
            const Icon(Icons.verified, color: UrPlantTheme.primaryLight, size: 22),
        ],
      ),
    );
  }

  Widget _listSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}