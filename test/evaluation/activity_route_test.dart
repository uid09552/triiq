import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/activity_route.dart';
import 'package:triiq/evaluation/session_streams.dart';
import 'package:triiq/screens/activities/session_analysis.dart';
import 'package:triiq/l10n/app_localizations.dart';
import 'package:triiq/screens/activities/route_card.dart';

LocalActivity act(String type, {Map<String, dynamic> raw = const {}}) => LocalActivity(
  id: 'a1', date: '2026-11-04', type: type, name: 'Morning $type',
  movingTime: 3600, distance: 10000, trainingLoad: 50, raw: raw,
  syncedAt: DateTime(2026),
);

ActivityRoute track(int n) => ActivityRoute([
  for (var i = 0; i < n; i++) RoutePoint(48.0 + i * 0.001, 11.0 + i * 0.001),
]);

class _Repo implements ActivityRouteRepository {
  _Repo(this.result, {this.fail = false});

  final ActivityRoute result;
  final bool fail;
  int loads = 0;

  @override
  Future<ActivityRoute> load(String activityId) async {
    loads++;
    if (fail) throw StateError('offline');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  group('ActivityRoute.fromSamples', () {
    test('drops gaps, no-fix zeros and impossible values', () {
      final r = ActivityRoute.fromSamples(
        [48.0, null, 0, 48.2, 95, 48.3],
        [11.0, 11.1, 0, 11.2, 11.3, 11.4],
      );
      expect(r.points.map((p) => p.lat), [48.0, 48.2, 48.3]);
      expect(r.isEmpty, isFalse);
    });

    test('thins a long track but keeps the first and last fix', () {
      final lat = [for (var i = 0; i < 20000; i++) 48.0 + i * 1e-5];
      final lng = [for (var i = 0; i < 20000; i++) 11.0 + i * 1e-5];
      final r = ActivityRoute.fromSamples(lat, lng);
      expect(r.points.length, ActivityRoute.maxPoints);
      expect(r.points.first.lat, 48.0);
      expect(r.points.last.lat, closeTo(48.0 + 19999 * 1e-5, 1e-9));
    });

    test('times follow the points through filtering and thinning', () {
      final r = ActivityRoute.fromSamples(
        [48.0, null, 48.2, 48.3],
        [11.0, 11.1, 11.2, 11.3],
        time: [0, 1, 2, 3],
      );
      expect(r.times, [0, 2, 3]);
      final lat = [for (var i = 0; i < 20000; i++) 48.0 + i * 1e-5];
      final lng = [for (var i = 0; i < 20000; i++) 11.0 + i * 1e-5];
      final big = ActivityRoute.fromSamples(lat, lng, time: [for (var i = 0; i < 20000; i++) i]);
      expect(big.times.length, big.points.length);
      expect(big.times.first, 0);
      expect(big.times.last, 19999);
    });

    test('pointAt finds the nearest fix; null without times', () {
      final r = ActivityRoute(
        [RoutePoint(1, 1), RoutePoint(2, 2), RoutePoint(3, 3)],
        times: const [0, 10, 30],
      );
      expect(r.pointAt(-5)!.lat, 1);
      expect(r.pointAt(4)!.lat, 1);
      expect(r.pointAt(6)!.lat, 2);
      expect(r.pointAt(19)!.lat, 2);
      expect(r.pointAt(21)!.lat, 3);
      expect(r.pointAt(999)!.lat, 3);
      expect(ActivityRoute([RoutePoint(1, 1), RoutePoint(2, 2)]).pointAt(5), isNull);
    });

    test('one fix or none is an empty route; JSON round-trips', () {
      expect(ActivityRoute.fromSamples([48.0], [11.0]).isEmpty, isTrue);
      expect(ActivityRoute.fromSamples(const [], const []).isEmpty, isTrue);
      final back = ActivityRoute.fromJson(track(5).toJson());
      expect(back.points.length, 5);
      expect(back.points.last.lng, closeTo(11.004, 1e-9));
      // Times survive the round trip; a track stored without them says so.
      final timed = ActivityRoute.fromJson(
        ActivityRoute(track(3).points, times: const [0, 5, 9]).toJson(),
      );
      expect(timed.times, [0, 5, 9]);
      expect(timed.timesKnown, isTrue);
      expect(
        ActivityRoute.fromJson({'lat': [1.0, 2.0], 'lng': [1.0, 2.0]}).timesKnown,
        isFalse,
      );
    });
  });

  group('hasRouteMap', () {
    test('outdoor run and ride only', () {
      expect(hasRouteMap(act('Run')), isTrue);
      expect(hasRouteMap(act('Ride')), isTrue);
      expect(hasRouteMap(act('GravelRide')), isTrue);
      expect(hasRouteMap(act('TrailRun')), isTrue);
      expect(hasRouteMap(act('VirtualRide')), isFalse);
      expect(hasRouteMap(act('Ride', raw: {'trainer': true})), isFalse);
      expect(hasRouteMap(act('Swim')), isFalse);
      expect(hasRouteMap(act('WeightTraining')), isFalse);
    });
  });

  group('map cursor', () {
    testWidgets('marks where the activity was at the diagram cursor', (t) async {
      final cursor = ValueNotifier<double?>(null);
      final route = ActivityRoute(
        track(10).points,
        times: [for (var i = 0; i < 10; i++) i * 60.0],
      );
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300, height: 300,
            child: RouteMap(route: route, showTiles: false, cursor: cursor),
          ),
        ),
      ));
      expect(find.byKey(const ValueKey('route-cursor')), findsNothing);
      cursor.value = 250;
      await t.pump();
      expect(find.byKey(const ValueKey('route-cursor')), findsOneWidget);
      cursor.value = null;
      await t.pump();
      expect(find.byKey(const ValueKey('route-cursor')), findsNothing);
    });

    testWidgets('a track without times shows no cursor', (t) async {
      final cursor = ValueNotifier<double?>(120);
      await t.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300, height: 300,
            child: RouteMap(route: track(10), showTiles: false, cursor: cursor),
          ),
        ),
      ));
      expect(find.byKey(const ValueKey('route-cursor')), findsNothing);
    });
  });

  testWidgets('hovering the session diagram moves the marker on the map',
      (t) async {
    t.view.physicalSize = const Size(900, 2600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final cursor = ValueNotifier<double?>(null);
    final streams = ActivityStreamsRepository(
      fetch: (_) async => SessionStreams(
        series: {
          'time': [for (var i = 0; i < 600; i++) i.toDouble()],
          'watts': [for (var i = 0; i < 600; i++) 150 + (i % 50).toDouble()],
        },
        intervals: const [],
      ),
    );
    final run = act('Run');
    await t.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            SessionDiagramCard(
              activity: run,
              streams: streams,
              onCursorSeconds: (s) => cursor.value = s,
            ),
            ActivityRouteCard(
              activity: run,
              routes: _Repo(ActivityRoute(
                track(30).points,
                times: [for (var i = 0; i < 30; i++) i * 20.0],
              )),
              showTiles: false,
              cursor: cursor,
            ),
          ]),
        ),
      ),
    ));
    // The streams come through SQLite, which needs real time.
    for (var i = 0; i < 60; i++) {
      if (find.byKey(const ValueKey('stream-chart-paint')).evaluate().isNotEmpty) {
        break;
      }
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await t.pump();
    }
    await t.pump();
    expect(find.byKey(const ValueKey('route-cursor')), findsNothing);

    final box = t.getRect(find.byKey(const ValueKey('stream-chart-paint')));
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset(box.left + 5, box.center.dy));
    await t.pump();
    await mouse.moveTo(Offset(box.left + box.width / 2, box.center.dy));
    await t.pump();
    expect(find.byKey(const ValueKey('route-cursor')), findsOneWidget);
    expect(cursor.value, closeTo(300, 80));
  });

  group('ActivityRouteCard', () {
    Widget wrap(Widget w) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: SingleChildScrollView(child: w)),
    );

    testWidgets('a run with a track shows the map; tapping opens it full screen',
        (t) async {
      final repo = _Repo(track(30));
      await t.pumpWidget(wrap(ActivityRouteCard(
        activity: act('Run'), routes: repo, showTiles: false,
      )));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-card')), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(PolylineLayer), findsOneWidget);

      await t.tap(find.byKey(const ValueKey('route-open')));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-full')), findsOneWidget);
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('no map for a swim or a trainer ride, and nothing is fetched',
        (t) async {
      final repo = _Repo(track(30));
      await t.pumpWidget(wrap(Column(children: [
        ActivityRouteCard(activity: act('Swim'), routes: repo, showTiles: false),
        ActivityRouteCard(activity: act('VirtualRide'), routes: repo, showTiles: false),
      ])));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-card')), findsNothing);
      expect(repo.loads, 0);
    });

    testWidgets('an activity without GPS, or a failed fetch, draws nothing',
        (t) async {
      await t.pumpWidget(wrap(ActivityRouteCard(
        activity: act('Run'), routes: _Repo(const ActivityRoute([])), showTiles: false,
      )));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-card')), findsNothing);

      await t.pumpWidget(wrap(ActivityRouteCard(
        key: const ValueKey('second'),
        activity: act('Run'), routes: _Repo(track(10), fail: true), showTiles: false,
      )));
      await t.pumpAndSettle();
      expect(find.byKey(const ValueKey('route-card')), findsNothing);
      expect(t.takeException(), isNull);
    });
  });
}
