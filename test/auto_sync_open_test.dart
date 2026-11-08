import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/repositories/sync_state_repository.dart';
import 'package:triiq/data/sync/auto_sync_service.dart';
import 'package:triiq/data/sync/sync_scope.dart';
import 'package:triiq/data/sync/sync_service.dart';

class _FakeSyncService extends SyncService {
  final scopes = <SyncScope>[];
  Object? failWith;

  @override
  Future<SyncResult> syncScope(SyncScope scope) async {
    scopes.add(scope);
    if (failWith != null) throw failWith!;
    return const SyncResult(
      wellnessCount: 0,
      activitiesCount: 0,
      eventsCount: 0,
    );
  }
}

class _NeverSynced extends SyncStateRepository {
  @override
  Future<({String oldest, String newest, DateTime lastSyncedAt})?> get(
    String scope,
  ) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeSyncService sync;
  late IntervalsSession session;
  late AutoSyncService service;

  setUp(() {
    sync = _FakeSyncService();
    session = IntervalsSession.forTesting(connected: true);
    service = AutoSyncService.forTesting(
      syncService: sync,
      session: session,
      syncStateRepository: _NeverSynced(),
    );
  });

  test('syncs today at once when already connected', () async {
    await service.syncToday();

    expect(sync.scopes, [SyncScope.today]);
  });

  test('resuming the app syncs today and then the stale month', () async {
    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(sync.scopes.first, SyncScope.today);
    expect(sync.scopes, contains(SyncScope.month));
  });

  test(
    'does nothing offline from the session, and survives a failure',
    () async {
      session.debugSetConnected(false);
      await service.syncToday();
      expect(sync.scopes, isEmpty);

      session.debugSetConnected(true);
      sync.failWith = StateError('no network');
      await service.syncToday();
      expect(sync.scopes, [SyncScope.today]);

      // The failure must not wedge later attempts.
      sync.failWith = null;
      await service.syncToday();
      expect(sync.scopes, [SyncScope.today, SyncScope.today]);
    },
  );

  test('a notification is sent so open screens reload', () async {
    var notified = 0;
    service.addListener(() => notified++);

    await service.syncToday();

    expect(notified, 1);
  });
}
