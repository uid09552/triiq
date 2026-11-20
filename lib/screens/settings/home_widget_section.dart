import 'package:flutter/material.dart';

import '../../data/home_widget_data.dart';
import '../../l10n/app_localizations.dart';
import 'home_widget_settings.dart';

/// Settings → Home-screen widget: which blocks the Android widget shows.
/// Changes are pushed to the widget at once.
class HomeWidgetSection extends StatelessWidget {
  HomeWidgetSection({super.key, HomeWidgetSettings? settings})
    : settings = settings ?? HomeWidgetSettings.instance;

  final HomeWidgetSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget toggle(
      String key,
      String label,
      bool value,
      Future<void> Function(bool) set,
    ) => SwitchListTile(
      key: ValueKey('home-widget-$key'),
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) async {
        await set(v);
        if (HomeWidgetUpdater.supported) {
          await HomeWidgetUpdater().update();
        }
      },
    );
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeWidgetHelp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          toggle(
            'sessions',
            l10n.homeWidgetSessions,
            settings.showSessions,
            settings.setShowSessions,
          ),
          toggle(
            'done',
            l10n.homeWidgetDone,
            settings.showDone,
            settings.setShowDone,
          ),
          toggle(
            'form',
            l10n.homeWidgetForm,
            settings.showForm,
            settings.setShowForm,
          ),
          toggle(
            'fitness',
            l10n.homeWidgetFitness,
            settings.showFitness,
            settings.setShowFitness,
          ),
          toggle(
            'rings',
            l10n.homeWidgetRings,
            settings.showRings,
            settings.setShowRings,
          ),
          toggle(
            'updated',
            l10n.homeWidgetUpdated,
            settings.showUpdated,
            settings.setShowUpdated,
          ),
        ],
      ),
    );
  }
}
