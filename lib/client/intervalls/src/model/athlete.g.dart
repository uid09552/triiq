// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteCWProxy {
  Athlete id(String? id);

  Athlete name(String? name);

  Athlete firstname(String? firstname);

  Athlete lastname(String? lastname);

  Athlete profileMedium(String? profileMedium);

  Athlete measurementPreference(String? measurementPreference);

  Athlete weightPrefLb(bool? weightPrefLb);

  Athlete fahrenheit(bool? fahrenheit);

  Athlete windSpeed(AthleteWindSpeedEnum? windSpeed);

  Athlete rain(AthleteRainEnum? rain);

  Athlete weight(double? weight);

  Athlete email(String? email);

  Athlete sex(String? sex);

  Athlete city(String? city);

  Athlete state(String? state);

  Athlete country(String? country);

  Athlete countries(List<String>? countries);

  Athlete languages(List<String>? languages);

  Athlete bikes(List<StravaGear>? bikes);

  Athlete shoes(List<StravaGear>? shoes);

  Athlete timezone(String? timezone);

  Athlete locale(String? locale);

  Athlete dateFormat(String? dateFormat);

  Athlete timeFormat(String? timeFormat);

  Athlete visibility(AthleteVisibilityEnum? visibility);

  Athlete icuLastSeen(DateTime? icuLastSeen);

  Athlete status(AthleteStatusEnum? status);

  Athlete statusUpdated(DateTime? statusUpdated);

  Athlete icuRestingHr(int? icuRestingHr);

  Athlete icuWeight(double? icuWeight);

  Athlete icuWeightSync(AthleteIcuWeightSyncEnum? icuWeightSync);

  Athlete icuActivated(DateTime? icuActivated);

  Athlete icuQueuePos(int? icuQueuePos);

  Athlete icuAdmin(bool? icuAdmin);

  Athlete icuFriendInviteToken(String? icuFriendInviteToken);

  Athlete icuPermission(AthleteIcuPermissionEnum? icuPermission);

  Athlete icuEffortSecs(List<int>? icuEffortSecs);

  Athlete icuCoach(bool? icuCoach);

  Athlete bio(String? bio);

  Athlete website(String? website);

  Athlete icuDateOfBirth(String? icuDateOfBirth);

  Athlete icuApiKey(String? icuApiKey);

  Athlete icuTypeSettings(List<Settings>? icuTypeSettings);

  Athlete icuFormAsPercent(bool? icuFormAsPercent);

  Athlete icuMmpDays(int? icuMmpDays);

  Athlete icuWellnessPrompt(bool? icuWellnessPrompt);

  Athlete wellnessLastPromptDate(String? wellnessLastPromptDate);

  Athlete icuWellnessKeys(List<String>? icuWellnessKeys);

  Athlete privateWellnessKeys(List<String>? privateWellnessKeys);

  Athlete icuTrackMenstrualCycle(bool? icuTrackMenstrualCycle);

  Athlete icuMenstrualCyclePerm(
    AthleteIcuMenstrualCyclePermEnum? icuMenstrualCyclePerm,
  );

  Athlete activityRpePrompt(bool? activityRpePrompt);

  Athlete coachTicks(List<CoachTick>? coachTicks);

  Athlete icuGarminHealth(bool? icuGarminHealth);

  Athlete icuGarminTraining(bool? icuGarminTraining);

  Athlete icuGarminSyncActivities(bool? icuGarminSyncActivities);

  Athlete garminSyncActivityTypes(
    List<AthleteGarminSyncActivityTypesEnum>? garminSyncActivityTypes,
  );

  Athlete garminSyncAfter(DateTime? garminSyncAfter);

  Athlete icuGarminDownloadWellness(bool? icuGarminDownloadWellness);

  Athlete icuGarminUploadWorkouts(bool? icuGarminUploadWorkouts);

  Athlete icuGarminOutdoorPowerRange(double? icuGarminOutdoorPowerRange);

  Athlete icuGarminHrRange(double? icuGarminHrRange);

  Athlete garminPaceRange(double? garminPaceRange);

  Athlete garminPowerTarget(AthleteGarminPowerTargetEnum? garminPowerTarget);

  Athlete icuGarminLastUpload(DateTime? icuGarminLastUpload);

  Athlete icuGarminUploadFilters(List<ActivityFilter>? icuGarminUploadFilters);

  Athlete icuGarminWellnessKeys(List<String>? icuGarminWellnessKeys);

  Athlete openStepDuration(int? openStepDuration);

  Athlete polarScope(String? polarScope);

  Athlete polarSyncActivities(bool? polarSyncActivities);

  Athlete polarSyncActivityTypes(
    List<AthletePolarSyncActivityTypesEnum>? polarSyncActivityTypes,
  );

  Athlete polarDownloadWellness(bool? polarDownloadWellness);

  Athlete polarWellnessKeys(List<String>? polarWellnessKeys);

  Athlete suuntoScope(String? suuntoScope);

  Athlete suuntoUserId(String? suuntoUserId);

  Athlete suuntoSyncActivities(bool? suuntoSyncActivities);

  Athlete suuntoSyncActivityTypes(
    List<AthleteSuuntoSyncActivityTypesEnum>? suuntoSyncActivityTypes,
  );

  Athlete suuntoUploadWorkouts(bool? suuntoUploadWorkouts);

  Athlete suuntoOutdoorPowerRange(double? suuntoOutdoorPowerRange);

  Athlete suuntoHrRange(double? suuntoHrRange);

  Athlete suuntoPaceRange(double? suuntoPaceRange);

  Athlete suuntoLastUpload(DateTime? suuntoLastUpload);

  Athlete suuntoUploadFilters(List<ActivityFilter>? suuntoUploadFilters);

  Athlete suuntoDownloadWellness(bool? suuntoDownloadWellness);

  Athlete corosUserId(String? corosUserId);

  Athlete corosSyncActivities(bool? corosSyncActivities);

  Athlete corosUploadWorkouts(bool? corosUploadWorkouts);

  Athlete corosDownloadWellness(bool? corosDownloadWellness);

  Athlete corosLastUpload(DateTime? corosLastUpload);

  Athlete concept2UserId(String? concept2UserId);

  Athlete concept2SyncActivities(bool? concept2SyncActivities);

  Athlete zeppUserId(String? zeppUserId);

  Athlete zeppSyncActivities(bool? zeppSyncActivities);

  Athlete zeppUploadWorkouts(bool? zeppUploadWorkouts);

  Athlete zeppDownloadWellness(bool? zeppDownloadWellness);

  Athlete huaweiUserId(String? huaweiUserId);

  Athlete huaweiSyncActivities(bool? huaweiSyncActivities);

  Athlete huaweiUploadWorkouts(bool? huaweiUploadWorkouts);

  Athlete huaweiDownloadWellness(bool? huaweiDownloadWellness);

  Athlete wahooUserId(String? wahooUserId);

  Athlete wahooSyncActivities(bool? wahooSyncActivities);

  Athlete wahooUploadWorkouts(bool? wahooUploadWorkouts);

  Athlete zwiftUserId(String? zwiftUserId);

  Athlete zwiftSyncActivities(bool? zwiftSyncActivities);

  Athlete zwiftUploadWorkouts(bool? zwiftUploadWorkouts);

  Athlete dropboxScope(String? dropboxScope);

  Athlete ouraScope(String? ouraScope);

  Athlete ouraWellnessKeys(List<String>? ouraWellnessKeys);

  Athlete whoopScope(String? whoopScope);

  Athlete whoopWellnessKeys(List<String>? whoopWellnessKeys);

  Athlete googleScope(String? googleScope);

  Athlete googleWellnessKeys(List<String>? googleWellnessKeys);

  Athlete icuEmailVerified(bool? icuEmailVerified);

  Athlete icuEmailDisabled(String? icuEmailDisabled);

  Athlete emailNotifications(
    List<AthleteEmailNotificationsEnum>? emailNotifications,
  );

  Athlete pushNotifications(
    List<AthletePushNotificationsEnum>? pushNotifications,
  );

  Athlete notificationAthleteTagsEnabled(
    List<String>? notificationAthleteTagsEnabled,
  );

  Athlete hasPushSubscriptions(bool? hasPushSubscriptions);

  Athlete includeDescrInPlanForWeek(bool? includeDescrInPlanForWeek);

  Athlete icuSendAchievements(bool? icuSendAchievements);

  Athlete icuSendNewsletter(bool? icuSendNewsletter);

  Athlete icuSendPrivateChat(bool? icuSendPrivateChat);

  Athlete icuSendPrivateMsg(bool? icuSendPrivateMsg);

  Athlete icuSendFollowReq(bool? icuSendFollowReq);

  Athlete icuSendGroupChat(bool? icuSendGroupChat);

  Athlete icuSendGroupMsg(bool? icuSendGroupMsg);

  Athlete icuSendActivityChat(bool? icuSendActivityChat);

  Athlete icuSendFollowedActivityChat(bool? icuSendFollowedActivityChat);

  Athlete icuSendCoachedActivityChat(bool? icuSendCoachedActivityChat);

  Athlete icuSendActivityMsg(bool? icuSendActivityMsg);

  Athlete icuSendCoachMeReq(bool? icuSendCoachMeReq);

  Athlete icuSendGearAlerts(bool? icuSendGearAlerts);

  Athlete icuSendPlanForWeek(bool? icuSendPlanForWeek);

  Athlete icuSendFollowedNewActivity(bool? icuSendFollowedNewActivity);

  Athlete icuSendCoachedNewActivity(bool? icuSendCoachedNewActivity);

  Athlete icuSendCoachTick(bool? icuSendCoachTick);

  Athlete stravaAllowed(bool? stravaAllowed);

  Athlete stravaId(int? stravaId);

  Athlete scope(String? scope);

  Athlete stravaSyncActivities(bool? stravaSyncActivities);

  Athlete stravaSyncActivityTypes(
    List<AthleteStravaSyncActivityTypesEnum>? stravaSyncActivityTypes,
  );

  Athlete stravaSyncOtherActivities(bool? stravaSyncOtherActivities);

  Athlete ignoreStravaGear(bool? ignoreStravaGear);

  Athlete updateStravaName(bool? updateStravaName);

  Athlete addWeatherToStravaDescr(bool? addWeatherToStravaDescr);

  Athlete height(double? height);

  Athlete heightUnits(AthleteHeightUnitsEnum? heightUnits);

  Athlete plan(AthletePlanEnum? plan);

  Athlete planExpires(DateTime? planExpires);

  Athlete trialEndDate(DateTime? trialEndDate);

  Athlete sponsoredByChatId(int? sponsoredByChatId);

  Athlete hasPassword(bool? hasPassword);

  Athlete betaUser(bool? betaUser);

  Athlete currency(String? currency);

  Athlete trainingPlanId(int? trainingPlanId);

  Athlete trainingPlanStartDate(String? trainingPlanStartDate);

  Athlete trainingAvailability(
    List<AthleteTrainingAvailability>? trainingAvailability,
  );

  Athlete stravaAuthorized(bool? stravaAuthorized);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Athlete(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Athlete(...).copyWith(id: 12, name: "My name")
  /// ````
  Athlete call({
    String? id,
    String? name,
    String? firstname,
    String? lastname,
    String? profileMedium,
    String? measurementPreference,
    bool? weightPrefLb,
    bool? fahrenheit,
    AthleteWindSpeedEnum? windSpeed,
    AthleteRainEnum? rain,
    double? weight,
    String? email,
    String? sex,
    String? city,
    String? state,
    String? country,
    List<String>? countries,
    List<String>? languages,
    List<StravaGear>? bikes,
    List<StravaGear>? shoes,
    String? timezone,
    String? locale,
    String? dateFormat,
    String? timeFormat,
    AthleteVisibilityEnum? visibility,
    DateTime? icuLastSeen,
    AthleteStatusEnum? status,
    DateTime? statusUpdated,
    int? icuRestingHr,
    double? icuWeight,
    AthleteIcuWeightSyncEnum? icuWeightSync,
    DateTime? icuActivated,
    int? icuQueuePos,
    bool? icuAdmin,
    String? icuFriendInviteToken,
    AthleteIcuPermissionEnum? icuPermission,
    List<int>? icuEffortSecs,
    bool? icuCoach,
    String? bio,
    String? website,
    String? icuDateOfBirth,
    String? icuApiKey,
    List<Settings>? icuTypeSettings,
    bool? icuFormAsPercent,
    int? icuMmpDays,
    bool? icuWellnessPrompt,
    String? wellnessLastPromptDate,
    List<String>? icuWellnessKeys,
    List<String>? privateWellnessKeys,
    bool? icuTrackMenstrualCycle,
    AthleteIcuMenstrualCyclePermEnum? icuMenstrualCyclePerm,
    bool? activityRpePrompt,
    List<CoachTick>? coachTicks,
    bool? icuGarminHealth,
    bool? icuGarminTraining,
    bool? icuGarminSyncActivities,
    List<AthleteGarminSyncActivityTypesEnum>? garminSyncActivityTypes,
    DateTime? garminSyncAfter,
    bool? icuGarminDownloadWellness,
    bool? icuGarminUploadWorkouts,
    double? icuGarminOutdoorPowerRange,
    double? icuGarminHrRange,
    double? garminPaceRange,
    AthleteGarminPowerTargetEnum? garminPowerTarget,
    DateTime? icuGarminLastUpload,
    List<ActivityFilter>? icuGarminUploadFilters,
    List<String>? icuGarminWellnessKeys,
    int? openStepDuration,
    String? polarScope,
    bool? polarSyncActivities,
    List<AthletePolarSyncActivityTypesEnum>? polarSyncActivityTypes,
    bool? polarDownloadWellness,
    List<String>? polarWellnessKeys,
    String? suuntoScope,
    String? suuntoUserId,
    bool? suuntoSyncActivities,
    List<AthleteSuuntoSyncActivityTypesEnum>? suuntoSyncActivityTypes,
    bool? suuntoUploadWorkouts,
    double? suuntoOutdoorPowerRange,
    double? suuntoHrRange,
    double? suuntoPaceRange,
    DateTime? suuntoLastUpload,
    List<ActivityFilter>? suuntoUploadFilters,
    bool? suuntoDownloadWellness,
    String? corosUserId,
    bool? corosSyncActivities,
    bool? corosUploadWorkouts,
    bool? corosDownloadWellness,
    DateTime? corosLastUpload,
    String? concept2UserId,
    bool? concept2SyncActivities,
    String? zeppUserId,
    bool? zeppSyncActivities,
    bool? zeppUploadWorkouts,
    bool? zeppDownloadWellness,
    String? huaweiUserId,
    bool? huaweiSyncActivities,
    bool? huaweiUploadWorkouts,
    bool? huaweiDownloadWellness,
    String? wahooUserId,
    bool? wahooSyncActivities,
    bool? wahooUploadWorkouts,
    String? zwiftUserId,
    bool? zwiftSyncActivities,
    bool? zwiftUploadWorkouts,
    String? dropboxScope,
    String? ouraScope,
    List<String>? ouraWellnessKeys,
    String? whoopScope,
    List<String>? whoopWellnessKeys,
    String? googleScope,
    List<String>? googleWellnessKeys,
    bool? icuEmailVerified,
    String? icuEmailDisabled,
    List<AthleteEmailNotificationsEnum>? emailNotifications,
    List<AthletePushNotificationsEnum>? pushNotifications,
    List<String>? notificationAthleteTagsEnabled,
    bool? hasPushSubscriptions,
    bool? includeDescrInPlanForWeek,
    bool? icuSendAchievements,
    bool? icuSendNewsletter,
    bool? icuSendPrivateChat,
    bool? icuSendPrivateMsg,
    bool? icuSendFollowReq,
    bool? icuSendGroupChat,
    bool? icuSendGroupMsg,
    bool? icuSendActivityChat,
    bool? icuSendFollowedActivityChat,
    bool? icuSendCoachedActivityChat,
    bool? icuSendActivityMsg,
    bool? icuSendCoachMeReq,
    bool? icuSendGearAlerts,
    bool? icuSendPlanForWeek,
    bool? icuSendFollowedNewActivity,
    bool? icuSendCoachedNewActivity,
    bool? icuSendCoachTick,
    bool? stravaAllowed,
    int? stravaId,
    String? scope,
    bool? stravaSyncActivities,
    List<AthleteStravaSyncActivityTypesEnum>? stravaSyncActivityTypes,
    bool? stravaSyncOtherActivities,
    bool? ignoreStravaGear,
    bool? updateStravaName,
    bool? addWeatherToStravaDescr,
    double? height,
    AthleteHeightUnitsEnum? heightUnits,
    AthletePlanEnum? plan,
    DateTime? planExpires,
    DateTime? trialEndDate,
    int? sponsoredByChatId,
    bool? hasPassword,
    bool? betaUser,
    String? currency,
    int? trainingPlanId,
    String? trainingPlanStartDate,
    List<AthleteTrainingAvailability>? trainingAvailability,
    bool? stravaAuthorized,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthlete.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthlete.copyWith.fieldName(...)`
class _$AthleteCWProxyImpl implements _$AthleteCWProxy {
  const _$AthleteCWProxyImpl(this._value);

  final Athlete _value;

  @override
  Athlete id(String? id) => this(id: id);

  @override
  Athlete name(String? name) => this(name: name);

  @override
  Athlete firstname(String? firstname) => this(firstname: firstname);

  @override
  Athlete lastname(String? lastname) => this(lastname: lastname);

  @override
  Athlete profileMedium(String? profileMedium) =>
      this(profileMedium: profileMedium);

  @override
  Athlete measurementPreference(String? measurementPreference) =>
      this(measurementPreference: measurementPreference);

  @override
  Athlete weightPrefLb(bool? weightPrefLb) => this(weightPrefLb: weightPrefLb);

  @override
  Athlete fahrenheit(bool? fahrenheit) => this(fahrenheit: fahrenheit);

  @override
  Athlete windSpeed(AthleteWindSpeedEnum? windSpeed) =>
      this(windSpeed: windSpeed);

  @override
  Athlete rain(AthleteRainEnum? rain) => this(rain: rain);

  @override
  Athlete weight(double? weight) => this(weight: weight);

  @override
  Athlete email(String? email) => this(email: email);

  @override
  Athlete sex(String? sex) => this(sex: sex);

  @override
  Athlete city(String? city) => this(city: city);

  @override
  Athlete state(String? state) => this(state: state);

  @override
  Athlete country(String? country) => this(country: country);

  @override
  Athlete countries(List<String>? countries) => this(countries: countries);

  @override
  Athlete languages(List<String>? languages) => this(languages: languages);

  @override
  Athlete bikes(List<StravaGear>? bikes) => this(bikes: bikes);

  @override
  Athlete shoes(List<StravaGear>? shoes) => this(shoes: shoes);

  @override
  Athlete timezone(String? timezone) => this(timezone: timezone);

  @override
  Athlete locale(String? locale) => this(locale: locale);

  @override
  Athlete dateFormat(String? dateFormat) => this(dateFormat: dateFormat);

  @override
  Athlete timeFormat(String? timeFormat) => this(timeFormat: timeFormat);

  @override
  Athlete visibility(AthleteVisibilityEnum? visibility) =>
      this(visibility: visibility);

  @override
  Athlete icuLastSeen(DateTime? icuLastSeen) => this(icuLastSeen: icuLastSeen);

  @override
  Athlete status(AthleteStatusEnum? status) => this(status: status);

  @override
  Athlete statusUpdated(DateTime? statusUpdated) =>
      this(statusUpdated: statusUpdated);

  @override
  Athlete icuRestingHr(int? icuRestingHr) => this(icuRestingHr: icuRestingHr);

  @override
  Athlete icuWeight(double? icuWeight) => this(icuWeight: icuWeight);

  @override
  Athlete icuWeightSync(AthleteIcuWeightSyncEnum? icuWeightSync) =>
      this(icuWeightSync: icuWeightSync);

  @override
  Athlete icuActivated(DateTime? icuActivated) =>
      this(icuActivated: icuActivated);

  @override
  Athlete icuQueuePos(int? icuQueuePos) => this(icuQueuePos: icuQueuePos);

  @override
  Athlete icuAdmin(bool? icuAdmin) => this(icuAdmin: icuAdmin);

  @override
  Athlete icuFriendInviteToken(String? icuFriendInviteToken) =>
      this(icuFriendInviteToken: icuFriendInviteToken);

  @override
  Athlete icuPermission(AthleteIcuPermissionEnum? icuPermission) =>
      this(icuPermission: icuPermission);

  @override
  Athlete icuEffortSecs(List<int>? icuEffortSecs) =>
      this(icuEffortSecs: icuEffortSecs);

  @override
  Athlete icuCoach(bool? icuCoach) => this(icuCoach: icuCoach);

  @override
  Athlete bio(String? bio) => this(bio: bio);

  @override
  Athlete website(String? website) => this(website: website);

  @override
  Athlete icuDateOfBirth(String? icuDateOfBirth) =>
      this(icuDateOfBirth: icuDateOfBirth);

  @override
  Athlete icuApiKey(String? icuApiKey) => this(icuApiKey: icuApiKey);

  @override
  Athlete icuTypeSettings(List<Settings>? icuTypeSettings) =>
      this(icuTypeSettings: icuTypeSettings);

  @override
  Athlete icuFormAsPercent(bool? icuFormAsPercent) =>
      this(icuFormAsPercent: icuFormAsPercent);

  @override
  Athlete icuMmpDays(int? icuMmpDays) => this(icuMmpDays: icuMmpDays);

  @override
  Athlete icuWellnessPrompt(bool? icuWellnessPrompt) =>
      this(icuWellnessPrompt: icuWellnessPrompt);

  @override
  Athlete wellnessLastPromptDate(String? wellnessLastPromptDate) =>
      this(wellnessLastPromptDate: wellnessLastPromptDate);

  @override
  Athlete icuWellnessKeys(List<String>? icuWellnessKeys) =>
      this(icuWellnessKeys: icuWellnessKeys);

  @override
  Athlete privateWellnessKeys(List<String>? privateWellnessKeys) =>
      this(privateWellnessKeys: privateWellnessKeys);

  @override
  Athlete icuTrackMenstrualCycle(bool? icuTrackMenstrualCycle) =>
      this(icuTrackMenstrualCycle: icuTrackMenstrualCycle);

  @override
  Athlete icuMenstrualCyclePerm(
    AthleteIcuMenstrualCyclePermEnum? icuMenstrualCyclePerm,
  ) => this(icuMenstrualCyclePerm: icuMenstrualCyclePerm);

  @override
  Athlete activityRpePrompt(bool? activityRpePrompt) =>
      this(activityRpePrompt: activityRpePrompt);

  @override
  Athlete coachTicks(List<CoachTick>? coachTicks) =>
      this(coachTicks: coachTicks);

  @override
  Athlete icuGarminHealth(bool? icuGarminHealth) =>
      this(icuGarminHealth: icuGarminHealth);

  @override
  Athlete icuGarminTraining(bool? icuGarminTraining) =>
      this(icuGarminTraining: icuGarminTraining);

  @override
  Athlete icuGarminSyncActivities(bool? icuGarminSyncActivities) =>
      this(icuGarminSyncActivities: icuGarminSyncActivities);

  @override
  Athlete garminSyncActivityTypes(
    List<AthleteGarminSyncActivityTypesEnum>? garminSyncActivityTypes,
  ) => this(garminSyncActivityTypes: garminSyncActivityTypes);

  @override
  Athlete garminSyncAfter(DateTime? garminSyncAfter) =>
      this(garminSyncAfter: garminSyncAfter);

  @override
  Athlete icuGarminDownloadWellness(bool? icuGarminDownloadWellness) =>
      this(icuGarminDownloadWellness: icuGarminDownloadWellness);

  @override
  Athlete icuGarminUploadWorkouts(bool? icuGarminUploadWorkouts) =>
      this(icuGarminUploadWorkouts: icuGarminUploadWorkouts);

  @override
  Athlete icuGarminOutdoorPowerRange(double? icuGarminOutdoorPowerRange) =>
      this(icuGarminOutdoorPowerRange: icuGarminOutdoorPowerRange);

  @override
  Athlete icuGarminHrRange(double? icuGarminHrRange) =>
      this(icuGarminHrRange: icuGarminHrRange);

  @override
  Athlete garminPaceRange(double? garminPaceRange) =>
      this(garminPaceRange: garminPaceRange);

  @override
  Athlete garminPowerTarget(AthleteGarminPowerTargetEnum? garminPowerTarget) =>
      this(garminPowerTarget: garminPowerTarget);

  @override
  Athlete icuGarminLastUpload(DateTime? icuGarminLastUpload) =>
      this(icuGarminLastUpload: icuGarminLastUpload);

  @override
  Athlete icuGarminUploadFilters(
    List<ActivityFilter>? icuGarminUploadFilters,
  ) => this(icuGarminUploadFilters: icuGarminUploadFilters);

  @override
  Athlete icuGarminWellnessKeys(List<String>? icuGarminWellnessKeys) =>
      this(icuGarminWellnessKeys: icuGarminWellnessKeys);

  @override
  Athlete openStepDuration(int? openStepDuration) =>
      this(openStepDuration: openStepDuration);

  @override
  Athlete polarScope(String? polarScope) => this(polarScope: polarScope);

  @override
  Athlete polarSyncActivities(bool? polarSyncActivities) =>
      this(polarSyncActivities: polarSyncActivities);

  @override
  Athlete polarSyncActivityTypes(
    List<AthletePolarSyncActivityTypesEnum>? polarSyncActivityTypes,
  ) => this(polarSyncActivityTypes: polarSyncActivityTypes);

  @override
  Athlete polarDownloadWellness(bool? polarDownloadWellness) =>
      this(polarDownloadWellness: polarDownloadWellness);

  @override
  Athlete polarWellnessKeys(List<String>? polarWellnessKeys) =>
      this(polarWellnessKeys: polarWellnessKeys);

  @override
  Athlete suuntoScope(String? suuntoScope) => this(suuntoScope: suuntoScope);

  @override
  Athlete suuntoUserId(String? suuntoUserId) =>
      this(suuntoUserId: suuntoUserId);

  @override
  Athlete suuntoSyncActivities(bool? suuntoSyncActivities) =>
      this(suuntoSyncActivities: suuntoSyncActivities);

  @override
  Athlete suuntoSyncActivityTypes(
    List<AthleteSuuntoSyncActivityTypesEnum>? suuntoSyncActivityTypes,
  ) => this(suuntoSyncActivityTypes: suuntoSyncActivityTypes);

  @override
  Athlete suuntoUploadWorkouts(bool? suuntoUploadWorkouts) =>
      this(suuntoUploadWorkouts: suuntoUploadWorkouts);

  @override
  Athlete suuntoOutdoorPowerRange(double? suuntoOutdoorPowerRange) =>
      this(suuntoOutdoorPowerRange: suuntoOutdoorPowerRange);

  @override
  Athlete suuntoHrRange(double? suuntoHrRange) =>
      this(suuntoHrRange: suuntoHrRange);

  @override
  Athlete suuntoPaceRange(double? suuntoPaceRange) =>
      this(suuntoPaceRange: suuntoPaceRange);

  @override
  Athlete suuntoLastUpload(DateTime? suuntoLastUpload) =>
      this(suuntoLastUpload: suuntoLastUpload);

  @override
  Athlete suuntoUploadFilters(List<ActivityFilter>? suuntoUploadFilters) =>
      this(suuntoUploadFilters: suuntoUploadFilters);

  @override
  Athlete suuntoDownloadWellness(bool? suuntoDownloadWellness) =>
      this(suuntoDownloadWellness: suuntoDownloadWellness);

  @override
  Athlete corosUserId(String? corosUserId) => this(corosUserId: corosUserId);

  @override
  Athlete corosSyncActivities(bool? corosSyncActivities) =>
      this(corosSyncActivities: corosSyncActivities);

  @override
  Athlete corosUploadWorkouts(bool? corosUploadWorkouts) =>
      this(corosUploadWorkouts: corosUploadWorkouts);

  @override
  Athlete corosDownloadWellness(bool? corosDownloadWellness) =>
      this(corosDownloadWellness: corosDownloadWellness);

  @override
  Athlete corosLastUpload(DateTime? corosLastUpload) =>
      this(corosLastUpload: corosLastUpload);

  @override
  Athlete concept2UserId(String? concept2UserId) =>
      this(concept2UserId: concept2UserId);

  @override
  Athlete concept2SyncActivities(bool? concept2SyncActivities) =>
      this(concept2SyncActivities: concept2SyncActivities);

  @override
  Athlete zeppUserId(String? zeppUserId) => this(zeppUserId: zeppUserId);

  @override
  Athlete zeppSyncActivities(bool? zeppSyncActivities) =>
      this(zeppSyncActivities: zeppSyncActivities);

  @override
  Athlete zeppUploadWorkouts(bool? zeppUploadWorkouts) =>
      this(zeppUploadWorkouts: zeppUploadWorkouts);

  @override
  Athlete zeppDownloadWellness(bool? zeppDownloadWellness) =>
      this(zeppDownloadWellness: zeppDownloadWellness);

  @override
  Athlete huaweiUserId(String? huaweiUserId) =>
      this(huaweiUserId: huaweiUserId);

  @override
  Athlete huaweiSyncActivities(bool? huaweiSyncActivities) =>
      this(huaweiSyncActivities: huaweiSyncActivities);

  @override
  Athlete huaweiUploadWorkouts(bool? huaweiUploadWorkouts) =>
      this(huaweiUploadWorkouts: huaweiUploadWorkouts);

  @override
  Athlete huaweiDownloadWellness(bool? huaweiDownloadWellness) =>
      this(huaweiDownloadWellness: huaweiDownloadWellness);

  @override
  Athlete wahooUserId(String? wahooUserId) => this(wahooUserId: wahooUserId);

  @override
  Athlete wahooSyncActivities(bool? wahooSyncActivities) =>
      this(wahooSyncActivities: wahooSyncActivities);

  @override
  Athlete wahooUploadWorkouts(bool? wahooUploadWorkouts) =>
      this(wahooUploadWorkouts: wahooUploadWorkouts);

  @override
  Athlete zwiftUserId(String? zwiftUserId) => this(zwiftUserId: zwiftUserId);

  @override
  Athlete zwiftSyncActivities(bool? zwiftSyncActivities) =>
      this(zwiftSyncActivities: zwiftSyncActivities);

  @override
  Athlete zwiftUploadWorkouts(bool? zwiftUploadWorkouts) =>
      this(zwiftUploadWorkouts: zwiftUploadWorkouts);

  @override
  Athlete dropboxScope(String? dropboxScope) =>
      this(dropboxScope: dropboxScope);

  @override
  Athlete ouraScope(String? ouraScope) => this(ouraScope: ouraScope);

  @override
  Athlete ouraWellnessKeys(List<String>? ouraWellnessKeys) =>
      this(ouraWellnessKeys: ouraWellnessKeys);

  @override
  Athlete whoopScope(String? whoopScope) => this(whoopScope: whoopScope);

  @override
  Athlete whoopWellnessKeys(List<String>? whoopWellnessKeys) =>
      this(whoopWellnessKeys: whoopWellnessKeys);

  @override
  Athlete googleScope(String? googleScope) => this(googleScope: googleScope);

  @override
  Athlete googleWellnessKeys(List<String>? googleWellnessKeys) =>
      this(googleWellnessKeys: googleWellnessKeys);

  @override
  Athlete icuEmailVerified(bool? icuEmailVerified) =>
      this(icuEmailVerified: icuEmailVerified);

  @override
  Athlete icuEmailDisabled(String? icuEmailDisabled) =>
      this(icuEmailDisabled: icuEmailDisabled);

  @override
  Athlete emailNotifications(
    List<AthleteEmailNotificationsEnum>? emailNotifications,
  ) => this(emailNotifications: emailNotifications);

  @override
  Athlete pushNotifications(
    List<AthletePushNotificationsEnum>? pushNotifications,
  ) => this(pushNotifications: pushNotifications);

  @override
  Athlete notificationAthleteTagsEnabled(
    List<String>? notificationAthleteTagsEnabled,
  ) => this(notificationAthleteTagsEnabled: notificationAthleteTagsEnabled);

  @override
  Athlete hasPushSubscriptions(bool? hasPushSubscriptions) =>
      this(hasPushSubscriptions: hasPushSubscriptions);

  @override
  Athlete includeDescrInPlanForWeek(bool? includeDescrInPlanForWeek) =>
      this(includeDescrInPlanForWeek: includeDescrInPlanForWeek);

  @override
  Athlete icuSendAchievements(bool? icuSendAchievements) =>
      this(icuSendAchievements: icuSendAchievements);

  @override
  Athlete icuSendNewsletter(bool? icuSendNewsletter) =>
      this(icuSendNewsletter: icuSendNewsletter);

  @override
  Athlete icuSendPrivateChat(bool? icuSendPrivateChat) =>
      this(icuSendPrivateChat: icuSendPrivateChat);

  @override
  Athlete icuSendPrivateMsg(bool? icuSendPrivateMsg) =>
      this(icuSendPrivateMsg: icuSendPrivateMsg);

  @override
  Athlete icuSendFollowReq(bool? icuSendFollowReq) =>
      this(icuSendFollowReq: icuSendFollowReq);

  @override
  Athlete icuSendGroupChat(bool? icuSendGroupChat) =>
      this(icuSendGroupChat: icuSendGroupChat);

  @override
  Athlete icuSendGroupMsg(bool? icuSendGroupMsg) =>
      this(icuSendGroupMsg: icuSendGroupMsg);

  @override
  Athlete icuSendActivityChat(bool? icuSendActivityChat) =>
      this(icuSendActivityChat: icuSendActivityChat);

  @override
  Athlete icuSendFollowedActivityChat(bool? icuSendFollowedActivityChat) =>
      this(icuSendFollowedActivityChat: icuSendFollowedActivityChat);

  @override
  Athlete icuSendCoachedActivityChat(bool? icuSendCoachedActivityChat) =>
      this(icuSendCoachedActivityChat: icuSendCoachedActivityChat);

  @override
  Athlete icuSendActivityMsg(bool? icuSendActivityMsg) =>
      this(icuSendActivityMsg: icuSendActivityMsg);

  @override
  Athlete icuSendCoachMeReq(bool? icuSendCoachMeReq) =>
      this(icuSendCoachMeReq: icuSendCoachMeReq);

  @override
  Athlete icuSendGearAlerts(bool? icuSendGearAlerts) =>
      this(icuSendGearAlerts: icuSendGearAlerts);

  @override
  Athlete icuSendPlanForWeek(bool? icuSendPlanForWeek) =>
      this(icuSendPlanForWeek: icuSendPlanForWeek);

  @override
  Athlete icuSendFollowedNewActivity(bool? icuSendFollowedNewActivity) =>
      this(icuSendFollowedNewActivity: icuSendFollowedNewActivity);

  @override
  Athlete icuSendCoachedNewActivity(bool? icuSendCoachedNewActivity) =>
      this(icuSendCoachedNewActivity: icuSendCoachedNewActivity);

  @override
  Athlete icuSendCoachTick(bool? icuSendCoachTick) =>
      this(icuSendCoachTick: icuSendCoachTick);

  @override
  Athlete stravaAllowed(bool? stravaAllowed) =>
      this(stravaAllowed: stravaAllowed);

  @override
  Athlete stravaId(int? stravaId) => this(stravaId: stravaId);

  @override
  Athlete scope(String? scope) => this(scope: scope);

  @override
  Athlete stravaSyncActivities(bool? stravaSyncActivities) =>
      this(stravaSyncActivities: stravaSyncActivities);

  @override
  Athlete stravaSyncActivityTypes(
    List<AthleteStravaSyncActivityTypesEnum>? stravaSyncActivityTypes,
  ) => this(stravaSyncActivityTypes: stravaSyncActivityTypes);

  @override
  Athlete stravaSyncOtherActivities(bool? stravaSyncOtherActivities) =>
      this(stravaSyncOtherActivities: stravaSyncOtherActivities);

  @override
  Athlete ignoreStravaGear(bool? ignoreStravaGear) =>
      this(ignoreStravaGear: ignoreStravaGear);

  @override
  Athlete updateStravaName(bool? updateStravaName) =>
      this(updateStravaName: updateStravaName);

  @override
  Athlete addWeatherToStravaDescr(bool? addWeatherToStravaDescr) =>
      this(addWeatherToStravaDescr: addWeatherToStravaDescr);

  @override
  Athlete height(double? height) => this(height: height);

  @override
  Athlete heightUnits(AthleteHeightUnitsEnum? heightUnits) =>
      this(heightUnits: heightUnits);

  @override
  Athlete plan(AthletePlanEnum? plan) => this(plan: plan);

  @override
  Athlete planExpires(DateTime? planExpires) => this(planExpires: planExpires);

  @override
  Athlete trialEndDate(DateTime? trialEndDate) =>
      this(trialEndDate: trialEndDate);

  @override
  Athlete sponsoredByChatId(int? sponsoredByChatId) =>
      this(sponsoredByChatId: sponsoredByChatId);

  @override
  Athlete hasPassword(bool? hasPassword) => this(hasPassword: hasPassword);

  @override
  Athlete betaUser(bool? betaUser) => this(betaUser: betaUser);

  @override
  Athlete currency(String? currency) => this(currency: currency);

  @override
  Athlete trainingPlanId(int? trainingPlanId) =>
      this(trainingPlanId: trainingPlanId);

  @override
  Athlete trainingPlanStartDate(String? trainingPlanStartDate) =>
      this(trainingPlanStartDate: trainingPlanStartDate);

  @override
  Athlete trainingAvailability(
    List<AthleteTrainingAvailability>? trainingAvailability,
  ) => this(trainingAvailability: trainingAvailability);

  @override
  Athlete stravaAuthorized(bool? stravaAuthorized) =>
      this(stravaAuthorized: stravaAuthorized);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Athlete(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Athlete(...).copyWith(id: 12, name: "My name")
  /// ````
  Athlete call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? firstname = const $CopyWithPlaceholder(),
    Object? lastname = const $CopyWithPlaceholder(),
    Object? profileMedium = const $CopyWithPlaceholder(),
    Object? measurementPreference = const $CopyWithPlaceholder(),
    Object? weightPrefLb = const $CopyWithPlaceholder(),
    Object? fahrenheit = const $CopyWithPlaceholder(),
    Object? windSpeed = const $CopyWithPlaceholder(),
    Object? rain = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? city = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? country = const $CopyWithPlaceholder(),
    Object? countries = const $CopyWithPlaceholder(),
    Object? languages = const $CopyWithPlaceholder(),
    Object? bikes = const $CopyWithPlaceholder(),
    Object? shoes = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? locale = const $CopyWithPlaceholder(),
    Object? dateFormat = const $CopyWithPlaceholder(),
    Object? timeFormat = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? icuLastSeen = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? statusUpdated = const $CopyWithPlaceholder(),
    Object? icuRestingHr = const $CopyWithPlaceholder(),
    Object? icuWeight = const $CopyWithPlaceholder(),
    Object? icuWeightSync = const $CopyWithPlaceholder(),
    Object? icuActivated = const $CopyWithPlaceholder(),
    Object? icuQueuePos = const $CopyWithPlaceholder(),
    Object? icuAdmin = const $CopyWithPlaceholder(),
    Object? icuFriendInviteToken = const $CopyWithPlaceholder(),
    Object? icuPermission = const $CopyWithPlaceholder(),
    Object? icuEffortSecs = const $CopyWithPlaceholder(),
    Object? icuCoach = const $CopyWithPlaceholder(),
    Object? bio = const $CopyWithPlaceholder(),
    Object? website = const $CopyWithPlaceholder(),
    Object? icuDateOfBirth = const $CopyWithPlaceholder(),
    Object? icuApiKey = const $CopyWithPlaceholder(),
    Object? icuTypeSettings = const $CopyWithPlaceholder(),
    Object? icuFormAsPercent = const $CopyWithPlaceholder(),
    Object? icuMmpDays = const $CopyWithPlaceholder(),
    Object? icuWellnessPrompt = const $CopyWithPlaceholder(),
    Object? wellnessLastPromptDate = const $CopyWithPlaceholder(),
    Object? icuWellnessKeys = const $CopyWithPlaceholder(),
    Object? privateWellnessKeys = const $CopyWithPlaceholder(),
    Object? icuTrackMenstrualCycle = const $CopyWithPlaceholder(),
    Object? icuMenstrualCyclePerm = const $CopyWithPlaceholder(),
    Object? activityRpePrompt = const $CopyWithPlaceholder(),
    Object? coachTicks = const $CopyWithPlaceholder(),
    Object? icuGarminHealth = const $CopyWithPlaceholder(),
    Object? icuGarminTraining = const $CopyWithPlaceholder(),
    Object? icuGarminSyncActivities = const $CopyWithPlaceholder(),
    Object? garminSyncActivityTypes = const $CopyWithPlaceholder(),
    Object? garminSyncAfter = const $CopyWithPlaceholder(),
    Object? icuGarminDownloadWellness = const $CopyWithPlaceholder(),
    Object? icuGarminUploadWorkouts = const $CopyWithPlaceholder(),
    Object? icuGarminOutdoorPowerRange = const $CopyWithPlaceholder(),
    Object? icuGarminHrRange = const $CopyWithPlaceholder(),
    Object? garminPaceRange = const $CopyWithPlaceholder(),
    Object? garminPowerTarget = const $CopyWithPlaceholder(),
    Object? icuGarminLastUpload = const $CopyWithPlaceholder(),
    Object? icuGarminUploadFilters = const $CopyWithPlaceholder(),
    Object? icuGarminWellnessKeys = const $CopyWithPlaceholder(),
    Object? openStepDuration = const $CopyWithPlaceholder(),
    Object? polarScope = const $CopyWithPlaceholder(),
    Object? polarSyncActivities = const $CopyWithPlaceholder(),
    Object? polarSyncActivityTypes = const $CopyWithPlaceholder(),
    Object? polarDownloadWellness = const $CopyWithPlaceholder(),
    Object? polarWellnessKeys = const $CopyWithPlaceholder(),
    Object? suuntoScope = const $CopyWithPlaceholder(),
    Object? suuntoUserId = const $CopyWithPlaceholder(),
    Object? suuntoSyncActivities = const $CopyWithPlaceholder(),
    Object? suuntoSyncActivityTypes = const $CopyWithPlaceholder(),
    Object? suuntoUploadWorkouts = const $CopyWithPlaceholder(),
    Object? suuntoOutdoorPowerRange = const $CopyWithPlaceholder(),
    Object? suuntoHrRange = const $CopyWithPlaceholder(),
    Object? suuntoPaceRange = const $CopyWithPlaceholder(),
    Object? suuntoLastUpload = const $CopyWithPlaceholder(),
    Object? suuntoUploadFilters = const $CopyWithPlaceholder(),
    Object? suuntoDownloadWellness = const $CopyWithPlaceholder(),
    Object? corosUserId = const $CopyWithPlaceholder(),
    Object? corosSyncActivities = const $CopyWithPlaceholder(),
    Object? corosUploadWorkouts = const $CopyWithPlaceholder(),
    Object? corosDownloadWellness = const $CopyWithPlaceholder(),
    Object? corosLastUpload = const $CopyWithPlaceholder(),
    Object? concept2UserId = const $CopyWithPlaceholder(),
    Object? concept2SyncActivities = const $CopyWithPlaceholder(),
    Object? zeppUserId = const $CopyWithPlaceholder(),
    Object? zeppSyncActivities = const $CopyWithPlaceholder(),
    Object? zeppUploadWorkouts = const $CopyWithPlaceholder(),
    Object? zeppDownloadWellness = const $CopyWithPlaceholder(),
    Object? huaweiUserId = const $CopyWithPlaceholder(),
    Object? huaweiSyncActivities = const $CopyWithPlaceholder(),
    Object? huaweiUploadWorkouts = const $CopyWithPlaceholder(),
    Object? huaweiDownloadWellness = const $CopyWithPlaceholder(),
    Object? wahooUserId = const $CopyWithPlaceholder(),
    Object? wahooSyncActivities = const $CopyWithPlaceholder(),
    Object? wahooUploadWorkouts = const $CopyWithPlaceholder(),
    Object? zwiftUserId = const $CopyWithPlaceholder(),
    Object? zwiftSyncActivities = const $CopyWithPlaceholder(),
    Object? zwiftUploadWorkouts = const $CopyWithPlaceholder(),
    Object? dropboxScope = const $CopyWithPlaceholder(),
    Object? ouraScope = const $CopyWithPlaceholder(),
    Object? ouraWellnessKeys = const $CopyWithPlaceholder(),
    Object? whoopScope = const $CopyWithPlaceholder(),
    Object? whoopWellnessKeys = const $CopyWithPlaceholder(),
    Object? googleScope = const $CopyWithPlaceholder(),
    Object? googleWellnessKeys = const $CopyWithPlaceholder(),
    Object? icuEmailVerified = const $CopyWithPlaceholder(),
    Object? icuEmailDisabled = const $CopyWithPlaceholder(),
    Object? emailNotifications = const $CopyWithPlaceholder(),
    Object? pushNotifications = const $CopyWithPlaceholder(),
    Object? notificationAthleteTagsEnabled = const $CopyWithPlaceholder(),
    Object? hasPushSubscriptions = const $CopyWithPlaceholder(),
    Object? includeDescrInPlanForWeek = const $CopyWithPlaceholder(),
    Object? icuSendAchievements = const $CopyWithPlaceholder(),
    Object? icuSendNewsletter = const $CopyWithPlaceholder(),
    Object? icuSendPrivateChat = const $CopyWithPlaceholder(),
    Object? icuSendPrivateMsg = const $CopyWithPlaceholder(),
    Object? icuSendFollowReq = const $CopyWithPlaceholder(),
    Object? icuSendGroupChat = const $CopyWithPlaceholder(),
    Object? icuSendGroupMsg = const $CopyWithPlaceholder(),
    Object? icuSendActivityChat = const $CopyWithPlaceholder(),
    Object? icuSendFollowedActivityChat = const $CopyWithPlaceholder(),
    Object? icuSendCoachedActivityChat = const $CopyWithPlaceholder(),
    Object? icuSendActivityMsg = const $CopyWithPlaceholder(),
    Object? icuSendCoachMeReq = const $CopyWithPlaceholder(),
    Object? icuSendGearAlerts = const $CopyWithPlaceholder(),
    Object? icuSendPlanForWeek = const $CopyWithPlaceholder(),
    Object? icuSendFollowedNewActivity = const $CopyWithPlaceholder(),
    Object? icuSendCoachedNewActivity = const $CopyWithPlaceholder(),
    Object? icuSendCoachTick = const $CopyWithPlaceholder(),
    Object? stravaAllowed = const $CopyWithPlaceholder(),
    Object? stravaId = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? stravaSyncActivities = const $CopyWithPlaceholder(),
    Object? stravaSyncActivityTypes = const $CopyWithPlaceholder(),
    Object? stravaSyncOtherActivities = const $CopyWithPlaceholder(),
    Object? ignoreStravaGear = const $CopyWithPlaceholder(),
    Object? updateStravaName = const $CopyWithPlaceholder(),
    Object? addWeatherToStravaDescr = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
    Object? heightUnits = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? planExpires = const $CopyWithPlaceholder(),
    Object? trialEndDate = const $CopyWithPlaceholder(),
    Object? sponsoredByChatId = const $CopyWithPlaceholder(),
    Object? hasPassword = const $CopyWithPlaceholder(),
    Object? betaUser = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? trainingPlanId = const $CopyWithPlaceholder(),
    Object? trainingPlanStartDate = const $CopyWithPlaceholder(),
    Object? trainingAvailability = const $CopyWithPlaceholder(),
    Object? stravaAuthorized = const $CopyWithPlaceholder(),
  }) {
    return Athlete(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      firstname: firstname == const $CopyWithPlaceholder()
          ? _value.firstname
          // ignore: cast_nullable_to_non_nullable
          : firstname as String?,
      lastname: lastname == const $CopyWithPlaceholder()
          ? _value.lastname
          // ignore: cast_nullable_to_non_nullable
          : lastname as String?,
      profileMedium: profileMedium == const $CopyWithPlaceholder()
          ? _value.profileMedium
          // ignore: cast_nullable_to_non_nullable
          : profileMedium as String?,
      measurementPreference:
          measurementPreference == const $CopyWithPlaceholder()
          ? _value.measurementPreference
          // ignore: cast_nullable_to_non_nullable
          : measurementPreference as String?,
      weightPrefLb: weightPrefLb == const $CopyWithPlaceholder()
          ? _value.weightPrefLb
          // ignore: cast_nullable_to_non_nullable
          : weightPrefLb as bool?,
      fahrenheit: fahrenheit == const $CopyWithPlaceholder()
          ? _value.fahrenheit
          // ignore: cast_nullable_to_non_nullable
          : fahrenheit as bool?,
      windSpeed: windSpeed == const $CopyWithPlaceholder()
          ? _value.windSpeed
          // ignore: cast_nullable_to_non_nullable
          : windSpeed as AthleteWindSpeedEnum?,
      rain: rain == const $CopyWithPlaceholder()
          ? _value.rain
          // ignore: cast_nullable_to_non_nullable
          : rain as AthleteRainEnum?,
      weight: weight == const $CopyWithPlaceholder()
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as String?,
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String?,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String?,
      country: country == const $CopyWithPlaceholder()
          ? _value.country
          // ignore: cast_nullable_to_non_nullable
          : country as String?,
      countries: countries == const $CopyWithPlaceholder()
          ? _value.countries
          // ignore: cast_nullable_to_non_nullable
          : countries as List<String>?,
      languages: languages == const $CopyWithPlaceholder()
          ? _value.languages
          // ignore: cast_nullable_to_non_nullable
          : languages as List<String>?,
      bikes: bikes == const $CopyWithPlaceholder()
          ? _value.bikes
          // ignore: cast_nullable_to_non_nullable
          : bikes as List<StravaGear>?,
      shoes: shoes == const $CopyWithPlaceholder()
          ? _value.shoes
          // ignore: cast_nullable_to_non_nullable
          : shoes as List<StravaGear>?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      locale: locale == const $CopyWithPlaceholder()
          ? _value.locale
          // ignore: cast_nullable_to_non_nullable
          : locale as String?,
      dateFormat: dateFormat == const $CopyWithPlaceholder()
          ? _value.dateFormat
          // ignore: cast_nullable_to_non_nullable
          : dateFormat as String?,
      timeFormat: timeFormat == const $CopyWithPlaceholder()
          ? _value.timeFormat
          // ignore: cast_nullable_to_non_nullable
          : timeFormat as String?,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as AthleteVisibilityEnum?,
      icuLastSeen: icuLastSeen == const $CopyWithPlaceholder()
          ? _value.icuLastSeen
          // ignore: cast_nullable_to_non_nullable
          : icuLastSeen as DateTime?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AthleteStatusEnum?,
      statusUpdated: statusUpdated == const $CopyWithPlaceholder()
          ? _value.statusUpdated
          // ignore: cast_nullable_to_non_nullable
          : statusUpdated as DateTime?,
      icuRestingHr: icuRestingHr == const $CopyWithPlaceholder()
          ? _value.icuRestingHr
          // ignore: cast_nullable_to_non_nullable
          : icuRestingHr as int?,
      icuWeight: icuWeight == const $CopyWithPlaceholder()
          ? _value.icuWeight
          // ignore: cast_nullable_to_non_nullable
          : icuWeight as double?,
      icuWeightSync: icuWeightSync == const $CopyWithPlaceholder()
          ? _value.icuWeightSync
          // ignore: cast_nullable_to_non_nullable
          : icuWeightSync as AthleteIcuWeightSyncEnum?,
      icuActivated: icuActivated == const $CopyWithPlaceholder()
          ? _value.icuActivated
          // ignore: cast_nullable_to_non_nullable
          : icuActivated as DateTime?,
      icuQueuePos: icuQueuePos == const $CopyWithPlaceholder()
          ? _value.icuQueuePos
          // ignore: cast_nullable_to_non_nullable
          : icuQueuePos as int?,
      icuAdmin: icuAdmin == const $CopyWithPlaceholder()
          ? _value.icuAdmin
          // ignore: cast_nullable_to_non_nullable
          : icuAdmin as bool?,
      icuFriendInviteToken: icuFriendInviteToken == const $CopyWithPlaceholder()
          ? _value.icuFriendInviteToken
          // ignore: cast_nullable_to_non_nullable
          : icuFriendInviteToken as String?,
      icuPermission: icuPermission == const $CopyWithPlaceholder()
          ? _value.icuPermission
          // ignore: cast_nullable_to_non_nullable
          : icuPermission as AthleteIcuPermissionEnum?,
      icuEffortSecs: icuEffortSecs == const $CopyWithPlaceholder()
          ? _value.icuEffortSecs
          // ignore: cast_nullable_to_non_nullable
          : icuEffortSecs as List<int>?,
      icuCoach: icuCoach == const $CopyWithPlaceholder()
          ? _value.icuCoach
          // ignore: cast_nullable_to_non_nullable
          : icuCoach as bool?,
      bio: bio == const $CopyWithPlaceholder()
          ? _value.bio
          // ignore: cast_nullable_to_non_nullable
          : bio as String?,
      website: website == const $CopyWithPlaceholder()
          ? _value.website
          // ignore: cast_nullable_to_non_nullable
          : website as String?,
      icuDateOfBirth: icuDateOfBirth == const $CopyWithPlaceholder()
          ? _value.icuDateOfBirth
          // ignore: cast_nullable_to_non_nullable
          : icuDateOfBirth as String?,
      icuApiKey: icuApiKey == const $CopyWithPlaceholder()
          ? _value.icuApiKey
          // ignore: cast_nullable_to_non_nullable
          : icuApiKey as String?,
      icuTypeSettings: icuTypeSettings == const $CopyWithPlaceholder()
          ? _value.icuTypeSettings
          // ignore: cast_nullable_to_non_nullable
          : icuTypeSettings as List<Settings>?,
      icuFormAsPercent: icuFormAsPercent == const $CopyWithPlaceholder()
          ? _value.icuFormAsPercent
          // ignore: cast_nullable_to_non_nullable
          : icuFormAsPercent as bool?,
      icuMmpDays: icuMmpDays == const $CopyWithPlaceholder()
          ? _value.icuMmpDays
          // ignore: cast_nullable_to_non_nullable
          : icuMmpDays as int?,
      icuWellnessPrompt: icuWellnessPrompt == const $CopyWithPlaceholder()
          ? _value.icuWellnessPrompt
          // ignore: cast_nullable_to_non_nullable
          : icuWellnessPrompt as bool?,
      wellnessLastPromptDate:
          wellnessLastPromptDate == const $CopyWithPlaceholder()
          ? _value.wellnessLastPromptDate
          // ignore: cast_nullable_to_non_nullable
          : wellnessLastPromptDate as String?,
      icuWellnessKeys: icuWellnessKeys == const $CopyWithPlaceholder()
          ? _value.icuWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : icuWellnessKeys as List<String>?,
      privateWellnessKeys: privateWellnessKeys == const $CopyWithPlaceholder()
          ? _value.privateWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : privateWellnessKeys as List<String>?,
      icuTrackMenstrualCycle:
          icuTrackMenstrualCycle == const $CopyWithPlaceholder()
          ? _value.icuTrackMenstrualCycle
          // ignore: cast_nullable_to_non_nullable
          : icuTrackMenstrualCycle as bool?,
      icuMenstrualCyclePerm:
          icuMenstrualCyclePerm == const $CopyWithPlaceholder()
          ? _value.icuMenstrualCyclePerm
          // ignore: cast_nullable_to_non_nullable
          : icuMenstrualCyclePerm as AthleteIcuMenstrualCyclePermEnum?,
      activityRpePrompt: activityRpePrompt == const $CopyWithPlaceholder()
          ? _value.activityRpePrompt
          // ignore: cast_nullable_to_non_nullable
          : activityRpePrompt as bool?,
      coachTicks: coachTicks == const $CopyWithPlaceholder()
          ? _value.coachTicks
          // ignore: cast_nullable_to_non_nullable
          : coachTicks as List<CoachTick>?,
      icuGarminHealth: icuGarminHealth == const $CopyWithPlaceholder()
          ? _value.icuGarminHealth
          // ignore: cast_nullable_to_non_nullable
          : icuGarminHealth as bool?,
      icuGarminTraining: icuGarminTraining == const $CopyWithPlaceholder()
          ? _value.icuGarminTraining
          // ignore: cast_nullable_to_non_nullable
          : icuGarminTraining as bool?,
      icuGarminSyncActivities:
          icuGarminSyncActivities == const $CopyWithPlaceholder()
          ? _value.icuGarminSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : icuGarminSyncActivities as bool?,
      garminSyncActivityTypes:
          garminSyncActivityTypes == const $CopyWithPlaceholder()
          ? _value.garminSyncActivityTypes
          // ignore: cast_nullable_to_non_nullable
          : garminSyncActivityTypes
                as List<AthleteGarminSyncActivityTypesEnum>?,
      garminSyncAfter: garminSyncAfter == const $CopyWithPlaceholder()
          ? _value.garminSyncAfter
          // ignore: cast_nullable_to_non_nullable
          : garminSyncAfter as DateTime?,
      icuGarminDownloadWellness:
          icuGarminDownloadWellness == const $CopyWithPlaceholder()
          ? _value.icuGarminDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : icuGarminDownloadWellness as bool?,
      icuGarminUploadWorkouts:
          icuGarminUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.icuGarminUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : icuGarminUploadWorkouts as bool?,
      icuGarminOutdoorPowerRange:
          icuGarminOutdoorPowerRange == const $CopyWithPlaceholder()
          ? _value.icuGarminOutdoorPowerRange
          // ignore: cast_nullable_to_non_nullable
          : icuGarminOutdoorPowerRange as double?,
      icuGarminHrRange: icuGarminHrRange == const $CopyWithPlaceholder()
          ? _value.icuGarminHrRange
          // ignore: cast_nullable_to_non_nullable
          : icuGarminHrRange as double?,
      garminPaceRange: garminPaceRange == const $CopyWithPlaceholder()
          ? _value.garminPaceRange
          // ignore: cast_nullable_to_non_nullable
          : garminPaceRange as double?,
      garminPowerTarget: garminPowerTarget == const $CopyWithPlaceholder()
          ? _value.garminPowerTarget
          // ignore: cast_nullable_to_non_nullable
          : garminPowerTarget as AthleteGarminPowerTargetEnum?,
      icuGarminLastUpload: icuGarminLastUpload == const $CopyWithPlaceholder()
          ? _value.icuGarminLastUpload
          // ignore: cast_nullable_to_non_nullable
          : icuGarminLastUpload as DateTime?,
      icuGarminUploadFilters:
          icuGarminUploadFilters == const $CopyWithPlaceholder()
          ? _value.icuGarminUploadFilters
          // ignore: cast_nullable_to_non_nullable
          : icuGarminUploadFilters as List<ActivityFilter>?,
      icuGarminWellnessKeys:
          icuGarminWellnessKeys == const $CopyWithPlaceholder()
          ? _value.icuGarminWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : icuGarminWellnessKeys as List<String>?,
      openStepDuration: openStepDuration == const $CopyWithPlaceholder()
          ? _value.openStepDuration
          // ignore: cast_nullable_to_non_nullable
          : openStepDuration as int?,
      polarScope: polarScope == const $CopyWithPlaceholder()
          ? _value.polarScope
          // ignore: cast_nullable_to_non_nullable
          : polarScope as String?,
      polarSyncActivities: polarSyncActivities == const $CopyWithPlaceholder()
          ? _value.polarSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : polarSyncActivities as bool?,
      polarSyncActivityTypes:
          polarSyncActivityTypes == const $CopyWithPlaceholder()
          ? _value.polarSyncActivityTypes
          // ignore: cast_nullable_to_non_nullable
          : polarSyncActivityTypes as List<AthletePolarSyncActivityTypesEnum>?,
      polarDownloadWellness:
          polarDownloadWellness == const $CopyWithPlaceholder()
          ? _value.polarDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : polarDownloadWellness as bool?,
      polarWellnessKeys: polarWellnessKeys == const $CopyWithPlaceholder()
          ? _value.polarWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : polarWellnessKeys as List<String>?,
      suuntoScope: suuntoScope == const $CopyWithPlaceholder()
          ? _value.suuntoScope
          // ignore: cast_nullable_to_non_nullable
          : suuntoScope as String?,
      suuntoUserId: suuntoUserId == const $CopyWithPlaceholder()
          ? _value.suuntoUserId
          // ignore: cast_nullable_to_non_nullable
          : suuntoUserId as String?,
      suuntoSyncActivities: suuntoSyncActivities == const $CopyWithPlaceholder()
          ? _value.suuntoSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : suuntoSyncActivities as bool?,
      suuntoSyncActivityTypes:
          suuntoSyncActivityTypes == const $CopyWithPlaceholder()
          ? _value.suuntoSyncActivityTypes
          // ignore: cast_nullable_to_non_nullable
          : suuntoSyncActivityTypes
                as List<AthleteSuuntoSyncActivityTypesEnum>?,
      suuntoUploadWorkouts: suuntoUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.suuntoUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : suuntoUploadWorkouts as bool?,
      suuntoOutdoorPowerRange:
          suuntoOutdoorPowerRange == const $CopyWithPlaceholder()
          ? _value.suuntoOutdoorPowerRange
          // ignore: cast_nullable_to_non_nullable
          : suuntoOutdoorPowerRange as double?,
      suuntoHrRange: suuntoHrRange == const $CopyWithPlaceholder()
          ? _value.suuntoHrRange
          // ignore: cast_nullable_to_non_nullable
          : suuntoHrRange as double?,
      suuntoPaceRange: suuntoPaceRange == const $CopyWithPlaceholder()
          ? _value.suuntoPaceRange
          // ignore: cast_nullable_to_non_nullable
          : suuntoPaceRange as double?,
      suuntoLastUpload: suuntoLastUpload == const $CopyWithPlaceholder()
          ? _value.suuntoLastUpload
          // ignore: cast_nullable_to_non_nullable
          : suuntoLastUpload as DateTime?,
      suuntoUploadFilters: suuntoUploadFilters == const $CopyWithPlaceholder()
          ? _value.suuntoUploadFilters
          // ignore: cast_nullable_to_non_nullable
          : suuntoUploadFilters as List<ActivityFilter>?,
      suuntoDownloadWellness:
          suuntoDownloadWellness == const $CopyWithPlaceholder()
          ? _value.suuntoDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : suuntoDownloadWellness as bool?,
      corosUserId: corosUserId == const $CopyWithPlaceholder()
          ? _value.corosUserId
          // ignore: cast_nullable_to_non_nullable
          : corosUserId as String?,
      corosSyncActivities: corosSyncActivities == const $CopyWithPlaceholder()
          ? _value.corosSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : corosSyncActivities as bool?,
      corosUploadWorkouts: corosUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.corosUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : corosUploadWorkouts as bool?,
      corosDownloadWellness:
          corosDownloadWellness == const $CopyWithPlaceholder()
          ? _value.corosDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : corosDownloadWellness as bool?,
      corosLastUpload: corosLastUpload == const $CopyWithPlaceholder()
          ? _value.corosLastUpload
          // ignore: cast_nullable_to_non_nullable
          : corosLastUpload as DateTime?,
      concept2UserId: concept2UserId == const $CopyWithPlaceholder()
          ? _value.concept2UserId
          // ignore: cast_nullable_to_non_nullable
          : concept2UserId as String?,
      concept2SyncActivities:
          concept2SyncActivities == const $CopyWithPlaceholder()
          ? _value.concept2SyncActivities
          // ignore: cast_nullable_to_non_nullable
          : concept2SyncActivities as bool?,
      zeppUserId: zeppUserId == const $CopyWithPlaceholder()
          ? _value.zeppUserId
          // ignore: cast_nullable_to_non_nullable
          : zeppUserId as String?,
      zeppSyncActivities: zeppSyncActivities == const $CopyWithPlaceholder()
          ? _value.zeppSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : zeppSyncActivities as bool?,
      zeppUploadWorkouts: zeppUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.zeppUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : zeppUploadWorkouts as bool?,
      zeppDownloadWellness: zeppDownloadWellness == const $CopyWithPlaceholder()
          ? _value.zeppDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : zeppDownloadWellness as bool?,
      huaweiUserId: huaweiUserId == const $CopyWithPlaceholder()
          ? _value.huaweiUserId
          // ignore: cast_nullable_to_non_nullable
          : huaweiUserId as String?,
      huaweiSyncActivities: huaweiSyncActivities == const $CopyWithPlaceholder()
          ? _value.huaweiSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : huaweiSyncActivities as bool?,
      huaweiUploadWorkouts: huaweiUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.huaweiUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : huaweiUploadWorkouts as bool?,
      huaweiDownloadWellness:
          huaweiDownloadWellness == const $CopyWithPlaceholder()
          ? _value.huaweiDownloadWellness
          // ignore: cast_nullable_to_non_nullable
          : huaweiDownloadWellness as bool?,
      wahooUserId: wahooUserId == const $CopyWithPlaceholder()
          ? _value.wahooUserId
          // ignore: cast_nullable_to_non_nullable
          : wahooUserId as String?,
      wahooSyncActivities: wahooSyncActivities == const $CopyWithPlaceholder()
          ? _value.wahooSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : wahooSyncActivities as bool?,
      wahooUploadWorkouts: wahooUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.wahooUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : wahooUploadWorkouts as bool?,
      zwiftUserId: zwiftUserId == const $CopyWithPlaceholder()
          ? _value.zwiftUserId
          // ignore: cast_nullable_to_non_nullable
          : zwiftUserId as String?,
      zwiftSyncActivities: zwiftSyncActivities == const $CopyWithPlaceholder()
          ? _value.zwiftSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : zwiftSyncActivities as bool?,
      zwiftUploadWorkouts: zwiftUploadWorkouts == const $CopyWithPlaceholder()
          ? _value.zwiftUploadWorkouts
          // ignore: cast_nullable_to_non_nullable
          : zwiftUploadWorkouts as bool?,
      dropboxScope: dropboxScope == const $CopyWithPlaceholder()
          ? _value.dropboxScope
          // ignore: cast_nullable_to_non_nullable
          : dropboxScope as String?,
      ouraScope: ouraScope == const $CopyWithPlaceholder()
          ? _value.ouraScope
          // ignore: cast_nullable_to_non_nullable
          : ouraScope as String?,
      ouraWellnessKeys: ouraWellnessKeys == const $CopyWithPlaceholder()
          ? _value.ouraWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : ouraWellnessKeys as List<String>?,
      whoopScope: whoopScope == const $CopyWithPlaceholder()
          ? _value.whoopScope
          // ignore: cast_nullable_to_non_nullable
          : whoopScope as String?,
      whoopWellnessKeys: whoopWellnessKeys == const $CopyWithPlaceholder()
          ? _value.whoopWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : whoopWellnessKeys as List<String>?,
      googleScope: googleScope == const $CopyWithPlaceholder()
          ? _value.googleScope
          // ignore: cast_nullable_to_non_nullable
          : googleScope as String?,
      googleWellnessKeys: googleWellnessKeys == const $CopyWithPlaceholder()
          ? _value.googleWellnessKeys
          // ignore: cast_nullable_to_non_nullable
          : googleWellnessKeys as List<String>?,
      icuEmailVerified: icuEmailVerified == const $CopyWithPlaceholder()
          ? _value.icuEmailVerified
          // ignore: cast_nullable_to_non_nullable
          : icuEmailVerified as bool?,
      icuEmailDisabled: icuEmailDisabled == const $CopyWithPlaceholder()
          ? _value.icuEmailDisabled
          // ignore: cast_nullable_to_non_nullable
          : icuEmailDisabled as String?,
      emailNotifications: emailNotifications == const $CopyWithPlaceholder()
          ? _value.emailNotifications
          // ignore: cast_nullable_to_non_nullable
          : emailNotifications as List<AthleteEmailNotificationsEnum>?,
      pushNotifications: pushNotifications == const $CopyWithPlaceholder()
          ? _value.pushNotifications
          // ignore: cast_nullable_to_non_nullable
          : pushNotifications as List<AthletePushNotificationsEnum>?,
      notificationAthleteTagsEnabled:
          notificationAthleteTagsEnabled == const $CopyWithPlaceholder()
          ? _value.notificationAthleteTagsEnabled
          // ignore: cast_nullable_to_non_nullable
          : notificationAthleteTagsEnabled as List<String>?,
      hasPushSubscriptions: hasPushSubscriptions == const $CopyWithPlaceholder()
          ? _value.hasPushSubscriptions
          // ignore: cast_nullable_to_non_nullable
          : hasPushSubscriptions as bool?,
      includeDescrInPlanForWeek:
          includeDescrInPlanForWeek == const $CopyWithPlaceholder()
          ? _value.includeDescrInPlanForWeek
          // ignore: cast_nullable_to_non_nullable
          : includeDescrInPlanForWeek as bool?,
      icuSendAchievements: icuSendAchievements == const $CopyWithPlaceholder()
          ? _value.icuSendAchievements
          // ignore: cast_nullable_to_non_nullable
          : icuSendAchievements as bool?,
      icuSendNewsletter: icuSendNewsletter == const $CopyWithPlaceholder()
          ? _value.icuSendNewsletter
          // ignore: cast_nullable_to_non_nullable
          : icuSendNewsletter as bool?,
      icuSendPrivateChat: icuSendPrivateChat == const $CopyWithPlaceholder()
          ? _value.icuSendPrivateChat
          // ignore: cast_nullable_to_non_nullable
          : icuSendPrivateChat as bool?,
      icuSendPrivateMsg: icuSendPrivateMsg == const $CopyWithPlaceholder()
          ? _value.icuSendPrivateMsg
          // ignore: cast_nullable_to_non_nullable
          : icuSendPrivateMsg as bool?,
      icuSendFollowReq: icuSendFollowReq == const $CopyWithPlaceholder()
          ? _value.icuSendFollowReq
          // ignore: cast_nullable_to_non_nullable
          : icuSendFollowReq as bool?,
      icuSendGroupChat: icuSendGroupChat == const $CopyWithPlaceholder()
          ? _value.icuSendGroupChat
          // ignore: cast_nullable_to_non_nullable
          : icuSendGroupChat as bool?,
      icuSendGroupMsg: icuSendGroupMsg == const $CopyWithPlaceholder()
          ? _value.icuSendGroupMsg
          // ignore: cast_nullable_to_non_nullable
          : icuSendGroupMsg as bool?,
      icuSendActivityChat: icuSendActivityChat == const $CopyWithPlaceholder()
          ? _value.icuSendActivityChat
          // ignore: cast_nullable_to_non_nullable
          : icuSendActivityChat as bool?,
      icuSendFollowedActivityChat:
          icuSendFollowedActivityChat == const $CopyWithPlaceholder()
          ? _value.icuSendFollowedActivityChat
          // ignore: cast_nullable_to_non_nullable
          : icuSendFollowedActivityChat as bool?,
      icuSendCoachedActivityChat:
          icuSendCoachedActivityChat == const $CopyWithPlaceholder()
          ? _value.icuSendCoachedActivityChat
          // ignore: cast_nullable_to_non_nullable
          : icuSendCoachedActivityChat as bool?,
      icuSendActivityMsg: icuSendActivityMsg == const $CopyWithPlaceholder()
          ? _value.icuSendActivityMsg
          // ignore: cast_nullable_to_non_nullable
          : icuSendActivityMsg as bool?,
      icuSendCoachMeReq: icuSendCoachMeReq == const $CopyWithPlaceholder()
          ? _value.icuSendCoachMeReq
          // ignore: cast_nullable_to_non_nullable
          : icuSendCoachMeReq as bool?,
      icuSendGearAlerts: icuSendGearAlerts == const $CopyWithPlaceholder()
          ? _value.icuSendGearAlerts
          // ignore: cast_nullable_to_non_nullable
          : icuSendGearAlerts as bool?,
      icuSendPlanForWeek: icuSendPlanForWeek == const $CopyWithPlaceholder()
          ? _value.icuSendPlanForWeek
          // ignore: cast_nullable_to_non_nullable
          : icuSendPlanForWeek as bool?,
      icuSendFollowedNewActivity:
          icuSendFollowedNewActivity == const $CopyWithPlaceholder()
          ? _value.icuSendFollowedNewActivity
          // ignore: cast_nullable_to_non_nullable
          : icuSendFollowedNewActivity as bool?,
      icuSendCoachedNewActivity:
          icuSendCoachedNewActivity == const $CopyWithPlaceholder()
          ? _value.icuSendCoachedNewActivity
          // ignore: cast_nullable_to_non_nullable
          : icuSendCoachedNewActivity as bool?,
      icuSendCoachTick: icuSendCoachTick == const $CopyWithPlaceholder()
          ? _value.icuSendCoachTick
          // ignore: cast_nullable_to_non_nullable
          : icuSendCoachTick as bool?,
      stravaAllowed: stravaAllowed == const $CopyWithPlaceholder()
          ? _value.stravaAllowed
          // ignore: cast_nullable_to_non_nullable
          : stravaAllowed as bool?,
      stravaId: stravaId == const $CopyWithPlaceholder()
          ? _value.stravaId
          // ignore: cast_nullable_to_non_nullable
          : stravaId as int?,
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as String?,
      stravaSyncActivities: stravaSyncActivities == const $CopyWithPlaceholder()
          ? _value.stravaSyncActivities
          // ignore: cast_nullable_to_non_nullable
          : stravaSyncActivities as bool?,
      stravaSyncActivityTypes:
          stravaSyncActivityTypes == const $CopyWithPlaceholder()
          ? _value.stravaSyncActivityTypes
          // ignore: cast_nullable_to_non_nullable
          : stravaSyncActivityTypes
                as List<AthleteStravaSyncActivityTypesEnum>?,
      stravaSyncOtherActivities:
          stravaSyncOtherActivities == const $CopyWithPlaceholder()
          ? _value.stravaSyncOtherActivities
          // ignore: cast_nullable_to_non_nullable
          : stravaSyncOtherActivities as bool?,
      ignoreStravaGear: ignoreStravaGear == const $CopyWithPlaceholder()
          ? _value.ignoreStravaGear
          // ignore: cast_nullable_to_non_nullable
          : ignoreStravaGear as bool?,
      updateStravaName: updateStravaName == const $CopyWithPlaceholder()
          ? _value.updateStravaName
          // ignore: cast_nullable_to_non_nullable
          : updateStravaName as bool?,
      addWeatherToStravaDescr:
          addWeatherToStravaDescr == const $CopyWithPlaceholder()
          ? _value.addWeatherToStravaDescr
          // ignore: cast_nullable_to_non_nullable
          : addWeatherToStravaDescr as bool?,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as double?,
      heightUnits: heightUnits == const $CopyWithPlaceholder()
          ? _value.heightUnits
          // ignore: cast_nullable_to_non_nullable
          : heightUnits as AthleteHeightUnitsEnum?,
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as AthletePlanEnum?,
      planExpires: planExpires == const $CopyWithPlaceholder()
          ? _value.planExpires
          // ignore: cast_nullable_to_non_nullable
          : planExpires as DateTime?,
      trialEndDate: trialEndDate == const $CopyWithPlaceholder()
          ? _value.trialEndDate
          // ignore: cast_nullable_to_non_nullable
          : trialEndDate as DateTime?,
      sponsoredByChatId: sponsoredByChatId == const $CopyWithPlaceholder()
          ? _value.sponsoredByChatId
          // ignore: cast_nullable_to_non_nullable
          : sponsoredByChatId as int?,
      hasPassword: hasPassword == const $CopyWithPlaceholder()
          ? _value.hasPassword
          // ignore: cast_nullable_to_non_nullable
          : hasPassword as bool?,
      betaUser: betaUser == const $CopyWithPlaceholder()
          ? _value.betaUser
          // ignore: cast_nullable_to_non_nullable
          : betaUser as bool?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      trainingPlanId: trainingPlanId == const $CopyWithPlaceholder()
          ? _value.trainingPlanId
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanId as int?,
      trainingPlanStartDate:
          trainingPlanStartDate == const $CopyWithPlaceholder()
          ? _value.trainingPlanStartDate
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanStartDate as String?,
      trainingAvailability: trainingAvailability == const $CopyWithPlaceholder()
          ? _value.trainingAvailability
          // ignore: cast_nullable_to_non_nullable
          : trainingAvailability as List<AthleteTrainingAvailability>?,
      stravaAuthorized: stravaAuthorized == const $CopyWithPlaceholder()
          ? _value.stravaAuthorized
          // ignore: cast_nullable_to_non_nullable
          : stravaAuthorized as bool?,
    );
  }
}

extension $AthleteCopyWith on Athlete {
  /// Returns a callable class that can be used as follows: `instanceOfAthlete.copyWith(...)` or like so:`instanceOfAthlete.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteCWProxy get copyWith => _$AthleteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Athlete _$AthleteFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Athlete',
  json,
  ($checkedConvert) {
    final val = Athlete(
      id: $checkedConvert('id', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      firstname: $checkedConvert('firstname', (v) => v as String?),
      lastname: $checkedConvert('lastname', (v) => v as String?),
      profileMedium: $checkedConvert('profile_medium', (v) => v as String?),
      measurementPreference: $checkedConvert(
        'measurement_preference',
        (v) => v as String?,
      ),
      weightPrefLb: $checkedConvert('weight_pref_lb', (v) => v as bool?),
      fahrenheit: $checkedConvert('fahrenheit', (v) => v as bool?),
      windSpeed: $checkedConvert(
        'wind_speed',
        (v) => $enumDecodeNullable(_$AthleteWindSpeedEnumEnumMap, v),
      ),
      rain: $checkedConvert(
        'rain',
        (v) => $enumDecodeNullable(_$AthleteRainEnumEnumMap, v),
      ),
      weight: $checkedConvert('weight', (v) => (v as num?)?.toDouble()),
      email: $checkedConvert('email', (v) => v as String?),
      sex: $checkedConvert('sex', (v) => v as String?),
      city: $checkedConvert('city', (v) => v as String?),
      state: $checkedConvert('state', (v) => v as String?),
      country: $checkedConvert('country', (v) => v as String?),
      countries: $checkedConvert(
        'countries',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      languages: $checkedConvert(
        'languages',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      bikes: $checkedConvert(
        'bikes',
        (v) => (v as List<dynamic>?)
            ?.map((e) => StravaGear.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      shoes: $checkedConvert(
        'shoes',
        (v) => (v as List<dynamic>?)
            ?.map((e) => StravaGear.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String?),
      locale: $checkedConvert('locale', (v) => v as String?),
      dateFormat: $checkedConvert('date_format', (v) => v as String?),
      timeFormat: $checkedConvert('time_format', (v) => v as String?),
      visibility: $checkedConvert(
        'visibility',
        (v) => $enumDecodeNullable(_$AthleteVisibilityEnumEnumMap, v),
      ),
      icuLastSeen: $checkedConvert(
        'icu_last_seen',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$AthleteStatusEnumEnumMap, v),
      ),
      statusUpdated: $checkedConvert(
        'status_updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuRestingHr: $checkedConvert(
        'icu_resting_hr',
        (v) => (v as num?)?.toInt(),
      ),
      icuWeight: $checkedConvert('icu_weight', (v) => (v as num?)?.toDouble()),
      icuWeightSync: $checkedConvert(
        'icu_weight_sync',
        (v) => $enumDecodeNullable(_$AthleteIcuWeightSyncEnumEnumMap, v),
      ),
      icuActivated: $checkedConvert(
        'icu_activated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuQueuePos: $checkedConvert(
        'icu_queue_pos',
        (v) => (v as num?)?.toInt(),
      ),
      icuAdmin: $checkedConvert('icu_admin', (v) => v as bool?),
      icuFriendInviteToken: $checkedConvert(
        'icu_friend_invite_token',
        (v) => v as String?,
      ),
      icuPermission: $checkedConvert(
        'icu_permission',
        (v) => $enumDecodeNullable(_$AthleteIcuPermissionEnumEnumMap, v),
      ),
      icuEffortSecs: $checkedConvert(
        'icu_effort_secs',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      icuCoach: $checkedConvert('icu_coach', (v) => v as bool?),
      bio: $checkedConvert('bio', (v) => v as String?),
      website: $checkedConvert('website', (v) => v as String?),
      icuDateOfBirth: $checkedConvert('icu_date_of_birth', (v) => v as String?),
      icuApiKey: $checkedConvert('icu_api_key', (v) => v as String?),
      icuTypeSettings: $checkedConvert(
        'icu_type_settings',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Settings.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuFormAsPercent: $checkedConvert(
        'icu_form_as_percent',
        (v) => v as bool?,
      ),
      icuMmpDays: $checkedConvert('icu_mmp_days', (v) => (v as num?)?.toInt()),
      icuWellnessPrompt: $checkedConvert(
        'icu_wellness_prompt',
        (v) => v as bool?,
      ),
      wellnessLastPromptDate: $checkedConvert(
        'wellness_last_prompt_date',
        (v) => v as String?,
      ),
      icuWellnessKeys: $checkedConvert(
        'icu_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      privateWellnessKeys: $checkedConvert(
        'private_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      icuTrackMenstrualCycle: $checkedConvert(
        'icu_track_menstrual_cycle',
        (v) => v as bool?,
      ),
      icuMenstrualCyclePerm: $checkedConvert(
        'icu_menstrual_cycle_perm',
        (v) =>
            $enumDecodeNullable(_$AthleteIcuMenstrualCyclePermEnumEnumMap, v),
      ),
      activityRpePrompt: $checkedConvert(
        'activity_rpe_prompt',
        (v) => v as bool?,
      ),
      coachTicks: $checkedConvert(
        'coach_ticks',
        (v) => (v as List<dynamic>?)
            ?.map((e) => CoachTick.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuGarminHealth: $checkedConvert('icu_garmin_health', (v) => v as bool?),
      icuGarminTraining: $checkedConvert(
        'icu_garmin_training',
        (v) => v as bool?,
      ),
      icuGarminSyncActivities: $checkedConvert(
        'icu_garmin_sync_activities',
        (v) => v as bool?,
      ),
      garminSyncActivityTypes: $checkedConvert(
        'garmin_sync_activity_types',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) =>
                  $enumDecode(_$AthleteGarminSyncActivityTypesEnumEnumMap, e),
            )
            .toList(),
      ),
      garminSyncAfter: $checkedConvert(
        'garmin_sync_after',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuGarminDownloadWellness: $checkedConvert(
        'icu_garmin_download_wellness',
        (v) => v as bool?,
      ),
      icuGarminUploadWorkouts: $checkedConvert(
        'icu_garmin_upload_workouts',
        (v) => v as bool?,
      ),
      icuGarminOutdoorPowerRange: $checkedConvert(
        'icu_garmin_outdoor_power_range',
        (v) => (v as num?)?.toDouble(),
      ),
      icuGarminHrRange: $checkedConvert(
        'icu_garmin_hr_range',
        (v) => (v as num?)?.toDouble(),
      ),
      garminPaceRange: $checkedConvert(
        'garmin_pace_range',
        (v) => (v as num?)?.toDouble(),
      ),
      garminPowerTarget: $checkedConvert(
        'garmin_power_target',
        (v) => $enumDecodeNullable(_$AthleteGarminPowerTargetEnumEnumMap, v),
      ),
      icuGarminLastUpload: $checkedConvert(
        'icu_garmin_last_upload',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuGarminUploadFilters: $checkedConvert(
        'icu_garmin_upload_filters',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ActivityFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuGarminWellnessKeys: $checkedConvert(
        'icu_garmin_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      openStepDuration: $checkedConvert(
        'open_step_duration',
        (v) => (v as num?)?.toInt(),
      ),
      polarScope: $checkedConvert('polar_scope', (v) => v as String?),
      polarSyncActivities: $checkedConvert(
        'polar_sync_activities',
        (v) => v as bool?,
      ),
      polarSyncActivityTypes: $checkedConvert(
        'polar_sync_activity_types',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => $enumDecode(_$AthletePolarSyncActivityTypesEnumEnumMap, e),
            )
            .toList(),
      ),
      polarDownloadWellness: $checkedConvert(
        'polar_download_wellness',
        (v) => v as bool?,
      ),
      polarWellnessKeys: $checkedConvert(
        'polar_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      suuntoScope: $checkedConvert('suunto_scope', (v) => v as String?),
      suuntoUserId: $checkedConvert('suunto_user_id', (v) => v as String?),
      suuntoSyncActivities: $checkedConvert(
        'suunto_sync_activities',
        (v) => v as bool?,
      ),
      suuntoSyncActivityTypes: $checkedConvert(
        'suunto_sync_activity_types',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) =>
                  $enumDecode(_$AthleteSuuntoSyncActivityTypesEnumEnumMap, e),
            )
            .toList(),
      ),
      suuntoUploadWorkouts: $checkedConvert(
        'suunto_upload_workouts',
        (v) => v as bool?,
      ),
      suuntoOutdoorPowerRange: $checkedConvert(
        'suunto_outdoor_power_range',
        (v) => (v as num?)?.toDouble(),
      ),
      suuntoHrRange: $checkedConvert(
        'suunto_hr_range',
        (v) => (v as num?)?.toDouble(),
      ),
      suuntoPaceRange: $checkedConvert(
        'suunto_pace_range',
        (v) => (v as num?)?.toDouble(),
      ),
      suuntoLastUpload: $checkedConvert(
        'suunto_last_upload',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      suuntoUploadFilters: $checkedConvert(
        'suunto_upload_filters',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ActivityFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      suuntoDownloadWellness: $checkedConvert(
        'suunto_download_wellness',
        (v) => v as bool?,
      ),
      corosUserId: $checkedConvert('coros_user_id', (v) => v as String?),
      corosSyncActivities: $checkedConvert(
        'coros_sync_activities',
        (v) => v as bool?,
      ),
      corosUploadWorkouts: $checkedConvert(
        'coros_upload_workouts',
        (v) => v as bool?,
      ),
      corosDownloadWellness: $checkedConvert(
        'coros_download_wellness',
        (v) => v as bool?,
      ),
      corosLastUpload: $checkedConvert(
        'coros_last_upload',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      concept2UserId: $checkedConvert('concept2_user_id', (v) => v as String?),
      concept2SyncActivities: $checkedConvert(
        'concept2_sync_activities',
        (v) => v as bool?,
      ),
      zeppUserId: $checkedConvert('zepp_user_id', (v) => v as String?),
      zeppSyncActivities: $checkedConvert(
        'zepp_sync_activities',
        (v) => v as bool?,
      ),
      zeppUploadWorkouts: $checkedConvert(
        'zepp_upload_workouts',
        (v) => v as bool?,
      ),
      zeppDownloadWellness: $checkedConvert(
        'zepp_download_wellness',
        (v) => v as bool?,
      ),
      huaweiUserId: $checkedConvert('huawei_user_id', (v) => v as String?),
      huaweiSyncActivities: $checkedConvert(
        'huawei_sync_activities',
        (v) => v as bool?,
      ),
      huaweiUploadWorkouts: $checkedConvert(
        'huawei_upload_workouts',
        (v) => v as bool?,
      ),
      huaweiDownloadWellness: $checkedConvert(
        'huawei_download_wellness',
        (v) => v as bool?,
      ),
      wahooUserId: $checkedConvert('wahoo_user_id', (v) => v as String?),
      wahooSyncActivities: $checkedConvert(
        'wahoo_sync_activities',
        (v) => v as bool?,
      ),
      wahooUploadWorkouts: $checkedConvert(
        'wahoo_upload_workouts',
        (v) => v as bool?,
      ),
      zwiftUserId: $checkedConvert('zwift_user_id', (v) => v as String?),
      zwiftSyncActivities: $checkedConvert(
        'zwift_sync_activities',
        (v) => v as bool?,
      ),
      zwiftUploadWorkouts: $checkedConvert(
        'zwift_upload_workouts',
        (v) => v as bool?,
      ),
      dropboxScope: $checkedConvert('dropbox_scope', (v) => v as String?),
      ouraScope: $checkedConvert('oura_scope', (v) => v as String?),
      ouraWellnessKeys: $checkedConvert(
        'oura_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      whoopScope: $checkedConvert('whoop_scope', (v) => v as String?),
      whoopWellnessKeys: $checkedConvert(
        'whoop_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      googleScope: $checkedConvert('google_scope', (v) => v as String?),
      googleWellnessKeys: $checkedConvert(
        'google_wellness_keys',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      icuEmailVerified: $checkedConvert(
        'icu_email_verified',
        (v) => v as bool?,
      ),
      icuEmailDisabled: $checkedConvert(
        'icu_email_disabled',
        (v) => v as String?,
      ),
      emailNotifications: $checkedConvert(
        'email_notifications',
        (v) => (v as List<dynamic>?)
            ?.map((e) => $enumDecode(_$AthleteEmailNotificationsEnumEnumMap, e))
            .toList(),
      ),
      pushNotifications: $checkedConvert(
        'push_notifications',
        (v) => (v as List<dynamic>?)
            ?.map((e) => $enumDecode(_$AthletePushNotificationsEnumEnumMap, e))
            .toList(),
      ),
      notificationAthleteTagsEnabled: $checkedConvert(
        'notification_athlete_tags_enabled',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      hasPushSubscriptions: $checkedConvert(
        'has_push_subscriptions',
        (v) => v as bool?,
      ),
      includeDescrInPlanForWeek: $checkedConvert(
        'include_descr_in_plan_for_week',
        (v) => v as bool?,
      ),
      icuSendAchievements: $checkedConvert(
        'icu_send_achievements',
        (v) => v as bool?,
      ),
      icuSendNewsletter: $checkedConvert(
        'icu_send_newsletter',
        (v) => v as bool?,
      ),
      icuSendPrivateChat: $checkedConvert(
        'icu_send_private_chat',
        (v) => v as bool?,
      ),
      icuSendPrivateMsg: $checkedConvert(
        'icu_send_private_msg',
        (v) => v as bool?,
      ),
      icuSendFollowReq: $checkedConvert(
        'icu_send_follow_req',
        (v) => v as bool?,
      ),
      icuSendGroupChat: $checkedConvert(
        'icu_send_group_chat',
        (v) => v as bool?,
      ),
      icuSendGroupMsg: $checkedConvert('icu_send_group_msg', (v) => v as bool?),
      icuSendActivityChat: $checkedConvert(
        'icu_send_activity_chat',
        (v) => v as bool?,
      ),
      icuSendFollowedActivityChat: $checkedConvert(
        'icu_send_followed_activity_chat',
        (v) => v as bool?,
      ),
      icuSendCoachedActivityChat: $checkedConvert(
        'icu_send_coached_activity_chat',
        (v) => v as bool?,
      ),
      icuSendActivityMsg: $checkedConvert(
        'icu_send_activity_msg',
        (v) => v as bool?,
      ),
      icuSendCoachMeReq: $checkedConvert(
        'icu_send_coach_me_req',
        (v) => v as bool?,
      ),
      icuSendGearAlerts: $checkedConvert(
        'icu_send_gear_alerts',
        (v) => v as bool?,
      ),
      icuSendPlanForWeek: $checkedConvert(
        'icu_send_plan_for_week',
        (v) => v as bool?,
      ),
      icuSendFollowedNewActivity: $checkedConvert(
        'icu_send_followed_new_activity',
        (v) => v as bool?,
      ),
      icuSendCoachedNewActivity: $checkedConvert(
        'icu_send_coached_new_activity',
        (v) => v as bool?,
      ),
      icuSendCoachTick: $checkedConvert(
        'icu_send_coach_tick',
        (v) => v as bool?,
      ),
      stravaAllowed: $checkedConvert('strava_allowed', (v) => v as bool?),
      stravaId: $checkedConvert('strava_id', (v) => (v as num?)?.toInt()),
      scope: $checkedConvert('scope', (v) => v as String?),
      stravaSyncActivities: $checkedConvert(
        'strava_sync_activities',
        (v) => v as bool?,
      ),
      stravaSyncActivityTypes: $checkedConvert(
        'strava_sync_activity_types',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) =>
                  $enumDecode(_$AthleteStravaSyncActivityTypesEnumEnumMap, e),
            )
            .toList(),
      ),
      stravaSyncOtherActivities: $checkedConvert(
        'strava_sync_other_activities',
        (v) => v as bool?,
      ),
      ignoreStravaGear: $checkedConvert(
        'ignore_strava_gear',
        (v) => v as bool?,
      ),
      updateStravaName: $checkedConvert(
        'update_strava_name',
        (v) => v as bool?,
      ),
      addWeatherToStravaDescr: $checkedConvert(
        'add_weather_to_strava_descr',
        (v) => v as bool?,
      ),
      height: $checkedConvert('height', (v) => (v as num?)?.toDouble()),
      heightUnits: $checkedConvert(
        'height_units',
        (v) => $enumDecodeNullable(_$AthleteHeightUnitsEnumEnumMap, v),
      ),
      plan: $checkedConvert(
        'plan',
        (v) => $enumDecodeNullable(_$AthletePlanEnumEnumMap, v),
      ),
      planExpires: $checkedConvert(
        'plan_expires',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      trialEndDate: $checkedConvert(
        'trial_end_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sponsoredByChatId: $checkedConvert(
        'sponsored_by_chat_id',
        (v) => (v as num?)?.toInt(),
      ),
      hasPassword: $checkedConvert('has_password', (v) => v as bool?),
      betaUser: $checkedConvert('beta_user', (v) => v as bool?),
      currency: $checkedConvert('currency', (v) => v as String?),
      trainingPlanId: $checkedConvert(
        'training_plan_id',
        (v) => (v as num?)?.toInt(),
      ),
      trainingPlanStartDate: $checkedConvert(
        'training_plan_start_date',
        (v) => v as String?,
      ),
      trainingAvailability: $checkedConvert(
        'training_availability',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => AthleteTrainingAvailability.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      stravaAuthorized: $checkedConvert('strava_authorized', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'profileMedium': 'profile_medium',
    'measurementPreference': 'measurement_preference',
    'weightPrefLb': 'weight_pref_lb',
    'windSpeed': 'wind_speed',
    'dateFormat': 'date_format',
    'timeFormat': 'time_format',
    'icuLastSeen': 'icu_last_seen',
    'statusUpdated': 'status_updated',
    'icuRestingHr': 'icu_resting_hr',
    'icuWeight': 'icu_weight',
    'icuWeightSync': 'icu_weight_sync',
    'icuActivated': 'icu_activated',
    'icuQueuePos': 'icu_queue_pos',
    'icuAdmin': 'icu_admin',
    'icuFriendInviteToken': 'icu_friend_invite_token',
    'icuPermission': 'icu_permission',
    'icuEffortSecs': 'icu_effort_secs',
    'icuCoach': 'icu_coach',
    'icuDateOfBirth': 'icu_date_of_birth',
    'icuApiKey': 'icu_api_key',
    'icuTypeSettings': 'icu_type_settings',
    'icuFormAsPercent': 'icu_form_as_percent',
    'icuMmpDays': 'icu_mmp_days',
    'icuWellnessPrompt': 'icu_wellness_prompt',
    'wellnessLastPromptDate': 'wellness_last_prompt_date',
    'icuWellnessKeys': 'icu_wellness_keys',
    'privateWellnessKeys': 'private_wellness_keys',
    'icuTrackMenstrualCycle': 'icu_track_menstrual_cycle',
    'icuMenstrualCyclePerm': 'icu_menstrual_cycle_perm',
    'activityRpePrompt': 'activity_rpe_prompt',
    'coachTicks': 'coach_ticks',
    'icuGarminHealth': 'icu_garmin_health',
    'icuGarminTraining': 'icu_garmin_training',
    'icuGarminSyncActivities': 'icu_garmin_sync_activities',
    'garminSyncActivityTypes': 'garmin_sync_activity_types',
    'garminSyncAfter': 'garmin_sync_after',
    'icuGarminDownloadWellness': 'icu_garmin_download_wellness',
    'icuGarminUploadWorkouts': 'icu_garmin_upload_workouts',
    'icuGarminOutdoorPowerRange': 'icu_garmin_outdoor_power_range',
    'icuGarminHrRange': 'icu_garmin_hr_range',
    'garminPaceRange': 'garmin_pace_range',
    'garminPowerTarget': 'garmin_power_target',
    'icuGarminLastUpload': 'icu_garmin_last_upload',
    'icuGarminUploadFilters': 'icu_garmin_upload_filters',
    'icuGarminWellnessKeys': 'icu_garmin_wellness_keys',
    'openStepDuration': 'open_step_duration',
    'polarScope': 'polar_scope',
    'polarSyncActivities': 'polar_sync_activities',
    'polarSyncActivityTypes': 'polar_sync_activity_types',
    'polarDownloadWellness': 'polar_download_wellness',
    'polarWellnessKeys': 'polar_wellness_keys',
    'suuntoScope': 'suunto_scope',
    'suuntoUserId': 'suunto_user_id',
    'suuntoSyncActivities': 'suunto_sync_activities',
    'suuntoSyncActivityTypes': 'suunto_sync_activity_types',
    'suuntoUploadWorkouts': 'suunto_upload_workouts',
    'suuntoOutdoorPowerRange': 'suunto_outdoor_power_range',
    'suuntoHrRange': 'suunto_hr_range',
    'suuntoPaceRange': 'suunto_pace_range',
    'suuntoLastUpload': 'suunto_last_upload',
    'suuntoUploadFilters': 'suunto_upload_filters',
    'suuntoDownloadWellness': 'suunto_download_wellness',
    'corosUserId': 'coros_user_id',
    'corosSyncActivities': 'coros_sync_activities',
    'corosUploadWorkouts': 'coros_upload_workouts',
    'corosDownloadWellness': 'coros_download_wellness',
    'corosLastUpload': 'coros_last_upload',
    'concept2UserId': 'concept2_user_id',
    'concept2SyncActivities': 'concept2_sync_activities',
    'zeppUserId': 'zepp_user_id',
    'zeppSyncActivities': 'zepp_sync_activities',
    'zeppUploadWorkouts': 'zepp_upload_workouts',
    'zeppDownloadWellness': 'zepp_download_wellness',
    'huaweiUserId': 'huawei_user_id',
    'huaweiSyncActivities': 'huawei_sync_activities',
    'huaweiUploadWorkouts': 'huawei_upload_workouts',
    'huaweiDownloadWellness': 'huawei_download_wellness',
    'wahooUserId': 'wahoo_user_id',
    'wahooSyncActivities': 'wahoo_sync_activities',
    'wahooUploadWorkouts': 'wahoo_upload_workouts',
    'zwiftUserId': 'zwift_user_id',
    'zwiftSyncActivities': 'zwift_sync_activities',
    'zwiftUploadWorkouts': 'zwift_upload_workouts',
    'dropboxScope': 'dropbox_scope',
    'ouraScope': 'oura_scope',
    'ouraWellnessKeys': 'oura_wellness_keys',
    'whoopScope': 'whoop_scope',
    'whoopWellnessKeys': 'whoop_wellness_keys',
    'googleScope': 'google_scope',
    'googleWellnessKeys': 'google_wellness_keys',
    'icuEmailVerified': 'icu_email_verified',
    'icuEmailDisabled': 'icu_email_disabled',
    'emailNotifications': 'email_notifications',
    'pushNotifications': 'push_notifications',
    'notificationAthleteTagsEnabled': 'notification_athlete_tags_enabled',
    'hasPushSubscriptions': 'has_push_subscriptions',
    'includeDescrInPlanForWeek': 'include_descr_in_plan_for_week',
    'icuSendAchievements': 'icu_send_achievements',
    'icuSendNewsletter': 'icu_send_newsletter',
    'icuSendPrivateChat': 'icu_send_private_chat',
    'icuSendPrivateMsg': 'icu_send_private_msg',
    'icuSendFollowReq': 'icu_send_follow_req',
    'icuSendGroupChat': 'icu_send_group_chat',
    'icuSendGroupMsg': 'icu_send_group_msg',
    'icuSendActivityChat': 'icu_send_activity_chat',
    'icuSendFollowedActivityChat': 'icu_send_followed_activity_chat',
    'icuSendCoachedActivityChat': 'icu_send_coached_activity_chat',
    'icuSendActivityMsg': 'icu_send_activity_msg',
    'icuSendCoachMeReq': 'icu_send_coach_me_req',
    'icuSendGearAlerts': 'icu_send_gear_alerts',
    'icuSendPlanForWeek': 'icu_send_plan_for_week',
    'icuSendFollowedNewActivity': 'icu_send_followed_new_activity',
    'icuSendCoachedNewActivity': 'icu_send_coached_new_activity',
    'icuSendCoachTick': 'icu_send_coach_tick',
    'stravaAllowed': 'strava_allowed',
    'stravaId': 'strava_id',
    'stravaSyncActivities': 'strava_sync_activities',
    'stravaSyncActivityTypes': 'strava_sync_activity_types',
    'stravaSyncOtherActivities': 'strava_sync_other_activities',
    'ignoreStravaGear': 'ignore_strava_gear',
    'updateStravaName': 'update_strava_name',
    'addWeatherToStravaDescr': 'add_weather_to_strava_descr',
    'heightUnits': 'height_units',
    'planExpires': 'plan_expires',
    'trialEndDate': 'trial_end_date',
    'sponsoredByChatId': 'sponsored_by_chat_id',
    'hasPassword': 'has_password',
    'betaUser': 'beta_user',
    'trainingPlanId': 'training_plan_id',
    'trainingPlanStartDate': 'training_plan_start_date',
    'trainingAvailability': 'training_availability',
    'stravaAuthorized': 'strava_authorized',
  },
);

Map<String, dynamic> _$AthleteToJson(Athlete instance) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'firstname': ?instance.firstname,
  'lastname': ?instance.lastname,
  'profile_medium': ?instance.profileMedium,
  'measurement_preference': ?instance.measurementPreference,
  'weight_pref_lb': ?instance.weightPrefLb,
  'fahrenheit': ?instance.fahrenheit,
  'wind_speed': ?_$AthleteWindSpeedEnumEnumMap[instance.windSpeed],
  'rain': ?_$AthleteRainEnumEnumMap[instance.rain],
  'weight': ?instance.weight,
  'email': ?instance.email,
  'sex': ?instance.sex,
  'city': ?instance.city,
  'state': ?instance.state,
  'country': ?instance.country,
  'countries': ?instance.countries,
  'languages': ?instance.languages,
  'bikes': ?instance.bikes?.map((e) => e.toJson()).toList(),
  'shoes': ?instance.shoes?.map((e) => e.toJson()).toList(),
  'timezone': ?instance.timezone,
  'locale': ?instance.locale,
  'date_format': ?instance.dateFormat,
  'time_format': ?instance.timeFormat,
  'visibility': ?_$AthleteVisibilityEnumEnumMap[instance.visibility],
  'icu_last_seen': ?instance.icuLastSeen?.toIso8601String(),
  'status': ?_$AthleteStatusEnumEnumMap[instance.status],
  'status_updated': ?instance.statusUpdated?.toIso8601String(),
  'icu_resting_hr': ?instance.icuRestingHr,
  'icu_weight': ?instance.icuWeight,
  'icu_weight_sync': ?_$AthleteIcuWeightSyncEnumEnumMap[instance.icuWeightSync],
  'icu_activated': ?instance.icuActivated?.toIso8601String(),
  'icu_queue_pos': ?instance.icuQueuePos,
  'icu_admin': ?instance.icuAdmin,
  'icu_friend_invite_token': ?instance.icuFriendInviteToken,
  'icu_permission': ?_$AthleteIcuPermissionEnumEnumMap[instance.icuPermission],
  'icu_effort_secs': ?instance.icuEffortSecs,
  'icu_coach': ?instance.icuCoach,
  'bio': ?instance.bio,
  'website': ?instance.website,
  'icu_date_of_birth': ?instance.icuDateOfBirth,
  'icu_api_key': ?instance.icuApiKey,
  'icu_type_settings': ?instance.icuTypeSettings
      ?.map((e) => e.toJson())
      .toList(),
  'icu_form_as_percent': ?instance.icuFormAsPercent,
  'icu_mmp_days': ?instance.icuMmpDays,
  'icu_wellness_prompt': ?instance.icuWellnessPrompt,
  'wellness_last_prompt_date': ?instance.wellnessLastPromptDate,
  'icu_wellness_keys': ?instance.icuWellnessKeys,
  'private_wellness_keys': ?instance.privateWellnessKeys,
  'icu_track_menstrual_cycle': ?instance.icuTrackMenstrualCycle,
  'icu_menstrual_cycle_perm':
      ?_$AthleteIcuMenstrualCyclePermEnumEnumMap[instance
          .icuMenstrualCyclePerm],
  'activity_rpe_prompt': ?instance.activityRpePrompt,
  'coach_ticks': ?instance.coachTicks?.map((e) => e.toJson()).toList(),
  'icu_garmin_health': ?instance.icuGarminHealth,
  'icu_garmin_training': ?instance.icuGarminTraining,
  'icu_garmin_sync_activities': ?instance.icuGarminSyncActivities,
  'garmin_sync_activity_types': ?instance.garminSyncActivityTypes
      ?.map((e) => _$AthleteGarminSyncActivityTypesEnumEnumMap[e]!)
      .toList(),
  'garmin_sync_after': ?instance.garminSyncAfter?.toIso8601String(),
  'icu_garmin_download_wellness': ?instance.icuGarminDownloadWellness,
  'icu_garmin_upload_workouts': ?instance.icuGarminUploadWorkouts,
  'icu_garmin_outdoor_power_range': ?instance.icuGarminOutdoorPowerRange,
  'icu_garmin_hr_range': ?instance.icuGarminHrRange,
  'garmin_pace_range': ?instance.garminPaceRange,
  'garmin_power_target':
      ?_$AthleteGarminPowerTargetEnumEnumMap[instance.garminPowerTarget],
  'icu_garmin_last_upload': ?instance.icuGarminLastUpload?.toIso8601String(),
  'icu_garmin_upload_filters': ?instance.icuGarminUploadFilters
      ?.map((e) => e.toJson())
      .toList(),
  'icu_garmin_wellness_keys': ?instance.icuGarminWellnessKeys,
  'open_step_duration': ?instance.openStepDuration,
  'polar_scope': ?instance.polarScope,
  'polar_sync_activities': ?instance.polarSyncActivities,
  'polar_sync_activity_types': ?instance.polarSyncActivityTypes
      ?.map((e) => _$AthletePolarSyncActivityTypesEnumEnumMap[e]!)
      .toList(),
  'polar_download_wellness': ?instance.polarDownloadWellness,
  'polar_wellness_keys': ?instance.polarWellnessKeys,
  'suunto_scope': ?instance.suuntoScope,
  'suunto_user_id': ?instance.suuntoUserId,
  'suunto_sync_activities': ?instance.suuntoSyncActivities,
  'suunto_sync_activity_types': ?instance.suuntoSyncActivityTypes
      ?.map((e) => _$AthleteSuuntoSyncActivityTypesEnumEnumMap[e]!)
      .toList(),
  'suunto_upload_workouts': ?instance.suuntoUploadWorkouts,
  'suunto_outdoor_power_range': ?instance.suuntoOutdoorPowerRange,
  'suunto_hr_range': ?instance.suuntoHrRange,
  'suunto_pace_range': ?instance.suuntoPaceRange,
  'suunto_last_upload': ?instance.suuntoLastUpload?.toIso8601String(),
  'suunto_upload_filters': ?instance.suuntoUploadFilters
      ?.map((e) => e.toJson())
      .toList(),
  'suunto_download_wellness': ?instance.suuntoDownloadWellness,
  'coros_user_id': ?instance.corosUserId,
  'coros_sync_activities': ?instance.corosSyncActivities,
  'coros_upload_workouts': ?instance.corosUploadWorkouts,
  'coros_download_wellness': ?instance.corosDownloadWellness,
  'coros_last_upload': ?instance.corosLastUpload?.toIso8601String(),
  'concept2_user_id': ?instance.concept2UserId,
  'concept2_sync_activities': ?instance.concept2SyncActivities,
  'zepp_user_id': ?instance.zeppUserId,
  'zepp_sync_activities': ?instance.zeppSyncActivities,
  'zepp_upload_workouts': ?instance.zeppUploadWorkouts,
  'zepp_download_wellness': ?instance.zeppDownloadWellness,
  'huawei_user_id': ?instance.huaweiUserId,
  'huawei_sync_activities': ?instance.huaweiSyncActivities,
  'huawei_upload_workouts': ?instance.huaweiUploadWorkouts,
  'huawei_download_wellness': ?instance.huaweiDownloadWellness,
  'wahoo_user_id': ?instance.wahooUserId,
  'wahoo_sync_activities': ?instance.wahooSyncActivities,
  'wahoo_upload_workouts': ?instance.wahooUploadWorkouts,
  'zwift_user_id': ?instance.zwiftUserId,
  'zwift_sync_activities': ?instance.zwiftSyncActivities,
  'zwift_upload_workouts': ?instance.zwiftUploadWorkouts,
  'dropbox_scope': ?instance.dropboxScope,
  'oura_scope': ?instance.ouraScope,
  'oura_wellness_keys': ?instance.ouraWellnessKeys,
  'whoop_scope': ?instance.whoopScope,
  'whoop_wellness_keys': ?instance.whoopWellnessKeys,
  'google_scope': ?instance.googleScope,
  'google_wellness_keys': ?instance.googleWellnessKeys,
  'icu_email_verified': ?instance.icuEmailVerified,
  'icu_email_disabled': ?instance.icuEmailDisabled,
  'email_notifications': ?instance.emailNotifications
      ?.map((e) => _$AthleteEmailNotificationsEnumEnumMap[e]!)
      .toList(),
  'push_notifications': ?instance.pushNotifications
      ?.map((e) => _$AthletePushNotificationsEnumEnumMap[e]!)
      .toList(),
  'notification_athlete_tags_enabled': ?instance.notificationAthleteTagsEnabled,
  'has_push_subscriptions': ?instance.hasPushSubscriptions,
  'include_descr_in_plan_for_week': ?instance.includeDescrInPlanForWeek,
  'icu_send_achievements': ?instance.icuSendAchievements,
  'icu_send_newsletter': ?instance.icuSendNewsletter,
  'icu_send_private_chat': ?instance.icuSendPrivateChat,
  'icu_send_private_msg': ?instance.icuSendPrivateMsg,
  'icu_send_follow_req': ?instance.icuSendFollowReq,
  'icu_send_group_chat': ?instance.icuSendGroupChat,
  'icu_send_group_msg': ?instance.icuSendGroupMsg,
  'icu_send_activity_chat': ?instance.icuSendActivityChat,
  'icu_send_followed_activity_chat': ?instance.icuSendFollowedActivityChat,
  'icu_send_coached_activity_chat': ?instance.icuSendCoachedActivityChat,
  'icu_send_activity_msg': ?instance.icuSendActivityMsg,
  'icu_send_coach_me_req': ?instance.icuSendCoachMeReq,
  'icu_send_gear_alerts': ?instance.icuSendGearAlerts,
  'icu_send_plan_for_week': ?instance.icuSendPlanForWeek,
  'icu_send_followed_new_activity': ?instance.icuSendFollowedNewActivity,
  'icu_send_coached_new_activity': ?instance.icuSendCoachedNewActivity,
  'icu_send_coach_tick': ?instance.icuSendCoachTick,
  'strava_allowed': ?instance.stravaAllowed,
  'strava_id': ?instance.stravaId,
  'scope': ?instance.scope,
  'strava_sync_activities': ?instance.stravaSyncActivities,
  'strava_sync_activity_types': ?instance.stravaSyncActivityTypes
      ?.map((e) => _$AthleteStravaSyncActivityTypesEnumEnumMap[e]!)
      .toList(),
  'strava_sync_other_activities': ?instance.stravaSyncOtherActivities,
  'ignore_strava_gear': ?instance.ignoreStravaGear,
  'update_strava_name': ?instance.updateStravaName,
  'add_weather_to_strava_descr': ?instance.addWeatherToStravaDescr,
  'height': ?instance.height,
  'height_units': ?_$AthleteHeightUnitsEnumEnumMap[instance.heightUnits],
  'plan': ?_$AthletePlanEnumEnumMap[instance.plan],
  'plan_expires': ?instance.planExpires?.toIso8601String(),
  'trial_end_date': ?instance.trialEndDate?.toIso8601String(),
  'sponsored_by_chat_id': ?instance.sponsoredByChatId,
  'has_password': ?instance.hasPassword,
  'beta_user': ?instance.betaUser,
  'currency': ?instance.currency,
  'training_plan_id': ?instance.trainingPlanId,
  'training_plan_start_date': ?instance.trainingPlanStartDate,
  'training_availability': ?instance.trainingAvailability
      ?.map((e) => e.toJson())
      .toList(),
  'strava_authorized': ?instance.stravaAuthorized,
};

const _$AthleteWindSpeedEnumEnumMap = {
  AthleteWindSpeedEnum.MPS: 'MPS',
  AthleteWindSpeedEnum.KNOTS: 'KNOTS',
  AthleteWindSpeedEnum.KMH: 'KMH',
  AthleteWindSpeedEnum.MPH: 'MPH',
  AthleteWindSpeedEnum.BFT: 'BFT',
};

const _$AthleteRainEnumEnumMap = {
  AthleteRainEnum.MM: 'MM',
  AthleteRainEnum.INCHES: 'INCHES',
};

const _$AthleteVisibilityEnumEnumMap = {
  AthleteVisibilityEnum.PRIVATE: 'PRIVATE',
  AthleteVisibilityEnum.PUBLIC: 'PUBLIC',
  AthleteVisibilityEnum.HIDDEN: 'HIDDEN',
};

const _$AthleteStatusEnumEnumMap = {
  AthleteStatusEnum.ACTIVE: 'ACTIVE',
  AthleteStatusEnum.DORMANT: 'DORMANT',
  AthleteStatusEnum.ARCHIVED: 'ARCHIVED',
};

const _$AthleteIcuWeightSyncEnumEnumMap = {
  AthleteIcuWeightSyncEnum.NONE: 'NONE',
  AthleteIcuWeightSyncEnum.STRAVA: 'STRAVA',
};

const _$AthleteIcuPermissionEnumEnumMap = {
  AthleteIcuPermissionEnum.NONE: 'NONE',
  AthleteIcuPermissionEnum.READ: 'READ',
  AthleteIcuPermissionEnum.WRITE: 'WRITE',
};

const _$AthleteIcuMenstrualCyclePermEnumEnumMap = {
  AthleteIcuMenstrualCyclePermEnum.NONE: 'NONE',
  AthleteIcuMenstrualCyclePermEnum.READ: 'READ',
  AthleteIcuMenstrualCyclePermEnum.WRITE: 'WRITE',
};

const _$AthleteGarminSyncActivityTypesEnumEnumMap = {
  AthleteGarminSyncActivityTypesEnum.ride: 'Ride',
  AthleteGarminSyncActivityTypesEnum.run: 'Run',
  AthleteGarminSyncActivityTypesEnum.swim: 'Swim',
  AthleteGarminSyncActivityTypesEnum.weightTraining: 'WeightTraining',
  AthleteGarminSyncActivityTypesEnum.hike: 'Hike',
  AthleteGarminSyncActivityTypesEnum.walk: 'Walk',
  AthleteGarminSyncActivityTypesEnum.alpineSki: 'AlpineSki',
  AthleteGarminSyncActivityTypesEnum.backcountrySki: 'BackcountrySki',
  AthleteGarminSyncActivityTypesEnum.badminton: 'Badminton',
  AthleteGarminSyncActivityTypesEnum.canoeing: 'Canoeing',
  AthleteGarminSyncActivityTypesEnum.crossfit: 'Crossfit',
  AthleteGarminSyncActivityTypesEnum.eBikeRide: 'EBikeRide',
  AthleteGarminSyncActivityTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  AthleteGarminSyncActivityTypesEnum.elliptical: 'Elliptical',
  AthleteGarminSyncActivityTypesEnum.golf: 'Golf',
  AthleteGarminSyncActivityTypesEnum.gravelRide: 'GravelRide',
  AthleteGarminSyncActivityTypesEnum.trackRide: 'TrackRide',
  AthleteGarminSyncActivityTypesEnum.handcycle: 'Handcycle',
  AthleteGarminSyncActivityTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  AthleteGarminSyncActivityTypesEnum.hockey: 'Hockey',
  AthleteGarminSyncActivityTypesEnum.iceSkate: 'IceSkate',
  AthleteGarminSyncActivityTypesEnum.inlineSkate: 'InlineSkate',
  AthleteGarminSyncActivityTypesEnum.kayaking: 'Kayaking',
  AthleteGarminSyncActivityTypesEnum.kitesurf: 'Kitesurf',
  AthleteGarminSyncActivityTypesEnum.mountainBikeRide: 'MountainBikeRide',
  AthleteGarminSyncActivityTypesEnum.cyclocross: 'Cyclocross',
  AthleteGarminSyncActivityTypesEnum.nordicSki: 'NordicSki',
  AthleteGarminSyncActivityTypesEnum.openWaterSwim: 'OpenWaterSwim',
  AthleteGarminSyncActivityTypesEnum.padel: 'Padel',
  AthleteGarminSyncActivityTypesEnum.pilates: 'Pilates',
  AthleteGarminSyncActivityTypesEnum.pickleball: 'Pickleball',
  AthleteGarminSyncActivityTypesEnum.racquetball: 'Racquetball',
  AthleteGarminSyncActivityTypesEnum.rugby: 'Rugby',
  AthleteGarminSyncActivityTypesEnum.rockClimbing: 'RockClimbing',
  AthleteGarminSyncActivityTypesEnum.rollerSki: 'RollerSki',
  AthleteGarminSyncActivityTypesEnum.rowing: 'Rowing',
  AthleteGarminSyncActivityTypesEnum.sail: 'Sail',
  AthleteGarminSyncActivityTypesEnum.skateboard: 'Skateboard',
  AthleteGarminSyncActivityTypesEnum.snowboard: 'Snowboard',
  AthleteGarminSyncActivityTypesEnum.snowshoe: 'Snowshoe',
  AthleteGarminSyncActivityTypesEnum.soccer: 'Soccer',
  AthleteGarminSyncActivityTypesEnum.squash: 'Squash',
  AthleteGarminSyncActivityTypesEnum.stairStepper: 'StairStepper',
  AthleteGarminSyncActivityTypesEnum.standUpPaddling: 'StandUpPaddling',
  AthleteGarminSyncActivityTypesEnum.surfing: 'Surfing',
  AthleteGarminSyncActivityTypesEnum.tableTennis: 'TableTennis',
  AthleteGarminSyncActivityTypesEnum.tennis: 'Tennis',
  AthleteGarminSyncActivityTypesEnum.trailRun: 'TrailRun',
  AthleteGarminSyncActivityTypesEnum.transition: 'Transition',
  AthleteGarminSyncActivityTypesEnum.velomobile: 'Velomobile',
  AthleteGarminSyncActivityTypesEnum.virtualRide: 'VirtualRide',
  AthleteGarminSyncActivityTypesEnum.virtualRow: 'VirtualRow',
  AthleteGarminSyncActivityTypesEnum.virtualRun: 'VirtualRun',
  AthleteGarminSyncActivityTypesEnum.virtualSki: 'VirtualSki',
  AthleteGarminSyncActivityTypesEnum.waterSport: 'WaterSport',
  AthleteGarminSyncActivityTypesEnum.wheelchair: 'Wheelchair',
  AthleteGarminSyncActivityTypesEnum.windsurf: 'Windsurf',
  AthleteGarminSyncActivityTypesEnum.workout: 'Workout',
  AthleteGarminSyncActivityTypesEnum.yoga: 'Yoga',
  AthleteGarminSyncActivityTypesEnum.other: 'Other',
};

const _$AthleteGarminPowerTargetEnumEnumMap = {
  AthleteGarminPowerTargetEnum.POWER_LAP: 'POWER_LAP',
  AthleteGarminPowerTargetEnum.POWER: 'POWER',
  AthleteGarminPowerTargetEnum.POWER_3S: 'POWER_3S',
  AthleteGarminPowerTargetEnum.POWER_10S: 'POWER_10S',
  AthleteGarminPowerTargetEnum.POWER_30S: 'POWER_30S',
};

const _$AthletePolarSyncActivityTypesEnumEnumMap = {
  AthletePolarSyncActivityTypesEnum.ride: 'Ride',
  AthletePolarSyncActivityTypesEnum.run: 'Run',
  AthletePolarSyncActivityTypesEnum.swim: 'Swim',
  AthletePolarSyncActivityTypesEnum.weightTraining: 'WeightTraining',
  AthletePolarSyncActivityTypesEnum.hike: 'Hike',
  AthletePolarSyncActivityTypesEnum.walk: 'Walk',
  AthletePolarSyncActivityTypesEnum.alpineSki: 'AlpineSki',
  AthletePolarSyncActivityTypesEnum.backcountrySki: 'BackcountrySki',
  AthletePolarSyncActivityTypesEnum.badminton: 'Badminton',
  AthletePolarSyncActivityTypesEnum.canoeing: 'Canoeing',
  AthletePolarSyncActivityTypesEnum.crossfit: 'Crossfit',
  AthletePolarSyncActivityTypesEnum.eBikeRide: 'EBikeRide',
  AthletePolarSyncActivityTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  AthletePolarSyncActivityTypesEnum.elliptical: 'Elliptical',
  AthletePolarSyncActivityTypesEnum.golf: 'Golf',
  AthletePolarSyncActivityTypesEnum.gravelRide: 'GravelRide',
  AthletePolarSyncActivityTypesEnum.trackRide: 'TrackRide',
  AthletePolarSyncActivityTypesEnum.handcycle: 'Handcycle',
  AthletePolarSyncActivityTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  AthletePolarSyncActivityTypesEnum.hockey: 'Hockey',
  AthletePolarSyncActivityTypesEnum.iceSkate: 'IceSkate',
  AthletePolarSyncActivityTypesEnum.inlineSkate: 'InlineSkate',
  AthletePolarSyncActivityTypesEnum.kayaking: 'Kayaking',
  AthletePolarSyncActivityTypesEnum.kitesurf: 'Kitesurf',
  AthletePolarSyncActivityTypesEnum.mountainBikeRide: 'MountainBikeRide',
  AthletePolarSyncActivityTypesEnum.cyclocross: 'Cyclocross',
  AthletePolarSyncActivityTypesEnum.nordicSki: 'NordicSki',
  AthletePolarSyncActivityTypesEnum.openWaterSwim: 'OpenWaterSwim',
  AthletePolarSyncActivityTypesEnum.padel: 'Padel',
  AthletePolarSyncActivityTypesEnum.pilates: 'Pilates',
  AthletePolarSyncActivityTypesEnum.pickleball: 'Pickleball',
  AthletePolarSyncActivityTypesEnum.racquetball: 'Racquetball',
  AthletePolarSyncActivityTypesEnum.rugby: 'Rugby',
  AthletePolarSyncActivityTypesEnum.rockClimbing: 'RockClimbing',
  AthletePolarSyncActivityTypesEnum.rollerSki: 'RollerSki',
  AthletePolarSyncActivityTypesEnum.rowing: 'Rowing',
  AthletePolarSyncActivityTypesEnum.sail: 'Sail',
  AthletePolarSyncActivityTypesEnum.skateboard: 'Skateboard',
  AthletePolarSyncActivityTypesEnum.snowboard: 'Snowboard',
  AthletePolarSyncActivityTypesEnum.snowshoe: 'Snowshoe',
  AthletePolarSyncActivityTypesEnum.soccer: 'Soccer',
  AthletePolarSyncActivityTypesEnum.squash: 'Squash',
  AthletePolarSyncActivityTypesEnum.stairStepper: 'StairStepper',
  AthletePolarSyncActivityTypesEnum.standUpPaddling: 'StandUpPaddling',
  AthletePolarSyncActivityTypesEnum.surfing: 'Surfing',
  AthletePolarSyncActivityTypesEnum.tableTennis: 'TableTennis',
  AthletePolarSyncActivityTypesEnum.tennis: 'Tennis',
  AthletePolarSyncActivityTypesEnum.trailRun: 'TrailRun',
  AthletePolarSyncActivityTypesEnum.transition: 'Transition',
  AthletePolarSyncActivityTypesEnum.velomobile: 'Velomobile',
  AthletePolarSyncActivityTypesEnum.virtualRide: 'VirtualRide',
  AthletePolarSyncActivityTypesEnum.virtualRow: 'VirtualRow',
  AthletePolarSyncActivityTypesEnum.virtualRun: 'VirtualRun',
  AthletePolarSyncActivityTypesEnum.virtualSki: 'VirtualSki',
  AthletePolarSyncActivityTypesEnum.waterSport: 'WaterSport',
  AthletePolarSyncActivityTypesEnum.wheelchair: 'Wheelchair',
  AthletePolarSyncActivityTypesEnum.windsurf: 'Windsurf',
  AthletePolarSyncActivityTypesEnum.workout: 'Workout',
  AthletePolarSyncActivityTypesEnum.yoga: 'Yoga',
  AthletePolarSyncActivityTypesEnum.other: 'Other',
};

const _$AthleteSuuntoSyncActivityTypesEnumEnumMap = {
  AthleteSuuntoSyncActivityTypesEnum.ride: 'Ride',
  AthleteSuuntoSyncActivityTypesEnum.run: 'Run',
  AthleteSuuntoSyncActivityTypesEnum.swim: 'Swim',
  AthleteSuuntoSyncActivityTypesEnum.weightTraining: 'WeightTraining',
  AthleteSuuntoSyncActivityTypesEnum.hike: 'Hike',
  AthleteSuuntoSyncActivityTypesEnum.walk: 'Walk',
  AthleteSuuntoSyncActivityTypesEnum.alpineSki: 'AlpineSki',
  AthleteSuuntoSyncActivityTypesEnum.backcountrySki: 'BackcountrySki',
  AthleteSuuntoSyncActivityTypesEnum.badminton: 'Badminton',
  AthleteSuuntoSyncActivityTypesEnum.canoeing: 'Canoeing',
  AthleteSuuntoSyncActivityTypesEnum.crossfit: 'Crossfit',
  AthleteSuuntoSyncActivityTypesEnum.eBikeRide: 'EBikeRide',
  AthleteSuuntoSyncActivityTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  AthleteSuuntoSyncActivityTypesEnum.elliptical: 'Elliptical',
  AthleteSuuntoSyncActivityTypesEnum.golf: 'Golf',
  AthleteSuuntoSyncActivityTypesEnum.gravelRide: 'GravelRide',
  AthleteSuuntoSyncActivityTypesEnum.trackRide: 'TrackRide',
  AthleteSuuntoSyncActivityTypesEnum.handcycle: 'Handcycle',
  AthleteSuuntoSyncActivityTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  AthleteSuuntoSyncActivityTypesEnum.hockey: 'Hockey',
  AthleteSuuntoSyncActivityTypesEnum.iceSkate: 'IceSkate',
  AthleteSuuntoSyncActivityTypesEnum.inlineSkate: 'InlineSkate',
  AthleteSuuntoSyncActivityTypesEnum.kayaking: 'Kayaking',
  AthleteSuuntoSyncActivityTypesEnum.kitesurf: 'Kitesurf',
  AthleteSuuntoSyncActivityTypesEnum.mountainBikeRide: 'MountainBikeRide',
  AthleteSuuntoSyncActivityTypesEnum.cyclocross: 'Cyclocross',
  AthleteSuuntoSyncActivityTypesEnum.nordicSki: 'NordicSki',
  AthleteSuuntoSyncActivityTypesEnum.openWaterSwim: 'OpenWaterSwim',
  AthleteSuuntoSyncActivityTypesEnum.padel: 'Padel',
  AthleteSuuntoSyncActivityTypesEnum.pilates: 'Pilates',
  AthleteSuuntoSyncActivityTypesEnum.pickleball: 'Pickleball',
  AthleteSuuntoSyncActivityTypesEnum.racquetball: 'Racquetball',
  AthleteSuuntoSyncActivityTypesEnum.rugby: 'Rugby',
  AthleteSuuntoSyncActivityTypesEnum.rockClimbing: 'RockClimbing',
  AthleteSuuntoSyncActivityTypesEnum.rollerSki: 'RollerSki',
  AthleteSuuntoSyncActivityTypesEnum.rowing: 'Rowing',
  AthleteSuuntoSyncActivityTypesEnum.sail: 'Sail',
  AthleteSuuntoSyncActivityTypesEnum.skateboard: 'Skateboard',
  AthleteSuuntoSyncActivityTypesEnum.snowboard: 'Snowboard',
  AthleteSuuntoSyncActivityTypesEnum.snowshoe: 'Snowshoe',
  AthleteSuuntoSyncActivityTypesEnum.soccer: 'Soccer',
  AthleteSuuntoSyncActivityTypesEnum.squash: 'Squash',
  AthleteSuuntoSyncActivityTypesEnum.stairStepper: 'StairStepper',
  AthleteSuuntoSyncActivityTypesEnum.standUpPaddling: 'StandUpPaddling',
  AthleteSuuntoSyncActivityTypesEnum.surfing: 'Surfing',
  AthleteSuuntoSyncActivityTypesEnum.tableTennis: 'TableTennis',
  AthleteSuuntoSyncActivityTypesEnum.tennis: 'Tennis',
  AthleteSuuntoSyncActivityTypesEnum.trailRun: 'TrailRun',
  AthleteSuuntoSyncActivityTypesEnum.transition: 'Transition',
  AthleteSuuntoSyncActivityTypesEnum.velomobile: 'Velomobile',
  AthleteSuuntoSyncActivityTypesEnum.virtualRide: 'VirtualRide',
  AthleteSuuntoSyncActivityTypesEnum.virtualRow: 'VirtualRow',
  AthleteSuuntoSyncActivityTypesEnum.virtualRun: 'VirtualRun',
  AthleteSuuntoSyncActivityTypesEnum.virtualSki: 'VirtualSki',
  AthleteSuuntoSyncActivityTypesEnum.waterSport: 'WaterSport',
  AthleteSuuntoSyncActivityTypesEnum.wheelchair: 'Wheelchair',
  AthleteSuuntoSyncActivityTypesEnum.windsurf: 'Windsurf',
  AthleteSuuntoSyncActivityTypesEnum.workout: 'Workout',
  AthleteSuuntoSyncActivityTypesEnum.yoga: 'Yoga',
  AthleteSuuntoSyncActivityTypesEnum.other: 'Other',
};

const _$AthleteEmailNotificationsEnumEnumMap = {
  AthleteEmailNotificationsEnum.NEWSLETTER: 'NEWSLETTER',
  AthleteEmailNotificationsEnum.ACHIEVEMENTS: 'ACHIEVEMENTS',
  AthleteEmailNotificationsEnum.FOLLOW_REQUEST: 'FOLLOW_REQUEST',
  AthleteEmailNotificationsEnum.COACH_ME_REQUEST: 'COACH_ME_REQUEST',
  AthleteEmailNotificationsEnum.PRIVATE_CHAT: 'PRIVATE_CHAT',
  AthleteEmailNotificationsEnum.PRIVATE_MSG: 'PRIVATE_MSG',
  AthleteEmailNotificationsEnum.GROUP_CHAT: 'GROUP_CHAT',
  AthleteEmailNotificationsEnum.GROUP_MSG: 'GROUP_MSG',
  AthleteEmailNotificationsEnum.ACTIVITY_CHAT: 'ACTIVITY_CHAT',
  AthleteEmailNotificationsEnum.ACTIVITY_MSG: 'ACTIVITY_MSG',
  AthleteEmailNotificationsEnum.COACH_TICK: 'COACH_TICK',
  AthleteEmailNotificationsEnum.FOLLOWED_ACTIVITY_CHAT:
      'FOLLOWED_ACTIVITY_CHAT',
  AthleteEmailNotificationsEnum.COACHED_ACTIVITY_CHAT: 'COACHED_ACTIVITY_CHAT',
  AthleteEmailNotificationsEnum.FOLLOWED_NEW_ACTIVITY: 'FOLLOWED_NEW_ACTIVITY',
  AthleteEmailNotificationsEnum.COACHED_NEW_ACTIVITY: 'COACHED_NEW_ACTIVITY',
  AthleteEmailNotificationsEnum.GEAR_ALERTS: 'GEAR_ALERTS',
  AthleteEmailNotificationsEnum.PLAN_FOR_WEEK: 'PLAN_FOR_WEEK',
  AthleteEmailNotificationsEnum.NEW_ACTIVITY: 'NEW_ACTIVITY',
};

const _$AthletePushNotificationsEnumEnumMap = {
  AthletePushNotificationsEnum.NEWSLETTER: 'NEWSLETTER',
  AthletePushNotificationsEnum.ACHIEVEMENTS: 'ACHIEVEMENTS',
  AthletePushNotificationsEnum.FOLLOW_REQUEST: 'FOLLOW_REQUEST',
  AthletePushNotificationsEnum.COACH_ME_REQUEST: 'COACH_ME_REQUEST',
  AthletePushNotificationsEnum.PRIVATE_CHAT: 'PRIVATE_CHAT',
  AthletePushNotificationsEnum.PRIVATE_MSG: 'PRIVATE_MSG',
  AthletePushNotificationsEnum.GROUP_CHAT: 'GROUP_CHAT',
  AthletePushNotificationsEnum.GROUP_MSG: 'GROUP_MSG',
  AthletePushNotificationsEnum.ACTIVITY_CHAT: 'ACTIVITY_CHAT',
  AthletePushNotificationsEnum.ACTIVITY_MSG: 'ACTIVITY_MSG',
  AthletePushNotificationsEnum.COACH_TICK: 'COACH_TICK',
  AthletePushNotificationsEnum.FOLLOWED_ACTIVITY_CHAT: 'FOLLOWED_ACTIVITY_CHAT',
  AthletePushNotificationsEnum.COACHED_ACTIVITY_CHAT: 'COACHED_ACTIVITY_CHAT',
  AthletePushNotificationsEnum.FOLLOWED_NEW_ACTIVITY: 'FOLLOWED_NEW_ACTIVITY',
  AthletePushNotificationsEnum.COACHED_NEW_ACTIVITY: 'COACHED_NEW_ACTIVITY',
  AthletePushNotificationsEnum.GEAR_ALERTS: 'GEAR_ALERTS',
  AthletePushNotificationsEnum.PLAN_FOR_WEEK: 'PLAN_FOR_WEEK',
  AthletePushNotificationsEnum.NEW_ACTIVITY: 'NEW_ACTIVITY',
};

const _$AthleteStravaSyncActivityTypesEnumEnumMap = {
  AthleteStravaSyncActivityTypesEnum.ride: 'Ride',
  AthleteStravaSyncActivityTypesEnum.run: 'Run',
  AthleteStravaSyncActivityTypesEnum.swim: 'Swim',
  AthleteStravaSyncActivityTypesEnum.weightTraining: 'WeightTraining',
  AthleteStravaSyncActivityTypesEnum.hike: 'Hike',
  AthleteStravaSyncActivityTypesEnum.walk: 'Walk',
  AthleteStravaSyncActivityTypesEnum.alpineSki: 'AlpineSki',
  AthleteStravaSyncActivityTypesEnum.backcountrySki: 'BackcountrySki',
  AthleteStravaSyncActivityTypesEnum.badminton: 'Badminton',
  AthleteStravaSyncActivityTypesEnum.canoeing: 'Canoeing',
  AthleteStravaSyncActivityTypesEnum.crossfit: 'Crossfit',
  AthleteStravaSyncActivityTypesEnum.eBikeRide: 'EBikeRide',
  AthleteStravaSyncActivityTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  AthleteStravaSyncActivityTypesEnum.elliptical: 'Elliptical',
  AthleteStravaSyncActivityTypesEnum.golf: 'Golf',
  AthleteStravaSyncActivityTypesEnum.gravelRide: 'GravelRide',
  AthleteStravaSyncActivityTypesEnum.trackRide: 'TrackRide',
  AthleteStravaSyncActivityTypesEnum.handcycle: 'Handcycle',
  AthleteStravaSyncActivityTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  AthleteStravaSyncActivityTypesEnum.hockey: 'Hockey',
  AthleteStravaSyncActivityTypesEnum.iceSkate: 'IceSkate',
  AthleteStravaSyncActivityTypesEnum.inlineSkate: 'InlineSkate',
  AthleteStravaSyncActivityTypesEnum.kayaking: 'Kayaking',
  AthleteStravaSyncActivityTypesEnum.kitesurf: 'Kitesurf',
  AthleteStravaSyncActivityTypesEnum.mountainBikeRide: 'MountainBikeRide',
  AthleteStravaSyncActivityTypesEnum.cyclocross: 'Cyclocross',
  AthleteStravaSyncActivityTypesEnum.nordicSki: 'NordicSki',
  AthleteStravaSyncActivityTypesEnum.openWaterSwim: 'OpenWaterSwim',
  AthleteStravaSyncActivityTypesEnum.padel: 'Padel',
  AthleteStravaSyncActivityTypesEnum.pilates: 'Pilates',
  AthleteStravaSyncActivityTypesEnum.pickleball: 'Pickleball',
  AthleteStravaSyncActivityTypesEnum.racquetball: 'Racquetball',
  AthleteStravaSyncActivityTypesEnum.rugby: 'Rugby',
  AthleteStravaSyncActivityTypesEnum.rockClimbing: 'RockClimbing',
  AthleteStravaSyncActivityTypesEnum.rollerSki: 'RollerSki',
  AthleteStravaSyncActivityTypesEnum.rowing: 'Rowing',
  AthleteStravaSyncActivityTypesEnum.sail: 'Sail',
  AthleteStravaSyncActivityTypesEnum.skateboard: 'Skateboard',
  AthleteStravaSyncActivityTypesEnum.snowboard: 'Snowboard',
  AthleteStravaSyncActivityTypesEnum.snowshoe: 'Snowshoe',
  AthleteStravaSyncActivityTypesEnum.soccer: 'Soccer',
  AthleteStravaSyncActivityTypesEnum.squash: 'Squash',
  AthleteStravaSyncActivityTypesEnum.stairStepper: 'StairStepper',
  AthleteStravaSyncActivityTypesEnum.standUpPaddling: 'StandUpPaddling',
  AthleteStravaSyncActivityTypesEnum.surfing: 'Surfing',
  AthleteStravaSyncActivityTypesEnum.tableTennis: 'TableTennis',
  AthleteStravaSyncActivityTypesEnum.tennis: 'Tennis',
  AthleteStravaSyncActivityTypesEnum.trailRun: 'TrailRun',
  AthleteStravaSyncActivityTypesEnum.transition: 'Transition',
  AthleteStravaSyncActivityTypesEnum.velomobile: 'Velomobile',
  AthleteStravaSyncActivityTypesEnum.virtualRide: 'VirtualRide',
  AthleteStravaSyncActivityTypesEnum.virtualRow: 'VirtualRow',
  AthleteStravaSyncActivityTypesEnum.virtualRun: 'VirtualRun',
  AthleteStravaSyncActivityTypesEnum.virtualSki: 'VirtualSki',
  AthleteStravaSyncActivityTypesEnum.waterSport: 'WaterSport',
  AthleteStravaSyncActivityTypesEnum.wheelchair: 'Wheelchair',
  AthleteStravaSyncActivityTypesEnum.windsurf: 'Windsurf',
  AthleteStravaSyncActivityTypesEnum.workout: 'Workout',
  AthleteStravaSyncActivityTypesEnum.yoga: 'Yoga',
  AthleteStravaSyncActivityTypesEnum.other: 'Other',
};

const _$AthleteHeightUnitsEnumEnumMap = {
  AthleteHeightUnitsEnum.CM: 'CM',
  AthleteHeightUnitsEnum.FEET: 'FEET',
};

const _$AthletePlanEnumEnumMap = {
  AthletePlanEnum.FREE: 'FREE',
  AthletePlanEnum.PREMIUM: 'PREMIUM',
  AthletePlanEnum.SUPPORTER: 'SUPPORTER',
  AthletePlanEnum.WHITELABEL: 'WHITELABEL',
};
