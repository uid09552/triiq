import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A compact "options" affordance for a chart card: the current choices as
/// one short line, and a tune icon that opens them in a sheet. Keeps the
/// selectors (streams, smoothing, axis, sport …) out of the way until asked
/// for, so the chart gets the space.
class ChartOptionsButton extends StatelessWidget {
  const ChartOptionsButton({super.key, required this.onPressed, this.summary});

  final VoidCallback onPressed;

  /// The current selection in a few words, e.g. `Power, Heart rate · 30 s`.
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (summary != null && summary!.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              summary!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        IconButton(
          key: const ValueKey('chart-options'),
          tooltip: AppLocalizations.of(context)!.chartOptions,
          icon: const Icon(Icons.tune),
          onPressed: onPressed,
        ),
      ],
    );
  }
}

/// Opens [builder]'s controls in a bottom sheet. Controls call the `apply`
/// they are given with their change: it runs in the owner's `setState` (so
/// the chart behind updates at once) and refreshes the sheet.
Future<void> showChartOptions(
  BuildContext context, {
  required String title,
  required void Function(VoidCallback change) ownerSetState,
  required Widget Function(
    BuildContext context,
    void Function(VoidCallback change) apply,
  )
  builder,
}) {
  // A choice that loads data may finish after the sheet was closed.
  var open = true;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setSheetState) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(sheet).textTheme.titleMedium),
              const SizedBox(height: 12),
              builder(sheet, (change) {
                ownerSetState(change);
                if (open) setSheetState(() {});
              }),
            ],
          ),
        ),
      ),
    ),
  ).whenComplete(() => open = false);
}

/// A labelled group of controls inside the options sheet.
class OptionGroup extends StatelessWidget {
  const OptionGroup({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
