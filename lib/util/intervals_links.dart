import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/intervals_session.dart';
import '../l10n/app_localizations.dart';

/// Long-press on a stat tile: offers to open the same figure on
/// intervals.icu, for the detail (raw tables, custom ranges, CSV export,
/// ...) this app doesn't attempt to replace. No-ops when not connected —
/// there is no athlete page to open.
///
/// [path] is the segment after `/athlete/{id}/`, e.g. `'fitness'` for the
/// PMC chart (CTL/ATL/form/ramp rate/TSS) or `'activities'` for the list.
Future<void> showOpenInIntervalsSheet(
  BuildContext context, {
  required String label,
  required String path,
}) async {
  final athleteId = IntervalsSession.instance.athleteId;
  if (athleteId == null) return;

  final l10n = AppLocalizations.of(context)!;
  final open = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: ListTile(
        leading: const Icon(Icons.open_in_new),
        title: Text(l10n.openInIntervals),
        subtitle: Text(label),
        onTap: () => Navigator.of(context).pop(true),
      ),
    ),
  );
  if (open != true || !context.mounted) return;
  await openInIntervals(context, path);
}

/// Opens `https://intervals.icu/athlete/{id}/{path}` in the browser.
Future<void> openInIntervals(BuildContext context, String path) async {
  final athleteId = IntervalsSession.instance.athleteId;
  if (athleteId == null) return;
  final l10n = AppLocalizations.of(context)!;
  final uri = Uri.parse('https://intervals.icu/athlete/$athleteId/$path');
  // externalApplication: same hand-off to the OS as "Open in Intervals.icu"
  // on the activity detail screen.
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.couldNotOpenUrl(uri.toString()))),
    );
  }
}
