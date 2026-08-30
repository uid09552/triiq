// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_stats.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GearStatsCWProxy {
  GearStats distance(double? distance);

  GearStats elapsedTime(double? elapsedTime);

  GearStats movingTime(double? movingTime);

  GearStats activities(int? activities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GearStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GearStats(...).copyWith(id: 12, name: "My name")
  /// ````
  GearStats call({
    double? distance,
    double? elapsedTime,
    double? movingTime,
    int? activities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGearStats.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGearStats.copyWith.fieldName(...)`
class _$GearStatsCWProxyImpl implements _$GearStatsCWProxy {
  const _$GearStatsCWProxyImpl(this._value);

  final GearStats _value;

  @override
  GearStats distance(double? distance) => this(distance: distance);

  @override
  GearStats elapsedTime(double? elapsedTime) => this(elapsedTime: elapsedTime);

  @override
  GearStats movingTime(double? movingTime) => this(movingTime: movingTime);

  @override
  GearStats activities(int? activities) => this(activities: activities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GearStats(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GearStats(...).copyWith(id: 12, name: "My name")
  /// ````
  GearStats call({
    Object? distance = const $CopyWithPlaceholder(),
    Object? elapsedTime = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
  }) {
    return GearStats(
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      elapsedTime: elapsedTime == const $CopyWithPlaceholder()
          ? _value.elapsedTime
          // ignore: cast_nullable_to_non_nullable
          : elapsedTime as double?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as double?,
      activities: activities == const $CopyWithPlaceholder()
          ? _value.activities
          // ignore: cast_nullable_to_non_nullable
          : activities as int?,
    );
  }
}

extension $GearStatsCopyWith on GearStats {
  /// Returns a callable class that can be used as follows: `instanceOfGearStats.copyWith(...)` or like so:`instanceOfGearStats.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GearStatsCWProxy get copyWith => _$GearStatsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GearStats _$GearStatsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'GearStats',
  json,
  ($checkedConvert) {
    final val = GearStats(
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      elapsedTime: $checkedConvert(
        'elapsed_time',
        (v) => (v as num?)?.toDouble(),
      ),
      movingTime: $checkedConvert(
        'moving_time',
        (v) => (v as num?)?.toDouble(),
      ),
      activities: $checkedConvert('activities', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'elapsedTime': 'elapsed_time',
    'movingTime': 'moving_time',
  },
);

Map<String, dynamic> _$GearStatsToJson(GearStats instance) => <String, dynamic>{
  'distance': ?instance.distance,
  'elapsed_time': ?instance.elapsedTime,
  'moving_time': ?instance.movingTime,
  'activities': ?instance.activities,
};
