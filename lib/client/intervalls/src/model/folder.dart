//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/athlete_search_result.dart';
import 'package:triiq/client/intervalls/src/model/workout.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Folder {
  /// Returns a new [Folder] instance.
  Folder({
    this.athleteId,

    this.id,

    this.type,

    this.name,

    this.description,

    this.children,

    this.visibility,

    this.startDateLocal,

    this.rolloutWeeks,

    this.autoRolloutDay,

    this.readOnlyWorkouts,

    this.startingCtl,

    this.startingAtl,

    this.activityTypes,

    this.numWorkouts,

    this.durationWeeks,

    this.hoursPerWeekMin,

    this.hoursPerWeekMax,

    this.workoutTargets,

    this.blurb,

    this.canEdit,

    this.sharedWithCount,

    this.shareToken,

    this.owner,
  });

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final FolderTypeEnum? type;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'children', required: false, includeIfNull: false)
  final List<Workout>? children;

  @JsonKey(name: r'visibility', required: false, includeIfNull: false)
  final FolderVisibilityEnum? visibility;

  @JsonKey(name: r'start_date_local', required: false, includeIfNull: false)
  final String? startDateLocal;

  @JsonKey(name: r'rollout_weeks', required: false, includeIfNull: false)
  final int? rolloutWeeks;

  @JsonKey(name: r'auto_rollout_day', required: false, includeIfNull: false)
  final int? autoRolloutDay;

  @JsonKey(name: r'read_only_workouts', required: false, includeIfNull: false)
  final bool? readOnlyWorkouts;

  @JsonKey(name: r'starting_ctl', required: false, includeIfNull: false)
  final int? startingCtl;

  @JsonKey(name: r'starting_atl', required: false, includeIfNull: false)
  final int? startingAtl;

  @JsonKey(name: r'activity_types', required: false, includeIfNull: false)
  final List<FolderActivityTypesEnum>? activityTypes;

  @JsonKey(name: r'num_workouts', required: false, includeIfNull: false)
  final int? numWorkouts;

  @JsonKey(name: r'duration_weeks', required: false, includeIfNull: false)
  final int? durationWeeks;

  @JsonKey(name: r'hours_per_week_min', required: false, includeIfNull: false)
  final int? hoursPerWeekMin;

  @JsonKey(name: r'hours_per_week_max', required: false, includeIfNull: false)
  final int? hoursPerWeekMax;

  @JsonKey(name: r'workout_targets', required: false, includeIfNull: false)
  final List<FolderWorkoutTargetsEnum>? workoutTargets;

  @JsonKey(name: r'blurb', required: false, includeIfNull: false)
  final String? blurb;

  @JsonKey(name: r'canEdit', required: false, includeIfNull: false)
  final bool? canEdit;

  @JsonKey(name: r'sharedWithCount', required: false, includeIfNull: false)
  final int? sharedWithCount;

  @JsonKey(name: r'shareToken', required: false, includeIfNull: false)
  final String? shareToken;

  @JsonKey(name: r'owner', required: false, includeIfNull: false)
  final AthleteSearchResult? owner;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder &&
          other.athleteId == athleteId &&
          other.id == id &&
          other.type == type &&
          other.name == name &&
          other.description == description &&
          other.children == children &&
          other.visibility == visibility &&
          other.startDateLocal == startDateLocal &&
          other.rolloutWeeks == rolloutWeeks &&
          other.autoRolloutDay == autoRolloutDay &&
          other.readOnlyWorkouts == readOnlyWorkouts &&
          other.startingCtl == startingCtl &&
          other.startingAtl == startingAtl &&
          other.activityTypes == activityTypes &&
          other.numWorkouts == numWorkouts &&
          other.durationWeeks == durationWeeks &&
          other.hoursPerWeekMin == hoursPerWeekMin &&
          other.hoursPerWeekMax == hoursPerWeekMax &&
          other.workoutTargets == workoutTargets &&
          other.blurb == blurb &&
          other.canEdit == canEdit &&
          other.sharedWithCount == sharedWithCount &&
          other.shareToken == shareToken &&
          other.owner == owner;

  @override
  int get hashCode =>
      athleteId.hashCode +
      id.hashCode +
      type.hashCode +
      name.hashCode +
      description.hashCode +
      children.hashCode +
      visibility.hashCode +
      startDateLocal.hashCode +
      rolloutWeeks.hashCode +
      autoRolloutDay.hashCode +
      readOnlyWorkouts.hashCode +
      startingCtl.hashCode +
      startingAtl.hashCode +
      activityTypes.hashCode +
      numWorkouts.hashCode +
      durationWeeks.hashCode +
      hoursPerWeekMin.hashCode +
      hoursPerWeekMax.hashCode +
      workoutTargets.hashCode +
      blurb.hashCode +
      canEdit.hashCode +
      sharedWithCount.hashCode +
      shareToken.hashCode +
      owner.hashCode;

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);

  Map<String, dynamic> toJson() => _$FolderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum FolderTypeEnum {
  @JsonValue(r'FOLDER')
  FOLDER(r'FOLDER'),
  @JsonValue(r'PLAN')
  PLAN(r'PLAN');

  const FolderTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum FolderVisibilityEnum {
  @JsonValue(r'PRIVATE')
  PRIVATE(r'PRIVATE'),
  @JsonValue(r'PUBLIC')
  PUBLIC(r'PUBLIC');

  const FolderVisibilityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum FolderActivityTypesEnum {
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

  const FolderActivityTypesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum FolderWorkoutTargetsEnum {
  @JsonValue(r'AUTO')
  AUTO(r'AUTO'),
  @JsonValue(r'POWER')
  POWER(r'POWER'),
  @JsonValue(r'HR')
  HR(r'HR'),
  @JsonValue(r'PACE')
  PACE(r'PACE');

  const FolderWorkoutTargetsEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
