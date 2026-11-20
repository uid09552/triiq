import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/more/more_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/statistics/insight_previews.dart' show insightDescription;
import '../screens/statistics/insights_grid.dart';
import '../widgets/main_navigation.dart';
import 'app_search.dart';
import 'nav_items.dart';
import 'navigation_layout.dart';
import 'okf_index.dart';

typedef L10nText = String Function(AppLocalizations l10n);

/// A place in the app the search and the trainer can send the athlete to.
///
/// This registry is the source of truth for *navigation*: the id, how to
/// get there, the localized title and breadcrumb. What a destination *is*
/// comes from `docs/okf.md` through [okfAnchor] (see [OkfIndex] for the
/// anchor syntax) — the same text the agent quotes, and what the search
/// matches beyond titles and keywords. `test/navigation/app_destinations_test.dart`
/// fails when an anchor points at nothing, or when an Insights tile, More
/// entry or Settings group/section is missing here.
class AppDestination {
  const AppDestination({
    required this.id,
    required this.icon,
    required this.title,
    required this.okfAnchor,
    required this.open,
    this.parents = const [],
    this.description,
    this.keywords = const [],
  });

  final String id;
  final IconData icon;
  final L10nText title;

  /// The breadcrumb above this destination, outermost first.
  final List<L10nText> parents;

  /// One line on what it is; null falls back to the okf passage's start.
  final L10nText? description;

  /// Synonyms in English and German (lowercase) besides the title.
  final List<String> keywords;

  /// Where `docs/okf.md` describes it.
  final String okfAnchor;

  /// Takes the athlete there. Only ever called from a tap.
  final void Function(BuildContext context) open;

  /// "Settings › App › Notifications". A parent that resolves to an empty
  /// string (a tab that is in the bottom bar right now) is left out.
  String path(AppLocalizations l10n) => [
    for (final p in parents)
      if (p(l10n) case final s when s.isNotEmpty) s,
    title(l10n),
  ].join(' › ');

  /// The one-line description, from l10n or else the okf passage.
  String describe(AppLocalizations l10n, OkfIndex? okf) {
    final own = description?.call(l10n) ?? '';
    if (own.isNotEmpty || okf == null) return own;
    return OkfIndex.trimToSentence(
      OkfIndex.userText(okf.resolve(okfAnchor) ?? ''),
      140,
    );
  }
}

void _push(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));

String _settings(AppLocalizations l) => l.titleSettings;
String _insights(AppLocalizations l) => l.navStatistics;

/// "More" while [id] lives in More, nothing while it is in the bottom bar —
/// the athlete arranges the two (`NavigationLayout`).
L10nText _whereIs(String id) =>
    (l) => NavigationLayout.instance.isInBar(id) ? '' : l.navMore;

const _tabKeywords = <String, List<String>>{
  MainNavigation.todayTab: [
    'home',
    'dashboard',
    'readiness',
    'today',
    'session',
    'heute',
    'startseite',
    'bereitschaft',
    'einheit',
  ],
  MainNavigation.calendarTab: [
    'calendar',
    'schedule',
    'month',
    'week',
    'planned',
    'move session',
    'kalender',
    'woche',
    'monat',
    'geplant',
    'verschieben',
  ],
  MainNavigation.chatTab: [
    'trainer',
    'coach',
    'ai',
    'ask',
    'assistant',
    'question',
    'ki',
    'fragen',
    'assistent',
  ],
  MainNavigation.insightsTab: [
    'statistics',
    'stats',
    'charts',
    'analysis',
    'volume',
    'statistik',
    'diagramme',
    'auswertung',
    'umfang',
  ],
  MainNavigation.moreTab: ['menu', 'more', 'mehr', 'menü'],
};

