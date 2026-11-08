import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/best_efforts.dart';
import 'package:triiq/evaluation/performance_curves.dart';

EffortSession s(String date, List<double?> v, [String? id]) =>
    EffortSession(id ?? date, date, v);

void main() {
  final today = DateTime(2026, 11, 7);

  group('parsing', () {
    test('power: picks the wanted durations out of the response', () {
      final out = parsePowerEfforts(
        {
          'secs': [1, 5, 60, 300, 1200, 3600],
          'curves': [
            {
              'id': 'i1',
              'start_date_local': '2026-10-01T08:00:00',
              'watts': [900, 800, 450, 330, 280, 250],
            },
            {
              'id': 'i2',
              'start_date_local': 'bad',
              'watts': [1],
            },
            {
              'id': 'i3',
              'start_date_local': '2026-10-02T08:00:00',
              'watts': [0, 0, 0, 0, 0, 0],
            },
          ],
        },
        const [5, 60, 300, 1200],
      );
      expect(out, hasLength(2));
      expect(out.first.date, '2026-10-01');
      expect(out.first.values, [800, 450, 330, 280]);
      expect(out.last.values, [null, null, null, null]);
    });

    test('pace: times as they are, speeds turned into times', () {
      final times = parsePaceEfforts(
        {
          'distances': [1000, 5000, 10000, 21097],
          'curves': [
            {
              'id': 'a',
              'start_date_local': '2026-10-01T07:00',
              'times': [240, 1300, 2700, 6000],
            },
          ],
        },
        const [1000.0, 5000.0, 10000.0],
      );
      expect(times.single.values, [240, 1300, 2700]);

      final speeds = parsePaceEfforts(
        {
          'distances': [1000, 5000],
          'curves': [
            {
              'id': 'b',
              'start_date_local': '2026-10-02T07:00',
              'values': [4.0, 3.8],
            },
          ],
        },
        const [1000.0, 5000.0],
      );
      expect(speeds.single.values[0], closeTo(250, 1e-9));
      expect(speeds.single.values[1], closeTo(5000 / 3.8, 1e-9));
    });

    test('pace: finds the figures under an unexpected key', () {
      final out = parsePaceEfforts(
        {
          'distances': [1000, 5000],
          'curves': [
            {
              'id': 'c',
              'start_date_local': '2026-10-03T07:00',
              'whatever': [250, 1400],
            },
          ],
        },
        const [1000.0, 5000.0],
      );
      expect(out.single.values, [250, 1400]);
    });
  });

  group('progression', () {
    final sessions = [
      s('2026-11-02', [null, 500, null, null]), // last 30 days
      s('2026-10-20', [null, 520, null, null]), // last 30 days
      s('2026-09-15', [null, 540, null, null]), // the 90 days before
      s('2026-08-20', [null, 510, null, null]), // the 90 days before
      s('2025-12-01', [null, 560, null, null]), // old
    ];

    test('windows of 30 days, oldest first, with a rolling 90-day best', () {
      final w = progression(sessions, 1, today, lower: false);
      expect(w, hasLength(12));
      expect(w.last.end, DateTime(2026, 11, 7));
      expect(w.last.start, DateTime(2026, 10, 9));
      expect(w.last.best, 520);
      expect(w.last.rollingBest, 540); // 90 days back reaches 15 Sep
      expect(w[w.length - 2].best, 540); // 9 Sep..8 Oct holds 15 Sep
      expect(w[w.length - 3].best, 510); // 10 Aug..8 Sep holds 20 Aug
    });

    test('delta: last 30 days against the 90 days before them', () {
      final d = effortDeltas(sessions, 4, today, lower: false)[1];
      expect(d.current, 520);
      expect(d.baseline, 540);
      expect(d.improvement, closeTo(-0.037, 0.001));
      // A point with no data on either side.
      expect(
        effortDeltas(sessions, 4, today, lower: false)[0].improvement,
        isNull,
      );
    });

    test('pace: a lower time is the improvement', () {
      final runs = [
        s('2026-11-01', [240]),
        s('2026-08-30', [250]),
      ];
      final d = effortDeltas(runs, 1, today, lower: true).single;
      expect(d.current, 240);
      expect(d.baseline, 250);
      expect(d.improvement, closeTo(0.04, 1e-9));
      expect(lowerIsBetter(CurveSport.run), isTrue);
      expect(lowerIsBetter(CurveSport.ride), isFalse);
    });
  });

  group('repository', () {
    test(
      'caches, serves the cache while fresh, falls back when offline',
      () async {
        var calls = 0;
        var offline = false;
        var now = DateTime(2026, 11, 7, 8);
        final repo = BestEffortsRepository(
          clock: () => now,
          fetch: (sport, days) async {
            calls++;
            if (offline) throw StateError('offline');
            return [
              s('2026-11-01', [800, 450, 330, 280]),
            ];
          },
        );

        final first = await repo.load(CurveSport.ride, 111);
        expect(first.single.values, [800, 450, 330, 280]);
        await repo.load(CurveSport.ride, 111);
        expect(calls, 1); // still fresh

        now = now.add(const Duration(hours: 7));
        offline = true;
        final stale = await repo.load(CurveSport.ride, 111);
        expect(calls, 2); // asked again, failed
        expect(stale.single.date, '2026-11-01'); // last copy
      },
    );

    test('no cache and no network is an error, not an empty list', () async {
      final repo = BestEffortsRepository(
        fetch: (sport, days) async => throw StateError('offline'),
      );
      expect(() => repo.load(CurveSport.run, 222), throwsStateError);
    });
  });

  group('failure text', () {
    DioException failure(int? code, [Object? body]) {
      final req = RequestOptions(path: '/x');
      return DioException(
        requestOptions: req,
        message: 'boom',
        response: code == null
            ? null
            : Response<Object>(
                requestOptions: req,
                statusCode: code,
                data: body,
              ),
      );
    }

    test('status and the server\'s own words, on one line', () {
      expect(
        describeDioFailure(failure(403, {'status': 403, 'error': 'Forbidden'})),
        'Intervals.icu answered HTTP 403: Forbidden',
      );
      expect(
        describeDioFailure(failure(500)),
        'Intervals.icu answered HTTP 500',
      );
      expect(
        describeDioFailure(failure(404, 'nope')),
        'Intervals.icu answered HTTP 404: nope',
      );
    });

    test('no response: the transport message', () {
      expect(describeDioFailure(failure(null)), 'boom');
    });
  });
}
