// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_weather.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityWeatherCWProxy {
  ActivityWeather points(List<WeatherPoint>? points);

  ActivityWeather closestPoints(List<Closest>? closestPoints);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityWeather(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityWeather(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityWeather call({
    List<WeatherPoint>? points,
    List<Closest>? closestPoints,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityWeather.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityWeather.copyWith.fieldName(...)`
class _$ActivityWeatherCWProxyImpl implements _$ActivityWeatherCWProxy {
  const _$ActivityWeatherCWProxyImpl(this._value);

  final ActivityWeather _value;

  @override
  ActivityWeather points(List<WeatherPoint>? points) => this(points: points);

  @override
  ActivityWeather closestPoints(List<Closest>? closestPoints) =>
      this(closestPoints: closestPoints);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityWeather(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityWeather(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityWeather call({
    Object? points = const $CopyWithPlaceholder(),
    Object? closestPoints = const $CopyWithPlaceholder(),
  }) {
    return ActivityWeather(
      points: points == const $CopyWithPlaceholder()
          ? _value.points
          // ignore: cast_nullable_to_non_nullable
          : points as List<WeatherPoint>?,
      closestPoints: closestPoints == const $CopyWithPlaceholder()
          ? _value.closestPoints
          // ignore: cast_nullable_to_non_nullable
          : closestPoints as List<Closest>?,
    );
  }
}

extension $ActivityWeatherCopyWith on ActivityWeather {
  /// Returns a callable class that can be used as follows: `instanceOfActivityWeather.copyWith(...)` or like so:`instanceOfActivityWeather.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityWeatherCWProxy get copyWith => _$ActivityWeatherCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityWeather _$ActivityWeatherFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityWeather', json, ($checkedConvert) {
      final val = ActivityWeather(
        points: $checkedConvert(
          'points',
          (v) => (v as List<dynamic>?)
              ?.map((e) => WeatherPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        closestPoints: $checkedConvert(
          'closest_points',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Closest.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'closestPoints': 'closest_points'});

Map<String, dynamic> _$ActivityWeatherToJson(
  ActivityWeather instance,
) => <String, dynamic>{
  'points': ?instance.points?.map((e) => e.toJson()).toList(),
  'closest_points': ?instance.closestPoints?.map((e) => e.toJson()).toList(),
};
