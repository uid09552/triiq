import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/local_event.dart';
import '../../data/planned_items.dart';
import '../../l10n/app_localizations.dart';
import '../../season/health_actions.dart';
import '../../season/illness_mode.dart';
import '../../season/life_modes.dart';
import '../../util/dates.dart';
import '../../util/clock.dart';

/// Sick or niggle, travel, short on time: pick the days and how much to
/// train, see every change before → after, apply them in one go. Only the
/// window changes; later weeks stay as they are.
Future<void> showLifeModeSheet(
  BuildContext context, {
  LifeMode initial = LifeMode.unwell,
  DateTime? today,
  Future<List<LocalEvent>> Function(DateTime from, DateTime to)? planned,
  HealthActions? actions,
}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (_) => LifeModeSheet(
    initial: initial,
    today: today,
    planned: planned,
    actions: actions,
  ),
);

class LifeModeSheet extends StatefulWidget {
  const LifeModeSheet({
    super.key,
    this.initial = LifeMode.unwell,
    this.today,
    this.planned,
    this.actions,
  });

  final LifeMode initial;
  final DateTime? today;
  final Future<List<LocalEvent>> Function(DateTime from, DateTime to)? planned;
  final HealthActions? actions;

  @override
  State<LifeModeSheet> createState() => _LifeModeSheetState();
}

class _LifeModeSheetState extends State<LifeModeSheet> {
  late LifeMode _mode = widget.initial;
  late ModeIntensity _intensity = intensitiesFor(_mode).first;
  late final DateTime _start = dateOnly(widget.today ?? clockNow());
  late DateTime _end = _start.add(const Duration(days: 3));
  List<LocalEvent> _sessions = const [];
  bool _loading = true;
  bool _applying = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list =
          await (widget.planned ??
              (a, b) => PlannedItemsRepository().getRange(
                isoDate(a),
                isoDate(b),
              ))(_start, _end);
      if (mounted) setState(() => _sessions = list);
    } catch (_) {
      if (mounted) setState(() => _sessions = const []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ReturnChange> get _changes => lifeModeChanges(
    mode: _mode,
    intensity: _intensity,
    start: _start,
    end: _end,
    planned: _sessions,
  );

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: _start,
      lastDate: _start.add(const Duration(days: 14)),
    );
    if (picked == null) return;
    setState(() => _end = dateOnly(picked));
    await _load();
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _applying = true;
      _message = null;
    });
    final changes = _changes;
    final result = await (widget.actions ?? HealthActions()).applyAll(changes);
    if (!mounted) return;
    if (result.error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.modeApplied(result.done))));
    } else {
      setState(() {
        _applying = false;
        _message = l10n.modePartlyApplied(
          result.done,
          changes.length,
          '${result.error}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final changes = _changes;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.modeTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l10n.modeIntro, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          SegmentedButton<LifeMode>(
            key: const ValueKey('mode-kind'),
            showSelectedIcon: false,
            segments: [
              for (final m in LifeMode.values)
                ButtonSegment(value: m, label: Text(modeLabel(l10n, m))),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _intensity = intensitiesFor(_mode).first;
            }),
          ),
          const SizedBox(height: 12),
          ListTile(
            key: const ValueKey('mode-end'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.date_range),
            title: Text(
              l10n.modeWindow(
                DateFormat.MMMEd(locale).format(_start),
                DateFormat.MMMEd(locale).format(_end),
              ),
            ),
            subtitle: Text(l10n.modeEndHint),
            onTap: _pickEnd,
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final i in intensitiesFor(_mode))
                ChoiceChip(
                  key: ValueKey('mode-intensity-${i.name}'),
                  label: Text(intensityLabel(l10n, i)),
                  selected: _intensity == i,
                  onSelected: (_) => setState(() => _intensity = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const LinearProgressIndicator()
          else if (changes.isEmpty)
            Text(l10n.modeNothingToChange, key: const ValueKey('mode-empty'))
          else
            for (final c in changes)
              ListTile(
                key: ValueKey('mode-change-${c.session.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  '${DateFormat.E(locale).format(DateTime.parse(c.session.date))}'
                  ' · ${c.session.name ?? c.session.type ?? ''}',
                ),
                subtitle: Text(
                  c.action == ReturnAction.rest
                      ? l10n.modeChangeRest(
                          ((c.session.plannedTime ?? 0) / 60).round(),
                        )
                      : l10n.modeChangeShorter(
                          ((c.session.plannedTime ?? 0) / 60).round(),
                          c.minutes ?? 0,
                        ),
                ),
              ),
          const SizedBox(height: 8),
          Text(l10n.modeAfterNote, style: theme.textTheme.bodySmall),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(_message!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const ValueKey('mode-apply'),
              onPressed: _applying || changes.isEmpty ? null : _apply,
              child: Text(l10n.modeApply(changes.length)),
            ),
          ),
        ],
      ),
    );
  }
}

String modeLabel(AppLocalizations l, LifeMode m) => switch (m) {
  LifeMode.unwell => l.modeUnwell,
  LifeMode.travel => l.modeTravel,
  LifeMode.timeCrunched => l.modeTimeCrunched,
};

String intensityLabel(AppLocalizations l, ModeIntensity i) => switch (i) {
  ModeIntensity.rest => l.modeRest,
  ModeIntensity.easy => l.modeEasy,
  ModeIntensity.shorter => l.modeShorter(timeCrunchedMinutes),
};
