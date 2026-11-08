import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:triiq/agent/tools/training_data_tools.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/repositories/activities_repository.dart';
import 'package:triiq/data/repositories/events_repository.dart';
import 'package:triiq/data/repositories/plans_repository.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/threshold_suggestions_service.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';

class _FakeThresholdSuggestionsService extends ThresholdSuggestionsService {
  _FakeThresholdSuggestionsService(this.suggestions);

  final List<ThresholdSuggestion> suggestions;

  @override
  Future<List<ThresholdSuggestion>> load() async => suggestions;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase database;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('triiq_threshold_tool');
    database = AppDatabase.atPath(p.join(tempDir.path, 'triiq.db'));
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  TrainingDataTools tools(List<ThresholdSuggestion> suggestions) =>
      TrainingDataTools(
        wellnessRepository: WellnessRepository(database: database),
        activitiesRepository: ActivitiesRepository(database: database),
        eventsRepository: EventsRepository(database: database),
        plansRepository: PlansRepository(database: database),
        syncStateRepository: SyncStateRepository(database: database),
        thresholdSuggestions: _FakeThresholdSuggestionsService(suggestions),
      );

  Future<Map<String, dynamic>> call(TrainingDataTools t) async {
    final tool = t.build().firstWhere(
      (tool) => tool.name == 'get_threshold_suggestions',
    );
    final output = await tool.invoke(tool.getInputFromJson(const {}));
    return jsonDecode(output as String) as Map<String, dynamic>;
  }

  test('reports current suggestions with their figures', () async {
    final result = await call(
      tools([
        const ThresholdSuggestion(
          sport: CurveSport.ride,
          field: 'ftp',
          currentValue: 252,
          candidateValue: 262,
          direction: ThresholdDirection.up,
          basisKind: ThresholdBasisKind.rideSeasonModel,
        ),
      ]),
    );

    final suggestions = (result['suggestions'] as List)
        .cast<Map<String, dynamic>>();
    expect(suggestions, hasLength(1));
    expect(suggestions.single['sport'], 'Ride');
    expect(suggestions.single['current_value'], 252);
    expect(suggestions.single['candidate_value'], 262);
    expect(suggestions.single['direction'], 'up');
    expect(result['note'], contains('Insights'));
  });

  test('says nothing right now when there are no suggestions', () async {
    final result = await call(tools(const []));

    expect(result['suggestions'], isNull); // compacted away, empty list
    expect(result['note'], contains('No threshold suggestions'));
  });

  test('the tool list exposes no threshold write tool', () async {
    final names = tools(const []).build().map((t) => t.name);

    expect(names.where((n) => n.contains('threshold')), [
      'get_threshold_suggestions',
    ], reason: 'only the read tool should exist — no apply/write tool');
  });
}
