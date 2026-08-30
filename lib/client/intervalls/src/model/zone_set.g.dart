// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_set.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ZoneSetCWProxy {
  ZoneSet code(String? code);

  ZoneSet zones(List<ZoneInfo>? zones);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneSet(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneSet call({String? code, List<ZoneInfo>? zones});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfZoneSet.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfZoneSet.copyWith.fieldName(...)`
class _$ZoneSetCWProxyImpl implements _$ZoneSetCWProxy {
  const _$ZoneSetCWProxyImpl(this._value);

  final ZoneSet _value;

  @override
  ZoneSet code(String? code) => this(code: code);

  @override
  ZoneSet zones(List<ZoneInfo>? zones) => this(zones: zones);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneSet(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneSet(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneSet call({
    Object? code = const $CopyWithPlaceholder(),
    Object? zones = const $CopyWithPlaceholder(),
  }) {
    return ZoneSet(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      zones: zones == const $CopyWithPlaceholder()
          ? _value.zones
          // ignore: cast_nullable_to_non_nullable
          : zones as List<ZoneInfo>?,
    );
  }
}

extension $ZoneSetCopyWith on ZoneSet {
  /// Returns a callable class that can be used as follows: `instanceOfZoneSet.copyWith(...)` or like so:`instanceOfZoneSet.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ZoneSetCWProxy get copyWith => _$ZoneSetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneSet _$ZoneSetFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ZoneSet', json, ($checkedConvert) {
      final val = ZoneSet(
        code: $checkedConvert('code', (v) => v as String?),
        zones: $checkedConvert(
          'zones',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ZoneInfo.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ZoneSetToJson(ZoneSet instance) => <String, dynamic>{
  'code': ?instance.code,
  'zones': ?instance.zones?.map((e) => e.toJson()).toList(),
};
