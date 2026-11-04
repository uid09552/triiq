// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navToday => 'Heute';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navChat => 'Chat';

  @override
  String get navStatistics => 'Statistik';

  @override
  String get navMore => 'Mehr';

  @override
  String get profileAndSettingsTooltip => 'Profil & Einstellungen';

  @override
  String get titleProfile => 'Profil';

  @override
  String get titleSettings => 'Einstellungen';

  @override
  String get titleSync => 'Synchronisierung';

  @override
  String get titleActivities => 'Aktivitäten';

  @override
  String get titleActivity => 'Aktivität';

  @override
  String get titleAthlete => 'Athlet';

  @override
  String get titlePlannedTraining => 'Geplantes Training';

  @override
  String get titleTrainNow => 'Jetzt trainieren';

  @override
  String get refreshTooltip => 'Aktualisieren';

  @override
  String get openSettingsButton => 'Einstellungen öffnen';

  @override
  String get openProfileButton => 'Profil öffnen';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get connectedLabel => 'Verbunden';

  @override
  String get syncedWithIntervals => 'Synchronisiert mit Intervals.icu';

  @override
  String get activityFallback => 'Aktivität';

  @override
  String get plannedSessionFallback => 'Geplante Einheit';

  @override
  String heroActivitiesStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aktivitäten heute protokolliert',
      one: '1 Aktivität heute protokolliert',
      zero: 'Bereit fürs Training',
    );
    return '$_temp0';
  }

  @override
  String get notConnectedToIntervals => 'Nicht mit Intervals.icu verbunden';

  @override
  String get noWorkoutLoggedToday => 'Heute noch kein Training protokolliert';

  @override
  String get finishSettingUp => 'Einrichtung abschließen';

  @override
  String get connectIntervalsPrompt =>
      'Verbinde dein Intervals.icu-Konto, um deine Trainingsdaten zu sehen.';

  @override
  String get setupLlmPrompt =>
      'Richte einen LLM-Anbieter (Claude oder Ollama) ein, um mit dem Trainingsassistenten zu chatten.';

  @override
  String get syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String get tssToday => 'TSS heute';

  @override
  String get tssWeek => 'TSS Woche';

  @override
  String get ctlLabel => 'CTL';

  @override
  String get atlLabel => 'ATL';

  @override
  String get todaysActivities => 'Heutige Aktivitäten';

  @override
  String get todaysTraining => 'Heutiges Training';

  @override
  String get tomorrowsTraining => 'Morgiges Training';

  @override
  String get nothingPlannedToday => 'Für heute nichts geplant — Ruhetag.';

  @override
  String get nothingPlannedTomorrow => 'Für morgen noch nichts geplant.';

  @override
  String get connectToSeePlan =>
      'Verbinde dein Intervals.icu-Konto, um deinen Plan zu sehen.';

  @override
  String get connectInProfile => 'Verbinde dein Intervals.icu-Konto im Profil';

  @override
  String get noTargetSet => 'Kein Ziel festgelegt';

  @override
  String get sportLabel => 'Sportart';

  @override
  String get sportRun => 'Laufen';

  @override
  String get sportRide => 'Rad';

  @override
  String get sportSwim => 'Schwimmen';

  @override
  String durationMinutes(int minutes) {
    return 'Dauer — $minutes Min.';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get intensityLabel => 'Intensität';

  @override
  String get intensityRecovery => 'Erholung';

  @override
  String get intensityEndurance => 'Ausdauer';

  @override
  String get intensityIntervals => 'Intervalle';

  @override
  String get addCustomInstructions => 'Eigene Anweisungen hinzufügen';

  @override
  String get customInstructionsLabel => 'Eigene Anweisungen';

  @override
  String get removeCustomInstructions => 'Eigene Anweisungen entfernen';

  @override
  String get customInstructionsHint =>
      'z. B. \"Lauf flach halten, ich will die Beine für ein Rennen am Samstag schonen\"';

  @override
  String trainNowEventTitle(String intensity, String sport) {
    return '$intensity $sport-Training';
  }

  @override
  String get llmNeededForProposal =>
      'Richte in den Einstellungen einen LLM-Anbieter ein, um einen Vorschlag zu erhalten.';

  @override
  String get proposeTraining => 'Training vorschlagen';

  @override
  String get askAgain => 'Erneut fragen';

  @override
  String get addToGoogleCalendar => 'Zu Google Kalender hinzufügen';

  @override
  String get couldNotOpenGoogleCalendar =>
      'Google Kalender konnte nicht geöffnet werden.';

  @override
  String get thinkingEllipsis => 'Denkt nach…';

  @override
  String toolFailedSuffix(String label) {
    return '$label — fehlgeschlagen';
  }

  @override
  String toolRunningGeneric(String name) {
    return '$name wird ausgeführt…';
  }

  @override
  String get trainNowToolChecking =>
      'Profil und zwischengespeicherte Daten werden geprüft…';

  @override
  String get trainNowToolDailyLoad =>
      'Tägliche Belastung und Wellness werden gelesen…';

  @override
  String get trainNowToolActivities => 'Letzte Aktivitäten werden gelesen…';

  @override
  String get trainNowToolPlanned => 'Geplante Einheiten werden gelesen…';

  @override
  String get trainNowToolSummary => 'Letzte 7 Tage werden zusammengefasst…';

  @override
  String get trainNowToolGuidance => 'Trainingsreferenz wird konsultiert…';

  @override
  String get trainNowToolSyncing => 'Synchronisierung mit Intervals.icu…';

  @override
  String get tssHistoryTitle => 'TSS — letzte 42 Tage';

  @override
  String get totalLabel => 'Gesamt';

  @override
  String get avgPerDay => 'Ø / Tag';

  @override
  String get avgPerWeek => 'Ø / Woche';

  @override
  String get dailyTss => 'Täglicher TSS';

  @override
  String get tapBarForDetails => 'Tippe auf einen Balken für Datum und Wert.';

  @override
  String selectedDayTss(String date, int tss) {
    return '$date · $tss TSS';
  }

  @override
  String get connectForAthleteDetails =>
      'Verbinde dein Intervals.icu-Konto im Profil, um deine Athletendetails zu sehen.';

  @override
  String athleteIdLine(String id) {
    return 'Athleten-ID $id · synchronisiert mit Intervals.icu';
  }

  @override
  String get bodyAndWellness => 'Körper & Wellness';

  @override
  String get noWellnessCached =>
      'Noch keine Wellness-Daten zwischengespeichert.';

  @override
  String get weightLabel => 'Gewicht';

  @override
  String get restingHrLabel => 'Ruhepuls';

  @override
  String get hrvLabel => 'HRV';

  @override
  String get thresholdsTitle => 'Schwellenwerte';

  @override
  String get noActivitiesForThresholds =>
      'Noch keine Aktivitäten zwischengespeichert, daher konnten keine sportartspezifischen Schwellenwerte gelesen werden.';

  @override
  String get thresholdPaceLabel => 'Schwellenpace';

  @override
  String get weightAsAnalysedLabel => 'Gewicht (bei Analyse)';

  @override
  String asOfDate(String date) {
    return 'Stand $date';
  }

  @override
  String get calendarMonth => 'Monat';

  @override
  String get calendarWeek => 'Woche';

  @override
  String get todayTooltip => 'Heute';

  @override
  String get noTrainingData => 'Keine Trainingsdaten';

  @override
  String get nothingPlannedOrLogged =>
      'An diesem Tag nichts geplant oder protokolliert.';

  @override
  String get plannedStatus => 'Geplant';

  @override
  String get completedStatus => 'Abgeschlossen';

  @override
  String get messageAgentHint => 'Nachricht an den Trainingsassistenten…';

  @override
  String get askAboutTraining =>
      'Frage nach deinem Training, Fortschritt oder Plan';

  @override
  String get pickLlmProviderToChat =>
      'Wähle einen LLM-Anbieter in den Einstellungen, um zu chatten';

  @override
  String get noReplyFromModel => 'Keine Antwort vom Modell erhalten.';

  @override
  String get chatToolChecking =>
      'Profil und zwischengespeicherte Daten werden geprüft…';

  @override
  String get chatToolDailyLoad =>
      'Tägliche Belastung und Wellness werden gelesen…';

  @override
  String get chatToolActivities => 'Aktivitäten werden gelesen…';

  @override
  String get chatToolPlanned => 'Geplante Einheiten werden gelesen…';

  @override
  String get chatToolSummary => 'Training wird zusammengefasst…';

  @override
  String get chatToolGuidance => 'Trainingsreferenz wird konsultiert…';

  @override
  String get chatToolSyncing => 'Synchronisierung mit Intervals.icu…';

  @override
  String get appearanceTitle => 'Erscheinungsbild';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String get appearanceDeveloper => 'Developer';

  @override
  String get performanceUpTooltip =>
      'Effizienter als dein jüngster Durchschnitt';

  @override
  String get performanceDownTooltip =>
      'Weniger effizient als dein jüngster Durchschnitt';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get notificationsTitle => 'Benachrichtigungen';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get notificationsSubtitle =>
      'Abschluss der Synchronisierung und Antworten des Trainingsassistenten';

  @override
  String get dailyTrainingReminder => 'Tägliche Trainingserinnerung';

  @override
  String get notificationPermissionDenied =>
      'Die Benachrichtigungsberechtigung wurde verweigert. Aktiviere sie für TriIQ in den Geräteeinstellungen, um dies einzuschalten.';

  @override
  String get reminderNeedsBackground =>
      'Die tägliche Erinnerung erfordert, dass die App im Hintergrund erreichbar bleibt — das ist auf dieser Plattform nicht verfügbar.';

  @override
  String get syncSectionTitle => 'Synchronisierung';

  @override
  String get autoSyncDescription =>
      'Diesen Monat automatisch aktualisieren, solange die App geöffnet ist, höchstens so oft wie:';

  @override
  String autoSyncMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String autoSyncHours(int hours) {
    return '$hours Std.';
  }

  @override
  String get backgroundSyncTitle => 'Nächtliche Hintergrund-Synchronisierung';

  @override
  String get backgroundSyncDescription =>
      'Aktualisiert die aktuelle Woche über Nacht, auch wenn die App geschlossen ist. Läuft etwa einmal täglich, nur mit Netzwerkverbindung und wenn der Akku nicht schwach ist.';

  @override
  String get backgroundSyncNoRun => 'Noch kein Hintergrundlauf.';

  @override
  String backgroundSyncLastRun(String when, String result) {
    return 'Letzter Lauf: $when – $result';
  }

  @override
  String get backgroundResultSuccess => 'synchronisiert';

  @override
  String get backgroundResultSkippedFresh =>
      'übersprungen, Daten waren aktuell';

  @override
  String get backgroundResultAuthRejected =>
      'Schlüssel abgelehnt, im Profil neu verbinden';

  @override
  String get backgroundResultFailed => 'fehlgeschlagen, neuer Versuch morgen';

  @override
  String get backgroundResultNotConnected => 'nicht verbunden';

  @override
  String get backgroundSyncUnsupported =>
      'Hintergrund-Synchronisierung ist auf dieser Plattform nicht verfügbar. Die Daten werden aktualisiert, solange die App geöffnet ist.';

  @override
  String get llmProviderTitle => 'LLM-Anbieter';

  @override
  String get claudeLabel => 'Claude';

  @override
  String get ollamaLabel => 'Ollama';

  @override
  String get claudeApiKeyLabel => 'Claude-API-Schlüssel';

  @override
  String get claudeKeyStoredHint =>
      'Ein Schlüssel ist gespeichert — gib einen neuen ein, um ihn zu ersetzen';

  @override
  String get showTooltip => 'Anzeigen';

  @override
  String get hideTooltip => 'Verbergen';

  @override
  String get saveKeyButton => 'Schlüssel speichern';

  @override
  String get clearButton => 'Löschen';

  @override
  String get claudeModelLabel => 'Claude-Modell';

  @override
  String get claudeKeySecureHelp =>
      'Der Schlüssel wird im Anmeldeinformationsspeicher deines Betriebssystems gespeichert und nur an Anthropic gesendet. Die Nutzung wird deinem eigenen Anthropic-Konto in Rechnung gestellt.';

  @override
  String get claudeKeyInsecureHelp =>
      'Dieser Build kann den Schlüssel nicht sicher speichern, daher wird er nur für diese Sitzung vorgehalten und du musst ihn nach einem Neuladen erneut eingeben.';

  @override
  String get ollamaServerUrlLabel => 'Ollama-Server-URL';

  @override
  String get ollamaCloudApiKeyLabel => 'Ollama-Cloud-API-Schlüssel';

  @override
  String get ollamaApiKeyOptionalLabel => 'Ollama-API-Schlüssel (optional)';

  @override
  String get ollamaKeyStoredHint =>
      'Ein Schlüssel ist gespeichert — gib einen neuen ein, um ihn zu ersetzen';

  @override
  String get getAKeyButton => 'Schlüssel holen';

  @override
  String get testConnectionButton => 'Verbindung testen';

  @override
  String get ollamaModelLabel => 'Ollama-Modell';

  @override
  String get ollamaKeySecureHelp =>
      'Der Schlüssel wird im Anmeldeinformationsspeicher deines Betriebssystems gespeichert und nur an Ollama Cloud gesendet.';

  @override
  String get ollamaKeyInsecureHelp =>
      'Dieser Build kann den Schlüssel nicht sicher speichern, daher wird er nur für diese Sitzung vorgehalten und du musst ihn nach einem Neuladen erneut eingeben.';

  @override
  String get ollamaLocalHelp =>
      'Nichts verlässt dein Netzwerk. Das Modell muss Tool-Aufrufe unterstützen — sonst kann der Assistent deine Trainingsdaten nicht lesen.';

  @override
  String get claudeKeySavedMessage => 'Claude-API-Schlüssel gespeichert.';

  @override
  String get claudeKeyRemovedMessage => 'Claude-API-Schlüssel entfernt.';

  @override
  String get ollamaKeyRemovedMessage => 'Ollama-API-Schlüssel entfernt.';

  @override
  String couldNotOpenUrl(String url) {
    return '$url konnte nicht geöffnet werden';
  }

  @override
  String get ollamaKeySavedPrefix => 'Ollama-API-Schlüssel gespeichert';

  @override
  String get connectedPrefix => 'Verbunden';

  @override
  String connectedModelsMessage(String prefix, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Modelle verfügbar.',
      one: '1 Modell verfügbar.',
      zero:
          'verbunden, aber auf diesem Server sind noch keine Modelle verfügbar.',
    );
    return '$prefix — $_temp0';
  }

  @override
  String couldNotConnectKeyNotSaved(String error) {
    return 'Verbindung fehlgeschlagen: $error. Schlüssel nicht gespeichert.';
  }

  @override
  String couldNotConnect(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get profileHeaderChecking => 'Gespeicherte Verbindung wird geprüft…';

  @override
  String get intervalsConnectionTitle => 'Intervals.icu-Verbindung';

  @override
  String get checkingForSavedKey => 'Suche nach gespeichertem API-Schlüssel…';

  @override
  String get disconnectButton => 'Trennen';

  @override
  String get apiKeyHelpSecure =>
      'Deinen API-Schlüssel findest du unter Einstellungen auf intervals.icu. Er wird im sicheren Anmeldeinformationsspeicher dieses Geräts aufbewahrt.';

  @override
  String get apiKeyHelpInsecure =>
      'Deinen API-Schlüssel findest du unter Einstellungen auf intervals.icu. Im Browser wird er nur für diesen Tab vorgehalten — Browser haben keinen sicheren Speicherort dafür, daher musst du ihn nach einem Neuladen erneut eingeben.';

  @override
  String get intervalsApiKeyLabel => 'Intervals.icu-API-Schlüssel';

  @override
  String get connectButton => 'Verbinden';

  @override
  String couldNotConnectGeneric(String error) {
    return 'Verbindung fehlgeschlagen: $error';
  }

  @override
  String get moreSyncSubtitle => 'Trainingsdaten von Intervals.icu abrufen';

  @override
  String get moreActivitiesSubtitle => 'Alle zwischengespeicherten Aktivitäten';

  @override
  String get trainingPlansTitle => 'Trainingspläne';

  @override
  String get moreKnowledgeSubtitle =>
      'Deine eigenen Trainingsunterlagen, die der Assistent durchsuchen kann';

  @override
  String get gearTitle => 'Ausrüstung';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get knowledgeLibraryTitle => 'Wissensbibliothek';

  @override
  String get knowledgeImportButton => 'Importieren';

  @override
  String get knowledgeEmptyTitle => 'Noch keine Dokumente';

  @override
  String get knowledgeEmptyBody =>
      'Importiere Markdown- oder Textdateien mit deinen eigenen Trainingsnotizen, Schwimm-Sätzen oder Taper-Leitfäden. Der Chat-Assistent durchsucht sie zusätzlich zur eingebauten Referenz — sie ändern nie deinen Trainingsplan.';

  @override
  String knowledgeSectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abschnitte',
      one: '1 Abschnitt',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportedOn(String date) {
    return 'Importiert am $date';
  }

  @override
  String get knowledgeDisabledLabel => 'Deaktiviert';

  @override
  String get knowledgeDeleteTitle => 'Dieses Dokument löschen?';

  @override
  String knowledgeDeleteConfirm(String title) {
    return '„$title“ und seine Abschnitte werden von diesem Gerät entfernt.';
  }

  @override
  String get knowledgeDuplicateTitle => 'Bereits importiert';

  @override
  String knowledgeDuplicateBody(String fileName) {
    return 'Ein Dokument namens „$fileName“ existiert bereits.';
  }

  @override
  String get knowledgeReplaceButton => 'Ersetzen';

  @override
  String get knowledgeKeepBothButton => 'Beide behalten';

  @override
  String knowledgeImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abschnitte importiert',
      one: '1 Abschnitt importiert',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportIgnoredBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count strukturierte Blöcke ignoriert',
      one: '1 strukturierter Block ignoriert',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportRejected(String fileName, String reason) {
    return '$fileName konnte nicht importiert werden: $reason';
  }

  @override
  String get syncNotConnectedTitle => 'Nicht verbunden';

  @override
  String get syncNotConnectedBody =>
      'Verbinde dein Intervals.icu-Konto im Profil, bevor du synchronisierst.';

  @override
  String get localCacheTitle => 'Lokaler Zwischenspeicher';

  @override
  String localCacheBody(String oldest, String newest, String lastSynced) {
    return 'Aktivitäten zwischengespeichert von $oldest bis $newest\nZuletzt synchronisiert $lastSynced';
  }

  @override
  String syncedMessage(int activities, int wellness) {
    return '$activities Aktivitäten synchronisiert, $wellness Wellness-Datensätze.';
  }

  @override
  String syncFailedMessage(String error) {
    return 'Synchronisierung fehlgeschlagen: $error';
  }

  @override
  String get syncScopeToday => 'Heute';

  @override
  String get syncScopeMonth => 'Dieser Monat';

  @override
  String get syncScopeYear => 'Dieses Jahr';

  @override
  String get syncScopeAll => 'Alles (Erstsynchronisierung)';

  @override
  String get noActivitiesCachedConnected =>
      'Noch keine Aktivitäten zwischengespeichert — versuche Synchronisierung unter Mehr.';

  @override
  String get noActivitiesCachedDisconnected =>
      'Verbinde dein Intervals.icu-Konto, um deine Aktivitäten zu sehen.';

  @override
  String noActivitiesOfType(String sport) {
    return 'Keine $sport-Aktivitäten gespeichert — synchronisiere unter Mehr.';
  }

  @override
  String get showAllActivities => 'Alle Aktivitäten anzeigen';

  @override
  String get tssSuffix => 'TSS';

  @override
  String get openInIntervals => 'In Intervals.icu öffnen';

  @override
  String get timeInZone => 'Zeit in Zone';

  @override
  String get distanceLabel => 'Distanz';

  @override
  String get durationLabel => 'Dauer';

  @override
  String get elevationGainLabel => 'Höhenmeter';

  @override
  String get avgHrLabel => 'Ø Puls';

  @override
  String get maxHrLabel => 'Max. Puls';

  @override
  String get avgPowerNpLabel => 'Ø Leistung (NP)';

  @override
  String get avgPowerLabel => 'Ø Leistung';

  @override
  String get caloriesLabel => 'Kalorien';

  @override
  String get plannedTssLabel => 'Geplanter TSS';

  @override
  String get locationLabel => 'Ort';

  @override
  String get indoorLabel => 'Indoor';

  @override
  String get workoutTitle => 'Workout';

  @override
  String get statsNotConnected => 'Nicht mit Intervals.icu verbunden';

  @override
  String get volumeTitle => 'Umfang';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String rangeDaysShort(int days) {
    return '$days T';
  }

  @override
  String get rangeOneYear => '1 J';

  @override
  String get noDataCachedForRange =>
      'Für diesen Zeitraum sind noch keine Daten gespeichert.';

  @override
  String selectedDayValue(String date, String value) {
    return '$date: $value';
  }

  @override
  String get tapChartForDay =>
      'Für einen einzelnen Tag auf das Diagramm tippen.';

  @override
  String get currentLabel => 'Aktuell';

  @override
  String get changeLabel => 'Änderung';

  @override
  String get avgLabel => 'Durchschnitt';

  @override
  String get rangeLabel => 'Tief – hoch';

  @override
  String get whatThisMeans => 'Was das bedeutet';

  @override
  String get metricCtlTitle => 'Fitness (CTL)';

  @override
  String get metricAtlTitle => 'Ermüdung (ATL)';

  @override
  String get metricFormTitle => 'Form (TSB)';

  @override
  String get metricRampTitle => 'Anstiegsrate';

  @override
  String get formLabel => 'Form';

  @override
  String get rampRateLabel => 'Anstieg';

  @override
  String get metricCtlExplainer =>
      'CTL ist ein gewichteter 42-Tage-Durchschnitt deiner Trainingsbelastung: wie viel Training du verarbeitet hast — kein Maß für Fitness oder Gesundheit. Der Wert kann steigen, während du dich immer tiefer eingräbst.';

  @override
  String get metricAtlExplainer =>
      'ATL ist derselbe Durchschnitt über 7 Tage — die Belastung, die noch in den Beinen steckt. Er steigt und fällt schnell; ein hoher ATL in einem harten Block ist normal und für sich genommen kein Warnsignal.';

  @override
  String get metricFormExplainer =>
      'Form ist CTL minus ATL. Positiv heißt: weniger frische Belastung als üblich, negativ heißt: das Training der letzten Tage war hart. Negative Form ist der Bereich, in dem Fitness entsteht — sie ist keine Diagnose.';

  @override
  String get metricRampExplainer =>
      'Die Anstiegsrate zeigt, wie schnell sich CTL verändert. Es gibt keinen allgemein sicheren Wert — beurteile ihn an deiner eigenen Historie, deinem Laufumfang und daran, wie du schläfst und dich erholst.';

  @override
  String ftpValue(int watts) {
    return 'FTP $watts W';
  }

  @override
  String ofPlanned(int planned) {
    return 'von $planned';
  }

  @override
  String weeklyGoalProgress(int completed, int planned, int remaining) {
    return '$completed von $planned TSS diese Woche · $remaining verbleiben';
  }

  @override
  String weeklyGoalReached(int completed, int planned) {
    return '$completed von $planned TSS diese Woche · Ziel erreicht';
  }

  @override
  String get weeklyLoadTitle => 'Wochenbelastung';

  @override
  String get fourWeekTrend => '4-Wochen-Trend';

  @override
  String get completedVsPlanned => 'Absolviert vs. geplant';

  @override
  String selectedWeekLoad(String week, int completed, int planned) {
    return 'Woche ab $week: $completed TSS absolviert, $planned geplant';
  }

  @override
  String get tapBarForWeek => 'Für eine Woche auf einen Balken tippen.';

  @override
  String weekSessionsAndTime(int sessions, String time) {
    return '$sessions Einheiten · $time';
  }

  @override
  String get completedLegend => 'Absolviert';

  @override
  String get plannedLegend => 'Geplant';

  @override
  String get fitnessTrendTitle => 'Fitness-Verlauf';

  @override
  String get bySportTitle => 'Nach Sportart';

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten',
      one: '1 Einheit',
    );
    return '$_temp0';
  }

  @override
  String get indoorFtpLabel => 'Indoor-FTP';

  @override
  String ageYears(int years) {
    return '$years J.';
  }

  @override
  String get thresholdsFromSettings =>
      'Aus deinen aktuellen Intervals.icu-Sporteinstellungen.';

  @override
  String get thresholdsFromActivity =>
      'Aus deiner zuletzt ausgewerteten Aktivität gelesen.';

  @override
  String get newChatTitle => 'Neuen Chat starten?';

  @override
  String get newChatConfirm =>
      'Damit wird das Gespräch gelöscht. Chats werden nirgends gespeichert.';

  @override
  String get newChatButton => 'Neuer Chat';

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get createButton => 'Erstellen';

  @override
  String messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Nachrichten',
      one: '1 Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get chatSuggestionLastWeek => 'Wie war die letzte Woche?';

  @override
  String get chatSuggestionRecovered => 'Bin ich erholt genug für Intervalle?';

  @override
  String get chatSuggestionIntensity => 'Ist meine Intensität wirklich 80/20?';

  @override
  String get createInIntervals => 'In Intervals.icu erstellen';

  @override
  String get connectToCreateWorkout =>
      'Verbinde Intervals.icu, um das in deinen Kalender zu legen.';

  @override
  String get preparingWorkout => 'Workout wird vorbereitet …';

  @override
  String get couldNotStructureWorkout =>
      'Das Modell hat kein Workout geliefert, das sich erstellen lässt. Frag noch einmal.';

  @override
  String couldNotCreateWorkout(String error) {
    return 'Workout konnte nicht erstellt werden: $error';
  }

  @override
  String workoutCreated(String name) {
    return '„$name“ wurde in deinen Intervals.icu-Kalender eingetragen.';
  }

  @override
  String get deleteButton => 'Löschen';

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String get deletePlannedWorkoutTitle => 'Diese Einheit löschen?';

  @override
  String deletePlannedWorkoutConfirm(String name) {
    return '„$name“ wird aus deinem Intervals.icu-Kalender entfernt. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String workoutDeleted(String name) {
    return '„$name“ wurde aus deinem Intervals.icu-Kalender gelöscht.';
  }

  @override
  String couldNotDeleteWorkout(String error) {
    return 'Workout konnte nicht gelöscht werden: $error';
  }

  @override
  String get workoutParsedByIntervals =>
      'Intervals.icu macht aus diesen Schritten ein strukturiertes Workout; nicht Erkennbares bleibt als Beschreibung stehen.';

  @override
  String get morePlanSubtitle =>
      'Belastungskurve und Wochenkalender auf dein Ziel hin';

  @override
  String get planGoalTitle => 'Ziel';

  @override
  String get planNoGoal =>
      'Lege ein Ziel fest und TriIQ schlägt einen Trainingsblock aus deinem bisherigen Training vor.';

  @override
  String get planSetGoal => 'Ziel festlegen';

  @override
  String get planEditGoal => 'Ziel bearbeiten';

  @override
  String planGoalSummary(String target, String sport, int days, String hours) {
    return '$target · $sport · $days Tage · $hours Std./Woche';
  }

  @override
  String get planGoalTarget => 'Ziel';

  @override
  String get planGoalSport => 'Sportart';

  @override
  String get planGoalDays => 'Trainingstage';

  @override
  String planGoalHours(String hours) {
    return 'Wochenstunden: $hours';
  }

  @override
  String get planGoalEventDate => 'Wettkampftermin (optional)';

  @override
  String get planGoalClearDate => 'Datum entfernen';

  @override
  String get planGoalBaseline => 'Typische Wochenbelastung in TSS (optional)';

  @override
  String get planGoalBaselineHelp =>
      'Wird genutzt, wenn nicht genug Verlauf synchronisiert ist.';

  @override
  String get planGoalLimitsTitle => 'Steigerungsgrenzen';

  @override
  String get planGoalMaxIncrease => 'Max. Steigerung der Wochenbelastung (%)';

  @override
  String get planGoalMaxRamp => 'Max. CTL-Zuwachs pro Woche';

  @override
  String get planGoalLimitsNote =>
      'Das sind Ausgangswerte, keine allgemein sicheren Werte. Passe sie an deine Belastbarkeit an.';

  @override
  String get planSaveButton => 'Speichern';

  @override
  String get planGenerate => 'Plan erstellen';

  @override
  String get planRegenerate => 'Neu erstellen';

  @override
  String get planRemoveUpcoming => 'Kommende Einheiten entfernen';

  @override
  String get planRemoveTitle => 'Kommende Einheiten entfernen?';

  @override
  String get planRemoveBody =>
      'Einheiten ab heute werden aus deinem Intervals.icu-Kalender gelöscht. Absolvierte und vergangene Einheiten bleiben.';

  @override
  String planRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten entfernt',
      one: '1 Einheit entfernt',
      zero: 'Keine Einheiten zu entfernen',
    );
    return '$_temp0';
  }

  @override
  String get planNeedsBaselineTitle => 'Basiswert nötig';

  @override
  String get planBaselineDialogField => 'Wochenbelastung (TSS)';

  @override
  String get planContinueButton => 'Weiter';

  @override
  String planGenerateFailed(String message) {
    return 'Plan konnte nicht erstellt werden: $message';
  }

  @override
  String get planPreviewTitle => 'Plan prüfen';

  @override
  String get planPreviewNote =>
      'Es wird nichts gespeichert, bevor du den Plan übernimmst. Tippe auf ein Datum, um eine Einheit zu verschieben.';

  @override
  String get planConfirmButton => 'Als Plan übernehmen';

  @override
  String get planCreateCalendarToo => 'Auch im Handy-Kalender eintragen';

  @override
  String planCreatedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten angelegt',
      one: '1 Einheit angelegt',
    );
    return '$_temp0';
  }

  @override
  String planCreatedPartial(int created, int failed) {
    return '$created angelegt, $failed fehlgeschlagen';
  }

  @override
  String planRetryFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fehlgeschlagene Einheiten wiederholen',
      one: '1 fehlgeschlagene Einheit wiederholen',
    );
    return '$_temp0';
  }

  @override
  String get planNotConnected =>
      'Verbinde Intervals.icu im Profil, um aus deiner Historie zu planen und Pläne dorthin zu senden.';

  @override
  String planWeekLabel(int number, String phase) {
    return 'Woche $number · $phase';
  }

  @override
  String get planThisWeek => 'Diese Woche';

  @override
  String get planPhaseBuild => 'Aufbau';

  @override
  String get planPhaseBuildPlus => 'Aufbau+';

  @override
  String get planPhasePeak => 'Spitze';

  @override
  String get planPhaseRecovery => 'Erholung';

  @override
  String planTargetVsActual(int actual, int target) {
    return '$actual von $target TSS';
  }

  @override
  String planTargetOnly(int target) {
    return 'Ziel $target TSS';
  }

  @override
  String planEasyShare(int percent) {
    return '$percent% locker';
  }

  @override
  String get planOutside8020 => 'Unter dem 80/20-Ziel';

  @override
  String get planLimitedIncrease =>
      'Durch die Wochensteigerungsgrenze begrenzt';

  @override
  String get planLimitedCtl => 'Durch die CTL-Steigerungsgrenze begrenzt';

  @override
  String get planLimitedHours => 'Durch deine Wochenstunden begrenzt';

  @override
  String get planKnowledgeWarning =>
      'Ein Teil des Trainingswissens konnte nicht gelesen werden, daher wurden Standardwerte genutzt.';

  @override
  String get planSessionFailed => 'Nicht angelegt';

  @override
  String planSessionMinutes(int minutes, int load) {
    return '$minutes Min. · $load TSS';
  }

  @override
  String get planAddToCalendar => 'Plan im Kalender eintragen';

  @override
  String planCalendarDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine im Kalender eingetragen',
      one: '1 Termin im Kalender eingetragen',
    );
    return '$_temp0';
  }

  @override
  String get planCalendarDenied => 'Kalenderzugriff wurde verweigert.';

  @override
  String get planCalendarPickTitle => 'Kalender wählen';

  @override
  String get planCalendarNone => 'Kein beschreibbarer Kalender gefunden.';

  @override
  String get planOpenSingle => 'Zu Google Kalender hinzufügen';

  @override
  String get sportTriathlon => 'Triathlon';

  @override
  String planGoalWeeks(int weeks) {
    return 'Planlänge: $weeks Wochen';
  }

  @override
  String get planGoalWeeksDefault =>
      'Standard: 8 Wochen oder die Wochen bis zum Wettkampf.';

  @override
  String get planGoalWeeksAuto => 'Standard verwenden';

  @override
  String get planGoalMixTitle => 'Sportarten (Anteil an der Wochenbelastung)';

  @override
  String planGoalMixTotal(int total) {
    return 'Summe $total %';
  }

  @override
  String planGoalMixShare(String sport, int percent) {
    return '$sport: $percent %';
  }

  @override
  String get planCurveTitle => 'Wochenbelastung';

  @override
  String get planCurveHint =>
      'Ziehe eine Woche innerhalb ihres hinterlegten Bereichs (80–120 % des Vorschlags) nach oben oder unten. Senke eine Woche um mehr als 10 % für Erholung.';

  @override
  String planCurveProposal(int percent, int baseline) {
    return 'Gestrichelte Linie = vorgeschlagene Belastung: bis zu +$percent % pro Woche ab $baseline TSS. Ein Standardwert, keine Regel.';
  }

  @override
  String get planCurveNeedsBaseline =>
      'Zu wenig synchronisierte Historie für einen Vorschlag. Gib im Ziel eine typische Wochenbelastung ein.';

  @override
  String planCurveWeekShort(int week) {
    return 'W$week';
  }

  @override
  String planCurveDragLabel(int week, int percent, int tss) {
    return 'Woche $week · $tss TSS · $percent %';
  }

  @override
  String planCurveDelta(String delta) {
    return '$delta % zur Vorwoche';
  }

  @override
  String get planCurveSelectHint =>
      'Tippe auf eine Woche, um sie fein einzustellen.';

  @override
  String get planCurveIncrease => 'Um 5 TSS erhöhen';

  @override
  String get planCurveDecrease => 'Um 5 TSS senken';

  @override
  String get planCurveUndo => 'Rückgängig';

  @override
  String get planCurveReset => 'Zurücksetzen';

  @override
  String get planCurveResetTitle => 'Belastungskurve zurücksetzen?';

  @override
  String get planCurveResetBody =>
      'Alle Wochen gehen zurück auf ihren vorgeschlagenen TSS.';

  @override
  String planCurveWeekSemantics(int week, int percent) {
    return 'Woche $week, $percent % des Vorschlags';
  }

  @override
  String planCurveTssValue(int tss) {
    return '$tss TSS';
  }

  @override
  String planWarnRamp(int percent) {
    return 'Mehr als +$percent % über der letzten Aufbauwoche';
  }

  @override
  String get planWarnCtl => 'Über dem CTL-Anstiegslimit';

  @override
  String get planWarnHours => 'Braucht mehr als deine Wochenstunden';

  @override
  String planWeekBySport(String sport, int tss) {
    return '$sport $tss';
  }

  @override
  String planTargetPlanned(int target, int planned) {
    return 'Ziel $target · geplant $planned TSS';
  }

  @override
  String planCurveFactor(int percent) {
    return '$percent % des Vorschlags';
  }

  @override
  String get planTakenLocal => 'Plan in TriIQ gespeichert.';

  @override
  String get planTakenNotConnected =>
      'Plan in TriIQ gespeichert. Verbinde Intervals.icu, um ihn dorthin zu senden.';

  @override
  String get retryButton => 'Erneut versuchen';

  @override
  String get planSessionSent => 'An Intervals.icu gesendet';

  @override
  String get planSessionLocalOnly => 'Nur in TriIQ';

  @override
  String get planSessionBadge => 'TriIQ-Plan';

  @override
  String get plannedTodayTitle => 'Heute geplant';

  @override
  String get plannedSourceIntervals => 'Intervals.icu';

  @override
  String get showAllSteps => 'Alle Schritte zeigen';

  @override
  String get showLessSteps => 'Weniger zeigen';

  @override
  String get findAlternative => 'Alternative finden';

  @override
  String get changeTraining => 'Training ändern';

  @override
  String get replaceTodaySession => 'Heutige Einheit ersetzen';

  @override
  String get addAlongside => 'Zusätzlich anlegen';

  @override
  String replacesSession(String name) {
    return 'Ersetzt „$name“';
  }

  @override
  String workoutReplaced(String name) {
    return '$name ersetzt die heutige Einheit';
  }

  @override
  String get workoutReplacedLocal => 'Heutige Planeinheit in TriIQ geändert';

  @override
  String get replaceBothExist =>
      'Die neue Einheit wurde angelegt, die alte konnte aber nicht gelöscht werden – beide stehen im Kalender. Lösche die alte im Kalender.';

  @override
  String get replaceRefusedSent =>
      'Diese Einheit ist in Intervals.icu. Verbinde dich und schalte „Plan an Intervals.icu senden“ ein, um sie zu ersetzen.';

  @override
  String get replaceRefusedOffline =>
      'Verbinde Intervals.icu, um diese Einheit zu ersetzen.';

  @override
  String couldNotReplace(String error) {
    return 'Einheit konnte nicht ersetzt werden: $error';
  }

  @override
  String get planChangeMissing => 'Diese Einheit ist nicht mehr im Plan.';

  @override
  String get planChangePast =>
      'Diese Einheit oder dieses Datum liegt in der Vergangenheit.';

  @override
  String get planChangeOutsidePlan =>
      'Dieses Datum liegt außerhalb der Planwochen.';

  @override
  String get planChangeInvalid => 'Diese Änderung passt nicht zum Ziel.';

  @override
  String get proposalCurveTitle => 'Änderung der Belastungskurve';

  @override
  String get proposalPlanTitle => 'Neuer Trainingsplan';

  @override
  String get proposalMoveTitle => 'Einheit verschieben';

  @override
  String get proposalRemoveTitle => 'Einheit entfernen';

  @override
  String get proposalApply => 'Übernehmen';

  @override
  String get proposalDismiss => 'Verwerfen';

  @override
  String get proposalApplied => 'Übernommen';

  @override
  String get proposalDismissed => 'Verworfen';

  @override
  String get proposalStale =>
      'Veraltet: dein Ziel oder Plan hat sich inzwischen geändert. Frag noch einmal.';

  @override
  String proposalFailed(String error) {
    return 'Konnte nicht übernommen werden: $error';
  }

  @override
  String get proposalPlanHint =>
      'Übernehmen öffnet die Planvorschau, dort übernimmst du den Plan.';

  @override
  String get chatToolPlanRead => 'Lese deinen Plan…';

  @override
  String get chatToolProposing => 'Bereite einen Vorschlag vor…';

  @override
  String planCurveRampValue(int percent) {
    return 'Steigerung pro Woche: $percent %';
  }

  @override
  String get planCurveHold => 'Jede 4. Woche halten';

  @override
  String get planCurveHoldHelp =>
      'Wochen 4, 8, 12 … behalten die Belastung der Vorwoche, statt zu steigern.';

  @override
  String get planGoalSlotsTitle =>
      'Einheiten-Mix (Anteil an der Belastung je Sportart)';

  @override
  String get slotZ2 => 'Z2';

  @override
  String get slotIntervals => 'Intervalle';

  @override
  String get slotLong => 'Lang';

  @override
  String get planGoalSlotsReset => 'Standard-Mix des Ziels verwenden';

  @override
  String get planGoalPrefsTitle => 'Vorlieben';

  @override
  String planGoalLongDay(String sport) {
    return 'Lange Einheit $sport am';
  }

  @override
  String get planGoalAnyDay => 'Beliebig';

  @override
  String get planGoalIntervalDays => 'Intervalltage';

  @override
  String get planGoalPerDay => 'Höchstens Einheiten pro Tag';

  @override
  String planNoteLongDay(String sport) {
    return 'Die lange Einheit $sport konnte nicht auf ihren Wunschtag.';
  }

  @override
  String get planNoteIntervalDay =>
      'Die Intervalle konnten nicht auf einen Wunsch-Intervalltag.';

  @override
  String get sessionDiagramTitle => 'Verlauf';

  @override
  String get sessionDiagramNoData =>
      'Diese Aktivität hat keine Zeitreihen (zum Beispiel ein manueller Eintrag).';

  @override
  String sessionDiagramError(String error) {
    return 'Zeitreihen konnten nicht geladen werden: $error';
  }

  @override
  String get sessionIntervalsTitle => 'Intervalle';

  @override
  String sessionIntervalN(int n) {
    return 'Intervall $n';
  }

  @override
  String get streamPower => 'Leistung';

  @override
  String get streamHeartRate => 'Herzfrequenz';

  @override
  String get streamSpeed => 'Tempo';

  @override
  String get streamCadence => 'Trittfrequenz';

  @override
  String get streamAltitude => 'Höhe';

  @override
  String get sessionEvaluationTitle => 'Auswertung';

  @override
  String get verdictOnTarget => 'Im Ziel';

  @override
  String get verdictTooHard => 'Zu hart';

  @override
  String get verdictTooEasy => 'Zu leicht';

  @override
  String get verdictCutShort => 'Verkürzt';

  @override
  String get evalNoPlan => 'Keine geplante Einheit zum Vergleich.';

  @override
  String evalReasonShort(int actual, int planned) {
    return '$actual von $planned geplanten Minuten';
  }

  @override
  String evalReasonTooIntense(String share, String limit) {
    return 'Locker geplant, aber $share der Zeit über der ersten Schwelle (Grenze $limit)';
  }

  @override
  String evalReasonNotIntense(String share, String minimum) {
    return 'Hart geplant, aber nur $share der Zeit über der ersten Schwelle (mindestens $minimum erwartet)';
  }

  @override
  String evalReasonLoad(int actual, int planned) {
    return '$actual TSS gegenüber $planned geplant';
  }

  @override
  String evalPlannedVsActual(String name) {
    return 'Geplant: $name';
  }

  @override
  String evalMinutes(int actual, int planned, String delta) {
    return '$actual von $planned min ($delta)';
  }

  @override
  String evalLoad(int actual, int planned, String delta) {
    return '$actual von $planned TSS ($delta)';
  }

  @override
  String get evalSplitTitle => 'Intensitätsverteilung';

  @override
  String get evalSplitNotAssessable =>
      'Keine Zonenzeiten für diese Einheit, die Intensitätsverteilung ist nicht bewertbar.';

  @override
  String get domainLow => 'Niedrig';

  @override
  String get domainModerate => 'Mittel';

  @override
  String get domainHigh => 'Hoch';

  @override
  String evalDecoupling(String percent) {
    return 'Aerobe Entkopplung: $percent %';
  }

  @override
  String get evalDecouplingNotAssessable =>
      'Aerobe Entkopplung: nicht bewertbar (braucht eine gleichmäßige Einheit von mindestens einer Stunde).';

  @override
  String get evalThresholdsNote =>
      'Die Schwellen folgen der 80/20-Regel im Trainingswissen.';

  @override
  String get askTrainer => 'Trainer fragen';

  @override
  String chatAbout(String title) {
    return 'Zu: $title';
  }

  @override
  String plannedDoneTitle(String name) {
    return 'Erledigt: $name';
  }

  @override
  String get plannedOpenActivity => 'Aktivität öffnen';

  @override
  String get weeklyReviewTitle => 'Wochenrückblick';

  @override
  String get moreReviewSubtitle =>
      'Plan gegen Erledigt, 80/20 und Belastungstrend pro Woche';

  @override
  String weeklyReviewTopic(String date) {
    return 'Woche ab $date';
  }

  @override
  String get previousWeek => 'Vorige Woche';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get weeklyCompliance => 'Plan gegen Erledigt';

  @override
  String get weeklyNothingPlanned => 'In dieser Woche war nichts geplant.';

  @override
  String weeklyComplianceValue(int percent, int done, int planned) {
    return '$percent % erledigt ($done von $planned geplanten Einheiten)';
  }

  @override
  String weeklyLoadValue(int load, int planned) {
    return '$load von $planned geplanten TSS';
  }

  @override
  String weeklyMissed(String name) {
    return '✗ verpasst: $name';
  }

  @override
  String get weeklySplitTitle => 'Intensität (80/20)';

  @override
  String weeklyOutside8020(int percent) {
    return 'Nur $percent % locker: unter der 80/20-Toleranz.';
  }

  @override
  String weeklyNoZones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten haben keine Zonendaten und zählen nicht.',
      one: '1 Einheit hat keine Zonendaten und zählt nicht.',
    );
    return '$_temp0';
  }

  @override
  String get weeklyTrendTitle => 'Belastungstrend';

  @override
  String get weeklyNoHistory =>
      'Zu wenige frühere Wochen im Cache zum Vergleich.';

  @override
  String weeklyVsRecent(String delta, int average) {
    return '$delta % gegenüber dem 4-Wochen-Schnitt von $average TSS';
  }

  @override
  String weeklyFitness(String ctl, String atl, String form) {
    return 'CTL $ctl, ATL $atl über die Woche; Form $form';
  }

  @override
  String get weeklyNoteTitle => 'Nächste Woche';

  @override
  String get weeklyNoteLabel =>
      'Vom Trainer aus den Zahlen oben abgeleitet (eine Einschätzung, keine Messung).';

  @override
  String get weeklyOpenInChat => 'Im Chat besprechen';

  @override
  String get insightsTitle => 'Einblicke';

  @override
  String get insightsBests => 'Bestleistungen';

  @override
  String bestPower(String duration, int watts) {
    return 'Beste $duration-Leistung $watts W';
  }

  @override
  String bestTime(String distance, String time) {
    return 'Schnellste $distance: $time';
  }

  @override
  String bestOther(String value) {
    return 'Bestleistung $value';
  }

  @override
  String bestWas(String best, String previous) {
    return '$best (vorher $previous)';
  }

  @override
  String get insightsEfficiency => 'Aerobe Effizienz';

  @override
  String insightsEfficiencyChange(String value, String change, int sessions) {
    return 'Effizienzfaktor $value: $change % gegenüber deinem 6-Wochen-Median ($sessions lockere Einheiten)';
  }

  @override
  String insightsEfficiencyTooFew(String value, int min) {
    return 'Effizienzfaktor $value. Noch zu wenig Verlauf (braucht $min lockere Einheiten in 6 Wochen).';
  }

  @override
  String get insightsRecovery => 'Erholung (Schätzung)';

  @override
  String insightsRecoveryHours(int hours) {
    return 'Etwa $hours Stunden';
  }

  @override
  String insightsRecoveryRule(int tss) {
    return 'Aus $tss TSS, nach der Erholungsregel im Trainingswissen.';
  }

  @override
  String insightsRecoveryRuleForm(int tss, String form) {
    return 'Aus $tss TSS, plus Zuschlag wegen deiner Form von $form, nach der Erholungsregel im Trainingswissen.';
  }

  @override
  String insightsRecoveryConflict(String name) {
    return 'Das reicht in die morgige Einheit $name. Erwäge eine leichtere Alternative.';
  }

  @override
  String get newTrainingTitle => 'Neues Training';

  @override
  String get newTrainingOk => 'OK';

  @override
  String get newTrainingDetails => 'Details';

  @override
  String get insightsPopupSetting => 'Neues Training beim Öffnen zeigen';

  @override
  String get insightsPopupSettingHelp =>
      'Die neuen Einheiten von heute mit Auswertung, jede einmal.';

  @override
  String get calendarSettingsTitle => 'Kalender';

  @override
  String get calendarSendPlan => 'Plan an Intervals.icu senden';

  @override
  String get calendarSendPlanHelp =>
      'Aus: Trainingspläne bleiben nur in TriIQ.';

  @override
  String get calendarCopyEvents =>
      'Geplante Termine aus Intervals.icu übernehmen';

  @override
  String get calendarCopyEventsHelp =>
      'Aus: in Intervals.icu geplante Einheiten werden ausgeblendet. Absolvierte Aktivitäten werden weiter synchronisiert.';

  @override
  String get calendarSendNowTitle => 'Plan jetzt senden?';

  @override
  String calendarSendNowBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anstehende Planeinheiten sind nur in TriIQ.',
      one: '1 anstehende Planeinheit ist nur in TriIQ.',
    );
    return '$_temp0';
  }

  @override
  String calendarSendNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einheiten senden',
      one: '1 Einheit senden',
    );
    return '$_temp0';
  }

  @override
  String get calendarSendLater => 'Nicht jetzt';

  @override
  String get planNotEnoughDays =>
      'Deine Trainingstage reichen für diese Woche nicht. Füge einen Tag hinzu oder setze eine Sportart auf 0 %.';

  @override
  String get weeklyTargetsSectionTitle => 'Wochenziele';

  @override
  String get weeklyTargetsSectionHelp =>
      'Ein wöchentliches Trainingszeit-Ziel pro Sportart. Leer lassen für kein Ziel.';

  @override
  String weeklyTargetHoursLabel(String sport) {
    return '$sport — Stunden pro Woche';
  }

  @override
  String get weeklyTargetShowOnToday => 'Auf \"Heute\" anzeigen';

  @override
  String get weeklyTargetShowOnTodayHelp =>
      'Ein Fortschrittsring pro Sportart mit festgelegtem Ziel.';

  @override
  String get performanceTitle => 'Leistung';

  @override
  String get performanceSubtitle =>
      'Bestleistungen nach Dauer und Distanz, Saison gegen Saison';

  @override
  String get curveMetricPower => 'Leistung';

  @override
  String get curveMetricPace => 'Pace';

  @override
  String get curveMetricHr => 'Herzfrequenz';

  @override
  String get curvePeriodThisSeason => 'Diese Saison';

  @override
  String get curvePeriodLastSeason => 'Letzte Saison';

  @override
  String get curvePeriodLast42 => 'Letzte 42 Tage';

  @override
  String curvePeriodNoData(String period) {
    return '$period: keine Daten';
  }

  @override
  String curvePeriodRange(String period, String from, String to) {
    return '$period ($from – $to)';
  }

  @override
  String get curveAxisDuration => 'Dauer';

  @override
  String get curveAxisDistance => 'Distanz';

  @override
  String get curveAxisPower => 'Leistung (W)';

  @override
  String get curveAxisHr => 'Herzfrequenz (bpm)';

  @override
  String curveAxisPace(String unit) {
    return 'Pace ($unit)';
  }

  @override
  String get curveTapHint =>
      'Tippe oder ziehe im Diagramm, um einen Wert abzulesen.';

  @override
  String get curveOpenSession => 'Einheit öffnen';

  @override
  String get curveSessionNotCached =>
      'Diese Einheit ist noch nicht im lokalen Cache – synchronisiere zuerst ihren Zeitraum.';

  @override
  String get curvesEmpty =>
      'Noch keine Bestleistungen für diese Sportart und Messgröße.';

  @override
  String curvesLoadFailed(String error) {
    return 'Kurven konnten nicht geladen werden: $error';
  }

  @override
  String get keyEffortsTitle => 'Wichtige Bestwerte';

  @override
  String get keyEffortsChange => 'Änderung';

  @override
  String get modelCardTitle => 'Modell (Intervals.icu)';

  @override
  String get modelNone =>
      'Intervals.icu hat für diese Kurve kein Modell berechnet.';

  @override
  String get modelSettingsValue => 'In deinen Einstellungen';

  @override
  String get modelNoSettingsValue =>
      'In deinen Intervals.icu-Einstellungen nicht gesetzt';

  @override
  String modelGap(String model, String settings, String diff) {
    return 'Modell $model vs. Einstellungen $settings: $diff';
  }

  @override
  String get modelCriticalSpeed => 'Kritische Geschwindigkeit';

  @override
  String get thresholdSuggestionsTitle => 'Schwellenwert-Vorschläge';

  @override
  String thresholdChangeLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String thresholdBasisRideSeasonModel(String percent) {
    return 'Die Modellanpassung dieser Saison liegt $percent% über deinem aktuellen FTP.';
  }

  @override
  String thresholdBasisRideRecentModel(String percent) {
    return 'Die Modellanpassung der letzten 42 Tage liegt $percent% unter deinem aktuellen FTP — vermutlich gesunken.';
  }

  @override
  String thresholdBasisRunSeason60Min(String percent) {
    return 'Deine beste ~60-Minuten-Leistung dieser Saison ist $percent% schneller als dein aktuelles Schwellentempo.';
  }

  @override
  String get thresholdBasisRunSeason40MinHeuristic =>
      'Geschätzt aus deiner besten ~40-Minuten-Leistung dieser Saison (Heuristik: angepasst an ein nachhaltiges 60-Minuten-Tempo).';

  @override
  String thresholdBasisRunRecent60Min(String percent) {
    return 'Deine jüngste beste Leistung ist $percent% langsamer als dein aktuelles Schwellentempo — vermutlich gesunken.';
  }

  @override
  String get thresholdBasisRunRecent40MinHeuristic =>
      'Geschätzt aus deiner jüngsten ~40-Minuten-Leistung (Heuristik) — vermutlich gesunken.';

  @override
  String thresholdBasisSwimSeasonCss(String percent) {
    return 'CSS aus deinen 400-m- und 200-m-Bestzeiten dieser Saison ist $percent% schneller als dein aktuelles Schwellentempo.';
  }

  @override
  String thresholdBasisSwimRecentCss(String percent) {
    return 'CSS aus deinen jüngsten 400-m-/200-m-Leistungen ist $percent% langsamer — vermutlich gesunken.';
  }

  @override
  String get thresholdReviewButton => 'Prüfen';

  @override
  String get thresholdUndoButton => 'Rückgängig';

  @override
  String get thresholdConfirmSheetTitle => 'Schwellenwert aktualisieren?';

  @override
  String get thresholdCurrentLabel => 'Aktuell';

  @override
  String get thresholdNewLabel => 'Neu';

  @override
  String get thresholdZonesTitle => 'Zonenbereiche';

  @override
  String get thresholdZonesBefore => 'Vorher';

  @override
  String get thresholdZonesAfter => 'Nachher';

  @override
  String get thresholdRecalcHrZones => 'Auch HF-Zonen neu berechnen';

  @override
  String get thresholdPastLoadNote =>
      'Vergangene Aktivitäten behalten ihre erfasste Belastung — nur Zonen und neue Einheiten ändern sich.';

  @override
  String get thresholdIndoorFtpNote =>
      'Der Indoor-FTP wird separat festgelegt und ändert sich nicht.';

  @override
  String get thresholdEffortsUsedTitle => 'Verwendete Leistungen';

  @override
  String get thresholdUpdating => 'Wird aktualisiert…';

  @override
  String thresholdUpdateFailed(String error) {
    return 'Aktualisierung fehlgeschlagen: $error';
  }

  @override
  String get thresholdUpdateSuccess => 'Aktualisiert';

  @override
  String get thresholdUndoSuccess => 'Auf den vorherigen Wert zurückgesetzt';

  @override
  String thresholdUndoFailed(String error) {
    return 'Rückgängig machen fehlgeschlagen: $error';
  }

  @override
  String get readinessTitle => 'Trainingsbereitschaft';

  @override
  String get readinessReady => 'Bereit';

  @override
  String get readinessCaution => 'Vorsicht';

  @override
  String get readinessBackOff => 'Ruhiger angehen';

  @override
  String get readinessAllOk => 'Alle Werte im Normalbereich';

  @override
  String readinessReasons(String signals) {
    return 'Wegen $signals';
  }

  @override
  String get readinessNoData => 'Keine Wellness-Daten';

  @override
  String get readinessNoDataHint =>
      'Verbinde eine Uhr oder HRV-App mit Intervals.icu, um HRV, Ruhepuls und Schlaf hier zu sehen.';

  @override
  String readinessWaiting(String date) {
    return 'Warte auf die heutigen Daten (zuletzt: $date)';
  }

  @override
  String get readinessSignalHrv => 'HRV';

  @override
  String get readinessSignalRestingHr => 'Ruhepuls';

  @override
  String get readinessSignalSleep => 'Schlaf';

  @override
  String get readinessSignalForm => 'Form';

  @override
  String get readinessSignalSubjective => 'Müdigkeit / Muskelkater';

  @override
  String get readinessRatingOk => 'OK';

  @override
  String get readinessRatingNoBaseline => 'Noch zu wenig Verlauf';

  @override
  String get readinessRatingMissing => 'Heute kein Wert';

  @override
  String readinessRangeHrv(String value, String mean) {
    return 'Normal ab $value ms (Ø $mean ms)';
  }

  @override
  String readinessRangeRestingHr(String value, String mean) {
    return 'Normal bis $value bpm (Ø $mean bpm)';
  }

  @override
  String readinessRangeSleep(String value) {
    return 'Normal ab $value h';
  }

  @override
  String readinessRangeForm(String value) {
    return 'Normal ab $value';
  }

  @override
  String readinessSubjectiveValues(String fatigue, String soreness) {
    return 'Müdigkeit $fatigue · Muskelkater $soreness (1 gut, 4 schlecht)';
  }

  @override
  String readinessDevice(String value) {
    return 'Geräte-Bereitschaft $value';
  }

  @override
  String get readinessTrend => 'Letzte 30 Tage';

  @override
  String get readinessDisclaimer =>
      'Die Schwellen sind allgemeine Standardwerte aus dem Trainingswissen, keine medizinische Beratung.';

  @override
  String get readinessHintTitle => 'Lieber ein leichterer Tag?';

  @override
  String readinessHintBody(String level, String session) {
    return 'Bereitschaft: $level, und heute steht $session im Plan.';
  }

  @override
  String get readinessTopic => 'Bereitschaft heute';

  @override
  String readinessChatDraft(String level, String reasons, String session) {
    return 'Meine Bereitschaft heute ist $level ($reasons). Soll ich $session trotzdem machen?';
  }

  @override
  String get proposalSwapTitle => 'Zwei Einheiten tauschen';

  @override
  String get proposalLetGoTitle => 'Ausfallen lassen';

  @override
  String get proposalCatchUpTitle => 'Verpasste Einheit nachholen';

  @override
  String adaptMissedReason(String day) {
    return 'Am $day verpasst: nichts dazu aufgezeichnet.';
  }

  @override
  String adaptLoadUnderReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  ) {
    return 'Woche $week: $actual von $target TSS geschafft. Nächste Woche $from → $to TSS.';
  }

  @override
  String adaptLoadOverReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  ) {
    return 'Woche $week: $actual von $target TSS, deutlich über Plan. Nächste Woche $from → $to TSS.';
  }

  @override
  String adaptLoadFloor(int load) {
    return 'Bei 80 % des Vorschlags gehalten; nur nach Steigerung wären es $load TSS.';
  }

  @override
  String get adaptLoadRegenerate =>
      'Die Einheiten der Woche folgen, wenn du den Plan neu erzeugst.';

  @override
  String adaptReadinessReason(String level) {
    return 'Bereitschaft: $level.';
  }

  @override
  String get todayAdjustmentsTitle => 'Plananpassungen';

  @override
  String get planPhaseTaper => 'Tapering';

  @override
  String get planPhaseRace => 'Wettkampfwoche';

  @override
  String get planCurveRaceShort => 'WK';

  @override
  String planEventBeyondPlan(int weeks) {
    return 'Dein Wettkampf ist $weeks Wochen entfernt, mehr als ein Block: Dieser Block baut ohne Tapering auf. Ein Plan, der mit dem Tapering endet, lässt sich erstellen, sobald der Wettkampf höchstens 16 Wochen entfernt ist.';
  }

  @override
  String todayRaceCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Wettkampf in $days Tagen',
      one: 'Wettkampf morgen',
    );
    return '$_temp0';
  }

  @override
  String get todayRaceDay => 'Wettkampftag!';

  @override
  String get feelDialogTitle => 'Wie fühlst du dich?';

  @override
  String get feelScaleHint => '1 gut, 4 schlecht';

  @override
  String get feelFatigueLabel => 'Müdigkeit';

  @override
  String get feelSorenessLabel => 'Muskelkater';

  @override
  String get feelSaveButton => 'Speichern';

  @override
  String get feelActionLabel => 'Müdigkeit & Muskelkater';

  @override
  String get feelNotConnectedHint =>
      'Mit Intervals.icu verbinden, um das festzulegen';

  @override
  String get feelSettingsTitle => 'Müdigkeit & Muskelkater';

  @override
  String get feelPromptOnNewActivity =>
      'Bei einer aktuellen Aktivität nachfragen';

  @override
  String get feelPromptOnNewActivityHelp =>
      'Fragt einmalig, wenn die Detailansicht einer aktuellen Aktivität zum ersten Mal geöffnet wird und für den Tag noch nichts festgelegt ist. Das manuelle Festlegen bei jeder Aktivität funktioniert unabhängig davon immer.';

  @override
  String get deleteDayTrainingsTitle => 'Trainings des Tages löschen?';

  @override
  String deleteDayTrainingsConfirm(int count) {
    return '$count geplante Einheit(en) werden aus deinem Intervals.icu-Kalender entfernt. Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String dayTrainingsDeleted(int count) {
    return '$count Einheit(en) gelöscht.';
  }

  @override
  String get customizeTodayTooltip => 'Heute anpassen';

  @override
  String get customizeTodayTitle => 'Heute anpassen';

  @override
  String get customizeTodayHelp =>
      'Zum Sortieren ziehen. Einen Bereich ausschalten, um ihn von Heute zu entfernen.';

  @override
  String get customizeTodayReset => 'Zurücksetzen';

  @override
  String get todaySectionReadiness => 'Bereitschaft';

  @override
  String get todaySectionMetrics => 'Belastungswerte';

  @override
  String get todaySectionThresholds => 'Schwellenwert-Vorschläge';

  @override
  String get eventsTitle => 'Ereignisse';

  @override
  String get moreEventsSubtitle => 'Wettkämpfe, Notizen, Urlaub und mehr';

  @override
  String get eventsEmpty =>
      'Noch keine Ereignisse. Füge einen Wettkampf oder eine Notiz hinzu.';

  @override
  String get eventsUpcoming => 'Anstehend';

  @override
  String get eventsPast => 'Vergangen';

  @override
  String get eventAddTooltip => 'Ereignis hinzufügen';

  @override
  String get eventNewTitle => 'Neues Ereignis';

  @override
  String get eventEditTitle => 'Ereignis bearbeiten';

  @override
  String get eventCategoryLabel => 'Art';

  @override
  String get eventNameLabel => 'Name';

  @override
  String get eventDateLabel => 'Datum';

  @override
  String get eventEndDateLabel => 'Bis (optional)';

  @override
  String get eventSportLabel => 'Sportart';

  @override
  String get eventDescriptionLabel => 'Beschreibung';

  @override
  String get eventSaveButton => 'Speichern';

  @override
  String get eventNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get eventNotConnected =>
      'Verbinde Intervals.icu, um Ereignisse anzulegen oder zu bearbeiten.';

  @override
  String eventCouldNotSave(String error) {
    return 'Ereignis konnte nicht gespeichert werden: $error';
  }

  @override
  String eventDeleteConfirm(String name) {
    return '„$name“ wird aus deinem Intervals.icu-Kalender entfernt. Das kann nicht rückgängig gemacht werden.';
  }

  @override
  String eventDeleted(String name) {
    return '„$name“ gelöscht.';
  }

  @override
  String get eventCategoryRaceA => 'Wettkampf (A)';

  @override
  String get eventCategoryRaceB => 'Wettkampf (B)';

  @override
  String get eventCategoryRaceC => 'Wettkampf (C)';

  @override
  String get eventCategoryNote => 'Notiz';

  @override
  String get eventCategoryHoliday => 'Urlaub';

  @override
  String get eventCategorySick => 'Krank';

  @override
  String get eventCategoryInjured => 'Verletzt';

  @override
  String get eventCategoryTarget => 'Ziel';

  @override
  String get eventCategorySeasonStart => 'Saisonstart';

  @override
  String get chartZoomIn => 'Vergrößern';

  @override
  String get chartZoomOut => 'Verkleinern';

  @override
  String get chartZoomReset => 'Alles anzeigen';

  @override
  String get streamSmoothing => 'Glättung';

  @override
  String get smoothOff => 'Aus';

  @override
  String get zoomToInterval => 'Auf Intervall zoomen';

  @override
  String get metricTssTodayExplainer =>
      'Der TSS (Training Stress Score) fasst in einer Zahl zusammen, wie hart die heutigen Einheiten waren – aus Dauer und Intensität. 100 entspricht etwa einer Stunde an deiner Schwelle. Vergleiche ihn mit dem Plan, nicht mit anderen.';

  @override
  String get metricTssWeekExplainer =>
      'Die Summe des TSS dieser Woche (Montag bis Sonntag) im Vergleich zum Plan – der schnellste Check, ob du im Soll bist. Ein einzelner leichter oder harter Tag zählt weniger als die ganze Woche.';

  @override
  String get tileShowHistory => 'Verlauf anzeigen';

  @override
  String get weekActivitiesThisWeek => 'Diese Woche';

  @override
  String get weekActivitiesAllSports => 'Alle Sportarten';

  @override
  String get weekActivitiesEmpty => 'Diese Woche noch keine Aktivitäten.';

  @override
  String get yearGoalsTitle => 'Jahresziele';

  @override
  String get yearGoalsHelp =>
      'Ein Distanzziel pro Sportart für dieses Kalenderjahr. Ein leeres Feld bedeutet kein Ziel. Der Fortschritt zählt die auf diesem Gerät gespeicherten Aktivitäten – synchronisiere das Jahr unter Einstellungen → Sync für ein vollständiges Bild.';

  @override
  String yearGoalKmLabel(String sport) {
    return '$sport-Ziel (km pro Jahr)';
  }

  @override
  String get yearGoalShowOnToday => 'Auf Heute anzeigen';

  @override
  String get yearGoalShowOnTodayHelp =>
      'Eine Fortschrittskarte für deine Jahresziele.';

  @override
  String get yearGoalOnTrack => 'Im Plan';

  @override
  String yearGoalAhead(String km) {
    return '$km km vor dem Soll';
  }

  @override
  String yearGoalBehind(String km) {
    return '$km km hinter dem Soll';
  }

  @override
  String yearGoalProjection(String km) {
    return 'Auf Kurs für $km km';
  }

  @override
  String get todaySectionYearGoals => 'Jahresziele';

  @override
  String get analysisTitle => 'Analyse';

  @override
  String get moreAnalysisSubtitle => 'Kennzahlen im Vergleich';

  @override
  String get analysisFilters => 'Filter';

  @override
  String get analysisPeriod => 'Zeitraum';

  @override
  String get analysisRange30d => '30 Tage';

  @override
  String get analysisRange90d => '90 Tage';

  @override
  String get analysisRange6m => '6 Monate';

  @override
  String get analysisRange1y => '1 Jahr';

  @override
  String get analysisRangeYtd => 'Dieses Jahr';

  @override
  String get analysisRangeCustom => 'Eigener…';

  @override
  String get analysisSport => 'Sportart';

  @override
  String get analysisSportAll => 'Alle Sportarten';

  @override
  String get analysisResolution => 'Auflösung';

  @override
  String get analysisDay => 'Tag';

  @override
  String get analysisWeek => 'Woche';

  @override
  String get analysisRolling => 'Gleitender Durchschnitt';

  @override
  String get analysisShowExtremes => 'Min / Max markieren';

  @override
  String get analysisShowBand => 'Standardabweichung (±1 σ)';

  @override
  String get analysisMetrics => 'Kennzahlen';

  @override
  String get analysisMetricTss => 'Trainingslast (TSS)';

  @override
  String get analysisMetricHours => 'Trainingszeit (h)';

  @override
  String get analysisMetricDistance => 'Distanz (km)';

  @override
  String get analysisMetricSleep => 'Schlaf (h)';

  @override
  String get analysisHint =>
      'Tippe in ein Diagramm, um alle Kennzahlen an dieser Stelle zu vergleichen. Mit Pinch oder + / − zoomst du alle gemeinsam.';

  @override
  String get analysisNoData => 'Keine Daten in diesem Zeitraum.';

  @override
  String get analysisPickMetric => 'Wähle oben mindestens eine Kennzahl.';

  @override
  String analysisWeekOf(String date) {
    return 'Woche ab $date';
  }

  @override
  String activityChatDraft(String name, String date) {
    return 'Bitte bewerte meine Einheit „$name“ vom $date: Wie lief sie, und was sollte ich anders oder als Nächstes machen?';
  }

  @override
  String weeklyReviewChatDraft(String date) {
    return 'Bitte bewerte meine Trainingswoche ab $date: Was lief gut, was nicht, und worauf soll ich nächste Woche achten?';
  }

  @override
  String tileChatDraft(String label, String value) {
    return 'Mein $label liegt gerade bei $value. Was bedeutet das für mein Training, und sollte ich diese Woche etwas ändern?';
  }

  @override
  String analysisChatDraft(String period) {
    return 'Hier ist meine Analyse für $period. Was fällt auf, und was sollte ich anpassen?';
  }

  @override
  String get seasonTitle => 'Saison';

  @override
  String get moreSeasonSubtitle =>
      'Fitnessprognose, Rennkalender, Rennprognose';

  @override
  String get seasonNoFitness =>
      'Noch keine Fitnessdaten. Synchronisiere zuerst Intervals.icu.';

  @override
  String seasonLoadError(String error) {
    return 'Die Saison konnte nicht geladen werden: $error';
  }

  @override
  String get forecastTitle => 'Fitnessprognose';

  @override
  String get forecastSubtitle =>
      'Fitness, Ermüdung und Form, hochgerechnet aus deinen geplanten Einheiten. Tage ohne Plan zählen als Ruhe.';

  @override
  String get forecastCtl => 'Fitness (CTL)';

  @override
  String get forecastAtl => 'Ermüdung (ATL)';

  @override
  String get forecastForm => 'Form';

  @override
  String forecastRaceForm(String name, String form) {
    return 'Form am Renntag ($name): $form';
  }

  @override
  String get forecastBandLoaded => 'Noch müde — rechne mit schweren Beinen.';

  @override
  String get forecastBandNeutral => 'Ausgeglichen: weder frisch noch müde.';

  @override
  String get forecastBandFresh =>
      'Frisch — eine gute Ausgangslage für ein Rennen.';

  @override
  String get forecastBandDetrained =>
      'Sehr frisch: durch zu viel Ruhe lässt die Fitness nach.';

  @override
  String forecastPeak(String date, String form) {
    return 'Die Form erreicht am $date ihr Maximum: $form.';
  }

  @override
  String forecastPlannedEnd(String date, String ctl, String form) {
    return 'Fitness am $date: $ctl (Form $form)';
  }

  @override
  String get seasonTimelineTitle => 'Saisonverlauf';

  @override
  String get seasonNoRaces =>
      'Noch keine Rennen. Lege unter Mehr → Ereignisse ein Rennen (Priorität A, B oder C) an oder setze ein Ereignisdatum in deinem Trainingsziel.';

  @override
  String seasonRaceLine(String priority, String name, String date, int weeks) {
    return '$priority-Rennen · $name · $date ($weeks Wo.)';
  }

  @override
  String get blockBase => 'Grundlage';

  @override
  String get blockBuild => 'Aufbau';

  @override
  String get blockTaper => 'Tapering';

  @override
  String get blockRace => 'Rennen';

  @override
  String get blockRecovery => 'Erholung';

  @override
  String get conflictsTitle => 'Konflikte';

  @override
  String get conflictNone => 'Keine Konflikte in deinem Rennkalender.';

  @override
  String conflictTooCloseA(String first, String second, int days) {
    return '$first und $second sind beide A-Rennen, nur $days Tage auseinander. Zwei Höhepunkte brauchen etwa 6 Wochen — mach eines zum B-Rennen.';
  }

  @override
  String conflictInsideTaper(String first, String second) {
    return '$second liegt im Tapering für $first. Behandle es als Trainingsrennen oder lass es aus.';
  }

  @override
  String conflictSameDay(String first, String second) {
    return '$first und $second liegen am selben Tag.';
  }

  @override
  String conflictInsideRecovery(String first, String second) {
    return '$second liegt in der Erholung nach $first.';
  }

  @override
  String conflictDuringIllness(String first) {
    return '$first liegt in einem Zeitraum, den du als krank oder verletzt eingetragen hast.';
  }

  @override
  String get healthSickTitle => 'Du bist als krank eingetragen';

  @override
  String get healthInjuredTitle => 'Du bist als verletzt eingetragen';

  @override
  String get healthReturningTitle => 'Langsamer Wiedereinstieg';

  @override
  String healthSickSubtitle(int days) {
    return 'Tag $days. Ruhe ist der Plan — harte Einheiten werden aus dem Kalender genommen.';
  }

  @override
  String healthInjuredSubtitle(int days) {
    return 'Tag $days. Betroffene Einheiten werden zu lockerem Alternativtraining.';
  }

  @override
  String healthReturnSubtitle(String date) {
    return 'Die Belastung steigt von 50 % bis $date wieder auf Normal.';
  }

  @override
  String get healthNoChanges => 'Es muss nichts Geplantes geändert werden.';

  @override
  String get healthChangeRest => 'Ruhetag';

  @override
  String healthChangeEasier(int minutes, int load) {
    return 'Locker, $minutes Min. (etwa $load TSS)';
  }

  @override
  String healthChangeCross(String sport, int minutes) {
    return 'Stattdessen lockeres $sport, $minutes Min.';
  }

  @override
  String get healthReasonIllness => 'Krankheit';

  @override
  String get healthReasonInjury => 'Verletzung';

  @override
  String get healthReasonReturn => 'Wiedereinstieg';

  @override
  String healthApply(int count) {
    return '$count Änderungen anwenden';
  }

  @override
  String get healthApplyConfirm =>
      'Das ändert deine geplanten Einheiten in Intervals.icu und in TriIQ.';

  @override
  String healthApplyDone(int count) {
    return '$count Einheiten angepasst.';
  }

  @override
  String healthApplyFailed(int done, String error) {
    return 'Nach $done gestoppt: $error';
  }

  @override
  String get healthLogHint =>
      'Krank oder verletzt? Trage es als Ereignis ein und TriIQ passt deinen Plan an.';

  @override
  String get healthLogButton => 'Krankheit oder Verletzung eintragen';

  @override
  String get racePredictorTitle => 'Rennprognose';

  @override
  String get racePredictorSubtitle =>
      'Zielzeit, Pacing und Verpflegung aus deinen Leistungs- und Pace-Kurven, deiner Fitness und deiner Form am Renntag.';

  @override
  String get raceChoose => 'Rennen';

  @override
  String get raceSpec5k => '5-km-Lauf';

  @override
  String get raceSpec10k => '10-km-Lauf';

  @override
  String get raceSpecHalf => 'Halbmarathon';

  @override
  String get raceSpecMarathon => 'Marathon';

  @override
  String get raceSpecRide100 => '100-km-Rad';

  @override
  String get raceSpecSprint => 'Sprint-Triathlon';

  @override
  String get raceSpecOlympic => 'Olympische Distanz';

  @override
  String get raceSpec703 => 'Mitteldistanz (70.3)';

  @override
  String get raceSpec1406 => 'Langdistanz (140.6)';

  @override
  String get raceDayLabel => 'Renntag';

  @override
  String get raceDayAuto => 'Aus meinen Rennen';

  @override
  String get raceDayNone => 'Kein Datum (Form ignorieren)';

  @override
  String get raceHot => 'Heiße Bedingungen';

  @override
  String get raceTotal => 'Prognostizierte Zielzeit';

  @override
  String raceTransitions(String t1, String t2) {
    return 'Wechsel: T1 $t1, T2 $t2';
  }

  @override
  String get raceLegSwim => 'Schwimmen';

  @override
  String get raceLegRide => 'Rad';

  @override
  String get raceLegRun => 'Laufen';

  @override
  String raceMissing(String legs) {
    return 'Nicht genug Daten für: $legs. Ein paar harte Einheiten im Training und ein Sync beheben das.';
  }

  @override
  String raceSlowdown(String pct) {
    return 'Enthält $pct % Zuschlag für Fitness (CTL) und Form am Renntag.';
  }

  @override
  String raceWatts(int watts, String pct) {
    return '$watts W ($pct % FTP)';
  }

  @override
  String raceWattsOnly(int watts) {
    return '$watts W';
  }

  @override
  String get racePacingTitle => 'Pacing-Plan';

  @override
  String get pacingStartControlled => 'Kontrolliert starten';

  @override
  String get pacingHoldSteady => 'Gleichmäßig halten';

  @override
  String get pacingFinishStrong => 'Stark beenden';

  @override
  String get pacingNegativeSplit => 'Einfinden, leicht steigern';

  @override
  String pacingRange(String start, String end) {
    return '$start–$end km';
  }

  @override
  String get fuelingTitle => 'Verpflegungsplan';

  @override
  String get fuelNone => 'Unter etwa 45 Minuten reicht Wasser.';

  @override
  String fuelCarbsPerHour(int g) {
    return '$g g Kohlenhydrate pro Stunde';
  }

  @override
  String fuelFluidPerHour(int ml) {
    return '$ml ml Flüssigkeit pro Stunde';
  }

  @override
  String fuelSodiumPerHour(int mg) {
    return '$mg mg Natrium pro Stunde';
  }

  @override
  String fuelTotals(int carbs, int fluid) {
    return 'Gesamt im Rennen: $carbs g Kohlenhydrate, $fluid ml Flüssigkeit';
  }

  @override
  String fuelDayBefore(int g) {
    return 'Am Vortag: etwa $g g Kohlenhydrate';
  }

  @override
  String fuelPreRace(int g) {
    return '1–4 Std. vor dem Start: etwa $g g Kohlenhydrate';
  }

  @override
  String fuelStep(int minute, String sport, int carbs, int fluid) {
    return '$minute Min. · $sport: $carbs g KH, $fluid ml';
  }

  @override
  String get raceDisclaimer =>
      'Eine Modellschätzung aus deinen Bestleistungen, kein Versprechen. Strecke, Wetter und Pacing entscheiden am Tag.';

  @override
  String get raceAskTrainer => 'Trainer fragen';

  @override
  String raceChatDraft(String time, String race) {
    return 'Die Rennprognose sagt $time für $race. Ist das realistisch, und woran sollte ich bis zum Renntag arbeiten?';
  }

  @override
  String get brickTitleBikeRun => 'Koppeltraining: Rad → Laufen';

  @override
  String get brickTitleSwimBike => 'Koppeltraining: Schwimmen → Rad';

  @override
  String brickTransition(String time) {
    return 'Wechsel: $time';
  }

  @override
  String brickSettle(String time) {
    return 'Beine eingelaufen nach $time';
  }

  @override
  String brickEarly(String pct) {
    return 'Erste 10 Min. mit $pct % deiner späteren Geschwindigkeit';
  }

  @override
  String get brickVerdictGood => 'Starkes Koppeltraining';

  @override
  String get brickVerdictOk => 'Ordentliches Koppeltraining';

  @override
  String get brickVerdictRough => 'Holpriger Start nach dem Rad';

  @override
  String get brickVerdictUnknown => 'Nur der Wechsel';

  @override
  String get brickNoteSettledFast => 'Die Beine waren schnell da.';

  @override
  String get brickNoteSettledSlow =>
      'Es dauerte lange, den Rhythmus zu finden.';

  @override
  String get brickNoteSlowStart =>
      'Die ersten Minuten waren deutlich langsamer als der Rest.';

  @override
  String get brickNoteHighEarlyCost =>
      'Der Puls war anfangs hoch für das Tempo — laufe die ersten 10 Minuten nach Anstrengung, nicht nach Tempo.';

  @override
  String get brickNoteHardFirstLeg =>
      'Die erste Einheit war hart (Intensität ab 85 %), das kostet meist die nächste.';

  @override
  String get brickNoteQuickTransition => 'Schneller Wechsel.';

  @override
  String get brickNoteLongTransition =>
      'Langer Wechsel — im Training okay, aber übe ihn vor einem Rennen.';

  @override
  String get brickNoteNoStream =>
      'Kein Datenstrom für die zweite Einheit, daher wird nur der Wechsel bewertet.';

  @override
  String brickSessions(String first, String second) {
    return '$first + $second';
  }

  @override
  String get memoryTitle => 'Trainer-Gedächtnis';

  @override
  String get moreMemorySubtitle => 'Was sich der Trainer über dich merkt';

  @override
  String get memoryIntro =>
      'Dauerhafte Vorlieben, die der Trainer in jedem Chat beachtet, z. B. „Keine harten Einheiten freitags“ oder „Schwimmen nur morgens“. Hier kannst du sie hinzufügen oder entfernen. Der Trainer speichert nur etwas, wenn du ihn darum bittest.';

  @override
  String get memoryEmpty => 'Noch nichts gemerkt.';

  @override
  String get memoryAddHint => 'Vorliebe hinzufügen…';

  @override
  String get memoryAddButton => 'Hinzufügen';

  @override
  String get memoryFromTrainer => 'vom Trainer gespeichert';

  @override
  String get memoryDelete => 'Entfernen';

  @override
  String get memoryClear => 'Alle entfernen';

  @override
  String get memoryClearConfirm =>
      'Alles entfernen, was sich der Trainer merkt?';

  @override
  String memoryFull(int max) {
    return 'Das Gedächtnis ist voll ($max Einträge). Entferne zuerst einen.';
  }

  @override
  String memoryCount(int count, int max) {
    return '$count von $max';
  }

  @override
  String get backupTitle => 'Datensicherung';

  @override
  String get backupIntro =>
      'Exportiere deine synchronisierten Daten, Pläne, Wissensbibliothek und Einstellungen als eine JSON-Datei und stelle sie auf einem anderen Gerät wieder her. Deine Intervals.icu- und KI-Schlüssel sind nicht enthalten — verbinde dich nach der Wiederherstellung neu.';

  @override
  String get backupIncludeCaches => 'Diagramm-Zwischenspeicher einschließen';

  @override
  String get backupIncludeCachesHelp =>
      'Verläufe und Leistungskurven. Größere Datei; sie lassen sich neu laden.';

  @override
  String get backupExport => 'Sicherung exportieren';

  @override
  String get backupRestore => 'Aus Sicherung wiederherstellen…';

  @override
  String backupExported(String path) {
    return 'Sicherung gespeichert unter $path';
  }

  @override
  String get backupShared => 'Sicherung zum Teilen bereit.';

  @override
  String backupFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get backupRestoreTitle => 'Diese Sicherung wiederherstellen?';

  @override
  String backupRestoreBody(
    String date,
    int activities,
    int plans,
    int total,
    int settings,
  ) {
    return 'Vom $date: $activities Aktivitäten, $plans Pläne, insgesamt $total Zeilen, $settings Einstellungen. Das ersetzt die synchronisierten Daten, Pläne und die Wissensbibliothek auf diesem Gerät.';
  }

  @override
  String get backupRestoreConfirm => 'Ersetzen';

  @override
  String get backupRestored =>
      'Wiederhergestellt. Starte TriIQ neu, um die Einstellungen zu übernehmen, und verbinde Intervals.icu bei Bedarf neu.';

  @override
  String get backupUnknownDate => 'einem unbekannten Datum';

  @override
  String forecastAssumed(String date) {
    return 'Nach dem $date ist nichts geplant; ab dann nimmt die Prognose an, dass du auf deinem aktuellen Fitnessniveau weitertrainierst.';
  }
}
