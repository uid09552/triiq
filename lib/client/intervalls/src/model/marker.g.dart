// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marker.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MarkerCWProxy {
  Marker lat(double? lat);

  Marker lng(double? lng);

  Marker name(String? name);

  Marker description(String? description);

  Marker icon(String? icon);

  Marker color(String? color);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Marker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Marker(...).copyWith(id: 12, name: "My name")
  /// ````
  Marker call({
    double? lat,
    double? lng,
    String? name,
    String? description,
    String? icon,
    String? color,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMarker.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMarker.copyWith.fieldName(...)`
class _$MarkerCWProxyImpl implements _$MarkerCWProxy {
  const _$MarkerCWProxyImpl(this._value);

  final Marker _value;

  @override
  Marker lat(double? lat) => this(lat: lat);

  @override
  Marker lng(double? lng) => this(lng: lng);

  @override
  Marker name(String? name) => this(name: name);

  @override
  Marker description(String? description) => this(description: description);

  @override
  Marker icon(String? icon) => this(icon: icon);

  @override
  Marker color(String? color) => this(color: color);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Marker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Marker(...).copyWith(id: 12, name: "My name")
  /// ````
  Marker call({
    Object? lat = const $CopyWithPlaceholder(),
    Object? lng = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
  }) {
    return Marker(
      lat: lat == const $CopyWithPlaceholder()
          ? _value.lat
          // ignore: cast_nullable_to_non_nullable
          : lat as double?,
      lng: lng == const $CopyWithPlaceholder()
          ? _value.lng
          // ignore: cast_nullable_to_non_nullable
          : lng as double?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as String?,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as String?,
    );
  }
}

extension $MarkerCopyWith on Marker {
  /// Returns a callable class that can be used as follows: `instanceOfMarker.copyWith(...)` or like so:`instanceOfMarker.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MarkerCWProxy get copyWith => _$MarkerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Marker _$MarkerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Marker', json, ($checkedConvert) {
      final val = Marker(
        lat: $checkedConvert('lat', (v) => (v as num?)?.toDouble()),
        lng: $checkedConvert('lng', (v) => (v as num?)?.toDouble()),
        name: $checkedConvert('name', (v) => v as String?),
        description: $checkedConvert('description', (v) => v as String?),
        icon: $checkedConvert('icon', (v) => v as String?),
        color: $checkedConvert('color', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MarkerToJson(Marker instance) => <String, dynamic>{
  'lat': ?instance.lat,
  'lng': ?instance.lng,
  'name': ?instance.name,
  'description': ?instance.description,
  'icon': ?instance.icon,
  'color': ?instance.color,
};
