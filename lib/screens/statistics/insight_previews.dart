import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_wellness.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../evaluation/durability.dart' show isDurabilityCandidate;
import '../../evaluation/load_heatmap.dart';
import '../../evaluation/performance_curves.dart';
import '../../evaluation/training_analytics.dart' show LoadSport;
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/charts/bar_chart.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/peek_parts.dart';
import '../../widgets/skeleton.dart';
import '../activities/activity_icons.dart';
import 'load_heatmap_screen.dart' show heatColor;

/// What the peeks draw from: the local cache, never the network, so a peek
/// is instant and works offline.
class InsightPreviewData {
  const InsightPreviewData({
    required this.today,
    required this.wellness,
    required this.activities,
    this.powerCurves,
  });

  final DateTime today;

  /// Oldest first.
  final List<LocalWellness> wellness;

  /// Most recent first.
  final List<LocalActivity> activities;
  final PerformanceCurves? powerCurves;
}

/// Reads [InsightPreviewData] from the cache: 12 weeks of activities and 60
/// days of wellness, plus the cached ride power curves.
class InsightPreviewSource {
  InsightPreviewSource({
    ActivitiesRepository? activities,
    WellnessRepository? wellness,
    PerformanceCurvesRepository? curves,
    DateTime Function()? clock,
  }) : _activities = activities,
       _wellness = wellness,
       _curves = curves,
       _clock = clock ?? DateTime.now;

  final ActivitiesRepository? _activities;
  final WellnessRepository? _wellness;
  final PerformanceCurvesRepository? _curves;
  final DateTime Function() _clock;

  Future<InsightPreviewData> load() async {
    final today = dateOnly(_clock());
    final activities = _activities ?? ActivitiesRepository();
    final wellness = _wellness ?? WellnessRepository();
    final curves = _curves ?? PerformanceCurvesRepository();
    final acts = await activities.getRange(
      isoDate(today.subtract(const Duration(days: 83))),
      isoDate(today),
    );
    final well = await wellness.getRange(
      isoDate(today.subtract(const Duration(days: 59))),
      isoDate(today),
    );
    PerformanceCurves? power;
    try {
      power = await curves.cached(CurveSport.ride, CurveMetric.power);
    } catch (_) {
      power = null;
    }
    return InsightPreviewData(
      today: today,
      wellness: well..sort((a, b) => a.date.compareTo(b.date)),
      activities: acts..sort((a, b) => b.date.compareTo(a.date)),
      powerCurves: power,
    );
  }
}

/// The card shown while an Insights tile is held: the destination's name
/// and a line on what it is, then a small chart or a few figures from the
/// athlete's own data, whichever says most.
class InsightPreview extends StatefulWidget {
  const InsightPreview({
    super.key,
    required this.id,
    required this.icon,
    required this.title,
    required this.accent,
    required this.source,
  });

  /// The destination's id (`analytics`, `explorer`, …).
  final String id;
  final IconData icon;
  final String title;
  final Color accent;
  final InsightPreviewSource source;

  @override
  State<InsightPreview> createState() => _InsightPreviewState();
}

