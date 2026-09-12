import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../data/models/plant.dart';
import '../../l10n/app_localizations.dart';
import '../camera/camera_screen.dart';
import '../plant_detail/plant_detail_screen.dart';
import '../shell/app_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final h = DateTime.now().hour;
    final greet = h < 12 ? l.greeting_morning : (h < 17 ? l.greeting_afternoon : l.greeting_evening);
    final emoji = h < 12 ? '☀️' : (h < 17 ? '🌤️' : '🌙');

    return Scaffold(
      backgroundColor: UrPlantTheme.canvas,
      body: RefreshIndicator(
        color: UrPlantTheme.primary,
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 150),
          children: [
            // ── Brand row ──────────────────────────────────────
            StaggerIn(index: 0, child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: UrPlantTheme.leafGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 9),
              Text(l.app_name, style: theme.textTheme.titleLarge),
              const Spacer(),
            ])),
            const SizedBox(height: 16),

            // ── Greeting ───────────────────────────────────────
            StaggerIn(index: 1, child: Row(children: [
              Text('$emoji  ', style: const TextStyle(fontSize: 18)),
              Flexible(child: Text(greet, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
            ])),
            const SizedBox(height: 2),
            StaggerIn(index: 2, child: Text(l.home_hero_title, style: theme.textTheme.headlineMedium)),
            const SizedBox(height: 18),

            // ── Hero scan card ─────────────────────────────────
            StaggerIn(index: 3, child: _HeroCard(l: l)),
            const SizedBox(height: 24),

            // ── Stats ──────────────────────────────────────────
            if (uid != null) StaggerIn(index: 4, child: _StatsBlock(uid: uid, l: l)),
            const SizedBox(height: 26),

            // ── Collection header ──────────────────────────────
            StaggerIn(index: 5, child: Row(children: [
              Expanded(child: Text(l.home_your_collection, style: theme.textTheme.titleLarge)),
              TextButton(
                onPressed: () => ref.read(selectedTabProvider.notifier).state = 1,
                style: TextButton.styleFrom(
                  foregroundColor: UrPlantTheme.primaryDark,
                  textStyle: const TextStyle(fontWeight: FontWeight.w800)),
                child: Text(l.home_view_all),
              ),
            ])),
            const SizedBox(height: 4),

            // ── Collection rail ────────────────────────────────
            if (uid == null)
              const SizedBox(height: 90)
            else
              StaggerIn(index: 6, child: _CollectionRail(uid: uid, l: l)),

            const SizedBox(height: 22),
            const Center(child: LeafDivider(width: 180)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final AppLocalizations l;
  const _HeroCard({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        gradient: UrPlantTheme.heroGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Color(0x3D0F3D20), blurRadius: 26, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 27),
              ),
              Positioned(
                top: -12, right: -18,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(Icons.eco_rounded,
                    color: Colors.white.withValues(alpha: 0.16), size: 78),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(l.home_hero_title,
            style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
          const SizedBox(height: 6),
          Text(l.home_hero_subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          ChunkyButton(
            color: UrPlantTheme.gold,
            edge: UrPlantTheme.goldEdge,
            foreground: const Color(0xFF3A2A05),
            expanded: false,
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CameraScreen(), fullscreenDialog: true)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.photo_camera_rounded, size: 20),
              const SizedBox(width: 9),
              Text(l.home_hero_cta, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatsBlock extends StatelessWidget {
  final String uid;
  final AppLocalizations l;
  const _StatsBlock({required this.uid, required this.l});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _skeleton();
        final d = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        final xp = (d['total_xp'] ?? 0) as int;
        final level = (d['level'] ?? 1) as int;
        final tiles = <(String, String, IconData, Color, Color)>[
          (l.profile_stat_scans, '${d['total_scans'] ?? 0}', Icons.photo_camera_rounded, UrPlantTheme.primary, UrPlantTheme.primarySoft),
          (l.profile_stat_unlocked, '${d['plants_unlocked'] ?? 0}', Icons.eco_rounded, UrPlantTheme.info, const Color(0xFFDDEBFD)),
          (l.profile_stat_rare, '${((d['rare_count'] ?? 0) as int) + ((d['special_rare_count'] ?? 0) as int)}', Icons.auto_awesome_rounded, UrPlantTheme.specialPurple, const Color(0xFFEAE2FE)),
          ('XP', '$xp', Icons.bolt_rounded, UrPlantTheme.goldEdge, const Color(0xFFFBEEDA)),
        ];
        final base = (level - 1) * (level - 1) * 100;
        final next = level * level * 100;
        final p = ((xp - base) / (next - base)).clamp(0.0, 1.0).toDouble();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: UrPlantTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: UrPlantTheme.line, width: 1.5),
          ),
          child: Column(children: [
            Row(children: tiles.map((t) => Expanded(child: _statTile(t))).toList()),
            if (xp > 0) ...[
              const SizedBox(height: 12),
              Row(children: [
                Text(l.profile_level(level),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: UrPlantTheme.primaryDark)),
                const Spacer(),
                Text('$xp/$next',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: UrPlantTheme.inkFaint)),
              ]),
              const SizedBox(height: 5),
              LayoutBuilder(builder: (context, box) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 9,
                    child: Stack(children: [
                      Container(height: 9, color: UrPlantTheme.primarySoft),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: p),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Container(
                          height: 9,
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
            ],
          ]),
        );
      },
    );
  }

  Widget _statTile((String, String, IconData, Color, Color) t) {
    final (label, value, icon, fg, bg) = t;
    return Column(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 19, color: fg),
      ),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: UrPlantTheme.ink, height: 1.1)),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: UrPlantTheme.inkFaint)),
    ]);
  }

  Widget _skeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6EFE7), highlightColor: Colors.white,
      child: Container(height: 96,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
    );
  }
}

