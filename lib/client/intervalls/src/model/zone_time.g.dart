// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_time.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ZoneTimeCWProxy {
  ZoneTime id(String? id);

  ZoneTime secs(int? secs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneTime(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneTime(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneTime call({String? id, int? secs});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfZoneTime.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfZoneTime.copyWith.fieldName(...)`
class _$ZoneTimeCWProxyImpl implements _$ZoneTimeCWProxy {
  const _$ZoneTimeCWProxyImpl(this._value);

  final ZoneTime _value;

  @override
  ZoneTime id(String? id) => this(id: id);

  @override
  ZoneTime secs(int? secs) => this(secs: secs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneTime(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneTime(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneTime call({
    Object? id = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
  }) {
    return ZoneTime(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as int?,
    );
  }
}

extension $ZoneTimeCopyWith on ZoneTime {
  /// Returns a callable class that can be used as follows: `instanceOfZoneTime.copyWith(...)` or like so:`instanceOfZoneTime.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ZoneTimeCWProxy get copyWith => _$ZoneTimeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneTime _$ZoneTimeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ZoneTime', json, ($checkedConvert) {
      final val = ZoneTime(
        id: $checkedConvert('id', (v) => v as String?),
        secs: $checkedConvert('secs', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ZoneTimeToJson(ZoneTime instance) => <String, dynamic>{
  'id': ?instance.id,
  'secs': ?instance.secs,
};