class _InsightPreviewState extends State<InsightPreview> {
  late final Future<InsightPreviewData> _data = widget.source.load();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      key: ValueKey('insight-preview-${widget.id}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 20, color: widget.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _describe(l10n, widget.id),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<InsightPreviewData>(
          future: _data,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return snapshot.hasError
                  ? PeekHint(l10n.insPeekNoData)
                  : const Skeleton(height: 110, radius: 12);
            }
            return _content(context, l10n, data);
          },
        ),
        const SizedBox(height: 10),
        Text(
          l10n.insPeekTapHint,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _describe(AppLocalizations l10n, String id) => switch (id) {
    'analytics' => l10n.insPeekAnalytics,
    'explorer' => l10n.insPeekExplorer,
    'heatmap' => l10n.insPeekHeatmap,
    'curves' => l10n.insPeekCurves,
    'best-efforts' => l10n.insPeekBestEfforts,
    'durability' => l10n.insPeekDurability,
    'wellness' => l10n.insPeekWellness,
    'compare' => l10n.insPeekCompare,
    'weekly-review' => l10n.insPeekWeeklyReview,
    'activities' => l10n.insPeekActivities,
    _ => '',
  };

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) => switch (widget.id) {
    'analytics' => _fitness(context, l10n, d),
    'explorer' => _weeklyLoad(context, l10n, d),
    'heatmap' => _heatmap(context, l10n, d),
    'curves' => _curves(context, l10n, d, id: 's0', label: l10n.insPeekSeason),
    'best-efforts' => _curves(
      context,
      l10n,
      d,
      id: '42d',
      label: l10n.insPeekSixWeeks,
    ),
    'durability' => _durability(context, l10n, d),
    'wellness' => _wellness(context, l10n, d),
    'compare' => _compare(context, l10n, d),
    'weekly-review' => _weeklyReview(context, l10n, d),
    'activities' => _recent(context, l10n, d),
    _ => const SizedBox.shrink(),
  };

  // ------------------------------------------------------------- fitness

  Widget _fitness(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final days = [
      for (final w in d.wellness)
        if (w.ctl != null && w.atl != null) w,
    ];
    final recent = days.length > 42 ? days.sublist(days.length - 42) : days;
    if (recent.length < 2) return PeekHint(l10n.insPeekNoData);
    final last = recent.last;
    final series = [
      ChartSeries(
        label: l10n.ctlLabel,
        color: scheme.tertiary,
        values: [for (final w in recent) w.ctl],
        fill: true,
        average: false,
      ),
      ChartSeries(
        label: l10n.atlLabel,
        color: scheme.secondary,
        values: [for (final w in recent) w.atl],
        average: false,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: MetricLineChart(
            series: series,
            labels: [
              for (final w in recent)
                DateFormat.MMMd(locale).format(DateTime.parse(w.date)),
            ],
            labelEvery: (recent.length / 3).ceil(),
            zoomable: false,
            showAverage: false,
          ),
        ),
        const SizedBox(height: 8),
        PeekFigures([
          PeekFigure(l10n.ctlLabel, last.ctl!.round().toString()),
          PeekFigure(l10n.atlLabel, last.atl!.round().toString()),
          PeekFigure(
            l10n.readinessSignalForm,
            _signed((last.ctl! - last.atl!).round()),
          ),
        ]),
      ],
    );
  }

  // ------------------------------------------------------- weekly volumes

  /// The [count] weeks up to this one, oldest first.
  List<_Week> _weeks(InsightPreviewData d, int count) {
    final thisWeek = startOfWeek(d.today);
    return [
      for (var k = count - 1; k >= 0; k--)
        _Week.of(
          d.activities,
          DateTime(thisWeek.year, thisWeek.month, thisWeek.day - 7 * k),
        ),
    ];
  }

  Widget _weeklyLoad(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final weeks = _weeks(d, 10);
    if (weeks.every((w) => w.tss == 0)) return PeekHint(l10n.insPeekNoData);
    final done = weeks.sublist(0, weeks.length - 1);
    final average = done.isEmpty
        ? 0
        : (done.fold<int>(0, (s, w) => s + w.tss) / done.length).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 110,
          child: SimpleBarChart(
            bars: [
              for (var i = 0; i < weeks.length; i++)
                ChartBar(
                  label: DateFormat.Md(locale).format(weeks[i].start),
                  value: weeks[i].tss.toDouble(),
                  highlighted: i == weeks.length - 1,
                ),
            ],
            labelEvery: 3,
            showAverage: false,
          ),
        ),
        const SizedBox(height: 8),
        PeekFigures([
          PeekFigure(
            l10n.insPeekThisWeek,
            '${weeks.last.tss} ${l10n.tssSuffix}',
          ),
          PeekFigure(l10n.insPeekAverage, '$average ${l10n.tssSuffix}'),
        ]),
      ],
    );
  }

  // -------------------------------------------------------------- heatmap

  Widget _heatmap(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final map = buildLoadHeatmap(
      d.activities,
      from: d.today.subtract(const Duration(days: 83)),
      to: d.today,
    );
    if (map.totalTss == 0) return PeekHint(l10n.insPeekNoData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final week in map.weeks)
              Column(
                children: [
                  for (final day in week)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      decoration: BoxDecoration(
                        color: day.inRange
                            ? heatColor(scheme, map.levelOf(day.tss))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        PeekFigures([
          PeekFigure(l10n.insPeekActiveDays, '${map.activeDays}'),
          PeekFigure(l10n.insPeekStreak, '${map.longestStreak}'),
          PeekFigure(l10n.insPeekTss, '${map.totalTss}'),
        ]),
      ],
    );
  }

  // --------------------------------------------------------------- curves

  Widget _curves(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d, {
    required String id,
    required String label,
  }) {
    final period = d.powerCurves?.period(id);
    if (period == null || period.isEmpty)
      return PeekHint(l10n.insPeekOpenToLoad);
    String at(double seconds) {
      final v = period.at(seconds)?.value;
      return v == null ? '–' : '${v.round()} W';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.anSportRide} · $label',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        PeekFigures([
          PeekFigure('5 s', at(5)),
          PeekFigure('1 min', at(60)),
          PeekFigure('5 min', at(300)),
          PeekFigure('20 min', at(1200)),
        ]),
      ],
    );
  }

  // ----------------------------------------------------------- durability

  Widget _durability(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final rides = d.activities
        .where((a) => isDurabilityCandidate(a, LoadSport.ride))
        .length;
    return PeekFigures([PeekFigure(l10n.insPeekRides, '$rides')]);
  }

  // ------------------------------------------------------------- wellness

  Widget _wellness(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    double? v(LocalWellness w, String key) {
      final x = w.raw[key];
      return x is num && x > 0 ? x.toDouble() : null;
    }

    final withHrv = [
      for (final w in d.wellness)
        if (v(w, 'hrv') != null) w,
    ];
    final recent = withHrv.length > 30
        ? withHrv.sublist(withHrv.length - 30)
        : withHrv;
    final latest = d.wellness.reversed.firstOrNull;
    final rhr = d.wellness.reversed
        .map((w) => v(w, 'restingHR'))
        .nonNulls
        .firstOrNull;
    final sleep = d.wellness.reversed
        .map((w) => v(w, 'sleepSecs'))
        .nonNulls
        .firstOrNull;
    if (latest == null || (recent.length < 2 && rhr == null && sleep == null)) {
      return PeekHint(l10n.insPeekNoData);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recent.length >= 2) ...[
          SizedBox(
            height: 90,
            child: MetricLineChart(
              series: [
                ChartSeries(
                  label: l10n.insPeekHrv,
                  color: scheme.error,
                  values: [for (final w in recent) v(w, 'hrv')],
                  fill: true,
                  average: false,
                ),
              ],
              labels: [
                for (final w in recent)
                  DateFormat.MMMd(locale).format(DateTime.parse(w.date)),
              ],
              labelEvery: (recent.length / 3).ceil(),
              zoomable: false,
              showAverage: false,
            ),
          ),
          const SizedBox(height: 8),
        ],
        PeekFigures([
          if (recent.isNotEmpty)
            PeekFigure(l10n.insPeekHrv, '${v(recent.last, 'hrv')!.round()} ms'),
          if (rhr != null)
            PeekFigure(l10n.insPeekRestingHr, '${rhr.round()} bpm'),
          if (sleep != null)
            PeekFigure(
              l10n.insPeekSleep,
              '${(sleep / 3600).toStringAsFixed(1)} h',
            ),
        ]),
      ],
    );
  }

  // -------------------------------------------------------------- compare

  Widget _compare(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final end = d.today;
    final cur = _Week.range(
      d.activities,
      end.subtract(const Duration(days: 27)),
      end,
    );
    final prev = _Week.range(
      d.activities,
      end.subtract(const Duration(days: 55)),
      end.subtract(const Duration(days: 28)),
    );
    if (cur.tss == 0 && prev.tss == 0) return PeekHint(l10n.insPeekNoData);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: SimpleBarChart(
            bars: [
              ChartBar(label: l10n.insPeekBefore, value: prev.tss.toDouble()),
              ChartBar(
                label: l10n.insPeekLast4,
                value: cur.tss.toDouble(),
                highlighted: true,
              ),
            ],
            showAverage: false,
          ),
        ),
        const SizedBox(height: 8),
        PeekFigures([
          PeekFigure(l10n.insPeekLast4, '${cur.tss} ${l10n.tssSuffix}'),
          PeekFigure(l10n.insPeekBefore, '${prev.tss} ${l10n.tssSuffix}'),
          if (prev.tss > 0)
            PeekFigure(
              'Δ',
              '${_signed(((cur.tss - prev.tss) * 100 / prev.tss).round())} %',
            ),
        ]),
      ],
    );
  }

  // -------------------------------------------------------- weekly review

  Widget _weeklyReview(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final weeks = _weeks(d, 3); // two weeks ago, last week, this week
    final last = weeks[1];
    final before = weeks[0];
    if (last.tss == 0 && before.tss == 0) return PeekHint(l10n.insPeekNoData);
    return PeekFigures([
      PeekFigure(l10n.insPeekLastWeek, '${last.tss} ${l10n.tssSuffix}'),
      PeekFigure(l10n.insPeekHours, formatDurationSecs(last.seconds)),
      PeekFigure(l10n.insPeekSessions, '${last.sessions}'),
      PeekFigure(l10n.insPeekWeekBefore, '${before.tss} ${l10n.tssSuffix}'),
    ]);
  }

  // --------------------------------------------------------------- recent

  Widget _recent(
    BuildContext context,
    AppLocalizations l10n,
    InsightPreviewData d,
  ) {
    final theme = Theme.of(context);
    final latest = d.activities.take(3).toList();
    if (latest.isEmpty) return PeekHint(l10n.insPeekNoData);
    return Column(
      children: [
        for (final a in latest)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(activityTypeIcon(a.type), size: 18, color: widget.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    a.name ?? a.type ?? l10n.activityFallback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatIsoDate(a.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _signed(int v) => v > 0 ? '+$v' : '$v';
}

/// One week (or any span) of training: load, time and sessions.
class _Week {
  const _Week(this.start, this.tss, this.seconds, this.sessions);

  final DateTime start;
  final int tss;
  final int seconds;
  final int sessions;

  /// The Monday-to-Sunday week starting [monday].
  factory _Week.of(List<LocalActivity> all, DateTime monday) => _Week.range(
    all,
    monday,
    DateTime(monday.year, monday.month, monday.day + 6),
  );

  /// Everything on the days [from]..[to], inclusive.
  factory _Week.range(List<LocalActivity> all, DateTime from, DateTime to) {
    final a = isoDate(from), b = isoDate(to);
    var tss = 0, secs = 0, n = 0;
    for (final x in all) {
      if (x.date.compareTo(a) < 0 || x.date.compareTo(b) > 0) continue;
      tss += x.trainingLoad ?? 0;
      secs += x.movingTime ?? 0;
      n++;
    }
    return _Week(dateOnly(from), tss, secs, n);
  }
}