class _CollectionRail extends StatelessWidget {
  final String uid;
  final AppLocalizations l;
  const _CollectionRail({required this.uid, required this.l});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_plants')
            .where('user_id', isEqualTo: uid)
            .orderBy('unlocked_at', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _skeleton();
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return _empty();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final up = UserPlant.fromMap(docs[i].data() as Map<String, dynamic>);
              return _CollectionCard(userPlant: up);
            },
          );
        },
      ),
    );
  }

  Widget _empty() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    decoration: BoxDecoration(
      color: UrPlantTheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: UrPlantTheme.line, width: 1.5),
    ),
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(color: UrPlantTheme.primarySoft, borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.eco_rounded, color: UrPlantTheme.primaryDark, size: 25),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.encyclopedia_empty_title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: UrPlantTheme.ink)),
          const SizedBox(height: 3),
          Text(l.encyclopedia_empty_body,
            style: const TextStyle(fontSize: 12.5, color: UrPlantTheme.inkSoft, height: 1.35)),
        ]),
      ),
    ]),
  );

  Widget _skeleton() => Shimmer.fromColors(
    baseColor: const Color(0xFFE6EFE7), highlightColor: Colors.white,
    child: Row(children: List.generate(3, (_) => Expanded(
      child: Container(height: 190, margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))))),
  );
}

class _CollectionCard extends StatelessWidget {
  final UserPlant userPlant;
  const _CollectionCard({required this.userPlant});

  (Color, Color, String) _rarity() {
    switch (userPlant.rarity) {
      case 'rare':
        return (UrPlantTheme.rarityRare, const Color(0xFFDDEBFD), '✦');
      case 'special_rare':
        return (UrPlantTheme.specialPurple, const Color(0xFFEAE2FE), '✦✦');
      default:
        return (UrPlantTheme.rarityNormal, UrPlantTheme.primarySoft, '★');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (c, bg, star) = _rarity();
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => PlantDetailScreen(plantId: userPlant.plantId))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 122,
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withValues(alpha: 0.4), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x1414281B), blurRadius: 12, offset: Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: userPlant.thumbnailUrl.isNotEmpty
                  ? Image.network(userPlant.thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(c))
                  : _placeholder(c),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(9, 6, 7, 7),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(color: c.withValues(alpha: 0.3))),
              ),
              child: Row(children: [
                Expanded(child: Text(
                  userPlant.displayName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c))),
                Text(star, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w900)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Color c) => Container(
    color: c.withValues(alpha: 0.08),
    alignment: Alignment.center,
    child: Icon(Icons.eco_rounded, color: c.withValues(alpha: 0.45), size: 32),
  );
}
