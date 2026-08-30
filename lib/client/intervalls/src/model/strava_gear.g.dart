// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strava_gear.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StravaGearCWProxy {
  StravaGear id(String? id);

  StravaGear name(String? name);

  StravaGear distance(double? distance);

  StravaGear primary(bool? primary);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StravaGear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StravaGear(...).copyWith(id: 12, name: "My name")
  /// ````
  StravaGear call({String? id, String? name, double? distance, bool? primary});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStravaGear.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStravaGear.copyWith.fieldName(...)`
class _$StravaGearCWProxyImpl implements _$StravaGearCWProxy {
  const _$StravaGearCWProxyImpl(this._value);

  final StravaGear _value;

  @override
  StravaGear id(String? id) => this(id: id);

  @override
  StravaGear name(String? name) => this(name: name);

  @override
  StravaGear distance(double? distance) => this(distance: distance);

  @override
  StravaGear primary(bool? primary) => this(primary: primary);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StravaGear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StravaGear(...).copyWith(id: 12, name: "My name")
  /// ````
  StravaGear call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? primary = const $CopyWithPlaceholder(),
  }) {
    return StravaGear(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      primary: primary == const $CopyWithPlaceholder()
          ? _value.primary
          // ignore: cast_nullable_to_non_nullable
          : primary as bool?,
    );
  }
}

extension $StravaGearCopyWith on StravaGear {
  /// Returns a callable class that can be used as follows: `instanceOfStravaGear.copyWith(...)` or like so:`instanceOfStravaGear.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StravaGearCWProxy get copyWith => _$StravaGearCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StravaGear _$StravaGearFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StravaGear', json, ($checkedConvert) {
      final val = StravaGear(
        id: $checkedConvert('id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
        primary: $checkedConvert('primary', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$StravaGearToJson(StravaGear instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'distance': ?instance.distance,
      'primary': ?instance.primary,
    };
