import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_wellness.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/peek_parts.dart';
import 'readiness_card.dart';
import 'readiness_format.dart';

/// The card shown while a pill on the readiness tile is held: what the
/// signal is, how it is rated, its last weeks as a small chart against the
/// athlete's normal band, and today's figure. Drawn from the report the
/// tile already holds, so it appears at once.
class ReadinessPeek extends StatelessWidget {
  /// A rated signal (HRV, resting HR, sleep, form, fatigue/soreness, load,
  /// device).
  const ReadinessPeek.signal({
    super.key,
    required ReadinessSignal this.signal,
    required this.report,
  });

  /// The Fitness pill: CTL and its trend.
  const ReadinessPeek.fitness({super.key, required this.report})
    : signal = null;

  final ReadinessSignal? signal;
  final ReadinessReport report;

  /// How many days of history the chart shows.
  static const days = 30;

  /// The signal's value on a day, or null when it has none that day.
  static double? valueOn(ReadinessSignalKind kind, LocalWellness w) {
    double? positive(Object? raw) =>
        raw is num && raw > 0 ? raw.toDouble() : null;
    switch (kind) {
      case ReadinessSignalKind.hrv:
        return positive(w.raw['hrv']);
      case ReadinessSignalKind.restingHr:
        return positive(w.raw['restingHR']);
      case ReadinessSignalKind.sleep:
        final secs = positive(w.raw['sleepSecs']);
        return secs == null ? null : secs / 3600;
      case ReadinessSignalKind.form:
        return w.ctl != null && w.atl != null ? w.ctl! - w.atl! : null;
      case ReadinessSignalKind.subjective:
        final scores = [
          for (final k in const ['fatigue', 'soreness'])
            if (w.raw[k] is num) (w.raw[k] as num).toDouble(),
        ];
        return scores.isEmpty ? null : scores.reduce((a, b) => a > b ? a : b);
      case ReadinessSignalKind.load:
        return positive(w.atlLoad) ?? positive(w.ctlLoad);
      case ReadinessSignalKind.device:
        final v = positive(w.raw['readiness']);
        return v == null || v > 100 ? null : v;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = signal;

    final title = s == null
        ? l10n.readinessFitness
        : readinessSignalLabel(l10n, s.kind);
    final (ratingLabel, ratingColor) = s == null
        ? ('', scheme.primary)
        : readinessRatingStyle(l10n, scheme, s.rating, signal: s);
    final accent = s == null ? scheme.primary : ratingColor;

    return Column(
      key: ValueKey('readiness-peek-${s?.kind.name ?? 'fitness'}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (s != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ratingLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.brightness == Brightness.dark
                        ? ratingColor
                        : Color.alphaBlend(
                            Colors.black.withValues(alpha: 0.3),
                            ratingColor,
                          ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          s == null ? l10n.readinessPeekFitness : _describe(l10n, s.kind),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (s == null)
          ..._fitness(context, l10n)
        else
          ..._signal(context, l10n, s, accent),
      ],
    );
  }

  static String _describe(AppLocalizations l10n, ReadinessSignalKind k) =>
      switch (k) {
        ReadinessSignalKind.hrv => l10n.readinessOptionHrv,
        ReadinessSignalKind.restingHr => l10n.readinessOptionRestingHr,
        ReadinessSignalKind.sleep => l10n.readinessOptionSleep,
        ReadinessSignalKind.form => l10n.readinessOptionForm,
        ReadinessSignalKind.subjective => l10n.readinessOptionSubjective,
        ReadinessSignalKind.load => l10n.readinessOptionLoad,
        ReadinessSignalKind.device => l10n.readinessOptionDevice,
      };

  /// The last [days] days that have a value, oldest first.
  List<(LocalWellness, double)> _points(
    double? Function(LocalWellness w) valueOf,
  ) {
    final all = [
      for (final w in report.records)
        if (valueOf(w) case final v?) (w, v),
    ]..sort((a, b) => a.$1.date.compareTo(b.$1.date));
    return all.length > days ? all.sublist(all.length - days) : all;
  }

  List<Widget> _fitness(BuildContext context, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final pts = _points((w) => w.ctl);
    if (pts.length < 2) return [PeekHint(l10n.insPeekNoData)];
    final last = pts.last;
    final lastDay = DateTime.tryParse(last.$1.date);
    double? weekAgo;
    if (lastDay != null) {
      final target = lastDay.subtract(const Duration(days: 7));
      for (final p in pts) {
        final d = DateTime.tryParse(p.$1.date);
        if (d != null && !d.isAfter(target)) weekAgo = p.$2;
      }
    }
    return [
      SizedBox(
        height: 90,
        child: MetricLineChart(
          series: [
            ChartSeries(
              label: l10n.readinessFitness,
              color: scheme.primary,
              values: [for (final p in pts) p.$2],
              fill: true,
              average: false,
            ),
          ],
          labels: _dateLabels(locale, pts),
          labelEvery: (pts.length / 3).ceil(),
          zoomable: false,
          showAverage: false,
        ),
      ),
      const SizedBox(height: 8),
      PeekFigures([
        PeekFigure(l10n.ctlLabel, last.$2.round().toString()),
        if (weekAgo != null)
          PeekFigure(
            l10n.readinessPeekWeekChange,
            '${last.$2 - weekAgo >= 0 ? '+' : ''}${(last.$2 - weekAgo).toStringAsFixed(1)}',
          ),
      ]),
    ];
  }

  List<Widget> _signal(
    BuildContext context,
    AppLocalizations l10n,
    ReadinessSignal s,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final pts = _points((w) => valueOn(s.kind, w));
    final range = readinessRangeText(l10n, s);

    Widget chart;
    if (pts.isEmpty) {
      chart = PeekHint(l10n.insPeekNoData);
    } else if (const {
      ReadinessSignalKind.sleep,
      ReadinessSignalKind.load,
      ReadinessSignalKind.subjective,
    }.contains(s.kind)) {
      // Daily quantities read best as bars; the last fortnight is enough.
      final recent = pts.length > 14 ? pts.sublist(pts.length - 14) : pts;
      chart = SizedBox(
        height: 90,
        child: SimpleBarChart(
          bars: [
            for (var i = 0; i < recent.length; i++)
              ChartBar(
                label: DateFormat.Md(
                  locale,
                ).format(DateTime.parse(recent[i].$1.date)),
                value: recent[i].$2,
                highlighted: i == recent.length - 1,
              ),
          ],
          labelEvery: 5,
          barColor: accent,
          showAverage: false,
        ),
      );
    } else if (pts.length < 2) {
      chart = PeekHint(l10n.insPeekNoData);
    } else {
      final mean = s.mean, sd = s.sd, bound = s.okBound;
      final green = Colors.green.shade600.withValues(alpha: 0.16);
      final band = switch (s.kind) {
        ReadinessSignalKind.hrv
            when mean != null && sd != null && bound != null =>
          ChartBand(low: bound, high: mean + sd, color: green),
        ReadinessSignalKind.restingHr
            when mean != null && sd != null && bound != null =>
          ChartBand(low: mean - sd, high: bound, color: green),
        _ => null,
      };
      chart = SizedBox(
        height: 90,
        child: MetricLineChart(
          series: [
            ChartSeries(
              label: readinessSignalLabel(l10n, s.kind),
              color: accent,
              values: [for (final p in pts) p.$2],
              fill: true,
              average: false,
            ),
          ],
          labels: _dateLabels(locale, pts),
          labelEvery: (pts.length / 3).ceil(),
          zoomable: false,
          showAverage: false,
          zeroLine: s.kind == ReadinessSignalKind.form,
          band: band,
        ),
      );
    }

    return [
      chart,
      const SizedBox(height: 8),
      PeekFigures([PeekFigure(l10n.readinessPeekToday, readinessValueText(s))]),
      if (range != null) ...[
        const SizedBox(height: 4),
        Text(
          range,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ];
  }

  static List<String> _dateLabels(
    String locale,
    List<(LocalWellness, double)> pts,
  ) => [
    for (final p in pts)
      DateFormat.MMMd(locale).format(DateTime.parse(p.$1.date)),
  ];
}
