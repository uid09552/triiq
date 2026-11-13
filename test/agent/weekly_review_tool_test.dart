import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/agent/system_prompt.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';

/// `get_weekly_review` answers "how was my week" with the same summary the
/// weekly-review notification is composed from.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late TrainingDataTools tools;
  final now = DateTime(2026, 11, 8, 20);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('triiq_weekly_tool');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    tools = TrainingDataTools(
      wellnessRepository: WellnessRepository(database: database),
      activitiesRepository: ActivitiesRepository(database: database),
      eventsRepository: EventsRepository(database: database),
      plansRepository: PlansRepository(database: database),
      syncStateRepository: SyncStateRepository(database: database),
      clock: () => now,
    );
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  Future<Map<String, dynamic>> call([
    Map<String, dynamic> args = const {},
  ]) async {
    final tool = tools.build().firstWhere((t) => t.name == 'get_weekly_review');
    final output = await tool.invoke(tool.getInputFromJson(args));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  test('reviews the current week from the cache', () async {
    await ActivitiesRepository(database: database).upsertAll([
      LocalActivity(
        id: 'a1',
        date: '2026-11-03',
        type: 'Run',
        name: 'Run',
        movingTime: 3600,
        distance: null,
        trainingLoad: 70,
        raw: const {},
        syncedAt: DateTime(2026, 11, 3),
      ),
    ]);
    await EventsRepository(database: database).upsert(
      LocalEvent(
        id: 'e1',
        date: '2026-11-03',
        category: 'WORKOUT',
        type: 'Run',
        name: 'Tempo',
        description: null,
        plannedLoad: 65,
        plannedTime: 3600,
        plannedDistance: null,
        indoor: false,
        raw: const {},
        syncedAt: DateTime(2026, 11, 1),
      ),
    );
    final r = await call();
    expect(r['week_start'], '2026-11-02');
    expect(r['load_tss'], 70);
    expect(r['planned_sessions'], 1);
    expect(r['completed_planned_sessions'], 1);
    expect(r['key_session']['name'], 'Tempo');
    expect(r['key_session']['done'], isTrue);
    expect(r.containsKey('note'), isFalse);
  });

  test('an empty week says so; a bad date is an error', () async {
    final empty = await call({'week_of': '2026-10-01'});
    expect(empty['note'], contains('Nothing done or planned'));
    final bad = await call({'week_of': 'last week'});
    expect(bad['error'], contains('YYYY-MM-DD'));
  });

  test('the system prompt points at get_weekly_review', () {
    expect(trainingAgentSystemPrompt, contains('`get_weekly_review`'));
  });
}
