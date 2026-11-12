import 'package:flutter/material.dart';

/// Which colour ramp a heatmap uses: the app's theme colour at four
/// strengths, or a perceptually uniform viridis-like ramp that stays
/// readable for most colour-vision deficiencies.
enum HeatScale { theme, viridis }

/// The one place every chart in `lib/widgets/charts/` gets its colours and
/// text style from, derived from the active [ColorScheme] (and the text
/// theme's font, so the Developer theme's monospace reaches the axes too).
///
/// Charts read it with [ChartTheme.of]; nothing in a painter should name a
/// colour itself, so light, dark and Developer all follow automatically.
@immutable
class ChartTheme {
  const ChartTheme({
    required this.brightness,
    required this.primary,
    required this.highlight,
    required this.warning,
    required this.grid,
    required this.axis,
    required this.text,
    required this.mutedText,
    required this.surface,
    required this.track,
    required this.selection,
    required this.tooltip,
    required this.tooltipBorder,
    required this.brush,
    required this.categorical,
    required this.labelStyle,
    this.reduceMotion = false,
  });

  factory ChartTheme.fromColorScheme(
    ColorScheme scheme, {
    TextTheme? textTheme,
    bool reduceMotion = false,
  }) {
    final font = textTheme?.bodySmall;
    return ChartTheme(
      brightness: scheme.brightness,
      primary: scheme.primary,
      highlight: scheme.tertiary,
      warning: scheme.error,
      grid: scheme.outlineVariant,
      axis: scheme.outline,
      text: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
      surface: scheme.surface,
      track: scheme.surfaceContainerHighest,
      selection: scheme.onSurfaceVariant,
      tooltip: scheme.surfaceContainerHighest,
      tooltipBorder: scheme.outlineVariant,
      brush: scheme.primary,
      categorical: [
        scheme.primary,
        scheme.tertiary,
        scheme.secondary,
        scheme.error,
        scheme.outline,
      ],
      labelStyle: TextStyle(
        fontSize: 10,
        color: scheme.onSurfaceVariant,
        fontFamily: font?.fontFamily,
        fontFamilyFallback: font?.fontFamilyFallback,
      ),
      reduceMotion: reduceMotion,
    );
  }

  /// The chart theme for [context]: its [ColorScheme], text theme and the
  /// platform's reduce-motion setting.
  static ChartTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return ChartTheme.fromColorScheme(
      theme.colorScheme,
      textTheme: theme.textTheme,
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
    );
  }

  final Brightness brightness;

  /// The lead series / bar colour.
  final Color primary;

  /// Selected bar, second accent.
  final Color highlight;
  final Color warning;
  final Color grid;
  final Color axis;
  final Color text;
  final Color mutedText;
  final Color surface;

  /// Background of tracks and empty heatmap cells.
  final Color track;

  /// The crosshair line.
  final Color selection;
  final Color tooltip;
  final Color tooltipBorder;

  /// Brush and overview-window colour.
  final Color brush;

  /// Series colours in order, for charts whose caller names none.
  final List<Color> categorical;

  /// Axis and tick labels.
  final TextStyle labelStyle;

  /// Skip entry animations (the platform asked for reduced motion).
  final bool reduceMotion;

  bool get isDark => brightness == Brightness.dark;

  /// The [i]-th categorical colour, wrapping around.
  Color seriesColor(int i) => categorical[i % categorical.length];

  /// Five heat steps — rest, then four strengths — in [scale].
  List<Color> heatRamp([HeatScale scale = HeatScale.theme]) => [
    track,
    for (var level = 1; level <= 4; level++) heatColorOf(level, scale),
  ];

  /// The colour of heat step [level] (0 rest … 4 hard) in [scale].
  Color heatColorOf(int level, [HeatScale scale = HeatScale.theme]) {
    if (level <= 0) return track;
    final i = level.clamp(1, 4) - 1;
    return switch (scale) {
      HeatScale.theme => primary.withValues(
        alpha: const <double>[0.30, 0.50, 0.75, 1.0][i],
      ),
      // Viridis at 4 stops, ordered so more load always stands out further
      // from the background: darker on light surfaces, brighter on dark.
      HeatScale.viridis => (isDark ? _viridisDark : _viridisLight)[i],
    };
  }

  static const _viridisLight = [
    Color(0xFFB5DE2B),
    Color(0xFF35B779),
    Color(0xFF26828E),
    Color(0xFF3E4A89),
  ];
  static const _viridisDark = [
    Color(0xFF31688E),
    Color(0xFF21918C),
    Color(0xFF5EC962),
    Color(0xFFFDE725),
  ];
}
