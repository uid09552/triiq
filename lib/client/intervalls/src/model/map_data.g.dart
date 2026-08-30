// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MapDataCWProxy {
  MapData bounds(List<List<double>>? bounds);

  MapData latlngs(List<List<double>>? latlngs);

  MapData route(AthleteRoute? route);

  MapData weather(ActivityWeather? weather);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MapData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MapData(...).copyWith(id: 12, name: "My name")
  /// ````
  MapData call({
    List<List<double>>? bounds,
    List<List<double>>? latlngs,
    AthleteRoute? route,
    ActivityWeather? weather,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMapData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMapData.copyWith.fieldName(...)`
class _$MapDataCWProxyImpl implements _$MapDataCWProxy {
  const _$MapDataCWProxyImpl(this._value);

  final MapData _value;

  @override
  MapData bounds(List<List<double>>? bounds) => this(bounds: bounds);

  @override
  MapData latlngs(List<List<double>>? latlngs) => this(latlngs: latlngs);

  @override
  MapData route(AthleteRoute? route) => this(route: route);

  @override
  MapData weather(ActivityWeather? weather) => this(weather: weather);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MapData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MapData(...).copyWith(id: 12, name: "My name")
  /// ````
  MapData call({
    Object? bounds = const $CopyWithPlaceholder(),
    Object? latlngs = const $CopyWithPlaceholder(),
    Object? route = const $CopyWithPlaceholder(),
    Object? weather = const $CopyWithPlaceholder(),
  }) {
    return MapData(
      bounds: bounds == const $CopyWithPlaceholder()
          ? _value.bounds
          // ignore: cast_nullable_to_non_nullable
          : bounds as List<List<double>>?,
      latlngs: latlngs == const $CopyWithPlaceholder()
          ? _value.latlngs
          // ignore: cast_nullable_to_non_nullable
          : latlngs as List<List<double>>?,
      route: route == const $CopyWithPlaceholder()
          ? _value.route
          // ignore: cast_nullable_to_non_nullable
          : route as AthleteRoute?,
      weather: weather == const $CopyWithPlaceholder()
          ? _value.weather
          // ignore: cast_nullable_to_non_nullable
          : weather as ActivityWeather?,
    );
  }
}

extension $MapDataCopyWith on MapData {
  /// Returns a callable class that can be used as follows: `instanceOfMapData.copyWith(...)` or like so:`instanceOfMapData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MapDataCWProxy get copyWith => _$MapDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapData _$MapDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MapData', json, ($checkedConvert) {
  final val = MapData(
    bounds: $checkedConvert(
      'bounds',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    ),
    latlngs: $checkedConvert(
      'latlngs',
      (v) => (v as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    ),
    route: $checkedConvert(
      'route',
      (v) =>
          v == null ? null : AthleteRoute.fromJson(v as Map<String, dynamic>),
    ),
    weather: $checkedConvert(
      'weather',
      (v) => v == null
          ? null
          : ActivityWeather.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MapDataToJson(MapData instance) => <String, dynamic>{
  'bounds': ?instance.bounds,
  'latlngs': ?instance.latlngs,
  'route': ?instance.route?.toJson(),
  'weather': ?instance.weather?.toJson(),
};
