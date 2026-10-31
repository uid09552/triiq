import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/sync/background_sync.dart';
import 'package:triiq/data/sync/background_sync_runner.dart';
import 'package:triiq/data/sync/sync_settings.dart';

void main() {
  late SyncSettings settings;
  late int syncCalls;
  late List<bool> notifications;

  final now = DateTime(2026, 8, 26, 3);

  BackgroundSyncRunner runner({
    RestoreFailure connection = RestoreFailure.none,
    DateTime? lastSynced,
    Future<void> Function()? sync,
  }) {
    return BackgroundSyncRunner(
      ensureConnected: () async => connection,
      lastSyncedAt: () async => lastSynced,
      sync: sync ?? () async => syncCalls++,
      notify: ({required bool reconnectNeeded}) async =>
          notifications.add(reconnectNeeded),
      settings: settings,
      now: () => now,
    );
  }

  DioException httpError(int status) => DioException(
    requestOptions: RequestOptions(path: '/'),
    response: Response(
      requestOptions: RequestOptions(path: '/'),
      statusCode: status,
    ),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    settings = SyncSettings.forTesting();
    syncCalls = 0;
    notifications = [];
  });

  test('syncs and records success', () async {
    final outcome = await runner().run();

    expect(outcome, BackgroundSyncOutcome.success);
    expect(syncCalls, 1);
    expect(settings.backgroundLastResult, 'success');
    expect(settings.backgroundLastRunAt, isNotNull);
    expect(settings.backgroundFailures, 0);
  });

  test('makes no request when the cache is already fresh', () async {
    final outcome = await runner(
      lastSynced: now.subtract(const Duration(hours: 1)),
    ).run();

    expect(outcome, BackgroundSyncOutcome.skippedFresh);
    expect(syncCalls, 0);
  });

  test('syncs when the cache is older than the freshness window', () async {
    final outcome = await runner(
      lastSynced: now.subtract(const Duration(hours: 7)),
    ).run();

    expect(outcome, BackgroundSyncOutcome.success);
    expect(syncCalls, 1);
  });

  test('does nothing when switched off', () async {
    await settings.load();
    await settings.setBackgroundSyncEnabled(false);

    final outcome = await runner().run();

    expect(outcome, BackgroundSyncOutcome.disabled);
    expect(syncCalls, 0);
  });

  test('does nothing, and does not count a failure, without a stored key', () async {
    final outcome = await runner(connection: RestoreFailure.noKey).run();

    expect(outcome, BackgroundSyncOutcome.notConnected);
    expect(syncCalls, 0);
    expect(settings.backgroundFailures, 0);
  });

  test('a network error is recorded as a failure without notifying', () async {
    final outcome = await runner(
      sync: () async => throw httpError(503),
    ).run();

    expect(outcome, BackgroundSyncOutcome.failed);
    expect(settings.backgroundFailures, 1);
    expect(notifications, isEmpty);
  });

  test('notifies once after three failures in a row, then stays quiet', () async {
    Future<void> fail() => runner(sync: () async => throw httpError(500)).run();

    await fail();
    await fail();
    expect(notifications, isEmpty);
    await fail();
    expect(notifications, [false]);
    await fail();
    await fail();
    expect(notifications, [false]);
    expect(settings.backgroundFailures, 5);
  });

  test('a success resets the failure streak', () async {
    Future<void> fail() => runner(sync: () async => throw httpError(500)).run();

    await fail();
    await fail();
    await runner().run();
    expect(settings.backgroundFailures, 0);
    await fail();
    await fail();
    expect(notifications, isEmpty);
  });

  test('a rejected key notifies once and does not loop', () async {
    final first = await runner(connection: RestoreFailure.rejected).run();
    final second = await runner(connection: RestoreFailure.rejected).run();

    expect(first, BackgroundSyncOutcome.authRejected);
    expect(second, BackgroundSyncOutcome.authRejected);
    expect(notifications, [true]);
    expect(syncCalls, 0);
  });

  test('a 401 during the fetch counts as a rejected key', () async {
    final outcome = await runner(
      sync: () async => throw httpError(401),
    ).run();

    expect(outcome, BackgroundSyncOutcome.authRejected);
    expect(notifications, [true]);
  });

  test('offline at restore is a retryable failure, not a rejected key', () async {
    final outcome = await runner(connection: RestoreFailure.network).run();

    expect(outcome, BackgroundSyncOutcome.failed);
    expect(notifications, isEmpty);
  });

  group('initialDelayFor', () {
    test('before the window end waits until 05:00 today', () {
      expect(
        BackgroundSync.initialDelayFor(DateTime(2026, 8, 26, 3)),
        const Duration(hours: 2),
      );
    });

    test('after the window end waits until 05:00 tomorrow', () {
      expect(
        BackgroundSync.initialDelayFor(DateTime(2026, 8, 26, 14)),
        const Duration(hours: 15),
      );
    });

    test('exactly at the window end waits a full day', () {
      expect(
        BackgroundSync.initialDelayFor(DateTime(2026, 8, 26, 5)),
        const Duration(hours: 24),
      );
    });
  });
}
