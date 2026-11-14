import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';

/// What can ask for attention on Today, most important first.
enum AttentionKind { health, fatigue, adjustments, race, thresholds }

/// One card in the attention stack. [priority] sorts it (lower first);
/// [kind] is what a dismissal hides for the rest of the day.
class AttentionItem {
  const AttentionItem({required this.kind, required this.child, int? priority})
    : priority = priority ?? 0;

  final AttentionKind kind;
  final Widget child;
  final int priority;
}

/// Kinds the athlete swiped (or closed) away today — stored on the device
/// for the day only, so tomorrow everything may speak up again.
class AttentionDismissals extends ChangeNotifier {
  AttentionDismissals._();

  static final AttentionDismissals instance = AttentionDismissals._();

  @visibleForTesting
  factory AttentionDismissals.forTesting() = AttentionDismissals._;

  static const _key = 'today.attention_dismissed';

  String? _day;
  final Set<AttentionKind> _kinds = {};

  bool isDismissed(AttentionKind kind, DateTime now) =>
      _day == isoDate(now) && _kinds.contains(kind);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_key) ?? const <String>[];
      _kinds.clear();
      _day = stored.isEmpty ? null : stored.first;
      for (final name in stored.skip(1)) {
        for (final k in AttentionKind.values) {
          if (k.name == name) _kinds.add(k);
        }
      }
    } catch (error) {
      debugPrint('AttentionDismissals: cannot read: $error');
    }
    notifyListeners();
  }

  Future<void> dismiss(AttentionKind kind, DateTime now) async {
    final day = isoDate(now);
    if (_day != day) {
      _day = day;
      _kinds.clear();
    }
    _kinds.add(kind);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, [day, for (final k in _kinds) k.name]);
    } catch (error) {
      debugPrint('AttentionDismissals: cannot save: $error');
    }
  }
}

/// The cards that have something to say, under the hero: most important
/// first, at most [maxVisible] open, the rest behind "+N more". Each can be
/// swiped away (or closed with its × button) for the rest of the day.
class AttentionStack extends StatefulWidget {
  const AttentionStack({
    super.key,
    required this.items,
    required this.onDismiss,
    this.maxVisible = 2,
  });

  final List<AttentionItem> items;
  final ValueChanged<AttentionKind> onDismiss;
  final int maxVisible;

  @override
  State<AttentionStack> createState() => _AttentionStackState();
}

class _AttentionStackState extends State<AttentionStack> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = [...widget.items]
      ..sort((a, b) => a.priority.compareTo(b.priority));
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final shown = _expanded ? items : items.take(widget.maxVisible).toList();
    final more = items.length - shown.length;

    return Column(
      key: const ValueKey('attention-stack'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in shown)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Dismissible(
              key: ValueKey('attention-${item.kind.name}'),
              onDismissed: (_) => widget.onDismiss(item.kind),
              background: _swipeBackground(scheme, l10n, Alignment.centerLeft),
              secondaryBackground: _swipeBackground(
                scheme,
                l10n,
                Alignment.centerRight,
              ),
              child: Semantics(
                customSemanticsActions: {
                  CustomSemanticsAction(label: l10n.attentionHideToday): () =>
                      widget.onDismiss(item.kind),
                },
                child: Stack(
                  children: [
                    item.child,
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: IconButton(
                        key: ValueKey('attention-close-${item.kind.name}'),
                        tooltip: l10n.attentionHideToday,
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        onPressed: () => widget.onDismiss(item.kind),
                        icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (more > 0 || (_expanded && items.length > widget.maxVisible))
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('attention-more'),
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _expanded ? l10n.attentionShowLess : l10n.attentionMore(more),
              ),
            ),
          ),
      ],
    );
  }

  Widget _swipeBackground(
    ColorScheme scheme,
    AppLocalizations l10n,
    Alignment alignment,
  ) => Container(
    alignment: alignment,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      l10n.attentionHideToday,
      style: TextStyle(color: scheme.onSurfaceVariant),
    ),
  );
}
