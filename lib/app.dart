import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'theme_controller.dart';
import 'widgets/main_shell.dart';

class TriiqApp extends StatelessWidget {
  const TriiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeController.instance,
        LocaleController.instance,
      ]),
      builder: (context, _) => MaterialApp(
        title: 'TriIQ',
        themeMode: ThemeController.instance.mode,
        theme: _buildTheme(Brightness.light),
        darkTheme: ThemeController.instance.choice == AppThemeChoice.developer
            ? _buildDeveloperTheme()
            : _buildTheme(Brightness.dark),
        locale: LocaleController.instance.locale,
        supportedLocales: LocaleController.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShell(),
      ),
    );
  }
}

ThemeData _buildDeveloperTheme() {
  const bg = Color(0xFF0A0E0A);
  const panel = Color(0xFF111811);
  const green = Color(0xFF33FF66);
  const amber = Color(0xFFFFB000);
  const cyan = Color(0xFF00E5FF);
  const red = Color(0xFFFF5555);
  const dim = Color(0xFF5F8F6A);
  const mono = 'monospace';

  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: green,
    onPrimary: bg,
    secondary: amber,
    onSecondary: bg,
    tertiary: cyan,
    onTertiary: bg,
    error: red,
    onError: bg,
    surface: bg,
    onSurface: green,
    onSurfaceVariant: dim,
    outline: dim,
    outlineVariant: Color(0xFF1F3A27),
    surfaceContainerLowest: bg,
    surfaceContainerLow: panel,
    surfaceContainer: panel,
    surfaceContainerHigh: Color(0xFF172217),
    surfaceContainerHighest: Color(0xFF1C2A1C),
    primaryContainer: Color(0xFF123A1E),
    onPrimaryContainer: green,
    secondaryContainer: Color(0xFF3A2A00),
    onSecondaryContainer: amber,
    tertiaryContainer: Color(0xFF003A44),
    onTertiaryContainer: cyan,
    errorContainer: Color(0xFF3A1010),
    onErrorContainer: red,
    inverseSurface: green,
    onInverseSurface: bg,
    inversePrimary: bg,
    surfaceTint: Colors.transparent,
  );

  const sharp = RoundedRectangleBorder(borderRadius: BorderRadius.zero);
  const outlined = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
    side: BorderSide(color: dim),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    fontFamily: mono,
    fontFamilyFallback: const ['Consolas', 'Courier New', 'Courier'],
    visualDensity: VisualDensity.compact,
    splashFactory: NoSplash.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: mono,
        color: green,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: panel,
      shape: outlined,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      elevation: 0,
      height: 64,
      indicatorColor: const Color(0xFF123A1E),
      indicatorShape: sharp,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: mono,
          fontSize: 12,
          color: states.contains(WidgetState.selected) ? green : dim,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: sharp,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: sharp,
        side: const BorderSide(color: dim),
      ),
    ),
    chipTheme: const ChipThemeData(
      shape: outlined,
      side: BorderSide(color: dim),
      backgroundColor: panel,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: panel,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: dim),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: green),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    listTileTheme: const ListTileThemeData(shape: sharp, iconColor: green),
    dividerTheme: const DividerThemeData(color: Color(0xFF1F3A27)),
  );
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750E4),
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      scrolledUnderElevation: 3,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      elevation: 0,
      height: 68,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
      backgroundColor: colorScheme.surfaceContainerHighest,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconColor: colorScheme.primary,
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
  );
}
