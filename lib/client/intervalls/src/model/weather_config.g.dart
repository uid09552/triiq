// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeatherConfigCWProxy {
  WeatherConfig forecasts(List<Forecast>? forecasts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherConfig call({List<Forecast>? forecasts});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeatherConfig.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeatherConfig.copyWith.fieldName(...)`
class _$WeatherConfigCWProxyImpl implements _$WeatherConfigCWProxy {
  const _$WeatherConfigCWProxyImpl(this._value);

  final WeatherConfig _value;

  @override
  WeatherConfig forecasts(List<Forecast>? forecasts) =>
      this(forecasts: forecasts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherConfig(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherConfig(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherConfig call({Object? forecasts = const $CopyWithPlaceholder()}) {
    return WeatherConfig(
      forecasts: forecasts == const $CopyWithPlaceholder()
          ? _value.forecasts
          // ignore: cast_nullable_to_non_nullable
          : forecasts as List<Forecast>?,
    );
  }
}

extension $WeatherConfigCopyWith on WeatherConfig {
  /// Returns a callable class that can be used as follows: `instanceOfWeatherConfig.copyWith(...)` or like so:`instanceOfWeatherConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeatherConfigCWProxy get copyWith => _$WeatherConfigCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherConfig _$WeatherConfigFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeatherConfig', json, ($checkedConvert) {
      final val = WeatherConfig(
        forecasts: $checkedConvert(
          'forecasts',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Forecast.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeatherConfigToJson(WeatherConfig instance) =>
    <String, dynamic>{
      'forecasts': ?instance.forecasts?.map((e) => e.toJson()).toList(),
    };
