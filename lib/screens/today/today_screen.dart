import 'dart:convert';

import 'package:flutter/material.dart';

import '../../agent/chat_handoff.dart';
import '../../agent/llm_settings.dart';
import '../../agent/plan_proposals.dart';
import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../data/pending_deletes.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/plans_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../data/threshold_suggestions_service.dart';
import '../../evaluation/fatigue_warning.dart';
import '../../evaluation/fatigue_warning_service.dart';
import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_service.dart';
import '../../evaluation/readiness_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/adaptation_service.dart';
import '../../plan/plan_changes.dart';
import '../../plan/plan_models.dart';
import '../../season/fitness_forecast.dart';
import '../../season/illness_mode.dart' show HealthPhase;
import '../../season/season_service.dart';
import '../../util/dates.dart';
import '../../util/intervals_links.dart';
import '../../widgets/athlete_avatar.dart';
import '../../widgets/main_navigation.dart';
import '../../widgets/peek_cards.dart';
import '../../widgets/peekable.dart';
import '../../widgets/pending_changes_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/sync_status_chip.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/activity_icons.dart';
import '../activities/feel_dialog.dart';
import '../activities/planned_workout_actions.dart';
import '../activities/planned_workout_detail_screen.dart';
import '../calendar/calendar_moves.dart';
import '../calendar/day_actions.dart';
import '../chat/ask_trainer.dart';
import '../chat/proposal_card.dart';
import '../plan/plan_labels.dart';
import '../plan/plan_session_sheet.dart';
import '../profile/profile_screen.dart';
import '../season/health_card.dart';
import '../settings/settings_screen.dart';
import '../settings/year_goals_settings.dart';
import '../statistics/threshold_suggestion_card.dart';
import 'athlete_detail_screen.dart';
import 'attention_stack.dart';
import 'customize_today_sheet.dart';
import 'fatigue_warning_card.dart';
import 'metric_history_screen.dart';
import 'race_week_header.dart';
import 'readiness_card.dart';
import 'readiness_explain_sheet.dart';
import 'this_week_card.dart';
import 'tile_details_sheet.dart';
import 'tile_metric.dart';
import 'tile_spark.dart';
import 'today_hero_card.dart';
import 'today_layout_settings.dart';
import 'train_now_screen.dart';
import 'tss_history_screen.dart';
import 'week_ribbon.dart';
import 'weekly_load_screen.dart';

/// From this content width Today lays its sections out in two columns.
const todayTwoColumnWidth = 900.0;

/// Days before a race from which Today switches to its race-week layout.
const raceWeekDays = 7;

