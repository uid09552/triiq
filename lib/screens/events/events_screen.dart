import 'package:flutter/material.dart';

import '../../data/intervals_event_service.dart';
import '../../data/intervals_session.dart';
import '../../data/models/local_event.dart';
import '../../data/repositories/events_repository.dart';
import '../../data/sync/auto_sync_service.dart';
import '../../data/sync/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../util/dates.dart';
import 'event_editor_screen.dart';
import 'event_labels.dart';

/// Races, notes, holidays and other non-workout calendar entries. They live
/// in Intervals.icu; this screen creates, edits and deletes them there and
/// reads them from the cache the daily background sync keeps current.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _repository = EventsRepository();
  final _syncService = SyncService();

  List<LocalEvent> _events = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    AutoSyncService.instance.addListener(_load);
    _refresh(force: false);
  }

  @override
  void dispose() {
    AutoSyncService.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _refresh({required bool force}) async {
    Object? syncError;
    try {
      if (force) {
        if (IntervalsSession.instance.isConnected) {
          await _syncService.syncEventsHorizon();
        }
      } else {
        await _syncService.syncEventsHorizonIfStale();
      }
    } catch (e) {
      syncError = e;
    }
    await _load();
    if (mounted && syncError != null) {
      setState(() => _error = syncError.toString());
    }
  }

  Future<void> _load() async {
    try {
      final events = await _repository.getByCategories(
        editableEventCategories.toSet(),
        oldest: isoDate(DateTime.now().subtract(SyncService.eventsLookBack)),
      );
      if (!mounted) return;
      setState(() {
        _events = events;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _edit([LocalEvent? event]) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EventEditorScreen(event: event)),
    );
    await _load();
  }

  Future<void> _delete(LocalEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final name = event.name ?? eventCategoryLabel(l10n, event.category);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTooltip),
        content: Text(l10n.eventDeleteConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await IntervalsEventService().delete(event.id);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.couldNotDeleteWorkout('$error'))),
      );
      return;
    }
    AutoSyncService.instance.notifyCacheChanged();
    messenger.showSnackBar(SnackBar(content: Text(l10n.eventDeleted(name))));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = isoDate(DateTime.now());
    final upcoming = _events.where((e) => e.date.compareTo(today) >= 0);
    final past = _events.where((e) => e.date.compareTo(today) < 0);
    final connected = IntervalsSession.instance.isConnected;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsTitle)),
      floatingActionButton: connected
          ? FloatingActionButton(
              tooltip: l10n.eventAddTooltip,
              onPressed: _edit,
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => _refresh(force: true),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (_events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(child: Text(l10n.eventsEmpty)),
                    ),
                  if (upcoming.isNotEmpty) _header(l10n.eventsUpcoming),
                  for (final e in upcoming) _tile(l10n, e),
                  if (past.isNotEmpty) _header(l10n.eventsPast),
                  for (final e in past) _tile(l10n, e),
                ],
              ),
      ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  Widget _tile(AppLocalizations l10n, LocalEvent event) {
    final end = DateTime.tryParse(event.raw['end_date_local'] as String? ?? '');
    final range = end != null && isoDate(end).compareTo(event.date) > 0
        ? '${event.date} – ${isoDate(end)}'
        : event.date;
    return Card(
      child: ListTile(
        title: Text(
          event.name ?? eventCategoryLabel(l10n, event.category),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${eventCategoryLabel(l10n, event.category)} · $range'
          '${event.type != null ? ' · ${event.type}' : ''}',
        ),
        onTap: () => _edit(event),
        trailing: IconButton(
          tooltip: l10n.deleteTooltip,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _delete(event),
        ),
      ),
    );
  }
}
