import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_wellness.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/readiness_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import '../../widgets/chart_options.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import 'readiness_card.dart';
import '../statistics/wellness_trends_screen.dart';
import 'readiness_options.dart';

/// Every signal behind today's readiness: its value, the athlete's normal
/// range and how it was rated, plus the last 30 days of HRV and resting HR.
class ReadinessScreen extends StatefulWidget {
  const ReadinessScreen({
    super.key,
    required this.report,
    this.service,
    this.settings,
  });

  final ReadinessReport report;

  /// Re-rates readiness when the signal selection changes.
  final ReadinessService? service;
  final ReadinessSettings? settings;

  static const trendDays = 30;

  @override
  State<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends State<ReadinessScreen> {
  late ReadinessReport _report = widget.report;
  late final ReadinessSettings _settings =
      widget.settings ?? ReadinessSettings.instance;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_reload);
  }

  @override
  void dispose() {
    _settings.removeListener(_reload);
    super.dispose();
  }

  /// The selection changed: rate again from the same cache.
  Future<void> _reload() async {
    try {
      final next = await (widget.service ?? ReadinessService()).load();
      if (mounted) setState(() => _report = next);
    } catch (_) {
      // Keep showing the last rating.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final report = _report;
    final r = report.readiness;
    final color = readinessColor(theme.colorScheme, r.level);
    final device = r.deviceReadiness;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readinessTitle),
        actions: [
          ChartOptionsButton(
            onPressed: () => showReadinessOptions(context, settings: _settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  readinessLevelLabel(l10n, r.level),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (device != null)
                Chip(label: Text(l10n.readinessDevice(_fmt(device, 0)))),
            ],
          ),
          if (r.dataState == ReadinessDataState.noData) ...[
            const SizedBox(height: 8),
            Text(l10n.readinessNoDataHint),
          ],
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                // The ones that count first, then the switched-off ones.
                for (final s in r.active)
                  if (!(s.kind == ReadinessSignalKind.device &&
                      s.rating == SignalRating.missing))
                    _SignalTile(signal: s),
                for (final s in r.signals)
                  if (s.rating == SignalRating.excluded) _SignalTile(signal: s),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Trend(records: report.records),
          const SizedBox(height: 12),
          Text(
            l10n.readinessDisclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.signal});

  final ReadinessSignal signal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final s = signal;

    final (ratingLabel, ratingColor) = switch (s.rating) {
      SignalRating.ok => (l10n.readinessRatingOk, Colors.green.shade600),
      SignalRating.caution => (
        l10n.readinessCaution,
        readinessColor(scheme, ReadinessLevel.caution),
      ),
      SignalRating.backOff => (
        l10n.readinessBackOff,
        readinessColor(scheme, ReadinessLevel.backOff),
      ),
      SignalRating.noBaseline => (
        l10n.readinessRatingNoBaseline,
        scheme.onSurfaceVariant,
      ),
      SignalRating.missing => (
        l10n.readinessRatingMissing,
        scheme.onSurfaceVariant,
      ),
      SignalRating.excluded => (
        l10n.readinessRatingExcluded,
        scheme.onSurfaceVariant,
      ),
    };

    final value = s.value;
    final String valueText = value == null
        ? '—'
        : switch (s.kind) {
            ReadinessSignalKind.hrv => '${_fmt(value, 0)} ms',
            ReadinessSignalKind.restingHr => '${_fmt(value, 0)} bpm',
            ReadinessSignalKind.sleep => _hours(value),
            ReadinessSignalKind.form => _fmt(value, 1),
            ReadinessSignalKind.subjective => _fmt(value, 0),
            ReadinessSignalKind.load => _fmt(value, 2),
            ReadinessSignalKind.device => _fmt(value, 0),
          };

    final mean = s.mean;
    final bound = s.okBound;
    final String? range = switch (s.kind) {
      ReadinessSignalKind.hrv when mean != null && bound != null =>
        l10n.readinessRangeHrv(_fmt(bound, 0), _fmt(mean, 0)),
      ReadinessSignalKind.restingHr when mean != null && bound != null =>
        l10n.readinessRangeRestingHr(_fmt(bound, 0), _fmt(mean, 0)),
      ReadinessSignalKind.sleep when bound != null => l10n.readinessRangeSleep(
        _fmt(bound, 1),
      ),
      ReadinessSignalKind.form when bound != null => l10n.readinessRangeForm(
        _fmt(bound, 0),
      ),
      ReadinessSignalKind.load when bound != null => [
        l10n.readinessRangeLoad(_fmt(bound, 2)),
        if (s.dayLoad != null) l10n.readinessLoadToday(_fmt(s.dayLoad!, 0)),
      ].join(' · '),
      ReadinessSignalKind.device when bound != null =>
        l10n.readinessRangeDevice(_fmt(bound, 0)),
      ReadinessSignalKind.subjective when value != null =>
        l10n.readinessSubjectiveValues(
          s.fatigue?.toString() ?? '—',
          s.soreness?.toString() ?? '—',
        ),
      _ => null,
    };

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -3),
      minVerticalPadding: 4,
      enabled: s.rating != SignalRating.excluded,
      title: Text(readinessSignalLabel(l10n, s.kind)),
      subtitle: Text(range == null ? ratingLabel : '$ratingLabel · $range'),
      subtitleTextStyle: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: ratingColor),
      trailing: Text(
        valueText,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// HRV and resting HR over the last [ReadinessScreen.trendDays] days, one
/// chart each — they don't share a scale.
class _Trend extends StatelessWidget {
  const _Trend({required this.records});

  final List<LocalWellness> records;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final today = dateOnly(DateTime.now());
    final days = [
      for (var i = ReadinessScreen.trendDays - 1; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];
    final byDate = {for (final r in records) r.date: r};
    List<double?> values(String key) => [
      for (final d in days) _positive(byDate[isoDate(d)]?.raw[key]),
    ];
    final labels = [for (final d in days) DateFormat.MMMd(locale).format(d)];

    Widget chart(String label, Color color, List<double?> data) {
      final series = [ChartSeries(label: label, color: color, values: data)];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: MetricLineChart(
              series: series,
              labels: labels,
              labelEvery: 10,
            ),
          ),
          const SizedBox(height: 8),
          ChartLegend(series: series),
        ],
      );
    }

    final hrv = values('hrv');
    final rhr = values('restingHR');
    return SectionCard(
      icon: Icons.show_chart,
      title: l10n.readinessTrend,
      child: Column(
        children: [
          if (hrv.any((v) => v != null))
            chart(l10n.readinessSignalHrv, scheme.primary, hrv),
          if (hrv.any((v) => v != null) && rhr.any((v) => v != null))
            const SizedBox(height: 16),
          if (rhr.any((v) => v != null))
            chart(l10n.readinessSignalRestingHr, scheme.tertiary, rhr),
          if (hrv.every((v) => v == null) && rhr.every((v) => v == null))
            Text(l10n.readinessNoData),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('longer-trends'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => WellnessTrendsScreen()),
              ),
              icon: const Icon(Icons.timeline),
              label: Text(l10n.wtLongerTrends),
            ),
          ),
        ],
      ),
    );
  }
}

String _fmt(double v, int digits) => v.toStringAsFixed(digits);

String _hours(double hours) {
  final minutes = (hours * 60).round();
  return '${minutes ~/ 60} h ${(minutes % 60).toString().padLeft(2, '0')} min';
}

double? _positive(Object? raw) {
  final v = raw is num ? raw.toDouble() : null;
  return v == null || v <= 0 ? null : v;
}
