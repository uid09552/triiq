import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_event.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/season/health_actions.dart';
import 'package:triiq/season/illness_mode.dart';
import 'package:triiq/season/life_modes.dart';
import 'package:triiq/screens/season/life_mode_sheet.dart';

LocalEvent ev(String id, String date, {int mins = 60, int load = 60}) =>
    LocalEvent(
      id: id,
      date: date,
      category: 'WORKOUT',
      type: 'Run',
      name: 'Run $id',
      description: null,
      plannedLoad: load,
      plannedTime: mins * 60,
      plannedDistance: null,
      indoor: false,
      raw: const {},
      syncedAt: DateTime(2026),
    );

class _Recording extends HealthActions {
  final applied = <String>[];

  @override
  Future<({int done, Object? error})> applyAll(
    Iterable<ReturnChange> changes,
  ) async {
    applied.addAll(changes.map((c) => '${c.session.id}:${c.action.name}'));
    return (done: changes.length, error: null);
  }
}

void main() {
  final planned = [
    ev('a', '2026-11-03', mins: 90),
    ev('b', '2026-11-05', mins: 40),
    ev('c', '2026-11-09', mins: 120), // after the window
  ];

  List<ReturnChange> run(LifeMode m, ModeIntensity i) => lifeModeChanges(
    mode: m,
    intensity: i,
    start: DateTime(2026, 11, 2),
    end: DateTime(2026, 11, 6),
    planned: planned,
  );

  test('only sessions inside the window change; later ones never', () {
    for (final mode in LifeMode.values) {
      for (final i in ModeIntensity.values) {
        expect(run(mode, i).map((c) => c.session.id), isNot(contains('c')));
      }
    }
  });

  test('rest drops, easy halves when unwell, short caps at 45 min', () {
    expect(run(LifeMode.unwell, ModeIntensity.rest).map((c) => c.action), [
      ReturnAction.rest,
      ReturnAction.rest,
    ]);
    expect(run(LifeMode.unwell, ModeIntensity.easy).first.minutes, 45);
    expect(run(LifeMode.travel, ModeIntensity.easy).first.minutes, 63);
    final short = run(LifeMode.timeCrunched, ModeIntensity.shorter);
    expect(short.single.session.id, 'a'); // 40 min already fits
    expect(short.single.minutes, 45);
    expect(short.single.load, 30);
  });

  testWidgets('the sheet shows before → after and applies all at once', (
    t,
  ) async {
    final actions = _Recording();
    t.view.physicalSize = const Size(800, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: LifeModeSheet(
            today: DateTime(2026, 11, 2),
            planned: (a, b) async => planned,
            actions: actions,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('90 min → rest'), findsOneWidget);
    expect(find.byKey(const ValueKey('mode-change-c')), findsNothing);
    await t.tap(find.byKey(const ValueKey('mode-apply')));
    await t.pumpAndSettle();
    expect(actions.applied, ['a:rest', 'b:rest']);
  });
}
