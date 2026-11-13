import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/intervals_session.dart';
import '../../data/models/local_event.dart';
import '../../data/pending_deletes.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_changes.dart';
import '../../util/dates.dart';
import '../../widgets/charts/chart_theme.dart';
import '../../widgets/main_navigation.dart';
import '../statistics/heatmap_views.dart' show HeatmapPrefs;
import 'calendar_data.dart';
import 'calendar_day_detail.dart';
import 'calendar_level.dart';
import 'calendar_moves.dart';
import 'day_actions.dart';
import 'day_calendar_view.dart';
import 'day_cell_parts.dart';
import 'monthly_calendar_view.dart';
import 'week_actions.dart';
import 'weekly_calendar_view.dart';
import 'year_calendar_view.dart';

/// Training calendar with four zoom levels — year, month, week, day — moved
/// between by tapping (a month, a week number, a day), pinching, the level
/// buttons or the breadcrumb. Swipe sideways to change period, swipe down
/// on the header for today. Shows proposed (planned) and passed (completed)
/// trainings, colour-coded, from the local cache the same way Today does.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    this.active = true,
    this.loader,
    this.mover,
    this.today,
  });

  /// Whether this is the tab currently on screen. The shell keeps every tab
  /// alive in an `IndexedStack`, so switching back here doesn't rebuild the
  /// state — this flag is how the screen learns it became visible and can
  /// refresh a cache that has gone stale meanwhile.
  final bool active;

  /// Test seams; the app uses the cache, [PlanActions] and the clock.
  final CalendarLoader? loader;
  final CalendarMover? mover;
  final DateTime Function()? today;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _compactKey = 'calendar.compact';

  final _session = IntervalsSession.instance;
  late final CalendarLoader _loader =
      widget.loader ?? CalendarLoader(clock: widget.today);
  late final CalendarMover _mover =
      widget.mover ?? CalendarMover(clock: widget.today);

  CalendarLevel _level = CalendarLevel.month;
  late DateTime _date;
  CalendarFilter _filter = const CalendarFilter();
  bool _compact = true;
  bool _showFilters = false;
  HeatScale _heatScale = HeatScale.theme;

  bool _loading = true;
  String? _error;
  CalendarData _data = const CalendarData();
  int _loadSeq = 0;
  double _pinchScale = 1;

  DateTime get _today => dateOnly((widget.today ?? DateTime.now)());

  @override
  void initState() {
    super.initState();
    _date = _today;
    _session.addListener(_load);
    AutoSyncService.instance.addListener(_load);
    // A taken/changed plan and the copy switch change what is planned
    // without any sync happening.
    PlanChanges.instance.addListener(_load);
    PendingDeletes.instance.addListener(_onPendingDeletes);
    SyncSettings.instance.addListener(_load);
    MainNavigation.instance.addListener(_onNavigate);
    _restore();
  }

  /// Reopens on the level and date the calendar was left on, unless another
  /// screen asked for a date meanwhile.
  Future<void> _restore() async {
    final prefs = await CalendarPrefs.load();
    var compact = true;
    var scale = HeatScale.theme;
    try {
      final sp = await SharedPreferences.getInstance();
      compact = sp.getBool(_compactKey) ?? true;
      scale = (await HeatmapPrefs.load()).scale;
    } catch (error) {
      debugPrint('CalendarScreen: cannot read preferences: $error');
    }
    if (!mounted) return;
    // A date another screen asked for while this was loading wins.
    final navigated = _focusSeq != 0;
    setState(() {
      if (prefs != null && !navigated) {
        _level = prefs.level;
        if (prefs.date != null) _date = dateOnly(prefs.date!);
      }
      _compact = compact;
      _heatScale = scale;
    });
    _onNavigate(load: false);
    _load();
  }

  int _focusSeq = 0;

  /// Another screen asked for a date (Take as plan → the plan's week 1).
  void _onNavigate({bool load = true}) {
    final focus = MainNavigation.instance.calendarFocus;
    if (focus == null || focus.seq == _focusSeq) return;
    _focusSeq = focus.seq;
    setState(() {
      _date = focus.date;
      if (_level == CalendarLevel.year) _level = CalendarLevel.month;
    });
    _persist();
    if (load) _load();
  }

  void _onPendingDeletes() {
    // Rebuild at once (the filter hides pending deletes), then reread.
    if (mounted) setState(() {});
    _load();
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _load(freshness: CalendarFreshness.ifStale);
    }
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    AutoSyncService.instance.removeListener(_load);
    PlanChanges.instance.removeListener(_load);
    PendingDeletes.instance.removeListener(_onPendingDeletes);
    SyncSettings.instance.removeListener(_load);
    MainNavigation.instance.removeListener(_onNavigate);
    super.dispose();
  }

  /// What is fetched: the visible range, and for the day the whole week so
  /// a move's rule check sees the neighbouring days.
  (DateTime, DateTime) get _loadRange => calendarRange(
    _level == CalendarLevel.day ? CalendarLevel.week : _level,
    _date,
  );

  Future<void> _load({
    CalendarFreshness freshness = CalendarFreshness.ifMissing,
  }) async {
    if (!mounted) return;
    final seq = ++_loadSeq;
    setState(() {
      _loading = true;
      _error = null;
    });

    final (oldest, newest) = _loadRange;
    Object? syncError;
    try {
      await _loader.sync(oldest, newest, freshness);
    } catch (e) {
      syncError = e;
    }

    try {
      final data = await _loader.read(oldest, newest);
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        _data = data;
        _error = syncError?.toString();
        _loading = false;
      });
    } catch (e) {
      if (!mounted || seq != _loadSeq) return;
      setState(() {
        _error = (syncError ?? e).toString();
        _loading = false;
      });
    }
  }

  void _persist() => CalendarPrefs(_level, _date).save();

  void _go(CalendarLevel level, DateTime date) {
    final reload =
        level != _level ||
        calendarRange(level, date) != calendarRange(_level, _date);
    setState(() {
      _level = level;
      _date = dateOnly(date);
    });
    _persist();
    if (reload) _load();
  }

  void _shift(int amount) => _go(_level, shiftPeriod(_level, _date, amount));

  void _goToToday() => _go(_level, _today);

  void _zoomIn() {
    final inner = _level.inner;
    if (inner != null) _go(inner, _date);
  }

  void _zoomOut() {
    final outer = _level.outer;
    if (outer != null) _go(outer, _date);
  }

  /// A day was tapped: the first tap selects it, tapping the selected day
  /// again opens it.
  void _tapDay(DateTime date) {
    if (dateOnly(date) == _date) {
      _go(CalendarLevel.day, date);
    } else {
      _go(_level, date);
    }
  }

  void _openWeek(DateTime monday) {
    final inWeek =
        !_date.isBefore(monday) &&
        _date.isBefore(DateTime(monday.year, monday.month, monday.day + 7));
    _go(CalendarLevel.week, inWeek ? _date : monday);
  }

  void _openMonth(DateTime first) {
    final sameMonth = _date.year == first.year && _date.month == first.month;
    _go(CalendarLevel.month, sameMonth ? _date : first);
  }

  CalendarData get _visible => _filter.apply(_data);

  Future<void> _dayActions(DateTime date) async {
    if (dateOnly(date) != _date) _go(_level, date);
    final key = isoDate(date);
    final events = (_visible.eventsByDate[key] ?? const <LocalEvent>[])
        .where((e) => e.isTraining)
        .toList();
    await showDayActions(
      context,
      date,
      events,
      today: widget.today,
      activities: _visible.activitiesByDate[key] ?? const [],
    );
  }

  Future<void> _weekActions(DateTime monday) => showWeekActions(
    context,
    monday,
    today: widget.today,
    onOpenWeek: _level == CalendarLevel.week ? null : () => _openWeek(monday),
    summary: PeriodSummary(
      _visible,
      monday,
      DateTime(monday.year, monday.month, monday.day + 6),
      today: _today,
    ),
  );

  void _moveTo(LocalEvent event) =>
      pickAndMove(context, _mover, event, eventsByDate: _data.eventsByDate);

  void _drop(LocalEvent event, DateTime day) => moveWithUndo(
    context,
    _mover,
    event,
    day,
    eventsByDate: _data.eventsByDate,
  );

  Future<void> _setCompact(bool compact) async {
    setState(() => _compact = compact);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(_compactKey, compact);
    } catch (error) {
      debugPrint('CalendarScreen: cannot persist density: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Column(
      children: [
        GestureDetector(
          // Swipe down on the header: back to today.
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) > 300) _goToToday();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: _levelButtons(context, l10n),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('calendar-prev'),
                      onPressed: () => _shift(-1),
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.calPrevious,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(child: Center(child: _breadcrumb(context, l10n))),
                    IconButton(
                      key: const ValueKey('calendar-next'),
                      onPressed: () => _shift(1),
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.calNext,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Row(
                  children: [
                    Expanded(child: _summary(context, l10n)),
                    IconButton(
                      onPressed: _goToToday,
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.todayTooltip,
                      icon: const Icon(Icons.today_outlined),
                    ),
                    IconButton(
                      key: const ValueKey('calendar-filter'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          setState(() => _showFilters = !_showFilters),
                      tooltip: l10n.calFilterTooltip,
                      isSelected: _filter.isActive,
                      icon: const Icon(Icons.filter_list),
                      selectedIcon: const Icon(Icons.filter_list_alt),
                    ),
                    IconButton(
                      onPressed: _loading
                          ? null
                          : () => _load(freshness: CalendarFreshness.force),
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.refreshTooltip,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showFilters) _filterRow(context, l10n),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              _error!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
        Expanded(
          child: GestureDetector(
            // Pinch out = zoom in a level, pinch in = zoom out.
            onScaleStart: (_) => _pinchScale = 1,
            onScaleUpdate: (d) {
              if (d.pointerCount >= 2) _pinchScale = d.scale;
            },
            onScaleEnd: (_) {
              if (_pinchScale > 1.25) _zoomIn();
              if (_pinchScale < 0.8) _zoomOut();
              _pinchScale = 1;
            },
            child: GestureDetector(
              key: const ValueKey('calendar-swipe-area'),
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() < 250) return;
                _shift(v < 0 ? 1 : -1);
              },
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.94,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_level),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _body(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _levelButtons(BuildContext context, AppLocalizations l10n) {
    final iconsOnly = MediaQuery.textScalerOf(context).scale(14) > 18;
    ButtonSegment<CalendarLevel> seg(
      CalendarLevel level,
      String label,
      IconData icon,
    ) => ButtonSegment(
      value: level,
      tooltip: iconsOnly ? label : null,
      label: iconsOnly
          ? null
          : Text(
              label,
              key: ValueKey('level-${level.name}'),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
      icon: Icon(icon, key: iconsOnly ? ValueKey('level-${level.name}') : null),
    );
    return SegmentedButton<CalendarLevel>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: const TextStyle(fontSize: 12),
        iconSize: 16,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: [
        seg(CalendarLevel.year, l10n.calendarYear, Icons.calendar_today),
        seg(CalendarLevel.month, l10n.calendarMonth, Icons.calendar_view_month),
        seg(CalendarLevel.week, l10n.calendarWeek, Icons.calendar_view_week),
        seg(CalendarLevel.day, l10n.calendarDay, Icons.calendar_view_day),
      ],
      selected: {_level},
      onSelectionChanged: (s) => _go(s.first, _date),
    );
  }

  /// "2026 › November › Week 46 › Thu 13", each part but the last tappable
  /// to jump back up.
  Widget _breadcrumb(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final parts = <(CalendarLevel, String)>[
      (CalendarLevel.year, '${_date.year}'),
      if (_level.index >= CalendarLevel.month.index)
        (CalendarLevel.month, DateFormat.MMMM(locale).format(_date)),
      if (_level.index >= CalendarLevel.week.index)
        (CalendarLevel.week, l10n.calBreadcrumbWeek(isoWeekNumber(_date))),
      if (_level == CalendarLevel.day)
        (CalendarLevel.day, DateFormat.MMMEd(locale).format(_date)),
    ];
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      final (level, label) = parts[i];
      final current = level == _level;
      if (i > 0) {
        children.add(
          ExcludeSemantics(
            child: Text(
              ' › ',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      final style = theme.textTheme.titleMedium?.copyWith(
        fontWeight: current ? FontWeight.w700 : FontWeight.w500,
        color: current ? null : theme.colorScheme.primary,
      );
      children.add(
        current
            ? Semantics(
                header: true,
                child: Text(
                  label,
                  key: ValueKey('crumb-${level.name}'),
                  style: style,
                ),
              )
            : Semantics(
                button: true,
                label: l10n.calGoTo(label),
                excludeSemantics: true,
                child: InkWell(
                  key: ValueKey('crumb-${level.name}'),
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _go(level, _date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 6,
                    ),
                    child: Text(label, style: style),
                  ),
                ),
              ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  /// The visible period's done vs. planned load, hours, sessions and CTL
  /// change.
  Widget _summary(BuildContext context, AppLocalizations l10n) {
    final (DateTime from, DateTime to) = switch (_level) {
      CalendarLevel.month => (
        DateTime(_date.year, _date.month, 1),
        DateTime(_date.year, _date.month + 1, 0),
      ),
      _ => calendarRange(_level, _date),
    };
    final s = PeriodSummary(_visible, from, to, today: _today);
    var text = l10n.calSummary(
      s.doneTss,
      s.plannedTss,
      (s.doneMinutes / 60).toStringAsFixed(1),
      s.doneCount,
      s.plannedCount,
    );
    final ctl = s.ctlChange;
    if (ctl != null && _level != CalendarLevel.day) {
      final sign = ctl >= 0 ? '+' : '−';
      text +=
          ' · ${l10n.calSummaryCtl('$sign${ctl.abs().toStringAsFixed(1)}')}';
    }
    return Text(
      text,
      key: const ValueKey('calendar-summary'),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _filterRow(BuildContext context, AppLocalizations l10n) {
    Widget chip(Key key, String label, bool selected, VoidCallback onTap) =>
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: FilterChip(
            key: key,
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
          ),
        );
    return SingleChildScrollView(
      key: const ValueKey('calendar-filters'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          for (final s in CalendarSport.values)
            chip(
              ValueKey('filter-${s.name}'),
              calendarSportLabel(l10n, s),
              _filter.sports.contains(s),
              () => setState(() {
                final sports = {..._filter.sports};
                if (!sports.remove(s)) sports.add(s);
                _filter = _filter.copyWith(sports: sports);
              }),
            ),
          chip(
            const ValueKey('filter-planned'),
            l10n.plannedStatus,
            _filter.planned,
            () => setState(
              () => _filter = _filter.copyWith(planned: !_filter.planned),
            ),
          ),
          chip(
            const ValueKey('filter-completed'),
            l10n.completedStatus,
            _filter.completed,
            () => setState(
              () => _filter = _filter.copyWith(completed: !_filter.completed),
            ),
          ),
          if (_level == CalendarLevel.month)
            chip(
              const ValueKey('density-compact'),
              l10n.calDensityCompact,
              _compact,
              () => _setCompact(!_compact),
            ),
        ],
      ),
    );
  }

  Widget _dayDetail(BuildContext context, CalendarData data) {
    final key = isoDate(_date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: CalendarDayDetail(
        date: _date,
        events: data.eventsByDate[key] ?? const [],
        dayEvents: data.dayEventsByDate[key] ?? const [],
        activities: data.activitiesByDate[key] ?? const [],
        today: widget.today,
        mover: _mover,
        onMove: _moveTo,
        swipeActions: true,
        onOpenDay: () => _go(CalendarLevel.day, _date),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final data = _visible;
    switch (_level) {
      case CalendarLevel.year:
        return YearCalendarView(
          year: _date.year,
          activitiesByDate: data.activitiesByDate,
          dayEventsByDate: data.dayEventsByDate,
          plan: data.plan,
          scale: _heatScale,
          selectedDate: _date,
          today: widget.today,
          onOpenMonth: _openMonth,
        );
      case CalendarLevel.month:
        return Column(
          children: [
            MonthlyCalendarView(
              month: _date,
              selectedDate: _date,
              eventsByDate: data.eventsByDate,
              dayEventsByDate: data.dayEventsByDate,
              activitiesByDate: data.activitiesByDate,
              readinessByDate: data.readinessByDate,
              onSelect: _tapDay,
              onLongPress: _dayActions,
              onOpenWeek: _openWeek,
              onWeekLongPress: _weekActions,
              onDrop: _drop,
              mover: _mover,
              compact: _compact,
              today: widget.today,
            ),
            _dayDetail(context, data),
          ],
        );
      case CalendarLevel.week:
        final (monday, _) = calendarRange(CalendarLevel.week, _date);
        return Column(
          children: [
            WeeklyCalendarView(
              weekStart: monday,
              selectedDate: _date,
              eventsByDate: data.eventsByDate,
              dayEventsByDate: data.dayEventsByDate,
              activitiesByDate: data.activitiesByDate,
              readinessByDate: data.readinessByDate,
              onSelect: _tapDay,
              onLongPress: _dayActions,
              onDrop: _drop,
              mover: _mover,
              onWeekActions: () => _weekActions(monday),
              today: widget.today,
            ),
            _dayDetail(context, data),
          ],
        );
      case CalendarLevel.day:
        final key = isoDate(_date);
        return DayCalendarView(
          date: _date,
          events: data.eventsByDate[key] ?? const [],
          dayEvents: data.dayEventsByDate[key] ?? const [],
          activities: data.activitiesByDate[key] ?? const [],
          readiness: data.readinessByDate[key],
          wellness: data.wellnessByDate[key],
          mover: _mover,
          onMove: _moveTo,
          today: widget.today,
        );
    }
  }
}