/// Per Insights tile: okf anchor and synonyms.
const _insightsMeta = <String, (String, List<String>)>{
  'analytics': (
    'status:Training analytics',
    [
      'ctl',
      'atl',
      'tsb',
      'form',
      'fitness',
      'fatigue',
      'ramp',
      'load',
      'pmc',
      'fitness',
      'ermudung',
      'belastung',
      'rampe',
    ],
  ),
  'explorer': (
    'Analysis',
    ['metric', 'explorer', 'chart', 'analysis', 'metrik', 'analyse'],
  ),
  'heatmap': (
    'status:Load heatmap',
    [
      'heatmap',
      'daily load',
      'streak',
      'tss',
      'grid',
      'raster',
      'tagesbelastung',
      'serie',
    ],
  ),
  'curves': (
    'Statistics#Performance',
    [
      'power curve',
      'pace curve',
      'ftp',
      'critical power',
      'threshold',
      'faster',
      'mmp',
      'leistungskurve',
      'schwelle',
      'schneller',
      'pace',
      'threshold suggestion',
      'schwellenvorschlag',
    ],
  ),
  'best-efforts': (
    'status:Best efforts',
    ['pr', 'personal best', 'record', 'rekord', 'bestzeit', 'bestwert'],
  ),
  'durability': (
    'status:Durability',
    [
      'fatigue resistance',
      'kj',
      'long ride',
      'stamina',
      'decay',
      'durability',
      'ausdauer',
      'belastbarkeit',
      'lange ausfahrt',
    ],
  ),
  'wellness': (
    'status:Wellness trends',
    [
      'hrv',
      'resting hr',
      'heart rate',
      'sleep',
      'weight',
      'ruhepuls',
      'schlaf',
      'gewicht',
      'herzfrequenz',
    ],
  ),
  'compare': (
    'status:Compare',
    ['versus', 'vs', 'side by side', 'block', 'vergleich', 'nebeneinander'],
  ),
  'weekly-review': (
    'More#Weekly review',
    [
      'week',
      'review',
      'summary',
      'missed',
      '80/20',
      'woche',
      'zusammenfassung',
      'verpasst',
      'ruckblick',
    ],
  ),
  'activities': (
    'Activities',
    [
      'sessions',
      'workouts',
      'history',
      'list',
      'rides',
      'runs',
      'swims',
      'einheiten',
      'verlauf',
      'liste',
      'fahrten',
      'laufe',
    ],
  ),
};

/// Per More entry: okf anchor and synonyms.
const _moreMeta = <String, (String, List<String>)>{
  'plan': (
    'Training plan',
    [
      'plan',
      'training plan',
      'goal',
      'load curve',
      'taper',
      'generate',
      'trainingsplan',
      'ziel',
      'belastungskurve',
      'erstellen',
    ],
  ),
  'season': (
    'status:Season',
    [
      'forecast',
      'race',
      'race predictor',
      'illness',
      'injury',
      'brick',
      'prognose',
      'wettkampf',
      'rennen',
      'krankheit',
      'verletzung',
      'koppeltraining',
      'vorhersage',
    ],
  ),
  'events': (
    'Events',
    [
      'race',
      'note',
      'holiday',
      'event',
      'wettkampf',
      'notiz',
      'urlaub',
      'ereignis',
    ],
  ),
  'memory': (
    'Trainer memory and backup#Trainer memory',
    [
      'memory',
      'remember',
      'preference',
      'forget',
      'gedachtnis',
      'merken',
      'vorlieben',
      'vergessen',
    ],
  ),
  'knowledge': (
    'More#Knowledge library',
    [
      'import',
      'documents',
      'markdown',
      'library',
      'reference',
      'dokumente',
      'bibliothek',
      'wissen',
    ],
  ),
  'sync': (
    'Sync',
    [
      'sync',
      'download',
      'history',
      'fetch',
      'refresh',
      'synchronisieren',
      'herunterladen',
      'abrufen',
    ],
  ),
  'info': (
    'About / Info and the SBOM',
    [
      'info',
      'about',
      'version',
      'build',
      'sbom',
      'bill of materials',
      'licenses',
      'licences',
      'open source',
      'dependencies',
      'packages',
      'release',
      'bug report',
      'ueber',
      'lizenzen',
      'stueckliste',
      'softwarestueckliste',
      'abhaengigkeiten',
      'fehlerbericht',
      'versionsnummer',
    ],
  ),
};

String _sectionAnchor(SettingsSection s) => switch (s) {
  SettingsSection.appearance => 'status:Appearance',
  SettingsSection.language => 'Settings#Language',
  SettingsSection.notifications => 'Settings#Notifications',
  SettingsSection.sync => 'Settings#Sync',
  SettingsSection.calendar => 'Settings#Calendar',
  SettingsSection.backup => 'status:Backup',
  SettingsSection.feel => 'Settings#Fatigue & soreness',
  SettingsSection.weeklyTargets => 'Settings#Weekly targets',
  SettingsSection.yearGoals => 'Year goals',
  SettingsSection.privacy => 'status:Consent & your rights',
  SettingsSection.ai => 'Settings#Models',
  SettingsSection.navigation => 'Arrange the menu',
  SettingsSection.homeWidget => 'Settings#Home-screen widget',
};

