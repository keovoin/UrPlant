import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// UrPlant — "Forest Friend" design system.
/// Playful Guide DNA (the approved khfinder.com language) translated to a
/// plant world: warm canvas, chunky buttons with press-physics, category
/// colors, rounded friendly type, kbach-inspired botanical ornaments.
class UrPlantTheme {
  // ─── Canvas & ink ───────────────────────────────────────────────
  static const canvas = Color(0xFFF6FBF6);        // soft leaf-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceCard = Color(0xFFF1F8F1);
  static const ink = Color(0xFF14281B);            // deep forest ink
  static const inkSoft = Color(0xFF4B5F51);
  static const inkFaint = Color(0xFF93A699);
  static const line = Color(0xFFDDE9DE);

  // ─── Brand greens ───────────────────────────────────────────────
  static const primary = Color(0xFF1B7A3D);        // fresh leaf
  static const primaryDark = Color(0xFF12582B);    // deep forest
  static const primarySoft = Color(0xFFD8F0DC);
  static const primaryEdge = Color(0xFF0E4522);    // chunky button bottom

  // ─── Reward / gamification ─────────────────────────────────────
  static const gold = Color(0xFFF4A82C);           // XP
  static const goldEdge = Color(0xFFC77F0E);
  static const rareBlue = Color(0xFF2E7DE0);
  static const rareBlueEdge = Color(0xFF1B5BAE);
  static const specialPurple = Color(0xFF7C4DFF);
  static const specialPurpleEdge = Color(0xFF5B32CC);

  // Rarity palette (normal=green, rare=blue, special=purple+gold)
  static const rarityNormal = primary;
  static const rarityRare = rareBlue;
  static const raritySpecial = Color(0xFFF4A82C);

  // ─── Compat aliases (old names → new palette; screens migrate over time)
  static const textPrimary = ink;
  static const textSecondary = inkSoft;
  static const textTertiary = inkFaint;
  static const divider = line;
  static const background = canvas;
  static const primaryMedium = primary;
  static const primaryLight = Color(0xFF2E9E52);
  static const primaryAccent = Color(0xFF7CCB93);
  static const error = danger;
  static const warning = gold;
  static const xpGold = gold;

  // Accents for pills/tags
  static const danger = Color(0xFFE5484D);
  static const success = Color(0xFF2FAE66);
  static const info = rareBlue;
  static const edit = specialPurple;

  static const LinearGradient leafGradient = LinearGradient(
    colors: [Color(0xFF166B36), Color(0xFF1B7A3D), Color(0xFF2E9E52)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF0B429), Color(0xFFF4A82C), Color(0xFFE5484D)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // Back-compat aliases used by camera / identifying / auth screens
  static const LinearGradient primaryGradient = leafGradient;
  static const LinearGradient accentGradient = goldGradient;

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F3D20), Color(0xFF12582B), Color(0xFF1B7A3D)],
    begin: Alignment.topCenter, end: Alignment.bottomRight,
  );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: gold,
        surface: surface,
        onSurface: ink,
        error: danger,
      ),
      scaffoldBackgroundColor: canvas,
    );
    final text = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displaySmall: GoogleFonts.koulen(
        fontSize: 30, fontWeight: FontWeight.w400, color: ink, letterSpacing: 0.5),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 26, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.5),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 22, fontWeight: FontWeight.w800, color: ink, letterSpacing: -0.3),
      titleLarge: GoogleFonts.nunito(
        fontSize: 19, fontWeight: FontWeight.w800, color: ink),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w700, color: ink),
      bodyLarge: GoogleFonts.nunito(fontSize: 15, color: ink, height: 1.5),
      bodyMedium: GoogleFonts.nunito(fontSize: 14, color: inkSoft, height: 1.5),
      bodySmall: GoogleFonts.nunito(fontSize: 12, color: inkFaint),
      labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800),
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: canvas,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas, surfaceTintColor: Colors.transparent,
        elevation: 0, centerTitle: false, foregroundColor: ink,
        titleTextStyle: text.headlineSmall,
      ),
      cardTheme: CardThemeData(
        elevation: 0, color: surface, surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: inkFaint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line, width: 1.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: line, width: 1.5)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2.5)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primarySoft,
        labelStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1.5, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink, contentTextStyle: GoogleFonts.nunito(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface, surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.titleLarge,
      ),
    );
  }
}

/// Chunky "Duolingo-physics" button — hard bottom edge, presses down.
class ChunkyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color edge;
  final Color foreground;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool expanded;

  const ChunkyButton({
    super.key, required this.child, this.onPressed,
    this.color = UrPlantTheme.primary,
    this.edge = UrPlantTheme.primaryEdge,
    this.foreground = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
    this.radius = 16, this.expanded = true,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true, enabled: widget.onPressed != null,
      child: GestureDetector(
        onTapDown: widget.onPressed == null ? null : (_) => setState(() => _down = true),
        onTapUp: widget.onPressed == null ? null : (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _down ? 3 : 0, 0),
          width: widget.expanded ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? widget.color.withValues(alpha: 0.45) : widget.color,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.edge.withValues(alpha: widget.onPressed == null ? 0.4 : 1), width: 1.5),
            boxShadow: [
              BoxShadow(color: widget.edge.withValues(alpha: widget.onPressed == null ? 0.2 : (_down ? 0.4 : 1)),
                offset: Offset(0, _down ? 1 : 4)),
            ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: widget.foreground, fontWeight: FontWeight.w800, fontSize: 16),
            child: IconTheme.merge(
              data: IconThemeData(color: widget.foreground, size: 20),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass floating search / card pill.
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassPill({super.key, required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: UrPlantTheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: UrPlantTheme.line),
        boxShadow: [BoxShadow(color: const Color(0x1F14281B), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }
}

/// Botanical divider — a row of leaf dots between hairlines (kbach-flavored).
class LeafDivider extends StatelessWidget {
  final double width;
  const LeafDivider({super.key, this.width = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(children: [
        const Expanded(child: Divider(color: UrPlantTheme.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: List.generate(3, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.landscape_rounded,
              size: i == 1 ? 13 : 9,
              color: i == 1 ? UrPlantTheme.primary : UrPlantTheme.primary.withValues(alpha: 0.4)),
          ))),
        ),
        const Expanded(child: Divider(color: UrPlantTheme.line)),
      ]),
    );
  }
}


/// Staggered fade+rise entrance (Playful Guide motion DNA).
class StaggerIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  const StaggerIn({super.key, required this.child, this.index = 0, this.delay = const Duration(milliseconds: 55)});

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, 0.10), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay * widget.index, () { if (mounted) _c.forward(); });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