/// Today: one hero card (status, readiness, today's session and one primary
/// action, tomorrow), what needs attention, this week, the load tiles,
/// today's activities.
///
/// Opening the screen (and any change to the Intervals.icu connection)
/// fetches the current week plus tomorrow if today isn't cached yet.
/// Pull-to-refresh always refetches. Display always reads from SQLite, so
/// the screen works offline once synced.
class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    this.wellnessRepository,
    this.activitiesRepository,
    this.plannedItems,
    this.readinessService,
    this.adaptationService,
    this.sparkLoader,
    this.goalStore,
    this.plansRepository,
    this.seasonService,
    this.fatigueWarningService,
    this.thresholdService,
    this.mover,
    this.clock,
  });

  /// Test seams; the app uses the defaults.
  final WellnessRepository? wellnessRepository;
  final ActivitiesRepository? activitiesRepository;
  final PlannedItemsRepository? plannedItems;
  final ReadinessService? readinessService;
  final AdaptationService? adaptationService;

  /// Test seam for the tiles' sparklines.
  final TileSparkLoader? sparkLoader;
  final GoalStore? goalStore;
  final PlansRepository? plansRepository;
  final SeasonService? seasonService;
  final FatigueWarningService? fatigueWarningService;
  final ThresholdSuggestionsService? thresholdService;

  /// Moves a session to tomorrow (the calendar's mover: plan rules, offline
  /// queue, undo).
  final CalendarMover? mover;
  final DateTime Function()? clock;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _session = IntervalsSession.instance;
  final _layout = TodayLayoutSettings.instance;
  final _dismissals = AttentionDismissals.instance;
  final _syncService = SyncService();
  late final _wellnessRepository =
      widget.wellnessRepository ?? WellnessRepository();
  late final _activitiesRepository =
      widget.activitiesRepository ?? ActivitiesRepository();
  late final _eventsRepository =
      widget.plannedItems ?? PlannedItemsRepository();
  late final _readinessService =
      widget.readinessService ??
      ReadinessService(wellness: _wellnessRepository, clock: widget.clock);
  late final _adaptationService =
      widget.adaptationService ??
      AdaptationService(
        plans: widget.plansRepository,
        goals: widget.goalStore,
        activities: _activitiesRepository,
        readiness: _readinessService,
      );
  late final _seasonService =
      widget.seasonService ??
      SeasonService(
        planned: _eventsRepository.getRange,
        wellness: _wellnessRepository,
        goals: widget.goalStore,
        clock: widget.clock,
      );
  late final _mover = widget.mover ?? CalendarMover(clock: widget.clock);

  bool _loading = true;
  String? _error;
  LocalWellness? _wellness;

  /// The same record a week ago, so each load tile can show which way it is
  /// moving rather than a bare number.
  LocalWellness? _wellnessWeekAgo;
  ReadinessReport? _readiness;

  /// Suggested plan changes (missed sessions, week load, readiness).
  List<PlanProposal> _adjustments = const [];

  /// Days to the active plan's event (0 on the day), or `null`.
  int? _raceDays;

  /// The plan's phase this week (taper, race week), for the race-week
  /// header.
  String? _racePhase;
  SeasonSnapshot? _season;
  FatigueWarning? _fatigue;

  /// Threshold suggestions waiting (the card loads its own; this only says
  /// whether it belongs in the attention stack).
  int _thresholds = 0;
  List<LocalActivity> _activities = const [];
  List<LocalActivity> _weekActivities = const [];
  List<LocalEvent> _weekEvents = const [];
  List<LocalEvent> _todaysPlan = const [];
  List<LocalEvent> _tomorrowsPlan = const [];
  int _weekLoad = 0;
  int _weekPlannedLoad = 0;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  String get _today => isoDate(_now);

  String get _tomorrow => isoDate(_now.add(const Duration(days: 1)));

  @override
  void initState() {
    super.initState();
    _session.addListener(_load);
    _layout.addListener(_onLayoutChanged);
    _dismissals.addListener(_onLayoutChanged);
    ReadinessSettings.instance.addListener(_onReadinessSelection);
    YearGoalsSettings.instance.addListener(_onLayoutChanged);
    AutoSyncService.instance.addListener(_onCacheChanged);
    PlanChanges.instance.addListener(_onCacheChanged);
    PendingDeletes.instance.addListener(_onCacheChanged);
    SyncSettings.instance.addListener(_onCacheChanged);
    _dismissals.load();
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    _layout.removeListener(_onLayoutChanged);
    _dismissals.removeListener(_onLayoutChanged);
    ReadinessSettings.instance.removeListener(_onReadinessSelection);
    YearGoalsSettings.instance.removeListener(_onLayoutChanged);
    AutoSyncService.instance.removeListener(_onCacheChanged);
    PlanChanges.instance.removeListener(_onCacheChanged);
    PendingDeletes.instance.removeListener(_onCacheChanged);
    SyncSettings.instance.removeListener(_onCacheChanged);
    super.dispose();
  }

  void _onLayoutChanged() {
    if (mounted) setState(() {});
  }

  /// Opening the screen or reconnecting: sync only if today is missing.
  Future<void> _load() => _refresh(force: false);

  /// Set while the pull-to-refresh gesture is running, so the cache-changed
  /// announcement it sends out doesn't bounce straight back as a second
  /// load of the data this screen just read.
  bool _refreshingFromGesture = false;

  void _onCacheChanged() {
    if (_refreshingFromGesture) return;
    _load();
  }

  /// Pull-to-refresh: [SyncService.refreshRange] decides whether that costs
  /// a fetch — it joins one already running instead of starting a second,
  /// skips it entirely within [SyncService.refreshMinGap] of the last one,
  /// and gives up waiting after [SyncService.refreshTimeout] — so the
  /// gesture is always cheap to repeat.
  Future<void> _refreshFromGesture() async {
    _refreshingFromGesture = true;
    try {
      final fetched = await _refresh(force: true);
      // Other tabs stay alive in the shell's `IndexedStack` and only reload
      // when something announces that the cache moved underneath them —
      // which a throttled-away refresh didn't.
      if (fetched) AutoSyncService.instance.notifyCacheChanged();
    } finally {
      _refreshingFromGesture = false;
    }
  }

  /// Reloads the screen, first refetching from Intervals.icu. Returns
  /// whether that fetch actually happened — [force] asks for one, the
  /// throttle can still say no.
  Future<bool> _refresh({required bool force}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // A failed fetch shouldn't blank the screen: fall through to reading
    // whatever is already cached and surface the error alongside it.
    Object? syncError;
    var fetched = false;
    try {
      if (force) {
        fetched = await _syncService.refreshDayWindow();
      } else {
        await _syncService.syncTodayWindowIfMissing();
      }
    } catch (e) {
      syncError = e;
    }

    try {
      final (weekStart, weekEnd) = SyncService.todayWindow(_now);
      final wellness = await _wellnessRepository.getByDate(_today);
      final wellnessWeekAgo = await _wellnessRepository.getByDate(
        isoDate(_now.subtract(const Duration(days: 7))),
      );
      final activities = await _activitiesRepository.getByDate(_today);
      final todaysPlan = await _eventsRepository.getByDate(_today);
      final tomorrowsPlan = await _eventsRepository.getByDate(_tomorrow);
      final weekActivities = await _activitiesRepository.getRange(
        isoDate(weekStart),
        isoDate(weekEnd),
      );
      final weekEvents = await _eventsRepository.getRange(
        isoDate(weekStart),
        isoDate(weekEnd),
      );
      if (!mounted) return fetched;
      setState(() {
        _wellness = wellness;
        _wellnessWeekAgo = wellnessWeekAgo;
        _activities = activities;
        _weekActivities = weekActivities;
        _weekEvents = weekEvents;
        _todaysPlan = todaysPlan.where((e) => e.isTraining).toList();
        _tomorrowsPlan = tomorrowsPlan.where((e) => e.isTraining).toList();
        _weekLoad = weekActivities.fold<int>(
          0,
          (sum, activity) => sum + (activity.trainingLoad ?? 0),
        );
        _weekPlannedLoad = weekEvents
            .where((e) => e.isTraining)
            .fold<int>(0, (sum, event) => sum + (event.plannedLoad ?? 0));
        _error = syncError?.toString();
      });
    } catch (e) {
      if (!mounted) return fetched;
      setState(() {
        _error = (syncError ?? e).toString();
      });
    }
    // Independent of each other: a slow one never holds the others back.
    await Future.wait([
      _loadReadiness().then((_) => _loadAdjustments()),
      _loadRaceCountdown(),
      _loadSeason(),
    ]);
    // The rest of the attention stack, one after the other: they only add
    // cards and shouldn't compete with the hero for the database.
    await _loadFatigue();
    await _loadThresholds();
    if (mounted) setState(() => _loading = false);
    return fetched;
  }

  Future<void> _loadRaceCountdown() async {
    try {
      final plan = await (widget.plansRepository ?? PlansRepository())
          .getCurrent();
      final goal = await (widget.goalStore ?? GoalStore()).load();
      final event = goal?.eventDate;
      final today = dateOnly(_now);
      int? days;
      String? phase;
      if (plan?.status == PlanStatus.active && event != null) {
        days = DateTime.utc(
          event.year,
          event.month,
          event.day,
        ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
        if (days < 0) days = null;
        for (final week in plan!.weeks) {
          final start = dateOnly(week.startDate);
          if (!today.isBefore(start) &&
              today.isBefore(start.add(const Duration(days: 7)))) {
            phase = week.phase;
          }
        }
      }
      if (mounted) {
        setState(() {
          _raceDays = days;
          _racePhase = phase;
        });
      }
    } catch (e) {
      debugPrint('TodayScreen: race countdown unavailable: $e');
    }
  }

  /// Illness / injury and the fitness forecast (race-day form).
  Future<void> _loadSeason() async {
    try {
      final s = await _seasonService.load(horizonDays: 60);
      if (mounted) setState(() => _season = s);
    } catch (e) {
      debugPrint('TodayScreen: season unavailable: $e');
    }
  }

  Future<void> _loadFatigue() async {
    final w = await loadVisibleFatigueWarning(
      service:
          widget.fatigueWarningService ??
          FatigueWarningService(wellness: _wellnessRepository),
      now: _now,
    );
    if (mounted) setState(() => _fatigue = w);
  }

  Future<void> _loadAdjustments() async {
    try {
      final adjustments = await _adaptationService.refresh();
      if (mounted) setState(() => _adjustments = adjustments);
    } catch (e) {
      debugPrint('TodayScreen: plan adjustments unavailable: $e');
    }
  }

  /// The athlete switched readiness signals on or off: rate again, and
  /// refresh the suggestions that depend on it.
  void _onReadinessSelection() {
    _loadReadiness().then((_) => _loadAdjustments());
  }

  /// Readiness after the rest of the screen, so a slow knowledge load or a
  /// bad wellness row only costs the readiness slot, never the load tiles.
  Future<void> _loadReadiness() async {
    try {
      final readiness = await _readinessService.load();
      if (mounted) setState(() => _readiness = readiness);
    } catch (e) {
      debugPrint('TodayScreen: readiness unavailable: $e');
      if (mounted) setState(() => _readiness = null);
    }
  }

  int? _score(String key) {
    final w = _wellness != null && _wellness!.date == _today ? _wellness : null;
    final v = w?.raw[key];
    return v is num && v > 0 ? v.toInt() : null;
  }

  /// "How do I feel?": today's fatigue and soreness, prefilled with what is
  /// already logged for the day.
  Future<void> _logFeel() async {
    await showFeelDialog(
      context,
      date: _today,
      initialFatigue: _score('fatigue'),
      initialSoreness: _score('soreness'),
    );
  }

  void _trainNow({String? eventId}) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => TrainNowScreen(initialEventId: eventId)),
  );

  /// A session's steps: the plan-session sheet for a TriIQ session, the
  /// planned-workout detail screen for an Intervals.icu one.
  void _openPlanned(LocalEvent event) => event.isPlanSession
      ? showPlanSessionSheetForEvent(context, event)
      : Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlannedWorkoutDetailScreen(event: event),
          ),
        );

  /// The calendar's move: rule warnings on the snackbar, Undo moves it back.
  Future<void> _moveToTomorrow(LocalEvent event) {
    final byDate = <String, List<LocalEvent>>{};
    for (final e in [..._weekEvents, ..._tomorrowsPlan]) {
      final list = byDate.putIfAbsent(e.date, () => []);
      if (!list.any((x) => x.id == e.id)) list.add(e);
    }
    return moveWithUndo(
      context,
      _mover,
      event,
      dateOnly(_now).add(const Duration(days: 1)),
      eventsByDate: byDate,
    );
  }

  void _askTrainerAboutToday(AppLocalizations l10n) {
    final r = _readiness?.readiness;
    Map<String, Object?> session(LocalEvent e) => {
      'name': e.name ?? e.type,
      'type': e.type,
      'planned_minutes': e.plannedTime == null
          ? null
          : (e.plannedTime! / 60).round(),
      'planned_load': e.plannedLoad,
    };
    askTrainer(
      context,
      ChatTopic(
        title: l10n.heroAskTrainerTopic,
        context: jsonEncode({
          'date': _today,
          'readiness': r == null || r.dataState == ReadinessDataState.noData
              ? null
              : {
                  'level': r.level.name,
                  'data': r.dataState.name,
                  'reasons': [for (final s in r.reasons) s.kind.name],
                },
          'today_planned': [for (final e in _todaysPlan) session(e)],
          'today_done': [
            for (final a in _activities)
              {
                'name': a.name ?? a.type,
                'type': a.type,
                'minutes': ((a.movingTime ?? 0) / 60).round(),
                'load': a.trainingLoad,
              },
          ],
          'tomorrow_planned': [for (final e in _tomorrowsPlan) session(e)],
          'note':
              'Call get_readiness and get_plan_adjustments for details '
              'before advising.',
        }),
        draft: l10n.heroAskTrainerDraft,
      ),
    );
  }

  /// An illness or injury that is still on (not the return ramp).
  bool get _sick => _season?.health?.phase == HealthPhase.affected;

  bool get _raceWeek {
    final days = _raceDays;
    return days != null && days <= raceWeekDays;
  }

  /// On a day with nothing planned: the next hard session of the week.
  LocalEvent? get _nextKeySession {
    for (final e in _weekEvents) {
      if (e.date.compareTo(_today) > 0 && e.isTraining && isHardSession(e)) {
        return e;
      }
    }
    return null;
  }

  double? get _raceDayForm {
    final days = _raceDays;
    final season = _season;
    if (days == null || season == null) return null;
    final day = forecastOn(
      season.forecast,
      dateOnly(_now).add(Duration(days: days)),
    );
    return day?.form;
  }

  void _dismissAttention(AttentionKind kind) => _dismissals.dismiss(kind, _now);

  List<AttentionItem> _attentionItems(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    bool open(AttentionKind kind) => !_dismissals.isDismissed(kind, _now);
    final season = _season;
    return [
      // The return-to-training ramp after an illness; while still sick the
      // card sits right under the hero instead.
      if (season?.health != null && !_sick && open(AttentionKind.health))
        AttentionItem(
          kind: AttentionKind.health,
          priority: 0,
          child: HealthCard(
            status: season!.health,
            changes: season.healthChanges,
            today: dateOnly(season.today),
            onChanged: _loadSeason,
          ),
        ),
      if (_fatigue case final w? when open(AttentionKind.fatigue))
        AttentionItem(
          kind: AttentionKind.fatigue,
          priority: w.level == FatigueLevel.warning ? 1 : 3,
          child: FatigueWarningCard(
            warning: w,
            onDismiss: () async {
              await FatigueWarningDismissals().dismiss(_now, w.level);
              if (mounted) setState(() => _fatigue = null);
            },
          ),
        ),
      if (_adjustments.any(
            (p) => p.canApply || p.state == ProposalState.applying,
          ) &&
          open(AttentionKind.adjustments))
        AttentionItem(
          kind: AttentionKind.adjustments,
          priority: 2,
          child: SectionCard(
            icon: Icons.auto_fix_high_outlined,
            title: l10n.todayAdjustmentsTitle,
            child: ListenableBuilder(
              listenable: PlanProposals.instance,
              builder: (context, _) => Column(
                children: [
                  for (final p in _adjustments)
                    if (p.canApply || p.state == ProposalState.applying)
                      ProposalCard(proposal: p),
                ],
              ),
            ),
          ),
        ),
      if (_raceDays case final days?
          when !_raceWeek && open(AttentionKind.race))
        AttentionItem(
          kind: AttentionKind.race,
          priority: 4,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 48, 14),
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.todayRaceCountdown(days),
                      key: const ValueKey('race-countdown'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (open(AttentionKind.thresholds) && _thresholds > 0)
        AttentionItem(
          kind: AttentionKind.thresholds,
          priority: 5,
          child: _thresholdSection(),
        ),
    ];
  }

  /// Shown only while it has suggestions; it reports back after a review
  /// or a dismissal, so the stack can drop it.
  Widget _thresholdSection() => ThresholdSuggestionsSection(
    key: const ValueKey('threshold-suggestions'),
    service: widget.thresholdService,
    bottomPadding: 0,
    onLoaded: (count) {
      if (mounted && count != _thresholds) {
        setState(() => _thresholds = count);
      }
    },
  );

  Future<void> _loadThresholds() async {
    try {
      final list =
          await (widget.thresholdService ?? ThresholdSuggestionsService())
              .load();
      if (mounted) setState(() => _thresholds = list.length);
    } catch (e) {
      debugPrint('TodayScreen: threshold suggestions unavailable: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connected = _session.isConnected;
    final sick = _sick;
    final raceWeek = _raceWeek;

    final todaysLoad = _activities.isEmpty
        ? null
        : _activities.fold<int>(
            0,
            (sum, activity) => sum + (activity.trainingLoad ?? 0),
          );
    final todaysPlannedLoad = _todaysPlan.fold<int>(
      0,
      (sum, event) => sum + (event.plannedLoad ?? 0),
    );
    final attention = sick ? const <AttentionItem>[] : _attentionItems(l10n);

    List<Widget> sectionWidgets(TodaySection section) => switch (section) {
      TodaySection.hero => [
        const SizedBox(height: 12),
        TodayHeroCard(
          date: _now,
          connected: connected,
          loading: _loading,
          readiness: _readiness,
          todaysPlan: _todaysPlan,
          activities: _activities,
          tomorrowsPlan: _tomorrowsPlan,
          nextKeySession: _nextKeySession,
          health: _season?.health,
          fatigue: _score('fatigue'),
          soreness: _score('soreness'),
          statusChip: SyncStatusChip(),
          onRefresh: _refreshFromGesture,
          onTrainNow: _trainNow,
          onSwapEasier: (e) => _trainNow(eventId: e.id),
          onFeel: _logFeel,
          onCustomize: () => showCustomizeTodaySheet(context, _layout),
          onOpenPlanned: _openPlanned,
          onMoveToTomorrow: sick ? null : _moveToTomorrow,
          onAskTrainer: () => _askTrainerAboutToday(l10n),
          onOpenTomorrow: () => _tomorrowsPlan.isEmpty
              ? MainNavigation.instance.openCalendar(
                  dateOnly(_now).add(const Duration(days: 1)),
                )
              : _openPlanned(_tomorrowsPlan.first),
          onOpenIntervals: connected
              ? () => openInIntervals(context, 'calendar')
              : null,
          onExplainReadiness: _readiness == null
              ? null
              : () => showReadinessExplainSheet(context, _readiness!),
        ),
        if (sick && _season?.health != null) ...[
          const SizedBox(height: 12),
          HealthCard(
            status: _season!.health,
            changes: _season!.healthChanges,
            today: dateOnly(_season!.today),
            onChanged: _loadSeason,
          ),
        ],
        if (raceWeek) ...[
          const SizedBox(height: 12),
          RaceWeekHeader(
            days: _raceDays!,
            phase: _racePhase == null ? null : phaseLabel(l10n, _racePhase!),
            raceDayForm: _raceDayForm,
          ),
        ],
      ],
      TodaySection.attention => [
        AttentionStack(items: attention, onDismiss: _dismissAttention),
      ],
      TodaySection.weekRibbon => [
        const SizedBox(height: 12),
        WeekRibbon(
          today: _now,
          activities: _weekActivities,
          events: _weekEvents,
        ),
      ],
      TodaySection.thisWeek => [
        const SizedBox(height: 12),
        ThisWeekCard(
          weekActivities: _weekActivities,
          weekLoad: _weekLoad,
          weekPlannedLoad: _weekPlannedLoad,
          sessionsPlanned: _weekEvents.where((e) => e.isTraining).length,
          collapsed: _layout.isCollapsed(TodaySection.thisWeek),
          onToggleCollapsed: () => _toggleFold(TodaySection.thisWeek),
        ),
      ],
      TodaySection.metrics => [
        const SizedBox(height: 12),
        _MetricTiles(
          todaysLoad: todaysLoad,
          todaysPlannedLoad: todaysPlannedLoad,
          weekLoad: _weekLoad,
          weekPlannedLoad: _weekPlannedLoad,
          wellness: _wellness,
          wellnessWeekAgo: _wellnessWeekAgo,
          sparkLoader: widget.sparkLoader,
          allTiles: _layout.allLoadTiles,
        ),
      ],
      TodaySection.activities => [
        if (_activities.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            collapsed: _layout.isCollapsed(TodaySection.activities),
            onToggleCollapsed: () => _toggleFold(TodaySection.activities),
            icon: Icons.check_circle_outline,
            title: l10n.todaysActivities,
            child: _TodayActivities(activities: _activities),
          ),
        ],
      ],
      TodaySection.tomorrowsTraining => [
        const SizedBox(height: 12),
        SectionCard(
          collapsed: _layout.isCollapsed(TodaySection.tomorrowsTraining),
          onToggleCollapsed: () => _toggleFold(TodaySection.tomorrowsTraining),
          icon: Icons.event_outlined,
          title: l10n.tomorrowsTraining,
          child: _PlannedTraining(
            onLongPress: _tomorrowsPlan.any(canDeletePlannedWorkout)
                ? () => confirmAndDeleteDaysWorkouts(context, _tomorrowsPlan)
                : null,
            events: _tomorrowsPlan,
            onEmptyLongPress: () => showDayActions(
              context,
              _now.add(const Duration(days: 1)),
              const [],
            ),
            emptyLabel: connected
                ? l10n.nothingPlannedTomorrow
                : l10n.connectToSeePlan,
          ),
        ),
      ],
      TodaySection.athlete => [
        const SizedBox(height: 12),
        SectionCard(
          collapsed: _layout.isCollapsed(TodaySection.athlete),
          onToggleCollapsed: () => _toggleFold(TodaySection.athlete),
          icon: Icons.person_outline,
          title: l10n.titleAthlete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: connected
                ? const AthleteAvatar(size: 44, onSurface: true)
                : const Icon(Icons.link_off),
            title: Text(
              connected
                  ? (_session.athleteName ?? l10n.connectedLabel)
                  : l10n.notConnected,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              connected ? _describeAthlete(l10n) : l10n.connectInProfile,
            ),
            trailing: connected ? const Icon(Icons.chevron_right) : null,
            onTap: connected
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AthleteDetailScreen(),
                    ),
                  )
                : null,
          ),
        ),
      ],
    };

    // A sick or injured day hides what is about training; race week puts
    // its header where the load tiles were.
    bool shown(TodaySection s) {
      if (!_layout.isVisible(s)) return false;
      if (sick) {
        return const {
          TodaySection.hero,
          TodaySection.activities,
          TodaySection.athlete,
        }.contains(s);
      }
      if (raceWeek && s == TodaySection.metrics) return false;
      return true;
    }

    final visible = contextualTodayOrder(
      [
        for (final section in _layout.order)
          if (shown(section)) section,
      ],
      _now,
      enabled: _layout.timeOfDayOrder,
    );
    // Hero hidden by the athlete: a sick day's plan and the race-week
    // header still have to show somewhere.
    final heroHidden = !visible.contains(TodaySection.hero);

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= todayTwoColumnWidth;
        return RefreshIndicator(
          onRefresh: _refreshFromGesture,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              PendingChangesCard(),
              _SetupBanner(connected: connected),
              if (_error != null) ...[
                const SizedBox(height: 12),
                SectionCard(
                  icon: Icons.error_outline,
                  title: l10n.syncFailed,
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              if (heroHidden && (sick || raceWeek))
                ...sectionWidgets(TodaySection.hero).skip(2),
              if (twoColumns)
                Row(
                  key: const ValueKey('today-two-columns'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final section in visible)
                            if (_primaryColumn.contains(section))
                              ...sectionWidgets(section),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final section in visible)
                            if (!_primaryColumn.contains(section))
                              ...sectionWidgets(section),
                        ],
                      ),
                    ),
                  ],
                )
              else
                for (final section in visible) ...sectionWidgets(section),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => showCustomizeTodaySheet(context, _layout),
                  icon: const Icon(Icons.tune),
                  label: Text(l10n.customizeTodayTitle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// What to do today stays on the left on a wide window; figures, targets
  /// and the rest go on the right.
  static const _primaryColumn = {
    TodaySection.hero,
    TodaySection.attention,
    TodaySection.weekRibbon,
    TodaySection.tomorrowsTraining,
  };

  void _toggleFold(TodaySection section) =>
      _layout.setCollapsed(section, !_layout.isCollapsed(section));

  /// FTP and threshold pace say more on the athlete row than "synced with
  /// Intervals.icu" does; fall back to that when nothing is loaded yet.
  String _describeAthlete(AppLocalizations l10n) {
    final parts = <String>[];
    for (final sport in const ['Ride', 'Run']) {
      final settings = _session.settingsForSport(sport);
      final ftp = settings?.ftp;
      if (ftp != null && ftp > 0) parts.add('$sport ${l10n.ftpValue(ftp)}');
    }
    return parts.isEmpty ? l10n.syncedWithIntervals : parts.join(' · ');
  }
}

