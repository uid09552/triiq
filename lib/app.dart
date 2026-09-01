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
        darkTheme: _buildTheme(Brightness.dark),
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
