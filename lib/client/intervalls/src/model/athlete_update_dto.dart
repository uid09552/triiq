//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_filter.dart';
import 'package:triiq/client/intervalls/src/model/coach_tick.dart';
import 'package:triiq/client/intervalls/src/model/strava_gear.dart';
import 'package:triiq/client/intervalls/src/model/athlete_training_availability.dart';
import 'package:triiq/client/intervalls/src/model/settings.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_update_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteUpdateDTO {
  /// Returns a new [AthleteUpdateDTO] instance.
  AthleteUpdateDTO({

     this.id,

     this.name,

     this.firstname,

     this.lastname,

     this.profileMedium,

     this.measurementPreference,

     this.weightPrefLb,

     this.fahrenheit,

     this.windSpeed,

     this.rain,

     this.weight,

     this.email,

     this.sex,

     this.city,

     this.state,

     this.country,

     this.countries,

     this.languages,

     this.bikes,

     this.shoes,

     this.timezone,

     this.locale,

     this.dateFormat,

     this.timeFormat,

     this.visibility,

     this.icuLastSeen,

     this.status,

     this.statusUpdated,

     this.icuRestingHr,

     this.icuWeight,

     this.icuWeightSync,

     this.icuActivated,

     this.icuQueuePos,

     this.icuAdmin,

     this.icuFriendInviteToken,

     this.icuPermission,

     this.icuEffortSecs,

     this.icuCoach,

     this.bio,

     this.website,

     this.icuDateOfBirth,

     this.icuApiKey,

     this.icuTypeSettings,

     this.icuFormAsPercent,

     this.icuMmpDays,

     this.icuWellnessPrompt,

     this.wellnessLastPromptDate,

     this.icuWellnessKeys,

     this.privateWellnessKeys,

     this.icuTrackMenstrualCycle,

     this.icuMenstrualCyclePerm,

     this.activityRpePrompt,

     this.coachTicks,

     this.icuGarminHealth,

     this.icuGarminTraining,

     this.icuGarminSyncActivities,

     this.garminSyncActivityTypes,

     this.garminSyncAfter,

     this.icuGarminDownloadWellness,

     this.icuGarminUploadWorkouts,

     this.icuGarminOutdoorPowerRange,

     this.icuGarminHrRange,

     this.garminPaceRange,

     this.garminPowerTarget,

     this.icuGarminLastUpload,

     this.icuGarminUploadFilters,

     this.icuGarminWellnessKeys,

     this.openStepDuration,

     this.polarScope,

     this.polarSyncActivities,

     this.polarSyncActivityTypes,

     this.polarDownloadWellness,

     this.polarWellnessKeys,

     this.suuntoScope,

     this.suuntoUserId,

     this.suuntoSyncActivities,

     this.suuntoSyncActivityTypes,

     this.suuntoUploadWorkouts,

     this.suuntoOutdoorPowerRange,

     this.suuntoHrRange,

     this.suuntoPaceRange,

     this.suuntoLastUpload,

     this.suuntoUploadFilters,

     this.suuntoDownloadWellness,

     this.corosUserId,

     this.corosSyncActivities,

     this.corosUploadWorkouts,

     this.corosDownloadWellness,

     this.corosLastUpload,

     this.concept2UserId,

     this.concept2SyncActivities,

     this.zeppUserId,

     this.zeppSyncActivities,

     this.zeppUploadWorkouts,

     this.zeppDownloadWellness,

     this.huaweiUserId,

     this.huaweiSyncActivities,

     this.huaweiUploadWorkouts,

     this.huaweiDownloadWellness,

     this.wahooUserId,

     this.wahooSyncActivities,

     this.wahooUploadWorkouts,

     this.zwiftUserId,

     this.zwiftSyncActivities,

     this.zwiftUploadWorkouts,

     this.dropboxScope,

     this.ouraScope,

     this.ouraWellnessKeys,

     this.whoopScope,

     this.whoopWellnessKeys,

     this.googleScope,

     this.googleWellnessKeys,

     this.icuEmailVerified,

     this.icuEmailDisabled,

     this.emailNotifications,

     this.pushNotifications,

     this.notificationAthleteTagsEnabled,

     this.hasPushSubscriptions,

     this.includeDescrInPlanForWeek,

     this.icuSendAchievements,

     this.icuSendNewsletter,

     this.icuSendPrivateChat,

     this.icuSendPrivateMsg,

     this.icuSendFollowReq,

     this.icuSendGroupChat,

     this.icuSendGroupMsg,

     this.icuSendActivityChat,

     this.icuSendFollowedActivityChat,

     this.icuSendCoachedActivityChat,

     this.icuSendActivityMsg,

     this.icuSendCoachMeReq,

     this.icuSendGearAlerts,

     this.icuSendPlanForWeek,

     this.icuSendFollowedNewActivity,

     this.icuSendCoachedNewActivity,

     this.icuSendCoachTick,

     this.stravaAllowed,

     this.stravaId,

     this.scope,

     this.stravaSyncActivities,

     this.stravaSyncActivityTypes,

     this.stravaSyncOtherActivities,

     this.ignoreStravaGear,

     this.updateStravaName,

     this.addWeatherToStravaDescr,

     this.height,

     this.heightUnits,

     this.plan,

     this.planExpires,

     this.trialEndDate,

     this.sponsoredByChatId,

     this.hasPassword,

     this.betaUser,

     this.currency,

     this.trainingPlanId,

     this.trainingPlanStartDate,

     this.trainingAvailability,

     this.recalcHrZones,

     this.applyToAll,

     this.localDate,

     this.password,

     this.icuTags,

     this.icuNotes,

     this.stravaAuthorized,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'firstname',
    required: false,
    includeIfNull: false,
  )


  final String? firstname;



  @JsonKey(
    
    name: r'lastname',
    required: false,
    includeIfNull: false,
  )


  final String? lastname;



  @JsonKey(
    
    name: r'profile_medium',
    required: false,
    includeIfNull: false,
  )


  final String? profileMedium;



  @JsonKey(
    
    name: r'measurement_preference',
    required: false,
    includeIfNull: false,
  )


  final String? measurementPreference;



  @JsonKey(
    
    name: r'weight_pref_lb',
    required: false,
    includeIfNull: false,
  )


  final bool? weightPrefLb;



  @JsonKey(
    
    name: r'fahrenheit',
    required: false,
    includeIfNull: false,
  )


  final bool? fahrenheit;



  @JsonKey(
    
    name: r'wind_speed',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOWindSpeedEnum? windSpeed;



  @JsonKey(
    
    name: r'rain',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTORainEnum? rain;



  @JsonKey(
    
    name: r'weight',
    required: false,
    includeIfNull: false,
  )


  final double? weight;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'sex',
    required: false,
    includeIfNull: false,
  )


  final String? sex;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    
    name: r'countries',
    required: false,
    includeIfNull: false,
  )


  final List<String>? countries;



  @JsonKey(
    
    name: r'languages',
    required: false,
    includeIfNull: false,
  )


  final List<String>? languages;



  @JsonKey(
    
    name: r'bikes',
    required: false,
    includeIfNull: false,
  )


  final List<StravaGear>? bikes;



  @JsonKey(
    
    name: r'shoes',
    required: false,
    includeIfNull: false,
  )


  final List<StravaGear>? shoes;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'date_format',
    required: false,
    includeIfNull: false,
  )


  final String? dateFormat;



  @JsonKey(
    
    name: r'time_format',
    required: false,
    includeIfNull: false,
  )


  final String? timeFormat;



  @JsonKey(
    
    name: r'visibility',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOVisibilityEnum? visibility;



  @JsonKey(
    
    name: r'icu_last_seen',
    required: false,
    includeIfNull: false,
  )


  final DateTime? icuLastSeen;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOStatusEnum? status;



  @JsonKey(
    
    name: r'status_updated',
    required: false,
    includeIfNull: false,
  )


  final DateTime? statusUpdated;



  @JsonKey(
    
    name: r'icu_resting_hr',
    required: false,
    includeIfNull: false,
  )


  final int? icuRestingHr;



  @JsonKey(
    
    name: r'icu_weight',
    required: false,
    includeIfNull: false,
  )


  final double? icuWeight;



  @JsonKey(
    
    name: r'icu_weight_sync',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOIcuWeightSyncEnum? icuWeightSync;



  @JsonKey(
    
    name: r'icu_activated',
    required: false,
    includeIfNull: false,
  )


  final DateTime? icuActivated;



  @JsonKey(
    
    name: r'icu_queue_pos',
    required: false,
    includeIfNull: false,
  )


  final int? icuQueuePos;



  @JsonKey(
    
    name: r'icu_admin',
    required: false,
    includeIfNull: false,
  )


  final bool? icuAdmin;



  @JsonKey(
    
    name: r'icu_friend_invite_token',
    required: false,
    includeIfNull: false,
  )


  final String? icuFriendInviteToken;



  @JsonKey(
    
    name: r'icu_permission',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOIcuPermissionEnum? icuPermission;



  @JsonKey(
    
    name: r'icu_effort_secs',
    required: false,
    includeIfNull: false,
  )


  final List<int>? icuEffortSecs;



  @JsonKey(
    
    name: r'icu_coach',
    required: false,
    includeIfNull: false,
  )


  final bool? icuCoach;



  @JsonKey(
    
    name: r'bio',
    required: false,
    includeIfNull: false,
  )


  final String? bio;



  @JsonKey(
    
    name: r'website',
    required: false,
    includeIfNull: false,
  )


  final String? website;



  @JsonKey(
    
    name: r'icu_date_of_birth',
    required: false,
    includeIfNull: false,
  )


  final String? icuDateOfBirth;



  @JsonKey(
    
    name: r'icu_api_key',
    required: false,
    includeIfNull: false,
  )


  final String? icuApiKey;



  @JsonKey(
    
    name: r'icu_type_settings',
    required: false,
    includeIfNull: false,
  )


  final List<Settings>? icuTypeSettings;



  @JsonKey(
    
    name: r'icu_form_as_percent',
    required: false,
    includeIfNull: false,
  )


  final bool? icuFormAsPercent;



  @JsonKey(
    
    name: r'icu_mmp_days',
    required: false,
    includeIfNull: false,
  )


  final int? icuMmpDays;



  @JsonKey(
    
    name: r'icu_wellness_prompt',
    required: false,
    includeIfNull: false,
  )


  final bool? icuWellnessPrompt;



  @JsonKey(
    
    name: r'wellness_last_prompt_date',
    required: false,
    includeIfNull: false,
  )


  final String? wellnessLastPromptDate;



  @JsonKey(
    
    name: r'icu_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? icuWellnessKeys;



  @JsonKey(
    
    name: r'private_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? privateWellnessKeys;



  @JsonKey(
    
    name: r'icu_track_menstrual_cycle',
    required: false,
    includeIfNull: false,
  )


  final bool? icuTrackMenstrualCycle;



  @JsonKey(
    
    name: r'icu_menstrual_cycle_perm',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOIcuMenstrualCyclePermEnum? icuMenstrualCyclePerm;



  @JsonKey(
    
    name: r'activity_rpe_prompt',
    required: false,
    includeIfNull: false,
  )


  final bool? activityRpePrompt;



  @JsonKey(
    
    name: r'coach_ticks',
    required: false,
    includeIfNull: false,
  )


  final List<CoachTick>? coachTicks;



  @JsonKey(
    
    name: r'icu_garmin_health',
    required: false,
    includeIfNull: false,
  )


  final bool? icuGarminHealth;



  @JsonKey(
    
    name: r'icu_garmin_training',
    required: false,
    includeIfNull: false,
  )


  final bool? icuGarminTraining;



  @JsonKey(
    
    name: r'icu_garmin_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? icuGarminSyncActivities;



  @JsonKey(
    
    name: r'garmin_sync_activity_types',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOGarminSyncActivityTypesEnum>? garminSyncActivityTypes;



  @JsonKey(
    
    name: r'garmin_sync_after',
    required: false,
    includeIfNull: false,
  )


  final DateTime? garminSyncAfter;



  @JsonKey(
    
    name: r'icu_garmin_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? icuGarminDownloadWellness;



  @JsonKey(
    
    name: r'icu_garmin_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? icuGarminUploadWorkouts;



  @JsonKey(
    
    name: r'icu_garmin_outdoor_power_range',
    required: false,
    includeIfNull: false,
  )


  final double? icuGarminOutdoorPowerRange;



  @JsonKey(
    
    name: r'icu_garmin_hr_range',
    required: false,
    includeIfNull: false,
  )


  final double? icuGarminHrRange;



  @JsonKey(
    
    name: r'garmin_pace_range',
    required: false,
    includeIfNull: false,
  )


  final double? garminPaceRange;



  @JsonKey(
    
    name: r'garmin_power_target',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOGarminPowerTargetEnum? garminPowerTarget;



  @JsonKey(
    
    name: r'icu_garmin_last_upload',
    required: false,
    includeIfNull: false,
  )


  final DateTime? icuGarminLastUpload;



  @JsonKey(
    
    name: r'icu_garmin_upload_filters',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityFilter>? icuGarminUploadFilters;



  @JsonKey(
    
    name: r'icu_garmin_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? icuGarminWellnessKeys;



  @JsonKey(
    
    name: r'open_step_duration',
    required: false,
    includeIfNull: false,
  )


  final int? openStepDuration;



  @JsonKey(
    
    name: r'polar_scope',
    required: false,
    includeIfNull: false,
  )


  final String? polarScope;



  @JsonKey(
    
    name: r'polar_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? polarSyncActivities;



  @JsonKey(
    
    name: r'polar_sync_activity_types',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOPolarSyncActivityTypesEnum>? polarSyncActivityTypes;



  @JsonKey(
    
    name: r'polar_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? polarDownloadWellness;



  @JsonKey(
    
    name: r'polar_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? polarWellnessKeys;



  @JsonKey(
    
    name: r'suunto_scope',
    required: false,
    includeIfNull: false,
  )


  final String? suuntoScope;



  @JsonKey(
    
    name: r'suunto_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? suuntoUserId;



  @JsonKey(
    
    name: r'suunto_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? suuntoSyncActivities;



  @JsonKey(
    
    name: r'suunto_sync_activity_types',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOSuuntoSyncActivityTypesEnum>? suuntoSyncActivityTypes;



  @JsonKey(
    
    name: r'suunto_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? suuntoUploadWorkouts;



  @JsonKey(
    
    name: r'suunto_outdoor_power_range',
    required: false,
    includeIfNull: false,
  )


  final double? suuntoOutdoorPowerRange;



  @JsonKey(
    
    name: r'suunto_hr_range',
    required: false,
    includeIfNull: false,
  )


  final double? suuntoHrRange;



  @JsonKey(
    
    name: r'suunto_pace_range',
    required: false,
    includeIfNull: false,
  )


  final double? suuntoPaceRange;



  @JsonKey(
    
    name: r'suunto_last_upload',
    required: false,
    includeIfNull: false,
  )


  final DateTime? suuntoLastUpload;



  @JsonKey(
    
    name: r'suunto_upload_filters',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityFilter>? suuntoUploadFilters;



  @JsonKey(
    
    name: r'suunto_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? suuntoDownloadWellness;



  @JsonKey(
    
    name: r'coros_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? corosUserId;



  @JsonKey(
    
    name: r'coros_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? corosSyncActivities;



  @JsonKey(
    
    name: r'coros_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? corosUploadWorkouts;



  @JsonKey(
    
    name: r'coros_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? corosDownloadWellness;



  @JsonKey(
    
    name: r'coros_last_upload',
    required: false,
    includeIfNull: false,
  )


  final DateTime? corosLastUpload;



  @JsonKey(
    
    name: r'concept2_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? concept2UserId;



  @JsonKey(
    
    name: r'concept2_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? concept2SyncActivities;



  @JsonKey(
    
    name: r'zepp_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? zeppUserId;



  @JsonKey(
    
    name: r'zepp_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? zeppSyncActivities;



  @JsonKey(
    
    name: r'zepp_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? zeppUploadWorkouts;



  @JsonKey(
    
    name: r'zepp_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? zeppDownloadWellness;



  @JsonKey(
    
    name: r'huawei_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? huaweiUserId;



  @JsonKey(
    
    name: r'huawei_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? huaweiSyncActivities;



  @JsonKey(
    
    name: r'huawei_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? huaweiUploadWorkouts;



  @JsonKey(
    
    name: r'huawei_download_wellness',
    required: false,
    includeIfNull: false,
  )


  final bool? huaweiDownloadWellness;



  @JsonKey(
    
    name: r'wahoo_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? wahooUserId;



  @JsonKey(
    
    name: r'wahoo_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? wahooSyncActivities;



  @JsonKey(
    
    name: r'wahoo_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? wahooUploadWorkouts;



  @JsonKey(
    
    name: r'zwift_user_id',
    required: false,
    includeIfNull: false,
  )


  final String? zwiftUserId;



  @JsonKey(
    
    name: r'zwift_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? zwiftSyncActivities;



  @JsonKey(
    
    name: r'zwift_upload_workouts',
    required: false,
    includeIfNull: false,
  )


  final bool? zwiftUploadWorkouts;



  @JsonKey(
    
    name: r'dropbox_scope',
    required: false,
    includeIfNull: false,
  )


  final String? dropboxScope;



  @JsonKey(
    
    name: r'oura_scope',
    required: false,
    includeIfNull: false,
  )


  final String? ouraScope;



  @JsonKey(
    
    name: r'oura_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? ouraWellnessKeys;



  @JsonKey(
    
    name: r'whoop_scope',
    required: false,
    includeIfNull: false,
  )


  final String? whoopScope;



  @JsonKey(
    
    name: r'whoop_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? whoopWellnessKeys;



  @JsonKey(
    
    name: r'google_scope',
    required: false,
    includeIfNull: false,
  )


  final String? googleScope;



  @JsonKey(
    
    name: r'google_wellness_keys',
    required: false,
    includeIfNull: false,
  )


  final List<String>? googleWellnessKeys;



  @JsonKey(
    
    name: r'icu_email_verified',
    required: false,
    includeIfNull: false,
  )


  final bool? icuEmailVerified;



  @JsonKey(
    
    name: r'icu_email_disabled',
    required: false,
    includeIfNull: false,
  )


  final String? icuEmailDisabled;



  @JsonKey(
    
    name: r'email_notifications',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOEmailNotificationsEnum>? emailNotifications;



  @JsonKey(
    
    name: r'push_notifications',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOPushNotificationsEnum>? pushNotifications;



  @JsonKey(
    
    name: r'notification_athlete_tags_enabled',
    required: false,
    includeIfNull: false,
  )


  final List<String>? notificationAthleteTagsEnabled;



  @JsonKey(
    
    name: r'has_push_subscriptions',
    required: false,
    includeIfNull: false,
  )


  final bool? hasPushSubscriptions;



  @JsonKey(
    
    name: r'include_descr_in_plan_for_week',
    required: false,
    includeIfNull: false,
  )


  final bool? includeDescrInPlanForWeek;



  @JsonKey(
    
    name: r'icu_send_achievements',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendAchievements;



  @JsonKey(
    
    name: r'icu_send_newsletter',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendNewsletter;



  @JsonKey(
    
    name: r'icu_send_private_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendPrivateChat;



  @JsonKey(
    
    name: r'icu_send_private_msg',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendPrivateMsg;



  @JsonKey(
    
    name: r'icu_send_follow_req',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendFollowReq;



  @JsonKey(
    
    name: r'icu_send_group_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendGroupChat;



  @JsonKey(
    
    name: r'icu_send_group_msg',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendGroupMsg;



  @JsonKey(
    
    name: r'icu_send_activity_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendActivityChat;



  @JsonKey(
    
    name: r'icu_send_followed_activity_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendFollowedActivityChat;



  @JsonKey(
    
    name: r'icu_send_coached_activity_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendCoachedActivityChat;



  @JsonKey(
    
    name: r'icu_send_activity_msg',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendActivityMsg;



  @JsonKey(
    
    name: r'icu_send_coach_me_req',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendCoachMeReq;



  @JsonKey(
    
    name: r'icu_send_gear_alerts',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendGearAlerts;



  @JsonKey(
    
    name: r'icu_send_plan_for_week',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendPlanForWeek;



  @JsonKey(
    
    name: r'icu_send_followed_new_activity',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendFollowedNewActivity;



  @JsonKey(
    
    name: r'icu_send_coached_new_activity',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendCoachedNewActivity;



  @JsonKey(
    
    name: r'icu_send_coach_tick',
    required: false,
    includeIfNull: false,
  )


  final bool? icuSendCoachTick;



  @JsonKey(
    
    name: r'strava_allowed',
    required: false,
    includeIfNull: false,
  )


  final bool? stravaAllowed;



  @JsonKey(
    
    name: r'strava_id',
    required: false,
    includeIfNull: false,
  )


  final int? stravaId;



  @JsonKey(
    
    name: r'scope',
    required: false,
    includeIfNull: false,
  )


  final String? scope;



  @JsonKey(
    
    name: r'strava_sync_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? stravaSyncActivities;



  @JsonKey(
    
    name: r'strava_sync_activity_types',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteUpdateDTOStravaSyncActivityTypesEnum>? stravaSyncActivityTypes;



  @JsonKey(
    
    name: r'strava_sync_other_activities',
    required: false,
    includeIfNull: false,
  )


  final bool? stravaSyncOtherActivities;



  @JsonKey(
    
    name: r'ignore_strava_gear',
    required: false,
    includeIfNull: false,
  )


  final bool? ignoreStravaGear;



  @JsonKey(
    
    name: r'update_strava_name',
    required: false,
    includeIfNull: false,
  )


  final bool? updateStravaName;



  @JsonKey(
    
    name: r'add_weather_to_strava_descr',
    required: false,
    includeIfNull: false,
  )


  final bool? addWeatherToStravaDescr;



  @JsonKey(
    
    name: r'height',
    required: false,
    includeIfNull: false,
  )


  final double? height;



  @JsonKey(
    
    name: r'height_units',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOHeightUnitsEnum? heightUnits;



  @JsonKey(
    
    name: r'plan',
    required: false,
    includeIfNull: false,
  )


  final AthleteUpdateDTOPlanEnum? plan;



  @JsonKey(
    
    name: r'plan_expires',
    required: false,
    includeIfNull: false,
  )


  final DateTime? planExpires;



  @JsonKey(
    
    name: r'trial_end_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trialEndDate;



  @JsonKey(
    
    name: r'sponsored_by_chat_id',
    required: false,
    includeIfNull: false,
  )


  final int? sponsoredByChatId;



  @JsonKey(
    
    name: r'has_password',
    required: false,
    includeIfNull: false,
  )


  final bool? hasPassword;



  @JsonKey(
    
    name: r'beta_user',
    required: false,
    includeIfNull: false,
  )


  final bool? betaUser;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'training_plan_id',
    required: false,
    includeIfNull: false,
  )


  final int? trainingPlanId;



  @JsonKey(
    
    name: r'training_plan_start_date',
    required: false,
    includeIfNull: false,
  )


  final String? trainingPlanStartDate;



  @JsonKey(
    
    name: r'training_availability',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteTrainingAvailability>? trainingAvailability;



  @JsonKey(
    
    name: r'recalcHrZones',
    required: false,
    includeIfNull: false,
  )


  final bool? recalcHrZones;



  @JsonKey(
    
    name: r'applyToAll',
    required: false,
    includeIfNull: false,
  )


  final bool? applyToAll;



  @JsonKey(
    
    name: r'localDate',
    required: false,
    includeIfNull: false,
  )


  final String? localDate;



  @JsonKey(
    
    name: r'password',
    required: false,
    includeIfNull: false,
  )


  final String? password;



  @JsonKey(
    
    name: r'icu_tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? icuTags;



  @JsonKey(
    
    name: r'icu_notes',
    required: false,
    includeIfNull: false,
  )


  final String? icuNotes;



  @JsonKey(
    
    name: r'strava_authorized',
    required: false,
    includeIfNull: false,
  )


  final bool? stravaAuthorized;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AthleteUpdateDTO &&
      other.id == id &&
      other.name == name &&
      other.firstname == firstname &&
      other.lastname == lastname &&
      other.profileMedium == profileMedium &&
      other.measurementPreference == measurementPreference &&
      other.weightPrefLb == weightPrefLb &&
      other.fahrenheit == fahrenheit &&
      other.windSpeed == windSpeed &&
      other.rain == rain &&
      other.weight == weight &&
      other.email == email &&
      other.sex == sex &&
      other.city == city &&
      other.state == state &&
      other.country == country &&
      other.countries == countries &&
      other.languages == languages &&
      other.bikes == bikes &&
      other.shoes == shoes &&
      other.timezone == timezone &&
      other.locale == locale &&
      other.dateFormat == dateFormat &&
      other.timeFormat == timeFormat &&
      other.visibility == visibility &&
      other.icuLastSeen == icuLastSeen &&
      other.status == status &&
      other.statusUpdated == statusUpdated &&
      other.icuRestingHr == icuRestingHr &&
      other.icuWeight == icuWeight &&
      other.icuWeightSync == icuWeightSync &&
      other.icuActivated == icuActivated &&
      other.icuQueuePos == icuQueuePos &&
      other.icuAdmin == icuAdmin &&
      other.icuFriendInviteToken == icuFriendInviteToken &&
      other.icuPermission == icuPermission &&
      other.icuEffortSecs == icuEffortSecs &&
      other.icuCoach == icuCoach &&
      other.bio == bio &&
      other.website == website &&
      other.icuDateOfBirth == icuDateOfBirth &&
      other.icuApiKey == icuApiKey &&
      other.icuTypeSettings == icuTypeSettings &&
      other.icuFormAsPercent == icuFormAsPercent &&
      other.icuMmpDays == icuMmpDays &&
      other.icuWellnessPrompt == icuWellnessPrompt &&
      other.wellnessLastPromptDate == wellnessLastPromptDate &&
      other.icuWellnessKeys == icuWellnessKeys &&
      other.privateWellnessKeys == privateWellnessKeys &&
      other.icuTrackMenstrualCycle == icuTrackMenstrualCycle &&
      other.icuMenstrualCyclePerm == icuMenstrualCyclePerm &&
      other.activityRpePrompt == activityRpePrompt &&
      other.coachTicks == coachTicks &&
      other.icuGarminHealth == icuGarminHealth &&
      other.icuGarminTraining == icuGarminTraining &&
      other.icuGarminSyncActivities == icuGarminSyncActivities &&
      other.garminSyncActivityTypes == garminSyncActivityTypes &&
      other.garminSyncAfter == garminSyncAfter &&
      other.icuGarminDownloadWellness == icuGarminDownloadWellness &&
      other.icuGarminUploadWorkouts == icuGarminUploadWorkouts &&
      other.icuGarminOutdoorPowerRange == icuGarminOutdoorPowerRange &&
      other.icuGarminHrRange == icuGarminHrRange &&
      other.garminPaceRange == garminPaceRange &&
      other.garminPowerTarget == garminPowerTarget &&
      other.icuGarminLastUpload == icuGarminLastUpload &&
      other.icuGarminUploadFilters == icuGarminUploadFilters &&
      other.icuGarminWellnessKeys == icuGarminWellnessKeys &&
      other.openStepDuration == openStepDuration &&
      other.polarScope == polarScope &&
      other.polarSyncActivities == polarSyncActivities &&
      other.polarSyncActivityTypes == polarSyncActivityTypes &&
      other.polarDownloadWellness == polarDownloadWellness &&
      other.polarWellnessKeys == polarWellnessKeys &&
      other.suuntoScope == suuntoScope &&
      other.suuntoUserId == suuntoUserId &&
      other.suuntoSyncActivities == suuntoSyncActivities &&
      other.suuntoSyncActivityTypes == suuntoSyncActivityTypes &&
      other.suuntoUploadWorkouts == suuntoUploadWorkouts &&
      other.suuntoOutdoorPowerRange == suuntoOutdoorPowerRange &&
      other.suuntoHrRange == suuntoHrRange &&
      other.suuntoPaceRange == suuntoPaceRange &&
      other.suuntoLastUpload == suuntoLastUpload &&
      other.suuntoUploadFilters == suuntoUploadFilters &&
      other.suuntoDownloadWellness == suuntoDownloadWellness &&
      other.corosUserId == corosUserId &&
      other.corosSyncActivities == corosSyncActivities &&
      other.corosUploadWorkouts == corosUploadWorkouts &&
      other.corosDownloadWellness == corosDownloadWellness &&
      other.corosLastUpload == corosLastUpload &&
      other.concept2UserId == concept2UserId &&
      other.concept2SyncActivities == concept2SyncActivities &&
      other.zeppUserId == zeppUserId &&
      other.zeppSyncActivities == zeppSyncActivities &&
      other.zeppUploadWorkouts == zeppUploadWorkouts &&
      other.zeppDownloadWellness == zeppDownloadWellness &&
      other.huaweiUserId == huaweiUserId &&
      other.huaweiSyncActivities == huaweiSyncActivities &&
      other.huaweiUploadWorkouts == huaweiUploadWorkouts &&
      other.huaweiDownloadWellness == huaweiDownloadWellness &&
      other.wahooUserId == wahooUserId &&
      other.wahooSyncActivities == wahooSyncActivities &&
      other.wahooUploadWorkouts == wahooUploadWorkouts &&
      other.zwiftUserId == zwiftUserId &&
      other.zwiftSyncActivities == zwiftSyncActivities &&
      other.zwiftUploadWorkouts == zwiftUploadWorkouts &&
      other.dropboxScope == dropboxScope &&
      other.ouraScope == ouraScope &&
      other.ouraWellnessKeys == ouraWellnessKeys &&
      other.whoopScope == whoopScope &&
      other.whoopWellnessKeys == whoopWellnessKeys &&
      other.googleScope == googleScope &&
      other.googleWellnessKeys == googleWellnessKeys &&
      other.icuEmailVerified == icuEmailVerified &&
      other.icuEmailDisabled == icuEmailDisabled &&
      other.emailNotifications == emailNotifications &&
      other.pushNotifications == pushNotifications &&
      other.notificationAthleteTagsEnabled == notificationAthleteTagsEnabled &&
      other.hasPushSubscriptions == hasPushSubscriptions &&
      other.includeDescrInPlanForWeek == includeDescrInPlanForWeek &&
      other.icuSendAchievements == icuSendAchievements &&
      other.icuSendNewsletter == icuSendNewsletter &&
      other.icuSendPrivateChat == icuSendPrivateChat &&
      other.icuSendPrivateMsg == icuSendPrivateMsg &&
      other.icuSendFollowReq == icuSendFollowReq &&
      other.icuSendGroupChat == icuSendGroupChat &&
      other.icuSendGroupMsg == icuSendGroupMsg &&
      other.icuSendActivityChat == icuSendActivityChat &&
      other.icuSendFollowedActivityChat == icuSendFollowedActivityChat &&
      other.icuSendCoachedActivityChat == icuSendCoachedActivityChat &&
      other.icuSendActivityMsg == icuSendActivityMsg &&
      other.icuSendCoachMeReq == icuSendCoachMeReq &&
      other.icuSendGearAlerts == icuSendGearAlerts &&
      other.icuSendPlanForWeek == icuSendPlanForWeek &&
      other.icuSendFollowedNewActivity == icuSendFollowedNewActivity &&
      other.icuSendCoachedNewActivity == icuSendCoachedNewActivity &&
      other.icuSendCoachTick == icuSendCoachTick &&
      other.stravaAllowed == stravaAllowed &&
      other.stravaId == stravaId &&
      other.scope == scope &&
      other.stravaSyncActivities == stravaSyncActivities &&
      other.stravaSyncActivityTypes == stravaSyncActivityTypes &&
      other.stravaSyncOtherActivities == stravaSyncOtherActivities &&
      other.ignoreStravaGear == ignoreStravaGear &&
      other.updateStravaName == updateStravaName &&
      other.addWeatherToStravaDescr == addWeatherToStravaDescr &&
      other.height == height &&
      other.heightUnits == heightUnits &&
      other.plan == plan &&
      other.planExpires == planExpires &&
      other.trialEndDate == trialEndDate &&
      other.sponsoredByChatId == sponsoredByChatId &&
      other.hasPassword == hasPassword &&
      other.betaUser == betaUser &&
      other.currency == currency &&
      other.trainingPlanId == trainingPlanId &&
      other.trainingPlanStartDate == trainingPlanStartDate &&
      other.trainingAvailability == trainingAvailability &&
      other.recalcHrZones == recalcHrZones &&
      other.applyToAll == applyToAll &&
      other.localDate == localDate &&
      other.password == password &&
      other.icuTags == icuTags &&
      other.icuNotes == icuNotes &&
      other.stravaAuthorized == stravaAuthorized;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        firstname.hashCode +
        lastname.hashCode +
        profileMedium.hashCode +
        measurementPreference.hashCode +
        weightPrefLb.hashCode +
        fahrenheit.hashCode +
        windSpeed.hashCode +
        rain.hashCode +
        weight.hashCode +
        email.hashCode +
        sex.hashCode +
        city.hashCode +
        state.hashCode +
        country.hashCode +
        countries.hashCode +
        languages.hashCode +
        bikes.hashCode +
        shoes.hashCode +
        timezone.hashCode +
        locale.hashCode +
        dateFormat.hashCode +
        timeFormat.hashCode +
        visibility.hashCode +
        icuLastSeen.hashCode +
        status.hashCode +
        statusUpdated.hashCode +
        icuRestingHr.hashCode +
        icuWeight.hashCode +
        icuWeightSync.hashCode +
        icuActivated.hashCode +
        icuQueuePos.hashCode +
        icuAdmin.hashCode +
        icuFriendInviteToken.hashCode +
        icuPermission.hashCode +
        icuEffortSecs.hashCode +
        icuCoach.hashCode +
        bio.hashCode +
        website.hashCode +
        icuDateOfBirth.hashCode +
        icuApiKey.hashCode +
        icuTypeSettings.hashCode +
        icuFormAsPercent.hashCode +
        icuMmpDays.hashCode +
        icuWellnessPrompt.hashCode +
        wellnessLastPromptDate.hashCode +
        icuWellnessKeys.hashCode +
        privateWellnessKeys.hashCode +
        icuTrackMenstrualCycle.hashCode +
        icuMenstrualCyclePerm.hashCode +
        activityRpePrompt.hashCode +
        coachTicks.hashCode +
        icuGarminHealth.hashCode +
        icuGarminTraining.hashCode +
        icuGarminSyncActivities.hashCode +
        garminSyncActivityTypes.hashCode +
        garminSyncAfter.hashCode +
        icuGarminDownloadWellness.hashCode +
        icuGarminUploadWorkouts.hashCode +
        icuGarminOutdoorPowerRange.hashCode +
        icuGarminHrRange.hashCode +
        garminPaceRange.hashCode +
        garminPowerTarget.hashCode +
        icuGarminLastUpload.hashCode +
        icuGarminUploadFilters.hashCode +
        icuGarminWellnessKeys.hashCode +
        openStepDuration.hashCode +
        polarScope.hashCode +
        polarSyncActivities.hashCode +
        polarSyncActivityTypes.hashCode +
        polarDownloadWellness.hashCode +
        polarWellnessKeys.hashCode +
        suuntoScope.hashCode +
        suuntoUserId.hashCode +
        suuntoSyncActivities.hashCode +
        suuntoSyncActivityTypes.hashCode +
        suuntoUploadWorkouts.hashCode +
        suuntoOutdoorPowerRange.hashCode +
        suuntoHrRange.hashCode +
        suuntoPaceRange.hashCode +
        suuntoLastUpload.hashCode +
        suuntoUploadFilters.hashCode +
        suuntoDownloadWellness.hashCode +
        corosUserId.hashCode +
        corosSyncActivities.hashCode +
        corosUploadWorkouts.hashCode +
        corosDownloadWellness.hashCode +
        corosLastUpload.hashCode +
        concept2UserId.hashCode +
        concept2SyncActivities.hashCode +
        zeppUserId.hashCode +
        zeppSyncActivities.hashCode +
        zeppUploadWorkouts.hashCode +
        zeppDownloadWellness.hashCode +
        huaweiUserId.hashCode +
        huaweiSyncActivities.hashCode +
        huaweiUploadWorkouts.hashCode +
        huaweiDownloadWellness.hashCode +
        wahooUserId.hashCode +
        wahooSyncActivities.hashCode +
        wahooUploadWorkouts.hashCode +
        zwiftUserId.hashCode +
        zwiftSyncActivities.hashCode +
        zwiftUploadWorkouts.hashCode +
        dropboxScope.hashCode +
        ouraScope.hashCode +
        ouraWellnessKeys.hashCode +
        whoopScope.hashCode +
        whoopWellnessKeys.hashCode +
        googleScope.hashCode +
        googleWellnessKeys.hashCode +
        icuEmailVerified.hashCode +
        icuEmailDisabled.hashCode +
        emailNotifications.hashCode +
        pushNotifications.hashCode +
        notificationAthleteTagsEnabled.hashCode +
        hasPushSubscriptions.hashCode +
        includeDescrInPlanForWeek.hashCode +
        icuSendAchievements.hashCode +
        icuSendNewsletter.hashCode +
        icuSendPrivateChat.hashCode +
        icuSendPrivateMsg.hashCode +
        icuSendFollowReq.hashCode +
        icuSendGroupChat.hashCode +
        icuSendGroupMsg.hashCode +
        icuSendActivityChat.hashCode +
        icuSendFollowedActivityChat.hashCode +
        icuSendCoachedActivityChat.hashCode +
        icuSendActivityMsg.hashCode +
        icuSendCoachMeReq.hashCode +
        icuSendGearAlerts.hashCode +
        icuSendPlanForWeek.hashCode +
        icuSendFollowedNewActivity.hashCode +
        icuSendCoachedNewActivity.hashCode +
        icuSendCoachTick.hashCode +
        stravaAllowed.hashCode +
        stravaId.hashCode +
        scope.hashCode +
        stravaSyncActivities.hashCode +
        stravaSyncActivityTypes.hashCode +
        stravaSyncOtherActivities.hashCode +
        ignoreStravaGear.hashCode +
        updateStravaName.hashCode +
        addWeatherToStravaDescr.hashCode +
        height.hashCode +
        heightUnits.hashCode +
        plan.hashCode +
        planExpires.hashCode +
        trialEndDate.hashCode +
        sponsoredByChatId.hashCode +
        hasPassword.hashCode +
        betaUser.hashCode +
        currency.hashCode +
        trainingPlanId.hashCode +
        trainingPlanStartDate.hashCode +
        trainingAvailability.hashCode +
        recalcHrZones.hashCode +
        applyToAll.hashCode +
        localDate.hashCode +
        password.hashCode +
        icuTags.hashCode +
        icuNotes.hashCode +
        stravaAuthorized.hashCode;

  factory AthleteUpdateDTO.fromJson(Map<String, dynamic> json) => _$AthleteUpdateDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteUpdateDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AthleteUpdateDTOWindSpeedEnum {
@JsonValue(r'MPS')
MPS(r'MPS'),
@JsonValue(r'KNOTS')
KNOTS(r'KNOTS'),
@JsonValue(r'KMH')
KMH(r'KMH'),
@JsonValue(r'MPH')
MPH(r'MPH'),
@JsonValue(r'BFT')
BFT(r'BFT');

const AthleteUpdateDTOWindSpeedEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTORainEnum {
@JsonValue(r'MM')
MM(r'MM'),
@JsonValue(r'INCHES')
INCHES(r'INCHES');

const AthleteUpdateDTORainEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOVisibilityEnum {
@JsonValue(r'PRIVATE')
PRIVATE(r'PRIVATE'),
@JsonValue(r'PUBLIC')
PUBLIC(r'PUBLIC'),
@JsonValue(r'HIDDEN')
HIDDEN(r'HIDDEN');

const AthleteUpdateDTOVisibilityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOStatusEnum {
@JsonValue(r'ACTIVE')
ACTIVE(r'ACTIVE'),
@JsonValue(r'DORMANT')
DORMANT(r'DORMANT'),
@JsonValue(r'ARCHIVED')
ARCHIVED(r'ARCHIVED');

const AthleteUpdateDTOStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOIcuWeightSyncEnum {
@JsonValue(r'NONE')
NONE(r'NONE'),
@JsonValue(r'STRAVA')
STRAVA(r'STRAVA');

const AthleteUpdateDTOIcuWeightSyncEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOIcuPermissionEnum {
@JsonValue(r'NONE')
NONE(r'NONE'),
@JsonValue(r'READ')
READ(r'READ'),
@JsonValue(r'WRITE')
WRITE(r'WRITE');

const AthleteUpdateDTOIcuPermissionEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOIcuMenstrualCyclePermEnum {
@JsonValue(r'NONE')
NONE(r'NONE'),
@JsonValue(r'READ')
READ(r'READ'),
@JsonValue(r'WRITE')
WRITE(r'WRITE');

const AthleteUpdateDTOIcuMenstrualCyclePermEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOGarminSyncActivityTypesEnum {
@JsonValue(r'Ride')
ride(r'Ride'),
@JsonValue(r'Run')
run(r'Run'),
@JsonValue(r'Swim')
swim(r'Swim'),
@JsonValue(r'WeightTraining')
weightTraining(r'WeightTraining'),
@JsonValue(r'Hike')
hike(r'Hike'),
@JsonValue(r'Walk')
walk(r'Walk'),
@JsonValue(r'AlpineSki')
alpineSki(r'AlpineSki'),
@JsonValue(r'BackcountrySki')
backcountrySki(r'BackcountrySki'),
@JsonValue(r'Badminton')
badminton(r'Badminton'),
@JsonValue(r'Canoeing')
canoeing(r'Canoeing'),
@JsonValue(r'Crossfit')
crossfit(r'Crossfit'),
@JsonValue(r'EBikeRide')
eBikeRide(r'EBikeRide'),
@JsonValue(r'EMountainBikeRide')
eMountainBikeRide(r'EMountainBikeRide'),
@JsonValue(r'Elliptical')
elliptical(r'Elliptical'),
@JsonValue(r'Golf')
golf(r'Golf'),
@JsonValue(r'GravelRide')
gravelRide(r'GravelRide'),
@JsonValue(r'TrackRide')
trackRide(r'TrackRide'),
@JsonValue(r'Handcycle')
handcycle(r'Handcycle'),
@JsonValue(r'HighIntensityIntervalTraining')
highIntensityIntervalTraining(r'HighIntensityIntervalTraining'),
@JsonValue(r'Hockey')
hockey(r'Hockey'),
@JsonValue(r'IceSkate')
iceSkate(r'IceSkate'),
@JsonValue(r'InlineSkate')
inlineSkate(r'InlineSkate'),
@JsonValue(r'Kayaking')
kayaking(r'Kayaking'),
@JsonValue(r'Kitesurf')
kitesurf(r'Kitesurf'),
@JsonValue(r'MountainBikeRide')
mountainBikeRide(r'MountainBikeRide'),
@JsonValue(r'Cyclocross')
cyclocross(r'Cyclocross'),
@JsonValue(r'NordicSki')
nordicSki(r'NordicSki'),
@JsonValue(r'OpenWaterSwim')
openWaterSwim(r'OpenWaterSwim'),
@JsonValue(r'Padel')
padel(r'Padel'),
@JsonValue(r'Pilates')
pilates(r'Pilates'),
@JsonValue(r'Pickleball')
pickleball(r'Pickleball'),
@JsonValue(r'Racquetball')
racquetball(r'Racquetball'),
@JsonValue(r'Rugby')
rugby(r'Rugby'),
@JsonValue(r'RockClimbing')
rockClimbing(r'RockClimbing'),
@JsonValue(r'RollerSki')
rollerSki(r'RollerSki'),
@JsonValue(r'Rowing')
rowing(r'Rowing'),
@JsonValue(r'Sail')
sail(r'Sail'),
@JsonValue(r'Skateboard')
skateboard(r'Skateboard'),
@JsonValue(r'Snowboard')
snowboard(r'Snowboard'),
@JsonValue(r'Snowshoe')
snowshoe(r'Snowshoe'),
@JsonValue(r'Soccer')
soccer(r'Soccer'),
@JsonValue(r'Squash')
squash(r'Squash'),
@JsonValue(r'StairStepper')
stairStepper(r'StairStepper'),
@JsonValue(r'StandUpPaddling')
standUpPaddling(r'StandUpPaddling'),
@JsonValue(r'Surfing')
surfing(r'Surfing'),
@JsonValue(r'TableTennis')
tableTennis(r'TableTennis'),
@JsonValue(r'Tennis')
tennis(r'Tennis'),
@JsonValue(r'TrailRun')
trailRun(r'TrailRun'),
@JsonValue(r'Transition')
transition(r'Transition'),
@JsonValue(r'Velomobile')
velomobile(r'Velomobile'),
@JsonValue(r'VirtualRide')
virtualRide(r'VirtualRide'),
@JsonValue(r'VirtualRow')
virtualRow(r'VirtualRow'),
@JsonValue(r'VirtualRun')
virtualRun(r'VirtualRun'),
@JsonValue(r'VirtualSki')
virtualSki(r'VirtualSki'),
@JsonValue(r'WaterSport')
waterSport(r'WaterSport'),
@JsonValue(r'Wheelchair')
wheelchair(r'Wheelchair'),
@JsonValue(r'Windsurf')
windsurf(r'Windsurf'),
@JsonValue(r'Workout')
workout(r'Workout'),
@JsonValue(r'Yoga')
yoga(r'Yoga'),
@JsonValue(r'Other')
other(r'Other');

const AthleteUpdateDTOGarminSyncActivityTypesEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOGarminPowerTargetEnum {
@JsonValue(r'POWER_LAP')
POWER_LAP(r'POWER_LAP'),
@JsonValue(r'POWER')
POWER(r'POWER'),
@JsonValue(r'POWER_3S')
POWER_3S(r'POWER_3S'),
@JsonValue(r'POWER_10S')
POWER_10S(r'POWER_10S'),
@JsonValue(r'POWER_30S')
POWER_30S(r'POWER_30S');

const AthleteUpdateDTOGarminPowerTargetEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOPolarSyncActivityTypesEnum {
@JsonValue(r'Ride')
ride(r'Ride'),
@JsonValue(r'Run')
run(r'Run'),
@JsonValue(r'Swim')
swim(r'Swim'),
@JsonValue(r'WeightTraining')
weightTraining(r'WeightTraining'),
@JsonValue(r'Hike')
hike(r'Hike'),
@JsonValue(r'Walk')
walk(r'Walk'),
@JsonValue(r'AlpineSki')
alpineSki(r'AlpineSki'),
@JsonValue(r'BackcountrySki')
backcountrySki(r'BackcountrySki'),
@JsonValue(r'Badminton')
badminton(r'Badminton'),
@JsonValue(r'Canoeing')
canoeing(r'Canoeing'),
@JsonValue(r'Crossfit')
crossfit(r'Crossfit'),
@JsonValue(r'EBikeRide')
eBikeRide(r'EBikeRide'),
@JsonValue(r'EMountainBikeRide')
eMountainBikeRide(r'EMountainBikeRide'),
@JsonValue(r'Elliptical')
elliptical(r'Elliptical'),
@JsonValue(r'Golf')
golf(r'Golf'),
@JsonValue(r'GravelRide')
gravelRide(r'GravelRide'),
@JsonValue(r'TrackRide')
trackRide(r'TrackRide'),
@JsonValue(r'Handcycle')
handcycle(r'Handcycle'),
@JsonValue(r'HighIntensityIntervalTraining')
highIntensityIntervalTraining(r'HighIntensityIntervalTraining'),
@JsonValue(r'Hockey')
hockey(r'Hockey'),
@JsonValue(r'IceSkate')
iceSkate(r'IceSkate'),
@JsonValue(r'InlineSkate')
inlineSkate(r'InlineSkate'),
@JsonValue(r'Kayaking')
kayaking(r'Kayaking'),
@JsonValue(r'Kitesurf')
kitesurf(r'Kitesurf'),
@JsonValue(r'MountainBikeRide')
mountainBikeRide(r'MountainBikeRide'),
@JsonValue(r'Cyclocross')
cyclocross(r'Cyclocross'),
@JsonValue(r'NordicSki')
nordicSki(r'NordicSki'),
@JsonValue(r'OpenWaterSwim')
openWaterSwim(r'OpenWaterSwim'),
@JsonValue(r'Padel')
padel(r'Padel'),
@JsonValue(r'Pilates')
pilates(r'Pilates'),
@JsonValue(r'Pickleball')
pickleball(r'Pickleball'),
@JsonValue(r'Racquetball')
racquetball(r'Racquetball'),
@JsonValue(r'Rugby')
rugby(r'Rugby'),
@JsonValue(r'RockClimbing')
rockClimbing(r'RockClimbing'),
@JsonValue(r'RollerSki')
rollerSki(r'RollerSki'),
@JsonValue(r'Rowing')
rowing(r'Rowing'),
@JsonValue(r'Sail')
sail(r'Sail'),
@JsonValue(r'Skateboard')
skateboard(r'Skateboard'),
@JsonValue(r'Snowboard')
snowboard(r'Snowboard'),
@JsonValue(r'Snowshoe')
snowshoe(r'Snowshoe'),
@JsonValue(r'Soccer')
soccer(r'Soccer'),
@JsonValue(r'Squash')
squash(r'Squash'),
@JsonValue(r'StairStepper')
stairStepper(r'StairStepper'),
@JsonValue(r'StandUpPaddling')
standUpPaddling(r'StandUpPaddling'),
@JsonValue(r'Surfing')
surfing(r'Surfing'),
@JsonValue(r'TableTennis')
tableTennis(r'TableTennis'),
@JsonValue(r'Tennis')
tennis(r'Tennis'),
@JsonValue(r'TrailRun')
trailRun(r'TrailRun'),
@JsonValue(r'Transition')
transition(r'Transition'),
@JsonValue(r'Velomobile')
velomobile(r'Velomobile'),
@JsonValue(r'VirtualRide')
virtualRide(r'VirtualRide'),
@JsonValue(r'VirtualRow')
virtualRow(r'VirtualRow'),
@JsonValue(r'VirtualRun')
virtualRun(r'VirtualRun'),
@JsonValue(r'VirtualSki')
virtualSki(r'VirtualSki'),
@JsonValue(r'WaterSport')
waterSport(r'WaterSport'),
@JsonValue(r'Wheelchair')
wheelchair(r'Wheelchair'),
@JsonValue(r'Windsurf')
windsurf(r'Windsurf'),
@JsonValue(r'Workout')
workout(r'Workout'),
@JsonValue(r'Yoga')
yoga(r'Yoga'),
@JsonValue(r'Other')
other(r'Other');

const AthleteUpdateDTOPolarSyncActivityTypesEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOSuuntoSyncActivityTypesEnum {
@JsonValue(r'Ride')
ride(r'Ride'),
@JsonValue(r'Run')
run(r'Run'),
@JsonValue(r'Swim')
swim(r'Swim'),
@JsonValue(r'WeightTraining')
weightTraining(r'WeightTraining'),
@JsonValue(r'Hike')
hike(r'Hike'),
@JsonValue(r'Walk')
walk(r'Walk'),
@JsonValue(r'AlpineSki')
alpineSki(r'AlpineSki'),
@JsonValue(r'BackcountrySki')
backcountrySki(r'BackcountrySki'),
@JsonValue(r'Badminton')
badminton(r'Badminton'),
@JsonValue(r'Canoeing')
canoeing(r'Canoeing'),
@JsonValue(r'Crossfit')
crossfit(r'Crossfit'),
@JsonValue(r'EBikeRide')
eBikeRide(r'EBikeRide'),
@JsonValue(r'EMountainBikeRide')
eMountainBikeRide(r'EMountainBikeRide'),
@JsonValue(r'Elliptical')
elliptical(r'Elliptical'),
@JsonValue(r'Golf')
golf(r'Golf'),
@JsonValue(r'GravelRide')
gravelRide(r'GravelRide'),
@JsonValue(r'TrackRide')
trackRide(r'TrackRide'),
@JsonValue(r'Handcycle')
handcycle(r'Handcycle'),
@JsonValue(r'HighIntensityIntervalTraining')
highIntensityIntervalTraining(r'HighIntensityIntervalTraining'),
@JsonValue(r'Hockey')
hockey(r'Hockey'),
@JsonValue(r'IceSkate')
iceSkate(r'IceSkate'),
@JsonValue(r'InlineSkate')
inlineSkate(r'InlineSkate'),
@JsonValue(r'Kayaking')
kayaking(r'Kayaking'),
@JsonValue(r'Kitesurf')
kitesurf(r'Kitesurf'),
@JsonValue(r'MountainBikeRide')
mountainBikeRide(r'MountainBikeRide'),
@JsonValue(r'Cyclocross')
cyclocross(r'Cyclocross'),
@JsonValue(r'NordicSki')
nordicSki(r'NordicSki'),
@JsonValue(r'OpenWaterSwim')
openWaterSwim(r'OpenWaterSwim'),
@JsonValue(r'Padel')
padel(r'Padel'),
@JsonValue(r'Pilates')
pilates(r'Pilates'),
@JsonValue(r'Pickleball')
pickleball(r'Pickleball'),
@JsonValue(r'Racquetball')
racquetball(r'Racquetball'),
@JsonValue(r'Rugby')
rugby(r'Rugby'),
@JsonValue(r'RockClimbing')
rockClimbing(r'RockClimbing'),
@JsonValue(r'RollerSki')
rollerSki(r'RollerSki'),
@JsonValue(r'Rowing')
rowing(r'Rowing'),
@JsonValue(r'Sail')
sail(r'Sail'),
@JsonValue(r'Skateboard')
skateboard(r'Skateboard'),
@JsonValue(r'Snowboard')
snowboard(r'Snowboard'),
@JsonValue(r'Snowshoe')
snowshoe(r'Snowshoe'),
@JsonValue(r'Soccer')
soccer(r'Soccer'),
@JsonValue(r'Squash')
squash(r'Squash'),
@JsonValue(r'StairStepper')
stairStepper(r'StairStepper'),
@JsonValue(r'StandUpPaddling')
standUpPaddling(r'StandUpPaddling'),
@JsonValue(r'Surfing')
surfing(r'Surfing'),
@JsonValue(r'TableTennis')
tableTennis(r'TableTennis'),
@JsonValue(r'Tennis')
tennis(r'Tennis'),
@JsonValue(r'TrailRun')
trailRun(r'TrailRun'),
@JsonValue(r'Transition')
transition(r'Transition'),
@JsonValue(r'Velomobile')
velomobile(r'Velomobile'),
@JsonValue(r'VirtualRide')
virtualRide(r'VirtualRide'),
@JsonValue(r'VirtualRow')
virtualRow(r'VirtualRow'),
@JsonValue(r'VirtualRun')
virtualRun(r'VirtualRun'),
@JsonValue(r'VirtualSki')
virtualSki(r'VirtualSki'),
@JsonValue(r'WaterSport')
waterSport(r'WaterSport'),
@JsonValue(r'Wheelchair')
wheelchair(r'Wheelchair'),
@JsonValue(r'Windsurf')
windsurf(r'Windsurf'),
@JsonValue(r'Workout')
workout(r'Workout'),
@JsonValue(r'Yoga')
yoga(r'Yoga'),
@JsonValue(r'Other')
other(r'Other');

const AthleteUpdateDTOSuuntoSyncActivityTypesEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOEmailNotificationsEnum {
@JsonValue(r'NEWSLETTER')
NEWSLETTER(r'NEWSLETTER'),
@JsonValue(r'ACHIEVEMENTS')
ACHIEVEMENTS(r'ACHIEVEMENTS'),
@JsonValue(r'FOLLOW_REQUEST')
FOLLOW_REQUEST(r'FOLLOW_REQUEST'),
@JsonValue(r'COACH_ME_REQUEST')
COACH_ME_REQUEST(r'COACH_ME_REQUEST'),
@JsonValue(r'PRIVATE_CHAT')
PRIVATE_CHAT(r'PRIVATE_CHAT'),
@JsonValue(r'PRIVATE_MSG')
PRIVATE_MSG(r'PRIVATE_MSG'),
@JsonValue(r'GROUP_CHAT')
GROUP_CHAT(r'GROUP_CHAT'),
@JsonValue(r'GROUP_MSG')
GROUP_MSG(r'GROUP_MSG'),
@JsonValue(r'ACTIVITY_CHAT')
ACTIVITY_CHAT(r'ACTIVITY_CHAT'),
@JsonValue(r'ACTIVITY_MSG')
ACTIVITY_MSG(r'ACTIVITY_MSG'),
@JsonValue(r'COACH_TICK')
COACH_TICK(r'COACH_TICK'),
@JsonValue(r'FOLLOWED_ACTIVITY_CHAT')
FOLLOWED_ACTIVITY_CHAT(r'FOLLOWED_ACTIVITY_CHAT'),
@JsonValue(r'COACHED_ACTIVITY_CHAT')
COACHED_ACTIVITY_CHAT(r'COACHED_ACTIVITY_CHAT'),
@JsonValue(r'FOLLOWED_NEW_ACTIVITY')
FOLLOWED_NEW_ACTIVITY(r'FOLLOWED_NEW_ACTIVITY'),
@JsonValue(r'COACHED_NEW_ACTIVITY')
COACHED_NEW_ACTIVITY(r'COACHED_NEW_ACTIVITY'),
@JsonValue(r'GEAR_ALERTS')
GEAR_ALERTS(r'GEAR_ALERTS'),
@JsonValue(r'PLAN_FOR_WEEK')
PLAN_FOR_WEEK(r'PLAN_FOR_WEEK'),
@JsonValue(r'NEW_ACTIVITY')
NEW_ACTIVITY(r'NEW_ACTIVITY');

const AthleteUpdateDTOEmailNotificationsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOPushNotificationsEnum {
@JsonValue(r'NEWSLETTER')
NEWSLETTER(r'NEWSLETTER'),
@JsonValue(r'ACHIEVEMENTS')
ACHIEVEMENTS(r'ACHIEVEMENTS'),
@JsonValue(r'FOLLOW_REQUEST')
FOLLOW_REQUEST(r'FOLLOW_REQUEST'),
@JsonValue(r'COACH_ME_REQUEST')
COACH_ME_REQUEST(r'COACH_ME_REQUEST'),
@JsonValue(r'PRIVATE_CHAT')
PRIVATE_CHAT(r'PRIVATE_CHAT'),
@JsonValue(r'PRIVATE_MSG')
PRIVATE_MSG(r'PRIVATE_MSG'),
@JsonValue(r'GROUP_CHAT')
GROUP_CHAT(r'GROUP_CHAT'),
@JsonValue(r'GROUP_MSG')
GROUP_MSG(r'GROUP_MSG'),
@JsonValue(r'ACTIVITY_CHAT')
ACTIVITY_CHAT(r'ACTIVITY_CHAT'),
@JsonValue(r'ACTIVITY_MSG')
ACTIVITY_MSG(r'ACTIVITY_MSG'),
@JsonValue(r'COACH_TICK')
COACH_TICK(r'COACH_TICK'),
@JsonValue(r'FOLLOWED_ACTIVITY_CHAT')
FOLLOWED_ACTIVITY_CHAT(r'FOLLOWED_ACTIVITY_CHAT'),
@JsonValue(r'COACHED_ACTIVITY_CHAT')
COACHED_ACTIVITY_CHAT(r'COACHED_ACTIVITY_CHAT'),
@JsonValue(r'FOLLOWED_NEW_ACTIVITY')
FOLLOWED_NEW_ACTIVITY(r'FOLLOWED_NEW_ACTIVITY'),
@JsonValue(r'COACHED_NEW_ACTIVITY')
COACHED_NEW_ACTIVITY(r'COACHED_NEW_ACTIVITY'),
@JsonValue(r'GEAR_ALERTS')
GEAR_ALERTS(r'GEAR_ALERTS'),
@JsonValue(r'PLAN_FOR_WEEK')
PLAN_FOR_WEEK(r'PLAN_FOR_WEEK'),
@JsonValue(r'NEW_ACTIVITY')
NEW_ACTIVITY(r'NEW_ACTIVITY');

const AthleteUpdateDTOPushNotificationsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOStravaSyncActivityTypesEnum {
@JsonValue(r'Ride')
ride(r'Ride'),
@JsonValue(r'Run')
run(r'Run'),
@JsonValue(r'Swim')
swim(r'Swim'),
@JsonValue(r'WeightTraining')
weightTraining(r'WeightTraining'),
@JsonValue(r'Hike')
hike(r'Hike'),
@JsonValue(r'Walk')
walk(r'Walk'),
@JsonValue(r'AlpineSki')
alpineSki(r'AlpineSki'),
@JsonValue(r'BackcountrySki')
backcountrySki(r'BackcountrySki'),
@JsonValue(r'Badminton')
badminton(r'Badminton'),
@JsonValue(r'Canoeing')
canoeing(r'Canoeing'),
@JsonValue(r'Crossfit')
crossfit(r'Crossfit'),
@JsonValue(r'EBikeRide')
eBikeRide(r'EBikeRide'),
@JsonValue(r'EMountainBikeRide')
eMountainBikeRide(r'EMountainBikeRide'),
@JsonValue(r'Elliptical')
elliptical(r'Elliptical'),
@JsonValue(r'Golf')
golf(r'Golf'),
@JsonValue(r'GravelRide')
gravelRide(r'GravelRide'),
@JsonValue(r'TrackRide')
trackRide(r'TrackRide'),
@JsonValue(r'Handcycle')
handcycle(r'Handcycle'),
@JsonValue(r'HighIntensityIntervalTraining')
highIntensityIntervalTraining(r'HighIntensityIntervalTraining'),
@JsonValue(r'Hockey')
hockey(r'Hockey'),
@JsonValue(r'IceSkate')
iceSkate(r'IceSkate'),
@JsonValue(r'InlineSkate')
inlineSkate(r'InlineSkate'),
@JsonValue(r'Kayaking')
kayaking(r'Kayaking'),
@JsonValue(r'Kitesurf')
kitesurf(r'Kitesurf'),
@JsonValue(r'MountainBikeRide')
mountainBikeRide(r'MountainBikeRide'),
@JsonValue(r'Cyclocross')
cyclocross(r'Cyclocross'),
@JsonValue(r'NordicSki')
nordicSki(r'NordicSki'),
@JsonValue(r'OpenWaterSwim')
openWaterSwim(r'OpenWaterSwim'),
@JsonValue(r'Padel')
padel(r'Padel'),
@JsonValue(r'Pilates')
pilates(r'Pilates'),
@JsonValue(r'Pickleball')
pickleball(r'Pickleball'),
@JsonValue(r'Racquetball')
racquetball(r'Racquetball'),
@JsonValue(r'Rugby')
rugby(r'Rugby'),
@JsonValue(r'RockClimbing')
rockClimbing(r'RockClimbing'),
@JsonValue(r'RollerSki')
rollerSki(r'RollerSki'),
@JsonValue(r'Rowing')
rowing(r'Rowing'),
@JsonValue(r'Sail')
sail(r'Sail'),
@JsonValue(r'Skateboard')
skateboard(r'Skateboard'),
@JsonValue(r'Snowboard')
snowboard(r'Snowboard'),
@JsonValue(r'Snowshoe')
snowshoe(r'Snowshoe'),
@JsonValue(r'Soccer')
soccer(r'Soccer'),
@JsonValue(r'Squash')
squash(r'Squash'),
@JsonValue(r'StairStepper')
stairStepper(r'StairStepper'),
@JsonValue(r'StandUpPaddling')
standUpPaddling(r'StandUpPaddling'),
@JsonValue(r'Surfing')
surfing(r'Surfing'),
@JsonValue(r'TableTennis')
tableTennis(r'TableTennis'),
@JsonValue(r'Tennis')
tennis(r'Tennis'),
@JsonValue(r'TrailRun')
trailRun(r'TrailRun'),
@JsonValue(r'Transition')
transition(r'Transition'),
@JsonValue(r'Velomobile')
velomobile(r'Velomobile'),
@JsonValue(r'VirtualRide')
virtualRide(r'VirtualRide'),
@JsonValue(r'VirtualRow')
virtualRow(r'VirtualRow'),
@JsonValue(r'VirtualRun')
virtualRun(r'VirtualRun'),
@JsonValue(r'VirtualSki')
virtualSki(r'VirtualSki'),
@JsonValue(r'WaterSport')
waterSport(r'WaterSport'),
@JsonValue(r'Wheelchair')
wheelchair(r'Wheelchair'),
@JsonValue(r'Windsurf')
windsurf(r'Windsurf'),
@JsonValue(r'Workout')
workout(r'Workout'),
@JsonValue(r'Yoga')
yoga(r'Yoga'),
@JsonValue(r'Other')
other(r'Other');

const AthleteUpdateDTOStravaSyncActivityTypesEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOHeightUnitsEnum {
@JsonValue(r'CM')
CM(r'CM'),
@JsonValue(r'FEET')
FEET(r'FEET');

const AthleteUpdateDTOHeightUnitsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteUpdateDTOPlanEnum {
@JsonValue(r'FREE')
FREE(r'FREE'),
@JsonValue(r'PREMIUM')
PREMIUM(r'PREMIUM'),
@JsonValue(r'SUPPORTER')
SUPPORTER(r'SUPPORTER'),
@JsonValue(r'WHITELABEL')
WHITELABEL(r'WHITELABEL');

const AthleteUpdateDTOPlanEnum(this.value);

final String value;

@override
String toString() => value;
}


