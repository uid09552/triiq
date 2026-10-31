import 'package:flutter/material.dart';

import '../../data/models/local_activity.dart';
import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../l10n/app_localizations.dart';
import '../activities/activity_icons.dart';
import '../activities/session_analysis.dart';
import 'insights_card.dart';

/// Today's new sessions, one page each (newest first), with their
/// evaluation and insights. **OK** — or closing the sheet — is the caller's
/// cue to mark them all as seen.
class NewTrainingSheet extends StatefulWidget {
  const NewTrainingSheet({
    super.key,
    required this.sessions,
    this.plannedItems,
    this.insights,
    this.onDetails,
    this.onFindAlternative,
  });

  final List<LocalActivity> sessions;

  /// Test seams; the app uses the defaults.
  final PlannedItemsRepository? plannedItems;
  final SessionInsightsLoader? insights;

  final ValueChanged<LocalActivity>? onDetails;
  final ValueChanged<LocalEvent>? onFindAlternative;

  @override
  State<NewTrainingSheet> createState() => _NewTrainingSheetState();
}

class _NewTrainingSheetState extends State<NewTrainingSheet> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = widget.sessions.length;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.newTrainingTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (count > 1)
                    Row(
                      key: const ValueKey('new-training-dots'),
                      children: [
                        for (var i = 0; i < count; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _page
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final a in widget.sessions)
                    ListView(
                      key: ValueKey('new-training-${a.id}'),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            activityTypeIcon(a.type),
                            color: sportColor(a.type, scheme),
                            size: 32,
                          ),
                          title: Text(
                            a.name ?? a.type ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            [
                              ?a.type,
                              if (a.movingTime != null)
                                formatDurationSecs(a.movingTime!),
                              if (a.trainingLoad != null)
                                '${a.trainingLoad} TSS',
                            ].join(' · '),
                          ),
                        ),
                        SessionEvaluationCard(
                          activity: a,
                          plannedItems: widget.plannedItems,
                        ),
                        const SizedBox(height: 12),
                        InsightsCard(
                          activity: a,
                          loader: widget.insights,
                          onFindAlternative: widget.onFindAlternative,
                        ),
                        if (widget.onDetails != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => widget.onDetails!(a),
                              icon: const Icon(Icons.open_in_full),
                              label: Text(l10n.newTrainingDetails),
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('new-training-ok'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.newTrainingOk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
