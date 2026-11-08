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
  /// **'Insights'**
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

  /// No description provided for @appearanceDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get appearanceDeveloper;

  /// No description provided for @performanceUpTooltip.
  ///
  /// In en, this message translates to:
  /// **'More efficient than your recent average'**
  String get performanceUpTooltip;

  /// No description provided for @performanceDownTooltip.
  ///
  /// In en, this message translates to:
  /// **'Less efficient than your recent average'**
  String get performanceDownTooltip;

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

  /// No description provided for @trainingPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Training plans'**
  String get trainingPlansTitle;

  /// No description provided for @moreKnowledgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your own coaching documents the agent can search'**
  String get moreKnowledgeSubtitle;

  /// No description provided for @knowledgeLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge library'**
  String get knowledgeLibraryTitle;

  /// No description provided for @knowledgeImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get knowledgeImportButton;

  /// No description provided for @knowledgeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get knowledgeEmptyTitle;

  /// No description provided for @knowledgeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Import Markdown or text files with your own coaching notes, swim sets or taper guides. The chat agent searches them alongside the built-in reference — they never change your training plan.'**
  String get knowledgeEmptyBody;

  /// No description provided for @knowledgeSectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 section} other{{count} sections}}'**
  String knowledgeSectionCount(int count);

  /// No description provided for @knowledgeImportedOn.
  ///
  /// In en, this message translates to:
  /// **'Imported {date}'**
  String knowledgeImportedOn(String date);

  /// No description provided for @knowledgeDisabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get knowledgeDisabledLabel;

  /// No description provided for @knowledgeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this document?'**
  String get knowledgeDeleteTitle;

  /// No description provided for @knowledgeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and its sections will be removed from this device.'**
  String knowledgeDeleteConfirm(String title);

  /// No description provided for @knowledgeDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already imported'**
  String get knowledgeDuplicateTitle;

  /// No description provided for @knowledgeDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'A document named \"{fileName}\" already exists.'**
  String knowledgeDuplicateBody(String fileName);

  /// No description provided for @knowledgeReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get knowledgeReplaceButton;

  /// No description provided for @knowledgeKeepBothButton.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get knowledgeKeepBothButton;

  /// No description provided for @knowledgeImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 section imported} other{{count} sections imported}}'**
  String knowledgeImportSuccess(int count);

  /// No description provided for @knowledgeImportIgnoredBlocks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 structured block ignored} other{{count} structured blocks ignored}}'**
  String knowledgeImportIgnoredBlocks(int count);

  /// No description provided for @knowledgeImportRejected.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import {fileName}: {reason}'**
  String knowledgeImportRejected(String fileName, String reason);

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
  /// **'No activities cached yet.'**
  String get noActivitiesCachedConnected;

  /// No description provided for @noActivitiesOfType.
  ///
  /// In en, this message translates to:
  /// **'No {sport} activities cached.'**
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
  /// **'Nothing is saved until you take the plan. Tap a date to move a session.'**
  String get planPreviewNote;

  /// No description provided for @planConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Take as plan'**
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
  /// **'Connect Intervals.icu in Profile to build from your history and send plans there.'**
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
  /// **'Drag a week up or down within its shaded band (80–120% of the proposal). Lower a week by more than 10% for recovery.'**
  String get planCurveHint;

  /// No description provided for @planCurveProposal.
  ///
  /// In en, this message translates to:
  /// **'Dashed line = proposed load from {baseline} TSS, up to +{percent}% a week. A default, not a rule.'**
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
  /// **'Week {week} · {tss} TSS · {percent}%'**
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
  /// **'Increase by 5 TSS'**
  String get planCurveIncrease;

  /// No description provided for @planCurveDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease by 5 TSS'**
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
  /// **'Every week goes back to its proposed TSS.'**
  String get planCurveResetBody;

  /// No description provided for @planCurveWeekSemantics.
  ///
  /// In en, this message translates to:
  /// **'Week {week}, {percent}% of proposal'**
  String planCurveWeekSemantics(int week, int percent);

  /// No description provided for @planCurveTssValue.
  ///
  /// In en, this message translates to:
  /// **'{tss} TSS'**
  String planCurveTssValue(int tss);

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

  /// No description provided for @planTakenLocal.
  ///
  /// In en, this message translates to:
  /// **'Plan saved in TriIQ.'**
  String get planTakenLocal;

  /// No description provided for @planTakenNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Plan saved in TriIQ. Connect Intervals.icu to send it there.'**
  String get planTakenNotConnected;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @planSessionSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to Intervals.icu'**
  String get planSessionSent;

  /// No description provided for @planSessionLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Only in TriIQ'**
  String get planSessionLocalOnly;

  /// No description provided for @planSessionBadge.
  ///
  /// In en, this message translates to:
  /// **'TriIQ plan'**
  String get planSessionBadge;

  /// No description provided for @plannedTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Planned today'**
  String get plannedTodayTitle;

  /// No description provided for @plannedSourceIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu'**
  String get plannedSourceIntervals;

  /// No description provided for @showAllSteps.
  ///
  /// In en, this message translates to:
  /// **'Show all steps'**
  String get showAllSteps;

  /// No description provided for @showLessSteps.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLessSteps;

  /// No description provided for @findAlternative.
  ///
  /// In en, this message translates to:
  /// **'Find alternative'**
  String get findAlternative;

  /// No description provided for @changeTraining.
  ///
  /// In en, this message translates to:
  /// **'Change training'**
  String get changeTraining;

  /// No description provided for @replaceTodaySession.
  ///
  /// In en, this message translates to:
  /// **'Replace today\'s session'**
  String get replaceTodaySession;

  /// No description provided for @addAlongside.
  ///
  /// In en, this message translates to:
  /// **'Add alongside'**
  String get addAlongside;

  /// No description provided for @replacesSession.
  ///
  /// In en, this message translates to:
  /// **'Replaces “{name}”'**
  String replacesSession(String name);

  /// No description provided for @workoutReplaced.
  ///
  /// In en, this message translates to:
  /// **'{name} replaces today\'s session'**
  String workoutReplaced(String name);

  /// No description provided for @workoutReplacedLocal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan session changed in TriIQ'**
  String get workoutReplacedLocal;

  /// No description provided for @replaceBothExist.
  ///
  /// In en, this message translates to:
  /// **'The new workout was created, but the old one could not be deleted, so both are on your calendar. Delete the old one from the Calendar.'**
  String get replaceBothExist;

  /// No description provided for @replaceRefusedSent.
  ///
  /// In en, this message translates to:
  /// **'This session is in Intervals.icu. Connect and turn on Send plan to Intervals.icu to replace it.'**
  String get replaceRefusedSent;

  /// No description provided for @replaceRefusedOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu to replace this session.'**
  String get replaceRefusedOffline;

  /// No description provided for @couldNotReplace.
  ///
  /// In en, this message translates to:
  /// **'Could not replace the session: {error}'**
  String couldNotReplace(String error);

  /// No description provided for @planChangeMissing.
  ///
  /// In en, this message translates to:
  /// **'That session is no longer in the plan.'**
  String get planChangeMissing;

  /// No description provided for @planChangePast.
  ///
  /// In en, this message translates to:
  /// **'That session or date is in the past.'**
  String get planChangePast;

  /// No description provided for @planChangeOutsidePlan.
  ///
  /// In en, this message translates to:
  /// **'That date is outside the plan\'s weeks.'**
  String get planChangeOutsidePlan;

  /// No description provided for @planChangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That change isn\'t valid for the goal.'**
  String get planChangeInvalid;

  /// No description provided for @proposalCurveTitle.
  ///
  /// In en, this message translates to:
  /// **'Load graph change'**
  String get proposalCurveTitle;

  /// No description provided for @proposalPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'New training plan'**
  String get proposalPlanTitle;

  /// No description provided for @proposalMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move a session'**
  String get proposalMoveTitle;

  /// No description provided for @proposalRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove a session'**
  String get proposalRemoveTitle;

  /// No description provided for @proposalApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get proposalApply;

  /// No description provided for @proposalDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get proposalDismiss;

  /// No description provided for @proposalApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get proposalApplied;

  /// No description provided for @proposalDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get proposalDismissed;

  /// No description provided for @proposalStale.
  ///
  /// In en, this message translates to:
  /// **'Out of date: your goal or plan changed since. Ask again.'**
  String get proposalStale;

  /// No description provided for @proposalFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply: {error}'**
  String proposalFailed(String error);

  /// No description provided for @proposalPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Apply opens the plan preview, where you take the plan.'**
  String get proposalPlanHint;

  /// No description provided for @chatToolPlanRead.
  ///
  /// In en, this message translates to:
  /// **'Reading your plan…'**
  String get chatToolPlanRead;

  /// No description provided for @chatToolProposing.
  ///
  /// In en, this message translates to:
  /// **'Preparing a proposal…'**
  String get chatToolProposing;

  /// No description provided for @planCurveRampValue.
  ///
  /// In en, this message translates to:
  /// **'Weekly increase: {percent}%'**
  String planCurveRampValue(int percent);

  /// No description provided for @planCurveHold.
  ///
  /// In en, this message translates to:
  /// **'Hold every 4th week'**
  String get planCurveHold;

  /// No description provided for @planCurveHoldHelp.
  ///
  /// In en, this message translates to:
  /// **'Weeks 4, 8, 12… keep the previous week\'s load instead of ramping.'**
  String get planCurveHoldHelp;

  /// No description provided for @planGoalSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Session mix (share of each sport\'s load)'**
  String get planGoalSlotsTitle;

  /// No description provided for @slotZ2.
  ///
  /// In en, this message translates to:
  /// **'Z2'**
  String get slotZ2;

  /// No description provided for @slotIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get slotIntervals;

  /// No description provided for @slotLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get slotLong;

  /// No description provided for @planGoalSlotsReset.
  ///
  /// In en, this message translates to:
  /// **'Use the goal\'s default mix'**
  String get planGoalSlotsReset;

  /// No description provided for @planGoalPrefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get planGoalPrefsTitle;

  /// No description provided for @planGoalLongDay.
  ///
  /// In en, this message translates to:
  /// **'Long {sport} on'**
  String planGoalLongDay(String sport);

  /// No description provided for @planGoalAnyDay.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get planGoalAnyDay;

  /// No description provided for @planGoalIntervalDays.
  ///
  /// In en, this message translates to:
  /// **'Interval days'**
  String get planGoalIntervalDays;

  /// No description provided for @planGoalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Most sessions per day'**
  String get planGoalPerDay;

  /// No description provided for @planNoteLongDay.
  ///
  /// In en, this message translates to:
  /// **'The long {sport} couldn\'t go on its preferred day.'**
  String planNoteLongDay(String sport);

  /// No description provided for @planNoteIntervalDay.
  ///
  /// In en, this message translates to:
  /// **'The intervals couldn\'t go on a preferred interval day.'**
  String get planNoteIntervalDay;

  /// No description provided for @sessionDiagramTitle.
  ///
  /// In en, this message translates to:
  /// **'Over time'**
  String get sessionDiagramTitle;

  /// No description provided for @sessionDiagramNoData.
  ///
  /// In en, this message translates to:
  /// **'This activity has no time-series data (for example a manual entry).'**
  String get sessionDiagramNoData;

  /// No description provided for @sessionIntervalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get sessionIntervalsTitle;

  /// No description provided for @sessionIntervalN.
  ///
  /// In en, this message translates to:
  /// **'Interval {n}'**
  String sessionIntervalN(int n);

  /// No description provided for @streamPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get streamPower;

  /// No description provided for @streamHeartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get streamHeartRate;

  /// No description provided for @streamSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get streamSpeed;

  /// No description provided for @streamCadence.
  ///
  /// In en, this message translates to:
  /// **'Cadence'**
  String get streamCadence;

  /// No description provided for @streamAltitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get streamAltitude;

  /// No description provided for @sessionEvaluationTitle.
  ///
  /// In en, this message translates to:
  /// **'Evaluation'**
  String get sessionEvaluationTitle;

  /// No description provided for @verdictOnTarget.
  ///
  /// In en, this message translates to:
  /// **'On target'**
  String get verdictOnTarget;

  /// No description provided for @verdictTooHard.
  ///
  /// In en, this message translates to:
  /// **'Too hard'**
  String get verdictTooHard;

  /// No description provided for @verdictTooEasy.
  ///
  /// In en, this message translates to:
  /// **'Too easy'**
  String get verdictTooEasy;

  /// No description provided for @verdictCutShort.
  ///
  /// In en, this message translates to:
  /// **'Cut short'**
  String get verdictCutShort;

  /// No description provided for @evalNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No planned session to compare with.'**
  String get evalNoPlan;

  /// No description provided for @evalReasonShort.
  ///
  /// In en, this message translates to:
  /// **'{actual} of {planned} planned minutes'**
  String evalReasonShort(int actual, int planned);

  /// No description provided for @evalReasonTooIntense.
  ///
  /// In en, this message translates to:
  /// **'Planned easy, but {share} of the time was above the first threshold (limit {limit})'**
  String evalReasonTooIntense(String share, String limit);

  /// No description provided for @evalReasonNotIntense.
  ///
  /// In en, this message translates to:
  /// **'Planned hard, but only {share} of the time was above the first threshold (at least {minimum} expected)'**
  String evalReasonNotIntense(String share, String minimum);

  /// No description provided for @evalReasonLoad.
  ///
  /// In en, this message translates to:
  /// **'{actual} TSS against {planned} planned'**
  String evalReasonLoad(int actual, int planned);

  /// No description provided for @evalPlannedVsActual.
  ///
  /// In en, this message translates to:
  /// **'Planned: {name}'**
  String evalPlannedVsActual(String name);

  /// No description provided for @evalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{actual} of {planned} min ({delta})'**
  String evalMinutes(int actual, int planned, String delta);

  /// No description provided for @evalLoad.
  ///
  /// In en, this message translates to:
  /// **'{actual} of {planned} TSS ({delta})'**
  String evalLoad(int actual, int planned, String delta);

  /// No description provided for @evalSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity split'**
  String get evalSplitTitle;

  /// No description provided for @evalSplitNotAssessable.
  ///
  /// In en, this message translates to:
  /// **'No zone times for this session, so its intensity split cannot be assessed.'**
  String get evalSplitNotAssessable;

  /// No description provided for @domainLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get domainLow;

  /// No description provided for @domainModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get domainModerate;

  /// No description provided for @domainHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get domainHigh;

  /// No description provided for @evalDecoupling.
  ///
  /// In en, this message translates to:
  /// **'Aerobic decoupling: {percent}%'**
  String evalDecoupling(String percent);

  /// No description provided for @evalDecouplingNotAssessable.
  ///
  /// In en, this message translates to:
  /// **'Aerobic decoupling: not assessable (needs a steady session of at least an hour).'**
  String get evalDecouplingNotAssessable;

  /// No description provided for @evalThresholdsNote.
  ///
  /// In en, this message translates to:
  /// **'Thresholds follow the 80/20 rule in the training knowledge.'**
  String get evalThresholdsNote;

  /// No description provided for @askTrainer.
  ///
  /// In en, this message translates to:
  /// **'Ask the trainer'**
  String get askTrainer;

  /// No description provided for @chatAbout.
  ///
  /// In en, this message translates to:
  /// **'About: {title}'**
  String chatAbout(String title);

  /// No description provided for @plannedDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Done: {name}'**
  String plannedDoneTitle(String name);

  /// No description provided for @plannedOpenActivity.
  ///
  /// In en, this message translates to:
  /// **'Open the activity'**
  String get plannedOpenActivity;

  /// No description provided for @weeklyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get weeklyReviewTitle;

  /// No description provided for @weeklyReviewTopic.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weeklyReviewTopic(String date);

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @weeklyCompliance.
  ///
  /// In en, this message translates to:
  /// **'Plan vs done'**
  String get weeklyCompliance;

  /// No description provided for @weeklyNothingPlanned.
  ///
  /// In en, this message translates to:
  /// **'Nothing was planned this week.'**
  String get weeklyNothingPlanned;

  /// No description provided for @weeklyComplianceValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done ({done} of {planned} planned sessions)'**
  String weeklyComplianceValue(int percent, int done, int planned);

  /// No description provided for @weeklyLoadValue.
  ///
  /// In en, this message translates to:
  /// **'{load} of {planned} planned TSS'**
  String weeklyLoadValue(int load, int planned);

  /// No description provided for @weeklyMissed.
  ///
  /// In en, this message translates to:
  /// **'✗ missed: {name}'**
  String weeklyMissed(String name);

  /// No description provided for @weeklySplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity (80/20)'**
  String get weeklySplitTitle;

  /// No description provided for @weeklyOutside8020.
  ///
  /// In en, this message translates to:
  /// **'Only {percent}% easy: below the 80/20 tolerance.'**
  String weeklyOutside8020(int percent);

  /// No description provided for @weeklyNoZones.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session has no zone data and is not counted.} other{{count} sessions have no zone data and are not counted.}}'**
  String weeklyNoZones(int count);

  /// No description provided for @weeklyTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Load trend'**
  String get weeklyTrendTitle;

  /// No description provided for @weeklyNoHistory.
  ///
  /// In en, this message translates to:
  /// **'Not enough earlier weeks cached to compare.'**
  String get weeklyNoHistory;

  /// No description provided for @weeklyVsRecent.
  ///
  /// In en, this message translates to:
  /// **'{delta}% against the 4-week average of {average} TSS'**
  String weeklyVsRecent(String delta, int average);

  /// No description provided for @weeklyFitness.
  ///
  /// In en, this message translates to:
  /// **'CTL {ctl}, ATL {atl} over the week; form {form}'**
  String weeklyFitness(String ctl, String atl, String form);

  /// No description provided for @weeklyNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get weeklyNoteTitle;

  /// No description provided for @weeklyNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested by the trainer from the figures above (an inference, not a measurement).'**
  String get weeklyNoteLabel;

  /// No description provided for @weeklyOpenInChat.
  ///
  /// In en, this message translates to:
  /// **'Discuss in Chat'**
  String get weeklyOpenInChat;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsBests.
  ///
  /// In en, this message translates to:
  /// **'Personal bests'**
  String get insightsBests;

  /// No description provided for @bestPower.
  ///
  /// In en, this message translates to:
  /// **'Best {duration} power {watts} W'**
  String bestPower(String duration, int watts);

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Fastest {distance}: {time}'**
  String bestTime(String distance, String time);

  /// No description provided for @bestOther.
  ///
  /// In en, this message translates to:
  /// **'Best effort {value}'**
  String bestOther(String value);

  /// No description provided for @bestWas.
  ///
  /// In en, this message translates to:
  /// **'{best} (was {previous})'**
  String bestWas(String best, String previous);

  /// No description provided for @insightsEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Aerobic efficiency'**
  String get insightsEfficiency;

  /// No description provided for @insightsEfficiencyChange.
  ///
  /// In en, this message translates to:
  /// **'Efficiency factor {value}: {change}% against your 6-week median ({sessions} easy sessions)'**
  String insightsEfficiencyChange(String value, String change, int sessions);

  /// No description provided for @insightsEfficiencyTooFew.
  ///
  /// In en, this message translates to:
  /// **'Efficiency factor {value}. Not enough history yet (needs {min} easy sessions in 6 weeks).'**
  String insightsEfficiencyTooFew(String value, int min);

  /// No description provided for @insightsRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery (estimate)'**
  String get insightsRecovery;

  /// No description provided for @insightsRecoveryHours.
  ///
  /// In en, this message translates to:
  /// **'About {hours} hours'**
  String insightsRecoveryHours(int hours);

  /// No description provided for @insightsRecoveryRule.
  ///
  /// In en, this message translates to:
  /// **'From {tss} TSS, by the recovery rule in the training knowledge.'**
  String insightsRecoveryRule(int tss);

  /// No description provided for @insightsRecoveryRuleForm.
  ///
  /// In en, this message translates to:
  /// **'From {tss} TSS, plus extra time because your form is {form}, by the recovery rule in the training knowledge.'**
  String insightsRecoveryRuleForm(int tss, String form);

  /// No description provided for @insightsRecoveryConflict.
  ///
  /// In en, this message translates to:
  /// **'That runs into tomorrow\'s {name}. Consider an easier alternative.'**
  String insightsRecoveryConflict(String name);

  /// No description provided for @newTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'New training'**
  String get newTrainingTitle;

  /// No description provided for @newTrainingOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get newTrainingOk;

  /// No description provided for @newTrainingDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get newTrainingDetails;

  /// No description provided for @insightsPopupSetting.
  ///
  /// In en, this message translates to:
  /// **'Show new training when opening the app'**
  String get insightsPopupSetting;

  /// No description provided for @insightsPopupSettingHelp.
  ///
  /// In en, this message translates to:
  /// **'Today\'s new sessions with their analysis, once each.'**
  String get insightsPopupSettingHelp;

  /// No description provided for @calendarSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarSettingsTitle;

  /// No description provided for @calendarSendPlan.
  ///
  /// In en, this message translates to:
  /// **'Send plan to Intervals.icu'**
  String get calendarSendPlan;

  /// No description provided for @calendarSendPlanHelp.
  ///
  /// In en, this message translates to:
  /// **'Off keeps training plans in TriIQ only.'**
  String get calendarSendPlanHelp;

  /// No description provided for @calendarCopyEvents.
  ///
  /// In en, this message translates to:
  /// **'Copy planned events from Intervals.icu'**
  String get calendarCopyEvents;

  /// No description provided for @calendarCopyEventsHelp.
  ///
  /// In en, this message translates to:
  /// **'Off hides workouts planned in Intervals.icu. Completed activities still sync.'**
  String get calendarCopyEventsHelp;

  /// No description provided for @calendarSendNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Send your plan now?'**
  String get calendarSendNowTitle;

  /// No description provided for @calendarSendNowBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 upcoming plan session is only in TriIQ.} other{{count} upcoming plan sessions are only in TriIQ.}}'**
  String calendarSendNowBody(int count);

  /// No description provided for @calendarSendNow.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send 1 session} other{Send {count} sessions}}'**
  String calendarSendNow(int count);

  /// No description provided for @calendarSendLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get calendarSendLater;

  /// No description provided for @planNotEnoughDays.
  ///
  /// In en, this message translates to:
  /// **'Your training days cannot hold this week. Add a day or set a sport to 0%.'**
  String get planNotEnoughDays;

  /// No description provided for @weeklyTargetsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly targets'**
  String get weeklyTargetsSectionTitle;

  /// No description provided for @weeklyTargetsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'A weekly training-time goal per sport. Leave a field blank for no target.'**
  String get weeklyTargetsSectionHelp;

  /// No description provided for @weeklyTargetHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{sport} — hours per week'**
  String weeklyTargetHoursLabel(String sport);

  /// No description provided for @weeklyTargetShowOnToday.
  ///
  /// In en, this message translates to:
  /// **'Show on Today'**
  String get weeklyTargetShowOnToday;

  /// No description provided for @weeklyTargetShowOnTodayHelp.
  ///
  /// In en, this message translates to:
  /// **'A progress ring per sport with a target set.'**
  String get weeklyTargetShowOnTodayHelp;

  /// No description provided for @performanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Performance curves'**
  String get performanceTitle;

  /// No description provided for @performanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best efforts by duration and distance, season against season'**
  String get performanceSubtitle;

  /// No description provided for @curveMetricPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get curveMetricPower;

  /// No description provided for @curveMetricPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get curveMetricPace;

  /// No description provided for @curveMetricHr.
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get curveMetricHr;

  /// No description provided for @curvePeriodThisSeason.
  ///
  /// In en, this message translates to:
  /// **'This season'**
  String get curvePeriodThisSeason;

  /// No description provided for @curvePeriodLastSeason.
  ///
  /// In en, this message translates to:
  /// **'Last season'**
  String get curvePeriodLastSeason;

  /// No description provided for @curvePeriodLast42.
  ///
  /// In en, this message translates to:
  /// **'Last 42 days'**
  String get curvePeriodLast42;

  /// No description provided for @curvePeriodNoData.
  ///
  /// In en, this message translates to:
  /// **'{period}: no data'**
  String curvePeriodNoData(String period);

  /// No description provided for @curvePeriodRange.
  ///
  /// In en, this message translates to:
  /// **'{period} ({from} – {to})'**
  String curvePeriodRange(String period, String from, String to);

  /// No description provided for @curveAxisDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get curveAxisDuration;

  /// No description provided for @curveAxisDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get curveAxisDistance;

  /// No description provided for @curveAxisPower.
  ///
  /// In en, this message translates to:
  /// **'Power (W)'**
  String get curveAxisPower;

  /// No description provided for @curveAxisHr.
  ///
  /// In en, this message translates to:
  /// **'Heart rate (bpm)'**
  String get curveAxisHr;

  /// No description provided for @curveAxisPace.
  ///
  /// In en, this message translates to:
  /// **'Pace ({unit})'**
  String curveAxisPace(String unit);

  /// No description provided for @curveTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap or drag the chart to read a value.'**
  String get curveTapHint;

  /// No description provided for @curveOpenSession.
  ///
  /// In en, this message translates to:
  /// **'Open session'**
  String get curveOpenSession;

  /// No description provided for @curveSessionNotCached.
  ///
  /// In en, this message translates to:
  /// **'That session isn\'t in the local cache yet — sync its date range first.'**
  String get curveSessionNotCached;

  /// No description provided for @curvesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No efforts for this sport and metric yet.'**
  String get curvesEmpty;

  /// No description provided for @keyEffortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Key efforts'**
  String get keyEffortsTitle;

  /// No description provided for @keyEffortsChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get keyEffortsChange;

  /// No description provided for @modelCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Model fit (Intervals.icu)'**
  String get modelCardTitle;

  /// No description provided for @modelNone.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu returned no model fit for this curve.'**
  String get modelNone;

  /// No description provided for @modelSettingsValue.
  ///
  /// In en, this message translates to:
  /// **'In your settings'**
  String get modelSettingsValue;

  /// No description provided for @modelNoSettingsValue.
  ///
  /// In en, this message translates to:
  /// **'Not set in your Intervals.icu settings'**
  String get modelNoSettingsValue;

  /// No description provided for @modelGap.
  ///
  /// In en, this message translates to:
  /// **'Model {model} vs settings {settings}: {diff}'**
  String modelGap(String model, String settings, String diff);

  /// No description provided for @modelCriticalSpeed.
  ///
  /// In en, this message translates to:
  /// **'Critical speed'**
  String get modelCriticalSpeed;

  /// No description provided for @thresholdSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Threshold suggestions'**
  String get thresholdSuggestionsTitle;

  /// No description provided for @thresholdChangeLine.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String thresholdChangeLine(String from, String to);

  /// No description provided for @thresholdBasisRideSeasonModel.
  ///
  /// In en, this message translates to:
  /// **'This season\'s model fit is {percent}% above your current FTP.'**
  String thresholdBasisRideSeasonModel(String percent);

  /// No description provided for @thresholdBasisRideRecentModel.
  ///
  /// In en, this message translates to:
  /// **'The last 42 days\' model fit is {percent}% below your current FTP — likely dropped.'**
  String thresholdBasisRideRecentModel(String percent);

  /// No description provided for @thresholdBasisRunSeason60Min.
  ///
  /// In en, this message translates to:
  /// **'Your season\'s ~60-minute best effort is {percent}% faster than your current threshold pace.'**
  String thresholdBasisRunSeason60Min(String percent);

  /// No description provided for @thresholdBasisRunSeason40MinHeuristic.
  ///
  /// In en, this message translates to:
  /// **'Estimated from your season\'s ~40-minute best effort (heuristic: scaled toward a sustainable 60-minute pace).'**
  String get thresholdBasisRunSeason40MinHeuristic;

  /// No description provided for @thresholdBasisRunRecent60Min.
  ///
  /// In en, this message translates to:
  /// **'Your recent best effort is {percent}% slower than your current threshold pace — likely dropped.'**
  String thresholdBasisRunRecent60Min(String percent);

  /// No description provided for @thresholdBasisRunRecent40MinHeuristic.
  ///
  /// In en, this message translates to:
  /// **'Estimated from your recent ~40-minute best effort (heuristic) — likely dropped.'**
  String get thresholdBasisRunRecent40MinHeuristic;

  /// No description provided for @thresholdBasisSwimSeasonCss.
  ///
  /// In en, this message translates to:
  /// **'CSS from your season\'s 400 m and 200 m bests is {percent}% faster than your current threshold pace.'**
  String thresholdBasisSwimSeasonCss(String percent);

  /// No description provided for @thresholdBasisSwimRecentCss.
  ///
  /// In en, this message translates to:
  /// **'CSS from your recent 400 m / 200 m efforts is {percent}% slower — likely dropped.'**
  String thresholdBasisSwimRecentCss(String percent);

  /// No description provided for @thresholdReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get thresholdReviewButton;

  /// No description provided for @thresholdUndoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get thresholdUndoButton;

  /// No description provided for @thresholdConfirmSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Update threshold?'**
  String get thresholdConfirmSheetTitle;

  /// No description provided for @thresholdCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get thresholdCurrentLabel;

  /// No description provided for @thresholdNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get thresholdNewLabel;

  /// No description provided for @thresholdZonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone ranges'**
  String get thresholdZonesTitle;

  /// No description provided for @thresholdZonesBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get thresholdZonesBefore;

  /// No description provided for @thresholdZonesAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get thresholdZonesAfter;

  /// No description provided for @thresholdRecalcHrZones.
  ///
  /// In en, this message translates to:
  /// **'Also recalculate HR zones'**
  String get thresholdRecalcHrZones;

  /// No description provided for @thresholdPastLoadNote.
  ///
  /// In en, this message translates to:
  /// **'Past activities keep their recorded load — this only changes zones and new sessions going forward.'**
  String get thresholdPastLoadNote;

  /// No description provided for @thresholdIndoorFtpNote.
  ///
  /// In en, this message translates to:
  /// **'Indoor FTP is set separately and won\'t change.'**
  String get thresholdIndoorFtpNote;

  /// No description provided for @thresholdEffortsUsedTitle.
  ///
  /// In en, this message translates to:
  /// **'Efforts used'**
  String get thresholdEffortsUsedTitle;

  /// No description provided for @thresholdUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get thresholdUpdating;

  /// No description provided for @thresholdUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update: {error}'**
  String thresholdUpdateFailed(String error);

  /// No description provided for @thresholdUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get thresholdUpdateSuccess;

  /// No description provided for @thresholdUndoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored to the previous value'**
  String get thresholdUndoSuccess;

  /// No description provided for @thresholdUndoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t undo: {error}'**
  String thresholdUndoFailed(String error);

  /// No description provided for @readinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get readinessTitle;

  /// No description provided for @readinessReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readinessReady;

  /// No description provided for @readinessCaution.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get readinessCaution;

  /// No description provided for @readinessBackOff.
  ///
  /// In en, this message translates to:
  /// **'Back off'**
  String get readinessBackOff;

  /// No description provided for @readinessAllOk.
  ///
  /// In en, this message translates to:
  /// **'All signals in your normal range'**
  String get readinessAllOk;

  /// No description provided for @readinessReasons.
  ///
  /// In en, this message translates to:
  /// **'Due to {signals}'**
  String readinessReasons(String signals);

  /// No description provided for @readinessNoData.
  ///
  /// In en, this message translates to:
  /// **'No wellness data'**
  String get readinessNoData;

  /// No description provided for @readinessNoDataHint.
  ///
  /// In en, this message translates to:
  /// **'Connect a watch or HRV app to Intervals.icu to see HRV, resting HR and sleep here.'**
  String get readinessNoDataHint;

  /// No description provided for @readinessWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for today\'s data (last: {date})'**
  String readinessWaiting(String date);

  /// No description provided for @readinessSignalHrv.
  ///
  /// In en, this message translates to:
  /// **'HRV'**
  String get readinessSignalHrv;

  /// No description provided for @readinessSignalRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Resting HR'**
  String get readinessSignalRestingHr;

  /// No description provided for @readinessSignalSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get readinessSignalSleep;

  /// No description provided for @readinessSignalForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get readinessSignalForm;

  /// No description provided for @readinessSignalSubjective.
  ///
  /// In en, this message translates to:
  /// **'Fatigue / soreness'**
  String get readinessSignalSubjective;

  /// No description provided for @readinessRatingOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get readinessRatingOk;

  /// No description provided for @readinessRatingNoBaseline.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet'**
  String get readinessRatingNoBaseline;

  /// No description provided for @readinessRatingMissing.
  ///
  /// In en, this message translates to:
  /// **'No value today'**
  String get readinessRatingMissing;

  /// No description provided for @readinessRangeHrv.
  ///
  /// In en, this message translates to:
  /// **'Normal from {value} ms (avg {mean} ms)'**
  String readinessRangeHrv(String value, String mean);

  /// No description provided for @readinessRangeRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Normal up to {value} bpm (avg {mean} bpm)'**
  String readinessRangeRestingHr(String value, String mean);

  /// No description provided for @readinessRangeSleep.
  ///
  /// In en, this message translates to:
  /// **'Normal from {value} h'**
  String readinessRangeSleep(String value);

  /// No description provided for @readinessRangeForm.
  ///
  /// In en, this message translates to:
  /// **'Normal from {value}'**
  String readinessRangeForm(String value);

  /// No description provided for @readinessSubjectiveValues.
  ///
  /// In en, this message translates to:
  /// **'Fatigue {fatigue} · soreness {soreness} (1 good, 4 bad)'**
  String readinessSubjectiveValues(String fatigue, String soreness);

  /// No description provided for @readinessDevice.
  ///
  /// In en, this message translates to:
  /// **'Device readiness {value}'**
  String readinessDevice(String value);

  /// No description provided for @readinessTrend.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get readinessTrend;

  /// No description provided for @readinessDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Thresholds are general defaults from the training knowledge, not medical advice.'**
  String get readinessDisclaimer;

  /// No description provided for @readinessHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Consider an easier day'**
  String get readinessHintTitle;

  /// No description provided for @readinessHintBody.
  ///
  /// In en, this message translates to:
  /// **'Readiness is {level} and today\'s plan has {session}.'**
  String readinessHintBody(String level, String session);

  /// No description provided for @readinessTopic.
  ///
  /// In en, this message translates to:
  /// **'Readiness today'**
  String get readinessTopic;

  /// No description provided for @readinessChatDraft.
  ///
  /// In en, this message translates to:
  /// **'My readiness today is {level} ({reasons}). Should I still do {session}?'**
  String readinessChatDraft(String level, String reasons, String session);

  /// No description provided for @proposalSwapTitle.
  ///
  /// In en, this message translates to:
  /// **'Swap two sessions'**
  String get proposalSwapTitle;

  /// No description provided for @proposalLetGoTitle.
  ///
  /// In en, this message translates to:
  /// **'Let it go'**
  String get proposalLetGoTitle;

  /// No description provided for @proposalCatchUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Catch up a missed session'**
  String get proposalCatchUpTitle;

  /// No description provided for @adaptMissedReason.
  ///
  /// In en, this message translates to:
  /// **'Missed on {day}: nothing logged for it.'**
  String adaptMissedReason(String day);

  /// No description provided for @adaptLoadUnderReason.
  ///
  /// In en, this message translates to:
  /// **'Week {week}: {actual} of {target} TSS done. Next week {from} → {to} TSS.'**
  String adaptLoadUnderReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  );

  /// No description provided for @adaptLoadOverReason.
  ///
  /// In en, this message translates to:
  /// **'Week {week}: {actual} of {target} TSS done, well above plan. Next week {from} → {to} TSS.'**
  String adaptLoadOverReason(
    int week,
    int actual,
    int target,
    int from,
    int to,
  );

  /// No description provided for @adaptLoadFloor.
  ///
  /// In en, this message translates to:
  /// **'Held at 80 % of the proposal; the ramp alone would say {load} TSS.'**
  String adaptLoadFloor(int load);

  /// No description provided for @adaptLoadRegenerate.
  ///
  /// In en, this message translates to:
  /// **'The week\'s sessions follow when you regenerate the plan.'**
  String get adaptLoadRegenerate;

  /// No description provided for @adaptReadinessReason.
  ///
  /// In en, this message translates to:
  /// **'Readiness: {level}.'**
  String adaptReadinessReason(String level);

  /// No description provided for @todayAdjustmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan adjustments'**
  String get todayAdjustmentsTitle;

  /// No description provided for @planPhaseTaper.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get planPhaseTaper;

  /// No description provided for @planPhaseRace.
  ///
  /// In en, this message translates to:
  /// **'Race week'**
  String get planPhaseRace;

  /// No description provided for @planCurveRaceShort.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get planCurveRaceShort;

  /// No description provided for @planEventBeyondPlan.
  ///
  /// In en, this message translates to:
  /// **'Your event is {weeks} weeks away, more than one block: this block builds without a taper. A plan ending with the taper can be generated once the event is at most 16 weeks away.'**
  String planEventBeyondPlan(int weeks);

  /// No description provided for @todayRaceCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Race tomorrow} other{Race in {days} days}}'**
  String todayRaceCountdown(int days);

  /// No description provided for @todayRaceDay.
  ///
  /// In en, this message translates to:
  /// **'Race day!'**
  String get todayRaceDay;

  /// No description provided for @feelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get feelDialogTitle;

  /// No description provided for @feelScaleHint.
  ///
  /// In en, this message translates to:
  /// **'1 good, 4 bad'**
  String get feelScaleHint;

  /// No description provided for @feelFatigueLabel.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get feelFatigueLabel;

  /// No description provided for @feelSorenessLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle soreness'**
  String get feelSorenessLabel;

  /// No description provided for @feelSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get feelSaveButton;

  /// No description provided for @feelActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Fatigue & soreness'**
  String get feelActionLabel;

  /// No description provided for @feelNotConnectedHint.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu to set this'**
  String get feelNotConnectedHint;

  /// No description provided for @feelSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue & soreness'**
  String get feelSettingsTitle;

  /// No description provided for @feelPromptOnNewActivity.
  ///
  /// In en, this message translates to:
  /// **'Prompt for a recent activity'**
  String get feelPromptOnNewActivity;

  /// No description provided for @feelPromptOnNewActivityHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask once, the first time a recent activity\'s detail screen opens, if that day has nothing set yet. Setting it manually on any activity always works, on or off.'**
  String get feelPromptOnNewActivityHelp;

  /// No description provided for @deleteDayTrainingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all trainings of the day?'**
  String get deleteDayTrainingsTitle;

  /// No description provided for @deleteDayTrainingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count} planned session(s) are removed from your Intervals.icu calendar. This can\'t be undone.'**
  String deleteDayTrainingsConfirm(int count);

  /// No description provided for @dayTrainingsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} session(s) deleted.'**
  String dayTrainingsDeleted(int count);

  /// No description provided for @customizeTodayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Customize Today'**
  String get customizeTodayTooltip;

  /// No description provided for @customizeTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Today'**
  String get customizeTodayTitle;

  /// No description provided for @customizeTodayHelp.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Switch a section off to remove it from Today.'**
  String get customizeTodayHelp;

  /// No description provided for @customizeTodayReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get customizeTodayReset;

  /// No description provided for @todaySectionReadiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get todaySectionReadiness;

  /// No description provided for @todaySectionMetrics.
  ///
  /// In en, this message translates to:
  /// **'Load metrics'**
  String get todaySectionMetrics;

  /// No description provided for @todaySectionThresholds.
  ///
  /// In en, this message translates to:
  /// **'Threshold suggestions'**
  String get todaySectionThresholds;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @moreEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Races, notes, holidays and more'**
  String get moreEventsSubtitle;

  /// No description provided for @eventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events yet. Add a race or a note.'**
  String get eventsEmpty;

  /// No description provided for @eventsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get eventsUpcoming;

  /// No description provided for @eventsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get eventsPast;

  /// No description provided for @eventAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get eventAddTooltip;

  /// No description provided for @eventNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get eventNewTitle;

  /// No description provided for @eventEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEditTitle;

  /// No description provided for @eventCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get eventCategoryLabel;

  /// No description provided for @eventNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get eventNameLabel;

  /// No description provided for @eventDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventDateLabel;

  /// No description provided for @eventEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Until (optional)'**
  String get eventEndDateLabel;

  /// No description provided for @eventSportLabel.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get eventSportLabel;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionLabel;

  /// No description provided for @eventSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get eventSaveButton;

  /// No description provided for @eventNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get eventNameRequired;

  /// No description provided for @eventNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu to add or edit events.'**
  String get eventNotConnected;

  /// No description provided for @eventCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save the event: {error}'**
  String eventCouldNotSave(String error);

  /// No description provided for @eventDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is removed from your Intervals.icu calendar. This can\'t be undone.'**
  String eventDeleteConfirm(String name);

  /// No description provided for @eventDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted.'**
  String eventDeleted(String name);

  /// No description provided for @eventCategoryRaceA.
  ///
  /// In en, this message translates to:
  /// **'Race (A)'**
  String get eventCategoryRaceA;

  /// No description provided for @eventCategoryRaceB.
  ///
  /// In en, this message translates to:
  /// **'Race (B)'**
  String get eventCategoryRaceB;

  /// No description provided for @eventCategoryRaceC.
  ///
  /// In en, this message translates to:
  /// **'Race (C)'**
  String get eventCategoryRaceC;

  /// No description provided for @eventCategoryNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get eventCategoryNote;

  /// No description provided for @eventCategoryHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get eventCategoryHoliday;

  /// No description provided for @eventCategorySick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get eventCategorySick;

  /// No description provided for @eventCategoryInjured.
  ///
  /// In en, this message translates to:
  /// **'Injured'**
  String get eventCategoryInjured;

  /// No description provided for @eventCategoryTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get eventCategoryTarget;

  /// No description provided for @eventCategorySeasonStart.
  ///
  /// In en, this message translates to:
  /// **'Season start'**
  String get eventCategorySeasonStart;

  /// No description provided for @chartZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get chartZoomIn;

  /// No description provided for @chartZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get chartZoomOut;

  /// No description provided for @chartZoomReset.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get chartZoomReset;

  /// No description provided for @streamSmoothing.
  ///
  /// In en, this message translates to:
  /// **'Smoothing'**
  String get streamSmoothing;

  /// No description provided for @smoothOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get smoothOff;

  /// No description provided for @zoomToInterval.
  ///
  /// In en, this message translates to:
  /// **'Zoom to interval'**
  String get zoomToInterval;

  /// No description provided for @metricTssTodayExplainer.
  ///
  /// In en, this message translates to:
  /// **'TSS (training stress score) puts one number on how hard today\'s sessions were, from duration and intensity. 100 is roughly an hour at your threshold. Compare it with what was planned, not with other people.'**
  String get metricTssTodayExplainer;

  /// No description provided for @metricTssWeekExplainer.
  ///
  /// In en, this message translates to:
  /// **'The sum of this week\'s TSS (Monday to Sunday) against what the plan asks for — the quickest check on whether you are on track. A single easy or hard day matters less than the week as a whole.'**
  String get metricTssWeekExplainer;

  /// No description provided for @tileShowHistory.
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get tileShowHistory;

  /// No description provided for @weekActivitiesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekActivitiesThisWeek;

  /// No description provided for @weekActivitiesAllSports.
  ///
  /// In en, this message translates to:
  /// **'All sports'**
  String get weekActivitiesAllSports;

  /// No description provided for @weekActivitiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activities this week yet.'**
  String get weekActivitiesEmpty;

  /// No description provided for @yearGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Year goals'**
  String get yearGoalsTitle;

  /// No description provided for @yearGoalsHelp.
  ///
  /// In en, this message translates to:
  /// **'A distance goal per sport for this calendar year. Leave a field blank for no goal. Progress counts the activities cached on this device — sync the year in Settings → Data & privacy → Sync for the full picture.'**
  String get yearGoalsHelp;

  /// No description provided for @yearGoalKmLabel.
  ///
  /// In en, this message translates to:
  /// **'{sport} goal (km per year)'**
  String yearGoalKmLabel(String sport);

  /// No description provided for @yearGoalShowOnToday.
  ///
  /// In en, this message translates to:
  /// **'Show on Today'**
  String get yearGoalShowOnToday;

  /// No description provided for @yearGoalShowOnTodayHelp.
  ///
  /// In en, this message translates to:
  /// **'A progress card for your year goals.'**
  String get yearGoalShowOnTodayHelp;

  /// No description provided for @yearGoalOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get yearGoalOnTrack;

  /// No description provided for @yearGoalAhead.
  ///
  /// In en, this message translates to:
  /// **'{km} km ahead of pace'**
  String yearGoalAhead(String km);

  /// No description provided for @yearGoalBehind.
  ///
  /// In en, this message translates to:
  /// **'{km} km behind pace'**
  String yearGoalBehind(String km);

  /// No description provided for @yearGoalProjection.
  ///
  /// In en, this message translates to:
  /// **'On pace for {km} km'**
  String yearGoalProjection(String km);

  /// No description provided for @todaySectionYearGoals.
  ///
  /// In en, this message translates to:
  /// **'Year goals'**
  String get todaySectionYearGoals;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Metric explorer'**
  String get analysisTitle;

  /// No description provided for @analysisFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get analysisFilters;

  /// No description provided for @analysisPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get analysisPeriod;

  /// No description provided for @analysisRange30d.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get analysisRange30d;

  /// No description provided for @analysisRange90d.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get analysisRange90d;

  /// No description provided for @analysisRange6m.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get analysisRange6m;

  /// No description provided for @analysisRange1y.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get analysisRange1y;

  /// No description provided for @analysisRangeYtd.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get analysisRangeYtd;

  /// No description provided for @analysisRangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get analysisRangeCustom;

  /// No description provided for @analysisSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get analysisSport;

  /// No description provided for @analysisSportAll.
  ///
  /// In en, this message translates to:
  /// **'All sports'**
  String get analysisSportAll;

  /// No description provided for @analysisResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get analysisResolution;

  /// No description provided for @analysisDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get analysisDay;

  /// No description provided for @analysisWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get analysisWeek;

  /// No description provided for @analysisRolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling average'**
  String get analysisRolling;

  /// No description provided for @analysisShowExtremes.
  ///
  /// In en, this message translates to:
  /// **'Mark min / max'**
  String get analysisShowExtremes;

  /// No description provided for @analysisShowBand.
  ///
  /// In en, this message translates to:
  /// **'Standard deviation band (±1 σ)'**
  String get analysisShowBand;

  /// No description provided for @analysisMetrics.
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get analysisMetrics;

  /// No description provided for @analysisMetricTss.
  ///
  /// In en, this message translates to:
  /// **'Training load (TSS)'**
  String get analysisMetricTss;

  /// No description provided for @analysisMetricHours.
  ///
  /// In en, this message translates to:
  /// **'Training time (h)'**
  String get analysisMetricHours;

  /// No description provided for @analysisMetricDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get analysisMetricDistance;

  /// No description provided for @analysisMetricSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep (h)'**
  String get analysisMetricSleep;

  /// No description provided for @analysisHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any graph to compare all metrics at that point. Pinch or use + / − to zoom them together.'**
  String get analysisHint;

  /// No description provided for @analysisNoData.
  ///
  /// In en, this message translates to:
  /// **'No data in this period.'**
  String get analysisNoData;

  /// No description provided for @analysisPickMetric.
  ///
  /// In en, this message translates to:
  /// **'Select at least one metric above.'**
  String get analysisPickMetric;

  /// No description provided for @analysisWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String analysisWeekOf(String date);

  /// No description provided for @activityChatDraft.
  ///
  /// In en, this message translates to:
  /// **'Please review my session “{name}” from {date}: how did it go, and what should I do differently or next?'**
  String activityChatDraft(String name, String date);

  /// No description provided for @weeklyReviewChatDraft.
  ///
  /// In en, this message translates to:
  /// **'Please review my training week of {date}: what went well, what didn\'t, and what should I focus on next week?'**
  String weeklyReviewChatDraft(String date);

  /// No description provided for @tileChatDraft.
  ///
  /// In en, this message translates to:
  /// **'My {label} is {value} right now. What does that mean for my training, and should I change anything this week?'**
  String tileChatDraft(String label, String value);

  /// No description provided for @analysisChatDraft.
  ///
  /// In en, this message translates to:
  /// **'Here is my analysis for {period}. What stands out, and what should I adjust?'**
  String analysisChatDraft(String period);

  /// No description provided for @seasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get seasonTitle;

  /// No description provided for @moreSeasonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness forecast, race calendar, race predictor'**
  String get moreSeasonSubtitle;

  /// No description provided for @seasonNoFitness.
  ///
  /// In en, this message translates to:
  /// **'No fitness data yet. Sync Intervals.icu first.'**
  String get seasonNoFitness;

  /// No description provided for @seasonLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the season: {error}'**
  String seasonLoadError(String error);

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness forecast'**
  String get forecastTitle;

  /// No description provided for @forecastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness, fatigue and form projected from your planned sessions. Days without a plan count as rest.'**
  String get forecastSubtitle;

  /// No description provided for @forecastCtl.
  ///
  /// In en, this message translates to:
  /// **'Fitness (CTL)'**
  String get forecastCtl;

  /// No description provided for @forecastAtl.
  ///
  /// In en, this message translates to:
  /// **'Fatigue (ATL)'**
  String get forecastAtl;

  /// No description provided for @forecastForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get forecastForm;

  /// No description provided for @forecastRaceForm.
  ///
  /// In en, this message translates to:
  /// **'Form on race day ({name}): {form}'**
  String forecastRaceForm(String name, String form);

  /// No description provided for @forecastBandLoaded.
  ///
  /// In en, this message translates to:
  /// **'Still carrying fatigue — expect heavy legs.'**
  String get forecastBandLoaded;

  /// No description provided for @forecastBandNeutral.
  ///
  /// In en, this message translates to:
  /// **'Balanced: neither fresh nor tired.'**
  String get forecastBandNeutral;

  /// No description provided for @forecastBandFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh — a good place to race from.'**
  String get forecastBandFresh;

  /// No description provided for @forecastBandDetrained.
  ///
  /// In en, this message translates to:
  /// **'Very fresh: fitness is starting to fade from too much rest.'**
  String get forecastBandDetrained;

  /// No description provided for @forecastPeak.
  ///
  /// In en, this message translates to:
  /// **'Form peaks on {date} at {form}.'**
  String forecastPeak(String date, String form);

  /// No description provided for @forecastPlannedEnd.
  ///
  /// In en, this message translates to:
  /// **'Fitness on {date}: {ctl} (form {form})'**
  String forecastPlannedEnd(String date, String ctl, String form);

  /// No description provided for @seasonTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Season timeline'**
  String get seasonTimelineTitle;

  /// No description provided for @seasonNoRaces.
  ///
  /// In en, this message translates to:
  /// **'No races yet. Add a race (priority A, B or C) under More → Events, or set an event date in your training goal.'**
  String get seasonNoRaces;

  /// No description provided for @seasonRaceLine.
  ///
  /// In en, this message translates to:
  /// **'{priority} race · {name} · {date} ({weeks} wk)'**
  String seasonRaceLine(String priority, String name, String date, int weeks);

  /// No description provided for @blockBase.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get blockBase;

  /// No description provided for @blockBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get blockBuild;

  /// No description provided for @blockTaper.
  ///
  /// In en, this message translates to:
  /// **'Taper'**
  String get blockTaper;

  /// No description provided for @blockRace.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get blockRace;

  /// No description provided for @blockRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get blockRecovery;

  /// No description provided for @conflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get conflictsTitle;

  /// No description provided for @conflictNone.
  ///
  /// In en, this message translates to:
  /// **'No conflicts in your race calendar.'**
  String get conflictNone;

  /// No description provided for @conflictTooCloseA.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} are both A races only {days} days apart. Peaking twice needs about 6 weeks — make one a B race.'**
  String conflictTooCloseA(String first, String second, int days);

  /// No description provided for @conflictInsideTaper.
  ///
  /// In en, this message translates to:
  /// **'{second} falls in the taper for {first}. Treat it as a training race or skip it.'**
  String conflictInsideTaper(String first, String second);

  /// No description provided for @conflictSameDay.
  ///
  /// In en, this message translates to:
  /// **'{first} and {second} are on the same day.'**
  String conflictSameDay(String first, String second);

  /// No description provided for @conflictInsideRecovery.
  ///
  /// In en, this message translates to:
  /// **'{second} comes while you are still recovering from {first}.'**
  String conflictInsideRecovery(String first, String second);

  /// No description provided for @conflictDuringIllness.
  ///
  /// In en, this message translates to:
  /// **'{first} falls in a period you logged as sick or injured.'**
  String conflictDuringIllness(String first);

  /// No description provided for @healthSickTitle.
  ///
  /// In en, this message translates to:
  /// **'You are logged as sick'**
  String get healthSickTitle;

  /// No description provided for @healthInjuredTitle.
  ///
  /// In en, this message translates to:
  /// **'You are logged as injured'**
  String get healthInjuredTitle;

  /// No description provided for @healthReturningTitle.
  ///
  /// In en, this message translates to:
  /// **'Easing back into training'**
  String get healthReturningTitle;

  /// No description provided for @healthSickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Day {days}. Rest is the plan — hard sessions come off the calendar.'**
  String healthSickSubtitle(int days);

  /// No description provided for @healthInjuredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Day {days}. Affected sessions become easy cross-training.'**
  String healthInjuredSubtitle(int days);

  /// No description provided for @healthReturnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load builds from 50 % back to normal until {date}.'**
  String healthReturnSubtitle(String date);

  /// No description provided for @healthNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned needs to change.'**
  String get healthNoChanges;

  /// No description provided for @healthChangeRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get healthChangeRest;

  /// No description provided for @healthChangeEasier.
  ///
  /// In en, this message translates to:
  /// **'Easy, {minutes} min (about {load} TSS)'**
  String healthChangeEasier(int minutes, int load);

  /// No description provided for @healthChangeCross.
  ///
  /// In en, this message translates to:
  /// **'Easy {sport}, {minutes} min instead'**
  String healthChangeCross(String sport, int minutes);

  /// No description provided for @healthReasonIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get healthReasonIllness;

  /// No description provided for @healthReasonInjury.
  ///
  /// In en, this message translates to:
  /// **'Injury'**
  String get healthReasonInjury;

  /// No description provided for @healthReasonReturn.
  ///
  /// In en, this message translates to:
  /// **'Return ramp'**
  String get healthReasonReturn;

  /// No description provided for @healthApply.
  ///
  /// In en, this message translates to:
  /// **'Apply {count} changes'**
  String healthApply(int count);

  /// No description provided for @healthApplyConfirm.
  ///
  /// In en, this message translates to:
  /// **'This changes your planned sessions on Intervals.icu and in TriIQ.'**
  String get healthApplyConfirm;

  /// No description provided for @healthApplyDone.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions updated.'**
  String healthApplyDone(int count);

  /// No description provided for @healthApplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Stopped after {done}: {error}'**
  String healthApplyFailed(int done, String error);

  /// No description provided for @healthLogHint.
  ///
  /// In en, this message translates to:
  /// **'Sick or injured? Log it as an event and TriIQ will reshape your plan.'**
  String get healthLogHint;

  /// No description provided for @healthLogButton.
  ///
  /// In en, this message translates to:
  /// **'Log illness or injury'**
  String get healthLogButton;

  /// No description provided for @racePredictorTitle.
  ///
  /// In en, this message translates to:
  /// **'Race predictor'**
  String get racePredictorTitle;

  /// No description provided for @racePredictorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish time, pacing and fuelling from your power and pace curves, your fitness and your race-day form.'**
  String get racePredictorSubtitle;

  /// No description provided for @raceChoose.
  ///
  /// In en, this message translates to:
  /// **'Race'**
  String get raceChoose;

  /// No description provided for @raceSpec5k.
  ///
  /// In en, this message translates to:
  /// **'5 km run'**
  String get raceSpec5k;

  /// No description provided for @raceSpec10k.
  ///
  /// In en, this message translates to:
  /// **'10 km run'**
  String get raceSpec10k;

  /// No description provided for @raceSpecHalf.
  ///
  /// In en, this message translates to:
  /// **'Half marathon'**
  String get raceSpecHalf;

  /// No description provided for @raceSpecMarathon.
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get raceSpecMarathon;

  /// No description provided for @raceSpecRide100.
  ///
  /// In en, this message translates to:
  /// **'100 km ride'**
  String get raceSpecRide100;

  /// No description provided for @raceSpecSprint.
  ///
  /// In en, this message translates to:
  /// **'Sprint triathlon'**
  String get raceSpecSprint;

  /// No description provided for @raceSpecOlympic.
  ///
  /// In en, this message translates to:
  /// **'Olympic triathlon'**
  String get raceSpecOlympic;

  /// No description provided for @raceSpec703.
  ///
  /// In en, this message translates to:
  /// **'Half-distance triathlon (70.3)'**
  String get raceSpec703;

  /// No description provided for @raceSpec1406.
  ///
  /// In en, this message translates to:
  /// **'Full-distance triathlon (140.6)'**
  String get raceSpec1406;

  /// No description provided for @raceDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Race day'**
  String get raceDayLabel;

  /// No description provided for @raceDayAuto.
  ///
  /// In en, this message translates to:
  /// **'From my races'**
  String get raceDayAuto;

  /// No description provided for @raceDayNone.
  ///
  /// In en, this message translates to:
  /// **'No date (ignore form)'**
  String get raceDayNone;

  /// No description provided for @raceHot.
  ///
  /// In en, this message translates to:
  /// **'Hot conditions'**
  String get raceHot;

  /// No description provided for @raceTotal.
  ///
  /// In en, this message translates to:
  /// **'Predicted finish'**
  String get raceTotal;

  /// No description provided for @raceTransitions.
  ///
  /// In en, this message translates to:
  /// **'Transitions: T1 {t1}, T2 {t2}'**
  String raceTransitions(String t1, String t2);

  /// No description provided for @raceLegSwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get raceLegSwim;

  /// No description provided for @raceLegRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get raceLegRide;

  /// No description provided for @raceLegRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get raceLegRun;

  /// No description provided for @raceMissing.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for: {legs}. Some hard efforts in training, then sync, will fix this.'**
  String raceMissing(String legs);

  /// No description provided for @raceSlowdown.
  ///
  /// In en, this message translates to:
  /// **'Includes a {pct} % allowance for fitness (CTL) and race-day form.'**
  String raceSlowdown(String pct);

  /// No description provided for @raceWatts.
  ///
  /// In en, this message translates to:
  /// **'{watts} W ({pct} % FTP)'**
  String raceWatts(int watts, String pct);

  /// No description provided for @raceWattsOnly.
  ///
  /// In en, this message translates to:
  /// **'{watts} W'**
  String raceWattsOnly(int watts);

  /// No description provided for @racePacingTitle.
  ///
  /// In en, this message translates to:
  /// **'Pacing plan'**
  String get racePacingTitle;

  /// No description provided for @pacingStartControlled.
  ///
  /// In en, this message translates to:
  /// **'Start controlled'**
  String get pacingStartControlled;

  /// No description provided for @pacingHoldSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold steady'**
  String get pacingHoldSteady;

  /// No description provided for @pacingFinishStrong.
  ///
  /// In en, this message translates to:
  /// **'Finish strong'**
  String get pacingFinishStrong;

  /// No description provided for @pacingNegativeSplit.
  ///
  /// In en, this message translates to:
  /// **'Settle in, build gently'**
  String get pacingNegativeSplit;

  /// No description provided for @pacingRange.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end} km'**
  String pacingRange(String start, String end);

  /// No description provided for @fuelingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fuelling plan'**
  String get fuelingTitle;

  /// No description provided for @fuelNone.
  ///
  /// In en, this message translates to:
  /// **'Under about 45 minutes water is enough.'**
  String get fuelNone;

  /// No description provided for @fuelCarbsPerHour.
  ///
  /// In en, this message translates to:
  /// **'{g} g carbohydrate per hour'**
  String fuelCarbsPerHour(int g);

  /// No description provided for @fuelFluidPerHour.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml fluid per hour'**
  String fuelFluidPerHour(int ml);

  /// No description provided for @fuelSodiumPerHour.
  ///
  /// In en, this message translates to:
  /// **'{mg} mg sodium per hour'**
  String fuelSodiumPerHour(int mg);

  /// No description provided for @fuelTotals.
  ///
  /// In en, this message translates to:
  /// **'Race total: {carbs} g carbohydrate, {fluid} ml fluid'**
  String fuelTotals(int carbs, int fluid);

  /// No description provided for @fuelDayBefore.
  ///
  /// In en, this message translates to:
  /// **'Day before: about {g} g carbohydrate'**
  String fuelDayBefore(int g);

  /// No description provided for @fuelPreRace.
  ///
  /// In en, this message translates to:
  /// **'1–4 h before the start: about {g} g carbohydrate'**
  String fuelPreRace(int g);

  /// No description provided for @fuelStep.
  ///
  /// In en, this message translates to:
  /// **'{minute} min · {sport}: {carbs} g carbs, {fluid} ml'**
  String fuelStep(int minute, String sport, int carbs, int fluid);

  /// No description provided for @raceDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A model estimate from your best efforts, not a promise. Course, weather and pacing decide the day.'**
  String get raceDisclaimer;

  /// No description provided for @raceAskTrainer.
  ///
  /// In en, this message translates to:
  /// **'Ask the trainer'**
  String get raceAskTrainer;

  /// No description provided for @raceChatDraft.
  ///
  /// In en, this message translates to:
  /// **'My race predictor says {time} for the {race}. Is that realistic, and what should I work on before race day?'**
  String raceChatDraft(String time, String race);

  /// No description provided for @brickTitleBikeRun.
  ///
  /// In en, this message translates to:
  /// **'Brick: bike → run'**
  String get brickTitleBikeRun;

  /// No description provided for @brickTitleSwimBike.
  ///
  /// In en, this message translates to:
  /// **'Brick: swim → bike'**
  String get brickTitleSwimBike;

  /// No description provided for @brickTransition.
  ///
  /// In en, this message translates to:
  /// **'Transition: {time}'**
  String brickTransition(String time);

  /// No description provided for @brickSettle.
  ///
  /// In en, this message translates to:
  /// **'Legs settled after {time}'**
  String brickSettle(String time);

  /// No description provided for @brickEarly.
  ///
  /// In en, this message translates to:
  /// **'First 10 min at {pct} % of your later speed'**
  String brickEarly(String pct);

  /// No description provided for @brickVerdictGood.
  ///
  /// In en, this message translates to:
  /// **'Strong brick'**
  String get brickVerdictGood;

  /// No description provided for @brickVerdictOk.
  ///
  /// In en, this message translates to:
  /// **'Decent brick'**
  String get brickVerdictOk;

  /// No description provided for @brickVerdictRough.
  ///
  /// In en, this message translates to:
  /// **'Rough start off the bike'**
  String get brickVerdictRough;

  /// No description provided for @brickVerdictUnknown.
  ///
  /// In en, this message translates to:
  /// **'Transition only'**
  String get brickVerdictUnknown;

  /// No description provided for @brickNoteSettledFast.
  ///
  /// In en, this message translates to:
  /// **'Legs came round quickly.'**
  String get brickNoteSettledFast;

  /// No description provided for @brickNoteSettledSlow.
  ///
  /// In en, this message translates to:
  /// **'It took a long time to find your rhythm.'**
  String get brickNoteSettledSlow;

  /// No description provided for @brickNoteSlowStart.
  ///
  /// In en, this message translates to:
  /// **'The opening minutes were much slower than the rest.'**
  String get brickNoteSlowStart;

  /// No description provided for @brickNoteHighEarlyCost.
  ///
  /// In en, this message translates to:
  /// **'Heart rate was high for the speed early on — pace the first 10 minutes by effort, not speed.'**
  String get brickNoteHighEarlyCost;

  /// No description provided for @brickNoteHardFirstLeg.
  ///
  /// In en, this message translates to:
  /// **'The first leg was hard (intensity 85 % or more), which usually costs the next one.'**
  String get brickNoteHardFirstLeg;

  /// No description provided for @brickNoteQuickTransition.
  ///
  /// In en, this message translates to:
  /// **'Quick transition.'**
  String get brickNoteQuickTransition;

  /// No description provided for @brickNoteLongTransition.
  ///
  /// In en, this message translates to:
  /// **'Long transition — fine in training, but practise it before a race.'**
  String get brickNoteLongTransition;

  /// No description provided for @brickNoteNoStream.
  ///
  /// In en, this message translates to:
  /// **'No data stream for the second leg, so only the transition is judged.'**
  String get brickNoteNoStream;

  /// No description provided for @brickSessions.
  ///
  /// In en, this message translates to:
  /// **'{first} + {second}'**
  String brickSessions(String first, String second);

  /// No description provided for @memoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainer memory'**
  String get memoryTitle;

  /// No description provided for @moreMemorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'What the trainer remembers about you'**
  String get moreMemorySubtitle;

  /// No description provided for @memoryIntro.
  ///
  /// In en, this message translates to:
  /// **'Standing preferences the trainer follows in every chat, e.g. \"No hard sessions on Fridays\" or \"Swim only in the mornings\". You can add, edit by deleting and re-adding, or remove them here. The trainer only saves one when you ask it to.'**
  String get memoryIntro;

  /// No description provided for @memoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing remembered yet.'**
  String get memoryEmpty;

  /// No description provided for @memoryAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a preference…'**
  String get memoryAddHint;

  /// No description provided for @memoryAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get memoryAddButton;

  /// No description provided for @memoryFromTrainer.
  ///
  /// In en, this message translates to:
  /// **'saved by the trainer'**
  String get memoryFromTrainer;

  /// No description provided for @memoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get memoryDelete;

  /// No description provided for @memoryClear.
  ///
  /// In en, this message translates to:
  /// **'Remove all'**
  String get memoryClear;

  /// No description provided for @memoryClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove everything the trainer remembers?'**
  String get memoryClearConfirm;

  /// No description provided for @memoryFull.
  ///
  /// In en, this message translates to:
  /// **'The memory is full ({max} items). Remove one first.'**
  String memoryFull(int max);

  /// No description provided for @memoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max}'**
  String memoryCount(int count, int max);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'Export your synced data, plans, knowledge library and settings as one JSON file, and restore it on another device. Your Intervals.icu and AI keys are not included — reconnect after restoring.'**
  String get backupIntro;

  /// No description provided for @backupIncludeCaches.
  ///
  /// In en, this message translates to:
  /// **'Include chart caches'**
  String get backupIncludeCaches;

  /// No description provided for @backupIncludeCachesHelp.
  ///
  /// In en, this message translates to:
  /// **'Session streams and performance curves. Larger file; they can be fetched again.'**
  String get backupIncludeCachesHelp;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get backupExport;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup…'**
  String get backupRestore;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to {path}'**
  String backupExported(String path);

  /// No description provided for @backupShared.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to share.'**
  String get backupShared;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'From {date}: {activities} activities, {plans} plans, {total} rows in all, {settings} settings. This replaces the synced data, plans and knowledge library on this device.'**
  String backupRestoreBody(
    String date,
    int activities,
    int plans,
    int total,
    int settings,
  );

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored. Restart TriIQ to apply the settings, and reconnect Intervals.icu if needed.'**
  String get backupRestored;

  /// No description provided for @backupUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'an unknown date'**
  String get backupUnknownDate;

  /// No description provided for @forecastAssumed.
  ///
  /// In en, this message translates to:
  /// **'Nothing is planned after {date}, so from then on the forecast assumes you keep training at your current fitness level.'**
  String forecastAssumed(String date);

  /// No description provided for @pendingTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String pendingTitle(int count);

  /// No description provided for @pendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Made while Intervals.icu was out of reach. They are sent automatically when you are back online.'**
  String get pendingSubtitle;

  /// No description provided for @pendingSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get pendingSyncNow;

  /// No description provided for @pendingFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change could not be sent} other{{count} changes could not be sent}}'**
  String pendingFailedTitle(int count);

  /// No description provided for @pendingRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pendingRetry;

  /// No description provided for @pendingDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get pendingDiscard;

  /// No description provided for @planQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions will be sent to Intervals.icu when you are back online.'**
  String planQueuedOffline(int count);

  /// No description provided for @replaceQueuedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved here. Intervals.icu can\'t be reached, so the swap will be sent when you are back online.'**
  String get replaceQueuedOffline;

  /// No description provided for @fatigueWatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue is building'**
  String get fatigueWatchTitle;

  /// No description provided for @fatigueWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Fatigue warning'**
  String get fatigueWarningTitle;

  /// No description provided for @fatigueAdviceWatch.
  ///
  /// In en, this message translates to:
  /// **'Keep the next hard session honest — if it feels bad, cut it short or swap it for an easy one.'**
  String get fatigueAdviceWatch;

  /// No description provided for @fatigueAdviceWarning.
  ///
  /// In en, this message translates to:
  /// **'Several signals have been off for days. Take an easy or rest day and ask the trainer to ease this week.'**
  String get fatigueAdviceWarning;

  /// No description provided for @fatigueSignalHrv.
  ///
  /// In en, this message translates to:
  /// **'HRV below your normal on {bad} of the last {of} days'**
  String fatigueSignalHrv(int bad, int of);

  /// No description provided for @fatigueSignalRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate raised on {bad} of the last {of} days'**
  String fatigueSignalRestingHr(int bad, int of);

  /// No description provided for @fatigueSignalSleep.
  ///
  /// In en, this message translates to:
  /// **'Under 6.5 hours of sleep on {bad} of the last {of} nights'**
  String fatigueSignalSleep(int bad, int of);

  /// No description provided for @fatigueSignalForm.
  ///
  /// In en, this message translates to:
  /// **'Form deeply negative on {bad} of the last {of} days'**
  String fatigueSignalForm(int bad, int of);

  /// No description provided for @fatigueSignalRamp.
  ///
  /// In en, this message translates to:
  /// **'Fitness ramping up fast on {bad} of the last {of} days'**
  String fatigueSignalRamp(int bad, int of);

  /// No description provided for @fatigueSignalSubjective.
  ///
  /// In en, this message translates to:
  /// **'You rated fatigue or soreness high on {bad} of the last {of} days'**
  String fatigueSignalSubjective(int bad, int of);

  /// No description provided for @fatigueAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask the trainer'**
  String get fatigueAsk;

  /// No description provided for @fatigueDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get fatigueDismiss;

  /// No description provided for @fatigueChatDraft.
  ///
  /// In en, this message translates to:
  /// **'My fatigue check says: {reasons}. Should I change anything this week?'**
  String fatigueChatDraft(String reasons);

  /// No description provided for @briefingTitle.
  ///
  /// In en, this message translates to:
  /// **'Today · {date}'**
  String briefingTitle(String date);

  /// No description provided for @briefingNoSession.
  ///
  /// In en, this message translates to:
  /// **'No session planned today.'**
  String get briefingNoSession;

  /// No description provided for @briefingSessions.
  ///
  /// In en, this message translates to:
  /// **'Planned: {sessions}'**
  String briefingSessions(String sessions);

  /// No description provided for @briefingMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String briefingMore(int count);

  /// No description provided for @briefingReadiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness: {level}'**
  String briefingReadiness(String level);

  /// No description provided for @briefingFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue: {level}'**
  String briefingFatigue(String level);

  /// No description provided for @briefingForm.
  ///
  /// In en, this message translates to:
  /// **'Form {form} · CTL {ctl}'**
  String briefingForm(String form, String ctl);

  /// No description provided for @briefingRace.
  ///
  /// In en, this message translates to:
  /// **'{race}'**
  String briefingRace(String race);

  /// No description provided for @briefingHealth.
  ///
  /// In en, this message translates to:
  /// **'You are logged as {kind} — check the Season screen.'**
  String briefingHealth(String kind);

  /// No description provided for @briefingSick.
  ///
  /// In en, this message translates to:
  /// **'sick'**
  String get briefingSick;

  /// No description provided for @briefingInjured.
  ///
  /// In en, this message translates to:
  /// **'injured'**
  String get briefingInjured;

  /// No description provided for @briefingLevelReady.
  ///
  /// In en, this message translates to:
  /// **'ready'**
  String get briefingLevelReady;

  /// No description provided for @briefingLevelCaution.
  ///
  /// In en, this message translates to:
  /// **'caution'**
  String get briefingLevelCaution;

  /// No description provided for @briefingLevelBackOff.
  ///
  /// In en, this message translates to:
  /// **'back off'**
  String get briefingLevelBackOff;

  /// No description provided for @briefingLevelWatch.
  ///
  /// In en, this message translates to:
  /// **'building'**
  String get briefingLevelWatch;

  /// No description provided for @briefingLevelWarning.
  ///
  /// In en, this message translates to:
  /// **'warning'**
  String get briefingLevelWarning;

  /// No description provided for @morningBriefing.
  ///
  /// In en, this message translates to:
  /// **'Morning briefing'**
  String get morningBriefing;

  /// No description provided for @morningBriefingHelp.
  ///
  /// In en, this message translates to:
  /// **'A notification with today\'s session, readiness and form. It is prepared from your last sync, so readiness appears when your watch data is already in.'**
  String get morningBriefingHelp;

  /// No description provided for @weeklyHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'All sports'**
  String get weeklyHoursLabel;

  /// No description provided for @weeklyHoursTotal.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String weeklyHoursTotal(String hours);

  /// No description provided for @weeklyHoursOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{hours} / {target} h'**
  String weeklyHoursOfTarget(String hours, String target);

  /// No description provided for @dayProposeTraining.
  ///
  /// In en, this message translates to:
  /// **'Propose training'**
  String get dayProposeTraining;

  /// No description provided for @dayProposeTrainingHelp.
  ///
  /// In en, this message translates to:
  /// **'Like Train now, but the session is placed on this day.'**
  String get dayProposeTrainingHelp;

  /// No description provided for @readinessFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get readinessFitness;

  /// No description provided for @dayCardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayCardToday;

  /// No description provided for @dayCardLoadOfPlanned.
  ///
  /// In en, this message translates to:
  /// **'{done} / {planned} TSS'**
  String dayCardLoadOfPlanned(int done, int planned);

  /// No description provided for @dayCardLoadDone.
  ///
  /// In en, this message translates to:
  /// **'{done} TSS'**
  String dayCardLoadDone(int done);

  /// No description provided for @routeTitle.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeTitle;

  /// No description provided for @heroSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get heroSyncNow;

  /// No description provided for @heroMoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get heroMoreTooltip;

  /// No description provided for @heroSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String heroSessions(int count);

  /// No description provided for @ollamaKeyCloudOnly.
  ///
  /// In en, this message translates to:
  /// **'An Ollama API key is only used with Ollama Cloud (https://ollama.com). A self-hosted server needs no key here.'**
  String get ollamaKeyCloudOnly;

  /// No description provided for @ollamaHttpWarning.
  ///
  /// In en, this message translates to:
  /// **'Unencrypted (http): prompts and training data are sent in plain text. Use it only for a server on your own network.'**
  String get ollamaHttpWarning;

  /// No description provided for @dayAddEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get dayAddEvent;

  /// No description provided for @dayAddEventHelp.
  ///
  /// In en, this message translates to:
  /// **'Sick day, injury, holiday, note, race …'**
  String get dayAddEventHelp;

  /// No description provided for @anTitle.
  ///
  /// In en, this message translates to:
  /// **'Training analytics'**
  String get anTitle;

  /// No description provided for @anSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness by sport, intensity split, load safety, aerobic base'**
  String get anSubtitle;

  /// No description provided for @anSportSwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get anSportSwim;

  /// No description provided for @anSportRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get anSportRide;

  /// No description provided for @anSportRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get anSportRun;

  /// No description provided for @anSportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get anSportOther;

  /// No description provided for @anSportFitnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitness by sport'**
  String get anSportFitnessTitle;

  /// No description provided for @anSportFitnessHint.
  ///
  /// In en, this message translates to:
  /// **'Each line is that sport\'s own CTL or ATL, computed from its training load with the same 42/7-day model; together they add up to your total.'**
  String get anSportFitnessHint;

  /// No description provided for @anTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get anTotalLabel;

  /// No description provided for @anLoadSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your load comes from'**
  String get anLoadSourceTitle;

  /// No description provided for @anLoadSourceTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a week to see its split.'**
  String get anLoadSourceTap;

  /// No description provided for @anLoadWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {week}: {total} TSS'**
  String anLoadWeekOf(String week, int total);

  /// No description provided for @anShareEntry.
  ///
  /// In en, this message translates to:
  /// **'{sport} {percent}%'**
  String anShareEntry(String sport, int percent);

  /// No description provided for @anIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Intensity distribution'**
  String get anIntensityTitle;

  /// No description provided for @anWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get anWeekly;

  /// No description provided for @anMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get anMonthly;

  /// No description provided for @anZoneEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get anZoneEasy;

  /// No description provided for @anZoneThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold'**
  String get anZoneThreshold;

  /// No description provided for @anZoneHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get anZoneHard;

  /// No description provided for @anIntensityHint.
  ///
  /// In en, this message translates to:
  /// **'Share of zone time. Easy is below the first threshold, threshold is the zones around it, hard is above. Power zones first, then heart rate, then pace.'**
  String get anIntensityHint;

  /// No description provided for @anModelPolarized.
  ///
  /// In en, this message translates to:
  /// **'Polarized'**
  String get anModelPolarized;

  /// No description provided for @anModelPyramidal.
  ///
  /// In en, this message translates to:
  /// **'Pyramidal'**
  String get anModelPyramidal;

  /// No description provided for @anModelThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold-heavy'**
  String get anModelThreshold;

  /// No description provided for @anModelHigh.
  ///
  /// In en, this message translates to:
  /// **'High-intensity'**
  String get anModelHigh;

  /// No description provided for @anModelUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not enough zone time'**
  String get anModelUnknown;

  /// No description provided for @anPolarizationIndex.
  ///
  /// In en, this message translates to:
  /// **'Polarization index {value}'**
  String anPolarizationIndex(String value);

  /// No description provided for @anIntensityPeriod.
  ///
  /// In en, this message translates to:
  /// **'{period}: {model}'**
  String anIntensityPeriod(String period, String model);

  /// No description provided for @anIntensitySplit.
  ///
  /// In en, this message translates to:
  /// **'{easy}% easy · {threshold}% threshold · {hard}% hard'**
  String anIntensitySplit(int easy, int threshold, int hard);

  /// No description provided for @anRangeOverall.
  ///
  /// In en, this message translates to:
  /// **'Whole range'**
  String get anRangeOverall;

  /// No description provided for @anSessionsNoZones.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions without zone data are not counted.'**
  String anSessionsNoZones(int count);

  /// No description provided for @anSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Load safety'**
  String get anSafetyTitle;

  /// No description provided for @anAcwr.
  ///
  /// In en, this message translates to:
  /// **'Acute:chronic'**
  String get anAcwr;

  /// No description provided for @anRamp.
  ///
  /// In en, this message translates to:
  /// **'Ramp rate'**
  String get anRamp;

  /// No description provided for @anMonotony.
  ///
  /// In en, this message translates to:
  /// **'Monotony'**
  String get anMonotony;

  /// No description provided for @anStrain.
  ///
  /// In en, this message translates to:
  /// **'Strain'**
  String get anStrain;

  /// No description provided for @anRiskSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get anRiskSafe;

  /// No description provided for @anRiskRisky.
  ///
  /// In en, this message translates to:
  /// **'Risky'**
  String get anRiskRisky;

  /// No description provided for @anRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'Too fast'**
  String get anRiskHigh;

  /// No description provided for @anRiskHighMonotony.
  ///
  /// In en, this message translates to:
  /// **'Too uniform'**
  String get anRiskHighMonotony;

  /// No description provided for @anAcwrBands.
  ///
  /// In en, this message translates to:
  /// **'7-day load over 28-day load. Safe 0.8–1.3, risky up to 1.5, too fast above. The shaded band is the safe range.'**
  String get anAcwrBands;

  /// No description provided for @anRampBands.
  ///
  /// In en, this message translates to:
  /// **'CTL change over 7 days. Safe up to 5 a week, risky up to 8, too fast above.'**
  String get anRampBands;

  /// No description provided for @anMonotonyBands.
  ///
  /// In en, this message translates to:
  /// **'Mean daily load over its spread across 7 days. Safe up to 1.5, risky up to 2, above that the week is too uniform. Strain is the week\'s load times monotony.'**
  String get anMonotonyBands;

  /// No description provided for @anSafetyNeedHistory.
  ///
  /// In en, this message translates to:
  /// **'The ratio needs 28 days of cached activities.'**
  String get anSafetyNeedHistory;

  /// No description provided for @anAerobicTitle.
  ///
  /// In en, this message translates to:
  /// **'Aerobic base'**
  String get anAerobicTitle;

  /// No description provided for @anAerobicHint.
  ///
  /// In en, this message translates to:
  /// **'Long steady sessions: at least 60 minutes, mostly below the first threshold. Higher efficiency factor and lower decoupling mean a stronger base.'**
  String get anAerobicHint;

  /// No description provided for @anEfTitle.
  ///
  /// In en, this message translates to:
  /// **'Efficiency factor'**
  String get anEfTitle;

  /// No description provided for @anDecouplingTitle.
  ///
  /// In en, this message translates to:
  /// **'Decoupling (Pa:HR)'**
  String get anDecouplingTitle;

  /// No description provided for @anEfTrend.
  ///
  /// In en, this message translates to:
  /// **'EF trend {percent}% per month'**
  String anEfTrend(String percent);

  /// No description provided for @anEfTrendFlat.
  ///
  /// In en, this message translates to:
  /// **'EF trend: flat'**
  String get anEfTrendFlat;

  /// No description provided for @anDecouplingBands.
  ///
  /// In en, this message translates to:
  /// **'Under 5% is solid, 5–10% developing, above 10% the heart rate drifted too far. The shaded band is the solid range.'**
  String get anDecouplingBands;

  /// No description provided for @anAerobicEmpty.
  ///
  /// In en, this message translates to:
  /// **'No long steady sessions with an efficiency factor or decoupling in this range.'**
  String get anAerobicEmpty;

  /// No description provided for @anAerobicSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String anAerobicSessions(int count);

  /// No description provided for @anLatestDecoupling.
  ///
  /// In en, this message translates to:
  /// **'Latest decoupling {value}%'**
  String anLatestDecoupling(String value);

  /// No description provided for @cmpTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get cmpTitle;

  /// No description provided for @cmpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Two runs or rides overlaid on their streams and course, or two blocks of training'**
  String get cmpSubtitle;

  /// No description provided for @cmpCompareWith.
  ///
  /// In en, this message translates to:
  /// **'Compare with…'**
  String get cmpCompareWith;

  /// No description provided for @cmpTabActivities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get cmpTabActivities;

  /// No description provided for @cmpTabPeriods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get cmpTabPeriods;

  /// No description provided for @cmpPickFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick the first activity'**
  String get cmpPickFirst;

  /// No description provided for @cmpPickSecond.
  ///
  /// In en, this message translates to:
  /// **'Pick the second activity'**
  String get cmpPickSecond;

  /// No description provided for @cmpPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an activity'**
  String get cmpPickTitle;

  /// No description provided for @cmpPickEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cached runs or rides to compare yet.'**
  String get cmpPickEmpty;

  /// No description provided for @cmpChooseTwo.
  ///
  /// In en, this message translates to:
  /// **'Pick two activities of the same sport to overlay them.'**
  String get cmpChooseTwo;

  /// No description provided for @cmpAxisDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cmpAxisDistance;

  /// No description provided for @cmpAxisTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get cmpAxisTime;

  /// No description provided for @cmpNoDistance.
  ///
  /// In en, this message translates to:
  /// **'One of these has no distance stream, so only the time axis is available.'**
  String get cmpNoDistance;

  /// No description provided for @cmpNoStreams.
  ///
  /// In en, this message translates to:
  /// **'No stream data for these activities. Connect to Intervals.icu and try again.'**
  String get cmpNoStreams;

  /// No description provided for @cmpNoMetric.
  ///
  /// In en, this message translates to:
  /// **'Neither activity recorded this stream.'**
  String get cmpNoMetric;

  /// No description provided for @cmpTrackerHint.
  ///
  /// In en, this message translates to:
  /// **'Touch the chart or tap the map to move the tracker.'**
  String get cmpTrackerHint;

  /// No description provided for @cmpCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get cmpCourseTitle;

  /// No description provided for @cmpCourseOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the map full screen'**
  String get cmpCourseOpen;

  /// No description provided for @cmpStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get cmpStatsTitle;

  /// No description provided for @cmpDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cmpDistance;

  /// No description provided for @cmpTime.
  ///
  /// In en, this message translates to:
  /// **'Moving time'**
  String get cmpTime;

  /// No description provided for @cmpElevation.
  ///
  /// In en, this message translates to:
  /// **'Elevation'**
  String get cmpElevation;

  /// No description provided for @cmpLoad.
  ///
  /// In en, this message translates to:
  /// **'Load (TSS)'**
  String get cmpLoad;

  /// No description provided for @cmpAvgHr.
  ///
  /// In en, this message translates to:
  /// **'Avg heart rate'**
  String get cmpAvgHr;

  /// No description provided for @cmpAvgPower.
  ///
  /// In en, this message translates to:
  /// **'Avg power'**
  String get cmpAvgPower;

  /// No description provided for @cmpAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg pace / speed'**
  String get cmpAvgSpeed;

  /// No description provided for @cmpEf.
  ///
  /// In en, this message translates to:
  /// **'Efficiency factor'**
  String get cmpEf;

  /// No description provided for @cmpDecoupling.
  ///
  /// In en, this message translates to:
  /// **'Decoupling'**
  String get cmpDecoupling;

  /// No description provided for @cmpEasyShare.
  ///
  /// In en, this message translates to:
  /// **'Easy share'**
  String get cmpEasyShare;

  /// No description provided for @cmpSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get cmpSessions;

  /// No description provided for @cmpBlockDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String cmpBlockDays(int days);

  /// No description provided for @cmpThisBlock.
  ///
  /// In en, this message translates to:
  /// **'This block'**
  String get cmpThisBlock;

  /// No description provided for @cmpPreviousBlock.
  ///
  /// In en, this message translates to:
  /// **'Previous block'**
  String get cmpPreviousBlock;

  /// No description provided for @cmpBlockLength.
  ///
  /// In en, this message translates to:
  /// **'Block length'**
  String get cmpBlockLength;

  /// No description provided for @cmpBlockRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String cmpBlockRange(String start, String end);

  /// No description provided for @cmpCumulative.
  ///
  /// In en, this message translates to:
  /// **'Cumulative by day'**
  String get cmpCumulative;

  /// No description provided for @cmpDayOfBlock.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String cmpDayOfBlock(int day);

  /// No description provided for @cmpNoBlockActivities.
  ///
  /// In en, this message translates to:
  /// **'No runs or rides in these two blocks.'**
  String get cmpNoBlockActivities;

  /// No description provided for @cmpFirst.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get cmpFirst;

  /// No description provided for @cmpSecond.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get cmpSecond;

  /// No description provided for @chartOptions.
  ///
  /// In en, this message translates to:
  /// **'Chart options'**
  String get chartOptions;

  /// No description provided for @chartOptionsStreams.
  ///
  /// In en, this message translates to:
  /// **'Streams'**
  String get chartOptionsStreams;

  /// No description provided for @chartOptionsAxis.
  ///
  /// In en, this message translates to:
  /// **'X axis'**
  String get chartOptionsAxis;

  /// No description provided for @chartOptionsRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get chartOptionsRange;

  /// No description provided for @chartOptionsView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get chartOptionsView;

  /// No description provided for @chartOptionsSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get chartOptionsSport;

  /// No description provided for @chartOptionsBlock.
  ///
  /// In en, this message translates to:
  /// **'Block length'**
  String get chartOptionsBlock;

  /// No description provided for @readinessOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Readiness signals'**
  String get readinessOptionsTitle;

  /// No description provided for @readinessOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which values count toward the score, the status and the trainer\'s advice. Switched-off values are ignored everywhere. At least one must stay on.'**
  String get readinessOptionsHint;

  /// No description provided for @readinessOptionHrv.
  ///
  /// In en, this message translates to:
  /// **'Heart-rate variability against your own 60-day baseline'**
  String get readinessOptionHrv;

  /// No description provided for @readinessOptionRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Resting heart rate against your own baseline'**
  String get readinessOptionRestingHr;

  /// No description provided for @readinessOptionSleep.
  ///
  /// In en, this message translates to:
  /// **'Hours slept last night'**
  String get readinessOptionSleep;

  /// No description provided for @readinessOptionForm.
  ///
  /// In en, this message translates to:
  /// **'Form: fitness minus fatigue (CTL − ATL)'**
  String get readinessOptionForm;

  /// No description provided for @readinessOptionSubjective.
  ///
  /// In en, this message translates to:
  /// **'Fatigue and soreness you logged today'**
  String get readinessOptionSubjective;

  /// No description provided for @readinessRatingExcluded.
  ///
  /// In en, this message translates to:
  /// **'Not used'**
  String get readinessRatingExcluded;

  /// No description provided for @readinessOptionsReset.
  ///
  /// In en, this message translates to:
  /// **'Use all signals'**
  String get readinessOptionsReset;

  /// No description provided for @durTitle.
  ///
  /// In en, this message translates to:
  /// **'Durability'**
  String get durTitle;

  /// No description provided for @durSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Power or pace after hours of work, against your fresh best'**
  String get durSubtitle;

  /// No description provided for @durFresh.
  ///
  /// In en, this message translates to:
  /// **'Season best'**
  String get durFresh;

  /// No description provided for @durAfterKj.
  ///
  /// In en, this message translates to:
  /// **'After {kj} kJ'**
  String durAfterKj(int kj);

  /// No description provided for @durAfterKm.
  ///
  /// In en, this message translates to:
  /// **'After {km} km'**
  String durAfterKm(int km);

  /// No description provided for @durRetained.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get durRetained;

  /// No description provided for @durHintRide.
  ///
  /// In en, this message translates to:
  /// **'How much of your fresh power is left once you have already done the work shown. An effort only counts when it starts after that much work, taken from your recent long rides.'**
  String get durHintRide;

  /// No description provided for @durHintRun.
  ///
  /// In en, this message translates to:
  /// **'How fast you can still run once you have already covered the distance shown. An effort only counts when it starts after that distance, taken from your recent long runs.'**
  String get durHintRun;

  /// No description provided for @durBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on {analysed} of {candidates} long sessions in the last {days} days.'**
  String durBasedOn(int analysed, int candidates, int days);

  /// No description provided for @durFailed.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions had no usable stream.'**
  String durFailed(int count);

  /// No description provided for @durReading.
  ///
  /// In en, this message translates to:
  /// **'Reading sessions {done}/{total}…'**
  String durReading(int done, int total);

  /// No description provided for @durNoneRide.
  ///
  /// In en, this message translates to:
  /// **'No rides with at least 1,000 kJ of work in this range.'**
  String get durNoneRide;

  /// No description provided for @durNoneRun.
  ///
  /// In en, this message translates to:
  /// **'No runs of at least 10 km in this range.'**
  String get durNoneRun;

  /// No description provided for @durNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough work in the sessions found to reach these levels.'**
  String get durNoData;

  /// No description provided for @wtTitle.
  ///
  /// In en, this message translates to:
  /// **'Wellness trends'**
  String get wtTitle;

  /// No description provided for @wtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'HRV, resting HR, sleep and weight over time, with a 7-day average and your usual range'**
  String get wtSubtitle;

  /// No description provided for @wtMetricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get wtMetricWeight;

  /// No description provided for @wtLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get wtLatest;

  /// No description provided for @wtAverage.
  ///
  /// In en, this message translates to:
  /// **'7-day avg'**
  String get wtAverage;

  /// No description provided for @wtWeek.
  ///
  /// In en, this message translates to:
  /// **'vs a week ago'**
  String get wtWeek;

  /// No description provided for @wtBelow.
  ///
  /// In en, this message translates to:
  /// **'Below your usual range'**
  String get wtBelow;

  /// No description provided for @wtWithin.
  ///
  /// In en, this message translates to:
  /// **'In your usual range'**
  String get wtWithin;

  /// No description provided for @wtAbove.
  ///
  /// In en, this message translates to:
  /// **'Above your usual range'**
  String get wtAbove;

  /// No description provided for @wtBandNote.
  ///
  /// In en, this message translates to:
  /// **'Shaded band: your usual range, the mean ± 1 SD over this period.'**
  String get wtBandNote;

  /// No description provided for @wtNoData.
  ///
  /// In en, this message translates to:
  /// **'No data in this range.'**
  String get wtNoData;

  /// No description provided for @wtLongerTrends.
  ///
  /// In en, this message translates to:
  /// **'Longer trends'**
  String get wtLongerTrends;

  /// No description provided for @wtShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get wtShow;

  /// No description provided for @exTitle.
  ///
  /// In en, this message translates to:
  /// **'Effort profile'**
  String get exTitle;

  /// No description provided for @exVi.
  ///
  /// In en, this message translates to:
  /// **'Variability index'**
  String get exVi;

  /// No description provided for @exViSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get exViSteady;

  /// No description provided for @exViModerate.
  ///
  /// In en, this message translates to:
  /// **'Some surges'**
  String get exViModerate;

  /// No description provided for @exViVariable.
  ///
  /// In en, this message translates to:
  /// **'Very variable'**
  String get exViVariable;

  /// No description provided for @exViHint.
  ///
  /// In en, this message translates to:
  /// **'Normalized over average: 1.00 is perfectly even, above about 1.05 the effort surged or stopped and started.'**
  String get exViHint;

  /// No description provided for @exHistPower.
  ///
  /// In en, this message translates to:
  /// **'Time at power'**
  String get exHistPower;

  /// No description provided for @exHistPace.
  ///
  /// In en, this message translates to:
  /// **'Time at pace'**
  String get exHistPace;

  /// No description provided for @exHistTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar for the details.'**
  String get exHistTap;

  /// No description provided for @exHistBand.
  ///
  /// In en, this message translates to:
  /// **'{band}: {minutes} min ({percent}%)'**
  String exHistBand(String band, String minutes, int percent);

  /// No description provided for @exHistZero.
  ///
  /// In en, this message translates to:
  /// **'Not pedalling or stopped: {minutes} min'**
  String exHistZero(String minutes);

  /// No description provided for @exIntervalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get exIntervalsTitle;

  /// No description provided for @exColInterval.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get exColInterval;

  /// No description provided for @exColTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get exColTime;

  /// No description provided for @exColOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get exColOutput;

  /// No description provided for @exColHr.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get exColHr;

  /// No description provided for @exColDrift.
  ///
  /// In en, this message translates to:
  /// **'Drift'**
  String get exColDrift;

  /// No description provided for @exColFade.
  ///
  /// In en, this message translates to:
  /// **'vs 1st'**
  String get exColFade;

  /// No description provided for @exRecovery.
  ///
  /// In en, this message translates to:
  /// **'rec'**
  String get exRecovery;

  /// No description provided for @exIntervalsHint.
  ///
  /// In en, this message translates to:
  /// **'Drift: how much less output per heartbeat the second half of the interval gave than the first (heart-rate decoupling). vs 1st: output against the first work interval. Intervals under 2 minutes show no drift.'**
  String get exIntervalsHint;

  /// No description provided for @hmTitle.
  ///
  /// In en, this message translates to:
  /// **'Load heatmap'**
  String get hmTitle;

  /// No description provided for @hmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A year of training load, day by day'**
  String get hmSubtitle;

  /// No description provided for @hmPeriod12m.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get hmPeriod12m;

  /// No description provided for @hmPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get hmPeriodYear;

  /// No description provided for @hmPeriodLastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get hmPeriodLastYear;

  /// No description provided for @hmLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get hmLess;

  /// No description provided for @hmMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get hmMore;

  /// No description provided for @hmTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see its load.'**
  String get hmTap;

  /// No description provided for @hmDay.
  ///
  /// In en, this message translates to:
  /// **'{date}: {tss} TSS · {sessions} sessions'**
  String hmDay(String date, int tss, int sessions);

  /// No description provided for @hmRest.
  ///
  /// In en, this message translates to:
  /// **'{date}: no training'**
  String hmRest(String date);

  /// No description provided for @hmTotal.
  ///
  /// In en, this message translates to:
  /// **'Total load'**
  String get hmTotal;

  /// No description provided for @hmActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Training days'**
  String get hmActiveDays;

  /// No description provided for @hmLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get hmLongestStreak;

  /// No description provided for @hmBusiestWeek.
  ///
  /// In en, this message translates to:
  /// **'Busiest week'**
  String get hmBusiestWeek;

  /// No description provided for @hmDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String hmDays(int count);

  /// No description provided for @hmWeekOf.
  ///
  /// In en, this message translates to:
  /// **'{tss} TSS, week of {date}'**
  String hmWeekOf(int tss, String date);

  /// No description provided for @hmNoData.
  ///
  /// In en, this message translates to:
  /// **'No training in this period.'**
  String get hmNoData;

  /// No description provided for @beTitle.
  ///
  /// In en, this message translates to:
  /// **'Best efforts'**
  String get beTitle;

  /// No description provided for @beSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best 5 s to 20 min power or 1 to 10 km pace over time, against your last 90 days'**
  String get beSubtitle;

  /// No description provided for @beWindowBest.
  ///
  /// In en, this message translates to:
  /// **'30-day best'**
  String get beWindowBest;

  /// No description provided for @beRollingBest.
  ///
  /// In en, this message translates to:
  /// **'Best of 90 days'**
  String get beRollingBest;

  /// No description provided for @beTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days against the 90 days before'**
  String get beTableTitle;

  /// No description provided for @beColEffort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get beColEffort;

  /// No description provided for @beColNow.
  ///
  /// In en, this message translates to:
  /// **'Last 30 d'**
  String get beColNow;

  /// No description provided for @beColBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beColBefore;

  /// No description provided for @beColChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get beColChange;

  /// No description provided for @beHint.
  ///
  /// In en, this message translates to:
  /// **'Each point is your best effort in a 30-day window; the second line is the best of the 90 days up to it. Change compares your last 30 days with the best of the 90 days before them: green is a better effort, red a worse one.'**
  String get beHint;

  /// No description provided for @beNoData.
  ///
  /// In en, this message translates to:
  /// **'No efforts recorded in the last year.'**
  String get beNoData;

  /// No description provided for @heroTitleCaution.
  ///
  /// In en, this message translates to:
  /// **'Train with care'**
  String get heroTitleCaution;

  /// No description provided for @heroTitleBackOff.
  ///
  /// In en, this message translates to:
  /// **'Take it easy today'**
  String get heroTitleBackOff;

  /// No description provided for @pvTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent & your rights'**
  String get pvTitle;

  /// No description provided for @pvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What TriIQ stores, who sees it, and your choices'**
  String get pvSubtitle;

  /// No description provided for @pvIntro.
  ///
  /// In en, this message translates to:
  /// **'TriIQ has no account, no server and no tracking. Your data stays on this device and goes only to the services you connect yourself.'**
  String get pvIntro;

  /// No description provided for @pvDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What is processed'**
  String get pvDataTitle;

  /// No description provided for @pvDataBody.
  ///
  /// In en, this message translates to:
  /// **'• Activities and routes (GPS tracks) from Intervals.icu\n• Health and wellness data: heart rate, HRV, resting heart rate, sleep, weight and how you feel. This is health data, a special category under the GDPR.\n• Your profile: name, picture, thresholds, goals and plans\n• API keys for the services you connect'**
  String get pvDataBody;

  /// No description provided for @pvStoredTitle.
  ///
  /// In en, this message translates to:
  /// **'Where it is stored'**
  String get pvStoredTitle;

  /// No description provided for @pvStoredBody.
  ///
  /// In en, this message translates to:
  /// **'Only on this device: a local database and app preferences. API keys are kept in the operating system\'s secure storage. Android\'s cloud backup is switched off for the app. TriIQ has no server and receives none of your data.'**
  String get pvStoredBody;

  /// No description provided for @pvRecipientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Who receives data'**
  String get pvRecipientsTitle;

  /// No description provided for @pvRecipientsBody.
  ///
  /// In en, this message translates to:
  /// **'• Intervals.icu: your training data is synced with your account, using your API key.\n• Your AI provider (Claude by Anthropic, Ollama Cloud, or your own Ollama server): only when you have allowed it below and use the AI trainer, Train now, the weekly note or AI-written plan content. The conversation and the training and health data it needs are sent.\n• OpenStreetMap tile servers: only when a route map is shown. They see your IP address and the map area.\nNothing else: no analytics, no crash reporting, no advertising.'**
  String get pvRecipientsBody;

  /// No description provided for @pvTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfers outside the EU/EEA'**
  String get pvTransferTitle;

  /// No description provided for @pvTransferBody.
  ///
  /// In en, this message translates to:
  /// **'Some of these services may process data outside the EU/EEA (for example an AI provider in the USA). Their own privacy terms apply to what they receive. A self-hosted Ollama server on your own network keeps the data with you.'**
  String get pvTransferBody;

  /// No description provided for @pvBasisTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal basis'**
  String get pvBasisTitle;

  /// No description provided for @pvBasisBody.
  ///
  /// In en, this message translates to:
  /// **'Syncing with Intervals.icu happens because you connected your account. Sending health and training data to an AI provider happens only with your explicit consent (GDPR Art. 6(1)(a) and 9(2)(a)), which you can withdraw at any time below. Map tiles are fetched only to show the map you opened; you can switch that off.'**
  String get pvBasisBody;

  /// No description provided for @pvRetentionTitle.
  ///
  /// In en, this message translates to:
  /// **'How long'**
  String get pvRetentionTitle;

  /// No description provided for @pvRetentionBody.
  ///
  /// In en, this message translates to:
  /// **'Until you delete it: data stays on your device until you erase it here, restore a backup over it or uninstall the app. Data already sent to Intervals.icu or an AI provider is kept by them under their own rules.'**
  String get pvRetentionBody;

  /// No description provided for @pvRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get pvRightsTitle;

  /// No description provided for @pvRightsBody.
  ///
  /// In en, this message translates to:
  /// **'• Access and portability: Settings → Data & privacy → Backup exports everything stored here as one file.\n• Rectification: correct your data in Intervals.icu; the next sync updates this device.\n• Erasure: use \"Delete all data\" below. To remove your data at Intervals.icu or an AI provider, use their account tools.\n• Withdraw consent or object: switch the AI off below, or disconnect Intervals.icu in Profile.\n• Complaint: you can complain to your data protection authority.'**
  String get pvRightsBody;

  /// No description provided for @pvControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get pvControlsTitle;

  /// No description provided for @pvAiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Send my data to the AI provider'**
  String get pvAiConsentTitle;

  /// No description provided for @pvAiConsentHelp.
  ///
  /// In en, this message translates to:
  /// **'Allows training and health data to be sent to your AI provider when you use the AI trainer. Off: the AI features stay unavailable.'**
  String get pvAiConsentHelp;

  /// No description provided for @pvAiConsentSince.
  ///
  /// In en, this message translates to:
  /// **'Allowed on {date}'**
  String pvAiConsentSince(String date);

  /// No description provided for @pvMapTilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Load map tiles from OpenStreetMap'**
  String get pvMapTilesTitle;

  /// No description provided for @pvMapTilesHelp.
  ///
  /// In en, this message translates to:
  /// **'Route maps need tiles from OpenStreetMap, which sees your IP address and the area shown. Off: routes are drawn without a map.'**
  String get pvMapTilesHelp;

  /// No description provided for @pvEraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data on this device'**
  String get pvEraseTitle;

  /// No description provided for @pvEraseHelp.
  ///
  /// In en, this message translates to:
  /// **'Removes activities, wellness, plans, settings, saved keys and the offline queue from this device and disconnects Intervals.icu. It does not delete anything at Intervals.icu or your AI provider.'**
  String get pvEraseHelp;

  /// No description provided for @pvEraseButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all data…'**
  String get pvEraseButton;

  /// No description provided for @pvEraseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get pvEraseConfirmTitle;

  /// No description provided for @pvEraseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Everything TriIQ stores on this device will be removed and the app disconnected. Export a backup first if you want to keep it. This cannot be undone.'**
  String get pvEraseConfirmBody;

  /// No description provided for @pvEraseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get pvEraseConfirm;

  /// No description provided for @pvEraseDone.
  ///
  /// In en, this message translates to:
  /// **'All data on this device was deleted.'**
  String get pvEraseDone;

  /// No description provided for @pvEraseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete everything: {error}'**
  String pvEraseFailed(String error);

  /// No description provided for @pvOpenWeb.
  ///
  /// In en, this message translates to:
  /// **'Read the full privacy notice'**
  String get pvOpenWeb;

  /// No description provided for @pvContact.
  ///
  /// In en, this message translates to:
  /// **'Questions or requests: open an issue at github.com/uid09552/triiq.'**
  String get pvContact;

  /// No description provided for @pvConsentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow AI processing?'**
  String get pvConsentDialogTitle;

  /// No description provided for @pvConsentDialogBody.
  ///
  /// In en, this message translates to:
  /// **'To answer, the AI trainer sends your questions together with training and health data (activities, heart rate, HRV, sleep, weight, how you feel) to {provider}. {provider} may process it outside the EU/EEA. You can withdraw this at any time in Settings → Data & privacy → Consent & your rights.'**
  String pvConsentDialogBody(String provider);

  /// No description provided for @pvConsentAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get pvConsentAllow;

  /// No description provided for @pvConsentNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get pvConsentNotNow;

  /// No description provided for @pvConsentCardTitle.
  ///
  /// In en, this message translates to:
  /// **'The AI trainer needs your consent'**
  String get pvConsentCardTitle;

  /// No description provided for @pvConsentCardBody.
  ///
  /// In en, this message translates to:
  /// **'Choose whether your training and health data may be sent to {provider}.'**
  String pvConsentCardBody(String provider);

  /// No description provided for @pvProviderClaude.
  ///
  /// In en, this message translates to:
  /// **'Claude (Anthropic)'**
  String get pvProviderClaude;

  /// No description provided for @pvProviderOllamaCloud.
  ///
  /// In en, this message translates to:
  /// **'Ollama Cloud'**
  String get pvProviderOllamaCloud;

  /// No description provided for @pvProviderOllamaServer.
  ///
  /// In en, this message translates to:
  /// **'your Ollama server'**
  String get pvProviderOllamaServer;

  /// No description provided for @syncStatusNow.
  ///
  /// In en, this message translates to:
  /// **'Synced just now'**
  String get syncStatusNow;

  /// No description provided for @syncStatusMinutes.
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes} min ago'**
  String syncStatusMinutes(int minutes);

  /// No description provided for @syncStatusHours.
  ///
  /// In en, this message translates to:
  /// **'Synced {hours} h ago'**
  String syncStatusHours(int hours);

  /// No description provided for @syncStatusDays.
  ///
  /// In en, this message translates to:
  /// **'Synced {days} d ago'**
  String syncStatusDays(int days);

  /// No description provided for @syncStatusNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncStatusNever;

  /// No description provided for @syncStatusNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get syncStatusNotConnected;

  /// No description provided for @syncStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting to send'**
  String syncStatusWaiting(int count);

  /// No description provided for @syncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'{count} failed to send'**
  String syncStatusFailed(int count);

  /// No description provided for @syncStatusTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open sync'**
  String get syncStatusTooltip;

  /// No description provided for @undoButton.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoButton;

  /// No description provided for @workoutRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored “{name}”'**
  String workoutRestored(String name);

  /// No description provided for @replaceUndone.
  ///
  /// In en, this message translates to:
  /// **'Back to “{name}”'**
  String replaceUndone(String name);

  /// No description provided for @couldNotUndo.
  ///
  /// In en, this message translates to:
  /// **'Could not undo: {error}'**
  String couldNotUndo(String error);

  /// No description provided for @workoutReplacedUndoable.
  ///
  /// In en, this message translates to:
  /// **'{name} replaces the session'**
  String workoutReplacedUndoable(String name);

  /// No description provided for @workoutDeletedUndoable.
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted'**
  String workoutDeletedUndoable(String name);

  /// No description provided for @moreGroupPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get moreGroupPlan;

  /// No description provided for @moreGroupTrainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get moreGroupTrainer;

  /// No description provided for @moreGroupData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get moreGroupData;

  /// No description provided for @exNoIntervals.
  ///
  /// In en, this message translates to:
  /// **'No intervals in this session.'**
  String get exNoIntervals;

  /// No description provided for @actTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get actTabOverview;

  /// No description provided for @actTabCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get actTabCharts;

  /// No description provided for @actTabIntervals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get actTabIntervals;

  /// No description provided for @actTabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get actTabMap;

  /// No description provided for @actMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get actMoreActions;

  /// No description provided for @actSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get actSearchHint;

  /// No description provided for @actSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actSearch;

  /// No description provided for @actFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter and sort'**
  String get actFilterTitle;

  /// No description provided for @actFilterSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get actFilterSport;

  /// No description provided for @actAllSports.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get actAllSports;

  /// No description provided for @actFilterDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get actFilterDate;

  /// No description provided for @actThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get actThisWeek;

  /// No description provided for @actThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get actThisMonth;

  /// No description provided for @actLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get actLast3Months;

  /// No description provided for @actCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get actCustomRange;

  /// No description provided for @actFilterDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance (km)'**
  String get actFilterDistance;

  /// No description provided for @actFilterDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get actFilterDuration;

  /// No description provided for @actHasPower.
  ///
  /// In en, this message translates to:
  /// **'Has power'**
  String get actHasPower;

  /// No description provided for @actHasGps.
  ///
  /// In en, this message translates to:
  /// **'Has GPS'**
  String get actHasGps;

  /// No description provided for @actSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get actSortBy;

  /// No description provided for @actSortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get actSortDate;

  /// No description provided for @actSortDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get actSortDistance;

  /// No description provided for @actSortDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get actSortDuration;

  /// No description provided for @actSortLoad.
  ///
  /// In en, this message translates to:
  /// **'Load (TSS)'**
  String get actSortLoad;

  /// No description provided for @actResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 activity} other{{count} activities}}'**
  String actResultCount(int count);

  /// No description provided for @actClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get actClearFilters;

  /// No description provided for @actNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No activity matches these filters.'**
  String get actNoMatch;

  /// No description provided for @actAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get actAny;

  /// No description provided for @setGroupTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get setGroupTraining;

  /// No description provided for @setGroupTrainingSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly targets, year goals, how you feel'**
  String get setGroupTrainingSub;

  /// No description provided for @setGroupAi.
  ///
  /// In en, this message translates to:
  /// **'AI trainer'**
  String get setGroupAi;

  /// No description provided for @setGroupAiSub.
  ///
  /// In en, this message translates to:
  /// **'Provider, model, AI consent'**
  String get setGroupAiSub;

  /// No description provided for @setGroupData.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get setGroupData;

  /// No description provided for @setGroupDataSub.
  ///
  /// In en, this message translates to:
  /// **'Sync, calendar, backup, privacy'**
  String get setGroupDataSub;

  /// No description provided for @setGroupApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get setGroupApp;

  /// No description provided for @setGroupAppSub.
  ///
  /// In en, this message translates to:
  /// **'Appearance, language, notifications'**
  String get setGroupAppSub;

  /// No description provided for @setSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get setSearchHint;

  /// No description provided for @setNoResults.
  ///
  /// In en, this message translates to:
  /// **'No setting matches “{query}”.'**
  String setNoResults(String query);

  /// No description provided for @obSkipSetup.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get obSkipSetup;

  /// No description provided for @obSkipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get obSkipStep;

  /// No description provided for @obNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get obNext;

  /// No description provided for @obBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get obBack;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TriIQ'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your training companion for swim, bike and run: readiness each morning, load and fitness at a glance, plans that adapt, and an AI trainer that knows your data.'**
  String get obWelcomeBody;

  /// No description provided for @obWelcomePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device. TriIQ reads it from Intervals.icu and only sends it to an AI provider if you agree.'**
  String get obWelcomePrivacy;

  /// No description provided for @obGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get obGetStarted;

  /// No description provided for @obConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu'**
  String get obConnectTitle;

  /// No description provided for @obConnectBody.
  ///
  /// In en, this message translates to:
  /// **'TriIQ reads your activities, wellness and calendar from Intervals.icu. Log in with Intervals.icu, or paste your API key.'**
  String get obConnectBody;

  /// No description provided for @obWhereKey.
  ///
  /// In en, this message translates to:
  /// **'Where do I find it?'**
  String get obWhereKey;

  /// No description provided for @obConnect.
  ///
  /// In en, this message translates to:
  /// **'Test and connect'**
  String get obConnect;

  /// No description provided for @obConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected as {name}'**
  String obConnected(String name);

  /// No description provided for @obSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing this month…'**
  String get obSyncing;

  /// No description provided for @obSynced.
  ///
  /// In en, this message translates to:
  /// **'This month is synced: {count} activities.'**
  String obSynced(int count);

  /// No description provided for @obSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Connected, but the first sync failed. It will retry in the background.'**
  String get obSyncFailed;

  /// No description provided for @obTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your training'**
  String get obTrainingTitle;

  /// No description provided for @obTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'Which sports do you do, and how many hours a week? Today shows your progress as rings.'**
  String get obTrainingBody;

  /// No description provided for @obHoursPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{sport}: hours per week'**
  String obHoursPerWeek(String sport);

  /// No description provided for @obSwim.
  ///
  /// In en, this message translates to:
  /// **'Swim'**
  String get obSwim;

  /// No description provided for @obRide.
  ///
  /// In en, this message translates to:
  /// **'Ride'**
  String get obRide;

  /// No description provided for @obRun.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get obRun;

  /// No description provided for @obAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI trainer (optional)'**
  String get obAiTitle;

  /// No description provided for @obAiBody.
  ///
  /// In en, this message translates to:
  /// **'Chat with a trainer that knows your data, and let it write plans. Pick a provider, or skip: you can set it up later in Settings.'**
  String get obAiBody;

  /// No description provided for @obAiNone.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get obAiNone;

  /// No description provided for @obOllamaServer.
  ///
  /// In en, this message translates to:
  /// **'Ollama server'**
  String get obOllamaServer;

  /// No description provided for @obAiSave.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get obAiSave;

  /// No description provided for @obDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re set'**
  String get obDoneTitle;

  /// No description provided for @obDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Today shows your readiness, today\'s training and your load. Everything you chose can be changed in Settings.'**
  String get obDoneBody;

  /// No description provided for @obOpenToday.
  ///
  /// In en, this message translates to:
  /// **'Open Today'**
  String get obOpenToday;

  /// No description provided for @obStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String obStep(int n, int total);

  /// No description provided for @smOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get smOfflineTitle;

  /// No description provided for @smOfflineReason.
  ///
  /// In en, this message translates to:
  /// **'Showing what\'s saved on this device. Try again once you\'re online.'**
  String get smOfflineReason;

  /// No description provided for @smRefusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu refused the request'**
  String get smRefusedTitle;

  /// No description provided for @smRefusedReason.
  ///
  /// In en, this message translates to:
  /// **'Check your API key in Profile.'**
  String get smRefusedReason;

  /// No description provided for @smNotConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get smNotConnectedTitle;

  /// No description provided for @smNotConnectedReason.
  ///
  /// In en, this message translates to:
  /// **'Connect Intervals.icu in Profile to load this.'**
  String get smNotConnectedReason;

  /// No description provided for @smServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu is having trouble'**
  String get smServerTitle;

  /// No description provided for @smServerReason.
  ///
  /// In en, this message translates to:
  /// **'Try again in a few minutes.'**
  String get smServerReason;

  /// No description provided for @smRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many requests'**
  String get smRateTitle;

  /// No description provided for @smRateReason.
  ///
  /// In en, this message translates to:
  /// **'Intervals.icu asks to slow down. Wait a minute, then try again.'**
  String get smRateReason;

  /// No description provided for @smLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read the data on this device'**
  String get smLocalTitle;

  /// No description provided for @smLocalReason.
  ///
  /// In en, this message translates to:
  /// **'Try again. If it keeps failing, a sync rebuilds it.'**
  String get smLocalReason;

  /// No description provided for @smGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get smGenericTitle;

  /// No description provided for @smGenericReason.
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get smGenericReason;

  /// No description provided for @smDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get smDetails;

  /// No description provided for @smOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get smOpenProfile;

  /// No description provided for @smOpenSync.
  ///
  /// In en, this message translates to:
  /// **'Open Sync'**
  String get smOpenSync;

  /// No description provided for @smNeedHistory.
  ///
  /// In en, this message translates to:
  /// **'This needs synced activities from Intervals.icu. Sync more history to fill it in.'**
  String get smNeedHistory;

  /// No description provided for @wtNoDataReason.
  ///
  /// In en, this message translates to:
  /// **'Wellness comes from your watch or app through Intervals.icu (HRV, resting heart rate, sleep, weight). Sync, or pick a longer range.'**
  String get wtNoDataReason;

  /// No description provided for @sessionDiagramNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No time series'**
  String get sessionDiagramNoDataTitle;

  /// No description provided for @a11yChartSeries.
  ///
  /// In en, this message translates to:
  /// **'{series}: latest {value}, {change} over the range'**
  String a11yChartSeries(String series, String value, String change);

  /// No description provided for @a11yChartSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected {label}: {values}'**
  String a11yChartSelected(String label, String values);

  /// No description provided for @a11yChartNoData.
  ///
  /// In en, this message translates to:
  /// **'Chart, no data'**
  String get a11yChartNoData;

  /// No description provided for @a11yBarChart.
  ///
  /// In en, this message translates to:
  /// **'Bar chart, {count} bars. Latest {label}: {value}. Highest {maxLabel}: {max}.'**
  String a11yBarChart(
    int count,
    String label,
    String value,
    String maxLabel,
    String max,
  );

  /// No description provided for @a11yReadinessScore.
  ///
  /// In en, this message translates to:
  /// **'Readiness {score} of 100'**
  String a11yReadinessScore(int score);

  /// No description provided for @a11yReadinessNoScore.
  ///
  /// In en, this message translates to:
  /// **'Readiness, no score yet'**
  String get a11yReadinessNoScore;

  /// No description provided for @a11ySignalOk.
  ///
  /// In en, this message translates to:
  /// **'fine'**
  String get a11ySignalOk;

  /// No description provided for @a11ySignalCaution.
  ///
  /// In en, this message translates to:
  /// **'caution'**
  String get a11ySignalCaution;

  /// No description provided for @a11ySignalBackOff.
  ///
  /// In en, this message translates to:
  /// **'back off'**
  String get a11ySignalBackOff;

  /// No description provided for @a11ySignalNone.
  ///
  /// In en, this message translates to:
  /// **'no rating'**
  String get a11ySignalNone;

  /// No description provided for @a11yHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Load heatmap: {days} days with training, {tss} TSS in total, longest streak {streak} days.'**
  String a11yHeatmap(int days, int tss, int streak);

  /// No description provided for @a11yStreamChart.
  ///
  /// In en, this message translates to:
  /// **'Time-series chart: {series}'**
  String a11yStreamChart(String series);

  /// No description provided for @trainDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get trainDetailLabel;

  /// No description provided for @trainDetailShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get trainDetailShort;

  /// No description provided for @trainDetailDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get trainDetailDetailed;

  /// No description provided for @trainDetailShortHint.
  ///
  /// In en, this message translates to:
  /// **'One compact table: a row per segment.'**
  String get trainDetailShortHint;

  /// No description provided for @trainDetailDetailedHint.
  ///
  /// In en, this message translates to:
  /// **'Named exercises and drills, with sets, reps, rest, targets and a coaching cue for each block.'**
  String get trainDetailDetailedHint;

  /// No description provided for @loginWithIntervals.
  ///
  /// In en, this message translates to:
  /// **'Log in with Intervals.icu'**
  String get loginWithIntervals;

  /// No description provided for @loginHelp.
  ///
  /// In en, this message translates to:
  /// **'Opens Intervals.icu in your browser. TriIQ never sees your password.'**
  String get loginHelp;

  /// No description provided for @loginWaiting.
  ///
  /// In en, this message translates to:
  /// **'Finish logging in in your browser…'**
  String get loginWaiting;

  /// No description provided for @loginOrApiKey.
  ///
  /// In en, this message translates to:
  /// **'or use an API key'**
  String get loginOrApiKey;

  /// No description provided for @loginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Login cancelled.'**
  String get loginCancelled;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not log in: {error}'**
  String loginFailed(String error);

  /// No description provided for @connectedViaOAuth.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Intervals.icu'**
  String get connectedViaOAuth;

  /// No description provided for @connectedViaApiKey.
  ///
  /// In en, this message translates to:
  /// **'Connected with an API key'**
  String get connectedViaApiKey;

  /// No description provided for @readinessSignalLoad.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get readinessSignalLoad;

  /// No description provided for @readinessSignalDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get readinessSignalDevice;

  /// No description provided for @readinessOptionLoad.
  ///
  /// In en, this message translates to:
  /// **'Load: today\'s training so far, and the acute:chronic ratio (ATL ÷ CTL)'**
  String get readinessOptionLoad;

  /// No description provided for @readinessOptionDevice.
  ///
  /// In en, this message translates to:
  /// **'The readiness figure your watch or app writes to Intervals.icu (0–100)'**
  String get readinessOptionDevice;

  /// No description provided for @readinessRangeLoad.
  ///
  /// In en, this message translates to:
  /// **'Normal below {value} ATL ÷ CTL'**
  String readinessRangeLoad(String value);

  /// No description provided for @readinessLoadToday.
  ///
  /// In en, this message translates to:
  /// **'{tss} TSS today'**
  String readinessLoadToday(String tss);

  /// No description provided for @readinessRangeDevice.
  ///
  /// In en, this message translates to:
  /// **'Normal from {value}'**
  String readinessRangeDevice(String value);

  /// No description provided for @insPeekAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Fitness, fatigue and form over time, with load-safety checks.'**
  String get insPeekAnalytics;

  /// No description provided for @insPeekExplorer.
  ///
  /// In en, this message translates to:
  /// **'Any metric over any period, week by week or day by day.'**
  String get insPeekExplorer;

  /// No description provided for @insPeekHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Your training load, day by day, in one grid.'**
  String get insPeekHeatmap;

  /// No description provided for @insPeekCurves.
  ///
  /// In en, this message translates to:
  /// **'Your best power, pace and heart rate for every duration.'**
  String get insPeekCurves;

  /// No description provided for @insPeekBestEfforts.
  ///
  /// In en, this message translates to:
  /// **'Your best efforts lately, against the season.'**
  String get insPeekBestEfforts;

  /// No description provided for @insPeekDurability.
  ///
  /// In en, this message translates to:
  /// **'How much power you keep once you are already fatigued.'**
  String get insPeekDurability;

  /// No description provided for @insPeekWellness.
  ///
  /// In en, this message translates to:
  /// **'Trends in HRV, resting heart rate, sleep and weight.'**
  String get insPeekWellness;

  /// No description provided for @insPeekCompare.
  ///
  /// In en, this message translates to:
  /// **'Two activities, or two training blocks, side by side.'**
  String get insPeekCompare;

  /// No description provided for @insPeekWeeklyReview.
  ///
  /// In en, this message translates to:
  /// **'How last week went, against the week before.'**
  String get insPeekWeeklyReview;

  /// No description provided for @insPeekActivities.
  ///
  /// In en, this message translates to:
  /// **'Every synced session: search, filter, sort.'**
  String get insPeekActivities;

  /// No description provided for @insPeekNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Sync to fill this in.'**
  String get insPeekNoData;

  /// No description provided for @insPeekOpenToLoad.
  ///
  /// In en, this message translates to:
  /// **'Open it once to load your curves.'**
  String get insPeekOpenToLoad;

  /// No description provided for @insPeekTapHint.
  ///
  /// In en, this message translates to:
  /// **'Release to close · tap to open'**
  String get insPeekTapHint;

  /// No description provided for @insPeekThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get insPeekThisWeek;

  /// No description provided for @insPeekAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get insPeekAverage;

  /// No description provided for @insPeekActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get insPeekActiveDays;

  /// No description provided for @insPeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get insPeekStreak;

  /// No description provided for @insPeekTss.
  ///
  /// In en, this message translates to:
  /// **'TSS'**
  String get insPeekTss;

  /// No description provided for @insPeekSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get insPeekSeason;

  /// No description provided for @insPeekSixWeeks.
  ///
  /// In en, this message translates to:
  /// **'Last 6 weeks'**
  String get insPeekSixWeeks;

  /// No description provided for @insPeekRides.
  ///
  /// In en, this message translates to:
  /// **'Rides over 1,000 kJ (12 weeks)'**
  String get insPeekRides;

  /// No description provided for @insPeekHrv.
  ///
  /// In en, this message translates to:
  /// **'HRV'**
  String get insPeekHrv;

  /// No description provided for @insPeekRestingHr.
  ///
  /// In en, this message translates to:
  /// **'Resting HR'**
  String get insPeekRestingHr;

  /// No description provided for @insPeekSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get insPeekSleep;

  /// No description provided for @insPeekBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get insPeekBefore;

  /// No description provided for @insPeekLast4.
  ///
  /// In en, this message translates to:
  /// **'Last 4 weeks'**
  String get insPeekLast4;

  /// No description provided for @insPeekLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get insPeekLastWeek;

  /// No description provided for @insPeekHours.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get insPeekHours;

  /// No description provided for @insPeekSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get insPeekSessions;

  /// No description provided for @insPeekWeekBefore.
  ///
  /// In en, this message translates to:
  /// **'Week before'**
  String get insPeekWeekBefore;

  /// No description provided for @readinessPeekFitness.
  ///
  /// In en, this message translates to:
  /// **'Chronic training load (CTL): your fitness built over the last weeks. The arrow compares it with a week ago.'**
  String get readinessPeekFitness;

  /// No description provided for @readinessPeekToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get readinessPeekToday;

  /// No description provided for @readinessPeekWeekChange.
  ///
  /// In en, this message translates to:
  /// **'vs a week ago'**
  String get readinessPeekWeekChange;
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
