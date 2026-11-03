import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../season/fitness_forecast.dart';
import '../../season/season_service.dart';
import '../../season/season_timeline.dart';
import '../../widgets/charts/line_chart.dart';
import '../../widgets/section_card.dart';
import 'health_card.dart';
import 'race_predictor_screen.dart';
import 'season_format.dart';

/// The season at a glance: a fitness forecast from the planned sessions
/// (with "form on race day"), a timeline of build / taper / race /
/// recovery blocks across all goal races with a conflict check, and the
/// illness / injury mode.
class SeasonScreen extends StatefulWidget {
  const SeasonScreen({super.key, this.service});

  final SeasonService? service;

  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  late final _service = widget.service ?? SeasonService();
  SeasonSnapshot? _snapshot;
  Object? _error;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _service.load();
      if (mounted) setState(() => _snapshot = s);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = _snapshot;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.seasonTitle)),
      body: _error != null
          ? Center(child: Text(l10n.seasonLoadError('$_error')))
          : s == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  HealthCard(
                    status: s.health,
                    changes: s.healthChanges,
                    today: s.today,
                    onChanged: _load,
                    showLogButton: true,
                  ),
                  if (s.health != null) const SizedBox(height: 16),
                  _ForecastCard(
                    snapshot: s,
                    selected: _selected,
                    onSelect: (i) => setState(() => _selected = i),
                  ),
                  const SizedBox(height: 16),
                  _TimelineCard(snapshot: s),
                  const SizedBox(height: 16),
                  SectionCard(
                    icon: Icons.speed_outlined,
                    title: l10n.racePredictorTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.racePredictorSubtitle),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const ValueKey('open-race-predictor'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RacePredictorScreen(
                                races: s.races
                                    .where((r) => !r.date.isBefore(s.today))
                                    .toList(),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(l10n.racePredictorTitle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({
    required this.snapshot,
    required this.selected,
    required this.onSelect,
  });

  final SeasonSnapshot snapshot;
  final int? selected;
  final ValueChanged<int> onSelect;

  String _bandText(AppLocalizations l10n, double form) =>
      switch (formBand(form)) {
        FormBand.loaded => l10n.forecastBandLoaded,
        FormBand.neutral => l10n.forecastBandNeutral,
        FormBand.fresh => l10n.forecastBandFresh,
        FormBand.detrained => l10n.forecastBandDetrained,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final md = DateFormat.MMMd(locale);
    final days = snapshot.forecast;

    Widget body;
    if (!snapshot.hasFitness || days.isEmpty) {
      body = Text(l10n.seasonNoFitness);
    } else {
      // Show up to the last race (+ a week), else 12 weeks.
      final lastRace = snapshot.races.isEmpty
          ? null
          : snapshot.races.last.date.add(const Duration(days: 7));
      final end = lastRace ?? snapshot.today.add(const Duration(days: 84));
      final shown = [for (final d in days) if (!d.date.isAfter(end)) d];
      final series = [
        ChartSeries(
          label: l10n.forecastCtl, color: scheme.primary,
          values: [for (final d in shown) d.ctl], fill: true, average: false,
        ),
        ChartSeries(
          label: l10n.forecastAtl, color: scheme.error,
          values: [for (final d in shown) d.atl], average: false,
        ),
        ChartSeries(
          label: l10n.forecastForm, color: scheme.tertiary,
          values: [for (final d in shown) d.form], average: false,
        ),
      ];
      final idx = selected != null && selected! < shown.length ? selected : null;
      final sel = idx == null ? null : shown[idx];
      final upcoming = [
        for (final r in snapshot.races)
          if (snapshot.onRaceDay(r) != null) r,
      ];
      final peak = upcoming.isEmpty
          ? null
          : peakForm(
              days,
              snapshot.today,
              upcoming.last.date,
            );
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.forecastSubtitle,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: MetricLineChart(
              series: series,
              labels: [for (final d in shown) md.format(d.date)],
              selectedIndex: idx,
              onSelect: onSelect,
              labelEvery: (shown.length / 5).ceil().clamp(1, 1000),
              zeroLine: true,
              showAverage: false,
            ),
          ),
          const SizedBox(height: 8),
          ChartLegend(series: series),
          if (sel != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.forecastPlannedEnd(
                md.format(sel.date),
                sel.ctl.toStringAsFixed(0),
                signed(sel.form),
              ),
              key: const ValueKey('forecast-selected'),
            ),
          ],
          const SizedBox(height: 12),
          for (final r in upcoming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.forecastRaceForm(
                      r.name,
                      signed(snapshot.onRaceDay(r)!.form),
                    ),
                    key: ValueKey('race-form-${r.name}'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _bandText(l10n, snapshot.onRaceDay(r)!.form),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          if (peak != null)
            Text(
              l10n.forecastPeak(md.format(peak.date), signed(peak.form)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      );
    }
    return SectionCard(
      icon: Icons.trending_up,
      title: l10n.forecastTitle,
      child: body,
    );
  }
}

Color _blockColor(ColorScheme c, BlockKind k) => switch (k) {
  BlockKind.base => c.secondaryContainer,
  BlockKind.build => c.primary,
  BlockKind.taper => c.tertiary,
  BlockKind.race => c.error,
  BlockKind.recovery => c.outlineVariant,
};

String blockLabel(AppLocalizations l10n, BlockKind k) => switch (k) {
  BlockKind.base => l10n.blockBase,
  BlockKind.build => l10n.blockBuild,
  BlockKind.taper => l10n.blockTaper,
  BlockKind.race => l10n.blockRace,
  BlockKind.recovery => l10n.blockRecovery,
};

String conflictText(AppLocalizations l10n, SeasonConflict c) {
  final first = c.first.name;
  final second = c.second?.name ?? '';
  return switch (c.kind) {
    ConflictKind.tooCloseA => l10n.conflictTooCloseA(
      first,
      second,
      c.second!.date.difference(c.first.date).inDays,
    ),
    ConflictKind.insideTaper => l10n.conflictInsideTaper(first, second),
    ConflictKind.sameDay => l10n.conflictSameDay(first, second),
    ConflictKind.insideRecovery => l10n.conflictInsideRecovery(first, second),
    ConflictKind.duringIllness => l10n.conflictDuringIllness(first),
  };
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.snapshot});

  final SeasonSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final md = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final blocks = snapshot.blocks;
    if (snapshot.races.isEmpty) {
      return SectionCard(
        icon: Icons.timeline,
        title: l10n.seasonTimelineTitle,
        child: Text(l10n.seasonNoRaces),
      );
    }
    final total = blocks.isEmpty
        ? 1
        : blocks.last.end.difference(blocks.first.start).inDays + 1;
    return SectionCard(
      icon: Icons.timeline,
      title: l10n.seasonTimelineTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              key: const ValueKey('season-bar'),
              height: 28,
              child: Row(
                children: [
                  for (final b in blocks)
                    Expanded(
                      flex: b.days.clamp(1, 100000) * 100 ~/ total + 1,
                      child: Tooltip(
                        message:
                            '${blockLabel(l10n, b.kind)} · ${md.format(b.start)}–${md.format(b.end)}',
                        child: Container(
                          color: _blockColor(scheme, b.kind),
                          margin: const EdgeInsets.only(right: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final k in BlockKind.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, height: 10, color: _blockColor(scheme, k),
                    ),
                    const SizedBox(width: 6),
                    Text(blockLabel(l10n, k),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in snapshot.races)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: r.isA ? scheme.error : scheme.secondary,
                child: Text(
                  r.priority,
                  style: TextStyle(
                    fontSize: 12,
                    color: r.isA ? scheme.onError : scheme.onSecondary,
                  ),
                ),
              ),
              title: Text(
                l10n.seasonRaceLine(
                  r.priority,
                  r.name,
                  md.format(r.date),
                  weeksTo(snapshot.today, r.date),
                ),
              ),
            ),
          const Divider(),
          Text(
            l10n.conflictsTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          if (snapshot.conflicts.isEmpty)
            Row(
              children: [
                Icon(Icons.check_circle_outline, color: scheme.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(l10n.conflictNone)),
              ],
            )
          else
            for (final c in snapshot.conflicts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: scheme.error, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        conflictText(l10n, c),
                        key: const ValueKey('season-conflict'),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
