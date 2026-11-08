import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/intervals_workout_service.dart';

void main() {
  test('moving a workout sends only its new date', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': 501, 'start_date_local': '2026-11-08T00:00:00'},
            ),
          );
        },
      ),
    );
    final service = IntervalsWorkoutService(
      session: IntervalsSession.forTesting(
        connected: true,
        client: IntervallsClient(dio: dio, interceptors: const []),
        athleteId: 'i42',
      ),
    );

    await service.updatePlannedWorkoutDate('501', DateTime(2026, 11, 8, 15));

    final request = requests.single;
    expect(request.method, 'PUT');
    expect(request.path, '/api/v1/athlete/i42/events/501');
    final body = request.data is String
        ? request.data as String
        : request.data.toString();
    expect(body, contains('"start_date_local":"2026-11-08T00:00:00"'));
    // Nothing else: the steps, name and load stay as they are upstream.
    expect(body, isNot(contains('description')));
    expect(body, isNot(contains('name')));
    expect(body, isNot(contains('icu_training_load')));
  });

  test('a non-numeric id is refused before any request', () async {
    final service = IntervalsWorkoutService(
      session: IntervalsSession.forTesting(connected: true, athleteId: 'i42'),
    );

    expect(
      () => service.updatePlannedWorkoutDate('plan:3', DateTime(2026, 11, 8)),
      throwsStateError,
    );
  });

  Future<String> sentDescription(PlannedWorkoutDraft draft) async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': 601, 'start_date_local': '2026-11-08T00:00:00'},
            ),
          );
        },
      ),
    );
    final service = IntervalsWorkoutService(
      session: IntervalsSession.forTesting(
        connected: true,
        client: IntervallsClient(dio: dio, interceptors: const []),
        athleteId: 'i42',
      ),
    );
    await service.createPlannedWorkout(draft);
    final data = requests.single.data;
    return data is String ? data : data.toString();
  }

  test(
    'a swim written in metres is sent as mtr, not as hundreds of minutes',
    () async {
      final body = await sentDescription(
        PlannedWorkoutDraft(
          name: 'Swim',
          sport: 'Swim',
          date: DateTime(2026, 11, 8),
          durationSeconds: 30 * 60,
          description:
              '- 300m Warm up\n4x\n  - 50m drill\n  - 50m easy\n- 200m Cool down',
        ),
      );
      expect(body, contains('300mtr'));
      expect(body, contains('200mtr'));
      expect(body, isNot(contains('300m ')));
    },
  );

  test('a minute-based swim and a ride are sent unchanged', () async {
    final swim = await sentDescription(
      PlannedWorkoutDraft(
        name: 'Swim',
        sport: 'Swim',
        date: DateTime(2026, 11, 8),
        durationSeconds: 31 * 60,
        description: '- 10m 75%\n4x\n  - 3m 98%\n  - 1m 70%\n- 5m 72%',
      ),
    );
    expect(swim, contains('- 10m 75%'));
    expect(swim, isNot(contains('mtr')));
    final ride = await sentDescription(
      PlannedWorkoutDraft(
        name: 'Ride',
        sport: 'Ride',
        date: DateTime(2026, 11, 8),
        durationSeconds: 60 * 60,
        description: '- 300m 60%',
      ),
    );
    expect(ride, contains('300m 60%'));
  });
}
