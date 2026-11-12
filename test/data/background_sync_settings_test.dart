import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/sync/sync_settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults keep the nightly background sync on', () async {
    final settings = SyncSettings.forTesting();
    await settings.load();

    expect(settings.backgroundSyncEnabled, isTrue);
    expect(settings.backgroundSyncInterval, BackgroundSyncInterval.nightly);
  });

  test('the chosen interval persists across a reload', () async {
    final settings = SyncSettings.forTesting();
    await settings.load();
    await settings.setBackgroundSyncInterval(BackgroundSyncInterval.hourly);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sync.background_interval'), 'hourly');

    final reloaded = SyncSettings.forTesting();
    await reloaded.load();
    expect(reloaded.backgroundSyncInterval, BackgroundSyncInterval.hourly);
  });

  test('an unknown stored interval falls back to nightly', () async {
    SharedPreferences.setMockInitialValues({
      'sync.background_interval': 'every5Seconds',
    });
    final settings = SyncSettings.forTesting();
    await settings.load();

    expect(settings.backgroundSyncInterval, BackgroundSyncInterval.nightly);
  });

  test('setting the same interval again does not notify', () async {
    final settings = SyncSettings.forTesting();
    await settings.load();
    var notified = 0;
    settings.addListener(() => notified++);

    await settings.setBackgroundSyncInterval(BackgroundSyncInterval.nightly);
    expect(notified, 0);
    await settings.setBackgroundSyncInterval(BackgroundSyncInterval.minutes15);
    expect(notified, 1);
  });

  test('intervals respect the WorkManager minimum and stay below their '
      'own period when deciding freshness', () {
    for (final interval in BackgroundSyncInterval.values) {
      expect(
        interval.frequency,
        greaterThanOrEqualTo(const Duration(minutes: 15)),
      );
      expect(interval.freshFor, lessThan(interval.frequency));
    }
    expect(
      BackgroundSyncInterval.nightly.freshFor,
      const Duration(hours: 6),
    );
  });
}
