import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation/app_destinations.dart';

/// The trainer's offer to open an app page (`open_app_page`), under the
/// reply that made it: where it leads and one button. Like a proposal,
/// nothing happens until the athlete taps.
class NavigationCard extends StatelessWidget {
  const NavigationCard({
    super.key,
    required this.destinationId,
    this.destinations,
  });

  final String destinationId;

  /// Test seam (default: [appDestinations]).
  final List<AppDestination>? destinations;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final destination = destinationById(destinationId, from: destinations);
    return Padding(
      padding: const EdgeInsets.only(left: 38, top: 4, bottom: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: destination == null
            ? ListTile(
                leading: const Icon(Icons.link_off),
                title: Text(l10n.navCardUnknown),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            destination.icon,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            destination.path(l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      // One node: "Open Durability", button, with the hint.
                      child: MergeSemantics(
                        child: Semantics(
                          hint: l10n.navCardHint(destination.path(l10n)),
                          child: FilledButton.tonalIcon(
                            key: ValueKey('nav-card-$destinationId'),
                            onPressed: () => destination.open(context),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: Text(
                              l10n.navCardOpen(destination.title(l10n)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
