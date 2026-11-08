import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/knowledge_library_repository.dart';
import '../../l10n/app_localizations.dart';

/// More → Knowledge library: the athlete's own imported coaching
/// documents, searched by the chat agent's `get_training_guidance` tool
/// alongside the bundled reference. Import/enable/disable/delete only —
/// nothing here is editable in place.
class KnowledgeLibraryScreen extends StatefulWidget {
  KnowledgeLibraryScreen({super.key, KnowledgeLibraryRepository? repository})
    : repository = repository ?? KnowledgeLibraryRepository();

  final KnowledgeLibraryRepository repository;

  @override
  State<KnowledgeLibraryScreen> createState() => _KnowledgeLibraryScreenState();
}

class _KnowledgeLibraryScreenState extends State<KnowledgeLibraryScreen> {
  static const _typeGroup = XTypeGroup(
    label: 'Markdown / text',
    extensions: ['md', 'markdown', 'txt'],
  );

  List<KnowledgeDocument>? _docs;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await widget.repository.list();
    if (!mounted) return;
    setState(() => _docs = docs);
  }

  Future<void> _import() async {
    final files = await openFiles(acceptedTypeGroups: const [_typeGroup]);
    if (files.isEmpty || !mounted) return;

    setState(() => _importing = true);
    for (final file in files) {
      if (!mounted) return;
      await _importOne(file);
    }
    if (!mounted) return;
    setState(() => _importing = false);
    await _load();
  }

  Future<void> _importOne(XFile file) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    KnowledgeDuplicateAction? duplicateAction;
    final existing = await widget.repository.findByFileName(file.name);
    if (existing != null) {
      if (!mounted) return;
      final action = await showDialog<KnowledgeDuplicateAction>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.knowledgeDuplicateTitle),
          content: Text(l10n.knowledgeDuplicateBody(file.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(KnowledgeDuplicateAction.keepBoth),
              child: Text(l10n.knowledgeKeepBothButton),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(KnowledgeDuplicateAction.replace),
              child: Text(l10n.knowledgeReplaceButton),
            ),
          ],
        ),
      );
      if (action == null) return;
      duplicateAction = action;
    }

    try {
      final bytes = await file.readAsBytes();
      final result = await widget.repository.import(
        fileName: file.name,
        bytes: bytes,
        duplicateAction: duplicateAction,
      );
      final parts = [
        l10n.knowledgeImportSuccess(result.document.sectionCount),
        if (result.ignoredBlocks > 0)
          l10n.knowledgeImportIgnoredBlocks(result.ignoredBlocks),
      ];
      messenger.showSnackBar(SnackBar(content: Text(parts.join(' · '))));
    } on KnowledgeRejectedImport catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.knowledgeImportRejected(file.name, '$error')),
        ),
      );
    }
  }

  Future<void> _setEnabled(KnowledgeDocument doc, bool enabled) async {
    await widget.repository.setEnabled(doc.id, enabled);
    await _load();
  }

  Future<void> _delete(KnowledgeDocument doc) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.knowledgeDeleteTitle),
        content: Text(l10n.knowledgeDeleteConfirm(doc.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.delete(doc.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final docs = _docs;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.knowledgeLibraryTitle),
        actions: [
          IconButton(
            key: const ValueKey('knowledge-import-appbar-button'),
            tooltip: l10n.knowledgeImportButton,
            icon: _importing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.upload_file_outlined),
            onPressed: _importing ? null : _import,
          ),
        ],
      ),
      body: docs == null
          ? const Center(child: CircularProgressIndicator())
          : docs.isEmpty
          ? _EmptyState(onImport: _importing ? null : _import)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocumentTile(
                    document: doc,
                    onEnabledChanged: (value) => _setEnabled(doc, value),
                    onDelete: () => _delete(doc),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onImport});

  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.knowledgeEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.knowledgeEmptyBody,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.knowledgeImportButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.onEnabledChanged,
    required this.onDelete,
  });

  final KnowledgeDocument document;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final date = MaterialLocalizations.of(
      context,
    ).formatShortDate(document.importedAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    document.fileName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.knowledgeSectionCount(document.sectionCount)} '
                    '· ${l10n.knowledgeImportedOn(date)}'
                    '${document.enabled ? '' : ' · ${l10n.knowledgeDisabledLabel}'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: document.enabled, onChanged: onEnabledChanged),
            IconButton(
              tooltip: l10n.deleteButton,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
