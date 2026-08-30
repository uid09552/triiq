// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wind_rose.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WindRoseCWProxy {
  WindRose avgSpeed(List<double>? avgSpeed);

  WindRose count(List<int>? count);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WindRose(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WindRose(...).copyWith(id: 12, name: "My name")
  /// ````
  WindRose call({List<double>? avgSpeed, List<int>? count});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWindRose.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWindRose.copyWith.fieldName(...)`
class _$WindRoseCWProxyImpl implements _$WindRoseCWProxy {
  const _$WindRoseCWProxyImpl(this._value);

  final WindRose _value;

  @override
  WindRose avgSpeed(List<double>? avgSpeed) => this(avgSpeed: avgSpeed);

  @override
  WindRose count(List<int>? count) => this(count: count);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WindRose(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WindRose(...).copyWith(id: 12, name: "My name")
  /// ````
  WindRose call({
    Object? avgSpeed = const $CopyWithPlaceholder(),
    Object? count = const $CopyWithPlaceholder(),
  }) {
    return WindRose(
      avgSpeed: avgSpeed == const $CopyWithPlaceholder()
          ? _value.avgSpeed
          // ignore: cast_nullable_to_non_nullable
          : avgSpeed as List<double>?,
      count: count == const $CopyWithPlaceholder()
          ? _value.count
          // ignore: cast_nullable_to_non_nullable
          : count as List<int>?,
    );
  }
}

extension $WindRoseCopyWith on WindRose {
  /// Returns a callable class that can be used as follows: `instanceOfWindRose.copyWith(...)` or like so:`instanceOfWindRose.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WindRoseCWProxy get copyWith => _$WindRoseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WindRose _$WindRoseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WindRose', json, ($checkedConvert) {
      final val = WindRose(
        avgSpeed: $checkedConvert(
          'avg_speed',
          (v) =>
              (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
        ),
        count: $checkedConvert(
          'count',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'avgSpeed': 'avg_speed'});

Map<String, dynamic> _$WindRoseToJson(WindRose instance) => <String, dynamic>{
  'avg_speed': ?instance.avgSpeed,
  'count': ?instance.count,
};
