// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navToday => 'Today';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navChat => 'Chat';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navMore => 'More';

  @override
  String get profileAndSettingsTooltip => 'Profile & settings';

  @override
  String get titleProfile => 'Profile';

  @override
  String get titleSettings => 'Settings';

  @override
  String get titleSync => 'Sync';

  @override
  String get titleActivities => 'Activities';

  @override
  String get titleActivity => 'Activity';

  @override
  String get titleAthlete => 'Athlete';

  @override
  String get titlePlannedTraining => 'Planned training';

  @override
  String get titleTrainNow => 'Train now';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get openSettingsButton => 'Open Settings';

  @override
  String get openProfileButton => 'Open Profile';

  @override
  String get notConnected => 'Not connected';

  @override
  String get connectedLabel => 'Connected';

  @override
  String get syncedWithIntervals => 'Synced with Intervals.icu';

  @override
  String get activityFallback => 'Activity';

  @override
  String get plannedSessionFallback => 'Planned session';

  @override
  String heroActivitiesStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activities logged today',
      one: '1 activity logged today',
      zero: 'Ready to train',
    );
    return '$_temp0';
  }

  @override
  String get notConnectedToIntervals => 'Not connected to Intervals.icu';

  @override
  String get noWorkoutLoggedToday => 'No workout logged today';

  @override
  String get finishSettingUp => 'Finish setting up';

  @override
  String get connectIntervalsPrompt =>
      'Connect your Intervals.icu account to see your training data.';

  @override
  String get setupLlmPrompt =>
      'Set up an LLM provider (Claude or Ollama) to chat with the training agent.';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get tssToday => 'TSS today';

  @override
  String get tssWeek => 'TSS week';

  @override
  String get ctlLabel => 'CTL';

  @override
  String get atlLabel => 'ATL';

  @override
  String get todaysActivities => 'Today\'s activities';

  @override
  String get todaysTraining => 'Today\'s training';

  @override
  String get tomorrowsTraining => 'Tomorrow\'s training';

  @override
  String get nothingPlannedToday => 'Nothing planned for today — rest day.';

  @override
  String get nothingPlannedTomorrow => 'Nothing planned for tomorrow yet.';

  @override
  String get connectToSeePlan =>
      'Connect your Intervals.icu account to see your plan.';

  @override
  String get connectInProfile =>
      'Connect your Intervals.icu account in Profile';

  @override
  String get noTargetSet => 'No target set';

  @override
  String get sportLabel => 'Sport';

  @override
  String get sportRun => 'Run';

  @override
  String get sportRide => 'Ride';

  @override
  String get sportSwim => 'Swim';

  @override
  String durationMinutes(int minutes) {
    return 'Duration — $minutes min';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get intensityRecovery => 'Recovery';

  @override
  String get intensityEndurance => 'Endurance';

  @override
  String get intensityIntervals => 'Intervals';

  @override
  String trainNowEventTitle(String intensity, String sport) {
    return '$intensity $sport session';
  }

  @override
  String get llmNeededForProposal =>
      'Set up an LLM provider in Settings to get a proposal.';

  @override
  String get proposeTraining => 'Propose training';

  @override
  String get askAgain => 'Ask again';

  @override
  String get addToGoogleCalendar => 'Add to Google Calendar';

  @override
  String get couldNotOpenGoogleCalendar => 'Could not open Google Calendar.';

  @override
  String get thinkingEllipsis => 'Thinking…';

  @override
  String toolFailedSuffix(String label) {
    return '$label — failed';
  }

  @override
  String toolRunningGeneric(String name) {
    return 'Running $name…';
  }

  @override
  String get trainNowToolChecking => 'Checking your profile and cached data…';

  @override
  String get trainNowToolDailyLoad => 'Reading your daily load and wellness…';

  @override
  String get trainNowToolActivities => 'Reading your recent activities…';

  @override
  String get trainNowToolPlanned => 'Reading your planned sessions…';

  @override
  String get trainNowToolSummary => 'Summarising your last 7 days…';

  @override
  String get trainNowToolGuidance => 'Consulting the training reference…';

  @override
  String get trainNowToolSyncing => 'Syncing from Intervals.icu…';

  @override
  String get tssHistoryTitle => 'TSS — last 42 days';

  @override
  String get totalLabel => 'Total';

  @override
  String get avgPerDay => 'Avg / day';

  @override
  String get avgPerWeek => 'Avg / week';

  @override
  String get dailyTss => 'Daily TSS';

  @override
  String get tapBarForDetails => 'Tap a bar for its date and value.';

  @override
  String selectedDayTss(String date, int tss) {
    return '$date · $tss TSS';
  }

  @override
  String get connectForAthleteDetails =>
      'Connect your Intervals.icu account in Profile to see your athlete details.';

  @override
  String athleteIdLine(String id) {
    return 'Athlete ID $id · synced with Intervals.icu';
  }

  @override
  String get bodyAndWellness => 'Body & wellness';

  @override
  String get noWellnessCached => 'No wellness data cached yet.';

  @override
  String get weightLabel => 'Weight';

  @override
  String get restingHrLabel => 'Resting HR';

  @override
  String get hrvLabel => 'HRV';

  @override
  String get thresholdsTitle => 'Thresholds';

  @override
  String get noActivitiesForThresholds =>
      'No activities cached yet, so no per-sport thresholds could be read.';

  @override
  String get thresholdPaceLabel => 'Threshold pace';

  @override
  String get weightAsAnalysedLabel => 'Weight (as analysed)';

  @override
  String asOfDate(String date) {
    return 'as of $date';
  }

  @override
  String get calendarMonth => 'Month';

  @override
  String get calendarWeek => 'Week';

  @override
  String get todayTooltip => 'Today';

  @override
  String get noTrainingData => 'No training data';

  @override
  String get nothingPlannedOrLogged => 'Nothing planned or logged this day.';

  @override
  String get plannedStatus => 'Planned';

  @override
  String get completedStatus => 'Completed';

  @override
  String get messageAgentHint => 'Message the training agent…';

  @override
  String get askAboutTraining => 'Ask about your training, progress, or plan';

  @override
  String get pickLlmProviderToChat =>
      'Pick an LLM provider in Settings to start chatting';

  @override
  String get noReplyFromModel => 'No reply came back from the model.';

  @override
  String get chatToolChecking => 'Checking your profile and cached data…';

  @override
  String get chatToolDailyLoad => 'Reading your daily load and wellness…';

  @override
  String get chatToolActivities => 'Reading your activities…';

  @override
  String get chatToolPlanned => 'Reading your planned sessions…';

  @override
  String get chatToolSummary => 'Summarising your training…';

  @override
  String get chatToolGuidance => 'Consulting the training reference…';

  @override
  String get chatToolSyncing => 'Syncing from Intervals.icu…';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get notificationsSubtitle =>
      'Sync completion and training-agent replies';

  @override
  String get dailyTrainingReminder => 'Daily training reminder';

  @override
  String get notificationPermissionDenied =>
      'Notification permission was denied. Enable it for TriIQ in your device settings to turn this on.';

  @override
  String get reminderNeedsBackground =>
      'The daily reminder needs the app to stay reachable in the background, which isn\'t available on this platform.';

  @override
  String get syncSectionTitle => 'Sync';

  @override
  String get autoSyncDescription =>
      'Refresh this month automatically while the app is open, no more often than:';

  @override
  String autoSyncMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String autoSyncHours(int hours) {
    return '$hours h';
  }

  @override
  String get llmProviderTitle => 'LLM provider';

  @override
  String get claudeLabel => 'Claude';

  @override
  String get ollamaLabel => 'Ollama';

  @override
  String get claudeApiKeyLabel => 'Claude API key';

  @override
  String get claudeKeyStoredHint =>
      'A key is stored — type a new one to replace it';

  @override
  String get showTooltip => 'Show';

  @override
  String get hideTooltip => 'Hide';

  @override
  String get saveKeyButton => 'Save key';

  @override
  String get clearButton => 'Clear';

  @override
  String get claudeModelLabel => 'Claude model';

  @override
  String get claudeKeySecureHelp =>
      'The key is stored in your operating system\'s credential vault and sent only to Anthropic. Usage is billed to your own Anthropic account.';

  @override
  String get claudeKeyInsecureHelp =>
      'This build cannot store the key securely, so it is kept for this session only and you will re-enter it after a reload.';

  @override
  String get ollamaServerUrlLabel => 'Ollama server URL';

  @override
  String get ollamaCloudApiKeyLabel => 'Ollama Cloud API key';

  @override
  String get ollamaApiKeyOptionalLabel => 'Ollama API key (optional)';

  @override
  String get ollamaKeyStoredHint =>
      'A key is stored — type a new one to replace it';

  @override
  String get getAKeyButton => 'Get a key';

  @override
  String get testConnectionButton => 'Test connection';

  @override
  String get ollamaModelLabel => 'Ollama model';

  @override
  String get ollamaKeySecureHelp =>
      'The key is stored in your operating system\'s credential vault and sent only to Ollama Cloud.';

  @override
  String get ollamaKeyInsecureHelp =>
      'This build cannot store the key securely, so it is kept for this session only and you will re-enter it after a reload.';

  @override
  String get ollamaLocalHelp =>
      'Nothing leaves your network. The model must support tool calling — without it the agent cannot read your training data.';

  @override
  String get claudeKeySavedMessage => 'Claude API key saved.';

  @override
  String get claudeKeyRemovedMessage => 'Claude API key removed.';

  @override
  String get ollamaKeyRemovedMessage => 'Ollama API key removed.';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get ollamaKeySavedPrefix => 'Ollama API key saved';

  @override
  String get connectedPrefix => 'Connected';

  @override
  String connectedModelsMessage(String prefix, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models available.',
      one: '1 model available.',
      zero: 'connected, but no models are available on that server yet.',
    );
    return '$prefix — $_temp0';
  }

  @override
  String couldNotConnectKeyNotSaved(String error) {
    return 'Could not connect: $error. Key not saved.';
  }

  @override
  String couldNotConnect(String error) {
    return 'Could not connect: $error';
  }

  @override
  String get profileHeaderChecking => 'Checking saved connection…';

  @override
  String get intervalsConnectionTitle => 'Intervals.icu connection';

  @override
  String get checkingForSavedKey => 'Checking for a saved API key…';

  @override
  String get disconnectButton => 'Disconnect';

  @override
  String get apiKeyHelpSecure =>
      'Find your API key under Settings on intervals.icu. It is kept in this device\'s secure credential store.';

  @override
  String get apiKeyHelpInsecure =>
      'Find your API key under Settings on intervals.icu. In the browser it is only held for this tab — browsers have no secure place to keep it, so you will re-enter it after a reload.';

  @override
  String get intervalsApiKeyLabel => 'Intervals.icu API key';

  @override
  String get connectButton => 'Connect';

  @override
  String couldNotConnectGeneric(String error) {
    return 'Could not connect: $error';
  }

  @override
  String get moreSyncSubtitle => 'Pull training data from Intervals.icu';

  @override
  String get moreActivitiesSubtitle => 'Every cached activity';

  @override
  String get trainingPlansTitle => 'Training plans';

  @override
  String get gearTitle => 'Gear';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get syncNotConnectedTitle => 'Not connected';

  @override
  String get syncNotConnectedBody =>
      'Connect your Intervals.icu account in Profile before syncing.';

  @override
  String get localCacheTitle => 'Local cache';

  @override
  String localCacheBody(String oldest, String newest, String lastSynced) {
    return 'Activities cached from $oldest to $newest\nLast synced $lastSynced';
  }

  @override
  String syncedMessage(int activities, int wellness) {
    return 'Synced $activities activities, $wellness wellness records.';
  }

  @override
  String syncFailedMessage(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get syncScopeToday => 'Today';

  @override
  String get syncScopeMonth => 'This month';

  @override
  String get syncScopeYear => 'This year';

  @override
  String get syncScopeAll => 'Everything (initial sync)';

  @override
  String get noActivitiesCachedConnected =>
      'No activities cached yet — try Sync from More.';

  @override
  String get noActivitiesCachedDisconnected =>
      'Connect your Intervals.icu account to see your activities.';

  @override
  String noActivitiesOfType(String sport) {
    return 'No $sport activities cached — try Sync from More.';
  }

  @override
  String get showAllActivities => 'Show all activities';

  @override
  String get tssSuffix => 'TSS';

  @override
  String get openInIntervals => 'Open in Intervals.icu';

  @override
  String get timeInZone => 'Time in zone';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get durationLabel => 'Duration';

  @override
  String get elevationGainLabel => 'Elevation gain';

  @override
  String get avgHrLabel => 'Avg HR';

  @override
  String get maxHrLabel => 'Max HR';

  @override
  String get avgPowerNpLabel => 'Avg power (NP)';

  @override
  String get avgPowerLabel => 'Avg power';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get plannedTssLabel => 'Planned TSS';

  @override
  String get locationLabel => 'Location';

  @override
  String get indoorLabel => 'Indoor';

  @override
  String get workoutTitle => 'Workout';

  @override
  String get statsNotConnected => 'Not connected to Intervals.icu';

  @override
  String get volumeTitle => 'Volume';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String rangeDaysShort(int days) {
    return '${days}d';
  }

  @override
  String get rangeOneYear => '1y';

  @override
  String get noDataCachedForRange => 'No data cached for this range yet.';

  @override
  String selectedDayValue(String date, String value) {
    return '$date: $value';
  }

  @override
  String get tapChartForDay => 'Tap the chart for a single day.';

  @override
  String get currentLabel => 'Current';

  @override
  String get changeLabel => 'Change';

  @override
  String get avgLabel => 'Average';

  @override
  String get rangeLabel => 'Low – high';

  @override
  String get whatThisMeans => 'What this means';

  @override
  String get metricCtlTitle => 'Fitness (CTL)';

  @override
  String get metricAtlTitle => 'Fatigue (ATL)';

  @override
  String get metricFormTitle => 'Form (TSB)';

  @override
  String get metricRampTitle => 'Ramp rate';

  @override
  String get formLabel => 'Form';

  @override
  String get rampRateLabel => 'Ramp';

  @override
  String get metricCtlExplainer =>
      'CTL is a 42-day weighted average of your training load: how much training you have absorbed, not a measure of fitness or health. It can keep rising while you dig yourself into a hole.';

  @override
  String get metricAtlExplainer =>
      'ATL is the same average over 7 days — the load still sitting in your legs. It rises and falls quickly, and a high ATL inside a hard block is normal rather than a warning on its own.';

  @override
  String get metricFormExplainer =>
      'Form is CTL minus ATL. Positive means you are carrying less recent load than usual, negative means recent training is heavy. Negative form is where fitness gets built; it is not a diagnosis.';

  @override
  String get metricRampExplainer =>
      'Ramp rate is how fast CTL is changing. There is no universally safe number — judge it against your own history, your running volume, and how you are sleeping and recovering.';

  @override
  String ftpValue(int watts) {
    return 'FTP $watts W';
  }

  @override
  String ofPlanned(int planned) {
    return 'of $planned';
  }

  @override
  String weeklyGoalProgress(int completed, int planned, int remaining) {
    return '$completed of $planned TSS this week · $remaining to go';
  }

  @override
  String weeklyGoalReached(int completed, int planned) {
    return '$completed of $planned TSS this week · goal reached';
  }

  @override
  String get weeklyLoadTitle => 'Weekly load';

  @override
  String get fourWeekTrend => '4-week trend';

  @override
  String get completedVsPlanned => 'Completed vs planned';

  @override
  String selectedWeekLoad(String week, int completed, int planned) {
    return 'Week of $week: $completed TSS done, $planned planned';
  }

  @override
  String get tapBarForWeek => 'Tap a bar for one week.';

  @override
  String weekSessionsAndTime(int sessions, String time) {
    return '$sessions sessions · $time';
  }

  @override
  String get completedLegend => 'Completed';

  @override
  String get plannedLegend => 'Planned';

  @override
  String get fitnessTrendTitle => 'Fitness trend';

  @override
  String get bySportTitle => 'By sport';

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get indoorFtpLabel => 'Indoor FTP';

  @override
  String ageYears(int years) {
    return '$years yrs';
  }

  @override
  String get thresholdsFromSettings =>
      'From your current Intervals.icu sport settings.';

  @override
  String get thresholdsFromActivity =>
      'Read from your most recent analysed activity.';

  @override
  String get newChatTitle => 'Start a new chat?';

  @override
  String get newChatConfirm =>
      'This clears the conversation. Chats aren\'t saved anywhere.';

  @override
  String get newChatButton => 'New chat';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get createButton => 'Create';

  @override
  String messagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get chatSuggestionLastWeek => 'How was last week?';

  @override
  String get chatSuggestionRecovered => 'Am I recovered enough for intervals?';

  @override
  String get chatSuggestionIntensity => 'Is my intensity really 80/20?';

  @override
  String get createInIntervals => 'Create in Intervals.icu';

  @override
  String get connectToCreateWorkout =>
      'Connect Intervals.icu to put this on your calendar.';

  @override
  String get preparingWorkout => 'Preparing the workout…';

  @override
  String get couldNotStructureWorkout =>
      'The model didn\'t return a workout that could be created. Try asking again.';

  @override
  String couldNotCreateWorkout(String error) {
    return 'Could not create the workout: $error';
  }

  @override
  String workoutCreated(String name) {
    return '“$name” added to your Intervals.icu calendar.';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get deletePlannedWorkoutTitle => 'Delete this session?';

  @override
  String deletePlannedWorkoutConfirm(String name) {
    return '“$name” is removed from your Intervals.icu calendar. This can\'t be undone.';
  }

  @override
  String workoutDeleted(String name) {
    return '“$name” deleted from your Intervals.icu calendar.';
  }

  @override
  String couldNotDeleteWorkout(String error) {
    return 'Could not delete the workout: $error';
  }

  @override
  String get workoutParsedByIntervals =>
      'Intervals.icu turns these steps into a structured workout; anything it can\'t parse stays as the description.';
}
