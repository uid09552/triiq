import 'package:flutter/material.dart';

import '../../data/threshold_dismissals_store.dart';
import '../../data/threshold_suggestions_service.dart';
import '../../evaluation/performance_curves.dart';
import '../../evaluation/threshold_suggestions.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/section_card.dart';
import '../activities/activity_icons.dart';
import 'threshold_confirm_sheet.dart';

/// "{sport} FTP" / "{sport} threshold pace" — the row title, built from
/// data the rest of the app already has strings for rather than a new key
/// per sport/field combination.
String thresholdSuggestionTitle(AppLocalizations l10n, ThresholdSuggestion s) {
  final sport = switch (s.sport) {
    CurveSport.ride => l10n.sportRide,
    CurveSport.run => l10n.sportRun,
    CurveSport.swim => l10n.sportSwim,
  };
  final field = s.field == 'ftp' ? 'FTP' : l10n.thresholdPaceLabel;
  return '$sport $field';
}

/// The formatted value for one threshold value — watts for FTP, pace for
/// thresholdPace.
String thresholdValueLabel(ThresholdSuggestion s, double value) {
  if (s.field == 'ftp') return '${value.round()} W';
  final unit = paceUnitMetres(s.sport);
  final suffix = s.sport == CurveSport.swim ? '/100 m' : '/km';
  return '${formatPace(value, per: unit)} $suffix';
}

/// Localized explanation of where [s]'s candidate came from.
String thresholdBasisText(AppLocalizations l10n, ThresholdSuggestion s) {
  final percent = (s.changeFraction.abs() * 100).toStringAsFixed(1);
  return switch (s.basisKind) {
    ThresholdBasisKind.rideSeasonModel =>
      l10n.thresholdBasisRideSeasonModel(percent),
    ThresholdBasisKind.rideRecentModel =>
      l10n.thresholdBasisRideRecentModel(percent),
    ThresholdBasisKind.runSeason60Min =>
      l10n.thresholdBasisRunSeason60Min(percent),
    ThresholdBasisKind.runSeason40MinHeuristic =>
      l10n.thresholdBasisRunSeason40MinHeuristic,
    ThresholdBasisKind.runRecent60Min =>
      l10n.thresholdBasisRunRecent60Min(percent),
    ThresholdBasisKind.runRecent40MinHeuristic =>
      l10n.thresholdBasisRunRecent40MinHeuristic,
    ThresholdBasisKind.swimSeasonCss =>
      l10n.thresholdBasisSwimSeasonCss(percent),
    ThresholdBasisKind.swimRecentCss =>
      l10n.thresholdBasisSwimRecentCss(percent),
  };
}

/// A representative Intervals.icu type string for [sport], so the existing
/// `sportColor`/`activityTypeIcon` helpers (keyed off activity type) can be
/// reused for threshold suggestions too.
String _representativeType(CurveSport sport) => sport.apiType;

/// Section listing every current threshold suggestion (ride FTP, run/swim
/// threshold pace), each with Review (opens the confirm sheet) and
/// Dismiss. Shown on the Performance screen and on Today; renders nothing
/// when there are no suggestions. Reads only the cache — like the rest of
/// the Performance screen, nothing here fetches.
class ThresholdSuggestionsSection extends StatefulWidget {
  ThresholdSuggestionsSection({super.key, ThresholdSuggestionsService? service})
    : service = service ?? ThresholdSuggestionsService();

  final ThresholdSuggestionsService service;

  @override
  State<ThresholdSuggestionsSection> createState() =>
      _ThresholdSuggestionsSectionState();
}

class _ThresholdSuggestionsSectionState
    extends State<ThresholdSuggestionsSection> {
  List<ThresholdSuggestion>? _suggestions;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final suggestions = await widget.service.load();
    if (!mounted) return;
    setState(() => _suggestions = suggestions);
  }

  Future<void> _dismiss(ThresholdSuggestion s) async {
    await ThresholdDismissalsStore.instance.dismiss(
      s.sport,
      s.direction,
      s.candidateValue,
    );
    await _load();
  }

  Future<void> _review(ThresholdSuggestion s) async {
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ThresholdConfirmSheet(suggestion: s),
    );
    if (applied == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions;
    if (suggestions == null || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SectionCard(
        icon: Icons.trending_up_outlined,
        title: l10n.thresholdSuggestionsTitle,
        child: Column(
          children: [
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SuggestionRow(
                  suggestion: s,
                  color: sportColor(_representativeType(s.sport), colorScheme),
                  icon: activityTypeIcon(_representativeType(s.sport)),
                  onReview: () => _review(s),
                  onDismiss: () => _dismiss(s),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.suggestion,
    required this.color,
    required this.icon,
    required this.onReview,
    required this.onDismiss,
  });

  final ThresholdSuggestion suggestion;
  final Color color;
  final IconData icon;
  final VoidCallback onReview;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    thresholdSuggestionTitle(l10n, suggestion),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  suggestion.direction == ThresholdDirection.up
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 16,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.thresholdChangeLine(
                thresholdValueLabel(suggestion, suggestion.currentValue),
                thresholdValueLabel(suggestion, suggestion.candidateValue),
              ),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              thresholdBasisText(l10n, suggestion),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: Text(l10n.proposalDismiss),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: onReview,
                  child: Text(l10n.thresholdReviewButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
