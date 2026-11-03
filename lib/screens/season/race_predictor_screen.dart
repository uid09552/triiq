import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../agent/chat_handoff.dart';
import '../chat/ask_trainer.dart';
import '../../l10n/app_localizations.dart';
import '../../season/race_predictor.dart';
import '../../season/season_service.dart';
import '../../season/season_timeline.dart';
import '../../widgets/section_card.dart';
import 'season_format.dart';

typedef RaceInputsFn = Future<RaceInputs> Function({
  DateTime? raceDay,
  bool hot,
});

String raceSpecLabel(AppLocalizations l10n, RaceSpec s) => switch (s.id) {
  'run5k' => l10n.raceSpec5k,
  'run10k' => l10n.raceSpec10k,
  'halfMarathon' => l10n.raceSpecHalf,
  'marathon' => l10n.raceSpecMarathon,
  'ride100k' => l10n.raceSpecRide100,
  'sprint' => l10n.raceSpecSprint,
  'olympic' => l10n.raceSpecOlympic,
  'half70' => l10n.raceSpec703,
  'full140' => l10n.raceSpec1406,
  _ => s.id,
};

String legLabel(AppLocalizations l10n, String sport) => switch (sport) {
  'Swim' => l10n.raceLegSwim,
  'Ride' => l10n.raceLegRide,
  _ => l10n.raceLegRun,
};

/// Finish time, pacing and fuelling for a chosen race, from the cached
/// performance curves, CTL and the forecast form on race day.
class RacePredictorScreen extends StatefulWidget {
  const RacePredictorScreen({
    super.key,
    this.races = const [],
    this.inputs,
    this.initial,
  });

  /// Upcoming races, to pick a race day from.
  final List<SeasonRace> races;

  /// Test seam; the app loads from the cache.
  final RaceInputsFn? inputs;
  final RaceSpec? initial;

  @override
  State<RacePredictorScreen> createState() => _RacePredictorScreenState();
}

