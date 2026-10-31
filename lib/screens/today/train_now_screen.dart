import 'dart:async';

import 'package:flutter/material.dart';

import '../../agent/chat_model_factory.dart';
import '../../agent/llm_settings.dart';
import '../../agent/training_agent.dart';
import '../../agent/workout_draft_parser.dart';
import '../../data/intervals_session.dart';
import '../../data/intervals_workout_service.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_actions.dart';
import '../../plan/plan_changes.dart';
import '../../util/calendar_export.dart';
import '../../util/dates.dart';
import '../../widgets/markdown_reply.dart';
import '../settings/settings_screen.dart';
import '../plan/plan_labels.dart';
import 'planned_session_card.dart';

enum _Intensity { recovery, endurance, intervals }

extension on _Intensity {
  String label(AppLocalizations l10n) => switch (this) {
    _Intensity.recovery => l10n.intensityRecovery,
    _Intensity.endurance => l10n.intensityEndurance,
    _Intensity.intervals => l10n.intensityIntervals,
  };

  IconData get icon => switch (this) {
    _Intensity.recovery => Icons.self_improvement_outlined,
    _Intensity.endurance => Icons.trending_flat_outlined,
    _Intensity.intervals => Icons.speed_outlined,
  };

  /// The wording handed to the agent — plain adjectives read more naturally
  /// in a sentence than the enum's UI label.
  String get promptWord => switch (this) {
    _Intensity.recovery => 'an easy recovery',
    _Intensity.endurance => 'a steady endurance',
    _Intensity.intervals => 'a high-intensity interval',
  };
}

const _sports = ['Run', 'Ride', 'Swim'];

/// "Train now": pick a sport, duration and intensity, and let the training
/// agent propose a session — reusing [TrainingAgent] exactly as Chat does,
/// so the proposal is grounded in the athlete's actual last-7-days load
/// (TSS/CTL/ATL) via the same tools, not a canned template.
class TrainNowScreen extends StatefulWidget {
  const TrainNowScreen({
    super.key,
    this.plannedItems,
    this.planActions,
    this.today,
    this.agentFactory,
    this.workoutWriter,
    this.syncService,
  });

  /// Test seams; the app uses the defaults.
  final PlannedItemsRepository? plannedItems;
  final PlanActions? planActions;
  /// The day to plan for (default today): its planned sessions are shown
  /// and a created workout lands on it.
  final DateTime Function()? today;
  final TrainingAgent Function()? agentFactory;
  final PlannedWorkoutWriter? workoutWriter;
  final SyncService? syncService;

  /// Longest reference steps sent to the agent.
  static const maxReferenceSteps = 1500;

