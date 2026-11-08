//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/hidden.dart';
import 'package:triiq/client/intervalls/src/model/interval_group.dart';
import 'package:triiq/client/intervalls/src/model/attachment.dart';
import 'package:triiq/client/intervalls/src/model/icu_achievement.dart';
import 'package:triiq/client/intervalls/src/model/zone_time.dart';
import 'package:triiq/client/intervalls/src/model/activity_with_intervals.dart';
import 'package:triiq/client/intervalls/src/model/activity_analysis_issue.dart';
import 'package:triiq/client/intervalls/src/model/ignore.dart';
import 'package:triiq/client/intervalls/src/model/activity.dart';
import 'package:triiq/client/intervalls/src/model/interval.dart';
import 'package:triiq/client/intervalls/src/model/hr_recovery.dart';
import 'package:triiq/client/intervalls/src/model/strava_gear.dart';
import 'package:triiq/client/intervalls/src/model/zone_set.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_activity_default_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GetActivityDefaultResponse {
  /// Returns a new [GetActivityDefaultResponse] instance.
  GetActivityDefaultResponse({
    this.id,

    this.startDateLocal,

    this.type,

    this.icuIgnoreTime,

    this.icuPmCp,

    this.icuPmWPrime,

    this.icuPmPMax,

    this.icuPmFtp,

    this.icuPmFtpSecs,

    this.icuPmFtpWatts,

    this.icuIgnorePower,

    this.icuRollingCp,

    this.icuRollingWPrime,

    this.icuRollingPMax,

    this.icuRollingFtp,

    this.icuRollingFtpDelta,

    this.icuTrainingLoad,

    this.icuAtl,

    this.icuCtl,

    this.ssPMax,

    this.ssWPrime,

    this.ssCp,

    this.pairedEventId,

    this.icuFtp,

    this.icuJoules,

    this.icuRecordingTime,

    this.elapsedTime,

    this.icuWeightedAvgWatts,

    this.carbsUsed,

    this.name,

    this.description,

    this.startDate,

    this.distance,

    this.icuDistance,

    this.movingTime,

    this.coastingTime,

    this.totalElevationGain,

    this.totalElevationLoss,

    this.timezone,

    this.trainer,

    this.subType,

    this.commute,

    this.race,

    this.maxSpeed,

    this.averageSpeed,

    this.deviceWatts,

    this.hasHeartrate,

    this.maxHeartrate,

    this.averageHeartrate,

    this.averageCadence,

    this.calories,

    this.averageTemp,

    this.minTemp,

    this.maxTemp,

    this.avgLrBalance,

    this.averageStanceTime,

    this.averageVerticalOscillation,

    this.averageVerticalRatio,

    this.averageStepLength,

    this.averageStanceTimePercent,

    this.averageStanceTimeBalance,

    this.averageVerticalSpeed,

    this.averageLegSpringStiffness,

    this.averageImpactLoadingRate,

    this.gap,

    this.gapModel,

    this.useElevationCorrection,

    this.gear,

    this.perceivedExertion,

    this.deviceName,

    this.powerMeter,

    this.powerMeterSerial,

    this.powerMeterBattery,

    this.crankLength,

    this.externalId,

    this.fileSportIndex,

    this.fileType,

    this.icuAthleteId,

    this.created,

    this.icuSyncDate,

    this.analyzed,

    this.icuWPrime,

    this.pMax,

    this.thresholdPace,

    this.icuHrZones,

    this.paceZones,

    this.lthr,

    this.icuRestingHr,

    this.icuWeight,

    this.icuPowerZones,

    this.icuSweetSpotMin,

    this.icuSweetSpotMax,

    this.icuPowerSpikeThreshold,

    this.trimp,

    this.icuWarmupTime,

    this.icuCooldownTime,

    this.icuChatId,

    this.icuIgnoreHr,

    this.ignoreVelocity,

    this.ignorePace,

    this.ignoreParts,

    this.icuTrainingLoadData,

    this.intervalSummary,

    this.skylineChartBytes,

    this.streamTypes,

    this.hasWeather,

    this.hasSegments,

    this.powerFieldNames,

    this.powerField,

    this.icuZoneTimes,

    this.icuHrZoneTimes,

    this.paceZoneTimes,

    this.gapZoneTimes,

    this.useGapZoneTimes,

    this.customZones,

    this.tizOrder,

    this.polarizationIndex,

    this.icuAchievements,

    this.icuIntervalsEdited,

    this.lockIntervals,

    this.icuLapCount,

    this.icuJoulesAboveFtp,

    this.icuMaxWbalDepletion,

    this.icuHrr,

    this.icuSyncError,

    this.icuColor,

    this.icuPowerHrZ2,

    this.icuPowerHrZ2Mins,

    this.icuCadenceZ2,

    this.icuRpe,

    this.feel,

    this.kgLifted,

    this.decoupling,

    this.icuMedianTimeDelta,

    this.p30sExponent,

    this.workoutShiftSecs,

    this.stravaId,

    this.lengths,

    this.poolLength,

    this.compliance,

    this.coachTick,

    this.source_,

    this.oauthClientId,

    this.oauthClientName,

    this.averageAltitude,

    this.minAltitude,

    this.maxAltitude,

    this.powerLoad,

    this.hrLoad,

    this.paceLoad,

    this.hrLoadType,

    this.paceLoadType,

    this.tags,

    this.attachments,

    this.recordingStops,

    this.averageWeatherTemp,

    this.minWeatherTemp,

    this.maxWeatherTemp,

    this.averageFeelsLike,

    this.minFeelsLike,

    this.maxFeelsLike,

    this.averageWindSpeed,

    this.averageWindGust,

    this.prevailingWindDeg,

    this.headwindPercent,

    this.tailwindPercent,

    this.averageClouds,

    this.maxRain,

    this.maxSnow,

    this.carbsIngested,

    this.routeId,

    this.analysisIssues,

    this.icuIntensity,

    this.pace,

    this.icuEfficiencyFactor,

    this.athleteMaxHr,

    this.group,

    this.icuPowerHr,

    this.sessionRpe,

    this.averageStride,

    this.icuAverageWatts,

    this.icuVariabilityIndex,

    this.strainScore,

    this.icuIntervals,

    this.icuGroups,

    this.note,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'start_date_local', required: false, includeIfNull: false)
  final String? startDateLocal;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final String? type;

  @JsonKey(name: r'icu_ignore_time', required: false, includeIfNull: false)
  final bool? icuIgnoreTime;

  @JsonKey(name: r'icu_pm_cp', required: false, includeIfNull: false)
  final int? icuPmCp;

  @JsonKey(name: r'icu_pm_w_prime', required: false, includeIfNull: false)
  final int? icuPmWPrime;

  @JsonKey(name: r'icu_pm_p_max', required: false, includeIfNull: false)
  final int? icuPmPMax;

  @JsonKey(name: r'icu_pm_ftp', required: false, includeIfNull: false)
  final int? icuPmFtp;

  @JsonKey(name: r'icu_pm_ftp_secs', required: false, includeIfNull: false)
  final int? icuPmFtpSecs;

  @JsonKey(name: r'icu_pm_ftp_watts', required: false, includeIfNull: false)
  final int? icuPmFtpWatts;

  @JsonKey(name: r'icu_ignore_power', required: false, includeIfNull: false)
  final bool? icuIgnorePower;

  @JsonKey(name: r'icu_rolling_cp', required: false, includeIfNull: false)
  final double? icuRollingCp;

  @JsonKey(name: r'icu_rolling_w_prime', required: false, includeIfNull: false)
  final double? icuRollingWPrime;

  @JsonKey(name: r'icu_rolling_p_max', required: false, includeIfNull: false)
  final double? icuRollingPMax;

  @JsonKey(name: r'icu_rolling_ftp', required: false, includeIfNull: false)
  final int? icuRollingFtp;

  @JsonKey(
    name: r'icu_rolling_ftp_delta',
    required: false,
    includeIfNull: false,
  )
  final int? icuRollingFtpDelta;

  @JsonKey(name: r'icu_training_load', required: false, includeIfNull: false)
  final int? icuTrainingLoad;

  @JsonKey(name: r'icu_atl', required: false, includeIfNull: false)
  final double? icuAtl;

  @JsonKey(name: r'icu_ctl', required: false, includeIfNull: false)
  final double? icuCtl;

  @JsonKey(name: r'ss_p_max', required: false, includeIfNull: false)
  final double? ssPMax;

  @JsonKey(name: r'ss_w_prime', required: false, includeIfNull: false)
  final double? ssWPrime;

  @JsonKey(name: r'ss_cp', required: false, includeIfNull: false)
  final double? ssCp;

  @JsonKey(name: r'paired_event_id', required: false, includeIfNull: false)
  final int? pairedEventId;

  @JsonKey(name: r'icu_ftp', required: false, includeIfNull: false)
  final int? icuFtp;

  @JsonKey(name: r'icu_joules', required: false, includeIfNull: false)
  final int? icuJoules;

  @JsonKey(name: r'icu_recording_time', required: false, includeIfNull: false)
  final int? icuRecordingTime;

  @JsonKey(name: r'elapsed_time', required: false, includeIfNull: false)
  final int? elapsedTime;

  @JsonKey(
    name: r'icu_weighted_avg_watts',
    required: false,
    includeIfNull: false,
  )
  final int? icuWeightedAvgWatts;

  @JsonKey(name: r'carbs_used', required: false, includeIfNull: false)
  final int? carbsUsed;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'start_date', required: false, includeIfNull: false)
  final String? startDate;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'icu_distance', required: false, includeIfNull: false)
  final double? icuDistance;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'coasting_time', required: false, includeIfNull: false)
  final int? coastingTime;

  @JsonKey(name: r'total_elevation_gain', required: false, includeIfNull: false)
  final double? totalElevationGain;

  @JsonKey(name: r'total_elevation_loss', required: false, includeIfNull: false)
  final double? totalElevationLoss;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'trainer', required: false, includeIfNull: false)
  final bool? trainer;

  @JsonKey(name: r'sub_type', required: false, includeIfNull: false)
  final GetActivityDefaultResponseSubTypeEnum? subType;

  @JsonKey(name: r'commute', required: false, includeIfNull: false)
  final bool? commute;

  @JsonKey(name: r'race', required: false, includeIfNull: false)
  final bool? race;

  @JsonKey(name: r'max_speed', required: false, includeIfNull: false)
  final double? maxSpeed;

  @JsonKey(name: r'average_speed', required: false, includeIfNull: false)
  final double? averageSpeed;

  @JsonKey(name: r'device_watts', required: false, includeIfNull: false)
  final bool? deviceWatts;

  @JsonKey(name: r'has_heartrate', required: false, includeIfNull: false)
  final bool? hasHeartrate;

  @JsonKey(name: r'max_heartrate', required: false, includeIfNull: false)
  final int? maxHeartrate;

  @JsonKey(name: r'average_heartrate', required: false, includeIfNull: false)
  final int? averageHeartrate;

  @JsonKey(name: r'average_cadence', required: false, includeIfNull: false)
  final double? averageCadence;

  @JsonKey(name: r'calories', required: false, includeIfNull: false)
  final int? calories;

  @JsonKey(name: r'average_temp', required: false, includeIfNull: false)
  final double? averageTemp;

  @JsonKey(name: r'min_temp', required: false, includeIfNull: false)
  final int? minTemp;

  @JsonKey(name: r'max_temp', required: false, includeIfNull: false)
  final int? maxTemp;

  @JsonKey(name: r'avg_lr_balance', required: false, includeIfNull: false)
  final double? avgLrBalance;

  @JsonKey(name: r'average_stance_time', required: false, includeIfNull: false)
  final double? averageStanceTime;

  @JsonKey(
    name: r'average_vertical_oscillation',
    required: false,
    includeIfNull: false,
  )
  final double? averageVerticalOscillation;

  @JsonKey(
    name: r'average_vertical_ratio',
    required: false,
    includeIfNull: false,
  )
  final double? averageVerticalRatio;

  @JsonKey(name: r'average_step_length', required: false, includeIfNull: false)
  final double? averageStepLength;

  @JsonKey(
    name: r'average_stance_time_percent',
    required: false,
    includeIfNull: false,
  )
  final double? averageStanceTimePercent;

  @JsonKey(
    name: r'average_stance_time_balance',
    required: false,
    includeIfNull: false,
  )
  final double? averageStanceTimeBalance;

  @JsonKey(
    name: r'average_vertical_speed',
    required: false,
    includeIfNull: false,
  )
  final double? averageVerticalSpeed;

  @JsonKey(
    name: r'average_leg_spring_stiffness',
    required: false,
    includeIfNull: false,
  )
  final double? averageLegSpringStiffness;

  @JsonKey(
    name: r'average_impact_loading_rate',
    required: false,
    includeIfNull: false,
  )
  final double? averageImpactLoadingRate;

  @JsonKey(name: r'gap', required: false, includeIfNull: false)
  final double? gap;

  @JsonKey(name: r'gap_model', required: false, includeIfNull: false)
  final GetActivityDefaultResponseGapModelEnum? gapModel;

  @JsonKey(
    name: r'use_elevation_correction',
    required: false,
    includeIfNull: false,
  )
  final bool? useElevationCorrection;

  @JsonKey(name: r'gear', required: false, includeIfNull: false)
  final StravaGear? gear;

  @JsonKey(name: r'perceived_exertion', required: false, includeIfNull: false)
  final double? perceivedExertion;

  @JsonKey(name: r'device_name', required: false, includeIfNull: false)
  final String? deviceName;

  @JsonKey(name: r'power_meter', required: false, includeIfNull: false)
  final String? powerMeter;

  @JsonKey(name: r'power_meter_serial', required: false, includeIfNull: false)
  final String? powerMeterSerial;

  @JsonKey(name: r'power_meter_battery', required: false, includeIfNull: false)
  final String? powerMeterBattery;

  @JsonKey(name: r'crank_length', required: false, includeIfNull: false)
  final double? crankLength;

  @JsonKey(name: r'external_id', required: false, includeIfNull: false)
  final String? externalId;

  @JsonKey(name: r'file_sport_index', required: false, includeIfNull: false)
  final int? fileSportIndex;

  @JsonKey(name: r'file_type', required: false, includeIfNull: false)
  final String? fileType;

  @JsonKey(name: r'icu_athlete_id', required: false, includeIfNull: false)
  final String? icuAthleteId;

  @JsonKey(name: r'created', required: false, includeIfNull: false)
  final DateTime? created;

  @JsonKey(name: r'icu_sync_date', required: false, includeIfNull: false)
  final DateTime? icuSyncDate;

  @JsonKey(name: r'analyzed', required: false, includeIfNull: false)
  final DateTime? analyzed;

  @JsonKey(name: r'icu_w_prime', required: false, includeIfNull: false)
  final int? icuWPrime;

  @JsonKey(name: r'p_max', required: false, includeIfNull: false)
  final int? pMax;

  @JsonKey(name: r'threshold_pace', required: false, includeIfNull: false)
  final double? thresholdPace;

  @JsonKey(name: r'icu_hr_zones', required: false, includeIfNull: false)
  final List<int>? icuHrZones;

  @JsonKey(name: r'pace_zones', required: false, includeIfNull: false)
  final List<double>? paceZones;

  @JsonKey(name: r'lthr', required: false, includeIfNull: false)
  final int? lthr;

  @JsonKey(name: r'icu_resting_hr', required: false, includeIfNull: false)
  final int? icuRestingHr;

  @JsonKey(name: r'icu_weight', required: false, includeIfNull: false)
  final double? icuWeight;

  @JsonKey(name: r'icu_power_zones', required: false, includeIfNull: false)
  final List<int>? icuPowerZones;

  @JsonKey(name: r'icu_sweet_spot_min', required: false, includeIfNull: false)
  final int? icuSweetSpotMin;

  @JsonKey(name: r'icu_sweet_spot_max', required: false, includeIfNull: false)
  final int? icuSweetSpotMax;

  @JsonKey(
    name: r'icu_power_spike_threshold',
    required: false,
    includeIfNull: false,
  )
  final int? icuPowerSpikeThreshold;

  @JsonKey(name: r'trimp', required: false, includeIfNull: false)
  final double? trimp;

  @JsonKey(name: r'icu_warmup_time', required: false, includeIfNull: false)
  final int? icuWarmupTime;

  @JsonKey(name: r'icu_cooldown_time', required: false, includeIfNull: false)
  final int? icuCooldownTime;

  @JsonKey(name: r'icu_chat_id', required: false, includeIfNull: false)
  final int? icuChatId;

  @JsonKey(name: r'icu_ignore_hr', required: false, includeIfNull: false)
  final bool? icuIgnoreHr;

  @JsonKey(name: r'ignore_velocity', required: false, includeIfNull: false)
  final bool? ignoreVelocity;

  @JsonKey(name: r'ignore_pace', required: false, includeIfNull: false)
  final bool? ignorePace;

  @JsonKey(name: r'ignore_parts', required: false, includeIfNull: false)
  final List<Ignore>? ignoreParts;

  @JsonKey(
    name: r'icu_training_load_data',
    required: false,
    includeIfNull: false,
  )
  final int? icuTrainingLoadData;

  @JsonKey(name: r'interval_summary', required: false, includeIfNull: false)
  final List<String>? intervalSummary;

  @JsonKey(name: r'skyline_chart_bytes', required: false, includeIfNull: false)
  final String? skylineChartBytes;

  @JsonKey(name: r'stream_types', required: false, includeIfNull: false)
  final List<String>? streamTypes;

  @JsonKey(name: r'has_weather', required: false, includeIfNull: false)
  final bool? hasWeather;

  @JsonKey(name: r'has_segments', required: false, includeIfNull: false)
  final bool? hasSegments;

  @JsonKey(name: r'power_field_names', required: false, includeIfNull: false)
  final List<String>? powerFieldNames;

  @JsonKey(name: r'power_field', required: false, includeIfNull: false)
  final String? powerField;

  @JsonKey(name: r'icu_zone_times', required: false, includeIfNull: false)
  final List<ZoneTime>? icuZoneTimes;

  @JsonKey(name: r'icu_hr_zone_times', required: false, includeIfNull: false)
  final List<int>? icuHrZoneTimes;

  @JsonKey(name: r'pace_zone_times', required: false, includeIfNull: false)
  final List<int>? paceZoneTimes;

  @JsonKey(name: r'gap_zone_times', required: false, includeIfNull: false)
  final List<int>? gapZoneTimes;

  @JsonKey(name: r'use_gap_zone_times', required: false, includeIfNull: false)
  final bool? useGapZoneTimes;

  @JsonKey(name: r'custom_zones', required: false, includeIfNull: false)
  final List<ZoneSet>? customZones;

  @JsonKey(name: r'tiz_order', required: false, includeIfNull: false)
  final GetActivityDefaultResponseTizOrderEnum? tizOrder;

  @JsonKey(name: r'polarization_index', required: false, includeIfNull: false)
  final double? polarizationIndex;

  @JsonKey(name: r'icu_achievements', required: false, includeIfNull: false)
  final List<IcuAchievement>? icuAchievements;

  @JsonKey(name: r'icu_intervals_edited', required: false, includeIfNull: false)
  final bool? icuIntervalsEdited;

  @JsonKey(name: r'lock_intervals', required: false, includeIfNull: false)
  final bool? lockIntervals;

  @JsonKey(name: r'icu_lap_count', required: false, includeIfNull: false)
  final int? icuLapCount;

  @JsonKey(name: r'icu_joules_above_ftp', required: false, includeIfNull: false)
  final int? icuJoulesAboveFtp;

  @JsonKey(
    name: r'icu_max_wbal_depletion',
    required: false,
    includeIfNull: false,
  )
  final int? icuMaxWbalDepletion;

  @JsonKey(name: r'icu_hrr', required: false, includeIfNull: false)
  final HRRecovery? icuHrr;

  @JsonKey(name: r'icu_sync_error', required: false, includeIfNull: false)
  final String? icuSyncError;

  @JsonKey(name: r'icu_color', required: false, includeIfNull: false)
  final String? icuColor;

  @JsonKey(name: r'icu_power_hr_z2', required: false, includeIfNull: false)
  final double? icuPowerHrZ2;

  @JsonKey(name: r'icu_power_hr_z2_mins', required: false, includeIfNull: false)
  final int? icuPowerHrZ2Mins;

  @JsonKey(name: r'icu_cadence_z2', required: false, includeIfNull: false)
  final int? icuCadenceZ2;

  @JsonKey(name: r'icu_rpe', required: false, includeIfNull: false)
  final int? icuRpe;

  @JsonKey(name: r'feel', required: false, includeIfNull: false)
  final int? feel;

  @JsonKey(name: r'kg_lifted', required: false, includeIfNull: false)
  final double? kgLifted;

  @JsonKey(name: r'decoupling', required: false, includeIfNull: false)
  final double? decoupling;

  @JsonKey(
    name: r'icu_median_time_delta',
    required: false,
    includeIfNull: false,
  )
  final int? icuMedianTimeDelta;

  @JsonKey(name: r'p30s_exponent', required: false, includeIfNull: false)
  final double? p30sExponent;

  @JsonKey(name: r'workout_shift_secs', required: false, includeIfNull: false)
  final int? workoutShiftSecs;

  @JsonKey(name: r'strava_id', required: false, includeIfNull: false)
  final String? stravaId;

  @JsonKey(name: r'lengths', required: false, includeIfNull: false)
  final int? lengths;

  @JsonKey(name: r'pool_length', required: false, includeIfNull: false)
  final double? poolLength;

  @JsonKey(name: r'compliance', required: false, includeIfNull: false)
  final double? compliance;

  @JsonKey(name: r'coach_tick', required: false, includeIfNull: false)
  final int? coachTick;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final GetActivityDefaultResponseSource_Enum? source_;

  @JsonKey(name: r'oauth_client_id', required: false, includeIfNull: false)
  final int? oauthClientId;

  @JsonKey(name: r'oauth_client_name', required: false, includeIfNull: false)
  final String? oauthClientName;

  @JsonKey(name: r'average_altitude', required: false, includeIfNull: false)
  final double? averageAltitude;

  @JsonKey(name: r'min_altitude', required: false, includeIfNull: false)
  final double? minAltitude;

  @JsonKey(name: r'max_altitude', required: false, includeIfNull: false)
  final double? maxAltitude;

  @JsonKey(name: r'power_load', required: false, includeIfNull: false)
  final int? powerLoad;

  @JsonKey(name: r'hr_load', required: false, includeIfNull: false)
  final int? hrLoad;

  @JsonKey(name: r'pace_load', required: false, includeIfNull: false)
  final int? paceLoad;

  @JsonKey(name: r'hr_load_type', required: false, includeIfNull: false)
  final GetActivityDefaultResponseHrLoadTypeEnum? hrLoadType;

  @JsonKey(name: r'pace_load_type', required: false, includeIfNull: false)
  final GetActivityDefaultResponsePaceLoadTypeEnum? paceLoadType;

  @JsonKey(name: r'tags', required: false, includeIfNull: false)
  final List<String>? tags;

  @JsonKey(name: r'attachments', required: false, includeIfNull: false)
  final List<Attachment>? attachments;

  @JsonKey(name: r'recording_stops', required: false, includeIfNull: false)
  final List<int>? recordingStops;

  @JsonKey(name: r'average_weather_temp', required: false, includeIfNull: false)
  final double? averageWeatherTemp;

  @JsonKey(name: r'min_weather_temp', required: false, includeIfNull: false)
  final double? minWeatherTemp;

  @JsonKey(name: r'max_weather_temp', required: false, includeIfNull: false)
  final double? maxWeatherTemp;

  @JsonKey(name: r'average_feels_like', required: false, includeIfNull: false)
  final double? averageFeelsLike;

  @JsonKey(name: r'min_feels_like', required: false, includeIfNull: false)
  final double? minFeelsLike;

  @JsonKey(name: r'max_feels_like', required: false, includeIfNull: false)
  final double? maxFeelsLike;

  @JsonKey(name: r'average_wind_speed', required: false, includeIfNull: false)
  final double? averageWindSpeed;

  @JsonKey(name: r'average_wind_gust', required: false, includeIfNull: false)
  final double? averageWindGust;

  @JsonKey(name: r'prevailing_wind_deg', required: false, includeIfNull: false)
  final int? prevailingWindDeg;

  @JsonKey(name: r'headwind_percent', required: false, includeIfNull: false)
  final double? headwindPercent;

  @JsonKey(name: r'tailwind_percent', required: false, includeIfNull: false)
  final double? tailwindPercent;

  @JsonKey(name: r'average_clouds', required: false, includeIfNull: false)
  final int? averageClouds;

  @JsonKey(name: r'max_rain', required: false, includeIfNull: false)
  final double? maxRain;

  @JsonKey(name: r'max_snow', required: false, includeIfNull: false)
  final double? maxSnow;

  @JsonKey(name: r'carbs_ingested', required: false, includeIfNull: false)
  final int? carbsIngested;

  @JsonKey(name: r'route_id', required: false, includeIfNull: false)
  final int? routeId;

  @JsonKey(name: r'analysis_issues', required: false, includeIfNull: false)
  final List<ActivityAnalysisIssue>? analysisIssues;

  @JsonKey(name: r'icu_intensity', required: false, includeIfNull: false)
  final double? icuIntensity;

  @JsonKey(name: r'pace', required: false, includeIfNull: false)
  final double? pace;

  @JsonKey(
    name: r'icu_efficiency_factor',
    required: false,
    includeIfNull: false,
  )
  final double? icuEfficiencyFactor;

  @JsonKey(name: r'athlete_max_hr', required: false, includeIfNull: false)
  final int? athleteMaxHr;

  @JsonKey(name: r'group', required: false, includeIfNull: false)
  final String? group;

  @JsonKey(name: r'icu_power_hr', required: false, includeIfNull: false)
  final double? icuPowerHr;

  @JsonKey(name: r'session_rpe', required: false, includeIfNull: false)
  final int? sessionRpe;

  @JsonKey(name: r'average_stride', required: false, includeIfNull: false)
  final double? averageStride;

  @JsonKey(name: r'icu_average_watts', required: false, includeIfNull: false)
  final int? icuAverageWatts;

  @JsonKey(
    name: r'icu_variability_index',
    required: false,
    includeIfNull: false,
  )
  final double? icuVariabilityIndex;

  @JsonKey(name: r'strain_score', required: false, includeIfNull: false)
  final double? strainScore;

  @JsonKey(name: r'icu_intervals', required: false, includeIfNull: false)
  final List<Interval>? icuIntervals;

  @JsonKey(name: r'icu_groups', required: false, includeIfNull: false)
  final List<IntervalGroup>? icuGroups;

  @JsonKey(name: r'_note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetActivityDefaultResponse &&
          other.id == id &&
          other.startDateLocal == startDateLocal &&
          other.type == type &&
          other.icuIgnoreTime == icuIgnoreTime &&
          other.icuPmCp == icuPmCp &&
          other.icuPmWPrime == icuPmWPrime &&
          other.icuPmPMax == icuPmPMax &&
          other.icuPmFtp == icuPmFtp &&
          other.icuPmFtpSecs == icuPmFtpSecs &&
          other.icuPmFtpWatts == icuPmFtpWatts &&
          other.icuIgnorePower == icuIgnorePower &&
          other.icuRollingCp == icuRollingCp &&
          other.icuRollingWPrime == icuRollingWPrime &&
          other.icuRollingPMax == icuRollingPMax &&
          other.icuRollingFtp == icuRollingFtp &&
          other.icuRollingFtpDelta == icuRollingFtpDelta &&
          other.icuTrainingLoad == icuTrainingLoad &&
          other.icuAtl == icuAtl &&
          other.icuCtl == icuCtl &&
          other.ssPMax == ssPMax &&
          other.ssWPrime == ssWPrime &&
          other.ssCp == ssCp &&
          other.pairedEventId == pairedEventId &&
          other.icuFtp == icuFtp &&
          other.icuJoules == icuJoules &&
          other.icuRecordingTime == icuRecordingTime &&
          other.elapsedTime == elapsedTime &&
          other.icuWeightedAvgWatts == icuWeightedAvgWatts &&
          other.carbsUsed == carbsUsed &&
          other.name == name &&
          other.description == description &&
          other.startDate == startDate &&
          other.distance == distance &&
          other.icuDistance == icuDistance &&
          other.movingTime == movingTime &&
          other.coastingTime == coastingTime &&
          other.totalElevationGain == totalElevationGain &&
          other.totalElevationLoss == totalElevationLoss &&
          other.timezone == timezone &&
          other.trainer == trainer &&
          other.subType == subType &&
          other.commute == commute &&
          other.race == race &&
          other.maxSpeed == maxSpeed &&
          other.averageSpeed == averageSpeed &&
          other.deviceWatts == deviceWatts &&
          other.hasHeartrate == hasHeartrate &&
          other.maxHeartrate == maxHeartrate &&
          other.averageHeartrate == averageHeartrate &&
          other.averageCadence == averageCadence &&
          other.calories == calories &&
          other.averageTemp == averageTemp &&
          other.minTemp == minTemp &&
          other.maxTemp == maxTemp &&
          other.avgLrBalance == avgLrBalance &&
          other.averageStanceTime == averageStanceTime &&
          other.averageVerticalOscillation == averageVerticalOscillation &&
          other.averageVerticalRatio == averageVerticalRatio &&
          other.averageStepLength == averageStepLength &&
          other.averageStanceTimePercent == averageStanceTimePercent &&
          other.averageStanceTimeBalance == averageStanceTimeBalance &&
          other.averageVerticalSpeed == averageVerticalSpeed &&
          other.averageLegSpringStiffness == averageLegSpringStiffness &&
          other.averageImpactLoadingRate == averageImpactLoadingRate &&
          other.gap == gap &&
          other.gapModel == gapModel &&
          other.useElevationCorrection == useElevationCorrection &&
          other.gear == gear &&
          other.perceivedExertion == perceivedExertion &&
          other.deviceName == deviceName &&
          other.powerMeter == powerMeter &&
          other.powerMeterSerial == powerMeterSerial &&
          other.powerMeterBattery == powerMeterBattery &&
          other.crankLength == crankLength &&
          other.externalId == externalId &&
          other.fileSportIndex == fileSportIndex &&
          other.fileType == fileType &&
          other.icuAthleteId == icuAthleteId &&
          other.created == created &&
          other.icuSyncDate == icuSyncDate &&
          other.analyzed == analyzed &&
          other.icuWPrime == icuWPrime &&
          other.pMax == pMax &&
          other.thresholdPace == thresholdPace &&
          other.icuHrZones == icuHrZones &&
          other.paceZones == paceZones &&
          other.lthr == lthr &&
          other.icuRestingHr == icuRestingHr &&
          other.icuWeight == icuWeight &&
          other.icuPowerZones == icuPowerZones &&
          other.icuSweetSpotMin == icuSweetSpotMin &&
          other.icuSweetSpotMax == icuSweetSpotMax &&
          other.icuPowerSpikeThreshold == icuPowerSpikeThreshold &&
          other.trimp == trimp &&
          other.icuWarmupTime == icuWarmupTime &&
          other.icuCooldownTime == icuCooldownTime &&
          other.icuChatId == icuChatId &&
          other.icuIgnoreHr == icuIgnoreHr &&
          other.ignoreVelocity == ignoreVelocity &&
          other.ignorePace == ignorePace &&
          other.ignoreParts == ignoreParts &&
          other.icuTrainingLoadData == icuTrainingLoadData &&
          other.intervalSummary == intervalSummary &&
          other.skylineChartBytes == skylineChartBytes &&
          other.streamTypes == streamTypes &&
          other.hasWeather == hasWeather &&
          other.hasSegments == hasSegments &&
          other.powerFieldNames == powerFieldNames &&
          other.powerField == powerField &&
          other.icuZoneTimes == icuZoneTimes &&
          other.icuHrZoneTimes == icuHrZoneTimes &&
          other.paceZoneTimes == paceZoneTimes &&
          other.gapZoneTimes == gapZoneTimes &&
          other.useGapZoneTimes == useGapZoneTimes &&
          other.customZones == customZones &&
          other.tizOrder == tizOrder &&
          other.polarizationIndex == polarizationIndex &&
          other.icuAchievements == icuAchievements &&
          other.icuIntervalsEdited == icuIntervalsEdited &&
          other.lockIntervals == lockIntervals &&
          other.icuLapCount == icuLapCount &&
          other.icuJoulesAboveFtp == icuJoulesAboveFtp &&
          other.icuMaxWbalDepletion == icuMaxWbalDepletion &&
          other.icuHrr == icuHrr &&
          other.icuSyncError == icuSyncError &&
          other.icuColor == icuColor &&
          other.icuPowerHrZ2 == icuPowerHrZ2 &&
          other.icuPowerHrZ2Mins == icuPowerHrZ2Mins &&
          other.icuCadenceZ2 == icuCadenceZ2 &&
          other.icuRpe == icuRpe &&
          other.feel == feel &&
          other.kgLifted == kgLifted &&
          other.decoupling == decoupling &&
          other.icuMedianTimeDelta == icuMedianTimeDelta &&
          other.p30sExponent == p30sExponent &&
          other.workoutShiftSecs == workoutShiftSecs &&
          other.stravaId == stravaId &&
          other.lengths == lengths &&
          other.poolLength == poolLength &&
          other.compliance == compliance &&
          other.coachTick == coachTick &&
          other.source_ == source_ &&
          other.oauthClientId == oauthClientId &&
          other.oauthClientName == oauthClientName &&
          other.averageAltitude == averageAltitude &&
          other.minAltitude == minAltitude &&
          other.maxAltitude == maxAltitude &&
          other.powerLoad == powerLoad &&
          other.hrLoad == hrLoad &&
          other.paceLoad == paceLoad &&
          other.hrLoadType == hrLoadType &&
          other.paceLoadType == paceLoadType &&
          other.tags == tags &&
          other.attachments == attachments &&
          other.recordingStops == recordingStops &&
          other.averageWeatherTemp == averageWeatherTemp &&
          other.minWeatherTemp == minWeatherTemp &&
          other.maxWeatherTemp == maxWeatherTemp &&
          other.averageFeelsLike == averageFeelsLike &&
          other.minFeelsLike == minFeelsLike &&
          other.maxFeelsLike == maxFeelsLike &&
          other.averageWindSpeed == averageWindSpeed &&
          other.averageWindGust == averageWindGust &&
          other.prevailingWindDeg == prevailingWindDeg &&
          other.headwindPercent == headwindPercent &&
          other.tailwindPercent == tailwindPercent &&
          other.averageClouds == averageClouds &&
          other.maxRain == maxRain &&
          other.maxSnow == maxSnow &&
          other.carbsIngested == carbsIngested &&
          other.routeId == routeId &&
          other.analysisIssues == analysisIssues &&
          other.icuIntensity == icuIntensity &&
          other.pace == pace &&
          other.icuEfficiencyFactor == icuEfficiencyFactor &&
          other.athleteMaxHr == athleteMaxHr &&
          other.group == group &&
          other.icuPowerHr == icuPowerHr &&
          other.sessionRpe == sessionRpe &&
          other.averageStride == averageStride &&
          other.icuAverageWatts == icuAverageWatts &&
          other.icuVariabilityIndex == icuVariabilityIndex &&
          other.strainScore == strainScore &&
          other.icuIntervals == icuIntervals &&
          other.icuGroups == icuGroups &&
          other.note == note;

  @override
  int get hashCode =>
      id.hashCode +
      startDateLocal.hashCode +
      type.hashCode +
      icuIgnoreTime.hashCode +
      icuPmCp.hashCode +
      icuPmWPrime.hashCode +
      icuPmPMax.hashCode +
      icuPmFtp.hashCode +
      icuPmFtpSecs.hashCode +
      icuPmFtpWatts.hashCode +
      icuIgnorePower.hashCode +
      icuRollingCp.hashCode +
      icuRollingWPrime.hashCode +
      icuRollingPMax.hashCode +
      icuRollingFtp.hashCode +
      icuRollingFtpDelta.hashCode +
      icuTrainingLoad.hashCode +
      icuAtl.hashCode +
      icuCtl.hashCode +
      ssPMax.hashCode +
      ssWPrime.hashCode +
      ssCp.hashCode +
      pairedEventId.hashCode +
      icuFtp.hashCode +
      icuJoules.hashCode +
      icuRecordingTime.hashCode +
      elapsedTime.hashCode +
      icuWeightedAvgWatts.hashCode +
      carbsUsed.hashCode +
      name.hashCode +
      description.hashCode +
      startDate.hashCode +
      distance.hashCode +
      icuDistance.hashCode +
      movingTime.hashCode +
      coastingTime.hashCode +
      totalElevationGain.hashCode +
      totalElevationLoss.hashCode +
      timezone.hashCode +
      trainer.hashCode +
      subType.hashCode +
      commute.hashCode +
      race.hashCode +
      maxSpeed.hashCode +
      averageSpeed.hashCode +
      deviceWatts.hashCode +
      hasHeartrate.hashCode +
      maxHeartrate.hashCode +
      averageHeartrate.hashCode +
      averageCadence.hashCode +
      calories.hashCode +
      averageTemp.hashCode +
      minTemp.hashCode +
      maxTemp.hashCode +
      avgLrBalance.hashCode +
      averageStanceTime.hashCode +
      averageVerticalOscillation.hashCode +
      averageVerticalRatio.hashCode +
      averageStepLength.hashCode +
      averageStanceTimePercent.hashCode +
      averageStanceTimeBalance.hashCode +
      averageVerticalSpeed.hashCode +
      averageLegSpringStiffness.hashCode +
      averageImpactLoadingRate.hashCode +
      gap.hashCode +
      gapModel.hashCode +
      useElevationCorrection.hashCode +
      gear.hashCode +
      perceivedExertion.hashCode +
      deviceName.hashCode +
      powerMeter.hashCode +
      powerMeterSerial.hashCode +
      powerMeterBattery.hashCode +
      crankLength.hashCode +
      externalId.hashCode +
      fileSportIndex.hashCode +
      fileType.hashCode +
      icuAthleteId.hashCode +
      created.hashCode +
      icuSyncDate.hashCode +
      analyzed.hashCode +
      icuWPrime.hashCode +
      pMax.hashCode +
      thresholdPace.hashCode +
      icuHrZones.hashCode +
      paceZones.hashCode +
      lthr.hashCode +
      icuRestingHr.hashCode +
      icuWeight.hashCode +
      icuPowerZones.hashCode +
      icuSweetSpotMin.hashCode +
      icuSweetSpotMax.hashCode +
      icuPowerSpikeThreshold.hashCode +
      trimp.hashCode +
      icuWarmupTime.hashCode +
      icuCooldownTime.hashCode +
      icuChatId.hashCode +
      icuIgnoreHr.hashCode +
      ignoreVelocity.hashCode +
      ignorePace.hashCode +
      ignoreParts.hashCode +
      icuTrainingLoadData.hashCode +
      intervalSummary.hashCode +
      skylineChartBytes.hashCode +
      streamTypes.hashCode +
      hasWeather.hashCode +
      hasSegments.hashCode +
      powerFieldNames.hashCode +
      powerField.hashCode +
      icuZoneTimes.hashCode +
      icuHrZoneTimes.hashCode +
      paceZoneTimes.hashCode +
      gapZoneTimes.hashCode +
      useGapZoneTimes.hashCode +
      customZones.hashCode +
      tizOrder.hashCode +
      polarizationIndex.hashCode +
      icuAchievements.hashCode +
      icuIntervalsEdited.hashCode +
      lockIntervals.hashCode +
      icuLapCount.hashCode +
      icuJoulesAboveFtp.hashCode +
      icuMaxWbalDepletion.hashCode +
      icuHrr.hashCode +
      icuSyncError.hashCode +
      icuColor.hashCode +
      icuPowerHrZ2.hashCode +
      icuPowerHrZ2Mins.hashCode +
      icuCadenceZ2.hashCode +
      icuRpe.hashCode +
      feel.hashCode +
      kgLifted.hashCode +
      decoupling.hashCode +
      icuMedianTimeDelta.hashCode +
      p30sExponent.hashCode +
      workoutShiftSecs.hashCode +
      stravaId.hashCode +
      lengths.hashCode +
      poolLength.hashCode +
      compliance.hashCode +
      coachTick.hashCode +
      source_.hashCode +
      oauthClientId.hashCode +
      oauthClientName.hashCode +
      averageAltitude.hashCode +
      minAltitude.hashCode +
      maxAltitude.hashCode +
      powerLoad.hashCode +
      hrLoad.hashCode +
      paceLoad.hashCode +
      hrLoadType.hashCode +
      paceLoadType.hashCode +
      tags.hashCode +
      attachments.hashCode +
      recordingStops.hashCode +
      averageWeatherTemp.hashCode +
      minWeatherTemp.hashCode +
      maxWeatherTemp.hashCode +
      averageFeelsLike.hashCode +
      minFeelsLike.hashCode +
      maxFeelsLike.hashCode +
      averageWindSpeed.hashCode +
      averageWindGust.hashCode +
      prevailingWindDeg.hashCode +
      headwindPercent.hashCode +
      tailwindPercent.hashCode +
      averageClouds.hashCode +
      maxRain.hashCode +
      maxSnow.hashCode +
      carbsIngested.hashCode +
      routeId.hashCode +
      analysisIssues.hashCode +
      icuIntensity.hashCode +
      pace.hashCode +
      icuEfficiencyFactor.hashCode +
      athleteMaxHr.hashCode +
      group.hashCode +
      icuPowerHr.hashCode +
      sessionRpe.hashCode +
      averageStride.hashCode +
      icuAverageWatts.hashCode +
      icuVariabilityIndex.hashCode +
      strainScore.hashCode +
      icuIntervals.hashCode +
      icuGroups.hashCode +
      note.hashCode;

  factory GetActivityDefaultResponse.fromJson(Map<String, dynamic> json) =>
      _$GetActivityDefaultResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetActivityDefaultResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum GetActivityDefaultResponseSubTypeEnum {
  @JsonValue(r'NONE')
  NONE(r'NONE'),
  @JsonValue(r'COMMUTE')
  COMMUTE(r'COMMUTE'),
  @JsonValue(r'WARMUP')
  WARMUP(r'WARMUP'),
  @JsonValue(r'COOLDOWN')
  COOLDOWN(r'COOLDOWN'),
  @JsonValue(r'RACE')
  RACE(r'RACE');

  const GetActivityDefaultResponseSubTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum GetActivityDefaultResponseGapModelEnum {
  @JsonValue(r'NONE')
  NONE(r'NONE'),
  @JsonValue(r'STRAVA_RUN')
  STRAVA_RUN(r'STRAVA_RUN');

  const GetActivityDefaultResponseGapModelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum GetActivityDefaultResponseTizOrderEnum {
  @JsonValue(r'POWER_HR_PACE')
  POWER_HR_PACE(r'POWER_HR_PACE'),
  @JsonValue(r'POWER_PACE_HR')
  POWER_PACE_HR(r'POWER_PACE_HR'),
  @JsonValue(r'HR_POWER_PACE')
  HR_POWER_PACE(r'HR_POWER_PACE'),
  @JsonValue(r'HR_PACE_POWER')
  HR_PACE_POWER(r'HR_PACE_POWER'),
  @JsonValue(r'PACE_POWER_HR')
  PACE_POWER_HR(r'PACE_POWER_HR'),
  @JsonValue(r'PACE_HR_POWER')
  PACE_HR_POWER(r'PACE_HR_POWER');

  const GetActivityDefaultResponseTizOrderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum GetActivityDefaultResponseSource_Enum {
  @JsonValue(r'STRAVA')
  STRAVA(r'STRAVA'),
  @JsonValue(r'UPLOAD')
  UPLOAD(r'UPLOAD'),
  @JsonValue(r'MANUAL')
  MANUAL(r'MANUAL'),
  @JsonValue(r'GARMIN_CONNECT')
  GARMIN_CONNECT(r'GARMIN_CONNECT'),
  @JsonValue(r'OAUTH_CLIENT')
  OAUTH_CLIENT(r'OAUTH_CLIENT'),
  @JsonValue(r'DROPBOX')
  DROPBOX(r'DROPBOX'),
  @JsonValue(r'POLAR')
  POLAR(r'POLAR'),
  @JsonValue(r'SUUNTO')
  SUUNTO(r'SUUNTO'),
  @JsonValue(r'COROS')
  COROS(r'COROS'),
  @JsonValue(r'WAHOO')
  WAHOO(r'WAHOO'),
  @JsonValue(r'ZWIFT')
  ZWIFT(r'ZWIFT'),
  @JsonValue(r'ZEPP')
  ZEPP(r'ZEPP'),
  @JsonValue(r'CONCEPT2')
  CONCEPT2(r'CONCEPT2'),
  @JsonValue(r'HUAWEI')
  HUAWEI(r'HUAWEI');

  const GetActivityDefaultResponseSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum GetActivityDefaultResponseHrLoadTypeEnum {
  @JsonValue(r'AVG_HR')
  AVG_HR(r'AVG_HR'),
  @JsonValue(r'HR_ZONES')
  HR_ZONES(r'HR_ZONES'),
  @JsonValue(r'HRSS')
  HRSS(r'HRSS');

  const GetActivityDefaultResponseHrLoadTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum GetActivityDefaultResponsePaceLoadTypeEnum {
  @JsonValue(r'SWIM')
  SWIM(r'SWIM'),
  @JsonValue(r'RUN')
  RUN(r'RUN');

  const GetActivityDefaultResponsePaceLoadTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
