// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_curve_set_pace_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCurveSetPaceCurveCWProxy {
  DataCurveSetPaceCurve list(List<DataCurve>? list);

  DataCurveSetPaceCurve activities(Map<String, Activity>? activities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetPaceCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetPaceCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetPaceCurve call({
    List<DataCurve>? list,
    Map<String, Activity>? activities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCurveSetPaceCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCurveSetPaceCurve.copyWith.fieldName(...)`
class _$DataCurveSetPaceCurveCWProxyImpl
    implements _$DataCurveSetPaceCurveCWProxy {
  const _$DataCurveSetPaceCurveCWProxyImpl(this._value);

  final DataCurveSetPaceCurve _value;

  @override
  DataCurveSetPaceCurve list(List<DataCurve>? list) => this(list: list);

  @override
  DataCurveSetPaceCurve activities(Map<String, Activity>? activities) =>
      this(activities: activities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurveSetPaceCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurveSetPaceCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurveSetPaceCurve call({
    Object? list = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
  }) {
    return DataCurveSetPaceCurve(
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

extension $DataCurveSetPaceCurveCopyWith on DataCurveSetPaceCurve {
  /// Returns a callable class that can be used as follows: `instanceOfDataCurveSetPaceCurve.copyWith(...)` or like so:`instanceOfDataCurveSetPaceCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCurveSetPaceCurveCWProxy get copyWith =>
      _$DataCurveSetPaceCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCurveSetPaceCurve _$DataCurveSetPaceCurveFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataCurveSetPaceCurve', json, ($checkedConvert) {
  final val = DataCurveSetPaceCurve(
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

Map<String, dynamic> _$DataCurveSetPaceCurveToJson(
  DataCurveSetPaceCurve instance,
) => <String, dynamic>{
  'list': ?instance.list?.map((e) => e.toJson()).toList(),
  'activities': ?instance.activities?.map((k, e) => MapEntry(k, e.toJson())),
};
