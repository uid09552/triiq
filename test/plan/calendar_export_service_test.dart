import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/plan/calendar_export_service.dart';
import 'package:triiq/plan/knowledge.dart';
import 'package:triiq/plan/plan_models.dart';

class _FakeGateway implements CalendarGateway {
  bool permission = true;
  int _next = 0;
  final events = <String, ({String title, String description, DateTime day})>{};
  final deleted = <String>[];

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<List<DeviceCalendarInfo>> writableCalendars() async => const [
    DeviceCalendarInfo(id: 'c1', name: 'Personal'),
  ];

  @override
  Future<String?> upsertAllDayEvent({
    required String calendarId,
    String? eventId,
    required String title,
    required String description,
    required DateTime day,
  }) async {
    final id = eventId ?? 'e${++_next}';
    events[id] = (title: title, description: description, day: day);
    return id;
  }

  @override
  Future<bool> deleteEvent({
    required String calendarId,
    required String eventId,
  }) async {
    deleted.add(eventId);
    return events.remove(eventId) != null || true;
  }
}

class _FakePlans implements PlansRepository {
  final saved = <PlanSession>[];

  @override
  Future<void> updateSession(PlanSession session) async => saved.add(session);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PlanSession _session({
  int? id = 1,
  DateTime? date,
  String? calendarEventId,
  String description = '**Warm-up** 10m',
}) => PlanSession(
  id: id,
  weekIndex: 0,
  date: date ?? DateTime(2026, 11, 3),
  slot: SessionSlot.z2,
  templateId: 't',
  name: 'Easy run',
  sport: 'Run',
  minutes: 45,
  load: 40,
  lowMinutes: 45,
  description: description,
  calendarEventId: calendarEventId,
);

void main() {
  test('creates events with plain-text descriptions and stores their ids',
      () async {
      final gateway = _FakeGateway();
      final plans = _FakePlans();
      final service = CalendarExportService(gateway: gateway, plans: plans);

      final report = await service.export([_session()], calendarId: 'c1');

      expect(report.created, 1);
      expect(gateway.events.values.single.description, isNot(contains('**')));
      expect(plans.saved.single.calendarEventId, 'e1');
  });

  test('re-export updates in place: no duplicate, date follows the session',
      () async {
    final gateway = _FakeGateway();
    final plans = _FakePlans();
    final service = CalendarExportService(gateway: gateway, plans: plans);

    await service.export([_session()], calendarId: 'c1');
    final moved = _session(
      date: DateTime(2026, 11, 5),
      calendarEventId: plans.saved.single.calendarEventId,
    );
    final report = await service.export([moved], calendarId: 'c1');

    expect(report.updated, 1);
    expect(report.created, 0);
    expect(gateway.events, hasLength(1));
    expect(gateway.events['e1']!.day, DateTime(2026, 11, 5));
  });

  test('permission denied writes nothing', () async {
    final gateway = _FakeGateway()..permission = false;
    final plans = _FakePlans();
    final report = await CalendarExportService(
      gateway: gateway,
      plans: plans,
    ).export([_session()], calendarId: 'c1');

    expect(report.permissionDenied, isTrue);
    expect(gateway.events, isEmpty);
    expect(plans.saved, isEmpty);
  });

  test('remove deletes the event and forgets its id', () async {
    final gateway = _FakeGateway();
    final plans = _FakePlans();
    final service = CalendarExportService(gateway: gateway, plans: plans);
    await service.export([_session()], calendarId: 'c1');

    final removed = await service.remove([
      _session(calendarEventId: 'e1'),
    ], calendarId: 'c1');

    expect(removed, 1);
    expect(gateway.deleted, ['e1']);
    expect(plans.saved.last.calendarEventId, isNull);
  });
}
