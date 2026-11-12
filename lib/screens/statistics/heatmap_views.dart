import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../evaluation/load_heatmap.dart';
import '../../util/dates.dart';
import '../../widgets/charts/chart_theme.dart';

/// How the load heatmap lays its days out.
enum HeatmapStyle {
  /// The contribution-graph grid: a column per week (a row per week on a
  /// narrow phone).
  grid,

  /// One small calendar per month.
  months,

  /// A table of weeks × weekdays with week and weekday totals.
  matrix,
}

/// The heatmap's style and colour scale, kept in shared_preferences so the
/// screen opens the way it was left.
class HeatmapPrefs {
  const HeatmapPrefs({
    this.style = HeatmapStyle.grid,
    this.scale = HeatScale.theme,
  });

  static const styleKey = 'heatmap.style';
  static const scaleKey = 'heatmap.scale';

  final HeatmapStyle style;
  final HeatScale scale;

  static Future<HeatmapPrefs> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final style = prefs.getString(styleKey);
      final scale = prefs.getString(scaleKey);
      return HeatmapPrefs(
        style: HeatmapStyle.values.firstWhere(
          (s) => s.name == style,
          orElse: () => HeatmapStyle.grid,
        ),
        scale: HeatScale.values.firstWhere(
          (s) => s.name == scale,
          orElse: () => HeatScale.theme,
        ),
      );
    } catch (error) {
      debugPrint('HeatmapPrefs: cannot read: $error');
      return const HeatmapPrefs();
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(styleKey, style.name);
      await prefs.setString(scaleKey, scale.name);
    } catch (error) {
      debugPrint('HeatmapPrefs: cannot persist: $error');
    }
  }
}

/// How [HeatmapGridView] fits [weeks] into a given width.
@immutable
class HeatmapGridLayout {
  const HeatmapGridLayout({
    required this.vertical,
    required this.cell,
    required this.scrolls,
  });

  /// Weeks as rows (narrow screens) instead of columns.
  final bool vertical;

  /// Side of one day square.
  final double cell;

  /// Too narrow even for the vertical layout: scroll sideways.
  final bool scrolls;

  static const gap = 3.0;

  /// Smallest square the horizontal (weeks-as-columns) grid may use before
  /// it turns into weeks-as-rows.
  static const minHorizontalCell = 8.0;
  static const maxHorizontalCell = 16.0;

  /// Smallest and largest square for weeks-as-rows.
  static const minVerticalCell = 10.0;
  static const maxVerticalCell = 22.0;

  /// Width of the weekday labels left of the horizontal grid.
  static double weekdayLabelWidth(double textScale) => 26 * textScale;

  /// Width of the month labels left of the vertical grid.
  static double monthLabelWidth(double textScale) => 34 * textScale;

  /// The layout for [width] pixels, [weeks] weeks and a text scale factor.
  /// Cells are sized from the width so a year fits a 360 dp phone without
  /// scrolling sideways; scrolling is the last resort.
  static HeatmapGridLayout fit(
    double width,
    int weeks, {
    double textScale = 1,
  }) {
    final horizontal =
        (width - weekdayLabelWidth(textScale)) / math.max(1, weeks) - gap;
    if (horizontal >= minHorizontalCell) {
      return HeatmapGridLayout(
        vertical: false,
        cell: _floor(math.min(horizontal, maxHorizontalCell)),
        scrolls: false,
      );
    }
    final vertical = (width - monthLabelWidth(textScale)) / 7 - gap;
    if (vertical >= minVerticalCell) {
      return HeatmapGridLayout(
        vertical: true,
        cell: _floor(math.min(vertical, maxVerticalCell)),
        scrolls: false,
      );
    }
    return const HeatmapGridLayout(
      vertical: true,
      cell: minVerticalCell,
      scrolls: true,
    );
  }
}

/// Rounds [v] down to a tenth, so a row of cells never overflows its width
/// by a rounding error.
double _floor(double v) => (v * 10).floorToDouble() / 10;

/// What every heatmap style draws from.
abstract class _HeatmapView extends StatelessWidget {
  const _HeatmapView({
    super.key,
    required this.heatmap,
    required this.selected,
    required this.onSelect,
    required this.scale,
  });

  final LoadHeatmap heatmap;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final HeatScale scale;

  /// One tappable day square, keyed `hm-<date>` for tests.
  Widget cell(
    BuildContext context,
    HeatmapDay day,
    double size, {
    double gap = HeatmapGridLayout.gap,
    EdgeInsets? margin,
  }) {
    final chart = ChartTheme.of(context);
    final isSelected = day.inRange && selected == day.date;
    return GestureDetector(
      onTap: day.inRange ? () => onSelect(day.date) : null,
      child: Container(
        key: day.inRange ? ValueKey('hm-${isoDate(day.date)}') : null,
        width: size,
        height: size,
        margin: margin ?? EdgeInsets.only(right: gap, bottom: gap),
        decoration: BoxDecoration(
          color: day.inRange
              ? chart.heatColorOf(heatmap.levelOf(day.tss), scale)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(size < 10 ? 2 : 3),
          border: isSelected ? Border.all(color: chart.text, width: 1.5) : null,
        ),
      ),
    );
  }

