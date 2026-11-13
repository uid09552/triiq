import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/evaluation/readiness_settings.dart';
import 'package:path/path.dart' as p;
import 'package:triiq/agent/system_prompt.dart';
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/models/local_wellness.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/evaluation/readiness.dart';
import 'package:triiq/util/dates.dart';

/// `get_readiness` must say what the Today tile says: same records, same
/// rules, same result.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;
  late WellnessRepository wellness;
  late TrainingDataTools tools;
  final now = DateTime(2026, 11, 1, 7);

  LocalWellness day(int daysAgo, {num? hrv, num? rhr, num? sleep}) {
    final date = isoDate(DateTime(now.year, now.month, now.day - daysAgo));
    return LocalWellness(
      date: date,
      ctl: 60,
      atl: 62,
      ctlLoad: null,
      atlLoad: null,
      rampRate: null,
      raw: {'id': date, 'hrv': ?hrv, 'restingHR': ?rhr, 'sleepSecs': ?sleep},
      syncedAt: DateTime(2026),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('triiq_readiness_tool');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
    wellness = WellnessRepository(database: database);
    tools = TrainingDataTools(
      wellnessRepository: wellness,
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

  Future<Map<String, dynamic>> call() async {
    final tool = tools.build().firstWhere((t) => t.name == 'get_readiness');
    final output = await tool.invoke(tool.getInputFromJson(const {}));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  test('matches evaluateReadiness for the same records', () async {
    // HRV low for three days (it is rated by its 3-day median), today's own
    // reading a little lower still.
    final records = [
      for (var i = 3; i <= 42; i++)
        day(i, hrv: 62 + (i.isEven ? 4 : -4), rhr: 48, sleep: 8 * 3600),
      day(2, hrv: 52, rhr: 48, sleep: 8 * 3600),
      day(1, hrv: 52, rhr: 48, sleep: 8 * 3600),
      day(0, hrv: 50, rhr: 48, sleep: 8 * 3600),
    ];
    await wellness.upsertAll(records);

    final result = await call();
    final expected = evaluateReadiness(records, now);

    expect(expected.level, ReadinessLevel.caution);
    expect(result['status'], 'caution');
    expect(result['reasons'], ['hrv']);
    expect(result['data_state'], 'complete');
    final hrv = (result['signals'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((s) => s['signal'] == 'hrv');
    expect(hrv['rating'], 'caution');
    expect(hrv['value'], 52);
    expect(hrv['value_today_raw'], 50);
    expect(hrv['smoothing_days'], 3);
    expect(hrv['baseline_mean'], 62);
    expect(hrv['baseline_days'], 40);
    expect(hrv['baseline_days_needed'], 21);
  });

  test('only the signals the athlete left on are reported', () async {
    SharedPreferences.setMockInitialValues({});
    await wellness.upsertAll([
      for (var i = 1; i <= 40; i++)
        day(i, hrv: 62 + (i.isEven ? 6 : -6), rhr: 48, sleep: 8 * 3600),
      day(0, hrv: 52, rhr: 48, sleep: 8 * 3600),
    ]);
    await ReadinessSettings.instance.setEnabled(ReadinessSignalKind.hrv, false);
    addTearDown(ReadinessSettings.instance.reset);

    final result = await call();

    expect(result['status'], 'ready');
    expect(result['reasons'], anyOf(isNull, isEmpty));
    expect(result['signals_switched_off'], ['hrv']);
    expect(result['signals_used'], isNot(contains('hrv')));
    final shown = [
      for (final s in (result['signals'] as List).cast<Map<String, dynamic>>())
        s['signal'],
    ];
    expect(shown, isNot(contains('hrv')));
    expect(result['note'], contains('signals_used'));
  });

  test('reports the missing-data state', () async {
    await wellness.upsertAll([day(0)]);

    final result = await call();

    expect(result['data_state'], 'no_data');
    expect(result['status'], 'ready');
  });

  test('the system prompt points at get_readiness', () {
    expect(trainingAgentSystemPrompt, contains('get_readiness'));
  });
}
