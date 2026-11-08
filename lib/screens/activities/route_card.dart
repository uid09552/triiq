import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/local_activity.dart';
import '../../evaluation/activity_route.dart';
import '../../evaluation/session_evaluator.dart' show sportFamily;
import '../../l10n/app_localizations.dart';
import '../../widgets/osm_layers.dart';
import '../../widgets/section_card.dart';

/// Whether the activity can have a GPS track worth a map: outdoor running
/// and cycling. Indoor rides (trainer, virtual) and other sports are left
/// out.
bool hasRouteMap(LocalActivity a) {
  final family = sportFamily(a.type);
  if (family != 'run' && family != 'ride') return false;
  final type = (a.type ?? '').toLowerCase();
  if (type.contains('virtual') || type.contains('treadmill')) return false;
  if (a.raw['trainer'] == true) return false;
  return true;
}

/// The track drawn on a map: the route in the theme's colour, a green start
/// and a red finish marker, OpenStreetMap tiles with attribution.
///
/// [interactive] lets the map pan and zoom (the full-screen view); in the
/// activity page the map is a still picture so it never steals the scroll.
/// [showTiles] is a test seam: tests draw the track without fetching tiles.
class RouteMap extends StatelessWidget {
  const RouteMap({
    super.key,
    required this.route,
    this.interactive = false,
    this.showTiles = true,
    this.padding = 28,
    this.cursor,
  });

  /// The elapsed seconds the athlete is pointing at on the diagram; the map
  /// marks where the activity was then. Null or unknown: no marker.
  final ValueListenable<double?>? cursor;

  final ActivityRoute route;
  final bool interactive;
  final bool showTiles;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = [for (final p in route.points) LatLng(p.lat, p.lng)];
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: points,
          padding: EdgeInsets.all(padding),
        ),
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all & ~InteractiveFlag.rotate : InteractiveFlag.none,
        ),
      ),
      children: [
        // Only with the athlete's say-so (Settings → Privacy & data),
        // and not before that choice has been read.
        OsmTileLayer(showTiles: showTiles),
        PolylineLayer(
          polylines: [
            Polyline(
              points: points,
              strokeWidth: 4,
              color: scheme.primary,
              borderStrokeWidth: 1.5,
              borderColor: Colors.white.withValues(alpha: 0.85),
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            _dot(points.first, Colors.green.shade600),
            _dot(points.last, Colors.red.shade600),
          ],
        ),
        if (cursor != null)
          ValueListenableBuilder<double?>(
            valueListenable: cursor!,
            builder: (context, seconds, _) {
              final at = seconds == null ? null : route.pointAt(seconds);
              if (at == null) return const SizedBox.shrink();
              return MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(at.lat, at.lng),
                    width: 22,
                    height: 22,
                    child: DecoratedBox(
                      key: const ValueKey('route-cursor'),
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        OsmAttribution(showTiles: showTiles),
      ],
    );
  }

  static Marker _dot(LatLng at, Color color) => Marker(
    point: at,
    width: 16,
    height: 16,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    ),
  );
}

/// The route of an outdoor run or ride, on the activity's detail page: a
/// still map that opens full screen (pan / zoom) on tap. Draws nothing when
/// there is no GPS track, and while loading or when it can't be fetched
/// (offline) — the map is a bonus, never an error.
class ActivityRouteCard extends StatefulWidget {
  ActivityRouteCard({
    super.key,
    required this.activity,
    ActivityRouteRepository? routes,
    this.showTiles = true,
    this.cursor,
  }) : routes = routes ?? ActivityRouteRepository();

  /// Where the pointer is on the session diagram (elapsed seconds).
  final ValueListenable<double?>? cursor;

  final LocalActivity activity;
  final ActivityRouteRepository routes;
  final bool showTiles;

  @override
  State<ActivityRouteCard> createState() => _ActivityRouteCardState();
}

class _ActivityRouteCardState extends State<ActivityRouteCard> {
  late final Future<ActivityRoute?> _future = hasRouteMap(widget.activity)
      ? widget.routes.load(widget.activity.id).then<ActivityRoute?>((r) => r).catchError((_) => null)
      : Future<ActivityRoute?>.value(null);

  @override
  Widget build(BuildContext context) {
    if (!hasRouteMap(widget.activity)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<ActivityRoute?>(
      future: _future,
      builder: (context, snap) {
        final route = snap.data;
        if (route == null || route.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SectionCard(
            key: const ValueKey('route-card'),
            icon: Icons.map_outlined,
            title: l10n.routeTitle,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RouteMap(
                      route: route,
                      showTiles: widget.showTiles,
                      cursor: widget.cursor,
                    ),
                    // The still map hands taps to the full-screen view.
                    Positioned.fill(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          key: const ValueKey('route-open'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RouteScreen(
                                title: widget.activity.name ?? l10n.routeTitle,
                                route: route,
                                showTiles: widget.showTiles,
                                cursor: widget.cursor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.open_in_full,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The full-screen, interactive map.
class RouteScreen extends StatelessWidget {
  const RouteScreen({
    super.key,
    required this.title,
    required this.route,
    this.showTiles = true,
    this.cursor,
  });

  final String title;
  final ActivityRoute route;
  final bool showTiles;
  final ValueListenable<double?>? cursor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: RouteMap(
        key: const ValueKey('route-full'),
        route: route,
        interactive: true,
        showTiles: showTiles,
        padding: 48,
        cursor: cursor,
      ),
    );
  }
}
