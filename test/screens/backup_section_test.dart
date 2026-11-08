import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/backup/backup_files.dart';
import 'package:triiq/data/backup/backup_service.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/settings/backup_settings_section.dart';

class _Service implements BackupService {
  Object? restored;
  bool exportedCaches = false;

  @override
  BackupSummary inspect(Object? json) => BackupSummary(
    createdAt: DateTime(2026, 5, 1),
    rows: const {'activities': 12, 'plans': 2},
    settings: 3,
    hasCaches: false,
  );

  @override
  Future<BackupSummary> restore(Object? json) async {
    restored = json;
    return inspect(json);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Files implements BackupFiles {
  _Files({this.picked});

  final Map<String, dynamic>? picked;
  bool? caches;

  @override
  Future<String?> export({bool includeCaches = false}) async {
    caches = includeCaches;
    return '/tmp/x.json';
  }

  @override
  Future<Map<String, dynamic>?> pick() async => picked;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget wrap(Widget w) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: w)),
);

void main() {
  testWidgets('export passes the caches switch and reports the path', (
    t,
  ) async {
    final files = _Files();
    await t.pumpWidget(
      wrap(BackupSettingsSection(files: files, service: _Service())),
    );
    await t.tap(find.byKey(const ValueKey('backup-caches')));
    await t.tap(find.byKey(const ValueKey('backup-export')));
    await t.pumpAndSettle();
    expect(files.caches, isTrue);
    expect(find.textContaining('/tmp/x.json'), findsOneWidget);
  });

  testWidgets('restore asks first, then restores', (t) async {
    final service = _Service();
    final json = {'format': 'triiq-backup'};
    await t.pumpWidget(
      wrap(
        BackupSettingsSection(
          files: _Files(picked: json),
          service: service,
        ),
      ),
    );
    await t.tap(find.byKey(const ValueKey('backup-restore')));
    await t.pumpAndSettle();
    expect(find.textContaining('12 activities'), findsOneWidget);
    expect(service.restored, isNull);
    await t.tap(find.byKey(const ValueKey('backup-restore-confirm')));
    await t.pumpAndSettle();
    expect(service.restored, json);
    expect(find.textContaining('Restart TriIQ'), findsOneWidget);
  });

  testWidgets('cancelling the picker does nothing', (t) async {
    final service = _Service();
    await t.pumpWidget(
      wrap(BackupSettingsSection(files: _Files(), service: service)),
    );
    await t.tap(find.byKey(const ValueKey('backup-restore')));
    await t.pumpAndSettle();
    expect(service.restored, isNull);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
