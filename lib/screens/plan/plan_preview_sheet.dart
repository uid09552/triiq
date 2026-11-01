import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/plan_models.dart';
import '../activities/activity_icons.dart';
import 'plan_labels.dart';

/// What the athlete confirmed: the plan (with any dates they moved) and
/// whether to also put it on their phone calendar.
class PlanPreviewResult {
  const PlanPreviewResult({required this.plan, required this.addToCalendar});

  final TrainingPlan plan;
  final bool addToCalendar;
}

/// Shows every session of a draft plan before anything is written. A date can
/// be moved here; cancelling (or dismissing) creates nothing anywhere.
class PlanPreviewSheet extends StatefulWidget {
  const PlanPreviewSheet({
    super.key,
    required this.plan,
    this.offerCalendar = false,
  });

  final TrainingPlan plan;

  /// Whether to offer "also add to my phone calendar" (Android only).
  final bool offerCalendar;

  @override
  State<PlanPreviewSheet> createState() => _PlanPreviewSheetState();
}

class _PlanPreviewSheetState extends State<PlanPreviewSheet> {
  late List<PlanWeek> _weeks;
  bool _calendar = false;

  @override
  void initState() {
    super.initState();
    _weeks = widget.plan.weeks;
  }

  Future<void> _moveSession(PlanWeek week, PlanSession session) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: session.date.isBefore(today) ? today : session.date,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: widget.plan.startDate.add(const Duration(days: 28 + 14)),
    );
    if (picked == null) return;
    setState(() {
      _weeks = [
        for (final w in _weeks)
          if (w.index == week.index)
            w.withSessions([
              for (final s in w.sessions)
                if (identical(s, session)) s.copyWith(date: picked) else s,
            ])
          else
            w,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.MMMEd(locale);

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (context, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.planPreviewTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.planPreviewNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scroll,
                  children: [
                    for (final week in _weeks) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          l10n.planWeekLabel(
                            week.index + 1,
                            phaseLabel(l10n, week.phase),
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final session in week.sessions)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            activityTypeIcon(session.sport),
                            color: sportColor(
                              session.sport,
                              theme.colorScheme,
                            ),
                            semanticLabel: sportLabel(l10n, session.sport),
                          ),
                          title: Text(session.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.planSessionMinutes(
                                  session.minutes,
                                  session.load,
                                ),
                              ),
                              Text(
                                session.shortDescription,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: TextButton(
                            onPressed: () => _moveSession(week, session),
                            child: Text(dateFormat.format(session.date)),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (widget.offerCalendar)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _calendar,
                  onChanged: (v) => setState(() => _calendar = v ?? false),
                  title: Text(l10n.planCreateCalendarToo),
                ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancelButton),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      PlanPreviewResult(
                        plan: widget.plan.copyWith(weeks: _weeks),
                        addToCalendar: _calendar,
                      ),
                    ),
                    child: Text(l10n.planConfirmButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
