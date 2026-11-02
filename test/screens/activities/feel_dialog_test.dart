import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:triiq/client/intervalls/intervalls_client.dart';
import 'package:triiq/data/db/app_database.dart';
import 'package:triiq/data/intervals_session.dart';
import 'package:triiq/data/repositories/wellness_repository.dart';
import 'package:triiq/data/wellness_actions.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/feel_dialog.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late List<RequestOptions> requests;
  late WellnessActions actions;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dir = await Directory.systemTemp.createTemp('triiq_feel_dialog');
    database = AppDatabase.atPath(p.join(dir.path, 'triiq.db'));

    requests = [];
    final dio = Dio(BaseOptions(baseUrl: 'https://intervals.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'id': '2026-11-03'},
            ),
          );
        },
      ),
    );
    actions = WellnessActions(
      session: IntervalsSession.forTesting(
        connected: true,
        client: IntervallsClient(dio: dio, interceptors: const []),
        athleteId: 'i42',
      ),
      wellness: WellnessRepository(database: database),
    );
  });

  tearDown(() async {
    await database.close();
    await dir.delete(recursive: true);
  });

  Future<void> realWait(WidgetTester tester, [int rounds = 8]) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump();
    }
  }

  Future<void> open(
    WidgetTester tester, {
    int? initialFatigue,
    int? initialSoreness,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showFeelDialog(
            context,
            date: '2026-11-03',
            initialFatigue: initialFatigue,
            initialSoreness: initialSoreness,
            actions: actions,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );

  testWidgets('prefilled values show when given', (tester) async {
    await open(tester, initialFatigue: 3, initialSoreness: 4);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final segmentedButtons = find.byType(SegmentedButton<int>);
    expect(
      tester.widget<SegmentedButton<int>>(segmentedButtons.at(0)).selected,
      {3},
    );
    expect(
      tester.widget<SegmentedButton<int>>(segmentedButtons.at(1)).selected,
      {4},
    );
  });

  testWidgets('Save calls setFeel with the selected values and closes',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Fatigue defaults to 1; pick 2. Soreness defaults to 1; pick 4.
    final segmentedButtons = find.byType(SegmentedButton<int>);
    await tester.tap(
      find.descendant(
        of: segmentedButtons.at(0),
        matching: find.text('2'),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: segmentedButtons.at(1),
        matching: find.text('4'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));
    await realWait(tester);
    await tester.pumpAndSettle();

    expect(requests, hasLength(1));
    final body = requests.single.data.toString();
    expect(body, contains('"fatigue":2'));
    expect(body, contains('"soreness":4'));
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Cancel closes without calling it', (tester) async {
    await open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(requests, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
