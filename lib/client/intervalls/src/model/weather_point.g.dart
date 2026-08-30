// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_point.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeatherPointCWProxy {
  WeatherPoint latitude(double? latitude);

  WeatherPoint longitude(double? longitude);

  WeatherPoint times(List<Time>? times);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherPoint call({double? latitude, double? longitude, List<Time>? times});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeatherPoint.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeatherPoint.copyWith.fieldName(...)`
class _$WeatherPointCWProxyImpl implements _$WeatherPointCWProxy {
  const _$WeatherPointCWProxyImpl(this._value);

  final WeatherPoint _value;

  @override
  WeatherPoint latitude(double? latitude) => this(latitude: latitude);

  @override
  WeatherPoint longitude(double? longitude) => this(longitude: longitude);

  @override
  WeatherPoint times(List<Time>? times) => this(times: times);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherPoint(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherPoint(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherPoint call({
    Object? latitude = const $CopyWithPlaceholder(),
    Object? longitude = const $CopyWithPlaceholder(),
    Object? times = const $CopyWithPlaceholder(),
  }) {
    return WeatherPoint(
      latitude: latitude == const $CopyWithPlaceholder()
          ? _value.latitude
          // ignore: cast_nullable_to_non_nullable
          : latitude as double?,
      longitude: longitude == const $CopyWithPlaceholder()
          ? _value.longitude
          // ignore: cast_nullable_to_non_nullable
          : longitude as double?,
      times: times == const $CopyWithPlaceholder()
          ? _value.times
          // ignore: cast_nullable_to_non_nullable
          : times as List<Time>?,
    );
  }
}

extension $WeatherPointCopyWith on WeatherPoint {
  /// Returns a callable class that can be used as follows: `instanceOfWeatherPoint.copyWith(...)` or like so:`instanceOfWeatherPoint.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeatherPointCWProxy get copyWith => _$WeatherPointCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherPoint _$WeatherPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeatherPoint', json, ($checkedConvert) {
      final val = WeatherPoint(
        latitude: $checkedConvert('latitude', (v) => (v as num?)?.toDouble()),
        longitude: $checkedConvert('longitude', (v) => (v as num?)?.toDouble()),
        times: $checkedConvert(
          'times',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Time.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeatherPointToJson(WeatherPoint instance) =>
    <String, dynamic>{
      'latitude': ?instance.latitude,
      'longitude': ?instance.longitude,
      'times': ?instance.times?.map((e) => e.toJson()).toList(),
    };