  TextStyle? smallLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9);
}

/// Monday-first weekday abbreviations in [locale].
List<String> _weekdayNames(String locale) => [
  for (var i = 0; i < 7; i++)
    DateFormat.E(locale).format(DateTime(2026, 11, 2 + i)),
];

/// The contribution-graph grid, sized to the width it gets.
class HeatmapGridView extends _HeatmapView {
  const HeatmapGridView({
    super.key,
    required super.heatmap,
    required super.selected,
    required super.onSelect,
    super.scale = HeatScale.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = HeatmapGridLayout.fit(
          constraints.maxWidth,
          heatmap.weeks.length,
          textScale: textScale,
        );
        final grid = layout.vertical
            ? _vertical(context, layout, textScale)
            : _horizontal(context, layout, textScale);
        return KeyedSubtree(
          key: ValueKey(
            layout.vertical ? 'hm-layout-vertical' : 'hm-layout-horizontal',
          ),
          child: layout.scrolls
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: grid,
                )
              : grid,
        );
      },
    );
  }

  Widget _horizontal(
    BuildContext context,
    HeatmapGridLayout layout,
    double textScale,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final weeks = heatmap.weeks;
    final step = layout.cell + HeatmapGridLayout.gap;
    final style = smallLabel(context);
    final names = _weekdayNames(locale);

    DateTime firstDayOf(int w) => weeks[w].firstWhere((d) => d.inRange).date;
    String? monthLabel(int w) {
      final first = firstDayOf(w);
      if (w > 0 && firstDayOf(w - 1).month == first.month) return null;
      return DateFormat.MMM(locale).format(first);
    }

    final labelHeight = 18 * textScale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: HeatmapGridLayout.weekdayLabelWidth(textScale),
          child: Column(
            children: [
              SizedBox(height: labelHeight),
              for (var i = 0; i < 7; i++)
                SizedBox(
                  height: step,
                  child: i.isEven
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(names[i], style: style),
                        )
                      : null,
                ),
            ],
          ),
        ),
        for (var w = 0; w < weeks.length; w++)
          Column(
            children: [
              SizedBox(
                height: labelHeight,
                width: step,
                child: OverflowBox(
                  maxWidth: 48 * textScale,
                  alignment: Alignment.centerLeft,
                  child: Text(monthLabel(w) ?? '', maxLines: 1, style: style),
                ),
              ),
              for (final day in weeks[w]) cell(context, day, layout.cell),
            ],
          ),
      ],
    );
  }

  Widget _vertical(
    BuildContext context,
    HeatmapGridLayout layout,
    double textScale,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final weeks = heatmap.weeks;
    final step = layout.cell + HeatmapGridLayout.gap;
    final style = smallLabel(context);
    final names = _weekdayNames(locale);
    final monthWidth = HeatmapGridLayout.monthLabelWidth(textScale);

    String? monthLabel(int w) {
      final days = weeks[w].where((d) => d.inRange).toList();
      if (days.isEmpty) return null;
      // Label the week that holds a month's first day (or the first week).
      if (w == 0) return DateFormat.MMM(locale).format(days.first.date);
      final first = days.where((d) => d.date.day == 1).firstOrNull;
      return first == null ? null : DateFormat.MMM(locale).format(first.date);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: monthWidth),
              for (final name in names)
                SizedBox(
                  width: step,
                  height: 16 * textScale,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(name, style: style),
                  ),
                ),
            ],
          ),
          for (var w = 0; w < weeks.length; w++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: monthWidth,
                  height: step,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(monthLabel(w) ?? '', style: style),
                  ),
                ),
                for (final day in weeks[w]) cell(context, day, layout.cell),
              ],
            ),
        ],
      ),
    );
  }
}

/// One small calendar per month, as many across as fit.
class HeatmapMonthsView extends _HeatmapView {
  const HeatmapMonthsView({
    super.key,
    required super.heatmap,
    required super.selected,
    required super.onSelect,
    super.scale = HeatScale.theme,
  });

  static const _spacing = 12.0;
  static const _gap = 2.0;