String _sectionDescription(AppLocalizations l, SettingsSection s) =>
    switch (s) {
      SettingsSection.appearance => l.searchDescAppearance,
      SettingsSection.language => l.searchDescLanguage,
      SettingsSection.notifications => l.searchDescNotifications,
      SettingsSection.sync => l.searchDescSync,
      SettingsSection.calendar => l.searchDescCalendarSettings,
      SettingsSection.backup => l.searchDescBackup,
      SettingsSection.feel => l.searchDescFeel,
      SettingsSection.weeklyTargets => l.searchDescWeeklyTargets,
      SettingsSection.yearGoals => l.searchDescYearGoals,
      SettingsSection.privacy => l.pvSubtitle,
      SettingsSection.ai => l.searchDescAi,
      SettingsSection.navigation => l.searchDescNavigation,
      SettingsSection.homeWidget => l.searchDescHomeWidget,
    };

AppDestination _tab(
  String tab,
  String id,
  IconData icon,
  L10nText title,
  L10nText description,
  String anchor,
) => AppDestination(
  id: id,
  icon: icon,
  title: title,
  description: description,
  parents: [_whereIs(tab)],
  keywords: _tabKeywords[tab]!,
  okfAnchor: anchor,
  open: (context) => openNavItem(context, tab),
);

AppDestination _notification(
  String id,
  IconData icon,
  L10nText title,
  L10nText description,
  String anchor,
  List<String> keywords,
) => AppDestination(
  id: id,
  icon: icon,
  title: title,
  description: description,
  parents: [
    _settings,
    SettingsGroup.app.title,
    SettingsSection.notifications.title,
  ],
  keywords: keywords,
  okfAnchor: anchor,
  open: (context) =>
      openSettingsSection(context, SettingsSection.notifications),
);

/// Every destination, in the order results tie-break in.
final List<AppDestination> appDestinations = [
  _tab(
    MainNavigation.todayTab,
    'tab.today',
    Icons.today_outlined,
    (l) => l.navToday,
    (l) => l.searchDescToday,
    'Today',
  ),
  _tab(
    MainNavigation.calendarTab,
    'tab.calendar',
    Icons.calendar_month_outlined,
    (l) => l.navCalendar,
    (l) => l.searchDescCalendar,
    'Calendar',
  ),
  _tab(
    MainNavigation.chatTab,
    'tab.chat',
    Icons.chat_bubble_outline,
    (l) => l.navChat,
    (l) => l.searchDescChat,
    'Chat',
  ),
  _tab(
    MainNavigation.insightsTab,
    'tab.insights',
    Icons.bar_chart_outlined,
    (l) => l.navStatistics,
    (l) => l.searchDescInsights,
    'Statistics',
  ),
  _tab(
    MainNavigation.moreTab,
    'tab.more',
    Icons.more_horiz,
    (l) => l.navMore,
    (l) => l.searchDescMore,
    'More',
  ),
  for (final d in insightsDestinations)
    AppDestination(
      id: 'insights.${d.id}',
      icon: d.icon,
      title: d.label,
      description: (l) => insightDescription(l, d.id),
      parents: const [_insights],
      keywords: _insightsMeta[d.id]?.$2 ?? const [],
      okfAnchor: _insightsMeta[d.id]?.$1 ?? 'Statistics',
      open: (context) => _push(context, d.builder),
    ),
  for (final e in moreEntries)
    if (e.available)
      AppDestination(
        id: 'more.${e.id}',
        icon: e.icon,
        title: e.title,
        description: e.subtitle,
        parents: [_whereIs(e.id)],
        keywords: _moreMeta[e.id]?.$2 ?? const [],
        okfAnchor: _moreMeta[e.id]?.$1 ?? 'More',
        open: (context) => openNavItem(context, e.id),
      ),
  AppDestination(
    id: 'profile',
    icon: Icons.account_circle_outlined,
    title: (l) => l.titleProfile,
    description: (l) => l.searchDescProfile,
    keywords: const [
      'account',
      'intervals',
      'intervals icu',
      'connect',
      'disconnect',
      'login',
      'log in',
      'api key',
      'avatar',
      'konto',
      'verbinden',
      'trennen',
      'anmelden',
      'schlussel',
    ],
    okfAnchor: 'Connecting your Intervals.icu account',
    open: (context) => _push(context, (_) => const ProfileScreen()),
  ),
  AppDestination(
    id: 'settings',
    icon: Icons.settings_outlined,
    title: _settings,
    description: (l) => l.searchDescSettings,
    keywords: const [
      'settings',
      'preferences',
      'options',
      'einstellungen',
      'optionen',
    ],
    okfAnchor: 'status:Settings hub',
    open: (context) => _push(context, (_) => const SettingsScreen()),
  ),
  for (final g in SettingsGroup.values)
    AppDestination(
      id: 'settings.group.${g.name}',
      icon: g.icon,
      title: g.title,
      description: g.subtitle,
      parents: const [_settings],
      okfAnchor: 'status:Settings hub',
      open: (context) => _push(context, (_) => SettingsGroupScreen(group: g)),
    ),
  for (final s in SettingsSection.values)
    AppDestination(
      id: 'settings.${s.name}',
      icon: s.icon,
      title: s.title,
      description: (l) => _sectionDescription(l, s),
      parents: [_settings, s.group.title],
      keywords: s.keywords,
      okfAnchor: _sectionAnchor(s),
      open: (context) => openSettingsSection(context, s),
    ),
  _notification(
    'settings.notifications.daily-reminder',
    Icons.alarm_outlined,
    (l) => l.dailyTrainingReminder,
    (l) => l.searchDescDailyReminder,
    'Settings#Notifications',
    const ['reminder', 'daily', 'alarm', 'erinnerung', 'taglich', 'wecker'],
  ),
  _notification(
    'settings.notifications.morning-briefing',
    Icons.wb_sunny_outlined,
    (l) => l.morningBriefing,
    (l) => l.searchDescMorningBriefing,
    'Fatigue early warning and morning briefing#Morning briefing',
    const ['morning', 'briefing', 'morgen', 'fruh'],
  ),
  _notification(
    'settings.notifications.weekly-review',
    Icons.fact_check_outlined,
    (l) => l.weeklyReviewNotification,
    (l) => l.searchDescWeeklyReviewNotification,
    'Fatigue early warning and morning briefing#Weekly review notification',
    const ['weekly', 'review', 'sunday', 'wochentlich', 'ruckblick', 'sonntag'],
  ),
];

