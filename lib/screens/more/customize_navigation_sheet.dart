import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation/nav_items.dart';
import '../../navigation/navigation_layout.dart';

/// Bottom sheet to arrange the navigation: drag to reorder the bottom bar
/// and More, or to move an item between them; Up / Down / Move to More /
/// Pin to bar buttons (and the same as screen-reader actions) do the same
/// one step at a time. A live preview shows the bar; a move that would
/// leave the bar's 2–4 items (besides More) is refused with a message.
Future<void> showCustomizeNavigationSheet(
  BuildContext context,
  NavigationLayout layout,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => CustomizeNavigationSheet(layout: layout),
);

class CustomizeNavigationSheet extends StatefulWidget {
  const CustomizeNavigationSheet({super.key, required this.layout});

  final NavigationLayout layout;

  @override
  State<CustomizeNavigationSheet> createState() =>
      _CustomizeNavigationSheetState();
}

const _barHeader = '#bar';
const _moreHeader = '#more';

class _CustomizeNavigationSheetState extends State<CustomizeNavigationSheet> {
  NavigationLayout get _layout => widget.layout;

  /// Why the last move was refused; cleared by the next one that works.
  String? _message;

  /// The list as the sheet draws it: a header, the bar's items, a header,
  /// More's items.
  List<String> get _rows => [
    _barHeader,
    ..._layout.bar,
    _moreHeader,
    ..._layout.more,
  ];

