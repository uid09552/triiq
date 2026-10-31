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
}