/// [id]'s destination, or null for an id the registry doesn't have.
AppDestination? destinationById(String id, {List<AppDestination>? from}) {
  for (final d in from ?? appDestinations) {
    if (d.id == id) return d;
  }
  return null;
}

/// The search behind More's search field and `search_app_features`: every
/// destination ranked against [query], matching titles, breadcrumbs and
/// descriptions in English and German, the keywords, and — once loaded —
/// the okf passage. Best first; empty for a blank query or no match.
List<AppDestination> searchDestinations(
  String query, {
  List<AppDestination>? destinations,
  OkfIndex? okf,
  int limit = 20,
}) {
  if (query.trim().isEmpty) return const [];
  final all = destinations ?? appDestinations;
  final index = _DestinationIndex.of(all, okf);
  final scored = <(AppDestination, double, int)>[];
  for (var i = 0; i < all.length; i++) {
    final s = index.documents[i].score(query);
    if (s > 0) scored.add((all[i], s, i));
  }
  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    return byScore != 0 ? byScore : a.$3.compareTo(b.$3);
  });
  return [for (final r in scored.take(limit)) r.$1];
}

/// The search documents for one destination list and okf index, built
/// once (both languages' strings are looked up eagerly).
class _DestinationIndex {
  _DestinationIndex(this.destinations, this.okf)
    : documents = [
        for (final d in destinations)
          SearchDocument(
            titles: [for (final l in _languages) d.title(l)],
            keywords: d.keywords,
            path: [
              for (final l in _languages)
                for (final p in d.parents) p(l),
            ],
            descriptions: [
              for (final l in _languages) d.description?.call(l) ?? '',
            ],
            okfText: okf == null
                ? ''
                : OkfIndex.userText(okf.resolve(d.okfAnchor) ?? ''),
          ),
      ];

  final List<AppDestination> destinations;
  final OkfIndex? okf;
  final List<SearchDocument> documents;

  static final _languages = [
    lookupAppLocalizations(const Locale('en')),
    lookupAppLocalizations(const Locale('de')),
  ];

  static _DestinationIndex? _last;

  static _DestinationIndex of(List<AppDestination> all, OkfIndex? okf) {
    final last = _last;
    if (last != null &&
        identical(last.destinations, all) &&
        identical(last.okf, okf)) {
      return last;
    }
    return _last = _DestinationIndex(all, okf);
  }
}
