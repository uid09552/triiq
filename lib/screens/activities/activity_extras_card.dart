import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../evaluation/activity_extras.dart';
import '../../evaluation/compare.dart' show isComparable;
import '../../evaluation/performance_curves.dart' show formatPace;
import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../../evaluation/session_streams.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/charts/stacked_bar_chart.dart';
import '../../widgets/section_card.dart';
import 'activity_icons.dart' show formatDurationSecs;

/// What the session diagram doesn't say: how the effort was spread over power
/// (or pace), how variable it was, and how each interval held up. Drawn from
/// the streams the diagram already downloaded — it adds no request — and
/// shown for runs and rides only. Draws nothing while loading, offline, or
/// when the activity has no such stream: it's a bonus, never an error.
class ActivityExtrasCard extends StatefulWidget {
  ActivityExtrasCard({
    super.key,
    required this.activity,
    ActivityStreamsRepository? streams,
  }) : streams = streams ?? ActivityStreamsRepository();

  final LocalActivity activity;
  final ActivityStreamsRepository streams;

  @override
  State<ActivityExtrasCard> createState() => _ActivityExtrasCardState();
}

class _ActivityExtrasCardState extends State<ActivityExtrasCard> {
  late final Future<SessionStreams?> _future = isComparable(widget.activity)
      ? widget.streams
            .load(widget.activity.id)
            .then<SessionStreams?>((s) => s)
            .catchError((_) => null)
      : Future<SessionStreams?>.value(null);

  int _selected = -1;

  bool get _isRun => sportFamily(widget.activity.type) == 'run';
  String get _key => _isRun ? 'velocity_smooth' : 'watts';

