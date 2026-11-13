import 'package:flutter/material.dart';

import '../../evaluation/readiness.dart';
import '../../evaluation/readiness_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chart_options.dart';
import 'readiness_card.dart';

/// Which readiness signals count — opened by a long press on the readiness
/// card on Today, or from the options icon on the readiness screen. The
/// choice is stored on the device and applies to the score, the status, the
/// morning briefing and the trainer alike. Below the signals, the HRV /
/// resting-HR smoothing window (3 or 5 days; [defaultSmoothingDays] is what
/// the training knowledge says while the athlete hasn't picked one).
Future<void> showReadinessOptions(
  BuildContext context, {
  ReadinessSettings? settings,
  int defaultSmoothingDays = 3,
}) {
  final l10n = AppLocalizations.of(context)!;
  final store = settings ?? ReadinessSettings.instance;
  String describe(ReadinessSignalKind k) => switch (k) {
    ReadinessSignalKind.hrv => l10n.readinessOptionHrv,
    ReadinessSignalKind.restingHr => l10n.readinessOptionRestingHr,
    ReadinessSignalKind.sleep => l10n.readinessOptionSleep,
    ReadinessSignalKind.form => l10n.readinessOptionForm,
    ReadinessSignalKind.subjective => l10n.readinessOptionSubjective,
    ReadinessSignalKind.load => l10n.readinessOptionLoad,
    ReadinessSignalKind.device => l10n.readinessOptionDevice,
  };

  return showChartOptions(
    context,
    title: l10n.readinessOptionsTitle,
    ownerSetState: (change) => change(),
    builder: (sheet, apply) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.readinessOptionsHint,
          style: Theme.of(sheet).textTheme.bodySmall?.copyWith(
            color: Theme.of(sheet).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final kind in ReadinessSignalKind.values)
          CheckboxListTile(
            key: ValueKey('readiness-option-${kind.name}'),
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(readinessSignalLabel(l10n, kind)),
            subtitle: Text(describe(kind)),
            value: store.isEnabled(kind),
            // The last signal that counts can't be switched off.
            onChanged: !store.isEnabled(kind) || store.enabled.length > 1
                ? (on) async {
                    await store.setEnabled(kind, on ?? false);
                    apply(() {});
                  }
                : null,
          ),
        const SizedBox(height: 12),
        Text(
          l10n.readinessSmoothingTitle,
          style: Theme.of(sheet).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.readinessSmoothingHint,
          style: Theme.of(sheet).textTheme.bodySmall?.copyWith(
            color: Theme.of(sheet).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          key: const ValueKey('readiness-smoothing'),
          segments: [
            for (final days in ReadinessSettings.smoothingChoices)
              ButtonSegment(
                value: days,
                label: Text(l10n.readinessSmoothingDays(days)),
              ),
          ],
          selected: {store.smoothingDays ?? defaultSmoothingDays},
          onSelectionChanged: (picked) async {
            await store.setSmoothingDays(picked.single);
            apply(() {});
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async {
              await store.reset();
              apply(() {});
            },
            child: Text(l10n.readinessOptionsReset),
          ),
        ),
      ],
    ),
  );
}
