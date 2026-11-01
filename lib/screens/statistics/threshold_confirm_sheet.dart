import 'package:flutter/material.dart';

import '../../client/intervalls/intervalls_client.dart';
import '../../data/intervals_session.dart';
import '../../data/sport_settings_service.dart';
import '../../evaluation/threshold_suggestions.dart';
import '../../l10n/app_localizations.dart';
import 'threshold_suggestion_card.dart';

/// Review-and-confirm sheet for one [ThresholdSuggestion]: current vs. new
/// value, the zone ranges each implies, an opt-in to also recalculate HR
/// zones, and that past activities keep their recorded load. Nothing is
/// written until **Apply**. Pops `true` after a successful apply so the
/// caller can refresh its list.
class ThresholdConfirmSheet extends StatefulWidget {
  ThresholdConfirmSheet({
    super.key,
    required this.suggestion,
    SportSettingsService? service,
    IntervalsSession? session,
  }) : service = service ?? SportSettingsService(),
       session = session ?? IntervalsSession.instance;

  final ThresholdSuggestion suggestion;
  final SportSettingsService service;
  final IntervalsSession session;

  @override
  State<ThresholdConfirmSheet> createState() => _ThresholdConfirmSheetState();
}

class _ThresholdConfirmSheetState extends State<ThresholdConfirmSheet> {
  bool _recalcHrZones = false;
  bool _applying = false;
  String? _error;
  bool _applied = false;

  ThresholdSuggestion get _s => widget.suggestion;

  SportSettings? get _settings =>
      widget.session.settingsForSport(_s.sport.apiType);

  Future<void> _apply() async {
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      await widget.service.apply(_s, recalcHrZones: _recalcHrZones);
      if (!mounted) return;
      setState(() {
        _applying = false;
        _applied = true;
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _applying = false;
        _error = l10n.thresholdUpdateFailed('$error');
      });
    }
  }

  Future<void> _undo() async {
    setState(() {
      _applying = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.service.undo(_s);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.thresholdUndoSuccess)),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.thresholdUndoFailed('$error'))),
      );
      setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = _settings;
    final indoorFtp = _s.field == 'ftp' ? settings?.indoorFtp : null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                thresholdSuggestionTitle(l10n, _s),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.thresholdConfirmSheetTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _valueTile(
                      context,
                      l10n.thresholdCurrentLabel,
                      thresholdValueLabel(_s, _s.currentValue),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: colorScheme.onSurfaceVariant),
                  Expanded(
                    child: _valueTile(
                      context,
                      l10n.thresholdNewLabel,
                      thresholdValueLabel(_s, _s.candidateValue),
                      accent: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                thresholdBasisText(l10n, _s),
                style: theme.textTheme.bodySmall,
              ),
              if (settings != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.thresholdZonesTitle,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _ZonesTable(suggestion: _s, settings: settings),
              ],
              if (indoorFtp != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.thresholdIndoorFtpNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                l10n.thresholdPastLoadNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (_s.effortActivityIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.thresholdEffortsUsedTitle,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  _s.effortActivityIds.join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.thresholdRecalcHrZones),
                value: _recalcHrZones,
                onChanged: _applied
                    ? null
                    : (v) => setState(() => _recalcHrZones = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: colorScheme.error)),
              ],
              const SizedBox(height: 16),
              if (_applied)
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.thresholdUpdateSuccess)),
                    TextButton(
                      onPressed: _applying ? null : _undo,
                      child: Text(l10n.thresholdUndoButton),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _applying
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancelButton),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applying ? null : _apply,
                        child: _applying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(l10n.proposalApply),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _valueTile(
    BuildContext context,
    String label,
    String value, {
    bool accent = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: accent ? colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}

/// Absolute zone ranges before/after, computed locally from the sport's
/// zone percentage list times the old/new threshold — no server call.
/// Assumes `powerZones`/`paceZones` are ascending percentage boundaries of
/// threshold (FTP or threshold pace), the same convention Intervals.icu
/// uses for the athlete-facing zone table.
class _ZonesTable extends StatelessWidget {
  const _ZonesTable({required this.suggestion, required this.settings});

  final ThresholdSuggestion suggestion;
  final SportSettings settings;

  List<num>? get _percentBoundaries => suggestion.field == 'ftp'
      ? settings.powerZones
      : settings.paceZones?.map((p) => p).toList();

  List<String>? get _names =>
      suggestion.field == 'ftp' ? settings.powerZoneNames : null;

  String _format(double value) => thresholdValueLabel(suggestion, value);

  @override
  Widget build(BuildContext context) {
    final boundaries = _percentBoundaries;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (boundaries == null || boundaries.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[
      Row(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            child: Text(
              l10n.thresholdZonesBefore,
              style: theme.textTheme.labelSmall,
            ),
          ),
          Expanded(
            child: Text(
              l10n.thresholdZonesAfter,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    ];

    var lowerOld = 0.0;
    var lowerNew = 0.0;
    for (var i = 0; i < boundaries.length; i++) {
      final percent = boundaries[i].toDouble() / 100;
      final upperOld = suggestion.currentValue * percent;
      final upperNew = suggestion.candidateValue * percent;
      final name = (_names != null && i < _names!.length)
          ? _names![i]
          : 'Z${i + 1}';
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(name, style: theme.textTheme.bodySmall),
              ),
              Expanded(
                child: Text(
                  '${_format(lowerOld)}-${_format(upperOld)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${_format(lowerNew)}-${_format(upperNew)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
      lowerOld = upperOld;
      lowerNew = upperNew;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}