  @override
  Widget build(BuildContext context) {
    if (!isComparable(widget.activity)) return const SizedBox.shrink();
    return FutureBuilder<SessionStreams?>(
      future: _future,
      builder: (context, snap) {
        final streams = snap.data;
        final values = streams?.series[_key];
        if (streams == null ||
            values == null ||
            !values.any((v) => v != null)) {
          return const SizedBox.shrink();
        }
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SectionCard(
            key: const ValueKey('extras-card'),
            icon: Icons.insights_outlined,
            title: l10n.exTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _variability(context, l10n, values),
                const SizedBox(height: 16),
                _histogram(context, l10n, values),
                ..._intervals(context, l10n, streams),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- variability ---------------------------------------------------------

  Widget _variability(
    BuildContext context,
    AppLocalizations l10n,
    List<double?> values,
  ) {
    final raw = widget.activity.raw['icu_variability_index'];
    final vi = (!_isRun && raw is num && raw > 0)
        ? raw.toDouble()
        : variabilityIndex(values);
    if (vi == null) return const SizedBox.shrink();
    final band = variabilityBand(vi);
    final theme = Theme.of(context);
    final color = switch (band) {
      VariabilityBand.steady => Colors.green.shade600,
      VariabilityBand.moderate => Colors.amber.shade700,
      VariabilityBand.variable => theme.colorScheme.error,
    };
    final label = switch (band) {
      VariabilityBand.steady => l10n.exViSteady,
      VariabilityBand.moderate => l10n.exViModerate,
      VariabilityBand.variable => l10n.exViVariable,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              vi.toStringAsFixed(2),
              key: const ValueKey('extras-vi'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${l10n.exVi} · $label',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        Text(
          l10n.exViHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // --- histogram -----------------------------------------------------------

  String _band(HistogramBin b) {
    if (!_isRun) return '${b.lo.round()}–${b.hi.round()} W';
    // Slow edge first, as a pace range reads: 5:20–5:00 /km.
    final slow = formatPace(b.lo <= 0 ? 0.01 : b.lo, per: 1000);
    final fast = formatPace(b.hi, per: 1000);
    return '$slow–$fast /km';
  }

  String _axis(HistogramBin b) =>
      _isRun ? formatPace(b.mid, per: 1000) : '${b.lo.round()}';

  Widget _histogram(
    BuildContext context,
    AppLocalizations l10n,
    List<double?> values,
  ) {
    final theme = Theme.of(context);
    final h = histogramOf(values, binWidth: binWidthFor(_key, values));
    if (h.isEmpty) return const SizedBox.shrink();
    final total = h.bins.fold<double>(0, (s, b) => s + b.seconds);
    String minutes(double seconds) =>
        (seconds / 60).toStringAsFixed(seconds >= 600 ? 0 : 1);
    final sel = _selected >= 0 && _selected < h.bins.length
        ? h.bins[_selected]
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isRun ? l10n.exHistPace : l10n.exHistPower,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          sel == null
              ? l10n.exHistTap
              : l10n.exHistBand(
                  _band(sel),
                  minutes(sel.seconds),
                  (sel.seconds / total * 100).round(),
                ),
          key: const ValueKey('extras-hist-readout'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        StackedBarChart(
          key: const ValueKey('extras-hist'),
          height: 150,
          bars: [
            for (final b in h.bins)
              StackedBar(label: _axis(b), values: [b.seconds / 60]),
          ],
          colors: [theme.colorScheme.primary],
          selectedIndex: _selected < 0 ? null : _selected,
          onSelect: (i) => setState(() => _selected = _selected == i ? -1 : i),
          labelEvery: (h.bins.length / 6).ceil().clamp(1, 12),
        ),
        if (h.zeroSeconds >= 60)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.exHistZero(minutes(h.zeroSeconds)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // --- intervals -----------------------------------------------------------

  String _output(double v) =>
      _isRun ? formatPace(v, per: 1000) : '${v.round()} W';

  List<Widget> _intervals(
    BuildContext context,
    AppLocalizations l10n,
    SessionStreams streams,
  ) {
    final stats = intervalStats(streams, outputKey: _key);
    if (stats.where((s) => s.isWork).isEmpty) return const [];
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget cell(
      String text, {
      int flex = 2,
      Color? color,
      bool head = false,
      bool end = true,
    }) => Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: end ? TextAlign.end : TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (head ? theme.textTheme.labelSmall : theme.textTheme.bodySmall)
            ?.copyWith(
              color:
                  color ?? (head ? theme.colorScheme.onSurfaceVariant : null),
            ),
      ),
    );

    String signed(double v, {int digits = 1, String suffix = '%'}) =>
        '${v > 0 ? '+' : ''}${v.toStringAsFixed(digits)}$suffix';

    Color driftColor(double d) => d > 8
        ? theme.colorScheme.error
        : d > 5
        ? Colors.amber.shade700
        : Colors.green.shade600;

    return [
      const SizedBox(height: 20),
      Text(l10n.exIntervalsTitle, style: theme.textTheme.titleSmall),
      const SizedBox(height: 6),
      Row(
        children: [
          cell(l10n.exColInterval, flex: 1, head: true, end: false),
          cell(l10n.exColTime, head: true),
          cell(l10n.exColOutput, head: true),
          cell(l10n.exColHr, head: true),
          cell(l10n.exColDrift, head: true),
          cell(l10n.exColFade, head: true),
        ],
      ),
      const Divider(height: 10),
      for (final s in stats)
        Padding(
          key: ValueKey('extras-interval-${s.number}'),
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Opacity(
            opacity: s.isWork ? 1 : 0.55,
            child: Row(
              children: [
                cell(
                  s.isWork ? '${s.number}' : '${s.number}·${l10n.exRecovery}',
                  flex: 1,
                  end: false,
                ),
                cell(formatDurationSecs(s.seconds)),
                cell(s.avgOutput == null ? '–' : _output(s.avgOutput!)),
                cell(
                  s.avgHeartrate == null ? '–' : '${s.avgHeartrate!.round()}',
                ),
                cell(
                  s.drift == null ? '–' : signed(s.drift!),
                  color: s.drift == null ? null : driftColor(s.drift!),
                ),
                cell(
                  s.fade == null ? '–' : signed(s.fade! * 100, digits: 0),
                  // For pace a negative change in m/s is a slower interval,
                  // for power a weaker one: down is down either way.
                  color: s.fade != null && s.fade! < -0.05
                      ? theme.colorScheme.error
                      : null,
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 8),
      Text(l10n.exIntervalsHint, style: muted),
    ];
  }
}
