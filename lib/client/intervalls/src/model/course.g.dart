// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CourseCWProxy {
  Course id(int? id);

  Course sharedEventId(int? sharedEventId);

  Course created(DateTime? created);

  Course updated(DateTime? updated);

  Course name(String? name);

  Course types(List<CourseTypesEnum>? types);

  Course fileType(String? fileType);

  Course fileSportIndex(int? fileSportIndex);

  Course startTime(String? startTime);

  Course description(String? description);

  Course distance(double? distance);

  Course minAltitude(double? minAltitude);

  Course maxAltitude(double? maxAltitude);

  Course averageAltitude(double? averageAltitude);

  Course totalElevationGain(double? totalElevationGain);

  Course totalElevationLoss(double? totalElevationLoss);

  Course startLat(double? startLat);

  Course startLng(double? startLng);

  Course weatherUpdated(DateTime? weatherUpdated);

  Course full(bool? full);

  Course markers(List<Marker>? markers);

  Course streams(List<ActivityStream>? streams);

  Course bounds(List<List<double>>? bounds);

  Course latlngs(List<List<double>>? latlngs);

  Course weather(ActivityWeather? weather);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Course(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Course(...).copyWith(id: 12, name: "My name")
  /// ````
  Course call({
    int? id,
    int? sharedEventId,
    DateTime? created,
    DateTime? updated,
    String? name,
    List<CourseTypesEnum>? types,
    String? fileType,
    int? fileSportIndex,
    String? startTime,
    String? description,
    double? distance,
    double? minAltitude,
    double? maxAltitude,
    double? averageAltitude,
    double? totalElevationGain,
    double? totalElevationLoss,
    double? startLat,
    double? startLng,
    DateTime? weatherUpdated,
    bool? full,
    List<Marker>? markers,
    List<ActivityStream>? streams,
    List<List<double>>? bounds,
    List<List<double>>? latlngs,
    ActivityWeather? weather,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCourse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCourse.copyWith.fieldName(...)`
class _$CourseCWProxyImpl implements _$CourseCWProxy {
  const _$CourseCWProxyImpl(this._value);

  final Course _value;

  @override
  Course id(int? id) => this(id: id);

  @override
  Course sharedEventId(int? sharedEventId) =>
      this(sharedEventId: sharedEventId);

  @override
  Course created(DateTime? created) => this(created: created);

  @override
  Course updated(DateTime? updated) => this(updated: updated);

  @override
  Course name(String? name) => this(name: name);

  @override
  Course types(List<CourseTypesEnum>? types) => this(types: types);

  @override
  Course fileType(String? fileType) => this(fileType: fileType);

  @override
  Course fileSportIndex(int? fileSportIndex) =>
      this(fileSportIndex: fileSportIndex);

  @override
  Course startTime(String? startTime) => this(startTime: startTime);

  @override
  Course description(String? description) => this(description: description);

  @override
  Course distance(double? distance) => this(distance: distance);

  @override
  Course minAltitude(double? minAltitude) => this(minAltitude: minAltitude);

  @override
  Course maxAltitude(double? maxAltitude) => this(maxAltitude: maxAltitude);

  @override
  Course averageAltitude(double? averageAltitude) =>
      this(averageAltitude: averageAltitude);

  @override
  Course totalElevationGain(double? totalElevationGain) =>
      this(totalElevationGain: totalElevationGain);

  @override
  Course totalElevationLoss(double? totalElevationLoss) =>
      this(totalElevationLoss: totalElevationLoss);

  @override
  Course startLat(double? startLat) => this(startLat: startLat);

  @override
  Course startLng(double? startLng) => this(startLng: startLng);

  @override
  Course weatherUpdated(DateTime? weatherUpdated) =>
      this(weatherUpdated: weatherUpdated);

  @override
  Course full(bool? full) => this(full: full);

  @override
  Course markers(List<Marker>? markers) => this(markers: markers);

  @override
  Course streams(List<ActivityStream>? streams) => this(streams: streams);

  @override
  Course bounds(List<List<double>>? bounds) => this(bounds: bounds);

  @override
  Course latlngs(List<List<double>>? latlngs) => this(latlngs: latlngs);

  @override
  Course weather(ActivityWeather? weather) => this(weather: weather);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Course(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Course(...).copyWith(id: 12, name: "My name")
  /// ````
  Course call({
    Object? id = const $CopyWithPlaceholder(),
    Object? sharedEventId = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? types = const $CopyWithPlaceholder(),
    Object? fileType = const $CopyWithPlaceholder(),
    Object? fileSportIndex = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? minAltitude = const $CopyWithPlaceholder(),
    Object? maxAltitude = const $CopyWithPlaceholder(),
    Object? averageAltitude = const $CopyWithPlaceholder(),
    Object? totalElevationGain = const $CopyWithPlaceholder(),
    Object? totalElevationLoss = const $CopyWithPlaceholder(),
    Object? startLat = const $CopyWithPlaceholder(),
    Object? startLng = const $CopyWithPlaceholder(),
    Object? weatherUpdated = const $CopyWithPlaceholder(),
    Object? full = const $CopyWithPlaceholder(),
    Object? markers = const $CopyWithPlaceholder(),
    Object? streams = const $CopyWithPlaceholder(),
    Object? bounds = const $CopyWithPlaceholder(),
    Object? latlngs = const $CopyWithPlaceholder(),
    Object? weather = const $CopyWithPlaceholder(),
  }) {
    return Course(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      sharedEventId: sharedEventId == const $CopyWithPlaceholder()
          ? _value.sharedEventId
          // ignore: cast_nullable_to_non_nullable
          : sharedEventId as int?,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as DateTime?,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as DateTime?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      types: types == const $CopyWithPlaceholder()
          ? _value.types
          // ignore: cast_nullable_to_non_nullable
          : types as List<CourseTypesEnum>?,
      fileType: fileType == const $CopyWithPlaceholder()
          ? _value.fileType
          // ignore: cast_nullable_to_non_nullable
          : fileType as String?,
      fileSportIndex: fileSportIndex == const $CopyWithPlaceholder()
          ? _value.fileSportIndex
          // ignore: cast_nullable_to_non_nullable
          : fileSportIndex as int?,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      minAltitude: minAltitude == const $CopyWithPlaceholder()
          ? _value.minAltitude
          // ignore: cast_nullable_to_non_nullable
          : minAltitude as double?,
      maxAltitude: maxAltitude == const $CopyWithPlaceholder()
          ? _value.maxAltitude
          // ignore: cast_nullable_to_non_nullable
          : maxAltitude as double?,
      averageAltitude: averageAltitude == const $CopyWithPlaceholder()
          ? _value.averageAltitude
          // ignore: cast_nullable_to_non_nullable
          : averageAltitude as double?,
      totalElevationGain: totalElevationGain == const $CopyWithPlaceholder()
          ? _value.totalElevationGain
          // ignore: cast_nullable_to_non_nullable
          : totalElevationGain as double?,
      totalElevationLoss: totalElevationLoss == const $CopyWithPlaceholder()
          ? _value.totalElevationLoss
          // ignore: cast_nullable_to_non_nullable
          : totalElevationLoss as double?,
      startLat: startLat == const $CopyWithPlaceholder()
          ? _value.startLat
          // ignore: cast_nullable_to_non_nullable
          : startLat as double?,
      startLng: startLng == const $CopyWithPlaceholder()
          ? _value.startLng
          // ignore: cast_nullable_to_non_nullable
          : startLng as double?,
      weatherUpdated: weatherUpdated == const $CopyWithPlaceholder()
          ? _value.weatherUpdated
          // ignore: cast_nullable_to_non_nullable
          : weatherUpdated as DateTime?,
      full: full == const $CopyWithPlaceholder()
          ? _value.full
          // ignore: cast_nullable_to_non_nullable
          : full as bool?,
      markers: markers == const $CopyWithPlaceholder()
          ? _value.markers
          // ignore: cast_nullable_to_non_nullable
          : markers as List<Marker>?,
      streams: streams == const $CopyWithPlaceholder()
          ? _value.streams
          // ignore: cast_nullable_to_non_nullable
          : streams as List<ActivityStream>?,
      bounds: bounds == const $CopyWithPlaceholder()
          ? _value.bounds
          // ignore: cast_nullable_to_non_nullable
          : bounds as List<List<double>>?,
      latlngs: latlngs == const $CopyWithPlaceholder()
          ? _value.latlngs
          // ignore: cast_nullable_to_non_nullable
          : latlngs as List<List<double>>?,
      weather: weather == const $CopyWithPlaceholder()
          ? _value.weather
          // ignore: cast_nullable_to_non_nullable
          : weather as ActivityWeather?,
    );
  }
}

extension $CourseCopyWith on Course {
  /// Returns a callable class that can be used as follows: `instanceOfCourse.copyWith(...)` or like so:`instanceOfCourse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CourseCWProxy get copyWith => _$CourseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Course',
  json,
  ($checkedConvert) {
    final val = Course(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      sharedEventId: $checkedConvert(
        'shared_event_id',
        (v) => (v as num?)?.toInt(),
      ),
      created: $checkedConvert(
        'created',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updated: $checkedConvert(
        'updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      name: $checkedConvert('name', (v) => v as String?),
      types: $checkedConvert(
        'types',
        (v) => (v as List<dynamic>?)
            ?.map((e) => $enumDecode(_$CourseTypesEnumEnumMap, e))
            .toList(),
      ),
      fileType: $checkedConvert('file_type', (v) => v as String?),
      fileSportIndex: $checkedConvert(
        'file_sport_index',
        (v) => (v as num?)?.toInt(),
      ),
      startTime: $checkedConvert('start_time', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      minAltitude: $checkedConvert(
        'min_altitude',
        (v) => (v as num?)?.toDouble(),
      ),
      maxAltitude: $checkedConvert(
        'max_altitude',
        (v) => (v as num?)?.toDouble(),
      ),
      averageAltitude: $checkedConvert(
        'average_altitude',
        (v) => (v as num?)?.toDouble(),
      ),
      totalElevationGain: $checkedConvert(
        'total_elevation_gain',
        (v) => (v as num?)?.toDouble(),
      ),
      totalElevationLoss: $checkedConvert(
        'total_elevation_loss',
        (v) => (v as num?)?.toDouble(),
      ),
      startLat: $checkedConvert('start_lat', (v) => (v as num?)?.toDouble()),
      startLng: $checkedConvert('start_lng', (v) => (v as num?)?.toDouble()),
      weatherUpdated: $checkedConvert(
        'weather_updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      full: $checkedConvert('full', (v) => v as bool?),
      markers: $checkedConvert(
        'markers',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Marker.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      streams: $checkedConvert(
        'streams',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ActivityStream.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      bounds: $checkedConvert(
        'bounds',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => (e as List<dynamic>)
                  .map((e) => (e as num).toDouble())
                  .toList(),
            )
            .toList(),
      ),
      latlngs: $checkedConvert(
        'latlngs',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => (e as List<dynamic>)
                  .map((e) => (e as num).toDouble())
                  .toList(),
            )
            .toList(),
      ),
      weather: $checkedConvert(
        'weather',
        (v) => v == null
            ? null
            : ActivityWeather.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'sharedEventId': 'shared_event_id',
    'fileType': 'file_type',
    'fileSportIndex': 'file_sport_index',
    'startTime': 'start_time',
    'minAltitude': 'min_altitude',
    'maxAltitude': 'max_altitude',
    'averageAltitude': 'average_altitude',
    'totalElevationGain': 'total_elevation_gain',
    'totalElevationLoss': 'total_elevation_loss',
    'startLat': 'start_lat',
    'startLng': 'start_lng',
    'weatherUpdated': 'weather_updated',
  },
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': ?instance.id,
  'shared_event_id': ?instance.sharedEventId,
  'created': ?instance.created?.toIso8601String(),
  'updated': ?instance.updated?.toIso8601String(),
  'name': ?instance.name,
  'types': ?instance.types?.map((e) => _$CourseTypesEnumEnumMap[e]!).toList(),
  'file_type': ?instance.fileType,
  'file_sport_index': ?instance.fileSportIndex,
  'start_time': ?instance.startTime,
  'description': ?instance.description,
  'distance': ?instance.distance,
  'min_altitude': ?instance.minAltitude,
  'max_altitude': ?instance.maxAltitude,
  'average_altitude': ?instance.averageAltitude,
  'total_elevation_gain': ?instance.totalElevationGain,
  'total_elevation_loss': ?instance.totalElevationLoss,
  'start_lat': ?instance.startLat,
  'start_lng': ?instance.startLng,
  'weather_updated': ?instance.weatherUpdated?.toIso8601String(),
  'full': ?instance.full,
  'markers': ?instance.markers?.map((e) => e.toJson()).toList(),
  'streams': ?instance.streams?.map((e) => e.toJson()).toList(),
  'bounds': ?instance.bounds,
  'latlngs': ?instance.latlngs,
  'weather': ?instance.weather?.toJson(),
};

const _$CourseTypesEnumEnumMap = {
  CourseTypesEnum.ride: 'Ride',
  CourseTypesEnum.run: 'Run',
  CourseTypesEnum.swim: 'Swim',
  CourseTypesEnum.weightTraining: 'WeightTraining',
  CourseTypesEnum.hike: 'Hike',
  CourseTypesEnum.walk: 'Walk',
  CourseTypesEnum.alpineSki: 'AlpineSki',
  CourseTypesEnum.backcountrySki: 'BackcountrySki',
  CourseTypesEnum.badminton: 'Badminton',
  CourseTypesEnum.canoeing: 'Canoeing',
  CourseTypesEnum.crossfit: 'Crossfit',
  CourseTypesEnum.eBikeRide: 'EBikeRide',
  CourseTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  CourseTypesEnum.elliptical: 'Elliptical',
  CourseTypesEnum.golf: 'Golf',
  CourseTypesEnum.gravelRide: 'GravelRide',
  CourseTypesEnum.trackRide: 'TrackRide',
  CourseTypesEnum.handcycle: 'Handcycle',
  CourseTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  CourseTypesEnum.hockey: 'Hockey',
  CourseTypesEnum.iceSkate: 'IceSkate',
  CourseTypesEnum.inlineSkate: 'InlineSkate',
  CourseTypesEnum.kayaking: 'Kayaking',
  CourseTypesEnum.kitesurf: 'Kitesurf',
  CourseTypesEnum.mountainBikeRide: 'MountainBikeRide',
  CourseTypesEnum.cyclocross: 'Cyclocross',
  CourseTypesEnum.nordicSki: 'NordicSki',
  CourseTypesEnum.openWaterSwim: 'OpenWaterSwim',
  CourseTypesEnum.padel: 'Padel',
  CourseTypesEnum.pilates: 'Pilates',
  CourseTypesEnum.pickleball: 'Pickleball',
  CourseTypesEnum.racquetball: 'Racquetball',
  CourseTypesEnum.rugby: 'Rugby',
  CourseTypesEnum.rockClimbing: 'RockClimbing',
  CourseTypesEnum.rollerSki: 'RollerSki',
  CourseTypesEnum.rowing: 'Rowing',
  CourseTypesEnum.sail: 'Sail',
  CourseTypesEnum.skateboard: 'Skateboard',
  CourseTypesEnum.snowboard: 'Snowboard',
  CourseTypesEnum.snowshoe: 'Snowshoe',
  CourseTypesEnum.soccer: 'Soccer',
  CourseTypesEnum.squash: 'Squash',
  CourseTypesEnum.stairStepper: 'StairStepper',
  CourseTypesEnum.standUpPaddling: 'StandUpPaddling',
  CourseTypesEnum.surfing: 'Surfing',
  CourseTypesEnum.tableTennis: 'TableTennis',
  CourseTypesEnum.tennis: 'Tennis',
  CourseTypesEnum.trailRun: 'TrailRun',
  CourseTypesEnum.transition: 'Transition',
  CourseTypesEnum.velomobile: 'Velomobile',
  CourseTypesEnum.virtualRide: 'VirtualRide',
  CourseTypesEnum.virtualRow: 'VirtualRow',
  CourseTypesEnum.virtualRun: 'VirtualRun',
  CourseTypesEnum.virtualSki: 'VirtualSki',
  CourseTypesEnum.waterSport: 'WaterSport',
  CourseTypesEnum.wheelchair: 'Wheelchair',
  CourseTypesEnum.windsurf: 'Windsurf',
  CourseTypesEnum.workout: 'Workout',
  CourseTypesEnum.yoga: 'Yoga',
  CourseTypesEnum.other: 'Other',
};
