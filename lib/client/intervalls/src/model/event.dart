//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/attachment.dart';
import 'package:triiq/client/intervalls/src/model/push_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Event {
  /// Returns a new [Event] instance.
  Event({
    this.id,

    this.startDateLocal,

    this.icuTrainingLoad,

    this.icuAtl,

    this.icuCtl,

    this.type,

    this.carbsUsed,

    this.ssPMax,

    this.ssWPrime,

    this.ssCp,

    this.calendarId,

    this.uid,

    this.athleteId,

    this.category,

    this.endDateLocal,

    this.name,

    this.description,

    this.indoor,

    this.color,

    this.movingTime,

    this.icuFtp,

    this.wPrime,

    this.pMax,

    this.atlDays,

    this.ctlDays,

    this.updated,

    this.notOnFitnessChart,

    this.showAsNote,

    this.showOnCtlLine,

    this.forWeek,

    this.target,

    this.joules,

    this.joulesAboveFtp,

    this.workoutDoc,

    this.pushErrors,

    this.athleteCannotEdit,

    this.hideFromAthlete,

    this.structureReadOnly,

    this.createdById,

    this.sharedEventId,

    this.entered,

    this.carbsPerHour,

    this.subType,

    this.distance,

    this.tags,

    this.attachments,

    this.oauthClientId,

    this.externalId,

    this.loadTarget,

    this.timeTarget,

    this.distanceTarget,

    this.trainingAvailability,

    this.maxTrainingTime,

    this.canTrainSports,

    this.planAthleteId,

    this.planFolderId,

    this.planWorkoutId,

    this.planApplied,

    this.icuIntensity,

    this.strainScore,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'start_date_local', required: false, includeIfNull: false)
  final String? startDateLocal;

  @JsonKey(name: r'icu_training_load', required: false, includeIfNull: false)
  final int? icuTrainingLoad;

  @JsonKey(name: r'icu_atl', required: false, includeIfNull: false)
  final double? icuAtl;

  @JsonKey(name: r'icu_ctl', required: false, includeIfNull: false)
  final double? icuCtl;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final String? type;

  @JsonKey(name: r'carbs_used', required: false, includeIfNull: false)
  final int? carbsUsed;

  @JsonKey(name: r'ss_p_max', required: false, includeIfNull: false)
  final double? ssPMax;

  @JsonKey(name: r'ss_w_prime', required: false, includeIfNull: false)
  final double? ssWPrime;

  @JsonKey(name: r'ss_cp', required: false, includeIfNull: false)
  final double? ssCp;

  @JsonKey(name: r'calendar_id', required: false, includeIfNull: false)
  final int? calendarId;

  @JsonKey(name: r'uid', required: false, includeIfNull: false)
  final String? uid;

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final EventCategoryEnum? category;

  @JsonKey(name: r'end_date_local', required: false, includeIfNull: false)
  final String? endDateLocal;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'indoor', required: false, includeIfNull: false)
  final bool? indoor;

  @JsonKey(name: r'color', required: false, includeIfNull: false)
  final String? color;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'icu_ftp', required: false, includeIfNull: false)
  final int? icuFtp;

  @JsonKey(name: r'w_prime', required: false, includeIfNull: false)
  final int? wPrime;

  @JsonKey(name: r'p_max', required: false, includeIfNull: false)
  final int? pMax;

  @JsonKey(name: r'atl_days', required: false, includeIfNull: false)
  final int? atlDays;

  @JsonKey(name: r'ctl_days', required: false, includeIfNull: false)
  final int? ctlDays;

  @JsonKey(name: r'updated', required: false, includeIfNull: false)
  final DateTime? updated;

  @JsonKey(name: r'not_on_fitness_chart', required: false, includeIfNull: false)
  final bool? notOnFitnessChart;

  @JsonKey(name: r'show_as_note', required: false, includeIfNull: false)
  final bool? showAsNote;

  @JsonKey(name: r'show_on_ctl_line', required: false, includeIfNull: false)
  final bool? showOnCtlLine;

  @JsonKey(name: r'for_week', required: false, includeIfNull: false)
  final bool? forWeek;

  @JsonKey(name: r'target', required: false, includeIfNull: false)
  final EventTargetEnum? target;

  @JsonKey(name: r'joules', required: false, includeIfNull: false)
  final int? joules;

  @JsonKey(name: r'joules_above_ftp', required: false, includeIfNull: false)
  final int? joulesAboveFtp;

  @JsonKey(name: r'workout_doc', required: false, includeIfNull: false)
  final Map<String, Object?>? workoutDoc;

  @JsonKey(name: r'push_errors', required: false, includeIfNull: false)
  final List<PushError>? pushErrors;

  @JsonKey(name: r'athlete_cannot_edit', required: false, includeIfNull: false)
  final bool? athleteCannotEdit;

  @JsonKey(name: r'hide_from_athlete', required: false, includeIfNull: false)
  final bool? hideFromAthlete;

  @JsonKey(name: r'structure_read_only', required: false, includeIfNull: false)
  final bool? structureReadOnly;

  @JsonKey(name: r'created_by_id', required: false, includeIfNull: false)
  final String? createdById;

  @JsonKey(name: r'shared_event_id', required: false, includeIfNull: false)
  final int? sharedEventId;

  @JsonKey(name: r'entered', required: false, includeIfNull: false)
  final bool? entered;

  @JsonKey(name: r'carbs_per_hour', required: false, includeIfNull: false)
  final int? carbsPerHour;

  @JsonKey(name: r'sub_type', required: false, includeIfNull: false)
  final EventSubTypeEnum? subType;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'tags', required: false, includeIfNull: false)
  final List<String>? tags;

  @JsonKey(name: r'attachments', required: false, includeIfNull: false)
  final List<Attachment>? attachments;

  @JsonKey(name: r'oauth_client_id', required: false, includeIfNull: false)
  final int? oauthClientId;

  @JsonKey(name: r'external_id', required: false, includeIfNull: false)
  final String? externalId;

  @JsonKey(name: r'load_target', required: false, includeIfNull: false)
  final int? loadTarget;

  @JsonKey(name: r'time_target', required: false, includeIfNull: false)
  final int? timeTarget;

  @JsonKey(name: r'distance_target', required: false, includeIfNull: false)
  final double? distanceTarget;

  @JsonKey(
    name: r'training_availability',
    required: false,
    includeIfNull: false,
  )
  final EventTrainingAvailabilityEnum? trainingAvailability;

  @JsonKey(name: r'max_training_time', required: false, includeIfNull: false)
  final int? maxTrainingTime;

  @JsonKey(name: r'can_train_sports', required: false, includeIfNull: false)
  final List<EventCanTrainSportsEnum>? canTrainSports;

  @JsonKey(name: r'plan_athlete_id', required: false, includeIfNull: false)
  final String? planAthleteId;

  @JsonKey(name: r'plan_folder_id', required: false, includeIfNull: false)
  final int? planFolderId;

  @JsonKey(name: r'plan_workout_id', required: false, includeIfNull: false)
  final int? planWorkoutId;

  @JsonKey(name: r'plan_applied', required: false, includeIfNull: false)
  final DateTime? planApplied;

  @JsonKey(name: r'icu_intensity', required: false, includeIfNull: false)
  final double? icuIntensity;

  @JsonKey(name: r'strain_score', required: false, includeIfNull: false)
  final double? strainScore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          other.id == id &&
          other.startDateLocal == startDateLocal &&
          other.icuTrainingLoad == icuTrainingLoad &&
          other.icuAtl == icuAtl &&
          other.icuCtl == icuCtl &&
          other.type == type &&
          other.carbsUsed == carbsUsed &&
          other.ssPMax == ssPMax &&
          other.ssWPrime == ssWPrime &&
          other.ssCp == ssCp &&
          other.calendarId == calendarId &&
          other.uid == uid &&
          other.athleteId == athleteId &&
          other.category == category &&
          other.endDateLocal == endDateLocal &&
          other.name == name &&
          other.description == description &&
          other.indoor == indoor &&
          other.color == color &&
          other.movingTime == movingTime &&
          other.icuFtp == icuFtp &&
          other.wPrime == wPrime &&
          other.pMax == pMax &&
          other.atlDays == atlDays &&
          other.ctlDays == ctlDays &&
          other.updated == updated &&
          other.notOnFitnessChart == notOnFitnessChart &&
          other.showAsNote == showAsNote &&
          other.showOnCtlLine == showOnCtlLine &&
          other.forWeek == forWeek &&
          other.target == target &&
          other.joules == joules &&
          other.joulesAboveFtp == joulesAboveFtp &&
          other.workoutDoc == workoutDoc &&
          other.pushErrors == pushErrors &&
          other.athleteCannotEdit == athleteCannotEdit &&
          other.hideFromAthlete == hideFromAthlete &&
          other.structureReadOnly == structureReadOnly &&
          other.createdById == createdById &&
          other.sharedEventId == sharedEventId &&
          other.entered == entered &&
          other.carbsPerHour == carbsPerHour &&
          other.subType == subType &&
          other.distance == distance &&
          other.tags == tags &&
          other.attachments == attachments &&
          other.oauthClientId == oauthClientId &&
          other.externalId == externalId &&
          other.loadTarget == loadTarget &&
          other.timeTarget == timeTarget &&
          other.distanceTarget == distanceTarget &&
          other.trainingAvailability == trainingAvailability &&
          other.maxTrainingTime == maxTrainingTime &&
          other.canTrainSports == canTrainSports &&
          other.planAthleteId == planAthleteId &&
          other.planFolderId == planFolderId &&
          other.planWorkoutId == planWorkoutId &&
          other.planApplied == planApplied &&
          other.icuIntensity == icuIntensity &&
          other.strainScore == strainScore;

  @override
  int get hashCode =>
      id.hashCode +
      startDateLocal.hashCode +
      icuTrainingLoad.hashCode +
      icuAtl.hashCode +
      icuCtl.hashCode +
      type.hashCode +
      carbsUsed.hashCode +
      ssPMax.hashCode +
      ssWPrime.hashCode +
      ssCp.hashCode +
      calendarId.hashCode +
      uid.hashCode +
      athleteId.hashCode +
      category.hashCode +
      endDateLocal.hashCode +
      name.hashCode +
      description.hashCode +
      indoor.hashCode +
      color.hashCode +
      movingTime.hashCode +
      icuFtp.hashCode +
      wPrime.hashCode +
      pMax.hashCode +
      atlDays.hashCode +
      ctlDays.hashCode +
      updated.hashCode +
      notOnFitnessChart.hashCode +
      showAsNote.hashCode +
      showOnCtlLine.hashCode +
      forWeek.hashCode +
      target.hashCode +
      joules.hashCode +
      joulesAboveFtp.hashCode +
      workoutDoc.hashCode +
      pushErrors.hashCode +
      athleteCannotEdit.hashCode +
      hideFromAthlete.hashCode +
      structureReadOnly.hashCode +
      createdById.hashCode +
      sharedEventId.hashCode +
      entered.hashCode +
      carbsPerHour.hashCode +
      subType.hashCode +
      distance.hashCode +
      tags.hashCode +
      attachments.hashCode +
      oauthClientId.hashCode +
      externalId.hashCode +
      loadTarget.hashCode +
      timeTarget.hashCode +
      distanceTarget.hashCode +
      trainingAvailability.hashCode +
      maxTrainingTime.hashCode +
      canTrainSports.hashCode +
      planAthleteId.hashCode +
      planFolderId.hashCode +
      planWorkoutId.hashCode +
      planApplied.hashCode +
      icuIntensity.hashCode +
      strainScore.hashCode;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventCategoryEnum {
  @JsonValue(r'WORKOUT')
  WORKOUT(r'WORKOUT'),
  @JsonValue(r'RACE_A')
  RACE_A(r'RACE_A'),
  @JsonValue(r'RACE_B')
  RACE_B(r'RACE_B'),
  @JsonValue(r'RACE_C')
  RACE_C(r'RACE_C'),
  @JsonValue(r'NOTE')
  NOTE(r'NOTE'),
  @JsonValue(r'PLAN')
  PLAN(r'PLAN'),
  @JsonValue(r'HOLIDAY')
  HOLIDAY(r'HOLIDAY'),
  @JsonValue(r'SICK')
  SICK(r'SICK'),
  @JsonValue(r'INJURED')
  INJURED(r'INJURED'),
  @JsonValue(r'SET_EFTP')
  SET_EFTP(r'SET_EFTP'),
  @JsonValue(r'FITNESS_DAYS')
  FITNESS_DAYS(r'FITNESS_DAYS'),
  @JsonValue(r'SEASON_START')
  SEASON_START(r'SEASON_START'),
  @JsonValue(r'TARGET')
  TARGET(r'TARGET'),
  @JsonValue(r'SET_FITNESS')
  SET_FITNESS(r'SET_FITNESS');

  const EventCategoryEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventTargetEnum {
  @JsonValue(r'AUTO')
  AUTO(r'AUTO'),
  @JsonValue(r'POWER')
  POWER(r'POWER'),
  @JsonValue(r'HR')
  HR(r'HR'),
  @JsonValue(r'PACE')
  PACE(r'PACE');

  const EventTargetEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventSubTypeEnum {
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

  const EventSubTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventTrainingAvailabilityEnum {
  @JsonValue(r'NORMAL')
  NORMAL(r'NORMAL'),
  @JsonValue(r'LIMITED')
  LIMITED(r'LIMITED'),
  @JsonValue(r'UNAVAILABLE')
  UNAVAILABLE(r'UNAVAILABLE');

  const EventTrainingAvailabilityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventCanTrainSportsEnum {
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

  const EventCanTrainSportsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