  /// The request for the agent. With [reference] — a session planned
  /// today — it asks for an alternative to it rather than a fresh session.
  @visibleForTesting
  static String buildPrompt({
    required String intensityWord,
    required String sport,
    required int minutes,
    String customPrompt = '',
    LocalEvent? reference,
  }) {
    final ref = reference;
    var refText = '';
    if (ref != null) {
      var steps = (ref.description ?? '').trim();
      if (steps.length > maxReferenceSteps) {
        steps = '${steps.substring(0, maxReferenceSteps)} …';
      }
      final refMinutes = (ref.plannedTime ?? 0) ~/ 60;
      refText =
          'Today I have this session planned: ${ref.type ?? 'a session'} '
          '"${ref.name ?? 'Planned session'}", $refMinutes min, about '
          '${ref.plannedLoad ?? 'unknown'} TSS'
          '${steps.isEmpty ? '' : ', steps:\n$steps\n'}. '
          'I want an alternative to do instead of it: aim for a similar '
          'training effect and load unless my recent load says otherwise, '
          'and say why. The alternative must last about $minutes minutes. ';
    }
    return '$refText'
        'Propose $intensityWord $sport session lasting about '
        '$minutes minutes for me to do right now. Before proposing, check my '
        'training load from the last 7 days (TSS, CTL, ATL, ramp rate) with '
        'your tools and take it into account — back off the prescription if '
        "the data suggests I'm not recovered, and say so. Reply with the "
        'session as a markdown table, one row per segment (warm-up, each '
        'interval or set, cool-down), with exactly these two columns and '
        'nothing else — more columns make the table unreadable on a '
        'phone: "Duration" (the segment name plus its time or distance, '
        'e.g. "Warm-up — 10m" or "3x8min"), "Session" (everything else '
        'about that segment in one cell — the concrete target: % of FTP, % '
        'of threshold pace, or for swimming a pace per 100m or explicit '
        'effort; any equipment, e.g. paddles, pull buoy, fins; and any '
        'other note worth flagging). After the table, add one line with '
        'the estimated total TSS and a one-line rationale citing the data '
        'you found.'
        '${sport == 'Swim' ? ' Vary the session: about one swim session in '
              'three or four, build the main set around technique instead of '
              'straight swimming — name a specific drill and/or piece of '
              'equipment (paddles, pull buoy, fins) rather than just '
              '"swim". Only do this when it fits the requested intensity and '
              "duration, and don't force it into a hard interval session." : ''}'
        '${customPrompt.isEmpty ? '' : ' Additional instructions from me, '
              'which take priority over the defaults above where they '
              'conflict: "$customPrompt".'}';
  }

  @override
  State<TrainNowScreen> createState() => _TrainNowScreenState();
}

/// Whether a created proposal takes today's planned session's place.
enum _CreateMode { replace, add }

class _TrainNowScreenState extends State<TrainNowScreen> {
  final _settings = LlmSettings.instance;
  final _session = IntervalsSession.instance;
  late final PlannedWorkoutWriter _workoutService =
      widget.workoutWriter ?? IntervalsWorkoutService();
  late final _syncService = widget.syncService ?? SyncService();

  String _sport = _sports.first;
  double _durationMinutes = 60;
  _Intensity _intensity = _Intensity.endurance;

  /// Revealed by a separate button rather than always shown — most requests
  /// need nothing beyond sport/duration/intensity, so the field stays out of
  /// the way until asked for.
  bool _showCustomPrompt = false;
  final _customPromptController = TextEditingController();

  TrainingAgent? _agent;
  StreamSubscription<AgentEvent>? _subscription;
  String _reply = '';

  /// What the agent is doing right now, when that is more specific than
  /// "thinking" — the tool it is running, or the note that one failed. Null
  /// means "no detail"; the spinner itself is driven by [_isBusy], so it
  /// keeps turning through the pauses between tool calls and while the final
  /// answer is still being written.
  String? _activity;
  String? _error;
  bool _requested = false;

  /// Set while the proposal is being turned into a structured workout and
  /// written to Intervals.icu — a separate flag from [_isBusy] so the
  /// proposal controls stay disabled for the whole round-trip.
  bool _publishing = false;

  bool get _isBusy => _subscription != null;

  late final _plannedItems = widget.plannedItems ?? PlannedItemsRepository();
  late final _planActions = widget.planActions ?? PlanActions();

  /// The day the session is for — today, or e.g. tomorrow when opened from
  /// a recovery hint.
  DateTime get _targetDay => (widget.today ?? DateTime.now)();

