import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Whether the one-time "hold to preview" tip has been dismissed. Plain
/// `shared_preferences`, same pattern as the other small stores.
class HoldTipStore {
  HoldTipStore._();

  static final HoldTipStore instance = HoldTipStore._();

  @visibleForTesting
  factory HoldTipStore.forTesting() = HoldTipStore._;

  static const dismissedKey = 'tips.hold_to_preview_dismissed';

  Future<bool> isDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(dismissedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> dismiss() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(dismissedKey, true);
    } catch (_) {
      // A tip is a convenience: it just shows once more.
    }
  }
}

/// One dismissible line on Today telling the athlete that items can be held
/// to preview them. Shown until dismissed once, then never again.
class HoldTipCard extends StatefulWidget {
  const HoldTipCard({super.key, HoldTipStore? store}) : _store = store;

  final HoldTipStore? _store;

  @override
  State<HoldTipCard> createState() => _HoldTipCardState();
}

class _HoldTipCardState extends State<HoldTipCard> {
  HoldTipStore get _store => widget._store ?? HoldTipStore.instance;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _store.isDismissed().then((done) {
      if (mounted && !done) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        key: const ValueKey('hold-tip'),
        margin: EdgeInsets.zero,
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.touch_app_outlined,
                      size: 20,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.holdTipText,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  key: const ValueKey('hold-tip-dismiss'),
                  onPressed: () {
                    _store.dismiss();
                    setState(() => _show = false);
                  },
                  child: Text(l10n.holdTipGotIt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
