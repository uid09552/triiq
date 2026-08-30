// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SettingsCWProxy {
  Settings type(SettingsTypeEnum? type);

  Settings ctlFactor(double? ctlFactor);

  Settings atlFactor(double? atlFactor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({SettingsTypeEnum? type, double? ctlFactor, double? atlFactor});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSettings.copyWith.fieldName(...)`
class _$SettingsCWProxyImpl implements _$SettingsCWProxy {
  const _$SettingsCWProxyImpl(this._value);

  final Settings _value;

  @override
  Settings type(SettingsTypeEnum? type) => this(type: type);

  @override
  Settings ctlFactor(double? ctlFactor) => this(ctlFactor: ctlFactor);

  @override
  Settings atlFactor(double? atlFactor) => this(atlFactor: atlFactor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Settings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Settings(...).copyWith(id: 12, name: "My name")
  /// ````
  Settings call({
    Object? type = const $CopyWithPlaceholder(),
    Object? ctlFactor = const $CopyWithPlaceholder(),
    Object? atlFactor = const $CopyWithPlaceholder(),
  }) {
    return Settings(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as SettingsTypeEnum?,
      ctlFactor: ctlFactor == const $CopyWithPlaceholder()
          ? _value.ctlFactor
          // ignore: cast_nullable_to_non_nullable
          : ctlFactor as double?,
      atlFactor: atlFactor == const $CopyWithPlaceholder()
          ? _value.atlFactor
          // ignore: cast_nullable_to_non_nullable
          : atlFactor as double?,
    );
  }
}

extension $SettingsCopyWith on Settings {
  /// Returns a callable class that can be used as follows: `instanceOfSettings.copyWith(...)` or like so:`instanceOfSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SettingsCWProxy get copyWith => _$SettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Settings', json, ($checkedConvert) {
      final val = Settings(
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$SettingsTypeEnumEnumMap, v),
        ),
        ctlFactor: $checkedConvert('ctlFactor', (v) => (v as num?)?.toDouble()),
        atlFactor: $checkedConvert('atlFactor', (v) => (v as num?)?.toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'type': ?_$SettingsTypeEnumEnumMap[instance.type],
  'ctlFactor': ?instance.ctlFactor,
  'atlFactor': ?instance.atlFactor,
};

const _$SettingsTypeEnumEnumMap = {
  SettingsTypeEnum.ride: 'Ride',
  SettingsTypeEnum.run: 'Run',
  SettingsTypeEnum.swim: 'Swim',
  SettingsTypeEnum.weightTraining: 'WeightTraining',
  SettingsTypeEnum.hike: 'Hike',
  SettingsTypeEnum.walk: 'Walk',
  SettingsTypeEnum.alpineSki: 'AlpineSki',
  SettingsTypeEnum.backcountrySki: 'BackcountrySki',
  SettingsTypeEnum.badminton: 'Badminton',
  SettingsTypeEnum.canoeing: 'Canoeing',
  SettingsTypeEnum.crossfit: 'Crossfit',
  SettingsTypeEnum.eBikeRide: 'EBikeRide',
  SettingsTypeEnum.eMountainBikeRide: 'EMountainBikeRide',
  SettingsTypeEnum.elliptical: 'Elliptical',
  SettingsTypeEnum.golf: 'Golf',
  SettingsTypeEnum.gravelRide: 'GravelRide',
  SettingsTypeEnum.trackRide: 'TrackRide',
  SettingsTypeEnum.handcycle: 'Handcycle',
  SettingsTypeEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  SettingsTypeEnum.hockey: 'Hockey',
  SettingsTypeEnum.iceSkate: 'IceSkate',
  SettingsTypeEnum.inlineSkate: 'InlineSkate',
  SettingsTypeEnum.kayaking: 'Kayaking',
  SettingsTypeEnum.kitesurf: 'Kitesurf',
  SettingsTypeEnum.mountainBikeRide: 'MountainBikeRide',
  SettingsTypeEnum.cyclocross: 'Cyclocross',
  SettingsTypeEnum.nordicSki: 'NordicSki',
  SettingsTypeEnum.openWaterSwim: 'OpenWaterSwim',
  SettingsTypeEnum.padel: 'Padel',
  SettingsTypeEnum.pilates: 'Pilates',
  SettingsTypeEnum.pickleball: 'Pickleball',
  SettingsTypeEnum.racquetball: 'Racquetball',
  SettingsTypeEnum.rugby: 'Rugby',
  SettingsTypeEnum.rockClimbing: 'RockClimbing',
  SettingsTypeEnum.rollerSki: 'RollerSki',
  SettingsTypeEnum.rowing: 'Rowing',
  SettingsTypeEnum.sail: 'Sail',
  SettingsTypeEnum.skateboard: 'Skateboard',
  SettingsTypeEnum.snowboard: 'Snowboard',
  SettingsTypeEnum.snowshoe: 'Snowshoe',
  SettingsTypeEnum.soccer: 'Soccer',
  SettingsTypeEnum.squash: 'Squash',
  SettingsTypeEnum.stairStepper: 'StairStepper',
  SettingsTypeEnum.standUpPaddling: 'StandUpPaddling',
  SettingsTypeEnum.surfing: 'Surfing',
  SettingsTypeEnum.tableTennis: 'TableTennis',
  SettingsTypeEnum.tennis: 'Tennis',
  SettingsTypeEnum.trailRun: 'TrailRun',
  SettingsTypeEnum.transition: 'Transition',
  SettingsTypeEnum.velomobile: 'Velomobile',
  SettingsTypeEnum.virtualRide: 'VirtualRide',
  SettingsTypeEnum.virtualRow: 'VirtualRow',
  SettingsTypeEnum.virtualRun: 'VirtualRun',
  SettingsTypeEnum.virtualSki: 'VirtualSki',
  SettingsTypeEnum.waterSport: 'WaterSport',
  SettingsTypeEnum.wheelchair: 'Wheelchair',
  SettingsTypeEnum.windsurf: 'Windsurf',
  SettingsTypeEnum.workout: 'Workout',
  SettingsTypeEnum.yoga: 'Yoga',
  SettingsTypeEnum.other: 'Other',
};