/// The load metrics on Today, every one of them a way into its own history.
///
/// Six numbers in three rows rather than a scrolling wall: what today cost,
/// what the week has cost, and the four Intervals.icu figures that put both
/// in context. Each tile carries the comparison the number needs — today
/// against what was planned, CTL/ATL against the same day last week — and
/// opens the chart behind it on tap.
class _MetricTiles extends StatefulWidget {
  const _MetricTiles({
    required this.todaysLoad,
    required this.todaysPlannedLoad,
    required this.weekLoad,
    required this.weekPlannedLoad,
    required this.wellness,
    required this.wellnessWeekAgo,
    this.sparkLoader,
    this.allTiles = false,
  });

  final TileSparkLoader? sparkLoader;

  /// All six tiles (the athlete's choice in Customize Today); otherwise
  /// Fitness, Fatigue and Form with the rest behind "More metrics".
  final bool allTiles;
  final int? todaysLoad;
  final int todaysPlannedLoad;
  final int weekLoad;
  final int weekPlannedLoad;
  final LocalWellness? wellness;
  final LocalWellness? wellnessWeekAgo;

  @override
  State<_MetricTiles> createState() => _MetricTilesState();
}

class _MetricTilesState extends State<_MetricTiles> {
  Map<TileMetric, TileSpark> _spark = const {};
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_loadSpark);
    _loadSpark();
  }

  @override
  void didUpdateWidget(_MetricTiles old) {
    super.didUpdateWidget(old);
    // New numbers (a sync landed): redraw the charts from the same cache.
    if (old.weekLoad != widget.weekLoad ||
        old.todaysLoad != widget.todaysLoad ||
        old.wellness?.date != widget.wellness?.date ||
        old.wellness?.ctl != widget.wellness?.ctl) {
      _loadSpark();
    }
  }

  @override
  void dispose() {
    AutoSyncService.instance.removeListener(_loadSpark);
    super.dispose();
  }

  Future<void> _loadSpark() async {
    try {
      final spark = await (widget.sparkLoader ?? TileSparkLoader()).load();
      if (mounted) setState(() => _spark = spark);
    } catch (_) {
      // Sparklines are decoration: the tiles work without them.
    }
  }

  @override
  Widget build(BuildContext context) {
    final todaysLoad = widget.todaysLoad;
    final todaysPlannedLoad = widget.todaysPlannedLoad;
    final weekLoad = widget.weekLoad;
    final weekPlannedLoad = widget.weekPlannedLoad;
    final wellness = widget.wellness;
    final wellnessWeekAgo = widget.wellnessWeekAgo;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final ctl = wellness?.ctl;
    final atl = wellness?.atl;
    final form = ctl != null && atl != null ? ctl - atl : null;
    final formWeekAgo =
        wellnessWeekAgo?.ctl != null && wellnessWeekAgo?.atl != null
        ? wellnessWeekAgo!.ctl! - wellnessWeekAgo.atl!
        : null;

    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    final tssToday = StatTile(
      label: l10n.tssToday,
      value: todaysLoad?.toString() ?? '—',
      subtitle: todaysPlannedLoad > 0
          ? l10n.ofPlanned(todaysPlannedLoad)
          : null,
      icon: Icons.bolt_outlined,
      color: colorScheme.primary,
      onTap: () => open(const TssHistoryScreen()),
      compact: true,
      sparkValues: _spark[TileMetric.tssToday]?.values,
      trend: _spark[TileMetric.tssToday]?.trend,
      hoverPreview: (_) => MetricPreview(
        metric: TileMetric.tssToday,
        color: colorScheme.primary,
      ),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.tssToday,
        label: l10n.tssToday,
        value: todaysLoad?.toString() ?? '—',
        color: colorScheme.primary,
        intervalsPath: 'fitness',
        onShowHistory: () => open(const TssHistoryScreen()),
      ),
    );
    final tssWeek = StatTile(
      // Actual load so far this week, against what the plan asks
      // for — the number that says "am I on track".
      label: l10n.tssWeek,
      value: weekLoad.toString(),
      subtitle: weekPlannedLoad > 0 ? l10n.ofPlanned(weekPlannedLoad) : null,
      icon: Icons.calendar_view_week_outlined,
      color: colorScheme.tertiary,
      onTap: () => open(const WeeklyLoadScreen()),
      compact: true,
      sparkValues: _spark[TileMetric.tssWeek]?.values,
      trend: _spark[TileMetric.tssWeek]?.trend,
      hoverPreview: (_) => MetricPreview(
        metric: TileMetric.tssWeek,
        color: colorScheme.tertiary,
      ),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.tssWeek,
        label: l10n.tssWeek,
        value: weekLoad.toString(),
        color: colorScheme.tertiary,
        intervalsPath: 'fitness',
        onShowHistory: () => open(const WeeklyLoadScreen()),
      ),
    );
    final ctlTile = StatTile(
      label: l10n.ctlLabel,
      value: _format(ctl),
      subtitle: _delta(ctl, wellnessWeekAgo?.ctl),
      icon: Icons.trending_up,
      color: colorScheme.tertiary,
      onTap: () => open(const MetricHistoryScreen(metric: LoadMetric.ctl)),
      compact: true,
      sparkValues: _spark[TileMetric.ctl]?.values,
      trend: _spark[TileMetric.ctl]?.trend,
      hoverPreview: (_) =>
          MetricPreview(metric: TileMetric.ctl, color: colorScheme.tertiary),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.ctl,
        label: l10n.ctlLabel,
        value: _format(ctl),
        color: colorScheme.tertiary,
        intervalsPath: 'fitness',
        onShowHistory: () =>
            open(const MetricHistoryScreen(metric: LoadMetric.ctl)),
      ),
    );
    final atlTile = StatTile(
      label: l10n.atlLabel,
      value: _format(atl),
      subtitle: _delta(atl, wellnessWeekAgo?.atl),
      icon: Icons.speed_outlined,
      color: colorScheme.secondary,
      onTap: () => open(const MetricHistoryScreen(metric: LoadMetric.atl)),
      compact: true,
      sparkValues: _spark[TileMetric.atl]?.values,
      trend: _spark[TileMetric.atl]?.trend,
      hoverPreview: (_) =>
          MetricPreview(metric: TileMetric.atl, color: colorScheme.secondary),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.atl,
        label: l10n.atlLabel,
        value: _format(atl),
        color: colorScheme.secondary,
        intervalsPath: 'fitness',
        onShowHistory: () =>
            open(const MetricHistoryScreen(metric: LoadMetric.atl)),
      ),
    );
    final formTile = StatTile(
      label: l10n.formLabel,
      value: _format(form),
      subtitle: _delta(form, formWeekAgo),
      icon: Icons.balance_outlined,
      color: colorScheme.primary,
      onTap: () => open(const MetricHistoryScreen(metric: LoadMetric.form)),
      compact: true,
      sparkValues: _spark[TileMetric.form]?.values,
      trend: _spark[TileMetric.form]?.trend,
      hoverPreview: (_) =>
          MetricPreview(metric: TileMetric.form, color: colorScheme.primary),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.form,
        label: l10n.formLabel,
        value: _format(form),
        color: colorScheme.primary,
        intervalsPath: 'fitness',
        onShowHistory: () =>
            open(const MetricHistoryScreen(metric: LoadMetric.form)),
      ),
    );
    final rampTile = StatTile(
      label: l10n.rampRateLabel,
      value: _format(wellness?.rampRate),
      subtitle: _delta(wellness?.rampRate, wellnessWeekAgo?.rampRate),
      icon: Icons.stacked_line_chart_outlined,
      color: colorScheme.secondary,
      onTap: () => open(const MetricHistoryScreen(metric: LoadMetric.rampRate)),
      compact: true,
      sparkValues: _spark[TileMetric.rampRate]?.values,
      trend: _spark[TileMetric.rampRate]?.trend,
      hoverPreview: (_) => MetricPreview(
        metric: TileMetric.rampRate,
        color: colorScheme.secondary,
      ),
      onLongPress: () => showTileDetailsSheet(
        context,
        metric: TileMetric.rampRate,
        label: l10n.rampRateLabel,
        value: _format(wellness?.rampRate),
        color: colorScheme.secondary,
        intervalsPath: 'fitness',
        onShowHistory: () =>
            open(const MetricHistoryScreen(metric: LoadMetric.rampRate)),
      ),
    );

    final all = _expanded || widget.allTiles;
    return Column(
      key: const ValueKey('load-tiles'),
      children: [
        if (all) ...[
          _TileRow(children: [tssToday, tssWeek]),
          const SizedBox(height: 6),
          _TileRow(children: [ctlTile, atlTile]),
          const SizedBox(height: 6),
          _TileRow(children: [formTile, rampTile]),
        ] else
          _TileRow(children: [ctlTile, atlTile, formTile]),
        if (!widget.allTiles)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('more-metrics'),
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _expanded ? l10n.todayFewerMetrics : l10n.todayMoreMetrics,
              ),
            ),
          ),
      ],
    );
  }

  static String _format(double? value) => value?.toStringAsFixed(1) ?? '—';

  /// Change since the same day last week, or `null` when either end is
  /// missing — a made-up baseline would be worse than no comparison.
  static String? _delta(double? now, double? weekAgo) {
    if (now == null || weekAgo == null) return null;
    final delta = now - weekAgo;
    if (delta.abs() < 0.05) return '±0.0';
    return '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}';
  }
}

