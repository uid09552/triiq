import 'package:flutter/material.dart';

import '../../info/app_info.dart';
import '../../l10n/app_localizations.dart';
import 'info_screen.dart';

/// "TriIQ 0.9.5 (build 1) · Android" in small type at the bottom of Settings;
/// a tap opens Info.
class VersionFooter extends StatefulWidget {
  const VersionFooter({super.key, this.info});

  /// Test seam (default: read from the platform).
  final Future<AppInfo?>? info;

  @override
  State<VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends State<VersionFooter> {
  late final Future<AppInfo?> _info = widget.info ?? AppInfo.load();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return FutureBuilder<AppInfo?>(
      future: _info,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 48);
        }
        final info = snapshot.data;
        final text = info == null
            ? l10n.infoVersionUnavailable
            : info.footerLine(l10n);
        return Center(
          child: Semantics(
            button: true,
            hint: l10n.infoFooterTooltip,
            child: TextButton(
              key: const ValueKey('settings-version'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InfoScreen(info: widget.info),
                ),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
