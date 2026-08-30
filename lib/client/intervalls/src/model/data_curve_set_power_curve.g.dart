// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_curve_set_power_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCurveSetPowerCurveCWProxy {
  DataCurveSetPowerCurve list(List<DataCurve>? list);

  DataCurveSetPowerCurve activities(Map<String, Activity>? activities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetPowerCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetPowerCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetPowerCurve call({
    List<DataCurve>? list,
    Map<String, Activity>? activities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCurveSetPowerCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCurveSetPowerCurve.copyWith.fieldName(...)`
class _$DataCurveSetPowerCurveCWProxyImpl
    implements _$DataCurveSetPowerCurveCWProxy {
  const _$DataCurveSetPowerCurveCWProxyImpl(this._value);

  final DataCurveSetPowerCurve _value;

  @override
  DataCurveSetPowerCurve list(List<DataCurve>? list) => this(list: list);

  @override
  DataCurveSetPowerCurve activities(Map<String, Activity>? activities) =>
      this(activities: activities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetPowerCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetPowerCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetPowerCurve call({
    Object? list = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
  }) {
    return DataCurveSetPowerCurve(
      list: list == const $CopyWithPlaceholder()
          ? _value.list
          // ignore: cast_nullable_to_non_nullable
          : list as List<DataCurve>?,
      activities: activities == const $CopyWithPlaceholder()
          ? _value.activities
          // ignore: cast_nullable_to_non_nullable
          : activities as Map<String, Activity>?,
    );
  }
}

extension $DataCurveSetPowerCurveCopyWith on DataCurveSetPowerCurve {
  /// Returns a callable class that can be used as follows: `instanceOfDataCurveSetPowerCurve.copyWith(...)` or like so:`instanceOfDataCurveSetPowerCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCurveSetPowerCurveCWProxy get copyWith =>
      _$DataCurveSetPowerCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCurveSetPowerCurve _$DataCurveSetPowerCurveFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataCurveSetPowerCurve', json, ($checkedConvert) {
  final val = DataCurveSetPowerCurve(
    list: $checkedConvert(
      'list',
      (v) => (v as List<dynamic>?)
          ?.map((e) => DataCurve.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    activities: $checkedConvert(
      'activities',
      (v) => (v as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Activity.fromJson(e as Map<String, dynamic>)),
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$DataCurveSetPowerCurveToJson(
  DataCurveSetPowerCurve instance,
) => <String, dynamic>{
  'list': ?instance.list?.map((e) => e.toJson()).toList(),
  'activities': ?instance.activities?.map((k, e) => MapEntry(k, e.toJson())),
};