/// Two equal-width tiles side by side, the layout unit Today's grid is
/// built from.
///
/// [IntrinsicHeight] so a tile with a comparison line under its label
/// doesn't leave the one next to it visibly shorter — `stretch` alone can't
/// do it inside a `ListView`, where the row's height is unbounded.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ],
    ),
  );
}

/// Points a not-yet-configured user at whichever setup step is still
/// missing — Intervals.icu connection, an LLM provider, or both — so a
/// first launch isn't a dead end of "not connected" labels with no next
/// step.
class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LlmSettings.instance,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final needsIntervals = !connected;
        final needsLlm = !LlmSettings.instance.isConfigured;
        if (!needsIntervals && !needsLlm) return const SizedBox.shrink();

        return SectionCard(
          icon: Icons.rocket_launch_outlined,
          title: l10n.finishSettingUp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (needsIntervals)
                _SetupRow(
                  text: l10n.connectIntervalsPrompt,
                  buttonLabel: l10n.openProfileButton,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
              if (needsIntervals && needsLlm) const SizedBox(height: 12),
              if (needsLlm)
                _SetupRow(
                  text: l10n.setupLlmPrompt,
                  buttonLabel: l10n.openSettingsButton,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SettingsGroupScreen(group: SettingsGroup.ai),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SetupRow extends StatelessWidget {
  const _SetupRow({
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
      ],
    );
  }
}

/// Renders the planned sessions for one day, or why there are none.
class _PlannedTraining extends StatelessWidget {
  const _PlannedTraining({
    required this.events,
    required this.emptyLabel,
    this.onLongPress,
    this.onEmptyLongPress,
  });

  /// Offered on a long press of the "nothing planned" line, e.g. to propose
  /// a training for the day.
  final VoidCallback? onEmptyLongPress;

  /// Offered on a long press of any session, e.g. to delete the day's.
  final VoidCallback? onLongPress;
  final List<LocalEvent> events;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (events.isEmpty) {
      final text = Text(
        emptyLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
      if (onEmptyLongPress == null) return text;
      return InkWell(
        key: const ValueKey('planned-empty'),
        onLongPress: onEmptyLongPress,
        child: SizedBox(width: double.infinity, child: text),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final event in events) ...[
          if (event != events.first) const Divider(height: 20),
          InkWell(
            onLongPress: onLongPress,
            onTap: () => event.isPlanSession
                ? showPlanSessionSheetForEvent(context, event)
                : Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlannedWorkoutDetailScreen(event: event),
                    ),
                  ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name ?? event.type ?? l10n.plannedSessionFallback,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _describe(l10n, event),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _describe(AppLocalizations l10n, LocalEvent event) {
    final parts = <String>[
      if (event.type != null) event.type!,
      if (event.indoor) l10n.indoorLabel,
      if (event.plannedTime != null) _formatDuration(event.plannedTime!),
      if (event.plannedDistance != null && event.plannedDistance! > 0)
        '${(event.plannedDistance! / 1000).toStringAsFixed(1)} km',
      if (event.plannedLoad != null) '${event.plannedLoad} ${l10n.tssSuffix}',
    ];
    return parts.isEmpty ? l10n.noTargetSet : parts.join(' · ');
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

/// Today's logged activities, tappable through to the full detail view.
class _TodayActivities extends StatelessWidget {
  const _TodayActivities({required this.activities});

  final List<LocalActivity> activities;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final activity in activities) ...[
          if (activity != activities.first) const Divider(height: 1),
          // Hold a row to peek at its key figures; a tap opens the activity.
          Peekable(
            preview: (_) => ActivityPeek(activity: activity),
            child: ListTile(
              key: ValueKey('today-activity-${activity.id}'),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActivityDetailScreen(activity: activity),
                ),
              ),
              leading: Icon(
                activityTypeIcon(activity.type),
                color: colorScheme.primary,
              ),
              title: Text(
                activity.name ?? activity.type ?? l10n.activityFallback,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [
                  if (activity.distance != null && activity.distance! > 0)
                    formatDistanceMeters(activity.distance!),
                  if (activity.movingTime != null && activity.movingTime! > 0)
                    formatDurationSecs(activity.movingTime!),
                  if (activity.trainingLoad != null)
                    '${activity.trainingLoad} ${l10n.tssSuffix}',
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ],
    );
  }
}
