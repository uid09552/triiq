import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get navStatistics;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @profileAndSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile & settings'**
  String get profileAndSettingsTooltip;

  /// No description provided for @titleProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get titleProfile;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @titleSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get titleSync;

  /// No description provided for @titleActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get titleActivities;

  /// No description provided for @titleActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get titleActivity;

  /// No description provided for @titleAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get titleAthlete;

  /// No description provided for @titlePlannedTraining.
  ///
  /// In en, this message translates to:
  /// **'Planned training'**
  String get titlePlannedTraining;

  /// No description provided for @titleTrainNow.
  ///
  /// In en, this message translates to:
  /// **'Train now'**
  String get titleTrainNow;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @openSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettingsButton;

  /// No description provided for @openProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get openProfileButton;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @connectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedLabel;

  /// No description provided for @syncedWithIntervals.
  ///
  /// In en, this message translates to:
  /// **'Synced with Intervals.icu'**
  String get syncedWithIntervals;

  /// No description provided for @activityFallback.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityFallback;

  /// No description provided for @plannedSessionFallback.
  ///
  /// In en, this message translates to:
  /// **'Planned session'**
  String get plannedSessionFallback;

  /// No description provided for @heroActivitiesStatus.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Ready to train} =1{1 activity logged today} other{{count} activities logged today}}'**
  String heroActivitiesStatus(int count);

  /// No description provided for @notConnectedToIntervals.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Intervals.icu'**
  String get notConnectedToIntervals;

  /// No description provided for @noWorkoutLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No workout logged today'**
  String get noWorkoutLoggedToday;

  /// No description provided for @finishSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up'**
  String get finishSettingUp;

  /// No description provided for @connectIntervalsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account to see your training data.'**
  String get connectIntervalsPrompt;

  /// No description provided for @setupLlmPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up an LLM provider (Claude or Ollama) to chat with the training agent.'**
  String get setupLlmPrompt;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @tssToday.
  ///
  /// In en, this message translates to:
  /// **'TSS today'**
  String get tssToday;

  /// No description provided for @tssWeek.
  ///
  /// In en, this message translates to:
  /// **'TSS week'**
  String get tssWeek;

  /// No description provided for @ctlLabel.
  ///
  /// In en, this message translates to:
  /// **'CTL'**
  String get ctlLabel;

  /// No description provided for @atlLabel.
  ///
  /// In en, this message translates to:
  /// **'ATL'**
  String get atlLabel;

  /// No description provided for @todaysActivities.
  ///
  /// In en, this message translates to:
  /// **'Today\'s activities'**
  String get todaysActivities;

  /// No description provided for @todaysTraining.
  ///
  /// In en, this message translates to:
  /// **'Today\'s training'**
  String get todaysTraining;

  /// No description provided for @tomorrowsTraining.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow\'s training'**
  String get tomorrowsTraining;

  /// No description provided for @nothingPlannedToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today — rest day.'**
  String get nothingPlannedToday;

  /// No description provided for @nothingPlannedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for tomorrow yet.'**
  String get nothingPlannedTomorrow;

  /// No description provided for @connectToSeePlan.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account to see your plan.'**
  String get connectToSeePlan;

  /// No description provided for @connectInProfile.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account in Profile'**
  String get connectInProfile;

  /// No description provided for @noTargetSet.
  ///
  /// In en, this message translates to:
  /// **'No target set'**
  String get noTargetSet;

  /// No description provided for @sportLabel.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sportLabel;

  /// No description provided for @sportRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get sportRun;

  /// No description provided for @sportRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get sportRide;

  /// No description provided for @sportSwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get sportSwim;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration — {minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @intensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLabel;

  /// No description provided for @intensityRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get intensityRecovery;

  /// No description provided for @intensityEndurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get intensityEndurance;

  /// No description provided for @intensityIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get intensityIntervals;

  /// No description provided for @addCustomInstructions.
  ///
  /// In en, this message translates to:
  /// **'Add custom instructions'**
  String get addCustomInstructions;

  /// No description provided for @customInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom instructions'**
  String get customInstructionsLabel;

  /// No description provided for @removeCustomInstructions.
  ///
  /// In en, this message translates to:
  /// **'Remove custom instructions'**
  String get removeCustomInstructions;

  /// No description provided for @customInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"keep the run flat, I want to save my legs for a race Saturday\"'**
  String get customInstructionsHint;

  /// No description provided for @trainNowEventTitle.
  ///
  /// In en, this message translates to:
  /// **'{intensity} {sport} session'**
  String trainNowEventTitle(String intensity, String sport);

  /// No description provided for @llmNeededForProposal.
  ///
  /// In en, this message translates to:
  /// **'Set up an LLM provider in Settings to get a proposal.'**
  String get llmNeededForProposal;

  /// No description provided for @proposeTraining.
  ///
  /// In en, this message translates to:
  /// **'Propose training'**
  String get proposeTraining;

  /// No description provided for @askAgain.
  ///
  /// In en, this message translates to:
  /// **'Ask again'**
  String get askAgain;

  /// No description provided for @addToGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to Google Calendar'**
  String get addToGoogleCalendar;

  /// No description provided for @couldNotOpenGoogleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Calendar.'**
  String get couldNotOpenGoogleCalendar;

  /// No description provided for @thinkingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinkingEllipsis;

  /// No description provided for @toolFailedSuffix.
  ///
  /// In en, this message translates to:
  /// **'{label} — failed'**
  String toolFailedSuffix(String label);

  /// No description provided for @toolRunningGeneric.
  ///
  /// In en, this message translates to:
  /// **'Running {name}…'**
  String toolRunningGeneric(String name);

  /// No description provided for @trainNowToolChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your profile and cached data…'**
  String get trainNowToolChecking;

  /// No description provided for @trainNowToolDailyLoad.
  ///
  /// In en, this message translates to:
  /// **'Reading your daily load and wellness…'**
  String get trainNowToolDailyLoad;

  /// No description provided for @trainNowToolActivities.
  ///
  /// In en, this message translates to:
  /// **'Reading your recent activities…'**
  String get trainNowToolActivities;

  /// No description provided for @trainNowToolPlanned.
  ///
  /// In en, this message translates to:
  /// **'Reading your planned sessions…'**
  String get trainNowToolPlanned;

  /// No description provided for @trainNowToolSummary.
  ///
  /// In en, this message translates to:
  /// **'Summarising your last 7 days…'**
  String get trainNowToolSummary;

  /// No description provided for @trainNowToolGuidance.
  ///
  /// In en, this message translates to:
  /// **'Consulting the training reference…'**
  String get trainNowToolGuidance;

  /// No description provided for @trainNowToolSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing from Intervals.icu…'**
  String get trainNowToolSyncing;

  /// No description provided for @tssHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'TSS — last 42 days'**
  String get tssHistoryTitle;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / day'**
  String get avgPerDay;

  /// No description provided for @avgPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Avg / week'**
  String get avgPerWeek;

  /// No description provided for @dailyTss.
  ///
  /// In en, this message translates to:
  /// **'Daily TSS'**
  String get dailyTss;

  /// No description provided for @tapBarForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar for its date and value.'**
  String get tapBarForDetails;

  /// No description provided for @selectedDayTss.
  ///
  /// In en, this message translates to:
  /// **'{date} · {tss} TSS'**
  String selectedDayTss(String date, int tss);

  /// No description provided for @connectForAthleteDetails.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account in Profile to see your athlete details.'**
  String get connectForAthleteDetails;

  /// No description provided for @athleteIdLine.
  ///
  /// In en, this message translates to:
  /// **'Athlete ID {id} · synced with Intervals.icu'**
  String athleteIdLine(String id);

  /// No description provided for @bodyAndWellness.
  ///
  /// In en, this message translates to:
  /// **'Body & wellness'**
  String get bodyAndWellness;

  /// No description provided for @noWellnessCached.
  ///
  /// In en, this message translates to:
  /// **'No wellness data cached yet.'**
  String get noWellnessCached;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @restingHrLabel.
  ///
  /// In en, this message translates to:
  /// **'Resting HR'**
  String get restingHrLabel;

  /// No description provided for @hrvLabel.
  ///
  /// In en, this message translates to:
  /// **'HRV'**
  String get hrvLabel;

  /// No description provided for @thresholdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Thresholds'**
  String get thresholdsTitle;

  /// No description provided for @noActivitiesForThresholds.
  ///
  /// In en, this message translates to:
  /// **'No activities cached yet, so no per-sport thresholds could be read.'**
  String get noActivitiesForThresholds;

  /// No description provided for @thresholdPaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold pace'**
  String get thresholdPaceLabel;

  /// No description provided for @weightAsAnalysedLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (as analysed)'**
  String get weightAsAnalysedLabel;

  /// No description provided for @asOfDate.
  ///
  /// In en, this message translates to:
  /// **'as of {date}'**
  String asOfDate(String date);

  /// No description provided for @calendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonth;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarWeek;

  /// No description provided for @todayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTooltip;

  /// No description provided for @noTrainingData.
  ///
  /// In en, this message translates to:
  /// **'No training data'**
  String get noTrainingData;

  /// No description provided for @nothingPlannedOrLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned or logged this day.'**
  String get nothingPlannedOrLogged;

  /// No description provided for @plannedStatus.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannedStatus;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @messageAgentHint.
  ///
  /// In en, this message translates to:
  /// **'Message the training agent…'**
  String get messageAgentHint;

  /// No description provided for @askAboutTraining.
  ///
  /// In en, this message translates to:
  /// **'Ask about your training, progress, or plan'**
  String get askAboutTraining;

  /// No description provided for @pickLlmProviderToChat.
  ///
  /// In en, this message translates to:
  /// **'Pick an LLM provider in Settings to start chatting'**
  String get pickLlmProviderToChat;

  /// No description provided for @noReplyFromModel.
  ///
  /// In en, this message translates to:
  /// **'No reply came back from the model.'**
  String get noReplyFromModel;

  /// No description provided for @chatToolChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking your profile and cached data…'**
  String get chatToolChecking;

  /// No description provided for @chatToolDailyLoad.
  ///
  /// In en, this message translates to:
  /// **'Reading your daily load and wellness…'**
  String get chatToolDailyLoad;

  /// No description provided for @chatToolActivities.
  ///
  /// In en, this message translates to:
  /// **'Reading your activities…'**
  String get chatToolActivities;

  /// No description provided for @chatToolPlanned.
  ///
  /// In en, this message translates to:
  /// **'Reading your planned sessions…'**
  String get chatToolPlanned;

  /// No description provided for @chatToolSummary.
  ///
  /// In en, this message translates to:
  /// **'Summarising your training…'**
  String get chatToolSummary;

  /// No description provided for @chatToolGuidance.
  ///
  /// In en, this message translates to:
  /// **'Consulting the training reference…'**
  String get chatToolGuidance;

  /// No description provided for @chatToolSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing from Intervals.icu…'**
  String get chatToolSyncing;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync completion and training-agent replies'**
  String get notificationsSubtitle;

  /// No description provided for @dailyTrainingReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily training reminder'**
  String get dailyTrainingReminder;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was denied. Enable it for TriIQ in your device settings to turn this on.'**
  String get notificationPermissionDenied;

  /// No description provided for @reminderNeedsBackground.
  ///
  /// In en, this message translates to:
  /// **'The daily reminder needs the app to stay reachable in the background, which isn\'t available on this platform.'**
  String get reminderNeedsBackground;

  /// No description provided for @syncSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSectionTitle;

  /// No description provided for @autoSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Refresh this month automatically while the app is open, no more often than:'**
  String get autoSyncDescription;

  /// No description provided for @autoSyncMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String autoSyncMinutes(int minutes);

  /// No description provided for @autoSyncHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String autoSyncHours(int hours);

  /// No description provided for @backgroundSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Nightly background sync'**
  String get backgroundSyncTitle;

  /// No description provided for @backgroundSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Refresh the current week overnight even when the app is closed. It runs about once a day, only with a network connection and when the battery isn\'t low.'**
  String get backgroundSyncDescription;

  /// No description provided for @backgroundSyncNoRun.
  ///
  /// In en, this message translates to:
  /// **'No background run yet.'**
  String get backgroundSyncNoRun;

  /// No description provided for @backgroundSyncLastRun.
  ///
  /// In en, this message translates to:
  /// **'Last run: {when} – {result}'**
  String backgroundSyncLastRun(String when, String result);

  /// No description provided for @backgroundResultSuccess.
  ///
  /// In en, this message translates to:
  /// **'synced'**
  String get backgroundResultSuccess;

  /// No description provided for @backgroundResultSkippedFresh.
  ///
  /// In en, this message translates to:
  /// **'skipped, data was fresh'**
  String get backgroundResultSkippedFresh;

  /// No description provided for @backgroundResultAuthRejected.
  ///
  /// In en, this message translates to:
  /// **'key rejected, reconnect in Profile'**
  String get backgroundResultAuthRejected;

  /// No description provided for @backgroundResultFailed.
  ///
  /// In en, this message translates to:
  /// **'failed, will retry tomorrow'**
  String get backgroundResultFailed;

  /// No description provided for @backgroundResultNotConnected.
  ///
  /// In en, this message translates to:
  /// **'not connected'**
  String get backgroundResultNotConnected;

  /// No description provided for @backgroundSyncUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Background sync is not available on this platform. Data refreshes while the app is open.'**
  String get backgroundSyncUnsupported;

  /// No description provided for @llmProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'LLM provider'**
  String get llmProviderTitle;

  /// No description provided for @claudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Claude'**
  String get claudeLabel;

  /// No description provided for @ollamaLabel.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get ollamaLabel;

  /// No description provided for @claudeApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Claude API key'**
  String get claudeApiKeyLabel;

  /// No description provided for @claudeKeyStoredHint.
  ///
  /// In en, this message translates to:
  /// **'A key is stored — type a new one to replace it'**
  String get claudeKeyStoredHint;

  /// No description provided for @showTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showTooltip;

  /// No description provided for @hideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideTooltip;

  /// No description provided for @saveKeyButton.
  ///
  /// In en, this message translates to:
  /// **'Save key'**
  String get saveKeyButton;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @claudeModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Claude model'**
  String get claudeModelLabel;

  /// No description provided for @claudeKeySecureHelp.
  ///
  /// In en, this message translates to:
  /// **'The key is stored in your operating system\'s credential vault and sent only to Anthropic. Usage is billed to your own Anthropic account.'**
  String get claudeKeySecureHelp;

  /// No description provided for @claudeKeyInsecureHelp.
  ///
  /// In en, this message translates to:
  /// **'This build cannot store the key securely, so it is kept for this session only and you will re-enter it after a reload.'**
  String get claudeKeyInsecureHelp;

  /// No description provided for @ollamaServerUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Ollama server URL'**
  String get ollamaServerUrlLabel;

  /// No description provided for @ollamaCloudApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ollama Cloud API key'**
  String get ollamaCloudApiKeyLabel;

  /// No description provided for @ollamaApiKeyOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Ollama API key (optional)'**
  String get ollamaApiKeyOptionalLabel;

  /// No description provided for @ollamaKeyStoredHint.
  ///
  /// In en, this message translates to:
  /// **'A key is stored — type a new one to replace it'**
  String get ollamaKeyStoredHint;

  /// No description provided for @getAKeyButton.
  ///
  /// In en, this message translates to:
  /// **'Get a key'**
  String get getAKeyButton;

  /// No description provided for @testConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnectionButton;

  /// No description provided for @ollamaModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Ollama model'**
  String get ollamaModelLabel;

  /// No description provided for @ollamaKeySecureHelp.
  ///
  /// In en, this message translates to:
  /// **'The key is stored in your operating system\'s credential vault and sent only to Ollama Cloud.'**
  String get ollamaKeySecureHelp;

  /// No description provided for @ollamaKeyInsecureHelp.
  ///
  /// In en, this message translates to:
  /// **'This build cannot store the key securely, so it is kept for this session only and you will re-enter it after a reload.'**
  String get ollamaKeyInsecureHelp;

  /// No description provided for @ollamaLocalHelp.
  ///
  /// In en, this message translates to:
  /// **'Nothing leaves your network. The model must support tool calling — without it the agent cannot read your training data.'**
  String get ollamaLocalHelp;

  /// No description provided for @claudeKeySavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Claude API key saved.'**
  String get claudeKeySavedMessage;

  /// No description provided for @claudeKeyRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Claude API key removed.'**
  String get claudeKeyRemovedMessage;

  /// No description provided for @ollamaKeyRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Ollama API key removed.'**
  String get ollamaKeyRemovedMessage;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// No description provided for @ollamaKeySavedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ollama API key saved'**
  String get ollamaKeySavedPrefix;

  /// No description provided for @connectedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedPrefix;

  /// No description provided for @connectedModelsMessage.
  ///
  /// In en, this message translates to:
  /// **'{prefix} — {count, plural, =0{connected, but no models are available on that server yet.} =1{1 model available.} other{{count} models available.}}'**
  String connectedModelsMessage(String prefix, int count);

  /// No description provided for @couldNotConnectKeyNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {error}. Key not saved.'**
  String couldNotConnectKeyNotSaved(String error);

  /// No description provided for @couldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {error}'**
  String couldNotConnect(String error);

  /// No description provided for @profileHeaderChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking saved connection…'**
  String get profileHeaderChecking;

  /// No description provided for @intervalsConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu connection'**
  String get intervalsConnectionTitle;

  /// No description provided for @checkingForSavedKey.
  ///
  /// In en, this message translates to:
  /// **'Checking for a saved API key…'**
  String get checkingForSavedKey;

  /// No description provided for @disconnectButton.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectButton;

  /// No description provided for @apiKeyHelpSecure.
  ///
  /// In en, this message translates to:
  /// **'Find your API key under Settings on intervals.icu. It is kept in this device\'s secure credential store.'**
  String get apiKeyHelpSecure;

  /// No description provided for @apiKeyHelpInsecure.
  ///
  /// In en, this message translates to:
  /// **'Find your API key under Settings on intervals.icu. In the browser it is only held for this tab — browsers have no secure place to keep it, so you will re-enter it after a reload.'**
  String get apiKeyHelpInsecure;

  /// No description provided for @intervalsApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu API key'**
  String get intervalsApiKeyLabel;

  /// No description provided for @connectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectButton;

  /// No description provided for @couldNotConnectGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {error}'**
  String couldNotConnectGeneric(String error);

  /// No description provided for @moreSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pull training data from Intervals.icu'**
  String get moreSyncSubtitle;

  /// No description provided for @moreActivitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every cached activity'**
  String get moreActivitiesSubtitle;

  /// No description provided for @trainingPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Training plans'**
  String get trainingPlansTitle;

  /// No description provided for @gearTitle.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get gearTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @syncNotConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get syncNotConnectedTitle;

  /// No description provided for @syncNotConnectedBody.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account in Profile before syncing.'**
  String get syncNotConnectedBody;

  /// No description provided for @localCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Local cache'**
  String get localCacheTitle;

  /// No description provided for @localCacheBody.
  ///
  /// In en, this message translates to:
  /// **'Activities cached from {oldest} to {newest}\nLast synced {lastSynced}'**
  String localCacheBody(String oldest, String newest, String lastSynced);

  /// No description provided for @syncedMessage.
  ///
  /// In en, this message translates to:
  /// **'Synced {activities} activities, {wellness} wellness records.'**
  String syncedMessage(int activities, int wellness);

  /// No description provided for @syncFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailedMessage(String error);

  /// No description provided for @syncScopeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get syncScopeToday;

  /// No description provided for @syncScopeMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get syncScopeMonth;

  /// No description provided for @syncScopeYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get syncScopeYear;

  /// No description provided for @syncScopeAll.
  ///
  /// In en, this message translates to:
  /// **'Everything (initial sync)'**
  String get syncScopeAll;

  /// No description provided for @noActivitiesCachedConnected.
  ///
  /// In en, this message translates to:
  /// **'No activities cached yet — try Sync from More.'**
  String get noActivitiesCachedConnected;

  /// No description provided for @noActivitiesCachedDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Connect your Intervals.icu account to see your activities.'**
  String get noActivitiesCachedDisconnected;

  /// No description provided for @noActivitiesOfType.
  ///
  /// In en, this message translates to:
  /// **'No {sport} activities cached — try Sync from More.'**
  String noActivitiesOfType(String sport);

  /// No description provided for @showAllActivities.
  ///
  /// In en, this message translates to:
  /// **'Show all activities'**
  String get showAllActivities;

  /// No description provided for @tssSuffix.
  ///
  /// In en, this message translates to:
  /// **'TSS'**
  String get tssSuffix;

  /// No description provided for @openInIntervals.
  ///
  /// In en, this message translates to:
  /// **'Open in Intervals.icu'**
  String get openInIntervals;

  /// No description provided for @timeInZone.
  ///
  /// In en, this message translates to:
  /// **'Time in zone'**
  String get timeInZone;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @elevationGainLabel.
  ///
  /// In en, this message translates to:
  /// **'Elevation gain'**
  String get elevationGainLabel;

  /// No description provided for @avgHrLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg HR'**
  String get avgHrLabel;

  /// No description provided for @maxHrLabel.
  ///
  /// In en, this message translates to:
  /// **'Max HR'**
  String get maxHrLabel;

  /// No description provided for @avgPowerNpLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg power (NP)'**
  String get avgPowerNpLabel;

  /// No description provided for @avgPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg power'**
  String get avgPowerLabel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @plannedTssLabel.
  ///
  /// In en, this message translates to:
  /// **'Planned TSS'**
  String get plannedTssLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @indoorLabel.
  ///
  /// In en, this message translates to:
  /// **'Indoor'**
  String get indoorLabel;

  /// No description provided for @workoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutTitle;

  /// No description provided for @statsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected to Intervals.icu'**
  String get statsNotConnected;

  /// No description provided for @volumeTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeTitle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @rangeDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String rangeDaysShort(int days);

  /// No description provided for @rangeOneYear.
  ///
  /// In en, this message translates to:
  /// **'1y'**
  String get rangeOneYear;

  /// No description provided for @noDataCachedForRange.
  ///
  /// In en, this message translates to:
  /// **'No data cached for this range yet.'**
  String get noDataCachedForRange;

  /// No description provided for @selectedDayValue.
  ///
  /// In en, this message translates to:
  /// **'{date}: {value}'**
  String selectedDayValue(String date, String value);

  /// No description provided for @tapChartForDay.
  ///
  /// In en, this message translates to:
  /// **'Tap the chart for a single day.'**
  String get tapChartForDay;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @changeLabel.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLabel;

  /// No description provided for @avgLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get avgLabel;

  /// No description provided for @rangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Low – high'**
  String get rangeLabel;

  /// No description provided for @whatThisMeans.
  ///
  /// In en, this message translates to:
  /// **'What this means'**
  String get whatThisMeans;

  /// No description provided for @metricCtlTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness (CTL)'**
  String get metricCtlTitle;

  /// No description provided for @metricAtlTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue (ATL)'**
  String get metricAtlTitle;

  /// No description provided for @metricFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Form (TSB)'**
  String get metricFormTitle;

  /// No description provided for @metricRampTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramp rate'**
  String get metricRampTitle;

  /// No description provided for @formLabel.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formLabel;

  /// No description provided for @rampRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Ramp'**
  String get rampRateLabel;

  /// No description provided for @metricCtlExplainer.
  ///
  /// In en, this message translates to:
  /// **'CTL is a 42-day weighted average of your training load: how much training you have absorbed, not a measure of fitness or health. It can keep rising while you dig yourself into a hole.'**
  String get metricCtlExplainer;

  /// No description provided for @metricAtlExplainer.
  ///
  /// In en, this message translates to:
  /// **'ATL is the same average over 7 days — the load still sitting in your legs. It rises and falls quickly, and a high ATL inside a hard block is normal rather than a warning on its own.'**
  String get metricAtlExplainer;

  /// No description provided for @metricFormExplainer.
  ///
  /// In en, this message translates to:
  /// **'Form is CTL minus ATL. Positive means you are carrying less recent load than usual, negative means recent training is heavy. Negative form is where fitness gets built; it is not a diagnosis.'**
  String get metricFormExplainer;

  /// No description provided for @metricRampExplainer.
  ///
  /// In en, this message translates to:
  /// **'Ramp rate is how fast CTL is changing. There is no universally safe number — judge it against your own history, your running volume, and how you are sleeping and recovering.'**
  String get metricRampExplainer;

  /// No description provided for @ftpValue.
  ///
  /// In en, this message translates to:
  /// **'FTP {watts} W'**
  String ftpValue(int watts);

  /// No description provided for @ofPlanned.
  ///
  /// In en, this message translates to:
  /// **'of {planned}'**
  String ofPlanned(int planned);

  /// No description provided for @weeklyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {planned} TSS this week · {remaining} to go'**
  String weeklyGoalProgress(int completed, int planned, int remaining);

  /// No description provided for @weeklyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {planned} TSS this week · goal reached'**
  String weeklyGoalReached(int completed, int planned);

  /// No description provided for @weeklyLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly load'**
  String get weeklyLoadTitle;

  /// No description provided for @fourWeekTrend.
  ///
  /// In en, this message translates to:
  /// **'4-week trend'**
  String get fourWeekTrend;

  /// No description provided for @completedVsPlanned.
  ///
  /// In en, this message translates to:
  /// **'Completed vs planned'**
  String get completedVsPlanned;

  /// No description provided for @selectedWeekLoad.
  ///
  /// In en, this message translates to:
  /// **'Week of {week}: {completed} TSS done, {planned} planned'**
  String selectedWeekLoad(String week, int completed, int planned);

  /// No description provided for @tapBarForWeek.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar for one week.'**
  String get tapBarForWeek;

  /// No description provided for @weekSessionsAndTime.
  ///
  /// In en, this message translates to:
  /// **'{sessions} sessions · {time}'**
  String weekSessionsAndTime(int sessions, String time);

  /// No description provided for @completedLegend.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLegend;

  /// No description provided for @plannedLegend.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannedLegend;

  /// No description provided for @fitnessTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness trend'**
  String get fitnessTrendTitle;

  /// No description provided for @bySportTitle.
  ///
  /// In en, this message translates to:
  /// **'By sport'**
  String get bySportTitle;

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String sessionsCount(int count);

  /// No description provided for @indoorFtpLabel.
  ///
  /// In en, this message translates to:
  /// **'Indoor FTP'**
  String get indoorFtpLabel;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs'**
  String ageYears(int years);

  /// No description provided for @thresholdsFromSettings.
  ///
  /// In en, this message translates to:
  /// **'From your current Intervals.icu sport settings.'**
  String get thresholdsFromSettings;

  /// No description provided for @thresholdsFromActivity.
  ///
  /// In en, this message translates to:
  /// **'Read from your most recent analysed activity.'**
  String get thresholdsFromActivity;

  /// No description provided for @newChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat?'**
  String get newChatTitle;

  /// No description provided for @newChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'This clears the conversation. Chats aren\'t saved anywhere.'**
  String get newChatConfirm;

  /// No description provided for @newChatButton.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChatButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @messagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String messagesCount(int count);

  /// No description provided for @chatSuggestionLastWeek.
  ///
  /// In en, this message translates to:
  /// **'How was last week?'**
  String get chatSuggestionLastWeek;

  /// No description provided for @chatSuggestionRecovered.
  ///
  /// In en, this message translates to:
  /// **'Am I recovered enough for intervals?'**
  String get chatSuggestionRecovered;

  /// No description provided for @chatSuggestionIntensity.
  ///
  /// In en, this message translates to:
  /// **'Is my intensity really 80/20?'**
  String get chatSuggestionIntensity;

  /// No description provided for @createInIntervals.
  ///
  /// In en, this message translates to:
  /// **'Create in Intervals.icu'**
  String get createInIntervals;

  /// No description provided for @connectToCreateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu to put this on your calendar.'**
  String get connectToCreateWorkout;

  /// No description provided for @preparingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Preparing the workout…'**
  String get preparingWorkout;

  /// No description provided for @couldNotStructureWorkout.
  ///
  /// In en, this message translates to:
  /// **'The model didn\'t return a workout that could be created. Try asking again.'**
  String get couldNotStructureWorkout;

  /// No description provided for @couldNotCreateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Could not create the workout: {error}'**
  String couldNotCreateWorkout(String error);

  /// No description provided for @workoutCreated.
  ///
  /// In en, this message translates to:
  /// **'“{name}” added to your Intervals.icu calendar.'**
  String workoutCreated(String name);

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @deletePlannedWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get deletePlannedWorkoutTitle;

  /// No description provided for @deletePlannedWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is removed from your Intervals.icu calendar. This can\'t be undone.'**
  String deletePlannedWorkoutConfirm(String name);

  /// No description provided for @workoutDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted from your Intervals.icu calendar.'**
  String workoutDeleted(String name);

  /// No description provided for @couldNotDeleteWorkout.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the workout: {error}'**
  String couldNotDeleteWorkout(String error);

  /// No description provided for @workoutParsedByIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu turns these steps into a structured workout; anything it can\'t parse stays as the description.'**
  String get workoutParsedByIntervals;

  /// No description provided for @morePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A load curve and weekly calendar toward your goal'**
  String get morePlanSubtitle;

  /// No description provided for @planGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get planGoalTitle;

  /// No description provided for @planNoGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a goal and TriIQ proposes a training block from your recent training.'**
  String get planNoGoal;

  /// No description provided for @planSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get planSetGoal;

  /// No description provided for @planEditGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get planEditGoal;

  /// No description provided for @planGoalSummary.
  ///
  /// In en, this message translates to:
  /// **'{target} · {sport} · {days} days · {hours} h/week'**
  String planGoalSummary(String target, String sport, int days, String hours);

  /// No description provided for @planGoalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get planGoalTarget;

  /// No description provided for @planGoalSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get planGoalSport;

  /// No description provided for @planGoalDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get planGoalDays;

  /// No description provided for @planGoalHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly hours: {hours}'**
  String planGoalHours(String hours);

  /// No description provided for @planGoalEventDate.
  ///
  /// In en, this message translates to:
  /// **'Event date (optional)'**
  String get planGoalEventDate;

  /// No description provided for @planGoalClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get planGoalClearDate;

  /// No description provided for @planGoalBaseline.
  ///
  /// In en, this message translates to:
  /// **'Typical weekly load in TSS (optional)'**
  String get planGoalBaseline;

  /// No description provided for @planGoalBaselineHelp.
  ///
  /// In en, this message translates to:
  /// **'Used when there is not enough synced history.'**
  String get planGoalBaselineHelp;

  /// No description provided for @planGoalLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramp limits'**
  String get planGoalLimitsTitle;

  /// No description provided for @planGoalMaxIncrease.
  ///
  /// In en, this message translates to:
  /// **'Max weekly load increase (%)'**
  String get planGoalMaxIncrease;

  /// No description provided for @planGoalMaxRamp.
  ///
  /// In en, this message translates to:
  /// **'Max CTL gain per week'**
  String get planGoalMaxRamp;

  /// No description provided for @planGoalLimitsNote.
  ///
  /// In en, this message translates to:
  /// **'These are starting points, not universally safe values. Adjust them to how you respond.'**
  String get planGoalLimitsNote;

  /// No description provided for @planSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get planSaveButton;

  /// No description provided for @planGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate plan'**
  String get planGenerate;

  /// No description provided for @planRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get planRegenerate;

  /// No description provided for @planRemoveUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Remove upcoming sessions'**
  String get planRemoveUpcoming;

  /// No description provided for @planRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove upcoming sessions?'**
  String get planRemoveTitle;

  /// No description provided for @planRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Sessions from today on are deleted from your Intervals.icu calendar. Completed and past sessions stay.'**
  String get planRemoveBody;

  /// No description provided for @planRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sessions to remove} =1{1 session removed} other{{count} sessions removed}}'**
  String planRemoved(int count);

  /// No description provided for @planNeedsBaselineTitle.
  ///
  /// In en, this message translates to:
  /// **'A baseline is needed'**
  String get planNeedsBaselineTitle;

  /// No description provided for @planBaselineDialogField.
  ///
  /// In en, this message translates to:
  /// **'Weekly load (TSS)'**
  String get planBaselineDialogField;

  /// No description provided for @planContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get planContinueButton;

  /// No description provided for @planGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build a plan: {message}'**
  String planGenerateFailed(String message);

  /// No description provided for @planPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your plan'**
  String get planPreviewTitle;

  /// No description provided for @planPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing is created until you confirm. Tap a date to move a session.'**
  String get planPreviewNote;

  /// No description provided for @planConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Create plan'**
  String get planConfirmButton;

  /// No description provided for @planCreateCalendarToo.
  ///
  /// In en, this message translates to:
  /// **'Also add to my phone calendar'**
  String get planCreateCalendarToo;

  /// No description provided for @planCreatedAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session created} other{{count} sessions created}}'**
  String planCreatedAll(int count);

  /// No description provided for @planCreatedPartial.
  ///
  /// In en, this message translates to:
  /// **'{created} created, {failed} failed'**
  String planCreatedPartial(int created, int failed);

  /// No description provided for @planRetryFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Retry 1 failed session} other{Retry {count} failed sessions}}'**
  String planRetryFailed(int count);

  /// No description provided for @planNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu in Profile to create a plan.'**
  String get planNotConnected;

  /// No description provided for @planWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {number} · {phase}'**
  String planWeekLabel(int number, String phase);

  /// No description provided for @planThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get planThisWeek;

  /// No description provided for @planPhaseBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get planPhaseBuild;

  /// No description provided for @planPhaseBuildPlus.
  ///
  /// In en, this message translates to:
  /// **'Build+'**
  String get planPhaseBuildPlus;

  /// No description provided for @planPhasePeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get planPhasePeak;

  /// No description provided for @planPhaseRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get planPhaseRecovery;

  /// No description provided for @planTargetVsActual.
  ///
  /// In en, this message translates to:
  /// **'{actual} of {target} TSS'**
  String planTargetVsActual(int actual, int target);

  /// No description provided for @planTargetOnly.
  ///
  /// In en, this message translates to:
  /// **'Target {target} TSS'**
  String planTargetOnly(int target);

  /// No description provided for @planEasyShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% easy'**
  String planEasyShare(int percent);

  /// No description provided for @planOutside8020.
  ///
  /// In en, this message translates to:
  /// **'Below the 80/20 target'**
  String get planOutside8020;

  /// No description provided for @planLimitedIncrease.
  ///
  /// In en, this message translates to:
  /// **'Held back by the weekly increase limit'**
  String get planLimitedIncrease;

  /// No description provided for @planLimitedCtl.
  ///
  /// In en, this message translates to:
  /// **'Held back by the CTL ramp limit'**
  String get planLimitedCtl;

  /// No description provided for @planLimitedHours.
  ///
  /// In en, this message translates to:
  /// **'Held back by your weekly hours'**
  String get planLimitedHours;

  /// No description provided for @planKnowledgeWarning.
  ///
  /// In en, this message translates to:
  /// **'Some training knowledge could not be read, so built-in defaults were used.'**
  String get planKnowledgeWarning;

  /// No description provided for @planSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Not created'**
  String get planSessionFailed;

  /// No description provided for @planSessionMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {load} TSS'**
  String planSessionMinutes(int minutes, int load);

  /// No description provided for @planAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add plan to calendar'**
  String get planAddToCalendar;

  /// No description provided for @planCalendarDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event added to your calendar} other{{count} events added to your calendar}}'**
  String planCalendarDone(int count);

  /// No description provided for @planCalendarDenied.
  ///
  /// In en, this message translates to:
  /// **'Calendar access was denied.'**
  String get planCalendarDenied;

  /// No description provided for @planCalendarPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a calendar'**
  String get planCalendarPickTitle;

  /// No description provided for @planCalendarNone.
  ///
  /// In en, this message translates to:
  /// **'No writable calendar found.'**
  String get planCalendarNone;

  /// No description provided for @planOpenSingle.
  ///
  /// In en, this message translates to:
  /// **'Add to Google Calendar'**
  String get planOpenSingle;

  /// No description provided for @sportTriathlon.
  ///
  /// In en, this message translates to:
  /// **'Triathlon'**
  String get sportTriathlon;

  /// No description provided for @planGoalWeeks.
  ///
  /// In en, this message translates to:
  /// **'Plan length: {weeks} weeks'**
  String planGoalWeeks(int weeks);

  /// No description provided for @planGoalWeeksDefault.
  ///
  /// In en, this message translates to:
  /// **'Default: 8 weeks, or the weeks until your event.'**
  String get planGoalWeeksDefault;

  /// No description provided for @planGoalWeeksAuto.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get planGoalWeeksAuto;

  /// No description provided for @planGoalMixTitle.
  ///
  /// In en, this message translates to:
  /// **'Sport mix (share of weekly load)'**
  String get planGoalMixTitle;

  /// No description provided for @planGoalMixTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {total}%'**
  String planGoalMixTotal(int total);

  /// No description provided for @planGoalMixShare.
  ///
  /// In en, this message translates to:
  /// **'{sport}: {percent}%'**
  String planGoalMixShare(String sport, int percent);

  /// No description provided for @planCurveTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly load'**
  String get planCurveTitle;

  /// No description provided for @planCurveHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a week up or down, 80–120% of the proposal. Drop a week to about 80% for recovery.'**
  String get planCurveHint;

  /// No description provided for @planCurveProposal.
  ///
  /// In en, this message translates to:
  /// **'100% = proposed load: up to +{percent}% a week from {baseline} TSS. A default, not a rule.'**
  String planCurveProposal(int percent, int baseline);

  /// No description provided for @planCurveNeedsBaseline.
  ///
  /// In en, this message translates to:
  /// **'Not enough synced history to propose a load. Enter a typical weekly load in the goal.'**
  String get planCurveNeedsBaseline;

  /// No description provided for @planCurveWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W{week}'**
  String planCurveWeekShort(int week);

  /// No description provided for @planCurveDragLabel.
  ///
  /// In en, this message translates to:
  /// **'Week {week} · {percent}% · {tss} TSS'**
  String planCurveDragLabel(int week, int percent, int tss);

  /// No description provided for @planCurveDelta.
  ///
  /// In en, this message translates to:
  /// **'{delta}% vs. previous week'**
  String planCurveDelta(String delta);

  /// No description provided for @planCurveSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a week to fine-tune it.'**
  String get planCurveSelectHint;

  /// No description provided for @planCurveIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase by 5%'**
  String get planCurveIncrease;

  /// No description provided for @planCurveDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease by 5%'**
  String get planCurveDecrease;

  /// No description provided for @planCurveUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get planCurveUndo;

  /// No description provided for @planCurveReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get planCurveReset;

  /// No description provided for @planCurveResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the load curve?'**
  String get planCurveResetTitle;

  /// No description provided for @planCurveResetBody.
  ///
  /// In en, this message translates to:
  /// **'Every week goes back to 100% of the proposal.'**
  String get planCurveResetBody;

  /// No description provided for @planCurveWeekSemantics.
  ///
  /// In en, this message translates to:
  /// **'Week {week}, {tss} TSS'**
  String planCurveWeekSemantics(int week, int tss);

  /// No description provided for @planWarnRamp.
  ///
  /// In en, this message translates to:
  /// **'More than +{percent}% over the last build week'**
  String planWarnRamp(int percent);

  /// No description provided for @planWarnCtl.
  ///
  /// In en, this message translates to:
  /// **'Above the CTL ramp limit'**
  String get planWarnCtl;

  /// No description provided for @planWarnHours.
  ///
  /// In en, this message translates to:
  /// **'Needs more than your weekly hours'**
  String get planWarnHours;

  /// No description provided for @planWeekBySport.
  ///
  /// In en, this message translates to:
  /// **'{sport} {tss}'**
  String planWeekBySport(String sport, int tss);

  /// No description provided for @planTargetPlanned.
  ///
  /// In en, this message translates to:
  /// **'Target {target} · planned {planned} TSS'**
  String planTargetPlanned(int target, int planned);

  /// No description provided for @planCurveFactor.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of proposal'**
  String planCurveFactor(int percent);

  /// No description provided for @planNotEnoughDays.
  ///
  /// In en, this message translates to:
  /// **'Your training days cannot hold this week. Add a day or set a sport to 0%.'**
  String get planNotEnoughDays;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
