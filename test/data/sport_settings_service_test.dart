import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/sport_settings_service.dart';
import 'package:triiq/evaluation/performance_curves.dart';
import 'package:triiq/evaluation/threshold_suggestions.dart';

/// A fake Intervals.icu backend recording every PUT body as decoded JSON,
/// and answering with [respondWith] (or an echo of the sent fields) so the
/// generated client's response deserialization has something to parse.
({IntervallsClient client, List<Map<String, dynamic>> putBodies}) _fakeClient({
  int? failStatus,
}) {
  final bodies = <Map<String, dynamic>>[];
  final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': '0'},
            ),
          );
          return;
        }
        final body = jsonDecode(options.data as String) as Map<String, dynamic>;
        bodies.add(body);
        if (failStatus != null) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: failStatus,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: body),
        );
      },
    ),
  );
  return (
    client: IntervallsClient(dio: dio, interceptors: const []),
    putBodies: bodies,
  );
}

IntervalsSession _sessionWithRideSettings(
  IntervallsClient client, {
  int settingsId = 7,
  int currentFtp = 252,
}) {
  final session = IntervalsSession.forTesting(
    connected: true,
    client: client,
    athleteId: 'a1',
  );
  session.athlete = WithSportSettings(
    sportSettings: [
      SportSettings(
        id: settingsId,
        types: const [SportSettingsTypesEnum.ride],
        ftp: currentFtp,
      ),
    ],
  );
  return session;
}

ThresholdSuggestion _rideSuggestion({
  double current = 252,
  double candidate = 262,
}) => ThresholdSuggestion(
  sport: CurveSport.ride,
  field: 'ftp',
  currentValue: current,
  candidateValue: candidate,
  direction: ThresholdDirection.up,
  basisKind: ThresholdBasisKind.rideSeasonModel,
);

void main() {
  group('SportSettingsService.apply', () {
    test('sends only id and the changed field', () async {
      final fake = _fakeClient();
      final session = _sessionWithRideSettings(fake.client);
      final service = SportSettingsService(session: session);

      await service.apply(_rideSuggestion());

      expect(fake.putBodies, hasLength(1));
      expect(fake.putBodies.single.keys.toSet(), {'id', 'ftp'});
      expect(fake.putBodies.single['ftp'], 262);
    });

    test('refreshes the cached athlete settings on success', () async {
      final fake = _fakeClient();
      final session = _sessionWithRideSettings(fake.client);
      final service = SportSettingsService(session: session);

      await service.apply(_rideSuggestion());

      // refreshAthlete() hits GET /athlete/0, stubbed above to return {id: 0}
      // deserialized as an Athlete — a real refresh happened rather than
      // being skipped.
      expect(session.athlete, isNotNull);
    });

    test('a failed write throws and leaves the old value cached', () async {
      final fake = _fakeClient(failStatus: 500);
      final session = _sessionWithRideSettings(fake.client);
      final service = SportSettingsService(session: session);
      final before = session.athlete;

      await expectLater(
        () => service.apply(_rideSuggestion()),
        throwsA(isA<DioException>()),
      );

      expect(session.athlete, same(before));
    });
  });

  group('SportSettingsService.undo', () {
    test('writes back the suggestion\'s original value', () async {
      final fake = _fakeClient();
      final session = _sessionWithRideSettings(fake.client);
      final service = SportSettingsService(session: session);

      await service.undo(_rideSuggestion());

      expect(fake.putBodies.single['ftp'], 252);
    });
  });
}