class _RacePredictorScreenState extends State<RacePredictorScreen> {
  late RaceSpec _spec = widget.initial ?? RaceSpec.olympic;
  SeasonRace? _race;
  bool _hot = false;
  RacePrediction? _prediction;
  Object? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    _race = widget.races.isEmpty ? null : widget.races.first;
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final loader = widget.inputs ?? RaceInputsLoader().load;
      final inputs = await loader(raceDay: _race?.date, hot: _hot);
      if (!mounted) return;
      setState(() {
        _prediction = predictRace(_spec, inputs);
        _busy = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _busy = false;
        });
      }
    }
  }

  void _ask(AppLocalizations l10n, RacePrediction p) {
    final label = raceSpecLabel(l10n, _spec);
    final legs = [
      for (final l in p.legs)
        '${l.sport}: ${clock(l.seconds)}'
            '${l.watts == null ? '' : ' @ ${l.watts} W'}',
    ].join('; ');
    askTrainer(
      context,
      ChatTopic(
        title: '${l10n.racePredictorTitle}: $label',
        context:
            'Race predictor for $label: total ${clock(p.totalSeconds)} ($legs). '
            'Fitness/form allowance ${((p.slowdown - 1) * 100).toStringAsFixed(1)} %. '
            'Carbs ${p.fueling.carbsPerHour} g/h.',
        draft: l10n.raceChatDraft(clock(p.totalSeconds), label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final p = _prediction;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.racePredictorTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.racePredictorSubtitle),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const ValueKey('race-spec'),
            initialValue: _spec.id,
            decoration: InputDecoration(labelText: l10n.raceChoose),
            items: [
              for (final s in RaceSpec.presets)
                DropdownMenuItem(value: s.id, child: Text(raceSpecLabel(l10n, s))),
            ],
            onChanged: (id) {
              if (id == null) return;
              _spec = RaceSpec.byId(id)!;
              _run();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SeasonRace?>(
            key: const ValueKey('race-day'),
            initialValue: _race,
            decoration: InputDecoration(labelText: l10n.raceDayLabel),
            items: [
              for (final r in widget.races)
                DropdownMenuItem(
                  value: r,
                  child: Text(
                    '${r.name} · ${DateFormat.MMMd(locale).format(r.date)}',
                  ),
                ),
              DropdownMenuItem(value: null, child: Text(l10n.raceDayNone)),
            ],
            onChanged: (r) {
              _race = r;
              _run();
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.raceHot),
            value: _hot,
            onChanged: (v) {
              _hot = v;
              _run();
            },
          ),
          const SizedBox(height: 8),
          if (_busy)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(l10n.seasonLoadError('$_error'))
          else if (p != null) ..._result(context, l10n, p),
        ],
      ),
    );
  }

  List<Widget> _result(
    BuildContext context,
    AppLocalizations l10n,
    RacePrediction p,
  ) {
    final theme = Theme.of(context);
    return [
      if (p.missing.isNotEmpty)
        Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              l10n.raceMissing(
                p.missing.map((m) => legLabel(l10n, m)).join(', '),
              ),
              key: const ValueKey('race-missing'),
            ),
          ),
        ),
      if (p.legs.isNotEmpty)
        SectionCard(
          icon: Icons.flag_outlined,
          title: l10n.raceTotal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clock(p.totalSeconds),
                key: const ValueKey('race-total'),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!p.complete) const Icon(Icons.info_outline, size: 18),
              const SizedBox(height: 8),
              for (final leg in p.legs) _LegRow(leg: leg, ftp: null),
              if (p.t1 + p.t2 > 0)
                Text(
                  l10n.raceTransitions(clock(p.t1), clock(p.t2)),
                  style: theme.textTheme.bodySmall,
                ),
              if (p.slowdown > 1.0005) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.raceSlowdown(((p.slowdown - 1) * 100).toStringAsFixed(1)),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      if (p.legs.isNotEmpty) ...[
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.route_outlined,
          title: l10n.racePacingTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final leg in p.legs) ..._pacing(context, l10n, leg),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.local_drink_outlined,
          title: l10n.fuelingTitle,
          child: _Fueling(plan: p.fueling),
        ),
        const SizedBox(height: 8),
        Text(l10n.raceDisclaimer, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _ask(l10n, p),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(l10n.raceAskTrainer),
          ),
        ),
      ],
    ];
  }

  List<Widget> _pacing(
    BuildContext context,
    AppLocalizations l10n,
    LegPrediction leg,
  ) {
    final theme = Theme.of(context);
    String km(double m) => (m / 1000).toStringAsFixed(m % 1000 == 0 ? 0 : 1);
    String target(PacingStep s) {
      if (s.watts != null) return l10n.raceWattsOnly(s.watts!);
      if (s.paceSecPerKm != null) return paceKm(s.paceSecPerKm!);
      if (s.pacePer100m != null) return pace100(s.pacePer100m!);
      return '';
    }

    String note(PacingNote n) => switch (n) {
      PacingNote.startControlled => l10n.pacingStartControlled,
      PacingNote.holdSteady => l10n.pacingHoldSteady,
      PacingNote.finishStrong => l10n.pacingFinishStrong,
      PacingNote.negativeSplit => l10n.pacingNegativeSplit,
    };
    return [
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Text(
          legLabel(l10n, leg.sport),
          style: theme.textTheme.titleSmall,
        ),
      ),
      for (final s in leg.steps)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  leg.sport == 'Swim'
                      ? '${(s.fromM).round()}–${(s.toM).round()} m'
                      : l10n.pacingRange(km(s.fromM), km(s.toM)),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(child: Text('${note(s.note)} · ${target(s)}')),
            ],
          ),
        ),
    ];
  }
}

class _LegRow extends StatelessWidget {
  const _LegRow({required this.leg, required this.ftp});

  final LegPrediction leg;
  final double? ftp;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detail = switch (leg.sport) {
      'Ride' => [
        if (leg.watts != null)
          leg.intensityFactor == null
              ? l10n.raceWattsOnly(leg.watts!)
              : l10n.raceWatts(
                  leg.watts!,
                  (leg.intensityFactor! * 100).toStringAsFixed(0),
                ),
        '${(leg.speed * 3.6).toStringAsFixed(1)} km/h',
      ].join(' · '),
      'Swim' => pace100(leg.pacePer100m),
      _ => paceKm(leg.paceSecPerKm),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(legLabel(l10n, leg.sport))),
          Text(clock(leg.seconds),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _Fueling extends StatelessWidget {
  const _Fueling({required this.plan});

  final FuelingPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (plan.carbsPerHour == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fuelNone),
          Text(l10n.fuelPreRace(plan.preRaceCarbsG),
              style: theme.textTheme.bodySmall),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.fuelCarbsPerHour(plan.carbsPerHour),
            key: const ValueKey('fuel-carbs'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(l10n.fuelFluidPerHour(plan.fluidPerHour)),
        Text(l10n.fuelSodiumPerHour(plan.sodiumPerHour)),
        const SizedBox(height: 4),
        Text(l10n.fuelTotals(plan.totalCarbsG, plan.totalFluidMl)),
        if (plan.dayBeforeCarbsG > 0) Text(l10n.fuelDayBefore(plan.dayBeforeCarbsG)),
        Text(l10n.fuelPreRace(plan.preRaceCarbsG)),
        const SizedBox(height: 8),
        for (final s in plan.steps.take(40))
          Text(
            l10n.fuelStep(s.minute, legLabel(l10n, s.sport), s.carbsG, s.fluidMl),
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}
