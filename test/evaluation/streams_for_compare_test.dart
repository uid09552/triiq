import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/evaluation/session_streams.dart';

void main() {
  test(
    'loadForCompare refetches streams cached without distance, once',
    () async {
      var fetches = 0;
      var withDistance = false;
      final repo = ActivityStreamsRepository(
        fetch: (id) async {
          fetches++;
          return SessionStreams(
            series: {
              'time': [0, 1, 2],
              'heartrate': [100, 110, 120],
              if (withDistance) 'distance': [0, 3, 6],
            },
          );
        },
      );

      // The diagram caches it first, without distance.
      await repo.load('cmp-1');
      expect(fetches, 1);

      withDistance = true;
      final s = await repo.loadForCompare('cmp-1');
      expect(fetches, 2);
      expect(s.series.containsKey('distance'), isTrue);

      // Now cached with distance: no further fetch.
      await repo.loadForCompare('cmp-1');
      expect(fetches, 2);

      // The extra stream is never offered as a curve in the diagram.
      expect(s.drawable, isNot(contains('distance')));
    },
  );

  test('an activity with no distance stream is not asked for again', () async {
    var fetches = 0;
    final repo = ActivityStreamsRepository(
      fetch: (id) async {
        fetches++;
        return const SessionStreams(
          series: {
            'time': [0, 1],
            'heartrate': [100, 110],
          },
        );
      },
    );
    await repo.loadForCompare('cmp-2');
    await repo.loadForCompare('cmp-2');
    expect(fetches, 1);
  });

  test('loadForCompare falls back to the cached copy when offline', () async {
    var offline = false;
    final repo = ActivityStreamsRepository(
      fetch: (id) async {
        if (offline) throw StateError('offline');
        return const SessionStreams(
          series: {
            'time': [0, 1],
            'heartrate': [100, 110],
          },
        );
      },
    );
    await repo.load('cmp-3');
    offline = true;
    final s = await repo.loadForCompare('cmp-3');
    expect(s.series['heartrate'], [100, 110]);
  });
}
