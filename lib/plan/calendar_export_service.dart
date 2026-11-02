import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:timezone/timezone.dart' as tz;

import '../data/repositories/plans_repository.dart';
import '../util/markdown_to_text.dart';
import 'plan_models.dart';

/// A writable device calendar the athlete can choose.
class DeviceCalendarInfo {
  const DeviceCalendarInfo({required this.id, required this.name});
  final String id;
  final String name;
}

/// The device-calendar operations export needs — a seam so the export logic
/// is testable without the plugin.
abstract class CalendarGateway {
  /// Asks for (or confirms) calendar permission.
  Future<bool> requestPermission();
  Future<List<DeviceCalendarInfo>> writableCalendars();

  /// Creates or, when [eventId] is set, updates an all-day event. Returns
  /// the event's id, or null when the write failed.
  Future<String?> upsertAllDayEvent({
    required String calendarId,
    String? eventId,
    required String title,
    required String description,
    required DateTime day,
  });

  /// Returns whether the event is gone afterwards (missing counts).
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  });
}

/// [CalendarGateway] over the `device_calendar` plugin (Android).
class PluginCalendarGateway implements CalendarGateway {
  PluginCalendarGateway([dc.DeviceCalendarPlugin? plugin])
    : _plugin = plugin ?? dc.DeviceCalendarPlugin();

  final dc.DeviceCalendarPlugin _plugin;

  @override
  Future<bool> requestPermission() async {
    final has = await _plugin.hasPermissions();
    if (has.isSuccess && (has.data ?? false)) return true;
    final asked = await _plugin.requestPermissions();
    return asked.isSuccess && (asked.data ?? false);
  }

  @override
  Future<List<DeviceCalendarInfo>> writableCalendars() async {
    final result = await _plugin.retrieveCalendars();
    return [
      for (final c in result.data ?? const <dc.Calendar>[])
        if (!(c.isReadOnly ?? true) && c.id != null)
          DeviceCalendarInfo(id: c.id!, name: c.name ?? c.id!),
    ];
  }

  @override
  Future<String?> upsertAllDayEvent({
    required String calendarId,
    String? eventId,
    required String title,
    required String description,
    required DateTime day,
  }) async {
    final start = tz.TZDateTime.utc(day.year, day.month, day.day);
    final event = dc.Event(
      calendarId,
      eventId: eventId,
      title: title,
      description: description,
      start: start,
      end: start.add(const Duration(days: 1)),
      allDay: true,
    );
    final result = await _plugin.createOrUpdateEvent(event);
    return result?.isSuccess == true ? result!.data : null;
  }

  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    final result = await _plugin.deleteEvent(calendarId, eventId);
    return result.isSuccess;
  }
}

/// What an export did.
class CalendarExportReport {
  const CalendarExportReport({
    required this.created,
    required this.updated,
    required this.failed,
    this.permissionDenied = false,
  });

  final int created;
  final int updated;
  final int failed;
  final bool permissionDenied;
}

/// Writes plan sessions to a device calendar and remembers the event id of
/// each (`calendar_event_id`), so re-exporting updates in place — a moved
/// session moves its event — and never creates a duplicate.
class CalendarExportService {
  CalendarExportService({CalendarGateway? gateway, PlansRepository? plans})
    : _gateway = gateway ?? PluginCalendarGateway(),
      _plans = plans ?? PlansRepository();

  final CalendarGateway _gateway;
  final PlansRepository _plans;

  Future<bool> requestPermission() => _gateway.requestPermission();
  Future<List<DeviceCalendarInfo>> calendars() => _gateway.writableCalendars();

  /// Exports [sessions] (saved ones only) to [calendarId]. Nothing is
  /// written without permission.
  Future<CalendarExportReport> export(
    Iterable<PlanSession> sessions, {
    required String calendarId,
  }) async {
    if (!await _gateway.requestPermission()) {
      return const CalendarExportReport(
        created: 0,
        updated: 0,
        failed: 0,
        permissionDenied: true,
      );
    }
    var created = 0, updated = 0, failed = 0;
    for (final s in sessions) {
      if (s.id == null) continue;
      final existing = s.calendarEventId;
      String? id;
      try {
        id = await _gateway.upsertAllDayEvent(
          calendarId: calendarId,
          eventId: existing,
          title: s.name,
          description: markdownToPlainText(
            '${s.minutes} min · ${s.load} TSS\n\n${s.description}',
          ),
          day: s.date,
        );
      } catch (_) {
        id = null;
      }
      if (id == null) {
        failed++;
        continue;
      }
      if (existing == null) {
        created++;
      } else {
        updated++;
      }
      if (id != existing) {
        await _plans.updateSession(s.copyWith(calendarEventId: id));
      }
    }
    return CalendarExportReport(
      created: created,
      updated: updated,
      failed: failed,
    );
  }

  /// Removes the exported events of [sessions] from [calendarId] and
  /// forgets their ids.
  Future<int> remove(
    Iterable<PlanSession> sessions, {
    required String calendarId,
  }) async {
    if (!await _gateway.requestPermission()) return 0;
    var removed = 0;
    for (final s in sessions) {
      final id = s.calendarEventId;
      if (id == null || s.id == null) continue;
      if (await _gateway.deleteEvent(calendarId: calendarId, eventId: id)) {
        await _plans.updateSession(s.copyWith(clearCalendarEventId: true));
        removed++;
      }
    }
    return removed;
  }
}
