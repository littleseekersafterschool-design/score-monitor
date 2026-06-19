import 'package:flutter/material.dart';

class MonitorTheme {
  // Brand colors — white-based with blue, red, yellow accents
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF0F2F5);
  static const Color border = Color(0xFFE2E6EA);

  // Text
  static const Color textPrimary = Color(0xFF1A2233);
  static const Color textSecondary = Color(0xFF6B7685);
  static const Color textMuted = Color(0xFFA0AAB4);

  // Three brand accent colors for kids
  static const Color blue = Color(0xFF3B82F6);
  static const Color red = Color(0xFFEF4444);
  static const Color yellow = Color(0xFFF59E0B);

  // Softer tints for backgrounds
  static const Color blueBg = Color(0xFFDBEAFE);
  static const Color redBg = Color(0xFFFEE2E2);
  static const Color yellowBg = Color(0xFFFEF3C7);

  // Score colors mapped to the 3 brand colors
  static const Color scoreUp = Color(0xFF3B82F6); // blue = great
  static const Color scoreUpBg = Color(0xFFDBEAFE);
  static const Color scoreDown = Color(0xFFEF4444); // red = needs work
  static const Color scoreDownBg = Color(0xFFFEE2E2);
  static const Color scoreFlat = Color(0xFFF59E0B); // yellow = ok
  static const Color scoreFlatBg = Color(0xFFFEF3C7);

  // Accent (primary action)
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentBg = Color(0xFFDBEAFE);

  // Goal category colors — brighter kid-friendly palette
  static const Color green = Color(0xFF22C55E);
  static const Color orange = Color(0xFFF97316);
  static const Color purple = Color(0xFFA855F7);
  static const Color teal = Color(0xFF14B8A6);
  static const Color pink = Color(0xFFEC4899);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bgLight,
        colorSchemeSeed: blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: white,
          indicatorColor: blueBg,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: blue,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: blue, width: 2),
          ),
          hintStyle: const TextStyle(color: textMuted),
        ),
      );

  static Color getGoalColor(String colorName) {
    switch (colorName) {
      case 'green':
        return green;
      case 'blue':
        return blue;
      case 'orange':
        return orange;
      case 'yellow':
        return yellow;
      case 'purple':
        return purple;
      case 'red':
        return red;
      case 'pink':
        return pink;
      case 'teal':
        return teal;
      default:
        return blue;
    }
  }

  static IconData getGoalIcon(String iconName) {
    switch (iconName) {
      case 'heart':
        return Icons.favorite_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'safety':
        return Icons.security_rounded;
      case 'play':
        return Icons.sports_esports_rounded;
      case 'people':
        return Icons.people_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      case 'seedling':
        return Icons.eco_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  static Color getScoreColor(double score) {
    if (score >= 4.0) return blue;
    if (score >= 3.0) return yellow;
    return red;
  }

  static Color getScoreBgColor(double score) {
    if (score >= 4.0) return blueBg;
    if (score >= 3.0) return yellowBg;
    return redBg;
  }

  static Color getChangeColor(double change) {
    if (change > 0.05) return blue;
    if (change < -0.05) return red;
    return yellow;
  }

  static IconData getChangeIcon(double change) {
    if (change > 0.05) return Icons.trending_up_rounded;
    if (change < -0.05) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  static String getChangePrefix(double change) {
    if (change > 0.05) return '+';
    return '';
  }

  /// Score emoji for kids
  static String getScoreEmoji(double score) {
    if (score >= 4.5) return '\u{1F929}'; // star-struck
    if (score >= 4.0) return '\u{1F60A}'; // smiling
    if (score >= 3.0) return '\u{1F642}'; // slightly smiling
    if (score >= 2.0) return '\u{1F914}'; // thinking
    if (score > 0) return '\u{1F4AA}'; // muscle (ganbare!)
    return '\u{2796}'; // minus (no data)
  }
}
