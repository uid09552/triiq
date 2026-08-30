// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_power_curve_payload.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityPowerCurvePayloadCWProxy {
  ActivityPowerCurvePayload afterKj(int? afterKj);

  ActivityPowerCurvePayload secs(List<int>? secs);

  ActivityPowerCurvePayload curves(List<ActivityPowerCurve>? curves);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityPowerCurvePayload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityPowerCurvePayload(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityPowerCurvePayload call({
    int? afterKj,
    List<int>? secs,
    List<ActivityPowerCurve>? curves,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityPowerCurvePayload.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityPowerCurvePayload.copyWith.fieldName(...)`
class _$ActivityPowerCurvePayloadCWProxyImpl
    implements _$ActivityPowerCurvePayloadCWProxy {
  const _$ActivityPowerCurvePayloadCWProxyImpl(this._value);

  final ActivityPowerCurvePayload _value;

  @override
  ActivityPowerCurvePayload afterKj(int? afterKj) => this(afterKj: afterKj);

  @override
  ActivityPowerCurvePayload secs(List<int>? secs) => this(secs: secs);

  @override
  ActivityPowerCurvePayload curves(List<ActivityPowerCurve>? curves) =>
      this(curves: curves);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityPowerCurvePayload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityPowerCurvePayload(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityPowerCurvePayload call({
    Object? afterKj = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
    Object? curves = const $CopyWithPlaceholder(),
  }) {
    return ActivityPowerCurvePayload(
      afterKj: afterKj == const $CopyWithPlaceholder()
          ? _value.afterKj
          // ignore: cast_nullable_to_non_nullable
          : afterKj as int?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as List<int>?,
      curves: curves == const $CopyWithPlaceholder()
          ? _value.curves
          // ignore: cast_nullable_to_non_nullable
          : curves as List<ActivityPowerCurve>?,
    );
  }
}

extension $ActivityPowerCurvePayloadCopyWith on ActivityPowerCurvePayload {
  /// Returns a callable class that can be used as follows: `instanceOfActivityPowerCurvePayload.copyWith(...)` or like so:`instanceOfActivityPowerCurvePayload.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityPowerCurvePayloadCWProxy get copyWith =>
      _$ActivityPowerCurvePayloadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityPowerCurvePayload _$ActivityPowerCurvePayloadFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActivityPowerCurvePayload', json, ($checkedConvert) {
  final val = ActivityPowerCurvePayload(
    afterKj: $checkedConvert('after_kj', (v) => (v as num?)?.toInt()),
    secs: $checkedConvert(
      'secs',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    curves: $checkedConvert(
      'curves',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ActivityPowerCurve.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'afterKj': 'after_kj'});

Map<String, dynamic> _$ActivityPowerCurvePayloadToJson(
  ActivityPowerCurvePayload instance,
) => <String, dynamic>{
  'after_kj': ?instance.afterKj,
  'secs': ?instance.secs,
  'curves': ?instance.curves?.map((e) => e.toJson()).toList(),
};
