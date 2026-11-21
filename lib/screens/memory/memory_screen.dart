import 'package:flutter/material.dart';

import '../../agent/agent_memory.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/shell_tab.dart';

/// More → Trainer memory: everything the trainer remembers across chats,
/// with add and remove. Nothing is remembered that isn't listed here.
class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key, this.store});

  final AgentMemoryStore? store;

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late final _store = widget.store ?? AgentMemoryStore.instance;
  final _input = TextEditingController();
  List<MemoryItem> _items = const [];
  bool _loaded = false;
  bool _enabled = true;
  TrainerTone _tone = TrainerTone.balanced;
  CheckInCadence _cadence = CheckInCadence.onRequest;
  final _style = TrainerStyle.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    _store.removeListener(_reload);
    _input.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final items = await _store.load();
    final enabled = await _store.isEnabled();
    final tone = await _style.tone();
    final cadence = await _style.cadence();
    if (mounted) {
      setState(() {
        _items = items;
        _enabled = enabled;
        _tone = tone;
        _cadence = cadence;
        _loaded = true;
      });
    }
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _store.add(_input.text);
      _input.clear();
    } on MemoryFullException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.memoryFull(AgentMemoryStore.maxItems))),
      );
    }
  }

  Future<void> _edit(MemoryItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: item.text);
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memoryEdit),
        content: TextField(
          key: const ValueKey('memory-edit-input'),
          controller: controller,
          maxLength: AgentMemoryStore.maxLength,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('memory-edit-save'),
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text != null) await _store.edit(item.id, text);
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.memoryClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const ValueKey('memory-clear-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.memoryClear),
          ),
        ],
      ),
    );
    if (ok == true) await _store.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memoryTitle),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              key: const ValueKey('memory-clear'),
              tooltip: l10n.memoryClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _clear,
            ),
          ...shellTabActions(context),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.memoryIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Card(
            key: const ValueKey('memory-care-note'),
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 20,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.memoryCareNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const ValueKey('memory-enabled'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.memoryUseTitle),
            subtitle: Text(l10n.memoryUseSubtitle),
            value: _enabled,
            onChanged: (v) async {
              await _store.setEnabled(v);
              _reload();
            },
          ),
          const SizedBox(height: 8),
          Text(l10n.trainerToneTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final t in TrainerTone.values)
                ChoiceChip(
                  key: ValueKey('tone-${t.name}'),
                  label: Text(_toneLabel(l10n, t)),
                  selected: _tone == t,
                  onSelected: (_) async {
                    await _style.setTone(t);
                    _reload();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.trainerCadenceTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final c in CheckInCadence.values)
                ChoiceChip(
                  key: ValueKey('cadence-${c.name}'),
                  label: Text(_cadenceLabel(l10n, c)),
                  selected: _cadence == c,
                  onSelected: (_) async {
                    await _style.setCadence(c);
                    _reload();
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('memory-input'),
                  controller: _input,
                  maxLength: AgentMemoryStore.maxLength,
                  decoration: InputDecoration(hintText: l10n.memoryAddHint),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('memory-add'),
                onPressed: _add,
                child: Text(l10n.memoryAddButton),
              ),
            ],
          ),
          if (_items.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.memoryCount(_items.length, AgentMemoryStore.maxItems),
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          if (_loaded && _items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.memoryEmpty)),
            ),
          for (final item in _items)
            Card(
              key: ValueKey('memory-${item.id}'),
              child: ListTile(
                title: Text(item.text),
                subtitle: item.fromAgent ? Text(l10n.memoryFromTrainer) : null,
                onTap: () => _edit(item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: ValueKey('memory-edit-${item.id}'),
                      tooltip: l10n.memoryEdit,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _edit(item),
                    ),
                    IconButton(
                      tooltip: l10n.memoryDelete,
                      icon: const Icon(Icons.close),
                      onPressed: () => _store.remove(item.id),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _toneLabel(AppLocalizations l, TrainerTone t) => switch (t) {
  TrainerTone.balanced => l.toneBalanced,
  TrainerTone.direct => l.toneDirect,
  TrainerTone.encouraging => l.toneEncouraging,
  TrainerTone.analytical => l.toneAnalytical,
};

String _cadenceLabel(AppLocalizations l, CheckInCadence c) => switch (c) {
  CheckInCadence.onRequest => l.cadenceOnRequest,
  CheckInCadence.weekly => l.cadenceWeekly,
  CheckInCadence.afterSessions => l.cadenceAfterSessions,
};
