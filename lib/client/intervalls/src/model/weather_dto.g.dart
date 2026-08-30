// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeatherDTOCWProxy {
  WeatherDTO forecasts(List<Forecast>? forecasts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherDTO call({List<Forecast>? forecasts});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeatherDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeatherDTO.copyWith.fieldName(...)`
class _$WeatherDTOCWProxyImpl implements _$WeatherDTOCWProxy {
  const _$WeatherDTOCWProxyImpl(this._value);

  final WeatherDTO _value;

  @override
  WeatherDTO forecasts(List<Forecast>? forecasts) => this(forecasts: forecasts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeatherDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeatherDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  WeatherDTO call({Object? forecasts = const $CopyWithPlaceholder()}) {
    return WeatherDTO(
      forecasts: forecasts == const $CopyWithPlaceholder()
          ? _value.forecasts
          // ignore: cast_nullable_to_non_nullable
          : forecasts as List<Forecast>?,
    );
  }
}

extension $WeatherDTOCopyWith on WeatherDTO {
  /// Returns a callable class that can be used as follows: `instanceOfWeatherDTO.copyWith(...)` or like so:`instanceOfWeatherDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeatherDTOCWProxy get copyWith => _$WeatherDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherDTO _$WeatherDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeatherDTO', json, ($checkedConvert) {
      final val = WeatherDTO(
        forecasts: $checkedConvert(
          'forecasts',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Forecast.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$WeatherDTOToJson(WeatherDTO instance) =>
    <String, dynamic>{
      'forecasts': ?instance.forecasts?.map((e) => e.toJson()).toList(),
    };
