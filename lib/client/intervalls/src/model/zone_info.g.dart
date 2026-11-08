// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ZoneInfoCWProxy {
  ZoneInfo id(String? id);

  ZoneInfo start(double? start);

  ZoneInfo end(double? end);

  ZoneInfo startValue(double? startValue);

  ZoneInfo endValue(double? endValue);

  ZoneInfo secs(int? secs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneInfo call({
    String? id,
    double? start,
    double? end,
    double? startValue,
    double? endValue,
    int? secs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfZoneInfo.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfZoneInfo.copyWith.fieldName(...)`
class _$ZoneInfoCWProxyImpl implements _$ZoneInfoCWProxy {
  const _$ZoneInfoCWProxyImpl(this._value);

  final ZoneInfo _value;

  @override
  ZoneInfo id(String? id) => this(id: id);

  @override
  ZoneInfo start(double? start) => this(start: start);

  @override
  ZoneInfo end(double? end) => this(end: end);

  @override
  ZoneInfo startValue(double? startValue) => this(startValue: startValue);

  @override
  ZoneInfo endValue(double? endValue) => this(endValue: endValue);

  @override
  ZoneInfo secs(int? secs) => this(secs: secs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ZoneInfo(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ZoneInfo(...).copyWith(id: 12, name: "My name")
  /// ````
  ZoneInfo call({
    Object? id = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
    Object? end = const $CopyWithPlaceholder(),
    Object? startValue = const $CopyWithPlaceholder(),
    Object? endValue = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
  }) {
    return ZoneInfo(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as double?,
      end: end == const $CopyWithPlaceholder()
          ? _value.end
          // ignore: cast_nullable_to_non_nullable
          : end as double?,
      startValue: startValue == const $CopyWithPlaceholder()
          ? _value.startValue
          // ignore: cast_nullable_to_non_nullable
          : startValue as double?,
      endValue: endValue == const $CopyWithPlaceholder()
          ? _value.endValue
          // ignore: cast_nullable_to_non_nullable
          : endValue as double?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as int?,
    );
  }
}

extension $ZoneInfoCopyWith on ZoneInfo {
  /// Returns a callable class that can be used as follows: `instanceOfZoneInfo.copyWith(...)` or like so:`instanceOfZoneInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ZoneInfoCWProxy get copyWith => _$ZoneInfoCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneInfo _$ZoneInfoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ZoneInfo', json, ($checkedConvert) {
  final val = ZoneInfo(
    id: $checkedConvert('id', (v) => v as String?),
    start: $checkedConvert('start', (v) => (v as num?)?.toDouble()),
    end: $checkedConvert('end', (v) => (v as num?)?.toDouble()),
    startValue: $checkedConvert('start_value', (v) => (v as num?)?.toDouble()),
    endValue: $checkedConvert('end_value', (v) => (v as num?)?.toDouble()),
    secs: $checkedConvert('secs', (v) => (v as num?)?.toInt()),
  );
  return val;
}, fieldKeyMap: const {'startValue': 'start_value', 'endValue': 'end_value'});

Map<String, dynamic> _$ZoneInfoToJson(ZoneInfo instance) => <String, dynamic>{
  'id': ?instance.id,
  'start': ?instance.start,
  'end': ?instance.end,
  'start_value': ?instance.startValue,
  'end_value': ?instance.endValue,
  'secs': ?instance.secs,
};