  Future<void> _apply(Future<NavMoveResult> move) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await move;
    if (!mounted) return;
    setState(() {
      _message = switch (result) {
        NavMoveResult.barFull => l10n.navBarFull(NavigationLayout.maxBar),
        NavMoveResult.barMinimum => l10n.navBarMinimum(NavigationLayout.minBar),
        NavMoveResult.ok => null,
        NavMoveResult.unchanged => _message,
      };
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    final rows = _rows;
    final id = rows[oldIndex];
    if (id == _barHeader || id == _moreHeader) return;
    if (newIndex > oldIndex) newIndex -= 1;
    final rest = List.of(rows)..removeAt(oldIndex);
    final moreAt = rest.indexOf(_moreHeader);
    final inBar = newIndex <= moreAt;
    final index = inBar ? math.max(0, newIndex - 1) : newIndex - moreAt - 1;
    _apply(_layout.place(id, inBar: inBar, index: index));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: ListenableBuilder(
        listenable: _layout,
        builder: (context, _) {
          final rows = _rows;
          final bar = _layout.bar;
          final more = _layout.more;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
                // Wraps: with large text the reset button goes below.
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.navCustomizeTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('nav-customize-reset'),
                      onPressed: _layout.isDefault
                          ? null
                          : () {
                              setState(() => _message = null);
                              _layout.reset();
                            },
                      child: Text(l10n.navCustomizeReset),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ReorderableListView(
                  key: const ValueKey('nav-customize-list'),
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  onReorder: _onReorder,
                  header: _Intro(
                    bar: _layout.barWithMore,
                    count: bar.length,
                    message: _message,
                  ),
                  children: [
                    for (final (index, id) in rows.indexed)
                      if (id == _barHeader)
                        _SectionHeader(
                          key: const ValueKey('nav-section-bar'),
                          title: l10n.navSectionBar,
                        )
                      else if (id == _moreHeader)
                        Column(
                          key: const ValueKey('nav-section-more'),
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              key: const ValueKey('nav-fixed-more'),
                              leading: const Icon(Icons.lock_outline),
                              title: Text(l10n.navMoreFixed),
                            ),
                            const Divider(height: 1),
                            _SectionHeader(title: l10n.navSectionMore),
                          ],
                        )
                      else
                        _ItemRow(
                          key: ValueKey('nav-item-$id'),
                          index: index,
                          item: navItem(id),
                          inBar: bar.contains(id),
                          position: bar.contains(id)
                              ? bar.indexOf(id)
                              : more.indexOf(id),
                          count: bar.contains(id) ? bar.length : more.length,
                          onShift: (delta) => _apply(_layout.shift(id, delta)),
                          onToggle: () => _apply(
                            bar.contains(id)
                                ? _layout.moveToMore(id)
                                : _layout.pinToBar(id),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Help text, the live preview of the bar, how full it is, and why the
/// last move was refused.
class _Intro extends StatelessWidget {
  const _Intro({required this.bar, required this.count, this.message});

  final List<String> bar;
  final int count;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final labels = [for (final id in bar) navItem(id).label(l10n)];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.navCustomizeHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Semantics(
            label: l10n.navPreviewLabel(labels.join(', ')),
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NavigationBar(
                    key: const ValueKey('nav-preview'),
                    selectedIndex: 0,
                    destinations: [
                      for (final id in bar)
                        NavigationDestination(
                          icon: Icon(navItem(id).icon),
                          selectedIcon: Icon(navItem(id).selectedIcon),
                          label: navItem(id).label(l10n),
                          tooltip: '',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.navBarCount(
              count,
              NavigationLayout.maxBar,
              NavigationLayout.minBar,
            ),
            style: theme.textTheme.bodySmall,
          ),
          Semantics(
            liveRegion: true,
            child: message == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      message!,
                      key: const ValueKey('nav-customize-message'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Settings › App › Navigation: what the bar holds now, and the way to
/// arrange it.
class NavigationSettingsTile extends StatelessWidget {
  const NavigationSettingsTile({super.key, this.layout});

  /// Test seam (default: [NavigationLayout.instance]).
  final NavigationLayout? layout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layout = this.layout ?? NavigationLayout.instance;
    return ListenableBuilder(
      listenable: layout,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.navSettingsCurrent(
              [
                for (final id in layout.barWithMore) navItem(id).label(l10n),
              ].join(' · '),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              key: const ValueKey('settings-customize-nav'),
              onPressed: () => showCustomizeNavigationSheet(context, layout),
              icon: const Icon(Icons.swap_vert),
              label: Text(l10n.navCustomizeTitle),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.inBar,
    required this.position,
    required this.count,
    required this.onShift,
    required this.onToggle,
  });

  /// Position in the reorderable list (headers included).
  final int index;
  final NavItem item;
  final bool inBar;

  /// Position within its own section, and that section's length.
  final int position;
  final int count;
  final void Function(int delta) onShift;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = item.title(l10n);
    final canUp = position > 0;
    final canDown = position < count - 1;
    final toggleLabel = inBar ? l10n.navMoveToMore : l10n.navPinToBar;
    return Semantics(
      container: true,
      customSemanticsActions: {
        if (canUp)
          CustomSemanticsAction(label: l10n.navMoveUp): () => onShift(-1),
        if (canDown)
          CustomSemanticsAction(label: l10n.navMoveDown): () => onShift(1),
        CustomSemanticsAction(label: toggleLabel): onToggle,
      },
      child: ReorderableDelayedDragStartListener(
        index: index,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
          leading: ReorderableDragStartListener(
            index: index,
            child: ExcludeSemantics(
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ),
          title: Semantics(
            label: l10n.navItemPosition(
              title,
              inBar ? l10n.navSectionBar : l10n.navSectionMore,
              position + 1,
              count,
            ),
            excludeSemantics: true,
            child: Row(
              children: [
                Icon(item.icon, size: 20),
                const SizedBox(width: 8),
                Flexible(child: Text(title)),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: ValueKey('nav-up-${item.id}'),
                tooltip: l10n.navMoveUp,
                icon: const Icon(Icons.arrow_upward),
                onPressed: canUp ? () => onShift(-1) : null,
              ),
              IconButton(
                key: ValueKey('nav-down-${item.id}'),
                tooltip: l10n.navMoveDown,
                icon: const Icon(Icons.arrow_downward),
                onPressed: canDown ? () => onShift(1) : null,
              ),
              IconButton(
                key: ValueKey('nav-toggle-${item.id}'),
                tooltip: toggleLabel,
                icon: Icon(
                  inBar ? Icons.playlist_remove : Icons.push_pin_outlined,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
