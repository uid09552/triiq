import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../data/privacy_settings.dart';

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Whether OpenStreetMap may be asked for tiles right now: the map wants
/// them ([showTiles]), the athlete's choice has been read, and it allows
/// them. Until the stored choice is loaded the answer is no — an opt-out
/// must hold from the first frame, not only once settings have loaded.
bool mapTilesAllowed(PrivacySettings privacy, {bool showTiles = true}) =>
    showTiles && privacy.isLoaded && privacy.mapTiles;

/// The OpenStreetMap tile layer, following the privacy choice as it changes.
class OsmTileLayer extends StatelessWidget {
  const OsmTileLayer({super.key, this.showTiles = true, this.privacy});

  final bool showTiles;
  final PrivacySettings? privacy;

  @override
  Widget build(BuildContext context) {
    final settings = privacy ?? PrivacySettings.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => mapTilesAllowed(settings, showTiles: showTiles)
          ? TileLayer(
              key: const ValueKey('osm-tiles'),
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.triiq.triiq',
            )
          : const SizedBox.shrink(),
    );
  }
}

/// The attribution OpenStreetMap requires, shown whenever its tiles are.
class OsmAttribution extends StatelessWidget {
  const OsmAttribution({super.key, this.showTiles = true, this.privacy});

  final bool showTiles;
  final PrivacySettings? privacy;

  @override
  Widget build(BuildContext context) {
    final settings = privacy ?? PrivacySettings.instance;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => mapTilesAllowed(settings, showTiles: showTiles)
          ? const SimpleAttributionWidget(
              source: Text('© OpenStreetMap contributors'),
            )
          : const SizedBox.shrink(),
    );
  }
}
