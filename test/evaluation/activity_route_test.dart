import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/data/models/local_activity.dart';
import 'package:triiq/evaluation/activity_route.dart';
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

    test('one fix or none is an empty route; JSON round-trips', () {
      expect(ActivityRoute.fromSamples([48.0], [11.0]).isEmpty, isTrue);
      expect(ActivityRoute.fromSamples(const [], const []).isEmpty, isTrue);
      final back = ActivityRoute.fromJson(track(5).toJson());
      expect(back.points.length, 5);
      expect(back.points.last.lng, closeTo(11.004, 1e-9));
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
