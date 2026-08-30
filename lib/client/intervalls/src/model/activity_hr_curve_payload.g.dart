// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_hr_curve_payload.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityHRCurvePayloadCWProxy {
  ActivityHRCurvePayload secs(List<int>? secs);

  ActivityHRCurvePayload curves(List<ActivityHRCurve>? curves);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityHRCurvePayload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityHRCurvePayload(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityHRCurvePayload call({List<int>? secs, List<ActivityHRCurve>? curves});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityHRCurvePayload.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityHRCurvePayload.copyWith.fieldName(...)`
class _$ActivityHRCurvePayloadCWProxyImpl
    implements _$ActivityHRCurvePayloadCWProxy {
  const _$ActivityHRCurvePayloadCWProxyImpl(this._value);

  final ActivityHRCurvePayload _value;

  @override
  ActivityHRCurvePayload secs(List<int>? secs) => this(secs: secs);

  @override
  ActivityHRCurvePayload curves(List<ActivityHRCurve>? curves) =>
      this(curves: curves);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityHRCurvePayload(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityHRCurvePayload(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityHRCurvePayload call({
    Object? secs = const $CopyWithPlaceholder(),
    Object? curves = const $CopyWithPlaceholder(),
  }) {
    return ActivityHRCurvePayload(
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as List<int>?,
      curves: curves == const $CopyWithPlaceholder()
          ? _value.curves
          // ignore: cast_nullable_to_non_nullable
          : curves as List<ActivityHRCurve>?,
    );
  }
}

extension $ActivityHRCurvePayloadCopyWith on ActivityHRCurvePayload {
  /// Returns a callable class that can be used as follows: `instanceOfActivityHRCurvePayload.copyWith(...)` or like so:`instanceOfActivityHRCurvePayload.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityHRCurvePayloadCWProxy get copyWith =>
      _$ActivityHRCurvePayloadCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityHRCurvePayload _$ActivityHRCurvePayloadFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActivityHRCurvePayload', json, ($checkedConvert) {
  final val = ActivityHRCurvePayload(
    secs: $checkedConvert(
      'secs',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    curves: $checkedConvert(
      'curves',
      (v) => (v as List<dynamic>?)
          ?.map((e) => ActivityHRCurve.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ActivityHRCurvePayloadToJson(
  ActivityHRCurvePayload instance,
) => <String, dynamic>{
  'secs': ?instance.secs,
  'curves': ?instance.curves?.map((e) => e.toJson()).toList(),
};
