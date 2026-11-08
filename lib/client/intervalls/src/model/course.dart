//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_weather.dart';
import 'package:triiq/client/intervalls/src/model/activity_stream.dart';
import 'package:triiq/client/intervalls/src/model/marker.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Course {
  /// Returns a new [Course] instance.
  Course({
    this.id,

    this.sharedEventId,

    this.created,

    this.updated,

    this.name,

    this.types,

    this.fileType,

    this.fileSportIndex,

    this.startTime,

    this.description,

    this.distance,

    this.minAltitude,

    this.maxAltitude,

    this.averageAltitude,

    this.totalElevationGain,

    this.totalElevationLoss,

    this.startLat,

    this.startLng,

    this.weatherUpdated,

    this.full,

    this.markers,

    this.streams,

    this.bounds,

    this.latlngs,

    this.weather,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'shared_event_id', required: false, includeIfNull: false)
  final int? sharedEventId;

  @JsonKey(name: r'created', required: false, includeIfNull: false)
  final DateTime? created;

  @JsonKey(name: r'updated', required: false, includeIfNull: false)
  final DateTime? updated;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'types', required: false, includeIfNull: false)
  final List<CourseTypesEnum>? types;

  @JsonKey(name: r'file_type', required: false, includeIfNull: false)
  final String? fileType;

  @JsonKey(name: r'file_sport_index', required: false, includeIfNull: false)
  final int? fileSportIndex;

  @JsonKey(name: r'start_time', required: false, includeIfNull: false)
  final String? startTime;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'min_altitude', required: false, includeIfNull: false)
  final double? minAltitude;

  @JsonKey(name: r'max_altitude', required: false, includeIfNull: false)
  final double? maxAltitude;

  @JsonKey(name: r'average_altitude', required: false, includeIfNull: false)
  final double? averageAltitude;

  @JsonKey(name: r'total_elevation_gain', required: false, includeIfNull: false)
  final double? totalElevationGain;

  @JsonKey(name: r'total_elevation_loss', required: false, includeIfNull: false)
  final double? totalElevationLoss;

  @JsonKey(name: r'start_lat', required: false, includeIfNull: false)
  final double? startLat;

  @JsonKey(name: r'start_lng', required: false, includeIfNull: false)
  final double? startLng;

  @JsonKey(name: r'weather_updated', required: false, includeIfNull: false)
  final DateTime? weatherUpdated;

  @JsonKey(name: r'full', required: false, includeIfNull: false)
  final bool? full;

  @JsonKey(name: r'markers', required: false, includeIfNull: false)
  final List<Marker>? markers;

  @JsonKey(name: r'streams', required: false, includeIfNull: false)
  final List<ActivityStream>? streams;

  @JsonKey(name: r'bounds', required: false, includeIfNull: false)
  final List<List<double>>? bounds;

  @JsonKey(name: r'latlngs', required: false, includeIfNull: false)
  final List<List<double>>? latlngs;

  @JsonKey(name: r'weather', required: false, includeIfNull: false)
  final ActivityWeather? weather;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          other.id == id &&
          other.sharedEventId == sharedEventId &&
          other.created == created &&
          other.updated == updated &&
          other.name == name &&
          other.types == types &&
          other.fileType == fileType &&
          other.fileSportIndex == fileSportIndex &&
          other.startTime == startTime &&
          other.description == description &&
          other.distance == distance &&
          other.minAltitude == minAltitude &&
          other.maxAltitude == maxAltitude &&
          other.averageAltitude == averageAltitude &&
          other.totalElevationGain == totalElevationGain &&
          other.totalElevationLoss == totalElevationLoss &&
          other.startLat == startLat &&
          other.startLng == startLng &&
          other.weatherUpdated == weatherUpdated &&
          other.full == full &&
          other.markers == markers &&
          other.streams == streams &&
          other.bounds == bounds &&
          other.latlngs == latlngs &&
          other.weather == weather;

  @override
  int get hashCode =>
      id.hashCode +
      sharedEventId.hashCode +
      created.hashCode +
      updated.hashCode +
      name.hashCode +
      types.hashCode +
      fileType.hashCode +
      fileSportIndex.hashCode +
      startTime.hashCode +
      description.hashCode +
      distance.hashCode +
      minAltitude.hashCode +
      maxAltitude.hashCode +
      averageAltitude.hashCode +
      totalElevationGain.hashCode +
      totalElevationLoss.hashCode +
      startLat.hashCode +
      startLng.hashCode +
      weatherUpdated.hashCode +
      full.hashCode +
      markers.hashCode +
      streams.hashCode +
      bounds.hashCode +
      latlngs.hashCode +
      weather.hashCode;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CourseTypesEnum {
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

  const CourseTypesEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
