// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_training_availability.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteTrainingAvailabilityCWProxy {
  AthleteTrainingAvailability dayOfWeek(int? dayOfWeek);

  AthleteTrainingAvailability trainingAvailability(
    AthleteTrainingAvailabilityTrainingAvailabilityEnum? trainingAvailability,
  );

  AthleteTrainingAvailability maxTrainingTime(int? maxTrainingTime);

  AthleteTrainingAvailability canTrainSports(
    List<AthleteTrainingAvailabilityCanTrainSportsEnum>? canTrainSports,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingAvailability(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingAvailability(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingAvailability call({
    int? dayOfWeek,
    AthleteTrainingAvailabilityTrainingAvailabilityEnum? trainingAvailability,
    int? maxTrainingTime,
    List<AthleteTrainingAvailabilityCanTrainSportsEnum>? canTrainSports,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteTrainingAvailability.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteTrainingAvailability.copyWith.fieldName(...)`
class _$AthleteTrainingAvailabilityCWProxyImpl
    implements _$AthleteTrainingAvailabilityCWProxy {
  const _$AthleteTrainingAvailabilityCWProxyImpl(this._value);

  final AthleteTrainingAvailability _value;

  @override
  AthleteTrainingAvailability dayOfWeek(int? dayOfWeek) =>
      this(dayOfWeek: dayOfWeek);

  @override
  AthleteTrainingAvailability trainingAvailability(
    AthleteTrainingAvailabilityTrainingAvailabilityEnum? trainingAvailability,
  ) => this(trainingAvailability: trainingAvailability);

  @override
  AthleteTrainingAvailability maxTrainingTime(int? maxTrainingTime) =>
      this(maxTrainingTime: maxTrainingTime);

  @override
  AthleteTrainingAvailability canTrainSports(
    List<AthleteTrainingAvailabilityCanTrainSportsEnum>? canTrainSports,
  ) => this(canTrainSports: canTrainSports);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingAvailability(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingAvailability(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingAvailability call({
    Object? dayOfWeek = const $CopyWithPlaceholder(),
    Object? trainingAvailability = const $CopyWithPlaceholder(),
    Object? maxTrainingTime = const $CopyWithPlaceholder(),
    Object? canTrainSports = const $CopyWithPlaceholder(),
  }) {
    return AthleteTrainingAvailability(
      dayOfWeek: dayOfWeek == const $CopyWithPlaceholder()
          ? _value.dayOfWeek
          // ignore: cast_nullable_to_non_nullable
          : dayOfWeek as int?,
      trainingAvailability: trainingAvailability == const $CopyWithPlaceholder()
          ? _value.trainingAvailability
          // ignore: cast_nullable_to_non_nullable
          : trainingAvailability
                as AthleteTrainingAvailabilityTrainingAvailabilityEnum?,
      maxTrainingTime: maxTrainingTime == const $CopyWithPlaceholder()
          ? _value.maxTrainingTime
          // ignore: cast_nullable_to_non_nullable
          : maxTrainingTime as int?,
      canTrainSports: canTrainSports == const $CopyWithPlaceholder()
          ? _value.canTrainSports
          // ignore: cast_nullable_to_non_nullable
          : canTrainSports
                as List<AthleteTrainingAvailabilityCanTrainSportsEnum>?,
    );
  }
}

extension $AthleteTrainingAvailabilityCopyWith on AthleteTrainingAvailability {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteTrainingAvailability.copyWith(...)` or like so:`instanceOfAthleteTrainingAvailability.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteTrainingAvailabilityCWProxy get copyWith =>
      _$AthleteTrainingAvailabilityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteTrainingAvailability _$AthleteTrainingAvailabilityFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AthleteTrainingAvailability',
  json,
  ($checkedConvert) {
    final val = AthleteTrainingAvailability(
      dayOfWeek: $checkedConvert('day_of_week', (v) => (v as num?)?.toInt()),
      trainingAvailability: $checkedConvert(
        'training_availability',
        (v) => $enumDecodeNullable(
          _$AthleteTrainingAvailabilityTrainingAvailabilityEnumEnumMap,
          v,
        ),
      ),
      maxTrainingTime: $checkedConvert(
        'max_training_time',
        (v) => (v as num?)?.toInt(),
      ),
      canTrainSports: $checkedConvert(
        'can_train_sports',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => $enumDecode(
                _$AthleteTrainingAvailabilityCanTrainSportsEnumEnumMap,
                e,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'dayOfWeek': 'day_of_week',
    'trainingAvailability': 'training_availability',
    'maxTrainingTime': 'max_training_time',
    'canTrainSports': 'can_train_sports',
  },
);

Map<String, dynamic> _$AthleteTrainingAvailabilityToJson(
  AthleteTrainingAvailability instance,
) => <String, dynamic>{
  'day_of_week': ?instance.dayOfWeek,
  'training_availability':
      ?_$AthleteTrainingAvailabilityTrainingAvailabilityEnumEnumMap[instance
          .trainingAvailability],
  'max_training_time': ?instance.maxTrainingTime,
  'can_train_sports': ?instance.canTrainSports
      ?.map((e) => _$AthleteTrainingAvailabilityCanTrainSportsEnumEnumMap[e]!)
      .toList(),
};

const _$AthleteTrainingAvailabilityTrainingAvailabilityEnumEnumMap = {
  AthleteTrainingAvailabilityTrainingAvailabilityEnum.NORMAL: 'NORMAL',
  AthleteTrainingAvailabilityTrainingAvailabilityEnum.LIMITED: 'LIMITED',
  AthleteTrainingAvailabilityTrainingAvailabilityEnum.UNAVAILABLE:
      'UNAVAILABLE',
};

const _$AthleteTrainingAvailabilityCanTrainSportsEnumEnumMap = {
  AthleteTrainingAvailabilityCanTrainSportsEnum.ride: 'Ride',
  AthleteTrainingAvailabilityCanTrainSportsEnum.run: 'Run',
  AthleteTrainingAvailabilityCanTrainSportsEnum.swim: 'Swim',
  AthleteTrainingAvailabilityCanTrainSportsEnum.weightTraining:
      'WeightTraining',
  AthleteTrainingAvailabilityCanTrainSportsEnum.hike: 'Hike',
  AthleteTrainingAvailabilityCanTrainSportsEnum.walk: 'Walk',
  AthleteTrainingAvailabilityCanTrainSportsEnum.alpineSki: 'AlpineSki',
  AthleteTrainingAvailabilityCanTrainSportsEnum.backcountrySki:
      'BackcountrySki',
  AthleteTrainingAvailabilityCanTrainSportsEnum.badminton: 'Badminton',
  AthleteTrainingAvailabilityCanTrainSportsEnum.canoeing: 'Canoeing',
  AthleteTrainingAvailabilityCanTrainSportsEnum.crossfit: 'Crossfit',
  AthleteTrainingAvailabilityCanTrainSportsEnum.eBikeRide: 'EBikeRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.eMountainBikeRide:
      'EMountainBikeRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.elliptical: 'Elliptical',
  AthleteTrainingAvailabilityCanTrainSportsEnum.golf: 'Golf',
  AthleteTrainingAvailabilityCanTrainSportsEnum.gravelRide: 'GravelRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.trackRide: 'TrackRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.handcycle: 'Handcycle',
  AthleteTrainingAvailabilityCanTrainSportsEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  AthleteTrainingAvailabilityCanTrainSportsEnum.hockey: 'Hockey',
  AthleteTrainingAvailabilityCanTrainSportsEnum.iceSkate: 'IceSkate',
  AthleteTrainingAvailabilityCanTrainSportsEnum.inlineSkate: 'InlineSkate',
  AthleteTrainingAvailabilityCanTrainSportsEnum.kayaking: 'Kayaking',
  AthleteTrainingAvailabilityCanTrainSportsEnum.kitesurf: 'Kitesurf',
  AthleteTrainingAvailabilityCanTrainSportsEnum.mountainBikeRide:
      'MountainBikeRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.cyclocross: 'Cyclocross',
  AthleteTrainingAvailabilityCanTrainSportsEnum.nordicSki: 'NordicSki',
  AthleteTrainingAvailabilityCanTrainSportsEnum.openWaterSwim: 'OpenWaterSwim',
  AthleteTrainingAvailabilityCanTrainSportsEnum.padel: 'Padel',
  AthleteTrainingAvailabilityCanTrainSportsEnum.pilates: 'Pilates',
  AthleteTrainingAvailabilityCanTrainSportsEnum.pickleball: 'Pickleball',
  AthleteTrainingAvailabilityCanTrainSportsEnum.racquetball: 'Racquetball',
  AthleteTrainingAvailabilityCanTrainSportsEnum.rugby: 'Rugby',
  AthleteTrainingAvailabilityCanTrainSportsEnum.rockClimbing: 'RockClimbing',
  AthleteTrainingAvailabilityCanTrainSportsEnum.rollerSki: 'RollerSki',
  AthleteTrainingAvailabilityCanTrainSportsEnum.rowing: 'Rowing',
  AthleteTrainingAvailabilityCanTrainSportsEnum.sail: 'Sail',
  AthleteTrainingAvailabilityCanTrainSportsEnum.skateboard: 'Skateboard',
  AthleteTrainingAvailabilityCanTrainSportsEnum.snowboard: 'Snowboard',
  AthleteTrainingAvailabilityCanTrainSportsEnum.snowshoe: 'Snowshoe',
  AthleteTrainingAvailabilityCanTrainSportsEnum.soccer: 'Soccer',
  AthleteTrainingAvailabilityCanTrainSportsEnum.squash: 'Squash',
  AthleteTrainingAvailabilityCanTrainSportsEnum.stairStepper: 'StairStepper',
  AthleteTrainingAvailabilityCanTrainSportsEnum.standUpPaddling:
      'StandUpPaddling',
  AthleteTrainingAvailabilityCanTrainSportsEnum.surfing: 'Surfing',
  AthleteTrainingAvailabilityCanTrainSportsEnum.tableTennis: 'TableTennis',
  AthleteTrainingAvailabilityCanTrainSportsEnum.tennis: 'Tennis',
  AthleteTrainingAvailabilityCanTrainSportsEnum.trailRun: 'TrailRun',
  AthleteTrainingAvailabilityCanTrainSportsEnum.transition: 'Transition',
  AthleteTrainingAvailabilityCanTrainSportsEnum.velomobile: 'Velomobile',
  AthleteTrainingAvailabilityCanTrainSportsEnum.virtualRide: 'VirtualRide',
  AthleteTrainingAvailabilityCanTrainSportsEnum.virtualRow: 'VirtualRow',
  AthleteTrainingAvailabilityCanTrainSportsEnum.virtualRun: 'VirtualRun',
  AthleteTrainingAvailabilityCanTrainSportsEnum.virtualSki: 'VirtualSki',
  AthleteTrainingAvailabilityCanTrainSportsEnum.waterSport: 'WaterSport',
  AthleteTrainingAvailabilityCanTrainSportsEnum.wheelchair: 'Wheelchair',
  AthleteTrainingAvailabilityCanTrainSportsEnum.windsurf: 'Windsurf',
  AthleteTrainingAvailabilityCanTrainSportsEnum.workout: 'Workout',
  AthleteTrainingAvailabilityCanTrainSportsEnum.yoga: 'Yoga',
  AthleteTrainingAvailabilityCanTrainSportsEnum.other: 'Other',
};