  /// Today's planned training, and which one an alternative is for.
  List<LocalEvent> _todays = const [];
  bool _todaysLoaded = false;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    PlanChanges.instance.addListener(_loadTodays);
    AutoSyncService.instance.addListener(_loadTodays);
    SyncSettings.instance.addListener(_loadTodays);
    _loadTodays();
  }

  @override
  void dispose() {
    PlanChanges.instance.removeListener(_loadTodays);
    AutoSyncService.instance.removeListener(_loadTodays);
    SyncSettings.instance.removeListener(_loadTodays);
    _subscription?.cancel();
    _customPromptController.dispose();
    super.dispose();
  }

  void _propose() {
    if (_isBusy) return;
    setState(() {
      _requested = true;
      _reply = '';
      _error = null;
      _activity = null;
    });

    final agent = _agent ??= (widget.agentFactory ?? TrainingAgent.new)();
    try {
      _subscription = agent
          .send(_buildPrompt())
          .listen(
            _onEvent,
            onError: (Object error) => _finish(error: error),
            onDone: _finish,
            cancelOnError: true,
          );
    } on LlmNotConfiguredException catch (error) {
      _finish(error: error);
    }
    setState(() {});
  }

  String _buildPrompt() => TrainNowScreen.buildPrompt(
    intensityWord: _intensity.promptWord,
    sport: _sport,
    minutes: _durationMinutes.round(),
    customPrompt: _customPromptController.text.trim(),
    reference: _reference,
  );

  /// The session an alternative is asked for: the selected one of today's,
  /// or `null` when nothing is planned.
  LocalEvent? get _reference =>
      _todays.isEmpty ? null : _todays[_selected.clamp(0, _todays.length - 1)];

  Future<void> _loadTodays() async {
    final now = (widget.today ?? DateTime.now)();
    List<LocalEvent> items;
    try {
      items = (await _plannedItems.getByDate(isoDate(now)))
          .where((e) => e.isTraining)
          .toList();
    } catch (error) {
      debugPrint('TrainNow: cannot read today\'s plan: $error');
      items = const [];
    }
    if (!mounted) return;
    final firstLoad = !_todaysLoaded;
    setState(() {
      _todays = items;
      _todaysLoaded = true;
      if (_selected >= items.length) _selected = 0;
    });
    if (firstLoad && items.isNotEmpty) _applyPresets(items[_selected]);
  }

  /// Starts sport, duration and intensity from [e]; the athlete can still
  /// change them.
  void _applyPresets(LocalEvent e) {
    final type = (e.type ?? '').toLowerCase();
    final sport = type.contains('ride') || type.contains('bike')
        ? 'Ride'
        : type.contains('run')
        ? 'Run'
        : type.contains('swim')
        ? 'Swim'
        : _sport;
    final minutes = (e.plannedTime ?? 0) / 60;
    final name = (e.name ?? '').toLowerCase();
    final intensity = e.planSessionSlot == 'intervals'
        ? _Intensity.intervals
        : name.contains('recovery') || name.contains('easy')
        ? _Intensity.recovery
        : e.planSessionSlot != null
        ? _Intensity.endurance
        : name.contains('interval') || name.contains('vo2')
        ? _Intensity.intervals
        : _Intensity.endurance;
    setState(() {
      _sport = sport;
      if (minutes > 0) {
        _durationMinutes = ((minutes / 15).round() * 15)
            .clamp(15, 180)
            .toDouble();
      }
      _intensity = intensity;
    });
  }

  void _select(int index) {
    if (index == _selected || _isBusy) return;
    setState(() => _selected = index);
    _applyPresets(_todays[index]);
  }

  void _onEvent(AgentEvent event) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      switch (event) {
        case AgentTextDelta(:final text):
          _reply += text;
          _activity = null;
        case AgentToolStarted(:final name):
          _activity = _describeTool(l10n, name);
        case AgentToolFinished(:final name, :final failed):
          _activity = failed
              ? l10n.toolFailedSuffix(_describeTool(l10n, name))
              : null;
        case AgentProposal():
          // Train Now has no proposal cards; the chat does.
          break;
      }
    });
  }

  void _finish({Object? error}) {
    _subscription?.cancel();
    _subscription = null;
    setState(() {
      _activity = null;
      if (error != null) _error = '$error';
    });
  }

  /// Turns the proposal into a structured workout on the athlete's
  /// Intervals.icu calendar for today.
  ///
  /// Two steps, both of which the athlete can back out of: the agent is
  /// asked to re-express what it just proposed as JSON with the workout in
  /// Intervals.icu's step syntax, and the result is shown for confirmation
  /// before anything is written upstream.
  Future<void> _createInIntervals() async {
    if (_isBusy || _publishing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _publishing = true);

    PlannedWorkoutDraft? draft;
    try {
      final structured = await _collectReply(workoutStructuringPrompt);
      draft = parseWorkoutDraft(
        structured,
        date: _targetDay,
        fallbackSport: _sport,
        fallbackName: l10n.trainNowEventTitle(
          _intensity.label(l10n),
          _sportLabel(l10n, _sport),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage('$error');
      return;
    }

    if (!mounted) return;
    setState(() => _publishing = false);
    final proposed = draft;
    if (proposed == null) {
      _showMessage(l10n.couldNotStructureWorkout);
      return;
    }

    final reference = _reference;
    final mode = await showModalBottomSheet<_CreateMode>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _WorkoutPreviewSheet(
        draft: proposed,
        replacing: reference,
        canAdd: _session.isConnected,
      ),
    );
    if (mode == null || !mounted) return;
    if (mode == _CreateMode.replace && reference != null) {
      await _replace(reference, proposed);
      return;
    }

    setState(() => _publishing = true);
    try {
      final event = await _workoutService.createPlannedWorkout(proposed);
      // Pull the new session straight back down so Today and Calendar show
      // it without waiting for the next background sync: the whole month it
      // landed in, which is what Calendar caches by, plus the Today window
      // when that reaches past the month's edge.
      try {
        await _syncService.syncMonth(proposed.date);
        final (windowStart, windowEnd) = SyncService.todayWindow();
        if (!_isSameMonth(windowStart, proposed.date) ||
            !_isSameMonth(windowEnd, proposed.date)) {
          await _syncService.syncTodayWindow();
        }
        AutoSyncService.instance.notifyCacheChanged();
      } catch (_) {
        // The workout is on Intervals.icu either way; the cache catches up
        // on the next sync.
      }
      if (!mounted) return;
      _showMessage(l10n.workoutCreated(event.name ?? proposed.name));
    } catch (error) {
      if (mounted) _showMessage(l10n.couldNotCreateWorkout('$error'));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  /// Puts [draft] in [reference]'s place via [PlanActions], and says how
  /// that went.
  Future<void> _replace(LocalEvent reference, PlannedWorkoutDraft draft) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _publishing = true);
    try {
      final outcome = await _planActions.replaceSession(reference, draft);
      if (!mounted) return;
      _showMessage(switch (outcome) {
        ReplaceOutcome.replaced => l10n.workoutReplaced(draft.name),
        ReplaceOutcome.replacedLocally => l10n.workoutReplacedLocal,
        ReplaceOutcome.bothExist => l10n.replaceBothExist,
      });
      await _loadTodays();
    } on ReplaceRefusedException catch (error) {
      if (!mounted) return;
      _showMessage(refusalLabel(l10n, error));
    } catch (error) {
      if (mounted) _showMessage(l10n.couldNotReplace('$error'));
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  /// Whether the proposal can be created at all: in Intervals.icu when
  /// connected, or as a replacement of a plan session that lives only in
  /// TriIQ.
  bool get _canCreate {
    final ref = _reference;
    return _session.isConnected ||
        (ref != null && ref.isPlanSession && !ref.planSessionSent);
  }

  /// Runs one more turn of the same conversation and returns the whole
  /// reply — the streaming UI has nothing to show for a format conversion.
  Future<String> _collectReply(String prompt) async {
    final agent = _agent ??= (widget.agentFactory ?? TrainingAgent.new)();
    final buffer = StringBuffer();
    await for (final event in agent.send(prompt)) {
      if (event is AgentTextDelta) buffer.write(event.text);
    }
    return buffer.toString();
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _addToCalendar() async {
    final l10n = AppLocalizations.of(context)!;
    final launched = await launchGoogleCalendarEvent(
      title: l10n.trainNowEventTitle(
        _intensity.label(l10n),
        _sportLabel(l10n, _sport),
      ),
      description: _reply,
      start: _targetDay,
      duration: Duration(minutes: _durationMinutes.round()),
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenGoogleCalendar)),
      );
    }
  }

  static String _describeTool(AppLocalizations l10n, String name) =>
      switch (name) {
        'get_athlete_context' => l10n.trainNowToolChecking,
        'get_daily_metrics' => l10n.trainNowToolDailyLoad,
        'get_activities' => l10n.trainNowToolActivities,
        'get_planned_workouts' => l10n.trainNowToolPlanned,
        'get_training_summary' => l10n.trainNowToolSummary,
        'get_training_guidance' => l10n.trainNowToolGuidance,
        'sync_from_intervals' => l10n.trainNowToolSyncing,
        _ => l10n.toolRunningGeneric(name),
      };

  static String _sportLabel(AppLocalizations l10n, String sport) =>
      switch (sport) {
        'Run' => l10n.sportRun,
        'Ride' => l10n.sportRide,
        'Swim' => l10n.sportSwim,
        _ => sport,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final configured = _settings.isConfigured;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleTrainNow)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_todays.isNotEmpty) ...[
            Text(l10n.plannedTodayTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var i = 0; i < _todays.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PlannedSessionCard(
                  key: ValueKey('planned-today-$i'),
                  event: _todays[i],
                  selected: _todays.length > 1 && i == _selected,
                  onTap: _todays.length > 1 ? () => _select(i) : null,
                ),
              ),
            const SizedBox(height: 12),
          ],
          Text(l10n.sportLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              for (final sport in _sports)
                ButtonSegment(
                  value: sport,
                  label: Text(_sportLabel(l10n, sport)),
                  icon: Icon(_sportIcon(sport)),
                ),
            ],
            selected: {_sport},
            onSelectionChanged: _isBusy
                ? null
                : (selection) => setState(() => _sport = selection.first),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.durationMinutes(_durationMinutes.round()),
            style: theme.textTheme.titleSmall,
          ),
          Slider(
            value: _durationMinutes,
            min: 15,
            max: 180,
            divisions: 11,
            label: l10n.minutesShort(_durationMinutes.round()),
            onChanged: _isBusy
                ? null
                : (value) => setState(() => _durationMinutes = value),
          ),
          const SizedBox(height: 12),
          Text(l10n.intensityLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<_Intensity>(
            segments: [
              for (final intensity in _Intensity.values)
                ButtonSegment(
                  value: intensity,
                  label: Text(intensity.label(l10n)),
                  icon: Icon(intensity.icon),
                ),
            ],
            selected: {_intensity},
            onSelectionChanged: _isBusy
                ? null
                : (selection) => setState(() => _intensity = selection.first),
          ),
          const SizedBox(height: 12),
          if (!_showCustomPrompt)
            OutlinedButton.icon(
              onPressed: _isBusy
                  ? null
                  : () => setState(() => _showCustomPrompt = true),
              icon: const Icon(Icons.tune),
              label: Text(l10n.addCustomInstructions),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.customInstructionsLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: _isBusy
                      ? null
                      : () => setState(() {
                          _showCustomPrompt = false;
                          _customPromptController.clear();
                        }),
                  tooltip: l10n.removeCustomInstructions,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: _customPromptController,
              enabled: !_isBusy,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: l10n.customInstructionsHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (!configured) ...[
            Text(
              l10n.llmNeededForProposal,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              child: Text(l10n.openSettingsButton),
            ),
          ] else
            FilledButton.icon(
              key: const ValueKey('train-now-main'),
              onPressed: _isBusy || _publishing ? null : _propose,
              icon: Icon(
                _todays.isNotEmpty ? Icons.swap_horiz : Icons.auto_awesome,
              ),
              label: Text(
                _requested
                    ? l10n.askAgain
                    : _todays.isNotEmpty
                    ? l10n.findAlternative
                    : l10n.proposeTraining,
              ),
            ),
          if (_requested) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isBusy)
                      Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _activity ?? l10n.thinkingEllipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_isBusy && _reply.isNotEmpty)
                      const SizedBox(height: 12),
                    if (_error != null)
                      Text(
                        _error!,
                        style: TextStyle(color: colorScheme.error),
                      )
                    else if (_reply.isNotEmpty) ...[
                      MarkdownReply(text: _reply),
                      if (!_isBusy) ...[
                        const SizedBox(height: 16),
                        if (_publishing)
                          Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.preparingWorkout,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: _canCreate
                                    ? _createInIntervals
                                    : null,
                                icon: const Icon(Icons.add_task_outlined),
                                label: Text(l10n.createInIntervals),
                              ),
                              OutlinedButton.icon(
                                onPressed: _addToCalendar,
                                icon: const Icon(Icons.event_outlined),
                                label: Text(l10n.addToGoogleCalendar),
                              ),
                            ],
                          ),
                        if (!_canCreate) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.connectToCreateWorkout,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static IconData _sportIcon(String sport) => switch (sport) {
    'Run' => Icons.directions_run_outlined,
    'Ride' => Icons.directions_bike_outlined,
    'Swim' => Icons.pool_outlined,
    _ => Icons.sports_score_outlined,
  };
}

