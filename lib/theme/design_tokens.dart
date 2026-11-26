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

/// Design.md "Border Radius".
abstract final class DesignRadius {
  /// Tags, chips, badges, inline code.
  static const tag = 4.0;

  /// Buttons, inputs, selects.
  static const control = 6.0;

  /// Metadata cards, dropdowns, panels.
  static const panel = 8.0;

  /// Cards, search bar, featured sections.
  static const card = 12.0;

  /// Avatars, status dots, pill badges.
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
