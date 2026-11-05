import 'package:flutter/material.dart';

import '../../data/intervals_event_service.dart';
import '../../data/intervals_session.dart';
import '../../data/models/local_event.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import 'event_labels.dart';

/// Creates a calendar event, or edits [event], in Intervals.icu. Pops
/// `true` once it was saved there.
class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({
    super.key,
    this.event,
    this.service,
    this.initialDate,
    this.initialCategory,
  });

  /// For a new event: the day it starts (e.g. the calendar day that was
  /// long-pressed) and its kind (e.g. "SICK"). Ignored when editing.
  final DateTime? initialDate;
  final String? initialCategory;

  final LocalEvent? event;

  /// Test seam; the app uses the default.
  final IntervalsEventService? service;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  static const _sports = ['Run', 'Ride', 'Swim', 'Triathlon'];

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.event?.name ?? '');
  late final _description = TextEditingController(
    text: widget.event?.description ?? '',
  );
  late String _category = _initialCategory();
  late DateTime _date =
      DateTime.tryParse(widget.event?.date ?? '') ??
      dateOnly(widget.initialDate ?? DateTime.now());
  DateTime? _endDate;
  String? _sport;
  bool _saving = false;

  String _initialCategory() {
    final c = widget.event?.category ?? widget.initialCategory;
    return c != null && editableEventCategories.contains(c) ? c : 'RACE_A';
  }

  @override
  void initState() {
    super.initState();
    final raw = widget.event?.raw;
    final end = DateTime.tryParse(raw?['end_date_local'] as String? ?? '');
    if (end != null) _endDate = dateOnly(end);
    final type = widget.event?.type;
    _sport = _sports.contains(type) ? type : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool end}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: end ? (_endDate ?? _date) : _date,
      firstDate: end ? _date : DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (end) {
        _endDate = picked;
      } else {
        _date = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    final draft = EventDraft(
      category: _category,
      name: _name.text.trim(),
      date: _date,
      endDate: _endDate,
      sport: _sport,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    );
    try {
      final service = widget.service ?? IntervalsEventService();
      final existing = widget.event;
      if (existing == null) {
        await service.create(draft);
      } else {
        await service.update(existing.id, draft);
      }
    } catch (error) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.eventCouldNotSave('$error'))),
      );
      return;
    }
    AutoSyncService.instance.notifyCacheChanged();
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connected = IntervalsSession.instance.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event == null ? l10n.eventNewTitle : l10n.eventEditTitle,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!connected)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.eventNotConnected),
              ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.eventCategoryLabel),
              items: [
                for (final c in editableEventCategories)
                  DropdownMenuItem(
                    value: c,
                    child: Text(eventCategoryLabel(l10n, c)),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.eventNameLabel),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.eventNameRequired
                  : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.eventDateLabel),
              subtitle: Text(isoDate(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () => _pickDate(end: false),
            ),
            if (eventCategoryHasEndDate(_category))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.eventEndDateLabel),
                subtitle: Text(_endDate == null ? '—' : isoDate(_endDate!)),
                trailing: _endDate == null
                    ? const Icon(Icons.calendar_today_outlined)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endDate = null),
                      ),
                onTap: () => _pickDate(end: true),
              ),
            if (eventCategoryHasSport(_category)) ...[
              const SizedBox(height: 4),
              DropdownButtonFormField<String?>(
                initialValue: _sport,
                decoration: InputDecoration(labelText: l10n.eventSportLabel),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('—'),
                  ),
                  for (final s in _sports)
                    DropdownMenuItem<String?>(value: s, child: Text(s)),
                ],
                onChanged: (v) => setState(() => _sport = v),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(
                labelText: l10n.eventDescriptionLabel,
              ),
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving || !connected ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.eventSaveButton),
            ),
          ],
        ),
      ),
    );
  }
}