  /// Months per row for [width].
  static int columnsFor(double width) => width >= 640
      ? 4
      : width >= 300
      ? 3
      : 2;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final style = smallLabel(context);
    final titleStyle = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700);
    final byDate = <DateTime, HeatmapDay>{
      for (final w in heatmap.weeks)
        for (final d in w)
          if (d.inRange) d.date: d,
    };
    final months = <DateTime>[];
    for (
      var m = DateTime(heatmap.from.year, heatmap.from.month);
      !m.isAfter(heatmap.to);
      m = DateTime(m.year, m.month + 1)
    ) {
      months.add(m);
    }
    final names = _weekdayNames(locale);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = columnsFor(constraints.maxWidth);
        final monthWidth =
            ((constraints.maxWidth - (cols - 1) * _spacing) / cols)
                .floorToDouble();
        final size = _floor(monthWidth / 7 - _gap);
        return Wrap(
          key: const ValueKey('hm-layout-months'),
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (final month in months)
              SizedBox(
                width: monthWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMM(locale).format(month),
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (final n in names)
                          SizedBox(
                            width: size + _gap,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(n.characters.first, style: style),
                            ),
                          ),
                      ],
                    ),
                    for (final week in _weeksOf(month))
                      Row(
                        children: [
                          for (final date in week)
                            date == null || byDate[date] == null
                                ? SizedBox(
                                    width: size + _gap,
                                    height: size + _gap,
                                  )
                                : cell(context, byDate[date]!, size, gap: _gap),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Monday-first rows of [month]'s dates, null outside the month.
  static List<List<DateTime?>> _weeksOf(DateTime month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = DateTime(month.year, month.month).weekday - 1;
    final rows = <List<DateTime?>>[];
    for (var start = -offset; start < days; start += 7) {
      rows.add([
        for (var i = start; i < start + 7; i++)
          i < 0 || i >= days ? null : DateTime(month.year, month.month, i + 1),
      ]);
    }
    return rows;
  }
}

/// Weeks as rows, weekdays as columns, with each week's total at the end of
/// its row and each weekday's total under its column.
class HeatmapMatrixView extends _HeatmapView {
  const HeatmapMatrixView({
    super.key,
    required super.heatmap,
    required super.selected,
    required super.onSelect,
    super.scale = HeatScale.theme,
    this.weekLabel = 'Week',
  });

  /// Header of the first column.
  final String weekLabel;

  static const _gap = 2.0;
  static const _minCell = 10.0;
  static const _maxCell = 26.0;

  /// TSS per weekday (Monday first) over the days in range.
  static List<int> weekdayTotals(LoadHeatmap heatmap) {
    final totals = List<int>.filled(7, 0);
    for (final w in heatmap.weeks) {
      for (var i = 0; i < 7; i++) {
        if (w[i].inRange) totals[i] += w[i].tss;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chart = ChartTheme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final style = smallLabel(context);
    final bold = style?.copyWith(fontWeight: FontWeight.w700);
    final names = _weekdayNames(locale);
    final weeks = heatmap.weeks;
    final weekTotals = [
      for (final w in weeks) w.fold<int>(0, (s, d) => s + d.tss),
    ];
    final maxWeek = weekTotals.fold<int>(1, math.max);
    final dayTotals = weekdayTotals(heatmap);

    return LayoutBuilder(
      builder: (context, constraints) {
        final labelWidth = 44 * textScale;
        final totalWidth = 44 * textScale;
        final fitted =
            (constraints.maxWidth - labelWidth - totalWidth) / 7 - _gap;
        final size = _floor(fitted.clamp(_minCell, _maxCell).toDouble());
        final step = size + _gap;
        final rowHeight = math.max(step, 14 * textScale);

        Widget label(
          String text,
          double width, {
          TextStyle? s,
          bool end = false,
        }) => SizedBox(
          width: width,
          height: rowHeight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: end ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(text, style: s ?? style),
          ),
        );

        final table = Column(
          key: const ValueKey('hm-layout-matrix'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label(weekLabel, labelWidth, s: bold),
                for (final n in names) label(n, step, s: bold),
                label('Σ', totalWidth, s: bold, end: true),
              ],
            ),
            for (var w = 0; w < weeks.length; w++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label(
                    DateFormat.MMMd(locale).format(weeks[w].first.date),
                    labelWidth,
                  ),
                  for (final day in weeks[w])
                    SizedBox(
                      width: step,
                      height: rowHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: cell(
                          context,
                          day,
                          size,
                          margin: const EdgeInsets.only(right: _gap),
                        ),
                      ),
                    ),
                  // The week's total over a bar of its share of the
                  // busiest week.
                  SizedBox(
                    width: totalWidth,
                    height: rowHeight,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        FractionallySizedBox(
                          widthFactor: weekTotals[w] / maxWeek,
                          heightFactor: 0.7,
                          alignment: Alignment.centerRight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: chart.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        label('${weekTotals[w]}', totalWidth, end: true),
                      ],
                    ),
                  ),
                ],
              ),
            Divider(height: 6, color: theme.colorScheme.outlineVariant),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label('Σ', labelWidth, s: bold),
                for (final t in dayTotals) label('$t', step, s: bold),
                label('${heatmap.totalTss}', totalWidth, s: bold, end: true),
              ],
            ),
          ],
        );
        return fitted < _minCell
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: table,
              )
            : table;
      },
    );
  }
}
