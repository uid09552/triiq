import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/onboarding/setup_checks.dart';

LocalActivity act(Map<String, dynamic> raw) => LocalActivity(
  id: '1',
  date: '2026-11-01',
  type: 'Ride',
  name: 'x',
  movingTime: null,
  distance: null,
  trainingLoad: null,
  raw: raw,
  syncedAt: DateTime(2026),
);

void main() {
  test('counts only Strava-sourced activities', () {
    expect(
      stravaSourcedCount([
        act({'source': 'STRAVA'}),
        act({'source': 'GARMIN_CONNECT'}),
        act({}),
      ]),
      1,
    );
  });

  test('a sport lacks its threshold: FTP for rides, pace for run and swim', () {
    final missing = sportsMissingThreshold(
      ['Ride', 'Run', 'Swim'],
      (s) => switch (s) {
        'Ride' => (ftp: 250, thresholdPace: null),
        'Run' => (ftp: null, thresholdPace: null),
        _ => null,
      },
    );
    expect(missing, ['Run', 'Swim']);
  });

  test('nothing to report when all is set', () {
    expect(const SetupFindings().isEmpty, isTrue);
  });
}
