import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../main.dart';
import '../achievements/achievements_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final xp = data['total_xp'] ?? 0;
                final level = data['level'] ?? 1;
                final nextLevelXp = (level * level) * 100;
                final currentLevelXp = ((level - 1) * (level - 1)) * 100;
                final progress = xp > 0
                    ? ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp)).clamp(0.0, 1.0)
                    : 0.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile header with gradient background
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: UrPlantTheme.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Avatar with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: user!.photoURL != null
                                    ? ClipOval(
                                        child: Image.network(user.photoURL!,
                                            width: 96, height: 96, fit: BoxFit.cover))
                                    : const Icon(Icons.person, size: 44, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              data['display_name'] ?? user.displayName ?? 'Explorer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _levelTitle(level),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // XP bar inside the gradient card
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Level $level',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$xp / $nextLevelXp XP',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                                    color: Colors.white,
                                    minHeight: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats grid — modern cards with colored icon circles
                      Row(
                        children: [
                          _modernStatCard('Total Scans', '${data['total_scans'] ?? 0}',
                              Icons.photo_camera, UrPlantTheme.primaryLight),
                          const SizedBox(width: 12),
                          _modernStatCard('Plants', '${data['plants_unlocked'] ?? 0}',
                              Icons.eco, UrPlantTheme.success),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _modernStatCard('Rare', '${data['rare_count'] ?? 0}',
                              Icons.diamond, UrPlantTheme.rarityRare),
                          const SizedBox(width: 12),
                          _modernStatCard('Earned', '${data['achievements_earned'] ?? 0}',
                              Icons.emoji_events, UrPlantTheme.raritySpecial),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Achievements tile
                      _menuTile(
                        icon: Icons.emoji_events,
                        iconColor: UrPlantTheme.warning,
                        iconBg: UrPlantTheme.warning.withValues(alpha: 0.1),
                        title: 'Achievements',
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                      ),
                      const SizedBox(height: 8),

                      // Language tile with modern chip-style toggle
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: UrPlantTheme.primaryAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.language, color: UrPlantTheme.primaryLight, size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Text('Language',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              ),
                              _langChip('EN', 'en', ref),
                              const SizedBox(width: 6),
                              _langChip('KH', 'kh', ref),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Delete account
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: UrPlantTheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline, color: UrPlantTheme.error, size: 22),
                        ),
                        title: const Text('Delete Account',
                            style: TextStyle(color: UrPlantTheme.error, fontWeight: FontWeight.w500)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Account?'),
                              content: const Text('This cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: UrPlantTheme.error))),
                              ],
                            ),
                          );
                          if (confirm == true && user != null) {
                            await user.delete();
                            if (Navigator.canPop(context)) Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _modernStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UrPlantTheme.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: UrPlantTheme.textPrimary)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(fontSize: 11, color: UrPlantTheme.textTertiary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _langChip(String label, String code, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _setLang(ref, code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: UrPlantTheme.primaryAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: UrPlantTheme.primaryMedium,
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: UrPlantTheme.textTertiary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }

  String _levelTitle(int level) {
    if (level <= 2) return '🌱 Seedling';
    if (level <= 5) return '🔍 Plant Scout';
    if (level <= 10) return '🧬 Botanist';
    if (level <= 20) return '🏆 Plant Master';
    if (level <= 35) return '🌿 Green Thumb';
    return '👑 Plant Legend';
  }

  void _setLang(WidgetRef ref, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    ref.read(localeProvider.notifier).state = Locale(code == 'kh' ? 'km' : 'en');
  }
}