//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategorySummary {
  /// Returns a new [CategorySummary] instance.
  CategorySummary({
    this.count,

    this.time,

    this.movingTime,

    this.elapsedTime,

    this.calories,

    this.totalElevationGain,

    this.trainingLoad,

    this.srpe,

    this.distance,

    this.eftp,

    this.eftpPerKg,

    this.category,
  });

  @JsonKey(name: r'count', required: false, includeIfNull: false)
  final int? count;

  @JsonKey(name: r'time', required: false, includeIfNull: false)
  final int? time;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'elapsed_time', required: false, includeIfNull: false)
  final int? elapsedTime;

  @JsonKey(name: r'calories', required: false, includeIfNull: false)
  final int? calories;

  @JsonKey(name: r'total_elevation_gain', required: false, includeIfNull: false)
  final double? totalElevationGain;

  @JsonKey(name: r'training_load', required: false, includeIfNull: false)
  final int? trainingLoad;

  @JsonKey(name: r'srpe', required: false, includeIfNull: false)
  final int? srpe;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'eftp', required: false, includeIfNull: false)
  final double? eftp;

  @JsonKey(name: r'eftpPerKg', required: false, includeIfNull: false)
  final double? eftpPerKg;

  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final CategorySummaryCategoryEnum? category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorySummary &&
          other.count == count &&
          other.time == time &&
          other.movingTime == movingTime &&
          other.elapsedTime == elapsedTime &&
          other.calories == calories &&
          other.totalElevationGain == totalElevationGain &&
          other.trainingLoad == trainingLoad &&
          other.srpe == srpe &&
          other.distance == distance &&
          other.eftp == eftp &&
          other.eftpPerKg == eftpPerKg &&
          other.category == category;

  @override
  int get hashCode =>
      count.hashCode +
      time.hashCode +
      movingTime.hashCode +
      elapsedTime.hashCode +
      calories.hashCode +
      totalElevationGain.hashCode +
      trainingLoad.hashCode +
      srpe.hashCode +
      distance.hashCode +
      eftp.hashCode +
      eftpPerKg.hashCode +
      category.hashCode;

  factory CategorySummary.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CategorySummaryCategoryEnum {
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

  const CategorySummaryCategoryEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
