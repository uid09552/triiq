import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/today/today_header.dart';

void main() {
  final calls = <String>[];

  setUp(calls.clear);

  Widget header({
    bool loading = false,
    bool connected = true,
    int doneTss = 55,
    int plannedTss = 80,
    int seconds = 4800,
    int sessions = 2,
  }) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [TodayHeader(
          date: DateTime(2026, 11, 4),
          title: '2 activities logged today',
          subtitle: 'Morning run, Swim',
          loading: loading,
          onRefresh: () => calls.add('refresh'),
          onTrainNow: () => calls.add('train'),
          onFeel: () => calls.add('feel'),
          onCustomize: () => calls.add('customize'),
          onOpenIntervals: connected ? () => calls.add('intervals') : null,
          doneTss: doneTss,
          plannedTss: plannedTss,
          doneSeconds: seconds,
          sessions: sessions,
        )],
      ),
    ),
  );

  testWidgets('compact tile: date badge, status, stats strip and progress',
      (t) async {
    await t.pumpWidget(header());
    expect(find.text('4'), findsOneWidget);
    expect(find.text('NOV'), findsOneWidget);
    expect(find.text('WEDNESDAY'), findsOneWidget);
    expect(find.text('2 activities logged today'), findsOneWidget);
    expect(find.text('55 / 80 TSS'), findsOneWidget);
    expect(find.text('1:20 h'), findsOneWidget);
    expect(find.text('2 sessions'), findsOneWidget);
    final bar = t.widget<LinearProgressIndicator>(find.byKey(const ValueKey('hero-progress')));
    expect(bar.value, closeTo(0.6875, 0.001));
    // Much slimmer than the old 20-px-padded gradient block.
    expect(t.getSize(find.byKey(const ValueKey('today-header'))).height, lessThan(130));
  });

  testWidgets('nothing done or planned: no stats strip', (t) async {
    await t.pumpWidget(header(doneTss: 0, plannedTss: 0, seconds: 0, sessions: 0));
    expect(find.byKey(const ValueKey('hero-stats')), findsNothing);
    expect(find.byKey(const ValueKey('hero-progress')), findsNothing);
  });

  testWidgets('the refresh button stays and works; it shows a spinner while loading',
      (t) async {
    await t.pumpWidget(header());
    await t.tap(find.byKey(const ValueKey('hero-refresh')));
    expect(calls, ['refresh']);

    await t.pumpWidget(header(loading: true));
    expect(find.byKey(const ValueKey('hero-refresh')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('long-press and the more button open the quick actions',
      (t) async {
    await t.pumpWidget(header());
    await t.longPress(find.byKey(const ValueKey('today-header')));
    await t.pumpAndSettle();
    for (final k in ['sync', 'train', 'feel', 'intervals', 'customize']) {
      expect(find.byKey(ValueKey('hero-action-$k')), findsOneWidget, reason: k);
    }
    await t.tap(find.byKey(const ValueKey('hero-action-feel')));
    await t.pumpAndSettle();
    expect(calls, ['feel']);

    await t.tap(find.byKey(const ValueKey('hero-more')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('hero-action-train')));
    await t.pumpAndSettle();
    expect(calls, ['feel', 'train']);
  });

  testWidgets('not connected: no "open in Intervals.icu" action', (t) async {
    await t.pumpWidget(header(connected: false));
    await t.tap(find.byKey(const ValueKey('hero-more')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('hero-action-intervals')), findsNothing);
    expect(find.byKey(const ValueKey('hero-action-sync')), findsOneWidget);
  });
}
