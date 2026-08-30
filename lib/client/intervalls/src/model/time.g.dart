// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimeCWProxy {
  Time startSecs(int? startSecs);

  Time endSecs(int? endSecs);

  Time index(int? index);

  Time temp(double? temp);

  Time feelsLike(double? feelsLike);

  Time humidity(int? humidity);

  Time windSpeed(double? windSpeed);

  Time windDeg(int? windDeg);

  Time windGust(double? windGust);

  Time rain(double? rain);

  Time showers(double? showers);

  Time snow(double? snow);

  Time clouds(int? clouds);

  Time pressure(double? pressure);

  Time weatherCode(int? weatherCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Time(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Time(...).copyWith(id: 12, name: "My name")
  /// ````
  Time call({
    int? startSecs,
    int? endSecs,
    int? index,
    double? temp,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? windDeg,
    double? windGust,
    double? rain,
    double? showers,
    double? snow,
    int? clouds,
    double? pressure,
    int? weatherCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTime.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTime.copyWith.fieldName(...)`
class _$TimeCWProxyImpl implements _$TimeCWProxy {
  const _$TimeCWProxyImpl(this._value);

  final Time _value;

  @override
  Time startSecs(int? startSecs) => this(startSecs: startSecs);

  @override
  Time endSecs(int? endSecs) => this(endSecs: endSecs);

  @override
  Time index(int? index) => this(index: index);

  @override
  Time temp(double? temp) => this(temp: temp);

  @override
  Time feelsLike(double? feelsLike) => this(feelsLike: feelsLike);

  @override
  Time humidity(int? humidity) => this(humidity: humidity);

  @override
  Time windSpeed(double? windSpeed) => this(windSpeed: windSpeed);

  @override
  Time windDeg(int? windDeg) => this(windDeg: windDeg);

  @override
  Time windGust(double? windGust) => this(windGust: windGust);

  @override
  Time rain(double? rain) => this(rain: rain);

  @override
  Time showers(double? showers) => this(showers: showers);

  @override
  Time snow(double? snow) => this(snow: snow);

  @override
  Time clouds(int? clouds) => this(clouds: clouds);

  @override
  Time pressure(double? pressure) => this(pressure: pressure);

  @override
  Time weatherCode(int? weatherCode) => this(weatherCode: weatherCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Time(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Time(...).copyWith(id: 12, name: "My name")
  /// ````
  Time call({
    Object? startSecs = const $CopyWithPlaceholder(),
    Object? endSecs = const $CopyWithPlaceholder(),
    Object? index = const $CopyWithPlaceholder(),
    Object? temp = const $CopyWithPlaceholder(),
    Object? feelsLike = const $CopyWithPlaceholder(),
    Object? humidity = const $CopyWithPlaceholder(),
    Object? windSpeed = const $CopyWithPlaceholder(),
    Object? windDeg = const $CopyWithPlaceholder(),
    Object? windGust = const $CopyWithPlaceholder(),
    Object? rain = const $CopyWithPlaceholder(),
    Object? showers = const $CopyWithPlaceholder(),
    Object? snow = const $CopyWithPlaceholder(),
    Object? clouds = const $CopyWithPlaceholder(),
    Object? pressure = const $CopyWithPlaceholder(),
    Object? weatherCode = const $CopyWithPlaceholder(),
  }) {
    return Time(
      startSecs: startSecs == const $CopyWithPlaceholder()
          ? _value.startSecs
          // ignore: cast_nullable_to_non_nullable
          : startSecs as int?,
      endSecs: endSecs == const $CopyWithPlaceholder()
          ? _value.endSecs
          // ignore: cast_nullable_to_non_nullable
          : endSecs as int?,
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int?,
      temp: temp == const $CopyWithPlaceholder()
          ? _value.temp
          // ignore: cast_nullable_to_non_nullable
          : temp as double?,
      feelsLike: feelsLike == const $CopyWithPlaceholder()
          ? _value.feelsLike
          // ignore: cast_nullable_to_non_nullable
          : feelsLike as double?,
      humidity: humidity == const $CopyWithPlaceholder()
          ? _value.humidity
          // ignore: cast_nullable_to_non_nullable
          : humidity as int?,
      windSpeed: windSpeed == const $CopyWithPlaceholder()
          ? _value.windSpeed
          // ignore: cast_nullable_to_non_nullable
          : windSpeed as double?,
      windDeg: windDeg == const $CopyWithPlaceholder()
          ? _value.windDeg
          // ignore: cast_nullable_to_non_nullable
          : windDeg as int?,
      windGust: windGust == const $CopyWithPlaceholder()
          ? _value.windGust
          // ignore: cast_nullable_to_non_nullable
          : windGust as double?,
      rain: rain == const $CopyWithPlaceholder()
          ? _value.rain
          // ignore: cast_nullable_to_non_nullable
          : rain as double?,
      showers: showers == const $CopyWithPlaceholder()
          ? _value.showers
          // ignore: cast_nullable_to_non_nullable
          : showers as double?,
      snow: snow == const $CopyWithPlaceholder()
          ? _value.snow
          // ignore: cast_nullable_to_non_nullable
          : snow as double?,
      clouds: clouds == const $CopyWithPlaceholder()
          ? _value.clouds
          // ignore: cast_nullable_to_non_nullable
          : clouds as int?,
      pressure: pressure == const $CopyWithPlaceholder()
          ? _value.pressure
          // ignore: cast_nullable_to_non_nullable
          : pressure as double?,
      weatherCode: weatherCode == const $CopyWithPlaceholder()
          ? _value.weatherCode
          // ignore: cast_nullable_to_non_nullable
          : weatherCode as int?,
    );
  }
}

extension $TimeCopyWith on Time {
  /// Returns a callable class that can be used as follows: `instanceOfTime.copyWith(...)` or like so:`instanceOfTime.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TimeCWProxy get copyWith => _$TimeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Time _$TimeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Time',
  json,
  ($checkedConvert) {
    final val = Time(
      startSecs: $checkedConvert('start_secs', (v) => (v as num?)?.toInt()),
      endSecs: $checkedConvert('end_secs', (v) => (v as num?)?.toInt()),
      index: $checkedConvert('index', (v) => (v as num?)?.toInt()),
      temp: $checkedConvert('temp', (v) => (v as num?)?.toDouble()),
      feelsLike: $checkedConvert('feels_like', (v) => (v as num?)?.toDouble()),
      humidity: $checkedConvert('humidity', (v) => (v as num?)?.toInt()),
      windSpeed: $checkedConvert('wind_speed', (v) => (v as num?)?.toDouble()),
      windDeg: $checkedConvert('wind_deg', (v) => (v as num?)?.toInt()),
      windGust: $checkedConvert('wind_gust', (v) => (v as num?)?.toDouble()),
      rain: $checkedConvert('rain', (v) => (v as num?)?.toDouble()),
      showers: $checkedConvert('showers', (v) => (v as num?)?.toDouble()),
      snow: $checkedConvert('snow', (v) => (v as num?)?.toDouble()),
      clouds: $checkedConvert('clouds', (v) => (v as num?)?.toInt()),
      pressure: $checkedConvert('pressure', (v) => (v as num?)?.toDouble()),
      weatherCode: $checkedConvert('weather_code', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'startSecs': 'start_secs',
    'endSecs': 'end_secs',
    'feelsLike': 'feels_like',
    'windSpeed': 'wind_speed',
    'windDeg': 'wind_deg',
    'windGust': 'wind_gust',
    'weatherCode': 'weather_code',
  },
);

Map<String, dynamic> _$TimeToJson(Time instance) => <String, dynamic>{
  'start_secs': ?instance.startSecs,
  'end_secs': ?instance.endSecs,
  'index': ?instance.index,
  'temp': ?instance.temp,
  'feels_like': ?instance.feelsLike,
  'humidity': ?instance.humidity,
  'wind_speed': ?instance.windSpeed,
  'wind_deg': ?instance.windDeg,
  'wind_gust': ?instance.windGust,
  'rain': ?instance.rain,
  'showers': ?instance.showers,
  'snow': ?instance.snow,
  'clouds': ?instance.clouds,
  'pressure': ?instance.pressure,
  'weather_code': ?instance.weatherCode,
};
