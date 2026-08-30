// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CategorySummaryCWProxy {
  CategorySummary count(int? count);

  CategorySummary time(int? time);

  CategorySummary movingTime(int? movingTime);

  CategorySummary elapsedTime(int? elapsedTime);

  CategorySummary calories(int? calories);

  CategorySummary totalElevationGain(double? totalElevationGain);

  CategorySummary trainingLoad(int? trainingLoad);

  CategorySummary srpe(int? srpe);

  CategorySummary distance(double? distance);

  CategorySummary eftp(double? eftp);

  CategorySummary eftpPerKg(double? eftpPerKg);

  CategorySummary category(CategorySummaryCategoryEnum? category);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  CategorySummary call({
    int? count,
    int? time,
    int? movingTime,
    int? elapsedTime,
    int? calories,
    double? totalElevationGain,
    int? trainingLoad,
    int? srpe,
    double? distance,
    double? eftp,
    double? eftpPerKg,
    CategorySummaryCategoryEnum? category,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCategorySummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCategorySummary.copyWith.fieldName(...)`
class _$CategorySummaryCWProxyImpl implements _$CategorySummaryCWProxy {
  const _$CategorySummaryCWProxyImpl(this._value);

  final CategorySummary _value;

  @override
  CategorySummary count(int? count) => this(count: count);

  @override
  CategorySummary time(int? time) => this(time: time);

  @override
  CategorySummary movingTime(int? movingTime) => this(movingTime: movingTime);

  @override
  CategorySummary elapsedTime(int? elapsedTime) =>
      this(elapsedTime: elapsedTime);

  @override
  CategorySummary calories(int? calories) => this(calories: calories);

  @override
  CategorySummary totalElevationGain(double? totalElevationGain) =>
      this(totalElevationGain: totalElevationGain);

  @override
  CategorySummary trainingLoad(int? trainingLoad) =>
      this(trainingLoad: trainingLoad);

  @override
  CategorySummary srpe(int? srpe) => this(srpe: srpe);

  @override
  CategorySummary distance(double? distance) => this(distance: distance);

  @override
  CategorySummary eftp(double? eftp) => this(eftp: eftp);

  @override
  CategorySummary eftpPerKg(double? eftpPerKg) => this(eftpPerKg: eftpPerKg);

  @override
  CategorySummary category(CategorySummaryCategoryEnum? category) =>
      this(category: category);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategorySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategorySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  CategorySummary call({
    Object? count = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? elapsedTime = const $CopyWithPlaceholder(),
    Object? calories = const $CopyWithPlaceholder(),
    Object? totalElevationGain = const $CopyWithPlaceholder(),
    Object? trainingLoad = const $CopyWithPlaceholder(),
    Object? srpe = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? eftp = const $CopyWithPlaceholder(),
    Object? eftpPerKg = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
  }) {
    return CategorySummary(
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as int?,
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as int?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as int?,
      elapsedTime: elapsedTime == const $CopyWithPlaceholder()
          ? _value.elapsedTime
          // ignore: cast_nullable_to_non_nullable
          : elapsedTime as int?,
      calories: calories == const $CopyWithPlaceholder()
          ? _value.calories
          // ignore: cast_nullable_to_non_nullable
          : calories as int?,
      totalElevationGain: totalElevationGain == const $CopyWithPlaceholder()
          ? _value.totalElevationGain
          // ignore: cast_nullable_to_non_nullable
          : totalElevationGain as double?,
      trainingLoad: trainingLoad == const $CopyWithPlaceholder()
          ? _value.trainingLoad
          // ignore: cast_nullable_to_non_nullable
          : trainingLoad as int?,
      srpe: srpe == const $CopyWithPlaceholder()
          ? _value.srpe
          // ignore: cast_nullable_to_non_nullable
          : srpe as int?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      eftp: eftp == const $CopyWithPlaceholder()
          ? _value.eftp
          // ignore: cast_nullable_to_non_nullable
          : eftp as double?,
      eftpPerKg: eftpPerKg == const $CopyWithPlaceholder()
          ? _value.eftpPerKg
          // ignore: cast_nullable_to_non_nullable
          : eftpPerKg as double?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as CategorySummaryCategoryEnum?,
    );
  }
}

extension $CategorySummaryCopyWith on CategorySummary {
  /// Returns a callable class that can be used as follows: `instanceOfCategorySummary.copyWith(...)` or like so:`instanceOfCategorySummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CategorySummaryCWProxy get copyWith => _$CategorySummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorySummary _$CategorySummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CategorySummary',
  json,
  ($checkedConvert) {
    final val = CategorySummary(
      count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
      time: $checkedConvert('time', (v) => (v as num?)?.toInt()),
      movingTime: $checkedConvert('moving_time', (v) => (v as num?)?.toInt()),
      elapsedTime: $checkedConvert('elapsed_time', (v) => (v as num?)?.toInt()),
      calories: $checkedConvert('calories', (v) => (v as num?)?.toInt()),
      totalElevationGain: $checkedConvert(
        'total_elevation_gain',
        (v) => (v as num?)?.toDouble(),
      ),
      trainingLoad: $checkedConvert(
        'training_load',
        (v) => (v as num?)?.toInt(),
      ),
      srpe: $checkedConvert('srpe', (v) => (v as num?)?.toInt()),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      eftp: $checkedConvert('eftp', (v) => (v as num?)?.toDouble()),
      eftpPerKg: $checkedConvert('eftpPerKg', (v) => (v as num?)?.toDouble()),
      category: $checkedConvert(
        'category',
        (v) => $enumDecodeNullable(_$CategorySummaryCategoryEnumEnumMap, v),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'movingTime': 'moving_time',
    'elapsedTime': 'elapsed_time',
    'totalElevationGain': 'total_elevation_gain',
    'trainingLoad': 'training_load',
  },
);

Map<String, dynamic> _$CategorySummaryToJson(CategorySummary instance) =>
    <String, dynamic>{
      'count': ?instance.count,
      'time': ?instance.time,
      'moving_time': ?instance.movingTime,
      'elapsed_time': ?instance.elapsedTime,
      'calories': ?instance.calories,
      'total_elevation_gain': ?instance.totalElevationGain,
      'training_load': ?instance.trainingLoad,
      'srpe': ?instance.srpe,
      'distance': ?instance.distance,
      'eftp': ?instance.eftp,
      'eftpPerKg': ?instance.eftpPerKg,
      'category': ?_$CategorySummaryCategoryEnumEnumMap[instance.category],
    };

const _$CategorySummaryCategoryEnumEnumMap = {
  CategorySummaryCategoryEnum.ride: 'Ride',
  CategorySummaryCategoryEnum.run: 'Run',
  CategorySummaryCategoryEnum.swim: 'Swim',
  CategorySummaryCategoryEnum.weightTraining: 'WeightTraining',
  CategorySummaryCategoryEnum.hike: 'Hike',
  CategorySummaryCategoryEnum.walk: 'Walk',
  CategorySummaryCategoryEnum.alpineSki: 'AlpineSki',
  CategorySummaryCategoryEnum.backcountrySki: 'BackcountrySki',
  CategorySummaryCategoryEnum.badminton: 'Badminton',
  CategorySummaryCategoryEnum.canoeing: 'Canoeing',
  CategorySummaryCategoryEnum.crossfit: 'Crossfit',
  CategorySummaryCategoryEnum.eBikeRide: 'EBikeRide',
  CategorySummaryCategoryEnum.eMountainBikeRide: 'EMountainBikeRide',
  CategorySummaryCategoryEnum.elliptical: 'Elliptical',
  CategorySummaryCategoryEnum.golf: 'Golf',
  CategorySummaryCategoryEnum.gravelRide: 'GravelRide',
  CategorySummaryCategoryEnum.trackRide: 'TrackRide',
  CategorySummaryCategoryEnum.handcycle: 'Handcycle',
  CategorySummaryCategoryEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  CategorySummaryCategoryEnum.hockey: 'Hockey',
  CategorySummaryCategoryEnum.iceSkate: 'IceSkate',
  CategorySummaryCategoryEnum.inlineSkate: 'InlineSkate',
  CategorySummaryCategoryEnum.kayaking: 'Kayaking',
  CategorySummaryCategoryEnum.kitesurf: 'Kitesurf',
  CategorySummaryCategoryEnum.mountainBikeRide: 'MountainBikeRide',
  CategorySummaryCategoryEnum.cyclocross: 'Cyclocross',
  CategorySummaryCategoryEnum.nordicSki: 'NordicSki',
  CategorySummaryCategoryEnum.openWaterSwim: 'OpenWaterSwim',
  CategorySummaryCategoryEnum.padel: 'Padel',
  CategorySummaryCategoryEnum.pilates: 'Pilates',
  CategorySummaryCategoryEnum.pickleball: 'Pickleball',
  CategorySummaryCategoryEnum.racquetball: 'Racquetball',
  CategorySummaryCategoryEnum.rugby: 'Rugby',
  CategorySummaryCategoryEnum.rockClimbing: 'RockClimbing',
  CategorySummaryCategoryEnum.rollerSki: 'RollerSki',
  CategorySummaryCategoryEnum.rowing: 'Rowing',
  CategorySummaryCategoryEnum.sail: 'Sail',
  CategorySummaryCategoryEnum.skateboard: 'Skateboard',
  CategorySummaryCategoryEnum.snowboard: 'Snowboard',
  CategorySummaryCategoryEnum.snowshoe: 'Snowshoe',
  CategorySummaryCategoryEnum.soccer: 'Soccer',
  CategorySummaryCategoryEnum.squash: 'Squash',
  CategorySummaryCategoryEnum.stairStepper: 'StairStepper',
  CategorySummaryCategoryEnum.standUpPaddling: 'StandUpPaddling',
  CategorySummaryCategoryEnum.surfing: 'Surfing',
  CategorySummaryCategoryEnum.tableTennis: 'TableTennis',
  CategorySummaryCategoryEnum.tennis: 'Tennis',
  CategorySummaryCategoryEnum.trailRun: 'TrailRun',
  CategorySummaryCategoryEnum.transition: 'Transition',
  CategorySummaryCategoryEnum.velomobile: 'Velomobile',
  CategorySummaryCategoryEnum.virtualRide: 'VirtualRide',
  CategorySummaryCategoryEnum.virtualRow: 'VirtualRow',
  CategorySummaryCategoryEnum.virtualRun: 'VirtualRun',
  CategorySummaryCategoryEnum.virtualSki: 'VirtualSki',
  CategorySummaryCategoryEnum.waterSport: 'WaterSport',
  CategorySummaryCategoryEnum.wheelchair: 'Wheelchair',
  CategorySummaryCategoryEnum.windsurf: 'Windsurf',
  CategorySummaryCategoryEnum.workout: 'Workout',
  CategorySummaryCategoryEnum.yoga: 'Yoga',
  CategorySummaryCategoryEnum.other: 'Other',
};
