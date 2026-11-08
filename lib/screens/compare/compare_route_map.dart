import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../evaluation/activity_route.dart';
import '../../widgets/osm_layers.dart';

/// Colours that tell the two compared activities apart, in light and dark,
/// for the lines, the map and the tracker alike.
const compareColorA = Color(0xFF1E88E5);
const compareColorB = Color(0xFFF57C00);

/// Two courses on one map — A in blue, B in orange — each with a tracker dot
/// at the position the chart's cursor points to, so the athlete sees where
/// both were at the same distance or time. Tapping the map reports the
/// coordinates, which the compare screen turns back into a chart position.
///
/// [markerA] / [markerB] resolve the shared cursor value to a point on the
/// respective route; return null to show no marker for that activity.
class CompareRouteMap extends StatelessWidget {
  const CompareRouteMap({
    super.key,
    required this.routeA,
    required this.routeB,
    required this.cursor,
    required this.markerA,
    required this.markerB,
    this.onTap,
    this.interactive = false,
    this.showTiles = true,
    this.padding = 28,
  });

  final ActivityRoute? routeA;
  final ActivityRoute? routeB;

  /// The shared x position (distance in metres or elapsed seconds).
  final ValueListenable<double?> cursor;
  final RoutePoint? Function(double x) markerA;
  final RoutePoint? Function(double x) markerB;
  final void Function(double lat, double lng)? onTap;
  final bool interactive;
  final bool showTiles;
  final double padding;

  static List<LatLng> _line(ActivityRoute? r) => r == null || r.isEmpty
      ? const []
      : [for (final p in r.points) LatLng(p.lat, p.lng)];

  @override
  Widget build(BuildContext context) {
    final a = _line(routeA);
    final b = _line(routeB);
    final all = [...a, ...b];
    if (all.isEmpty) return const SizedBox.shrink();
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: all,
          padding: EdgeInsets.all(padding),
        ),
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
        onTap: onTap == null
            ? null
            : (_, point) => onTap!(point.latitude, point.longitude),
      ),
      children: [
        // Only with the athlete's say-so (Settings → Data & privacy → Consent & your rights),
        // and not before that choice has been read.
        OsmTileLayer(showTiles: showTiles),
        PolylineLayer(
          polylines: [
            if (a.isNotEmpty)
              Polyline(
                points: a,
                strokeWidth: 6,
                color: compareColorA,
                borderStrokeWidth: 1.5,
                borderColor: Colors.white.withValues(alpha: 0.85),
              ),
            if (b.isNotEmpty)
              Polyline(points: b, strokeWidth: 3, color: compareColorB),
          ],
        ),
        ValueListenableBuilder<double?>(
          valueListenable: cursor,
          builder: (context, x, _) {
            if (x == null) return const SizedBox.shrink();
            final pa = markerA(x);
            final pb = markerB(x);
            return MarkerLayer(
              markers: [
                if (pa != null)
                  _tracker(
                    const ValueKey('compare-tracker-a'),
                    LatLng(pa.lat, pa.lng),
                    compareColorA,
                    'A',
                  ),
                if (pb != null)
                  _tracker(
                    const ValueKey('compare-tracker-b'),
                    LatLng(pb.lat, pb.lng),
                    compareColorB,
                    'B',
                  ),
              ],
            );
          },
        ),
        OsmAttribution(showTiles: showTiles),
      ],
    );
  }

  static Marker _tracker(Key key, LatLng at, Color color, String letter) =>
      Marker(
        point: at,
        width: 26,
        height: 26,
        child: DecoratedBox(
          key: key,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
}

/// The full-screen, pan-and-zoom version, sharing the compare screen's
/// cursor so the tracker and the chart stay in step.
class CompareRouteScreen extends StatelessWidget {
  const CompareRouteScreen({super.key, required this.title, required this.map});

  final String title;
  final CompareRouteMap map;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: CompareRouteMap(
      key: const ValueKey('compare-map-full'),
      routeA: map.routeA,
      routeB: map.routeB,
      cursor: map.cursor,
      markerA: map.markerA,
      markerB: map.markerB,
      onTap: map.onTap,
      interactive: true,
      showTiles: map.showTiles,
      padding: 48,
    ),
  );
}
