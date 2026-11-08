//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/power_model.dart';
import 'package:triiq/client/intervalls/src/model/activity_charts.dart';
import 'package:triiq/client/intervalls/src/model/display.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sport_settings.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SportSettings {
  /// Returns a new [SportSettings] instance.
  SportSettings({
    this.id,

    this.athleteId,

    this.types,

    this.warmupTime,

    this.cooldownTime,

    this.ftp,

    this.indoorFtp,

    this.wPrime,

    this.pMax,

    this.powerZones,

    this.sweetSpotMin,

    this.sweetSpotMax,

    this.powerSpikeThreshold,

    this.powerZoneNames,

    this.ftpEstMinSecs,

    this.useLapsForPowerIntervals,

    this.keepAllLapsForPowerIntervals,

    this.powerIntervalsStartLocked,

    this.afterKj0,

    this.afterKj1,

    this.powerField,

    this.lthr,

    this.maxHr,

    this.hrZones,

    this.hrZoneNames,

    this.hrLoadType,

    this.hrrcMinPercent,

    this.thresholdPace,

    this.paceUnits,

    this.paceZones,

    this.paceZoneNames,

    this.paceLoadType,

    this.gapModel,

    this.elevationCorrection,

    this.useGapZoneTimes,

    this.bestEffortDistances,

    this.paceCurveStart,

    this.loadOrder,

    this.tizOrder,

    this.workoutOrder,

    this.intervalDisplay,

    this.defaultGearId,

    this.defaultIndoorGearId,

    this.extractWorkouts,

    this.showPauses,

    this.ignoreVelocity,

    this.defaultWorkoutTime,

    this.updateActivityNameFromWorkout,

    this.created,

    this.updated,

    this.mmpModel,

    this.display,

    this.activityFieldIds,

    this.activityCharts,

    this.customFieldIds,

    this.customFieldValues,

    this.customZonesIds,

    this.calendarTileActivityPanelId,

    this.other,

    this.iseFTPSupported,

    this.useDistanceForIntervals,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'types', required: false, includeIfNull: false)
  final List<SportSettingsTypesEnum>? types;

  @JsonKey(name: r'warmup_time', required: false, includeIfNull: false)
  final int? warmupTime;

  @JsonKey(name: r'cooldown_time', required: false, includeIfNull: false)
  final int? cooldownTime;

  @JsonKey(name: r'ftp', required: false, includeIfNull: false)
  final int? ftp;

  @JsonKey(name: r'indoor_ftp', required: false, includeIfNull: false)
  final int? indoorFtp;

  @JsonKey(name: r'w_prime', required: false, includeIfNull: false)
  final int? wPrime;

  @JsonKey(name: r'p_max', required: false, includeIfNull: false)
  final int? pMax;

  @JsonKey(name: r'power_zones', required: false, includeIfNull: false)
  final List<int>? powerZones;

  @JsonKey(name: r'sweet_spot_min', required: false, includeIfNull: false)
  final int? sweetSpotMin;

  @JsonKey(name: r'sweet_spot_max', required: false, includeIfNull: false)
  final int? sweetSpotMax;

  @JsonKey(
    name: r'power_spike_threshold',
    required: false,
    includeIfNull: false,
  )
  final int? powerSpikeThreshold;

  @JsonKey(name: r'power_zone_names', required: false, includeIfNull: false)
  final List<String>? powerZoneNames;

  @JsonKey(name: r'ftp_est_min_secs', required: false, includeIfNull: false)
  final int? ftpEstMinSecs;

  @JsonKey(
    name: r'use_laps_for_power_intervals',
    required: false,
    includeIfNull: false,
  )
  final bool? useLapsForPowerIntervals;

  @JsonKey(
    name: r'keep_all_laps_for_power_intervals',
    required: false,
    includeIfNull: false,
  )
  final bool? keepAllLapsForPowerIntervals;

  @JsonKey(
    name: r'power_intervals_start_locked',
    required: false,
    includeIfNull: false,
  )
  final bool? powerIntervalsStartLocked;

  @JsonKey(name: r'after_kj0', required: false, includeIfNull: false)
  final int? afterKj0;

  @JsonKey(name: r'after_kj1', required: false, includeIfNull: false)
  final int? afterKj1;

  @JsonKey(name: r'power_field', required: false, includeIfNull: false)
  final String? powerField;

  @JsonKey(name: r'lthr', required: false, includeIfNull: false)
  final int? lthr;

  @JsonKey(name: r'max_hr', required: false, includeIfNull: false)
  final int? maxHr;

  @JsonKey(name: r'hr_zones', required: false, includeIfNull: false)
  final List<int>? hrZones;

  @JsonKey(name: r'hr_zone_names', required: false, includeIfNull: false)
  final List<String>? hrZoneNames;

  @JsonKey(name: r'hr_load_type', required: false, includeIfNull: false)
  final SportSettingsHrLoadTypeEnum? hrLoadType;

  @JsonKey(name: r'hrrc_min_percent', required: false, includeIfNull: false)
  final double? hrrcMinPercent;

  @JsonKey(name: r'threshold_pace', required: false, includeIfNull: false)
  final double? thresholdPace;

  @JsonKey(name: r'pace_units', required: false, includeIfNull: false)
  final SportSettingsPaceUnitsEnum? paceUnits;

  @JsonKey(name: r'pace_zones', required: false, includeIfNull: false)
  final List<double>? paceZones;

  @JsonKey(name: r'pace_zone_names', required: false, includeIfNull: false)
  final List<String>? paceZoneNames;

  @JsonKey(name: r'pace_load_type', required: false, includeIfNull: false)
  final SportSettingsPaceLoadTypeEnum? paceLoadType;

  @JsonKey(name: r'gap_model', required: false, includeIfNull: false)
  final SportSettingsGapModelEnum? gapModel;

  @JsonKey(name: r'elevation_correction', required: false, includeIfNull: false)
  final SportSettingsElevationCorrectionEnum? elevationCorrection;

  @JsonKey(name: r'use_gap_zone_times', required: false, includeIfNull: false)
  final bool? useGapZoneTimes;

  @JsonKey(
    name: r'best_effort_distances',
    required: false,
    includeIfNull: false,
  )
  final List<double>? bestEffortDistances;

  @JsonKey(name: r'pace_curve_start', required: false, includeIfNull: false)
  final double? paceCurveStart;

  @JsonKey(name: r'load_order', required: false, includeIfNull: false)
  final SportSettingsLoadOrderEnum? loadOrder;

  @JsonKey(name: r'tiz_order', required: false, includeIfNull: false)
  final SportSettingsTizOrderEnum? tizOrder;

  @JsonKey(name: r'workout_order', required: false, includeIfNull: false)
  final SportSettingsWorkoutOrderEnum? workoutOrder;

  @JsonKey(name: r'interval_display', required: false, includeIfNull: false)
  final SportSettingsIntervalDisplayEnum? intervalDisplay;

  @JsonKey(name: r'default_gear_id', required: false, includeIfNull: false)
  final String? defaultGearId;

  @JsonKey(
    name: r'default_indoor_gear_id',
    required: false,
    includeIfNull: false,
  )
  final String? defaultIndoorGearId;

  @JsonKey(name: r'extract_workouts', required: false, includeIfNull: false)
  final bool? extractWorkouts;

  @JsonKey(name: r'show_pauses', required: false, includeIfNull: false)
  final int? showPauses;

  @JsonKey(name: r'ignore_velocity', required: false, includeIfNull: false)
  final bool? ignoreVelocity;

  @JsonKey(name: r'default_workout_time', required: false, includeIfNull: false)
  final String? defaultWorkoutTime;

  @JsonKey(
    name: r'update_activity_name_from_workout',
    required: false,
    includeIfNull: false,
  )
  final bool? updateActivityNameFromWorkout;

  @JsonKey(name: r'created', required: false, includeIfNull: false)
  final DateTime? created;

  @JsonKey(name: r'updated', required: false, includeIfNull: false)
  final DateTime? updated;

  @JsonKey(name: r'mmp_model', required: false, includeIfNull: false)
  final PowerModel? mmpModel;

  @JsonKey(name: r'display', required: false, includeIfNull: false)
  final Display? display;

  @JsonKey(name: r'activity_field_ids', required: false, includeIfNull: false)
  final List<int>? activityFieldIds;

  @JsonKey(name: r'activity_charts', required: false, includeIfNull: false)
  final ActivityCharts? activityCharts;

  @JsonKey(name: r'custom_field_ids', required: false, includeIfNull: false)
  final List<int>? customFieldIds;

  @JsonKey(name: r'custom_field_values', required: false, includeIfNull: false)
  final Map<String, Object>? customFieldValues;

  @JsonKey(name: r'custom_zones_ids', required: false, includeIfNull: false)
  final List<int>? customZonesIds;

  @JsonKey(
    name: r'calendar_tile_activity_panel_id',
    required: false,
    includeIfNull: false,
  )
  final int? calendarTileActivityPanelId;

  @JsonKey(name: r'other', required: false, includeIfNull: false)
  final bool? other;

  @JsonKey(name: r'iseFTPSupported', required: false, includeIfNull: false)
  final bool? iseFTPSupported;

  @JsonKey(
    name: r'use_distance_for_intervals',
    required: false,
    includeIfNull: false,
  )
  final bool? useDistanceForIntervals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SportSettings &&
          other.id == id &&
          other.athleteId == athleteId &&
          other.types == types &&
          other.warmupTime == warmupTime &&
          other.cooldownTime == cooldownTime &&
          other.ftp == ftp &&
          other.indoorFtp == indoorFtp &&
          other.wPrime == wPrime &&
          other.pMax == pMax &&
          other.powerZones == powerZones &&
          other.sweetSpotMin == sweetSpotMin &&
          other.sweetSpotMax == sweetSpotMax &&
          other.powerSpikeThreshold == powerSpikeThreshold &&
          other.powerZoneNames == powerZoneNames &&
          other.ftpEstMinSecs == ftpEstMinSecs &&
          other.useLapsForPowerIntervals == useLapsForPowerIntervals &&
          other.keepAllLapsForPowerIntervals == keepAllLapsForPowerIntervals &&
          other.powerIntervalsStartLocked == powerIntervalsStartLocked &&
          other.afterKj0 == afterKj0 &&
          other.afterKj1 == afterKj1 &&
          other.powerField == powerField &&
          other.lthr == lthr &&
          other.maxHr == maxHr &&
          other.hrZones == hrZones &&
          other.hrZoneNames == hrZoneNames &&
          other.hrLoadType == hrLoadType &&
          other.hrrcMinPercent == hrrcMinPercent &&
          other.thresholdPace == thresholdPace &&
          other.paceUnits == paceUnits &&
          other.paceZones == paceZones &&
          other.paceZoneNames == paceZoneNames &&
          other.paceLoadType == paceLoadType &&
          other.gapModel == gapModel &&
          other.elevationCorrection == elevationCorrection &&
          other.useGapZoneTimes == useGapZoneTimes &&
          other.bestEffortDistances == bestEffortDistances &&
          other.paceCurveStart == paceCurveStart &&
          other.loadOrder == loadOrder &&
          other.tizOrder == tizOrder &&
          other.workoutOrder == workoutOrder &&
          other.intervalDisplay == intervalDisplay &&
          other.defaultGearId == defaultGearId &&
          other.defaultIndoorGearId == defaultIndoorGearId &&
          other.extractWorkouts == extractWorkouts &&
          other.showPauses == showPauses &&
          other.ignoreVelocity == ignoreVelocity &&
          other.defaultWorkoutTime == defaultWorkoutTime &&
          other.updateActivityNameFromWorkout ==
              updateActivityNameFromWorkout &&
          other.created == created &&
          other.updated == updated &&
          other.mmpModel == mmpModel &&
          other.display == display &&
          other.activityFieldIds == activityFieldIds &&
          other.activityCharts == activityCharts &&
          other.customFieldIds == customFieldIds &&
          other.customFieldValues == customFieldValues &&
          other.customZonesIds == customZonesIds &&
          other.calendarTileActivityPanelId == calendarTileActivityPanelId &&
          other.other == other &&
          other.iseFTPSupported == iseFTPSupported &&
          other.useDistanceForIntervals == useDistanceForIntervals;

  @override
  int get hashCode =>
      id.hashCode +
      athleteId.hashCode +
      types.hashCode +
      warmupTime.hashCode +
      cooldownTime.hashCode +
      ftp.hashCode +
      indoorFtp.hashCode +
      wPrime.hashCode +
      pMax.hashCode +
      powerZones.hashCode +
      sweetSpotMin.hashCode +
      sweetSpotMax.hashCode +
      powerSpikeThreshold.hashCode +
      powerZoneNames.hashCode +
      ftpEstMinSecs.hashCode +
      useLapsForPowerIntervals.hashCode +
      keepAllLapsForPowerIntervals.hashCode +
      powerIntervalsStartLocked.hashCode +
      afterKj0.hashCode +
      afterKj1.hashCode +
      powerField.hashCode +
      lthr.hashCode +
      maxHr.hashCode +
      hrZones.hashCode +
      hrZoneNames.hashCode +
      hrLoadType.hashCode +
      hrrcMinPercent.hashCode +
      thresholdPace.hashCode +
      paceUnits.hashCode +
      paceZones.hashCode +
      paceZoneNames.hashCode +
      paceLoadType.hashCode +
      gapModel.hashCode +
      elevationCorrection.hashCode +
      useGapZoneTimes.hashCode +
      bestEffortDistances.hashCode +
      paceCurveStart.hashCode +
      loadOrder.hashCode +
      tizOrder.hashCode +
      workoutOrder.hashCode +
      intervalDisplay.hashCode +
      defaultGearId.hashCode +
      defaultIndoorGearId.hashCode +
      extractWorkouts.hashCode +
      showPauses.hashCode +
      ignoreVelocity.hashCode +
      defaultWorkoutTime.hashCode +
      updateActivityNameFromWorkout.hashCode +
      created.hashCode +
      updated.hashCode +
      mmpModel.hashCode +
      display.hashCode +
      activityFieldIds.hashCode +
      activityCharts.hashCode +
      customFieldIds.hashCode +
      customFieldValues.hashCode +
      customZonesIds.hashCode +
      calendarTileActivityPanelId.hashCode +
      other.hashCode +
      iseFTPSupported.hashCode +
      useDistanceForIntervals.hashCode;

  factory SportSettings.fromJson(Map<String, dynamic> json) =>
      _$SportSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SportSettingsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum SportSettingsTypesEnum {
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

  const SportSettingsTypesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsHrLoadTypeEnum {
  @JsonValue(r'AVG_HR')
  AVG_HR(r'AVG_HR'),
  @JsonValue(r'HR_ZONES')
  HR_ZONES(r'HR_ZONES'),
  @JsonValue(r'HRSS')
  HRSS(r'HRSS');

  const SportSettingsHrLoadTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsPaceUnitsEnum {
  @JsonValue(r'SECS_100M')
  SECS_100M(r'SECS_100M'),
  @JsonValue(r'SECS_100Y')
  SECS_100Y(r'SECS_100Y'),
  @JsonValue(r'MINS_KM')
  MINS_KM(r'MINS_KM'),
  @JsonValue(r'MINS_MILE')
  MINS_MILE(r'MINS_MILE'),
  @JsonValue(r'SECS_500M')
  SECS_500M(r'SECS_500M'),
  @JsonValue(r'SECS_400M')
  SECS_400M(r'SECS_400M'),
  @JsonValue(r'SECS_250M')
  SECS_250M(r'SECS_250M'),
  @JsonValue(r'NONE')
  NONE(r'NONE');

  const SportSettingsPaceUnitsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsPaceLoadTypeEnum {
  @JsonValue(r'SWIM')
  SWIM(r'SWIM'),
  @JsonValue(r'RUN')
  RUN(r'RUN');

  const SportSettingsPaceLoadTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsGapModelEnum {
  @JsonValue(r'NONE')
  NONE(r'NONE'),
  @JsonValue(r'STRAVA_RUN')
  STRAVA_RUN(r'STRAVA_RUN');

  const SportSettingsGapModelEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsElevationCorrectionEnum {
  @JsonValue(r'NO')
  NO(r'NO'),
  @JsonValue(r'AUTO')
  AUTO(r'AUTO'),
  @JsonValue(r'YES')
  YES(r'YES');

  const SportSettingsElevationCorrectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsLoadOrderEnum {
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

  const SportSettingsLoadOrderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsTizOrderEnum {
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

  const SportSettingsTizOrderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsWorkoutOrderEnum {
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

  const SportSettingsWorkoutOrderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum SportSettingsIntervalDisplayEnum {
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

  const SportSettingsIntervalDisplayEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
