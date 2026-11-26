import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// The app's theme, built from `Design.md` (see [DesignColors] and friends).
///
/// Flat by default: cards and app bars rest on a 1 px border without
/// shadow; elevation is kept for menus, dialogs and sheets.
ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final primary = dark ? DesignColors.darkPrimary : DesignColors.primary;
  final background = dark
      ? DesignColors.darkBackground
      : DesignColors.background;
  final surface = dark ? DesignColors.darkSurface : DesignColors.surface;
  final text = dark ? DesignColors.darkTextPrimary : DesignColors.textPrimary;
  final textMuted = dark
      ? DesignColors.darkTextSecondary
      : DesignColors.textSecondary;
  final border = dark ? DesignColors.darkBorder : DesignColors.border;
  final chipFill = dark ? DesignColors.darkChipFill : DesignColors.chipFill;
  final chipText = dark ? DesignColors.darkChipText : DesignColors.chipText;

  Color mix(Color a, double t) => Color.lerp(surface, a, t)!;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: dark ? DesignColors.darkBackground : DesignColors.surface,
    primaryContainer: mix(primary, dark ? 0.28 : 0.14),
    onPrimaryContainer: dark
        ? const Color(0xFFE0E7FF)
        : const Color(0xFF312E81),
    secondary: DesignColors.secondary,
    onSecondary: DesignColors.surface,
    secondaryContainer: mix(DesignColors.secondary, dark ? 0.28 : 0.14),
    onSecondaryContainer: dark
        ? const Color(0xFFDCFCE7)
        : const Color(0xFF14532D),
    tertiary: DesignColors.warning,
    onTertiary: DesignColors.textPrimary,
    tertiaryContainer: mix(DesignColors.warning, dark ? 0.28 : 0.16),
    onTertiaryContainer: dark
        ? const Color(0xFFFEF3C7)
        : const Color(0xFF78350F),
    error: DesignColors.error,
    onError: DesignColors.surface,
    errorContainer: mix(DesignColors.error, dark ? 0.28 : 0.12),
    onErrorContainer: dark ? const Color(0xFFFEE2E2) : const Color(0xFF7F1D1D),
    surface: surface,
    onSurface: text,
    onSurfaceVariant: textMuted,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surface,
    surfaceContainer: dark ? const Color(0xFF1F1F23) : background,
    surfaceContainerHigh: chipFill,
    surfaceContainerHighest: dark ? const Color(0xFF2A2A2F) : border,
    outline: DesignColors.neutral,
    outlineVariant: border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: text,
    onInverseSurface: surface,
    inversePrimary: dark ? DesignColors.primary : DesignColors.darkPrimary,
    surfaceTint: Colors.transparent,
  );

  // Display and headings: bold, tight tracking (-0.03em); body regular,
  // labels medium. Sizes follow Design.md's scale, with title sizes for
  // phone app bars and cards.
  TextStyle heading(double size) => TextStyle(
    fontFamily: DesignFonts.display,
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.03 * size,
    color: text,
    height: 1.15,
  );
  TextStyle body(double size, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: DesignFonts.body,
        fontSize: size,
        fontWeight: weight,
        color: text,
      );
  final textTheme = TextTheme(
    displayLarge: heading(72),
    displayMedium: heading(60),
    displaySmall: heading(44),
    headlineLarge: heading(32),
    headlineMedium: heading(24),
    headlineSmall: heading(22),
    titleLarge: heading(20),
    titleMedium: body(16, weight: FontWeight.w500),
    titleSmall: body(14, weight: FontWeight.w500),
    bodyLarge: body(16),
    bodyMedium: body(15),
    bodySmall: body(13).copyWith(color: textMuted),
    labelLarge: body(14, weight: FontWeight.w500),
    labelMedium: body(12, weight: FontWeight.w500),
    labelSmall: body(11, weight: FontWeight.w500).copyWith(letterSpacing: 0.4),
  );

  final control = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DesignRadius.control),
  );
  final cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(DesignRadius.card),
    side: BorderSide(color: border),
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  const buttonSize = Size(64, 38);

  OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(DesignRadius.control),
    borderSide: BorderSide(color: c, width: w),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: DesignFonts.body,
    textTheme: textTheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 56,
      centerTitle: false,
      shape: Border(bottom: BorderSide(color: border)),
      titleTextStyle: heading(22),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: cardShape,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.panel),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => body(12, weight: FontWeight.w500).copyWith(
          color: states.contains(WidgetState.selected) ? primary : textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? primary : textMuted,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: scheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.panel),
      ),
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: textMuted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: control,
        padding: buttonPadding,
        minimumSize: buttonSize,
        elevation: 0,
        textStyle: textTheme.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: control,
        padding: buttonPadding,
        minimumSize: buttonSize,
        elevation: 0,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: control,
        padding: buttonPadding,
        minimumSize: buttonSize,
        side: BorderSide(color: border),
        foregroundColor: text,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: control,
        padding: buttonPadding,
        minimumSize: buttonSize,
        textStyle: textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: control),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: control,
        side: BorderSide(color: border),
        selectedBackgroundColor: scheme.primaryContainer,
        selectedForegroundColor: scheme.onPrimaryContainer,
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: chipFill,
      selectedColor: primary,
      secondarySelectedColor: primary,
      checkmarkColor: scheme.onPrimary,
      labelStyle: body(12, weight: FontWeight.w500).copyWith(color: chipText),
      secondaryLabelStyle: body(
        12,
        weight: FontWeight.w500,
      ).copyWith(color: scheme.onPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      hintStyle: body(14).copyWith(color: DesignColors.neutral),
      border: inputBorder(border),
      enabledBorder: inputBorder(border),
      focusedBorder: inputBorder(primary, 2),
      errorBorder: inputBorder(DesignColors.error),
      focusedErrorBorder: inputBorder(DesignColors.error, 2),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(surface),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.card),
        ),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: border)),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const CircleBorder(),
      side: BorderSide(color: border, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primary : null,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primary : chipFill,
      ),
      trackOutlineColor: WidgetStatePropertyAll(border),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      iconColor: textMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.panel),
      ),
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.card),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignRadius.card),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.panel),
        side: BorderSide(color: border),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignRadius.panel),
          ),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.panel),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.card),
      ),
    ),
  );
}