/// What is about to be written to Intervals.icu, shown before it is.
///
/// Creating a calendar entry in someone's training log is not undoable from
/// here, and the step syntax is the agent's work rather than the athlete's,
/// so the whole thing — name, targets and every line of the workout — is on
/// screen before the Create button is.
class _WorkoutPreviewSheet extends StatefulWidget {
  const _WorkoutPreviewSheet({
    required this.draft,
    this.replacing,
    this.canAdd = true,
  });

  final PlannedWorkoutDraft draft;

  /// Today's session the proposal is an alternative to; offers Replace /
  /// Add alongside when set.
  final LocalEvent? replacing;

  /// Whether adding a new workout (in Intervals.icu) is possible at all.
  final bool canAdd;

  @override
  State<_WorkoutPreviewSheet> createState() => _WorkoutPreviewSheetState();
}

class _WorkoutPreviewSheetState extends State<_WorkoutPreviewSheet> {
  late _CreateMode _mode = widget.replacing != null
      ? _CreateMode.replace
      : _CreateMode.add;

  PlannedWorkoutDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final replacing = widget.replacing;

    final facts = <String>[
      draft.sport,
      if (draft.indoor) l10n.indoorLabel,
      if (draft.durationSeconds != null)
        '${(draft.durationSeconds! / 60).round()} min',
      if (draft.load != null) '${draft.load} ${l10n.tssSuffix}',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.createInIntervals,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              draft.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              facts.join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    draft.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.workoutParsedByIntervals,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (replacing != null) ...[
              const SizedBox(height: 16),
              SegmentedButton<_CreateMode>(
                key: const ValueKey('create-mode'),
                segments: [
                  ButtonSegment(
                    value: _CreateMode.replace,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(l10n.replaceTodaySession),
                  ),
                  ButtonSegment(
                    value: _CreateMode.add,
                    enabled: widget.canAdd,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addAlongside),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              if (_mode == _CreateMode.replace) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.replacesSession(
                    replacing.name ?? l10n.plannedSessionFallback,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancelButton),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _mode == _CreateMode.add && !widget.canAdd
                      ? null
                      : () => Navigator.of(context).pop(_mode),
                  icon: const Icon(Icons.add_task_outlined),
                  label: Text(l10n.createButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
