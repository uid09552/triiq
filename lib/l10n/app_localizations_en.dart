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
  String get navStatistics => 'Insights';

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
  String get addCustomInstructions => 'Add custom instructions';

  @override
  String get customInstructionsLabel => 'Custom instructions';

  @override
  String get removeCustomInstructions => 'Remove custom instructions';

  @override
  String get customInstructionsHint =>
      'e.g. \"keep the run flat, I want to save my legs for a race Saturday\"';

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
  String get appearanceDeveloper => 'Developer';

  @override
  String get performanceUpTooltip => 'More efficient than your recent average';

  @override
  String get performanceDownTooltip =>
      'Less efficient than your recent average';

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
  String get backgroundSyncTitle => 'Nightly background sync';

  @override
  String get backgroundSyncDescription =>
      'Refresh the current week overnight even when the app is closed. It runs about once a day, only with a network connection and when the battery isn\'t low.';

  @override
  String get backgroundSyncNoRun => 'No background run yet.';

  @override
  String backgroundSyncLastRun(String when, String result) {
    return 'Last run: $when – $result';
  }

  @override
  String get backgroundResultSuccess => 'synced';

  @override
  String get backgroundResultSkippedFresh => 'skipped, data was fresh';

  @override
  String get backgroundResultAuthRejected =>
      'key rejected, reconnect in Profile';

  @override
  String get backgroundResultFailed => 'failed, will retry tomorrow';

  @override
  String get backgroundResultNotConnected => 'not connected';

  @override
  String get backgroundSyncUnsupported =>
      'Background sync is not available on this platform. Data refreshes while the app is open.';

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
  String get trainingPlansTitle => 'Training plans';

  @override
  String get moreKnowledgeSubtitle =>
      'Your own coaching documents the agent can search';

  @override
  String get knowledgeLibraryTitle => 'Knowledge library';

  @override
  String get knowledgeImportButton => 'Import';

  @override
  String get knowledgeEmptyTitle => 'No documents yet';

  @override
  String get knowledgeEmptyBody =>
      'Import Markdown or text files with your own coaching notes, swim sets or taper guides. The chat agent searches them alongside the built-in reference — they never change your training plan.';

  @override
  String knowledgeSectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections',
      one: '1 section',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportedOn(String date) {
    return 'Imported $date';
  }

  @override
  String get knowledgeDisabledLabel => 'Disabled';

  @override
  String get knowledgeDeleteTitle => 'Delete this document?';

  @override
  String knowledgeDeleteConfirm(String title) {
    return '\"$title\" and its sections will be removed from this device.';
  }

  @override
  String get knowledgeDuplicateTitle => 'Already imported';

  @override
  String knowledgeDuplicateBody(String fileName) {
    return 'A document named \"$fileName\" already exists.';
  }

  @override
  String get knowledgeReplaceButton => 'Replace';

  @override
  String get knowledgeKeepBothButton => 'Keep both';

  @override
  String knowledgeImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sections imported',
      one: '1 section imported',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportIgnoredBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count structured blocks ignored',
      one: '1 structured block ignored',
    );
    return '$_temp0';
  }

  @override
  String knowledgeImportRejected(String fileName, String reason) {
    return 'Couldn\'t import $fileName: $reason';
  }

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
  String couldNotDeleteWorkout(String error) {
    return 'Could not delete the workout: $error';
  }

  @override
  String get workoutParsedByIntervals =>
      'Intervals.icu turns these steps into a structured workout; anything it can\'t parse stays as the description.';

  @override
  String get morePlanSubtitle =>
      'A load curve and weekly calendar toward your goal';

  @override
  String get planGoalTitle => 'Goal';

  @override
  String get planNoGoal =>
      'Set a goal and TriIQ proposes a training block from your recent training.';

  @override
  String get planSetGoal => 'Set goal';

  @override
  String get planEditGoal => 'Edit goal';

  @override
  String planGoalSummary(String target, String sport, int days, String hours) {
    return '$target · $sport · $days days · $hours h/week';
  }

  @override
  String get planGoalTarget => 'Target';

  @override
  String get planGoalSport => 'Sport';

  @override
  String get planGoalDays => 'Training days';

  @override
  String planGoalHours(String hours) {
    return 'Weekly hours: $hours';
  }

  @override
  String get planGoalEventDate => 'Event date (optional)';

  @override
  String get planGoalClearDate => 'Clear date';

  @override
  String get planGoalBaseline => 'Typical weekly load in TSS (optional)';

  @override
  String get planGoalBaselineHelp =>
      'Used when there is not enough synced history.';

  @override
  String get planGoalLimitsTitle => 'Ramp limits';

  @override
  String get planGoalMaxIncrease => 'Max weekly load increase (%)';

  @override
  String get planGoalMaxRamp => 'Max CTL gain per week';

  @override
  String get planGoalLimitsNote =>
      'These are starting points, not universally safe values. Adjust them to how you respond.';

  @override
  String get planSaveButton => 'Save';

  @override
  String get planGenerate => 'Generate plan';

  @override
  String get planRegenerate => 'Regenerate';

  @override
  String get planRemoveUpcoming => 'Remove upcoming sessions';

  @override
  String get planRemoveTitle => 'Remove upcoming sessions?';

  @override
  String get planRemoveBody =>
      'Sessions from today on are deleted from your Intervals.icu calendar. Completed and past sessions stay.';

  @override
  String planRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions removed',
      one: '1 session removed',
      zero: 'No sessions to remove',
    );
    return '$_temp0';
  }

  @override
  String get planNeedsBaselineTitle => 'A baseline is needed';

  @override
  String get planBaselineDialogField => 'Weekly load (TSS)';

  @override
  String get planContinueButton => 'Continue';

  @override
  String planGenerateFailed(String message) {
    return 'Could not build a plan: $message';
  }

  @override
  String get planPreviewTitle => 'Review your plan';

  @override
  String get planPreviewNote =>
      'Nothing is saved until you take the plan. Tap a date to move a session.';

  @override
  String get planConfirmButton => 'Take as plan';

  @override
  String get planCreateCalendarToo => 'Also add to my phone calendar';

  @override
  String planCreatedAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions created',
      one: '1 session created',
    );
    return '$_temp0';
  }

  @override
  String planCreatedPartial(int created, int failed) {
    return '$created created, $failed failed';
  }

  @override
  String planRetryFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Retry $count failed sessions',
      one: 'Retry 1 failed session',
    );
    return '$_temp0';
  }

  @override
  String get planNotConnected =>
      'Connect Intervals.icu in Profile to build from your history and send plans there.';

  @override
  String planWeekLabel(int number, String phase) {
    return 'Week $number · $phase';
  }

  @override
  String get planThisWeek => 'This week';

  @override
  String get planPhaseBuild => 'Build';

  @override
  String get planPhaseBuildPlus => 'Build+';

  @override
  String get planPhasePeak => 'Peak';

  @override
  String get planPhaseRecovery => 'Recovery';

  @override
  String planTargetVsActual(int actual, int target) {
    return '$actual of $target TSS';
  }

  @override
  String planTargetOnly(int target) {
    return 'Target $target TSS';
  }

  @override
  String planEasyShare(int percent) {
    return '$percent% easy';
  }

  @override
  String get planOutside8020 => 'Below the 80/20 target';

  @override
  String get planLimitedIncrease => 'Held back by the weekly increase limit';

  @override
  String get planLimitedCtl => 'Held back by the CTL ramp limit';

  @override
  String get planLimitedHours => 'Held back by your weekly hours';

  @override
  String get planKnowledgeWarning =>
      'Some training knowledge could not be read, so built-in defaults were used.';

  @override
  String get planSessionFailed => 'Not created';

  @override
  String planSessionMinutes(int minutes, int load) {
    return '$minutes min · $load TSS';
  }

  @override
  String get planAddToCalendar => 'Add plan to calendar';

  @override
  String planCalendarDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events added to your calendar',
      one: '1 event added to your calendar',
    );
    return '$_temp0';
  }

  @override
  String get planCalendarDenied => 'Calendar access was denied.';

  @override
  String get planCalendarPickTitle => 'Choose a calendar';

  @override
  String get planCalendarNone => 'No writable calendar found.';

  @override
  String get planOpenSingle => 'Add to Google Calendar';

  @override
  String get sportTriathlon => 'Triathlon';

  @override
  String planGoalWeeks(int weeks) {
    return 'Plan length: $weeks weeks';
  }

  @override
  String get planGoalWeeksDefault =>
      'Default: 8 weeks, or the weeks until your event.';

  @override
  String get planGoalWeeksAuto => 'Use default';

  @override
  String get planGoalMixTitle => 'Sport mix (share of weekly load)';

  @override
  String planGoalMixTotal(int total) {
    return 'Total $total%';
  }

  @override
  String planGoalMixShare(String sport, int percent) {
    return '$sport: $percent%';
  }

  @override
  String get planCurveTitle => 'Weekly load';

  @override
  String get planCurveHint =>
      'Drag a week up or down within its shaded band (80–120% of the proposal). Lower a week by more than 10% for recovery.';

  @override
  String planCurveProposal(int percent, int baseline) {
    return 'Dashed line = proposed load from $baseline TSS, up to +$percent% a week. A default, not a rule.';
  }

  @override
  String get planCurveNeedsBaseline =>
      'Not enough synced history to propose a load. Enter a typical weekly load in the goal.';

  @override
  String planCurveWeekShort(int week) {
    return 'W$week';
  }

  @override
  String planCurveDragLabel(int week, int percent, int tss) {
    return 'Week $week · $tss TSS · $percent%';
  }

  @override
  String planCurveDelta(String delta) {
    return '$delta% vs. previous week';
  }

  @override
  String get planCurveSelectHint => 'Tap a week to fine-tune it.';

  @override
  String get planCurveIncrease => 'Increase by 5 TSS';

  @override
  String get planCurveDecrease => 'Decrease by 5 TSS';

  @override
  String get planCurveUndo => 'Undo';

  @override
  String get planCurveReset => 'Reset';

  @override
  String get planCurveResetTitle => 'Reset the load curve?';

  @override
  String get planCurveResetBody => 'Every week goes back to its proposed TSS.';

  @override
  String planCurveWeekSemantics(int week, int percent) {
    return 'Week $week, $percent% of proposal';
  }

  @override
  String planCurveTssValue(int tss) {
    return '$tss TSS';
  }

  @override
  String planWarnRamp(int percent) {
    return 'More than +$percent% over the last build week';
  }

  @override
  String get planWarnCtl => 'Above the CTL ramp limit';

  @override
  String get planWarnHours => 'Needs more than your weekly hours';

  @override
  String planWeekBySport(String sport, int tss) {
    return '$sport $tss';
  }

  @override
  String planTargetPlanned(int target, int planned) {
    return 'Target $target · planned $planned TSS';
  }

  @override
  String planCurveFactor(int percent) {
    return '$percent% of proposal';
  }

  @override
  String get planTakenLocal => 'Plan saved in TriIQ.';

  @override
  String get planTakenNotConnected =>
      'Plan saved in TriIQ. Connect Intervals.icu to send it there.';

  @override
  String get retryButton => 'Retry';

  @override
  String get planSessionSent => 'Sent to Intervals.icu';

  @override
  String get planSessionLocalOnly => 'Only in TriIQ';

  @override
  String get planSessionBadge => 'TriIQ plan';

  @override
  String get plannedTodayTitle => 'Planned today';

  @override
  String get plannedSourceIntervals => 'Intervals.icu';

  @override
  String get showAllSteps => 'Show all steps';

  @override
  String get showLessSteps => 'Show less';

  @override
  String get findAlternative => 'Find alternative';

  @override
  String get changeTraining => 'Change training';

  @override
  String get replaceTodaySession => 'Replace today\'s session';

  @override
  String get addAlongside => 'Add alongside';

  @override
  String replacesSession(String name) {
    return 'Replaces “$name”';
  }

  @override
  String workoutReplaced(String name) {
    return '$name replaces today\'s session';
  }

  @override
  String get workoutReplacedLocal => 'Today\'s plan session changed in TriIQ';

  @override
  String get replaceBothExist =>
      'The new workout was created, but the old one could not be deleted, so both are on your calendar. Delete the old one from the Calendar.';

  @override
  String get replaceRefusedSent =>
      'This session is in Intervals.icu. Connect and turn on Send plan to Intervals.icu to replace it.';

  @override
  String get replaceRefusedOffline =>
      'Connect Intervals.icu to replace this session.';

  @override
  String couldNotReplace(String error) {
    return 'Could not replace the session: $error';
  }

  @override
  String get planChangeMissing => 'That session is no longer in the plan.';

  @override
  String get planChangePast => 'That session or date is in the past.';

  @override
  String get planChangeOutsidePlan => 'That date is outside the plan\'s weeks.';

  @override
  String get planChangeInvalid => 'That change isn\'t valid for the goal.';

  @override
  String get proposalCurveTitle => 'Load graph change';

  @override
  String get proposalPlanTitle => 'New training plan';

  @override
  String get proposalMoveTitle => 'Move a session';

  @override
  String get proposalRemoveTitle => 'Remove a session';

  @override
  String get proposalApply => 'Apply';

  @override
  String get proposalDismiss => 'Dismiss';

  @override
  String get proposalApplied => 'Applied';

  @override
  String get proposalDismissed => 'Dismissed';

  @override
  String get proposalStale =>
      'Out of date: your goal or plan changed since. Ask again.';

  @override
  String proposalFailed(String error) {
    return 'Could not apply: $error';
  }

  @override
  String get proposalPlanHint =>
      'Apply opens the plan preview, where you take the plan.';

  @override
  String get chatToolPlanRead => 'Reading your plan…';

  @override
  String get chatToolProposing => 'Preparing a proposal…';

  @override
  String planCurveRampValue(int percent) {
    return 'Weekly increase: $percent%';
  }

  @override
  String get planCurveHold => 'Hold every 4th week';

  @override
  String get planCurveHoldHelp =>
      'Weeks 4, 8, 12… keep the previous week\'s load instead of ramping.';

  @override
  String get planGoalSlotsTitle => 'Session mix (share of each sport\'s load)';

  @override
  String get slotZ2 => 'Z2';

  @override
  String get slotIntervals => 'Intervals';

  @override
  String get slotLong => 'Long';

  @override
  String get planGoalSlotsReset => 'Use the goal\'s default mix';

  @override
  String get planGoalPrefsTitle => 'Preferences';

  @override
  String planGoalLongDay(String sport) {
    return 'Long $sport on';
  }

  @override
  String get planGoalAnyDay => 'Any';

  @override
  String get planGoalIntervalDays => 'Interval days';

  @override
  String get planGoalPerDay => 'Most sessions per day';

  @override
  String planNoteLongDay(String sport) {
    return 'The long $sport couldn\'t go on its preferred day.';
  }

  @override
  String get planNoteIntervalDay =>
      'The intervals couldn\'t go on a preferred interval day.';

  @override
  String get sessionDiagramTitle => 'Over time';

  @override
  String get sessionDiagramNoData =>
      'This activity has no time-series data (for example a manual entry).';

  @override
  String sessionDiagramError(String error) {
    return 'Could not load the time series: $error';
  }

  @override
  String get sessionIntervalsTitle => 'Intervals';

  @override
  String sessionIntervalN(int n) {
    return 'Interval $n';
  }

  @override
  String get streamPower => 'Power';

  @override
  String get streamHeartRate => 'Heart rate';

  @override
  String get streamSpeed => 'Speed';

  @override
  String get streamCadence => 'Cadence';

  @override
  String get streamAltitude => 'Altitude';

  @override
  String get sessionEvaluationTitle => 'Evaluation';

  @override
  String get verdictOnTarget => 'On target';

  @override
  String get verdictTooHard => 'Too hard';

  @override
  String get verdictTooEasy => 'Too easy';

  @override
  String get verdictCutShort => 'Cut short';

  @override
  String get evalNoPlan => 'No planned session to compare with.';

  @override
  String evalReasonShort(int actual, int planned) {
    return '$actual of $planned planned minutes';
  }

  @override
  String evalReasonTooIntense(String share, String limit) {
    return 'Planned easy, but $share of the time was above the first threshold (limit $limit)';
  }

  @override
  String evalReasonNotIntense(String share, String minimum) {
    return 'Planned hard, but only $share of the time was above the first threshold (at least $minimum expected)';
  }

  @override
  String evalReasonLoad(int actual, int planned) {
    return '$actual TSS against $planned planned';
  }

  @override
  String evalPlannedVsActual(String name) {
    return 'Planned: $name';
  }

  @override
  String evalMinutes(int actual, int planned, String delta) {
    return '$actual of $planned min ($delta)';
  }

  @override
  String evalLoad(int actual, int planned, String delta) {
    return '$actual of $planned TSS ($delta)';
  }

  @override
  String get evalSplitTitle => 'Intensity split';

  @override
  String get evalSplitNotAssessable =>
      'No zone times for this session, so its intensity split cannot be assessed.';

  @override
  String get domainLow => 'Low';

  @override
  String get domainModerate => 'Moderate';

  @override
  String get domainHigh => 'High';

  @override
  String evalDecoupling(String percent) {
    return 'Aerobic decoupling: $percent%';
  }

  @override
  String get evalDecouplingNotAssessable =>
      'Aerobic decoupling: not assessable (needs a steady session of at least an hour).';

  @override
  String get evalThresholdsNote =>
      'Thresholds follow the 80/20 rule in the training knowledge.';

  @override
  String get askTrainer => 'Ask the trainer';

  @override
  String chatAbout(String title) {
    return 'About: $title';
  }

  @override
  String plannedDoneTitle(String name) {
    return 'Done: $name';
  }

  @override
  String get plannedOpenActivity => 'Open the activity';

  @override
  String get weeklyReviewTitle => 'Weekly review';

  @override
  String weeklyReviewTopic(String date) {
    return 'Week of $date';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get weeklyCompliance => 'Plan vs done';

  @override
  String get weeklyNothingPlanned => 'Nothing was planned this week.';

  @override
  String weeklyComplianceValue(int percent, int done, int planned) {
    return '$percent% done ($done of $planned planned sessions)';
  }

  @override
  String weeklyLoadValue(int load, int planned) {
    return '$load of $planned planned TSS';
  }

  @override
  String weeklyMissed(String name) {
    return '✗ missed: $name';
  }

  @override
  String get weeklySplitTitle => 'Intensity (80/20)';

  @override
  String weeklyOutside8020(int percent) {
    return 'Only $percent% easy: below the 80/20 tolerance.';
  }

  @override
  String weeklyNoZones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions have no zone data and are not counted.',
      one: '1 session has no zone data and is not counted.',
    );
    return '$_temp0';
  }

  @override
  String get weeklyTrendTitle => 'Load trend';

  @override
  String get weeklyNoHistory => 'Not enough earlier weeks cached to compare.';

  @override
  String weeklyVsRecent(String delta, int average) {
    return '$delta% against the 4-week average of $average TSS';
  }

  @override
  String weeklyFitness(String ctl, String atl, String form) {
    return 'CTL $ctl, ATL $atl over the week; form $form';
  }

  @override
  String get weeklyNoteTitle => 'Next week';

  @override
  String get weeklyNoteLabel =>
      'Suggested by the trainer from the figures above (an inference, not a measurement).';

  @override
  String get weeklyOpenInChat => 'Discuss in Chat';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsBests => 'Personal bests';

  @override
  String bestPower(String duration, int watts) {
    return 'Best $duration power $watts W';
  }

  @override
  String bestTime(String distance, String time) {
    return 'Fastest $distance: $time';
  }

  @override
  String bestOther(String value) {
    return 'Best effort $value';
  }

  @override
  String bestWas(String best, String previous) {
    return '$best (was $previous)';
  }

  @override
  String get insightsEfficiency => 'Aerobic efficiency';

  @override
  String insightsEfficiencyChange(String value, String change, int sessions) {
    return 'Efficiency factor $value: $change% against your 6-week median ($sessions easy sessions)';
  }

  @override
  String insightsEfficiencyTooFew(String value, int min) {
    return 'Efficiency factor $value. Not enough history yet (needs $min easy sessions in 6 weeks).';
  }

  @override
  String get insightsRecovery => 'Recovery (estimate)';

  @override
  String insightsRecoveryHours(int hours) {
    return 'About $hours hours';
  }

  @override
  String insightsRecoveryRule(int tss) {
    return 'From $tss TSS, by the recovery rule in the training knowledge.';
  }

  @override
  String insightsRecoveryRuleForm(int tss, String form) {
    return 'From $tss TSS, plus extra time because your form is $form, by the recovery rule in the training knowledge.';
  }

  @override
  String insightsRecoveryConflict(String name) {
    return 'That runs into tomorrow\'s $name. Consider an easier alternative.';
  }

  @override
  String get newTrainingTitle => 'New training';

  @override
  String get newTrainingOk => 'OK';

  @override
  String get newTrainingDetails => 'Details';

  @override
  String get insightsPopupSetting => 'Show new training when opening the app';

  @override
  String get insightsPopupSettingHelp =>
      'Today\'s new sessions with their analysis, once each.';

  @override
  String get calendarSettingsTitle => 'Calendar';

  @override
  String get calendarSendPlan => 'Send plan to Intervals.icu';

  @override
  String get calendarSendPlanHelp => 'Off keeps training plans in TriIQ only.';

  @override
  String get calendarCopyEvents => 'Copy planned events from Intervals.icu';

  @override
  String get calendarCopyEventsHelp =>
      'Off hides workouts planned in Intervals.icu. Completed activities still sync.';

  @override
  String get calendarSendNowTitle => 'Send your plan now?';

  @override
  String calendarSendNowBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upcoming plan sessions are only in TriIQ.',
      one: '1 upcoming plan session is only in TriIQ.',
    );
    return '$_temp0';
  }

  @override
  String calendarSendNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count sessions',
      one: 'Send 1 session',
    );
    return '$_temp0';
  }

  @override
  String get calendarSendLater => 'Not now';

  @override
  String get planNotEnoughDays =>
      'Your training days cannot hold this week. Add a day or set a sport to 0%.';

  @override
  String get weeklyTargetsSectionTitle => 'Weekly targets';

  @override
  String get weeklyTargetsSectionHelp =>
      'A weekly training-time goal per sport. Leave a field blank for no target.';

  @override
  String weeklyTargetHoursLabel(String sport) {
    return '$sport — hours per week';
  }

  @override
  String get weeklyTargetShowOnToday => 'Show on Today';

  @override
  String get weeklyTargetShowOnTodayHelp =>
      'A progress ring per sport with a target set.';

  @override
  String get performanceTitle => 'Performance curves';

  @override
  String get performanceSubtitle =>
      'Best efforts by duration and distance, season against season';

  @override
  String get curveMetricPower => 'Power';

  @override
  String get curveMetricPace => 'Pace';

  @override
  String get curveMetricHr => 'Heart rate';

  @override
  String get curvePeriodThisSeason => 'This season';

  @override
  String get curvePeriodLastSeason => 'Last season';

  @override
  String get curvePeriodLast42 => 'Last 42 days';

  @override
  String curvePeriodNoData(String period) {
    return '$period: no data';
  }

  @override
  String curvePeriodRange(String period, String from, String to) {
    return '$period ($from – $to)';
  }

  @override
  String get curveAxisDuration => 'Duration';

  @override
  String get curveAxisDistance => 'Distance';

  @override
  String get curveAxisPower => 'Power (W)';

  @override
  String get curveAxisHr => 'Heart rate (bpm)';

  @override
  String curveAxisPace(String unit) {
    return 'Pace ($unit)';
  }

  @override
  String get curveTapHint => 'Tap or drag the chart to read a value.';

  @override
  String get curveOpenSession => 'Open session';

  @override
  String get curveSessionNotCached =>
      'That session isn\'t in the local cache yet — sync its date range first.';

  @override
  String get curvesEmpty => 'No efforts for this sport and metric yet.';

  @override
  String curvesLoadFailed(String error) {
    return 'Couldn\'t load the curves: $error';
  }

  @override
  String get keyEffortsTitle => 'Key efforts';

  @override
  String get keyEffortsChange => 'Change';

  @override
  String get modelCardTitle => 'Model fit (Intervals.icu)';

  @override
  String get modelNone => 'Intervals.icu returned no model fit for this curve.';

  @override
  String get modelSettingsValue => 'In your settings';

  @override
  String get modelNoSettingsValue => 'Not set in your Intervals.icu settings';

  @override
  String modelGap(String model, String settings, String diff) {
    return 'Model $model vs settings $settings: $diff';
  }

  @override
  String get modelCriticalSpeed => 'Critical speed';

  @override
  String get thresholdSuggestionsTitle => 'Threshold suggestions';

  @override
  String thresholdChangeLine(String from, String to) {
    return '$from → $to';
  }

  @override
  String thresholdBasisRideSeasonModel(String percent) {
    return 'This season\'s model fit is $percent% above your current FTP.';
  }

  @override
  String thresholdBasisRideRecentModel(String percent) {
    return 'The last 42 days\' model fit is $percent% below your current FTP — likely dropped.';
  }

  @override
  String thresholdBasisRunSeason60Min(String percent) {
    return 'Your season\'s ~60-minute best effort is $percent% faster than your current threshold pace.';
  }

  @override
  String get thresholdBasisRunSeason40MinHeuristic =>
      'Estimated from your season\'s ~40-minute best effort (heuristic: scaled toward a sustainable 60-minute pace).';

  @override
  String thresholdBasisRunRecent60Min(String percent) {
    return 'Your recent best effort is $percent% slower than your current threshold pace — likely dropped.';
  }

  @override
  String get thresholdBasisRunRecent40MinHeuristic =>
      'Estimated from your recent ~40-minute best effort (heuristic) — likely dropped.';

  @override
  String thresholdBasisSwimSeasonCss(String percent) {
    return 'CSS from your season\'s 400 m and 200 m bests is $percent% faster than your current threshold pace.';
  }

  @override
  String thresholdBasisSwimRecentCss(String percent) {
    return 'CSS from your recent 400 m / 200 m efforts is $percent% slower — likely dropped.';
  }

  @override
  String get thresholdReviewButton => 'Review';

  @override
  String get thresholdUndoButton => 'Undo';

  @override
  String get thresholdConfirmSheetTitle => 'Update threshold?';

  @override
  String get thresholdCurrentLabel => 'Current';

  @override
  String get thresholdNewLabel => 'New';

  @override
  String get thresholdZonesTitle => 'Zone ranges';

  @override
  String get thresholdZonesBefore => 'Before';

  @override
  String get thresholdZonesAfter => 'After';

  @override
  String get thresholdRecalcHrZones => 'Also recalculate HR zones';

  @override
  String get thresholdPastLoadNote =>
      'Past activities keep their recorded load — this only changes zones and new sessions going forward.';

  @override
  String get thresholdIndoorFtpNote =>
      'Indoor FTP is set separately and won\'t change.';

  @override
  String get thresholdEffortsUsedTitle => 'Efforts used';

  @override
  String get thresholdUpdating => 'Updating…';

  @override
  String thresholdUpdateFailed(String error) {
    return 'Couldn\'t update: $error';
  }

  @override
  String get thresholdUpdateSuccess => 'Updated';

  @override
  String get thresholdUndoSuccess => 'Restored to the previous value';

  @override
  String thresholdUndoFailed(String error) {
    return 'Couldn\'t undo: $error';
  }

  @override
  String get readinessTitle => 'Readiness';

  @override
  String get readinessReady => 'Ready';

  @override
  String get readinessCaution => 'Caution';

  @override
  String get readinessBackOff => 'Back off';

  @override
  String get readinessAllOk => 'All signals in your normal range';

  @override
  String readinessReasons(String signals) {
    return 'Due to $signals';
  }

  @override
  String get readinessNoData => 'No wellness data';

  @override
  String get readinessNoDataHint =>
      'Connect a watch or HRV app to Intervals.icu to see HRV, resting HR and sleep here.';

  @override
  String readinessWaiting(String date) {
    return 'Waiting for today\'s data (last: $date)';
  }

  @override
  String get readinessSignalHrv => 'HRV';

  @override
  String get readinessSignalRestingHr => 'Resting HR';

  @override
  String get readinessSignalSleep => 'Sleep';

  @override
  String get readinessSignalForm => 'Form';

  @override
  String get readinessSignalSubjective => 'Fatigue / soreness';

  @override
  String get readinessRatingOk => 'OK';

  @override
  String get readinessRatingNoBaseline => 'Not enough history yet';

  @override
  String get readinessRatingMissing => 'No value today';

  @override
  String readinessRangeHrv(String value, String mean) {
    return 'Normal from $value ms (avg $mean ms)';
  }

  @override
  String readinessRangeRestingHr(String value, String mean) {
    return 'Normal up to $value bpm (avg $mean bpm)';
  }

  @override
  String readinessRangeSleep(String value) {
    return 'Normal from $value h';
  }

  @override
  String readinessRangeForm(String value) {
    return 'Normal from $value';
  }

  @override
  String readinessSubjectiveValues(String fatigue, String soreness) {
    return 'Fatigue $fatigue · soreness $soreness (1 good, 4 bad)';
  }

  @override
  String readinessDevice(String value) {
    return 'Device readiness $value';
  }

  @override
  String get readinessTrend => 'Last 30 days';

  @override
  String get readinessDisclaimer =>
      'Thresholds are general defaults from the training knowledge, not medical advice.';

  @override
  String get readinessHintTitle => 'Consider an easier day';

  @override
  String readinessHintBody(String level, String session) {
    return 'Readiness is $level and today\'s plan has $session.';
  }

  @override
  String get readinessTopic => 'Readiness today';

  @override
  String readinessChatDraft(String level, String reasons, String session) {
    return 'My readiness today is $level ($reasons). Should I still do $session?';
  }

  @override
  String get proposalSwapTitle => 'Swap two sessions';

  @override
  String get proposalLetGoTitle => 'Let it go';

  @override
  String get proposalCatchUpTitle => 'Catch up a missed session';

  @override
  String adaptMissedReason(String day) {
    return 'Missed on $day: nothing logged for it.';
  }

  @override
  String adaptLoadUnderReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  ) {
    return 'Week $week: $actual of $target TSS done. Next week $from → $to TSS.';
  }

  @override
  String adaptLoadOverReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  ) {
    return 'Week $week: $actual of $target TSS done, well above plan. Next week $from → $to TSS.';
  }

  @override
  String adaptLoadFloor(int load) {
    return 'Held at 80 % of the proposal; the ramp alone would say $load TSS.';
  }

  @override
  String get adaptLoadRegenerate =>
      'The week\'s sessions follow when you regenerate the plan.';

  @override
  String adaptReadinessReason(String level) {
    return 'Readiness: $level.';
  }

  @override
  String get todayAdjustmentsTitle => 'Plan adjustments';

  @override
  String get planPhaseTaper => 'Taper';

  @override
  String get planPhaseRace => 'Race week';

  @override
  String get planCurveRaceShort => 'Race';

  @override
  String planEventBeyondPlan(int weeks) {
    return 'Your event is $weeks weeks away, more than one block: this block builds without a taper. A plan ending with the taper can be generated once the event is at most 16 weeks away.';
  }

  @override
  String todayRaceCountdown(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Race in $days days',
      one: 'Race tomorrow',
    );
    return '$_temp0';
  }

  @override
  String get todayRaceDay => 'Race day!';

  @override
  String get feelDialogTitle => 'How did it feel?';

  @override
  String get feelScaleHint => '1 good, 4 bad';

  @override
  String get feelFatigueLabel => 'Fatigue';

  @override
  String get feelSorenessLabel => 'Muscle soreness';

  @override
  String get feelSaveButton => 'Save';

  @override
  String get feelActionLabel => 'Fatigue & soreness';

  @override
  String get feelNotConnectedHint => 'Connect Intervals.icu to set this';

  @override
  String get feelSettingsTitle => 'Fatigue & soreness';

  @override
  String get feelPromptOnNewActivity => 'Prompt for a recent activity';

  @override
  String get feelPromptOnNewActivityHelp =>
      'Ask once, the first time a recent activity\'s detail screen opens, if that day has nothing set yet. Setting it manually on any activity always works, on or off.';

  @override
  String get deleteDayTrainingsTitle => 'Delete all trainings of the day?';

  @override
  String deleteDayTrainingsConfirm(int count) {
    return '$count planned session(s) are removed from your Intervals.icu calendar. This can\'t be undone.';
  }

  @override
  String dayTrainingsDeleted(int count) {
    return '$count session(s) deleted.';
  }

  @override
  String get customizeTodayTooltip => 'Customize Today';

  @override
  String get customizeTodayTitle => 'Customize Today';

  @override
  String get customizeTodayHelp =>
      'Drag to reorder. Switch a section off to remove it from Today.';

  @override
  String get customizeTodayReset => 'Reset';

  @override
  String get todaySectionReadiness => 'Readiness';

  @override
  String get todaySectionMetrics => 'Load metrics';

  @override
  String get todaySectionThresholds => 'Threshold suggestions';

  @override
  String get eventsTitle => 'Events';

  @override
  String get moreEventsSubtitle => 'Races, notes, holidays and more';

  @override
  String get eventsEmpty => 'No events yet. Add a race or a note.';

  @override
  String get eventsUpcoming => 'Upcoming';

  @override
  String get eventsPast => 'Past';

  @override
  String get eventAddTooltip => 'Add event';

  @override
  String get eventNewTitle => 'New event';

  @override
  String get eventEditTitle => 'Edit event';

  @override
  String get eventCategoryLabel => 'Type';

  @override
  String get eventNameLabel => 'Name';

  @override
  String get eventDateLabel => 'Date';

  @override
  String get eventEndDateLabel => 'Until (optional)';

  @override
  String get eventSportLabel => 'Sport';

  @override
  String get eventDescriptionLabel => 'Description';

  @override
  String get eventSaveButton => 'Save';

  @override
  String get eventNameRequired => 'Enter a name';

  @override
  String get eventNotConnected =>
      'Connect Intervals.icu to add or edit events.';

  @override
  String eventCouldNotSave(String error) {
    return 'Could not save the event: $error';
  }

  @override
  String eventDeleteConfirm(String name) {
    return '“$name” is removed from your Intervals.icu calendar. This can\'t be undone.';
  }

  @override
  String eventDeleted(String name) {
    return '“$name” deleted.';
  }

  @override
  String get eventCategoryRaceA => 'Race (A)';

  @override
  String get eventCategoryRaceB => 'Race (B)';

  @override
  String get eventCategoryRaceC => 'Race (C)';

  @override
  String get eventCategoryNote => 'Note';

  @override
  String get eventCategoryHoliday => 'Holiday';

  @override
  String get eventCategorySick => 'Sick';

  @override
  String get eventCategoryInjured => 'Injured';

  @override
  String get eventCategoryTarget => 'Target';

  @override
  String get eventCategorySeasonStart => 'Season start';

  @override
  String get chartZoomIn => 'Zoom in';

  @override
  String get chartZoomOut => 'Zoom out';

  @override
  String get chartZoomReset => 'Show all';

  @override
  String get streamSmoothing => 'Smoothing';

  @override
  String get smoothOff => 'Off';

  @override
  String get zoomToInterval => 'Zoom to interval';

  @override
  String get metricTssTodayExplainer =>
      'TSS (training stress score) puts one number on how hard today\'s sessions were, from duration and intensity. 100 is roughly an hour at your threshold. Compare it with what was planned, not with other people.';

  @override
  String get metricTssWeekExplainer =>
      'The sum of this week\'s TSS (Monday to Sunday) against what the plan asks for — the quickest check on whether you are on track. A single easy or hard day matters less than the week as a whole.';

  @override
  String get tileShowHistory => 'Show history';

  @override
  String get weekActivitiesThisWeek => 'This week';

  @override
  String get weekActivitiesAllSports => 'All sports';

  @override
  String get weekActivitiesEmpty => 'No activities this week yet.';

  @override
  String get yearGoalsTitle => 'Year goals';

  @override
  String get yearGoalsHelp =>
      'A distance goal per sport for this calendar year. Leave a field blank for no goal. Progress counts the activities cached on this device — sync the year in Settings → Sync for the full picture.';

  @override
  String yearGoalKmLabel(String sport) {
    return '$sport goal (km per year)';
  }

  @override
  String get yearGoalShowOnToday => 'Show on Today';

  @override
  String get yearGoalShowOnTodayHelp => 'A progress card for your year goals.';

  @override
  String get yearGoalOnTrack => 'On track';

  @override
  String yearGoalAhead(String km) {
    return '$km km ahead of pace';
  }

  @override
  String yearGoalBehind(String km) {
    return '$km km behind pace';
  }

  @override
  String yearGoalProjection(String km) {
    return 'On pace for $km km';
  }

  @override
  String get todaySectionYearGoals => 'Year goals';

  @override
  String get analysisTitle => 'Metric explorer';

  @override
  String get analysisFilters => 'Filters';

  @override
  String get analysisPeriod => 'Period';

  @override
  String get analysisRange30d => '30 days';

  @override
  String get analysisRange90d => '90 days';

  @override
  String get analysisRange6m => '6 months';

  @override
  String get analysisRange1y => '1 year';

  @override
  String get analysisRangeYtd => 'This year';

  @override
  String get analysisRangeCustom => 'Custom…';

  @override
  String get analysisSport => 'Sport';

  @override
  String get analysisSportAll => 'All sports';

  @override
  String get analysisResolution => 'Resolution';

  @override
  String get analysisDay => 'Day';

  @override
  String get analysisWeek => 'Week';

  @override
  String get analysisRolling => 'Rolling average';

  @override
  String get analysisShowExtremes => 'Mark min / max';

  @override
  String get analysisShowBand => 'Standard deviation band (±1 σ)';

  @override
  String get analysisMetrics => 'Metrics';

  @override
  String get analysisMetricTss => 'Training load (TSS)';

  @override
  String get analysisMetricHours => 'Training time (h)';

  @override
  String get analysisMetricDistance => 'Distance (km)';

  @override
  String get analysisMetricSleep => 'Sleep (h)';

  @override
  String get analysisHint =>
      'Tap any graph to compare all metrics at that point. Pinch or use + / − to zoom them together.';

  @override
  String get analysisNoData => 'No data in this period.';

  @override
  String get analysisPickMetric => 'Select at least one metric above.';

  @override
  String analysisWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String activityChatDraft(String name, String date) {
    return 'Please review my session “$name” from $date: how did it go, and what should I do differently or next?';
  }

  @override
  String weeklyReviewChatDraft(String date) {
    return 'Please review my training week of $date: what went well, what didn\'t, and what should I focus on next week?';
  }

  @override
  String tileChatDraft(String label, String value) {
    return 'My $label is $value right now. What does that mean for my training, and should I change anything this week?';
  }

  @override
  String analysisChatDraft(String period) {
    return 'Here is my analysis for $period. What stands out, and what should I adjust?';
  }

  @override
  String get seasonTitle => 'Season';

  @override
  String get moreSeasonSubtitle =>
      'Fitness forecast, race calendar, race predictor';

  @override
  String get seasonNoFitness =>
      'No fitness data yet. Sync Intervals.icu first.';

  @override
  String seasonLoadError(String error) {
    return 'Could not load the season: $error';
  }

  @override
  String get forecastTitle => 'Fitness forecast';

  @override
  String get forecastSubtitle =>
      'Fitness, fatigue and form projected from your planned sessions. Days without a plan count as rest.';

  @override
  String get forecastCtl => 'Fitness (CTL)';

  @override
  String get forecastAtl => 'Fatigue (ATL)';

  @override
  String get forecastForm => 'Form';

  @override
  String forecastRaceForm(String name, String form) {
    return 'Form on race day ($name): $form';
  }

  @override
  String get forecastBandLoaded =>
      'Still carrying fatigue — expect heavy legs.';

  @override
  String get forecastBandNeutral => 'Balanced: neither fresh nor tired.';

  @override
  String get forecastBandFresh => 'Fresh — a good place to race from.';

  @override
  String get forecastBandDetrained =>
      'Very fresh: fitness is starting to fade from too much rest.';

  @override
  String forecastPeak(String date, String form) {
    return 'Form peaks on $date at $form.';
  }

  @override
  String forecastPlannedEnd(String date, String ctl, String form) {
    return 'Fitness on $date: $ctl (form $form)';
  }

  @override
  String get seasonTimelineTitle => 'Season timeline';

  @override
  String get seasonNoRaces =>
      'No races yet. Add a race (priority A, B or C) under More → Events, or set an event date in your training goal.';

  @override
  String seasonRaceLine(String priority, String name, String date, int weeks) {
    return '$priority race · $name · $date ($weeks wk)';
  }

  @override
  String get blockBase => 'Base';

  @override
  String get blockBuild => 'Build';

  @override
  String get blockTaper => 'Taper';

  @override
  String get blockRace => 'Race';

  @override
  String get blockRecovery => 'Recovery';

  @override
  String get conflictsTitle => 'Conflicts';

  @override
  String get conflictNone => 'No conflicts in your race calendar.';

  @override
  String conflictTooCloseA(String first, String second, int days) {
    return '$first and $second are both A races only $days days apart. Peaking twice needs about 6 weeks — make one a B race.';
  }

  @override
  String conflictInsideTaper(String first, String second) {
    return '$second falls in the taper for $first. Treat it as a training race or skip it.';
  }

  @override
  String conflictSameDay(String first, String second) {
    return '$first and $second are on the same day.';
  }

  @override
  String conflictInsideRecovery(String first, String second) {
    return '$second comes while you are still recovering from $first.';
  }

  @override
  String conflictDuringIllness(String first) {
    return '$first falls in a period you logged as sick or injured.';
  }

  @override
  String get healthSickTitle => 'You are logged as sick';

  @override
  String get healthInjuredTitle => 'You are logged as injured';

  @override
  String get healthReturningTitle => 'Easing back into training';

  @override
  String healthSickSubtitle(int days) {
    return 'Day $days. Rest is the plan — hard sessions come off the calendar.';
  }

  @override
  String healthInjuredSubtitle(int days) {
    return 'Day $days. Affected sessions become easy cross-training.';
  }

  @override
  String healthReturnSubtitle(String date) {
    return 'Load builds from 50 % back to normal until $date.';
  }

  @override
  String get healthNoChanges => 'Nothing planned needs to change.';

  @override
  String get healthChangeRest => 'Rest';

  @override
  String healthChangeEasier(int minutes, int load) {
    return 'Easy, $minutes min (about $load TSS)';
  }

  @override
  String healthChangeCross(String sport, int minutes) {
    return 'Easy $sport, $minutes min instead';
  }

  @override
  String get healthReasonIllness => 'Illness';

  @override
  String get healthReasonInjury => 'Injury';

  @override
  String get healthReasonReturn => 'Return ramp';

  @override
  String healthApply(int count) {
    return 'Apply $count changes';
  }

  @override
  String get healthApplyConfirm =>
      'This changes your planned sessions on Intervals.icu and in TriIQ.';

  @override
  String healthApplyDone(int count) {
    return '$count sessions updated.';
  }

  @override
  String healthApplyFailed(int done, String error) {
    return 'Stopped after $done: $error';
  }

  @override
  String get healthLogHint =>
      'Sick or injured? Log it as an event and TriIQ will reshape your plan.';

  @override
  String get healthLogButton => 'Log illness or injury';

  @override
  String get racePredictorTitle => 'Race predictor';

  @override
  String get racePredictorSubtitle =>
      'Finish time, pacing and fuelling from your power and pace curves, your fitness and your race-day form.';

  @override
  String get raceChoose => 'Race';

  @override
  String get raceSpec5k => '5 km run';

  @override
  String get raceSpec10k => '10 km run';

  @override
  String get raceSpecHalf => 'Half marathon';

  @override
  String get raceSpecMarathon => 'Marathon';

  @override
  String get raceSpecRide100 => '100 km ride';

  @override
  String get raceSpecSprint => 'Sprint triathlon';

  @override
  String get raceSpecOlympic => 'Olympic triathlon';

  @override
  String get raceSpec703 => 'Half-distance triathlon (70.3)';

  @override
  String get raceSpec1406 => 'Full-distance triathlon (140.6)';

  @override
  String get raceDayLabel => 'Race day';

  @override
  String get raceDayAuto => 'From my races';

  @override
  String get raceDayNone => 'No date (ignore form)';

  @override
  String get raceHot => 'Hot conditions';

  @override
  String get raceTotal => 'Predicted finish';

  @override
  String raceTransitions(String t1, String t2) {
    return 'Transitions: T1 $t1, T2 $t2';
  }

  @override
  String get raceLegSwim => 'Swim';

  @override
  String get raceLegRide => 'Ride';

  @override
  String get raceLegRun => 'Run';

  @override
  String raceMissing(String legs) {
    return 'Not enough data for: $legs. Some hard efforts in training, then sync, will fix this.';
  }

  @override
  String raceSlowdown(String pct) {
    return 'Includes a $pct % allowance for fitness (CTL) and race-day form.';
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
  String get racePacingTitle => 'Pacing plan';

  @override
  String get pacingStartControlled => 'Start controlled';

  @override
  String get pacingHoldSteady => 'Hold steady';

  @override
  String get pacingFinishStrong => 'Finish strong';

  @override
  String get pacingNegativeSplit => 'Settle in, build gently';

  @override
  String pacingRange(String start, String end) {
    return '$start–$end km';
  }

  @override
  String get fuelingTitle => 'Fuelling plan';

  @override
  String get fuelNone => 'Under about 45 minutes water is enough.';

  @override
  String fuelCarbsPerHour(int g) {
    return '$g g carbohydrate per hour';
  }

  @override
  String fuelFluidPerHour(int ml) {
    return '$ml ml fluid per hour';
  }

  @override
  String fuelSodiumPerHour(int mg) {
    return '$mg mg sodium per hour';
  }

  @override
  String fuelTotals(int carbs, int fluid) {
    return 'Race total: $carbs g carbohydrate, $fluid ml fluid';
  }

  @override
  String fuelDayBefore(int g) {
    return 'Day before: about $g g carbohydrate';
  }

  @override
  String fuelPreRace(int g) {
    return '1–4 h before the start: about $g g carbohydrate';
  }

  @override
  String fuelStep(int minute, String sport, int carbs, int fluid) {
    return '$minute min · $sport: $carbs g carbs, $fluid ml';
  }

  @override
  String get raceDisclaimer =>
      'A model estimate from your best efforts, not a promise. Course, weather and pacing decide the day.';

  @override
  String get raceAskTrainer => 'Ask the trainer';

  @override
  String raceChatDraft(String time, String race) {
    return 'My race predictor says $time for the $race. Is that realistic, and what should I work on before race day?';
  }

  @override
  String get brickTitleBikeRun => 'Brick: bike → run';

  @override
  String get brickTitleSwimBike => 'Brick: swim → bike';

  @override
  String brickTransition(String time) {
    return 'Transition: $time';
  }

  @override
  String brickSettle(String time) {
    return 'Legs settled after $time';
  }

  @override
  String brickEarly(String pct) {
    return 'First 10 min at $pct % of your later speed';
  }

  @override
  String get brickVerdictGood => 'Strong brick';

  @override
  String get brickVerdictOk => 'Decent brick';

  @override
  String get brickVerdictRough => 'Rough start off the bike';

  @override
  String get brickVerdictUnknown => 'Transition only';

  @override
  String get brickNoteSettledFast => 'Legs came round quickly.';

  @override
  String get brickNoteSettledSlow => 'It took a long time to find your rhythm.';

  @override
  String get brickNoteSlowStart =>
      'The opening minutes were much slower than the rest.';

  @override
  String get brickNoteHighEarlyCost =>
      'Heart rate was high for the speed early on — pace the first 10 minutes by effort, not speed.';

  @override
  String get brickNoteHardFirstLeg =>
      'The first leg was hard (intensity 85 % or more), which usually costs the next one.';

  @override
  String get brickNoteQuickTransition => 'Quick transition.';

  @override
  String get brickNoteLongTransition =>
      'Long transition — fine in training, but practise it before a race.';

  @override
  String get brickNoteNoStream =>
      'No data stream for the second leg, so only the transition is judged.';

  @override
  String brickSessions(String first, String second) {
    return '$first + $second';
  }

  @override
  String get memoryTitle => 'Trainer memory';

  @override
  String get moreMemorySubtitle => 'What the trainer remembers about you';

  @override
  String get memoryIntro =>
      'Standing preferences the trainer follows in every chat, e.g. \"No hard sessions on Fridays\" or \"Swim only in the mornings\". You can add, edit by deleting and re-adding, or remove them here. The trainer only saves one when you ask it to.';

  @override
  String get memoryEmpty => 'Nothing remembered yet.';

  @override
  String get memoryAddHint => 'Add a preference…';

  @override
  String get memoryAddButton => 'Add';

  @override
  String get memoryFromTrainer => 'saved by the trainer';

  @override
  String get memoryDelete => 'Remove';

  @override
  String get memoryClear => 'Remove all';

  @override
  String get memoryClearConfirm => 'Remove everything the trainer remembers?';

  @override
  String memoryFull(int max) {
    return 'The memory is full ($max items). Remove one first.';
  }

  @override
  String memoryCount(int count, int max) {
    return '$count of $max';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupIntro =>
      'Export your synced data, plans, knowledge library and settings as one JSON file, and restore it on another device. Your Intervals.icu and AI keys are not included — reconnect after restoring.';

  @override
  String get backupIncludeCaches => 'Include chart caches';

  @override
  String get backupIncludeCachesHelp =>
      'Session streams and performance curves. Larger file; they can be fetched again.';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupRestore => 'Restore from backup…';

  @override
  String backupExported(String path) {
    return 'Backup saved to $path';
  }

  @override
  String get backupShared => 'Backup ready to share.';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupRestoreTitle => 'Restore this backup?';

  @override
  String backupRestoreBody(
    String date,
    int activities,
    int plans,
    int total,
    int settings,
  ) {
    return 'From $date: $activities activities, $plans plans, $total rows in all, $settings settings. This replaces the synced data, plans and knowledge library on this device.';
  }

  @override
  String get backupRestoreConfirm => 'Replace';

  @override
  String get backupRestored =>
      'Restored. Restart TriIQ to apply the settings, and reconnect Intervals.icu if needed.';

  @override
  String get backupUnknownDate => 'an unknown date';

  @override
  String forecastAssumed(String date) {
    return 'Nothing is planned after $date, so from then on the forecast assumes you keep training at your current fitness level.';
  }

  @override
  String pendingTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get pendingSubtitle =>
      'Made while Intervals.icu was out of reach. They are sent automatically when you are back online.';

  @override
  String get pendingSyncNow => 'Send now';

  @override
  String pendingFailedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes could not be sent',
      one: '1 change could not be sent',
    );
    return '$_temp0';
  }

  @override
  String get pendingRetry => 'Retry';

  @override
  String get pendingDiscard => 'Discard';

  @override
  String planQueuedOffline(int count) {
    return '$count sessions will be sent to Intervals.icu when you are back online.';
  }

  @override
  String get replaceQueuedOffline =>
      'Saved here. Intervals.icu can\'t be reached, so the swap will be sent when you are back online.';

  @override
  String get fatigueWatchTitle => 'Fatigue is building';

  @override
  String get fatigueWarningTitle => 'Fatigue warning';

  @override
  String get fatigueAdviceWatch =>
      'Keep the next hard session honest — if it feels bad, cut it short or swap it for an easy one.';

  @override
  String get fatigueAdviceWarning =>
      'Several signals have been off for days. Take an easy or rest day and ask the trainer to ease this week.';

  @override
  String fatigueSignalHrv(int bad, int of) {
    return 'HRV below your normal on $bad of the last $of days';
  }

  @override
  String fatigueSignalRestingHr(int bad, int of) {
    return 'Resting heart rate raised on $bad of the last $of days';
  }

  @override
  String fatigueSignalSleep(int bad, int of) {
    return 'Under 6.5 hours of sleep on $bad of the last $of nights';
  }

  @override
  String fatigueSignalForm(int bad, int of) {
    return 'Form deeply negative on $bad of the last $of days';
  }

  @override
  String fatigueSignalRamp(int bad, int of) {
    return 'Fitness ramping up fast on $bad of the last $of days';
  }

  @override
  String fatigueSignalSubjective(int bad, int of) {
    return 'You rated fatigue or soreness high on $bad of the last $of days';
  }

  @override
  String get fatigueAsk => 'Ask the trainer';

  @override
  String get fatigueDismiss => 'Not now';

  @override
  String fatigueChatDraft(String reasons) {
    return 'My fatigue check says: $reasons. Should I change anything this week?';
  }

  @override
  String briefingTitle(String date) {
    return 'Today · $date';
  }

  @override
  String get briefingNoSession => 'No session planned today.';

  @override
  String briefingSessions(String sessions) {
    return 'Planned: $sessions';
  }

  @override
  String briefingMore(int count) {
    return '+$count more';
  }

  @override
  String briefingReadiness(String level) {
    return 'Readiness: $level';
  }

  @override
  String briefingFatigue(String level) {
    return 'Fatigue: $level';
  }

  @override
  String briefingForm(String form, String ctl) {
    return 'Form $form · CTL $ctl';
  }

  @override
  String briefingRace(String race) {
    return '$race';
  }

  @override
  String briefingHealth(String kind) {
    return 'You are logged as $kind — check the Season screen.';
  }

  @override
  String get briefingSick => 'sick';

  @override
  String get briefingInjured => 'injured';

  @override
  String get briefingLevelReady => 'ready';

  @override
  String get briefingLevelCaution => 'caution';

  @override
  String get briefingLevelBackOff => 'back off';

  @override
  String get briefingLevelWatch => 'building';

  @override
  String get briefingLevelWarning => 'warning';

  @override
  String get morningBriefing => 'Morning briefing';

  @override
  String get morningBriefingHelp =>
      'A notification with today\'s session, readiness and form. It is prepared from your last sync, so readiness appears when your watch data is already in.';

  @override
  String get weeklyHoursLabel => 'All sports';

  @override
  String weeklyHoursTotal(String hours) {
    return '$hours h';
  }

  @override
  String weeklyHoursOfTarget(String hours, String target) {
    return '$hours / $target h';
  }

  @override
  String get dayProposeTraining => 'Propose training';

  @override
  String get dayProposeTrainingHelp =>
      'Like Train now, but the session is placed on this day.';

  @override
  String get readinessFitness => 'Fitness';

  @override
  String get dayCardToday => 'Today';

  @override
  String dayCardLoadOfPlanned(int done, int planned) {
    return '$done / $planned TSS';
  }

  @override
  String dayCardLoadDone(int done) {
    return '$done TSS';
  }

  @override
  String get routeTitle => 'Route';

  @override
  String get heroSyncNow => 'Sync now';

  @override
  String get heroMoreTooltip => 'More actions';

  @override
  String heroSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get ollamaKeyCloudOnly =>
      'An Ollama API key is only used with Ollama Cloud (https://ollama.com). A self-hosted server needs no key here.';

  @override
  String get ollamaHttpWarning =>
      'Unencrypted (http): prompts and training data are sent in plain text. Use it only for a server on your own network.';

  @override
  String get dayAddEvent => 'Add event';

  @override
  String get dayAddEventHelp => 'Sick day, injury, holiday, note, race …';

  @override
  String get anTitle => 'Training analytics';

  @override
  String get anSubtitle =>
      'Fitness by sport, intensity split, load safety, aerobic base';

  @override
  String get anSportSwim => 'Swim';

  @override
  String get anSportRide => 'Ride';

  @override
  String get anSportRun => 'Run';

  @override
  String get anSportOther => 'Other';

  @override
  String get anSportFitnessTitle => 'Fitness by sport';

  @override
  String get anSportFitnessHint =>
      'Each line is that sport\'s own CTL or ATL, computed from its training load with the same 42/7-day model; together they add up to your total.';

  @override
  String get anTotalLabel => 'Total';

  @override
  String get anLoadSourceTitle => 'Where your load comes from';

  @override
  String get anLoadSourceTap => 'Tap a week to see its split.';

  @override
  String anLoadWeekOf(String week, int total) {
    return 'Week of $week: $total TSS';
  }

  @override
  String anShareEntry(String sport, int percent) {
    return '$sport $percent%';
  }

  @override
  String get anIntensityTitle => 'Intensity distribution';

  @override
  String get anWeekly => 'Weekly';

  @override
  String get anMonthly => 'Monthly';

  @override
  String get anZoneEasy => 'Easy';

  @override
  String get anZoneThreshold => 'Threshold';

  @override
  String get anZoneHard => 'Hard';

  @override
  String get anIntensityHint =>
      'Share of zone time. Easy is below the first threshold, threshold is the zones around it, hard is above. Power zones first, then heart rate, then pace.';

  @override
  String get anModelPolarized => 'Polarized';

  @override
  String get anModelPyramidal => 'Pyramidal';

  @override
  String get anModelThreshold => 'Threshold-heavy';

  @override
  String get anModelHigh => 'High-intensity';

  @override
  String get anModelUnknown => 'Not enough zone time';

  @override
  String anPolarizationIndex(String value) {
    return 'Polarization index $value';
  }

  @override
  String anIntensityPeriod(String period, String model) {
    return '$period: $model';
  }

  @override
  String anIntensitySplit(int easy, int threshold, int hard) {
    return '$easy% easy · $threshold% threshold · $hard% hard';
  }

  @override
  String get anRangeOverall => 'Whole range';

  @override
  String anSessionsNoZones(int count) {
    return '$count sessions without zone data are not counted.';
  }

  @override
  String get anSafetyTitle => 'Load safety';

  @override
  String get anAcwr => 'Acute:chronic';

  @override
  String get anRamp => 'Ramp rate';

  @override
  String get anMonotony => 'Monotony';

  @override
  String get anStrain => 'Strain';

  @override
  String get anRiskSafe => 'Safe';

  @override
  String get anRiskRisky => 'Risky';

  @override
  String get anRiskHigh => 'Too fast';

  @override
  String get anRiskHighMonotony => 'Too uniform';

  @override
  String get anAcwrBands =>
      '7-day load over 28-day load. Safe 0.8–1.3, risky up to 1.5, too fast above. The shaded band is the safe range.';

  @override
  String get anRampBands =>
      'CTL change over 7 days. Safe up to 5 a week, risky up to 8, too fast above.';

  @override
  String get anMonotonyBands =>
      'Mean daily load over its spread across 7 days. Safe up to 1.5, risky up to 2, above that the week is too uniform. Strain is the week\'s load times monotony.';

  @override
  String get anSafetyNeedHistory =>
      'The ratio needs 28 days of cached activities.';

  @override
  String get anAerobicTitle => 'Aerobic base';

  @override
  String get anAerobicHint =>
      'Long steady sessions: at least 60 minutes, mostly below the first threshold. Higher efficiency factor and lower decoupling mean a stronger base.';

  @override
  String get anEfTitle => 'Efficiency factor';

  @override
  String get anDecouplingTitle => 'Decoupling (Pa:HR)';

  @override
  String anEfTrend(String percent) {
    return 'EF trend $percent% per month';
  }

  @override
  String get anEfTrendFlat => 'EF trend: flat';

  @override
  String get anDecouplingBands =>
      'Under 5% is solid, 5–10% developing, above 10% the heart rate drifted too far. The shaded band is the solid range.';

  @override
  String get anAerobicEmpty =>
      'No long steady sessions with an efficiency factor or decoupling in this range.';

  @override
  String anAerobicSessions(int count) {
    return '$count sessions';
  }

  @override
  String anLatestDecoupling(String value) {
    return 'Latest decoupling $value%';
  }

  @override
  String get cmpTitle => 'Compare';

  @override
  String get cmpSubtitle =>
      'Two runs or rides overlaid on their streams and course, or two blocks of training';

  @override
  String get cmpCompareWith => 'Compare with…';

  @override
  String get cmpTabActivities => 'Activities';

  @override
  String get cmpTabPeriods => 'Periods';

  @override
  String get cmpPickFirst => 'Pick the first activity';

  @override
  String get cmpPickSecond => 'Pick the second activity';

  @override
  String get cmpPickTitle => 'Choose an activity';

  @override
  String get cmpPickEmpty => 'No cached runs or rides to compare yet.';

  @override
  String get cmpChooseTwo =>
      'Pick two activities of the same sport to overlay them.';

  @override
  String get cmpAxisDistance => 'Distance';

  @override
  String get cmpAxisTime => 'Time';

  @override
  String get cmpNoDistance =>
      'One of these has no distance stream, so only the time axis is available.';

  @override
  String get cmpNoStreams =>
      'No stream data for these activities. Connect to Intervals.icu and try again.';

  @override
  String get cmpNoMetric => 'Neither activity recorded this stream.';

  @override
  String get cmpTrackerHint =>
      'Touch the chart or tap the map to move the tracker.';

  @override
  String get cmpCourseTitle => 'Course';

  @override
  String get cmpCourseOpen => 'Open the map full screen';

  @override
  String get cmpStatsTitle => 'Side by side';

  @override
  String get cmpDistance => 'Distance';

  @override
  String get cmpTime => 'Moving time';

  @override
  String get cmpElevation => 'Elevation';

  @override
  String get cmpLoad => 'Load (TSS)';

  @override
  String get cmpAvgHr => 'Avg heart rate';

  @override
  String get cmpAvgPower => 'Avg power';

  @override
  String get cmpAvgSpeed => 'Avg pace / speed';

  @override
  String get cmpEf => 'Efficiency factor';

  @override
  String get cmpDecoupling => 'Decoupling';

  @override
  String get cmpEasyShare => 'Easy share';

  @override
  String get cmpSessions => 'Sessions';

  @override
  String cmpBlockDays(int days) {
    return '$days days';
  }

  @override
  String get cmpThisBlock => 'This block';

  @override
  String get cmpPreviousBlock => 'Previous block';

  @override
  String get cmpBlockLength => 'Block length';

  @override
  String cmpBlockRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get cmpCumulative => 'Cumulative by day';

  @override
  String cmpDayOfBlock(int day) {
    return 'Day $day';
  }

  @override
  String get cmpNoBlockActivities => 'No runs or rides in these two blocks.';

  @override
  String get cmpFirst => 'A';

  @override
  String get cmpSecond => 'B';

  @override
  String get chartOptions => 'Chart options';

  @override
  String get chartOptionsStreams => 'Streams';

  @override
  String get chartOptionsAxis => 'X axis';

  @override
  String get chartOptionsRange => 'Range';

  @override
  String get chartOptionsView => 'View';

  @override
  String get chartOptionsSport => 'Sport';

  @override
  String get chartOptionsBlock => 'Block length';

  @override
  String get readinessOptionsTitle => 'Readiness signals';

  @override
  String get readinessOptionsHint =>
      'Choose which values count toward the score, the status and the trainer\'s advice. Switched-off values are ignored everywhere. At least one must stay on.';

  @override
  String get readinessOptionHrv =>
      'Heart-rate variability against your own 60-day baseline';

  @override
  String get readinessOptionRestingHr =>
      'Resting heart rate against your own baseline';

  @override
  String get readinessOptionSleep => 'Hours slept last night';

  @override
  String get readinessOptionForm => 'Form: fitness minus fatigue (CTL − ATL)';

  @override
  String get readinessOptionSubjective =>
      'Fatigue and soreness you logged today';

  @override
  String get readinessRatingExcluded => 'Not used';

  @override
  String get readinessOptionsReset => 'Use all signals';

  @override
  String get durTitle => 'Durability';

  @override
  String get durSubtitle =>
      'Power or pace after hours of work, against your fresh best';

  @override
  String get durFresh => 'Season best';

  @override
  String durAfterKj(int kj) {
    return 'After $kj kJ';
  }

  @override
  String durAfterKm(int km) {
    return 'After $km km';
  }

  @override
  String get durRetained => 'Kept';

  @override
  String get durHintRide =>
      'How much of your fresh power is left once you have already done the work shown. An effort only counts when it starts after that much work, taken from your recent long rides.';

  @override
  String get durHintRun =>
      'How fast you can still run once you have already covered the distance shown. An effort only counts when it starts after that distance, taken from your recent long runs.';

  @override
  String durBasedOn(int analysed, int candidates, int days) {
    return 'Based on $analysed of $candidates long sessions in the last $days days.';
  }

  @override
  String durFailed(int count) {
    return '$count sessions had no usable stream.';
  }

  @override
  String durReading(int done, int total) {
    return 'Reading sessions $done/$total…';
  }

  @override
  String get durNoneRide =>
      'No rides with at least 1,000 kJ of work in this range.';

  @override
  String get durNoneRun => 'No runs of at least 10 km in this range.';

  @override
  String get durNoData =>
      'Not enough work in the sessions found to reach these levels.';

  @override
  String durError(String error) {
    return 'Could not read the sessions: $error';
  }

  @override
  String get wtTitle => 'Wellness trends';

  @override
  String get wtSubtitle =>
      'HRV, resting HR, sleep and weight over time, with a 7-day average and your usual range';

  @override
  String get wtMetricWeight => 'Weight';

  @override
  String get wtLatest => 'Latest';

  @override
  String get wtAverage => '7-day avg';

  @override
  String get wtWeek => 'vs a week ago';

  @override
  String get wtBelow => 'Below your usual range';

  @override
  String get wtWithin => 'In your usual range';

  @override
  String get wtAbove => 'Above your usual range';

  @override
  String get wtBandNote =>
      'Shaded band: your usual range, the mean ± 1 SD over this period.';

  @override
  String get wtNoData => 'No data in this range.';

  @override
  String get wtLongerTrends => 'Longer trends';

  @override
  String get wtShow => 'Show';

  @override
  String get exTitle => 'Effort profile';

  @override
  String get exVi => 'Variability index';

  @override
  String get exViSteady => 'Steady';

  @override
  String get exViModerate => 'Some surges';

  @override
  String get exViVariable => 'Very variable';

  @override
  String get exViHint =>
      'Normalized over average: 1.00 is perfectly even, above about 1.05 the effort surged or stopped and started.';

  @override
  String get exHistPower => 'Time at power';

  @override
  String get exHistPace => 'Time at pace';

  @override
  String get exHistTap => 'Tap a bar for the details.';

  @override
  String exHistBand(String band, String minutes, int percent) {
    return '$band: $minutes min ($percent%)';
  }

  @override
  String exHistZero(String minutes) {
    return 'Not pedalling or stopped: $minutes min';
  }

  @override
  String get exIntervalsTitle => 'Intervals';

  @override
  String get exColInterval => '#';

  @override
  String get exColTime => 'Time';

  @override
  String get exColOutput => 'Output';

  @override
  String get exColHr => 'HR';

  @override
  String get exColDrift => 'Drift';

  @override
  String get exColFade => 'vs 1st';

  @override
  String get exRecovery => 'rec';

  @override
  String get exIntervalsHint =>
      'Drift: how much less output per heartbeat the second half of the interval gave than the first (heart-rate decoupling). vs 1st: output against the first work interval. Intervals under 2 minutes show no drift.';

  @override
  String get hmTitle => 'Load heatmap';

  @override
  String get hmSubtitle => 'A year of training load, day by day';

  @override
  String get hmPeriod12m => 'Last 12 months';

  @override
  String get hmPeriodYear => 'This year';

  @override
  String get hmPeriodLastYear => 'Last year';

  @override
  String get hmLess => 'Less';

  @override
  String get hmMore => 'More';

  @override
  String get hmTap => 'Tap a day to see its load.';

  @override
  String hmDay(String date, int tss, int sessions) {
    return '$date: $tss TSS · $sessions sessions';
  }

  @override
  String hmRest(String date) {
    return '$date: no training';
  }

  @override
  String get hmTotal => 'Total load';

  @override
  String get hmActiveDays => 'Training days';

  @override
  String get hmLongestStreak => 'Longest streak';

  @override
  String get hmBusiestWeek => 'Busiest week';

  @override
  String hmDays(int count) {
    return '$count days';
  }

  @override
  String hmWeekOf(int tss, String date) {
    return '$tss TSS, week of $date';
  }

  @override
  String get hmNoData => 'No training in this period.';

  @override
  String get beTitle => 'Best efforts';

  @override
  String get beSubtitle =>
      'Best 5 s to 20 min power or 1 to 10 km pace over time, against your last 90 days';

  @override
  String get beWindowBest => '30-day best';

  @override
  String get beRollingBest => 'Best of 90 days';

  @override
  String get beTableTitle => 'Last 30 days against the 90 days before';

  @override
  String get beColEffort => 'Effort';

  @override
  String get beColNow => 'Last 30 d';

  @override
  String get beColBefore => 'Before';

  @override
  String get beColChange => 'Change';

  @override
  String get beHint =>
      'Each point is your best effort in a 30-day window; the second line is the best of the 90 days up to it. Change compares your last 30 days with the best of the 90 days before them: green is a better effort, red a worse one.';

  @override
  String get beNoData => 'No efforts recorded in the last year.';

  @override
  String beError(String error) {
    return 'Could not load your efforts: $error';
  }

  @override
  String get heroTitleCaution => 'Train with care';

  @override
  String get heroTitleBackOff => 'Take it easy today';

  @override
  String get pvTitle => 'Privacy & data';

  @override
  String get pvSubtitle => 'What TriIQ stores, who sees it, and your choices';

  @override
  String get pvIntro =>
      'TriIQ has no account, no server and no tracking. Your data stays on this device and goes only to the services you connect yourself.';

  @override
  String get pvDataTitle => 'What is processed';

  @override
  String get pvDataBody =>
      '• Activities and routes (GPS tracks) from Intervals.icu\n• Health and wellness data: heart rate, HRV, resting heart rate, sleep, weight and how you feel. This is health data, a special category under the GDPR.\n• Your profile: name, picture, thresholds, goals and plans\n• API keys for the services you connect';

  @override
  String get pvStoredTitle => 'Where it is stored';

  @override
  String get pvStoredBody =>
      'Only on this device: a local database and app preferences. API keys are kept in the operating system\'s secure storage. Android\'s cloud backup is switched off for the app. TriIQ has no server and receives none of your data.';

  @override
  String get pvRecipientsTitle => 'Who receives data';

  @override
  String get pvRecipientsBody =>
      '• Intervals.icu: your training data is synced with your account, using your API key.\n• Your AI provider (Claude by Anthropic, Ollama Cloud, or your own Ollama server): only when you have allowed it below and use the AI trainer, Train now, the weekly note or AI-written plan content. The conversation and the training and health data it needs are sent.\n• OpenStreetMap tile servers: only when a route map is shown. They see your IP address and the map area.\nNothing else: no analytics, no crash reporting, no advertising.';

  @override
  String get pvTransferTitle => 'Transfers outside the EU/EEA';

  @override
  String get pvTransferBody =>
      'Some of these services may process data outside the EU/EEA (for example an AI provider in the USA). Their own privacy terms apply to what they receive. A self-hosted Ollama server on your own network keeps the data with you.';

  @override
  String get pvBasisTitle => 'Legal basis';

  @override
  String get pvBasisBody =>
      'Syncing with Intervals.icu happens because you connected your account. Sending health and training data to an AI provider happens only with your explicit consent (GDPR Art. 6(1)(a) and 9(2)(a)), which you can withdraw at any time below. Map tiles are fetched only to show the map you opened; you can switch that off.';

  @override
  String get pvRetentionTitle => 'How long';

  @override
  String get pvRetentionBody =>
      'Until you delete it: data stays on your device until you erase it here, restore a backup over it or uninstall the app. Data already sent to Intervals.icu or an AI provider is kept by them under their own rules.';

  @override
  String get pvRightsTitle => 'Your rights';

  @override
  String get pvRightsBody =>
      '• Access and portability: Settings → Backup exports everything stored here as one file.\n• Rectification: correct your data in Intervals.icu; the next sync updates this device.\n• Erasure: use \"Delete all data\" below. To remove your data at Intervals.icu or an AI provider, use their account tools.\n• Withdraw consent or object: switch the AI off below, or disconnect Intervals.icu in Profile.\n• Complaint: you can complain to your data protection authority.';

  @override
  String get pvControlsTitle => 'Your choices';

  @override
  String get pvAiConsentTitle => 'Send my data to the AI provider';

  @override
  String get pvAiConsentHelp =>
      'Allows training and health data to be sent to your AI provider when you use the AI trainer. Off: the AI features stay unavailable.';

  @override
  String pvAiConsentSince(String date) {
    return 'Allowed on $date';
  }

  @override
  String get pvMapTilesTitle => 'Load map tiles from OpenStreetMap';

  @override
  String get pvMapTilesHelp =>
      'Route maps need tiles from OpenStreetMap, which sees your IP address and the area shown. Off: routes are drawn without a map.';

  @override
  String get pvEraseTitle => 'Delete all data on this device';

  @override
  String get pvEraseHelp =>
      'Removes activities, wellness, plans, settings, saved keys and the offline queue from this device and disconnects Intervals.icu. It does not delete anything at Intervals.icu or your AI provider.';

  @override
  String get pvEraseButton => 'Delete all data…';

  @override
  String get pvEraseConfirmTitle => 'Delete all data?';

  @override
  String get pvEraseConfirmBody =>
      'Everything TriIQ stores on this device will be removed and the app disconnected. Export a backup first if you want to keep it. This cannot be undone.';

  @override
  String get pvEraseConfirm => 'Delete everything';

  @override
  String get pvEraseDone => 'All data on this device was deleted.';

  @override
  String pvEraseFailed(String error) {
    return 'Could not delete everything: $error';
  }

  @override
  String get pvOpenWeb => 'Read the full privacy notice';

  @override
  String get pvContact =>
      'Questions or requests: open an issue at github.com/uid09552/triiq.';

  @override
  String get pvConsentDialogTitle => 'Allow AI processing?';

  @override
  String pvConsentDialogBody(String provider) {
    return 'To answer, the AI trainer sends your questions together with training and health data (activities, heart rate, HRV, sleep, weight, how you feel) to $provider. $provider may process it outside the EU/EEA. You can withdraw this at any time in Settings → Privacy & data.';
  }

  @override
  String get pvConsentAllow => 'Allow';

  @override
  String get pvConsentNotNow => 'Not now';

  @override
  String get pvConsentCardTitle => 'The AI trainer needs your consent';

  @override
  String pvConsentCardBody(String provider) {
    return 'Choose whether your training and health data may be sent to $provider.';
  }

  @override
  String get pvProviderClaude => 'Claude (Anthropic)';

  @override
  String get pvProviderOllamaCloud => 'Ollama Cloud';

  @override
  String get pvProviderOllamaServer => 'your Ollama server';

  @override
  String get syncStatusNow => 'Synced just now';

  @override
  String syncStatusMinutes(int minutes) {
    return 'Synced $minutes min ago';
  }

  @override
  String syncStatusHours(int hours) {
    return 'Synced $hours h ago';
  }

  @override
  String syncStatusDays(int days) {
    return 'Synced $days d ago';
  }

  @override
  String get syncStatusNever => 'Not synced yet';

  @override
  String get syncStatusNotConnected => 'Not connected';

  @override
  String syncStatusWaiting(int count) {
    return '$count waiting to send';
  }

  @override
  String syncStatusFailed(int count) {
    return '$count failed to send';
  }

  @override
  String get syncStatusTooltip => 'Open sync';

  @override
  String get undoButton => 'Undo';

  @override
  String workoutRestored(String name) {
    return 'Restored “$name”';
  }

  @override
  String replaceUndone(String name) {
    return 'Back to “$name”';
  }

  @override
  String couldNotUndo(String error) {
    return 'Could not undo: $error';
  }

  @override
  String workoutReplacedUndoable(String name) {
    return '$name replaces the session';
  }

  @override
  String workoutDeletedUndoable(String name) {
    return '“$name” deleted';
  }

  @override
  String get moreGroupPlan => 'Plan';

  @override
  String get moreGroupTrainer => 'Trainer';

  @override
  String get moreGroupData => 'Data';

  @override
  String get exNoIntervals => 'No intervals in this session.';

  @override
  String get actTabOverview => 'Overview';

  @override
  String get actTabCharts => 'Charts';

  @override
  String get actTabIntervals => 'Intervals';

  @override
  String get actTabMap => 'Map';

  @override
  String get actMoreActions => 'More actions';
}
