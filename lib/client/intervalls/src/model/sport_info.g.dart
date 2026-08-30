// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SportInfoCWProxy {
  SportInfo type(SportInfoTypeEnum? type);

  SportInfo eftp(double? eftp);

  SportInfo wPrime(double? wPrime);

  SportInfo pMax(double? pMax);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SportInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SportInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  SportInfo call({
    SportInfoTypeEnum? type,
    double? eftp,
    double? wPrime,
    double? pMax,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSportInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSportInfo.copyWith.fieldName(...)`
class _$SportInfoCWProxyImpl implements _$SportInfoCWProxy {
  const _$SportInfoCWProxyImpl(this._value);

  final SportInfo _value;

  @override
  SportInfo type(SportInfoTypeEnum? type) => this(type: type);

  @override
  SportInfo eftp(double? eftp) => this(eftp: eftp);

  @override
  SportInfo wPrime(double? wPrime) => this(wPrime: wPrime);

  @override
  SportInfo pMax(double? pMax) => this(pMax: pMax);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SportInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SportInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  SportInfo call({
    Object? type = const $CopyWithPlaceholder(),
    Object? eftp = const $CopyWithPlaceholder(),
    Object? wPrime = const $CopyWithPlaceholder(),
    Object? pMax = const $CopyWithPlaceholder(),
  }) {
    return SportInfo(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as SportInfoTypeEnum?,
      eftp: eftp == const $CopyWithPlaceholder()
          ? _value.eftp
          // ignore: cast_nullable_to_non_nullable
          : eftp as double?,
      wPrime: wPrime == const $CopyWithPlaceholder()
          ? _value.wPrime
          // ignore: cast_nullable_to_non_nullable
          : wPrime as double?,
      pMax: pMax == const $CopyWithPlaceholder()
          ? _value.pMax
          // ignore: cast_nullable_to_non_nullable
          : pMax as double?,
    );
  }
}

extension $SportInfoCopyWith on SportInfo {
  /// Returns a callable class that can be used as follows: `instanceOfSportInfo.copyWith(...)` or like so:`instanceOfSportInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SportInfoCWProxy get copyWith => _$SportInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportInfo _$SportInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SportInfo', json, ($checkedConvert) {
      final val = SportInfo(
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$SportInfoTypeEnumEnumMap, v),
        ),
        eftp: $checkedConvert('eftp', (v) => (v as num?)?.toDouble()),
        wPrime: $checkedConvert('wPrime', (v) => (v as num?)?.toDouble()),
        pMax: $checkedConvert('pMax', (v) => (v as num?)?.toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$SportInfoToJson(SportInfo instance) => <String, dynamic>{
  'type': ?_$SportInfoTypeEnumEnumMap[instance.type],
  'eftp': ?instance.eftp,
  'wPrime': ?instance.wPrime,
  'pMax': ?instance.pMax,
};

const _$SportInfoTypeEnumEnumMap = {
  SportInfoTypeEnum.ride: 'Ride',
  SportInfoTypeEnum.run: 'Run',
  SportInfoTypeEnum.swim: 'Swim',
  SportInfoTypeEnum.weightTraining: 'WeightTraining',
  SportInfoTypeEnum.hike: 'Hike',
  SportInfoTypeEnum.walk: 'Walk',
  SportInfoTypeEnum.alpineSki: 'AlpineSki',
  SportInfoTypeEnum.backcountrySki: 'BackcountrySki',
  SportInfoTypeEnum.badminton: 'Badminton',
  SportInfoTypeEnum.canoeing: 'Canoeing',
  SportInfoTypeEnum.crossfit: 'Crossfit',
  SportInfoTypeEnum.eBikeRide: 'EBikeRide',
  SportInfoTypeEnum.eMountainBikeRide: 'EMountainBikeRide',
  SportInfoTypeEnum.elliptical: 'Elliptical',
  SportInfoTypeEnum.golf: 'Golf',
  SportInfoTypeEnum.gravelRide: 'GravelRide',
  SportInfoTypeEnum.trackRide: 'TrackRide',
  SportInfoTypeEnum.handcycle: 'Handcycle',
  SportInfoTypeEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  SportInfoTypeEnum.hockey: 'Hockey',
  SportInfoTypeEnum.iceSkate: 'IceSkate',
  SportInfoTypeEnum.inlineSkate: 'InlineSkate',
  SportInfoTypeEnum.kayaking: 'Kayaking',
  SportInfoTypeEnum.kitesurf: 'Kitesurf',
  SportInfoTypeEnum.mountainBikeRide: 'MountainBikeRide',
  SportInfoTypeEnum.cyclocross: 'Cyclocross',
  SportInfoTypeEnum.nordicSki: 'NordicSki',
  SportInfoTypeEnum.openWaterSwim: 'OpenWaterSwim',
  SportInfoTypeEnum.padel: 'Padel',
  SportInfoTypeEnum.pilates: 'Pilates',
  SportInfoTypeEnum.pickleball: 'Pickleball',
  SportInfoTypeEnum.racquetball: 'Racquetball',
  SportInfoTypeEnum.rugby: 'Rugby',
  SportInfoTypeEnum.rockClimbing: 'RockClimbing',
  SportInfoTypeEnum.rollerSki: 'RollerSki',
  SportInfoTypeEnum.rowing: 'Rowing',
  SportInfoTypeEnum.sail: 'Sail',
  SportInfoTypeEnum.skateboard: 'Skateboard',
  SportInfoTypeEnum.snowboard: 'Snowboard',
  SportInfoTypeEnum.snowshoe: 'Snowshoe',
  SportInfoTypeEnum.soccer: 'Soccer',
  SportInfoTypeEnum.squash: 'Squash',
  SportInfoTypeEnum.stairStepper: 'StairStepper',
  SportInfoTypeEnum.standUpPaddling: 'StandUpPaddling',
  SportInfoTypeEnum.surfing: 'Surfing',
  SportInfoTypeEnum.tableTennis: 'TableTennis',
  SportInfoTypeEnum.tennis: 'Tennis',
  SportInfoTypeEnum.trailRun: 'TrailRun',
  SportInfoTypeEnum.transition: 'Transition',
  SportInfoTypeEnum.velomobile: 'Velomobile',
  SportInfoTypeEnum.virtualRide: 'VirtualRide',
  SportInfoTypeEnum.virtualRow: 'VirtualRow',
  SportInfoTypeEnum.virtualRun: 'VirtualRun',
  SportInfoTypeEnum.virtualSki: 'VirtualSki',
  SportInfoTypeEnum.waterSport: 'WaterSport',
  SportInfoTypeEnum.wheelchair: 'Wheelchair',
  SportInfoTypeEnum.windsurf: 'Windsurf',
  SportInfoTypeEnum.workout: 'Workout',
  SportInfoTypeEnum.yoga: 'Yoga',
  SportInfoTypeEnum.other: 'Other',
};
