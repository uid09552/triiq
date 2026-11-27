import 'package:flutter/material.dart';

/// The design system from `Design.md` (repo root), as code. Every colour,
/// radius, spacing step and font family the app uses comes from here; see
/// [buildAppTheme] for how they map onto Material.
///
/// Design.md defines the light palette only. The dark values below are
/// derived from it (same roles, a lighter indigo for contrast on dark).
abstract final class DesignColors {
  // Light (Design.md "Colors").
  static const primary = Color(0xFF6366F1);
  static const primaryHover = Color(0xFF4F46E5);
  static const secondary = Color(0xFF20970B);
  static const neutral = Color(0xFF9C9C9C);
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const border = Color(0xFFE8E8EC);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Chips: gray-100 fill, gray-600 text.
  static const chipFill = Color(0xFFF4F4F5);
  static const chipText = Color(0xFF52525B);

  /// Flat dark surface for headers and avatars that carry white text (the
  /// former indigo→amber gradients). Same in both modes, bordered in dark.
  static const ink = Color(0xFF111114);
  static const inkDark = Color(0xFF26262C);

  // Dark, derived.
  static const darkPrimary = Color(0xFF818CF8);
  static const darkBackground = Color(0xFF0F0F12);
  static const darkSurface = Color(0xFF18181B);
  static const darkTextPrimary = Color(0xFFF4F4F5);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkBorder = Color(0xFF2E2E35);
  static const darkChipFill = Color(0xFF27272A);
  static const darkChipText = Color(0xFFD4D4D8);
}

/// Colours that carry data, not interaction (Design.md "Data colours").
/// Categorical series use the Okabe–Ito palette, which stays apart for
/// the common colour-vision deficiencies; each has a lighter variant for
/// dark surfaces. Indigo is never a data colour.
abstract final class DesignData {
  // Okabe–Ito.
  static const blue = Color(0xFF0072B2);
  static const blueDark = Color(0xFF56B4E9);
  static const orange = Color(0xFFE69F00);
  static const orangeDark = Color(0xFFF0C060);
  static const green = Color(0xFF009E73);
  static const greenDark = Color(0xFF3CCB9E);
  static const vermillion = Color(0xFFD55E00);
  static const vermillionDark = Color(0xFFFF8F4D);
  static const purple = Color(0xFFCC79A7);
  static const purpleDark = Color(0xFFE5A3C8);

  static Color _pick(bool dark, Color light, Color onDark) =>
      dark ? onDark : light;

  /// Per sport: swim blue, ride orange, run green.
  static Color swim(bool dark) => _pick(dark, blue, blueDark);
  static Color ride(bool dark) => _pick(dark, orange, orangeDark);
  static Color run(bool dark) => _pick(dark, green, greenDark);

  /// Per stream or metric: power, heart rate, speed/HRV, sleep.
  static Color power(bool dark) => _pick(dark, orange, orangeDark);
  static Color heart(bool dark) => _pick(dark, vermillion, vermillionDark);
  static Color speed(bool dark) => _pick(dark, green, greenDark);
  static Color sleep(bool dark) => _pick(dark, purple, purpleDark);

  /// Two things compared (A, B).
  static const compareA = blue;
  static const compareB = vermillion;

  /// Load risk: safe, risky (high uses the theme's error colour).
  static const safe = green;
  static const risky = orange;

  /// A "within the usual range" band behind a line.
  static const safeBand = Color(0x33009E73);

  /// Severity steps, mild → strong.
  static const severity = [orange, vermillion, Color(0xFFB22222)];

  /// Workout intensity by % of threshold, like power zones: recovery,
  /// endurance, tempo, threshold, VO2max, anaerobic.
  static const intensity = [
    Color(0xFF7C8DA6),
    Color(0xFF3FA66B),
    Color(0xFFD6A400),
    Color(0xFFEF8A17),
    Color(0xFFE5484D),
    Color(0xFF8E4EC6),
  ];

  /// Viridis at 4 stops (sequential, colour-blind safe): more load stands
  /// out further from the background.
  static const viridisLight = [
    Color(0xFFB5DE2B),
    Color(0xFF35B779),
    Color(0xFF26828E),
    Color(0xFF3E4A89),
  ];
  static const viridisDark = [
    Color(0xFF31688E),
    Color(0xFF21918C),
    Color(0xFF5EC962),
    Color(0xFFFDE725),
  ];

  /// The hover shadow (Design.md: 0 8px 30px rgba(0,0,0,0.08)).
  static const hoverShadow = Color(0x14000000);
}

/// Design.md "Border Radius".
abstract final class DesignRadius {
  /// Hairline bars and progress tracks.
  static const hairline = 2.0;

  /// Tags, badges, inline code, chart bar tops.
  static const tag = 4.0;

  /// Buttons, inputs, selects.
  static const control = 6.0;

  /// Metadata cards, dropdowns, panels.
  static const panel = 8.0;

  /// Cards, search bar, featured sections.
  static const card = 12.0;

  /// Chips, avatars, status dots, pill badges.
  static const pill = 9999.0;
}

/// Design.md "Spacing": a 4 px grid.
abstract final class DesignSpace {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s64 = 64.0;
}

/// Design.md "Typography". General Sans (display) is not bundled — it is
/// not available as a TTF through the package registries — so headings use
/// DM Sans Bold, which keeps the same weight and tight tracking.
abstract final class DesignFonts {
  static const display = 'DMSans';
  static const body = 'DMSans';
  static const code = 'JetBrainsMono';
}

/// The flat "ink" header: white content on near-black, 12 px radius, a
/// 1 px border in dark mode so it still reads against the dark background.
BoxDecoration inkDecoration(
  BuildContext context, {
  BoxShape shape = BoxShape.rectangle,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: dark ? DesignColors.inkDark : DesignColors.ink,
    shape: shape,
    borderRadius: shape == BoxShape.circle
        ? null
        : BorderRadius.circular(DesignRadius.card),
    border: dark
        ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
        : null,
  );
}
