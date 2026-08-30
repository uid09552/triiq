// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ForecastCWProxy {
  Forecast id(int? id);

  Forecast provider(ForecastProviderEnum? provider);

  Forecast location(String? location);

  Forecast label(String? label);

  Forecast lat(double? lat);

  Forecast lon(double? lon);

  Forecast enabled(bool? enabled);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Forecast(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Forecast(...).copyWith(id: 12, name: "My name")
  /// ````
  Forecast call({
    int? id,
    ForecastProviderEnum? provider,
    String? location,
    String? label,
    double? lat,
    double? lon,
    bool? enabled,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfForecast.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfForecast.copyWith.fieldName(...)`
class _$ForecastCWProxyImpl implements _$ForecastCWProxy {
  const _$ForecastCWProxyImpl(this._value);

  final Forecast _value;

  @override
  Forecast id(int? id) => this(id: id);

  @override
  Forecast provider(ForecastProviderEnum? provider) => this(provider: provider);

  @override
  Forecast location(String? location) => this(location: location);

  @override
  Forecast label(String? label) => this(label: label);

  @override
  Forecast lat(double? lat) => this(lat: lat);

  @override
  Forecast lon(double? lon) => this(lon: lon);

  @override
  Forecast enabled(bool? enabled) => this(enabled: enabled);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Forecast(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Forecast(...).copyWith(id: 12, name: "My name")
  /// ````
  Forecast call({
    Object? id = const $CopyWithPlaceholder(),
    Object? provider = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? lat = const $CopyWithPlaceholder(),
    Object? lon = const $CopyWithPlaceholder(),
    Object? enabled = const $CopyWithPlaceholder(),
  }) {
    return Forecast(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      provider: provider == const $CopyWithPlaceholder()
          ? _value.provider
          // ignore: cast_nullable_to_non_nullable
          : provider as ForecastProviderEnum?,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String?,
      lat: lat == const $CopyWithPlaceholder()
          ? _value.lat
          // ignore: cast_nullable_to_non_nullable
          : lat as double?,
      lon: lon == const $CopyWithPlaceholder()
          ? _value.lon
          // ignore: cast_nullable_to_non_nullable
          : lon as double?,
      enabled: enabled == const $CopyWithPlaceholder()
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool?,
    );
  }
}

extension $ForecastCopyWith on Forecast {
  /// Returns a callable class that can be used as follows: `instanceOfForecast.copyWith(...)` or like so:`instanceOfForecast.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ForecastCWProxy get copyWith => _$ForecastCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Forecast _$ForecastFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Forecast', json, ($checkedConvert) {
      final val = Forecast(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        provider: $checkedConvert(
          'provider',
          (v) => $enumDecodeNullable(_$ForecastProviderEnumEnumMap, v),
        ),
        location: $checkedConvert('location', (v) => v as String?),
        label: $checkedConvert('label', (v) => v as String?),
        lat: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
        lon: $checkedConvert('lon', (v) => (v as num?)?.toDouble()),
        enabled: $checkedConvert('enabled', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$ForecastToJson(Forecast instance) => <String, dynamic>{
  'id': ?instance.id,
  'provider': ?_$ForecastProviderEnumEnumMap[instance.provider],
  'location': ?instance.location,
  'label': ?instance.label,
  'lat': ?instance.lat,
  'lon': ?instance.lon,
  'enabled': ?instance.enabled,
};

const _$ForecastProviderEnumEnumMap = {
  ForecastProviderEnum.OPEN_WEATHER: 'OPEN_WEATHER',
};
