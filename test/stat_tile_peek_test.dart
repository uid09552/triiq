import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/stat_tile_peek.dart';

class _Streams extends ActivityStreamsRepository {
  _Streams(this.data);
  final SessionStreams? data;

  @override
  Future<SessionStreams?> cached(String activityId) async => data;

  @override
  Future<SessionStreams> load(String activityId) async =>
      data ?? (throw StateError('offline'));
}

void main() {
  group('streamHistogram', () {
    test('time-weighted bins, min / avg / max, peak', () {
      // 60 s at 130, 30 s at 151, 10 s at 172 (1 Hz).
      final hr = [
        for (var i = 0; i < 60; i++) 130.0,
        for (var i = 0; i < 30; i++) 151.0,
        for (var i = 0; i < 10; i++) 172.0,
      ];
      final time = [for (var i = 0; i <= hr.length; i++) i.toDouble()];
      final h = streamHistogram(hr, time: time, binWidth: 5, floor: 0)!;
      expect(h.binStart, 130);
      expect(h.seconds.length, 9); // 130 … 175
      expect(h.seconds[0], 60);
      expect(h.seconds[4], 30); // 150–155
      expect(h.seconds[8], 10); // 170–175
      expect(h.totalSeconds, 100);
      expect(h.min, 130);
      expect(h.max, 172);
      expect(h.avg, closeTo((60 * 130 + 30 * 151 + 10 * 172) / 100, 1e-9));
      expect(h.peak, 0);
    });

    test('pauses are capped, zeros and nulls left out', () {
      final values = [140.0, null, 0.0, 140.0, 150.0];
      final time = [0.0, 1.0, 2.0, 3.0, 600.0, 601.0];
      final h = streamHistogram(values, time: time, binWidth: 5, floor: 0)!;
      // 140 for 1 s, 140 for 10 s (the 597 s pause capped), 150 for 1 s.
      expect(h.seconds.first, 11);
      expect(h.seconds.last, 1);
      expect(h.totalSeconds, 12);
    });

    test('nothing usable gives null', () {
      expect(streamHistogram([null, 0], binWidth: 5, floor: 0), isNull);
      expect(streamHistogram(const [], binWidth: 5), isNull);
    });
  });

  Future<void> pumpPeek(
    WidgetTester tester,
    SessionStreams? data, {
    StatStream stream = StatStream.heartrate,
    bool pace = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: StatTilePeek(
              title: 'Heart rate',
              activityId: 'i1',
              stream: stream,
              streams: _Streams(data),
              color: Colors.red,
              pace: pace,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('heart rate: figures, histogram and the most common range', (
    tester,
  ) async {
    await pumpPeek(
      tester,
      SessionStreams(
        series: {
          'time': [for (var i = 0; i < 100; i++) i.toDouble()],
          'heartrate': [
            for (var i = 0; i < 70; i++) 142.0,
            for (var i = 0; i < 30; i++) 165.0,
          ],
        },
      ),
    );
    expect(find.byKey(const ValueKey('stat-peek-histogram')), findsOneWidget);
    expect(find.textContaining('142 bpm'), findsWidgets);
    expect(find.textContaining('165 bpm'), findsWidgets);
    expect(find.text('Most time at 140 bpm – 145 bpm (70%)'), findsOneWidget);
  });

  testWidgets('pace for a run reads fastest first', (tester) async {
    await pumpPeek(
      tester,
      SessionStreams(
        series: {
          'time': [for (var i = 0; i < 60; i++) i.toDouble()],
          // 5:00 /km = 3.333 m/s.
          'velocity_smooth': [for (var i = 0; i < 60; i++) 1000 / 300],
        },
      ),
      stream: StatStream.speed,
      pace: true,
    );
    expect(find.textContaining('5:00 /km'), findsWidgets);
  });

  testWidgets('no stream: says so instead of an empty chart', (tester) async {
    await pumpPeek(tester, const SessionStreams(series: {}));
    expect(find.byKey(const ValueKey('stat-peek-empty')), findsOneWidget);
    await pumpPeek(tester, null);
    expect(find.byKey(const ValueKey('stat-peek-empty')), findsOneWidget);
  });
}
