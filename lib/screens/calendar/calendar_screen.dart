import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../data/intervals_session.dart';
import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../data/repositories/activities_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../data/sync/sync_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_changes.dart';
import '../../widgets/main_navigation.dart';
import 'calendar_day_detail.dart';
import 'monthly_calendar_view.dart';
import 'weekly_calendar_view.dart';

enum CalendarViewMode { month, week }

/// How hard [_CalendarScreenState._load] tries to refetch before reading
/// the cache.
enum _Freshness {
  /// Only fetch a span that has never been synced — plain navigation
  /// between months, where an already-seen month costs nothing.
  ifMissing,

  /// Fetch unless the cache was refreshed within [SyncService.staleAfter] —
  /// arriving on the tab, which should show current data without paying for
  /// a round-trip every time the tab is bounced.
  ifStale,

  /// Always fetch — the refresh button.
  force,
}

/// Training calendar: monthly view switchable to a weekly view, showing
/// both proposed (planned) and passed (completed) trainings, colour-coded
/// and reading from the local cache the same way Today does.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.active = true});

  /// Whether this is the tab currently on screen. The shell keeps every tab
  /// alive in an `IndexedStack`, so switching back here doesn't rebuild the
  /// state — this flag is how the screen learns it became visible and can
  /// refresh a cache that has gone stale meanwhile.
  final bool active;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _session = IntervalsSession.instance;
  final _syncService = SyncService();
  final _activitiesRepository = ActivitiesRepository();
  final _eventsRepository = PlannedItemsRepository();

  CalendarViewMode _mode = CalendarViewMode.month;
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  bool _loading = true;
  String? _error;
  Map<String, List<LocalEvent>> _eventsByDate = const {};
  Map<String, List<LocalActivity>> _activitiesByDate = const {};

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedDate = today;
    _selectedDate = today;
    _session.addListener(_load);
    AutoSyncService.instance.addListener(_load);
    // A taken/changed plan and the copy switch change what is planned
    // without any sync happening.
    PlanChanges.instance.addListener(_load);
    SyncSettings.instance.addListener(_load);
    MainNavigation.instance.addListener(_onNavigate);
    _onNavigate(load: false);
    _load();
  }

  int _focusSeq = 0;

  /// Another screen asked for a date (Take as plan → the plan's week 1).
  void _onNavigate({bool load = true}) {
    final focus = MainNavigation.instance.calendarFocus;
    if (focus == null || focus.seq == _focusSeq) return;
    _focusSeq = focus.seq;
    _focusedDate = focus.date;
    _selectedDate = focus.date;
    if (load) {
      setState(() {});
      _load();
    }
  }

  @override
  void didUpdateWidget(CalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _load(freshness: _Freshness.ifStale);
    }
  }

  @override
  void dispose() {
    _session.removeListener(_load);
    AutoSyncService.instance.removeListener(_load);
    PlanChanges.instance.removeListener(_load);
    SyncSettings.instance.removeListener(_load);
    MainNavigation.instance.removeListener(_onNavigate);
    super.dispose();
  }

  (DateTime, DateTime) get _visibleRange {
    if (_mode == CalendarViewMode.week) {
      final start = _focusedDate.subtract(
        Duration(days: _focusedDate.weekday - 1),
      );
      return (start, start.add(const Duration(days: 6)));
    }
    final firstOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final gridStart = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );
    return (gridStart, gridStart.add(const Duration(days: 41)));
  }

  Future<void> _load({_Freshness freshness = _Freshness.ifMissing}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final (oldest, newest) = _visibleRange;
    Object? syncError;
    try {
      switch (freshness) {
        case _Freshness.ifMissing:
          await _syncService.syncRangeIfMissing(oldest, newest);
        case _Freshness.ifStale:
          await _syncService.syncRangeIfStale(oldest, newest);
        case _Freshness.force:
          // syncRange throws when disconnected; the other two already
          // no-op in that case, and an offline calendar should just show
          // what's cached.
          if (_session.isConnected) {
            await _syncService.syncRange(oldest, newest);
          }
      }
    } catch (e) {
      syncError = e;
    }

    try {
      final events = await _eventsRepository.getRange(
        _fmt(oldest),
        _fmt(newest),
      );
      final activities = await _activitiesRepository.getRange(
        _fmt(oldest),
        _fmt(newest),
      );

      final eventsByDate = <String, List<LocalEvent>>{};
      for (final event in events) {
        eventsByDate.putIfAbsent(event.date, () => []).add(event);
      }
      final activitiesByDate = <String, List<LocalActivity>>{};
      for (final activity in activities) {
        activitiesByDate.putIfAbsent(activity.date, () => []).add(activity);
      }

      if (!mounted) return;
      setState(() {
        _eventsByDate = eventsByDate;
        _activitiesByDate = activitiesByDate;
        _error = syncError?.toString();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = (syncError ?? e).toString();
        _loading = false;
      });
    }
  }

  void _shiftFocus(int amount) {
    setState(() {
      _focusedDate = _mode == CalendarViewMode.week
          ? _focusedDate.add(Duration(days: 7 * amount))
          : DateTime(_focusedDate.year, _focusedDate.month + amount, 1);
    });
    _load();
  }

  void _goToToday() {
    setState(() {
      _focusedDate = _dateOnly(DateTime.now());
      _selectedDate = _focusedDate;
    });
    _load();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
    });
  }

  void _setMode(CalendarViewMode mode) {
    setState(() => _mode = mode);
    _load();
  }

  String _periodLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (_mode == CalendarViewMode.month) {
      return DateFormat.yMMMM(locale).format(_focusedDate);
    }
    final (start, end) = _visibleRange;
    final day = DateFormat.MMMd(locale);
    return '${day.format(start)} – ${day.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final key = _fmt(_selectedDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<CalendarViewMode>(
            segments: [
              ButtonSegment(
                value: CalendarViewMode.month,
                label: Text(l10n.calendarMonth),
                icon: const Icon(Icons.calendar_view_month),
              ),
              ButtonSegment(
                value: CalendarViewMode.week,
                label: Text(l10n.calendarWeek),
                icon: const Icon(Icons.calendar_view_week),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => _setMode(selection.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _shiftFocus(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _periodLabel(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _shiftFocus(1),
                icon: const Icon(Icons.chevron_right),
              ),
              IconButton(
                onPressed: _goToToday,
                tooltip: l10n.todayTooltip,
                icon: const Icon(Icons.today_outlined),
              ),
              IconButton(
                onPressed: _loading
                    ? null
                    : () => _load(freshness: _Freshness.force),
                tooltip: l10n.refreshTooltip,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Column(
              children: [
                _mode == CalendarViewMode.month
                    ? MonthlyCalendarView(
                        month: _focusedDate,
                        selectedDate: _selectedDate,
                        eventsByDate: _eventsByDate,
                        activitiesByDate: _activitiesByDate,
                        onSelect: _selectDate,
                      )
                    : WeeklyCalendarView(
                        weekStart: _visibleRange.$1,
                        selectedDate: _selectedDate,
                        eventsByDate: _eventsByDate,
                        activitiesByDate: _activitiesByDate,
                        onSelect: _selectDate,
                      ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: CalendarDayDetail(
                    date: _selectedDate,
                    events: _eventsByDate[key] ?? const [],
                    activities: _activitiesByDate[key] ?? const [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String _fmt(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
