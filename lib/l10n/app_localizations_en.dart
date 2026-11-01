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
  String get moreReviewSubtitle =>
      'Plan vs done, 80/20 and load trend per week';

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
  String get performanceTitle => 'Performance';

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
}
