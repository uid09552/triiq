// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_curve_set_hr_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCurveSetHRCurveCWProxy {
  DataCurveSetHRCurve list(List<DataCurve>? list);

  DataCurveSetHRCurve activities(Map<String, Activity>? activities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetHRCurve call({
    List<DataCurve>? list,
    Map<String, Activity>? activities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCurveSetHRCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCurveSetHRCurve.copyWith.fieldName(...)`
class _$DataCurveSetHRCurveCWProxyImpl implements _$DataCurveSetHRCurveCWProxy {
  const _$DataCurveSetHRCurveCWProxyImpl(this._value);

  final DataCurveSetHRCurve _value;

  @override
  DataCurveSetHRCurve list(List<DataCurve>? list) => this(list: list);

  @override
  DataCurveSetHRCurve activities(Map<String, Activity>? activities) =>
      this(activities: activities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetHRCurve call({
    Object? list = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
  }) {
    return DataCurveSetHRCurve(
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

extension $DataCurveSetHRCurveCopyWith on DataCurveSetHRCurve {
  /// Returns a callable class that can be used as follows: `instanceOfDataCurveSetHRCurve.copyWith(...)` or like so:`instanceOfDataCurveSetHRCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCurveSetHRCurveCWProxy get copyWith =>
      _$DataCurveSetHRCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCurveSetHRCurve _$DataCurveSetHRCurveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DataCurveSetHRCurve', json, ($checkedConvert) {
      final val = DataCurveSetHRCurve(
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

Map<String, dynamic> _$DataCurveSetHRCurveToJson(
  DataCurveSetHRCurve instance,
) => <String, dynamic>{
  'list': ?instance.list?.map((e) => e.toJson()).toList(),
  'activities': ?instance.activities?.map((k, e) => MapEntry(k, e.toJson())),
};
