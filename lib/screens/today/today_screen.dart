import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../agent/llm_settings.dart';
import '../../agent/plan_proposals.dart';
import '../../data/intervals_session.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/adaptation_service.dart';
import '../../plan/plan_changes.dart';
import '../../plan/plan_models.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/models/local_wellness.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/repositories/plans_repository.dart';
import '../../data/repositories/wellness_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../data/sync/sync_service.dart';
import '../../evaluation/readiness_service.dart';
import '../../util/dates.dart';
import '../../util/intervals_links.dart';
import '../../widgets/athlete_avatar.dart';
import '../../widgets/section_card.dart';
import '../../widgets/stat_tile.dart';
import '../activities/activity_detail_screen.dart';
import '../activities/activity_icons.dart';
import '../activities/planned_workout_detail_screen.dart';
import '../chat/proposal_card.dart';
import '../plan/plan_session_sheet.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'athlete_detail_screen.dart';
import 'metric_history_screen.dart';
import 'readiness_card.dart';
import 'train_now_screen.dart';
import '../statistics/threshold_suggestion_card.dart';
import 'tss_history_screen.dart';
import 'weekly_load_screen.dart';
import 'weekly_targets_row.dart';

/// Today's and tomorrow's planned training, what was actually logged, and
/// the key load metrics (TSS today, TSS this week, CTL/ATL).
///
/// Opening the screen (and any change to the Intervals.icu connection)
/// fetches the current week plus tomorrow if today isn't cached yet.
/// Pull-to-refresh always refetches, scoped to just today so the gesture
/// stays fast. Display always reads from SQLite, so the screen works
/// offline once synced.
class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    this.wellnessRepository,
    this.activitiesRepository,
    this.plannedItems,
    this.readinessService,
    this.adaptationService,
    this.goalStore,
    this.plansRepository,
  });

  /// Test seams; the app uses the defaults.
  final WellnessRepository? wellnessRepository;
  final ActivitiesRepository? activitiesRepository;
  final PlannedItemsRepository? plannedItems;
  final ReadinessService? readinessService;
  final AdaptationService? adaptationService;
  final GoalStore? goalStore;
  final PlansRepository? plansRepository;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _session = IntervalsSession.instance;
  final _syncService = SyncService();
  late final _wellnessRepository =
      widget.wellnessRepository ?? WellnessRepository();
  late final _activitiesRepository =
      widget.activitiesRepository ?? ActivitiesRepository();
  late final _eventsRepository =
      widget.plannedItems ?? PlannedItemsRepository();
  late final _readinessService =
      widget.readinessService ??
      ReadinessService(wellness: _wellnessRepository);
  late final _adaptationService =
      widget.adaptationService ??
      AdaptationService(
        plans: widget.plansRepository,
        goals: widget.goalStore,
        activities: _activitiesRepository,
        readiness: _readinessService,
      );

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
  List<LocalActivity> _activities = const [];
  List<LocalActivity> _weekActivities = const [];
  List<LocalEvent> _todaysPlan = const [];
  List<LocalEvent> _tomorrowsPlan = const [];
  int _weekLoad = 0;
  int _weekPlannedLoad = 0;

  static String get _today => isoDate(DateTime.now());

  static String get _tomorrow =>
      isoDate(DateTime.now().add(const Duration(days: 1)));

  @override
  void initState() {
    super.initState();
    _session.addListener(_load);
    AutoSyncService.instance.addListener(_onCacheChanged);
    PlanChanges.instance.addListener(_onCacheChanged);
    SyncSettings.instance.addListener(_onCacheChanged);
    _load();
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    AutoSyncService.instance.removeListener(_onCacheChanged);
    PlanChanges.instance.removeListener(_onCacheChanged);
    SyncSettings.instance.removeListener(_onCacheChanged);
    super.dispose();
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

  /// Pull-to-refresh: refetch just today. [SyncService.refreshRange] decides
  /// whether that costs a fetch — it joins one already running instead of
  /// starting a second, skips it entirely within [SyncService.refreshMinGap]
  /// of the last one, and gives up waiting after [SyncService.refreshTimeout]
  /// — so the gesture is always cheap to repeat.
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
      final (weekStart, weekEnd) = SyncService.todayWindow();
      final wellness = await _wellnessRepository.getByDate(_today);
      final wellnessWeekAgo = await _wellnessRepository.getByDate(
        isoDate(DateTime.now().subtract(const Duration(days: 7))),
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
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return fetched;
      setState(() {
        _error = (syncError ?? e).toString();
        _loading = false;
      });
    }
    // Independent of each other: a slow one never holds the others back.
    await Future.wait([
      _loadReadiness().then((_) => _loadAdjustments()),
      _loadRaceCountdown(),
    ]);
    return fetched;
  }

  Future<void> _loadRaceCountdown() async {
    try {
      final plan = await (widget.plansRepository ?? PlansRepository())
          .getCurrent();
      final goal = await (widget.goalStore ?? GoalStore()).load();
      final event = goal?.eventDate;
      int? days;
      if (plan?.status == PlanStatus.active && event != null) {
        final today = dateOnly(DateTime.now());
        days = DateTime.utc(
          event.year,
          event.month,
          event.day,
        ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
        if (days < 0) days = null;
      }
      if (mounted) setState(() => _raceDays = days);
    } catch (e) {
      debugPrint('TodayScreen: race countdown unavailable: $e');
    }
  }

  Future<void> _loadAdjustments() async {
    try {
      final adjustments = await _adaptationService.refresh();
      if (mounted) setState(() => _adjustments = adjustments);
    } catch (e) {
      debugPrint('TodayScreen: plan adjustments unavailable: $e');
    }
  }

  /// Readiness after the rest of the screen, so a slow knowledge load or a
  /// bad wellness row only costs the readiness row, never the load tiles.
  Future<void> _loadReadiness() async {
    try {
      final readiness = await _readinessService.load();
      if (mounted) setState(() => _readiness = readiness);
    } catch (e) {
      debugPrint('TodayScreen: readiness unavailable: $e');
      if (mounted) setState(() => _readiness = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final connected = _session.isConnected;

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

    return RefreshIndicator(
      onRefresh: _refreshFromGesture,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.tertiary],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.MMMMEEEEd(
                          Localizations.localeOf(context).toString(),
                        ).format(DateTime.now()).toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.heroActivitiesStatus(_activities.length),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _describeStatus(context, connected),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Doubles as the refresh affordance: pull-to-refresh is
                // fine on a phone but awkward with a mouse on Windows.
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _refreshFromGesture,
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(),
                          tooltip: l10n.refreshTooltip,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (_raceDays case final days?) ...[
            const SizedBox(height: 12),
            Row(
              key: const ValueKey('race-countdown'),
              children: [
                Icon(Icons.flag_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  days == 0 ? l10n.todayRaceDay : l10n.todayRaceCountdown(days),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TrainNowScreen())),
              icon: const Icon(Icons.fitness_center),
              label: Text(l10n.titleTrainNow),
            ),
          ),
          const SizedBox(height: 16),
          _SetupBanner(connected: connected),
          if (_error != null) ...[
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.error_outline,
              title: l10n.syncFailed,
              child: Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          if (_readiness case final readiness?) ...[
            const SizedBox(height: 16),
            ReadinessCard(report: readiness),
            if (ReadinessHint.hardSessionFor(
                  readiness.readiness,
                  _todaysPlan,
                ) !=
                null) ...[
              const SizedBox(height: 12),
              ReadinessHint(
                readiness: readiness.readiness,
                todaysPlan: _todaysPlan,
              ),
            ],
          ],
          if (_adjustments.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionCard(
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
          ],
          const SizedBox(height: 16),
          _MetricTiles(
            todaysLoad: todaysLoad,
            todaysPlannedLoad: todaysPlannedLoad,
            weekLoad: _weekLoad,
            weekPlannedLoad: _weekPlannedLoad,
            wellness: _wellness,
            wellnessWeekAgo: _wellnessWeekAgo,
          ),
          WeeklyTargetsRow(weekActivities: _weekActivities),
          ThresholdSuggestionsSection(),
          if (_activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.check_circle_outline,
              title: l10n.todaysActivities,
              child: _TodayActivities(activities: _activities),
            ),
          ],
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.event_available_outlined,
            title: l10n.todaysTraining,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // What today's session (or rest day) means for the week's
                // plan as a whole — the "am I still on track" line the
                // planned-vs-completed numbers alone don't spell out.
                // Shown without a connection too: a TriIQ plan is local.
                if (_weekPlannedLoad > 0) ...[
                  _WeeklyGoalProgress(
                    completed: _weekLoad,
                    planned: _weekPlannedLoad,
                  ),
                  const SizedBox(height: 12),
                ],
                _PlannedTraining(
                  events: _todaysPlan,
                  emptyLabel: connected
                      ? l10n.nothingPlannedToday
                      : l10n.connectToSeePlan,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            icon: Icons.event_outlined,
            title: l10n.tomorrowsTraining,
            child: _PlannedTraining(
              events: _tomorrowsPlan,
              emptyLabel: connected
                  ? l10n.nothingPlannedTomorrow
                  : l10n.connectToSeePlan,
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
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
      ),
    );
  }

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

  String _describeStatus(BuildContext context, bool connected) {
    final l10n = AppLocalizations.of(context)!;
    if (!connected) return l10n.notConnectedToIntervals;
    if (_activities.isEmpty) return l10n.noWorkoutLoggedToday;
    final names = _activities
        .map((a) => a.name ?? a.type ?? l10n.activityFallback)
        .join(', ');
    return names;
  }
}

/// The load metrics on Today, every one of them a way into its own history.
///
/// Six numbers in three rows rather than a scrolling wall: what today cost,
/// what the week has cost, and the four Intervals.icu figures that put both
/// in context. Each tile carries the comparison the number needs — today
/// against what was planned, CTL/ATL against the same day last week — and
/// opens the chart behind it on tap.
class _MetricTiles extends StatelessWidget {
  const _MetricTiles({
    required this.todaysLoad,
    required this.todaysPlannedLoad,
    required this.weekLoad,
    required this.weekPlannedLoad,
    required this.wellness,
    required this.wellnessWeekAgo,
  });

  final int? todaysLoad;
  final int todaysPlannedLoad;
  final int weekLoad;
  final int weekPlannedLoad;
  final LocalWellness? wellness;
  final LocalWellness? wellnessWeekAgo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final ctl = wellness?.ctl;
    final atl = wellness?.atl;
    final form = ctl != null && atl != null ? ctl - atl : null;
    final formWeekAgo =
        wellnessWeekAgo?.ctl != null && wellnessWeekAgo?.atl != null
        ? wellnessWeekAgo!.ctl! - wellnessWeekAgo!.atl!
        : null;

    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Column(
      children: [
        _TileRow(
          children: [
            StatTile(
              label: l10n.tssToday,
              value: todaysLoad?.toString() ?? '—',
              subtitle: todaysPlannedLoad > 0
                  ? l10n.ofPlanned(todaysPlannedLoad)
                  : null,
              icon: Icons.bolt_outlined,
              color: colorScheme.primary,
              onTap: () => open(const TssHistoryScreen()),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.tssToday,
                path: 'fitness',
              ),
            ),
            StatTile(
              // Actual load so far this week, against what the plan asks
              // for — the number that says "am I on track".
              label: l10n.tssWeek,
              value: weekLoad.toString(),
              subtitle: weekPlannedLoad > 0
                  ? l10n.ofPlanned(weekPlannedLoad)
                  : null,
              icon: Icons.calendar_view_week_outlined,
              color: colorScheme.tertiary,
              onTap: () => open(const WeeklyLoadScreen()),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.tssWeek,
                path: 'fitness',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TileRow(
          children: [
            StatTile(
              label: l10n.ctlLabel,
              value: _format(ctl),
              subtitle: _delta(ctl, wellnessWeekAgo?.ctl),
              icon: Icons.trending_up,
              color: colorScheme.tertiary,
              onTap: () =>
                  open(const MetricHistoryScreen(metric: LoadMetric.ctl)),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.ctlLabel,
                path: 'fitness',
              ),
            ),
            StatTile(
              label: l10n.atlLabel,
              value: _format(atl),
              subtitle: _delta(atl, wellnessWeekAgo?.atl),
              icon: Icons.speed_outlined,
              color: colorScheme.secondary,
              onTap: () =>
                  open(const MetricHistoryScreen(metric: LoadMetric.atl)),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.atlLabel,
                path: 'fitness',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TileRow(
          children: [
            StatTile(
              label: l10n.formLabel,
              value: _format(form),
              subtitle: _delta(form, formWeekAgo),
              icon: Icons.balance_outlined,
              color: colorScheme.primary,
              onTap: () =>
                  open(const MetricHistoryScreen(metric: LoadMetric.form)),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.formLabel,
                path: 'fitness',
              ),
            ),
            StatTile(
              label: l10n.rampRateLabel,
              value: _format(wellness?.rampRate),
              subtitle: _delta(wellness?.rampRate, wellnessWeekAgo?.rampRate),
              icon: Icons.stacked_line_chart_outlined,
              color: colorScheme.secondary,
              onTap: () =>
                  open(const MetricHistoryScreen(metric: LoadMetric.rampRate)),
              onLongPress: () => showOpenInIntervalsSheet(
                context,
                label: l10n.rampRateLabel,
                path: 'fitness',
              ),
            ),
          ],
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
          if (index > 0) const SizedBox(width: 12),
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
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

/// This week's completed load against its planned total (the sum of every
/// planned event in the week, [TodayScreen._weekPlannedLoad]) — the "goal"
/// today's session is working toward.
class _WeeklyGoalProgress extends StatelessWidget {
  const _WeeklyGoalProgress({required this.completed, required this.planned});

  final int completed;
  final int planned;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = planned - completed;
    final progress = (completed / planned).clamp(0.0, 1.0);
    final accent = remaining > 0 ? colorScheme.primary : colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          remaining > 0
              ? l10n.weeklyGoalProgress(completed, planned, remaining)
              : l10n.weeklyGoalReached(completed, planned),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: accent,
          ),
        ),
      ],
    );
  }
}

/// Renders the planned sessions for one day, or why there are none.
class _PlannedTraining extends StatelessWidget {
  const _PlannedTraining({required this.events, required this.emptyLabel});

  final List<LocalEvent> events;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (events.isEmpty) {
      return Text(
        emptyLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final event in events) ...[
          if (event != events.first) const Divider(height: 20),
          InkWell(
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
          ListTile(
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
        ],
      ],
    );
  }
}
