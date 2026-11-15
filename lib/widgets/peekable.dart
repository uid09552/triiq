import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../l10n/app_localizations.dart';
import 'hold_preview.dart';

/// A [HoldPreview] that assistive technology can reach too: besides the
/// press-and-hold peek, the item gets a "Show preview" semantics action that
/// opens the very same [preview] in a dialog (a peek vanishes when the
/// finger lifts, which a screen reader or switch user cannot do).
///
/// Use this, not a bare [HoldPreview], for tappable items that lead to a
/// detail page. Never wrap an item that already does something on long
/// press (menus, sheets, drag) — see "Hold to peek" in `docs/okf.md`.
class Peekable extends StatelessWidget {
  const Peekable({
    super.key,
    required this.child,
    required this.preview,
    this.width = 340,
    this.estimatedHeight = 240,
  });

  final Widget child;
  final WidgetBuilder preview;
  final double width;
  final double estimatedHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.peekShowPreview): () =>
            showPeekDialog(context, preview),
      },
      child: HoldPreview(
        width: width,
        estimatedHeight: estimatedHeight,
        preview: preview,
        child: child,
      ),
    );
  }
}

/// The peek content in a dialog, for the "Show preview" action.
Future<void> showPeekDialog(BuildContext context, WidgetBuilder preview) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const ValueKey('peek-dialog'),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: preview(dialogContext),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.peekClose),
        ),
      ],
    ),
  );
}
