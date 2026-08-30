// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pace_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaceCurveCWProxy {
  PaceCurve id(String? id);

  PaceCurve filters(List<ActivityFilter>? filters);

  PaceCurve label(String? label);

  PaceCurve filterLabel(String? filterLabel);

  PaceCurve percentile(double? percentile);

  PaceCurve startDateLocal(String? startDateLocal);

  PaceCurve endDateLocal(String? endDateLocal);

  PaceCurve days(int? days);

  PaceCurve movingTime(int? movingTime);

  PaceCurve trainingLoad(int? trainingLoad);

  PaceCurve weight(double? weight);

  PaceCurve distance(List<double>? distance);

  PaceCurve values(List<int>? values);

  PaceCurve submaxValues(List<List<int>>? submaxValues);

  PaceCurve submaxActivityId(List<List<String>>? submaxActivityId);

  PaceCurve startIndex(List<int>? startIndex);

  PaceCurve endIndex(List<int>? endIndex);

  PaceCurve activityId(List<String>? activityId);

  PaceCurve type(PaceCurveTypeEnum? type);

  PaceCurve paceModels(List<PaceModel>? paceModels);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceCurve call({
    String? id,
    List<ActivityFilter>? filters,
    String? label,
    String? filterLabel,
    double? percentile,
    String? startDateLocal,
    String? endDateLocal,
    int? days,
    int? movingTime,
    int? trainingLoad,
    double? weight,
    List<double>? distance,
    List<int>? values,
    List<List<int>>? submaxValues,
    List<List<String>>? submaxActivityId,
    List<int>? startIndex,
    List<int>? endIndex,
    List<String>? activityId,
    PaceCurveTypeEnum? type,
    List<PaceModel>? paceModels,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaceCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaceCurve.copyWith.fieldName(...)`
class _$PaceCurveCWProxyImpl implements _$PaceCurveCWProxy {
  const _$PaceCurveCWProxyImpl(this._value);

  final PaceCurve _value;

  @override
  PaceCurve id(String? id) => this(id: id);

  @override
  PaceCurve filters(List<ActivityFilter>? filters) => this(filters: filters);

  @override
  PaceCurve label(String? label) => this(label: label);

  @override
  PaceCurve filterLabel(String? filterLabel) => this(filterLabel: filterLabel);

  @override
  PaceCurve percentile(double? percentile) => this(percentile: percentile);

  @override
  PaceCurve startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  PaceCurve endDateLocal(String? endDateLocal) =>
      this(endDateLocal: endDateLocal);

  @override
  PaceCurve days(int? days) => this(days: days);

  @override
  PaceCurve movingTime(int? movingTime) => this(movingTime: movingTime);

  @override
  PaceCurve trainingLoad(int? trainingLoad) => this(trainingLoad: trainingLoad);

  @override
  PaceCurve weight(double? weight) => this(weight: weight);

  @override
  PaceCurve distance(List<double>? distance) => this(distance: distance);

  @override
  PaceCurve values(List<int>? values) => this(values: values);

  @override
  PaceCurve submaxValues(List<List<int>>? submaxValues) =>
      this(submaxValues: submaxValues);

  @override
  PaceCurve submaxActivityId(List<List<String>>? submaxActivityId) =>
      this(submaxActivityId: submaxActivityId);

  @override
  PaceCurve startIndex(List<int>? startIndex) => this(startIndex: startIndex);

  @override
  PaceCurve endIndex(List<int>? endIndex) => this(endIndex: endIndex);

  @override
  PaceCurve activityId(List<String>? activityId) =>
      this(activityId: activityId);

  @override
  PaceCurve type(PaceCurveTypeEnum? type) => this(type: type);

  @override
  PaceCurve paceModels(List<PaceModel>? paceModels) =>
      this(paceModels: paceModels);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceCurve call({
    Object? id = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? filterLabel = const $CopyWithPlaceholder(),
    Object? percentile = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? endDateLocal = const $CopyWithPlaceholder(),
    Object? days = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? trainingLoad = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? values = const $CopyWithPlaceholder(),
    Object? submaxValues = const $CopyWithPlaceholder(),
    Object? submaxActivityId = const $CopyWithPlaceholder(),
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? activityId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? paceModels = const $CopyWithPlaceholder(),
  }) {
    return PaceCurve(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as List<ActivityFilter>?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String?,
      filterLabel: filterLabel == const $CopyWithPlaceholder()
          ? _value.filterLabel
          // ignore: cast_nullable_to_non_nullable
          : filterLabel as String?,
      percentile: percentile == const $CopyWithPlaceholder()
          ? _value.percentile
          // ignore: cast_nullable_to_non_nullable
          : percentile as double?,
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      endDateLocal: endDateLocal == const $CopyWithPlaceholder()
          ? _value.endDateLocal
          // ignore: cast_nullable_to_non_nullable
          : endDateLocal as String?,
      days: days == const $CopyWithPlaceholder()
          ? _value.days
          // ignore: cast_nullable_to_non_nullable
          : days as int?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as int?,
      trainingLoad: trainingLoad == const $CopyWithPlaceholder()
          ? _value.trainingLoad
          // ignore: cast_nullable_to_non_nullable
          : trainingLoad as int?,
      weight: weight == const $CopyWithPlaceholder()
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as List<double>?,
      values: values == const $CopyWithPlaceholder()
          ? _value.values
          // ignore: cast_nullable_to_non_nullable
          : values as List<int>?,
      submaxValues: submaxValues == const $CopyWithPlaceholder()
          ? _value.submaxValues
          // ignore: cast_nullable_to_non_nullable
          : submaxValues as List<List<int>>?,
      submaxActivityId: submaxActivityId == const $CopyWithPlaceholder()
          ? _value.submaxActivityId
          // ignore: cast_nullable_to_non_nullable
          : submaxActivityId as List<List<String>>?,
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as List<int>?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as List<int>?,
      activityId: activityId == const $CopyWithPlaceholder()
          ? _value.activityId
          // ignore: cast_nullable_to_non_nullable
          : activityId as List<String>?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PaceCurveTypeEnum?,
      paceModels: paceModels == const $CopyWithPlaceholder()
          ? _value.paceModels
          // ignore: cast_nullable_to_non_nullable
          : paceModels as List<PaceModel>?,
    );
  }
}

extension $PaceCurveCopyWith on PaceCurve {
  /// Returns a callable class that can be used as follows: `instanceOfPaceCurve.copyWith(...)` or like so:`instanceOfPaceCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaceCurveCWProxy get copyWith => _$PaceCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaceCurve _$PaceCurveFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PaceCurve',
  json,
  ($checkedConvert) {
    final val = PaceCurve(
      id: $checkedConvert('id', (v) => v as String?),
      filters: $checkedConvert(
        'filters',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ActivityFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      label: $checkedConvert('label', (v) => v as String?),
      filterLabel: $checkedConvert('filter_label', (v) => v as String?),
      percentile: $checkedConvert('percentile', (v) => (v as num?)?.toDouble()),
      startDateLocal: $checkedConvert('start_date_local', (v) => v as String?),
      endDateLocal: $checkedConvert('end_date_local', (v) => v as String?),
      days: $checkedConvert('days', (v) => (v as num?)?.toInt()),
      movingTime: $checkedConvert('moving_time', (v) => (v as num?)?.toInt()),
      trainingLoad: $checkedConvert(
        'training_load',
        (v) => (v as num?)?.toInt(),
      ),
      weight: $checkedConvert('weight', (v) => (v as num?)?.toDouble()),
      distance: $checkedConvert(
        'distance',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      values: $checkedConvert(
        'values',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      submaxValues: $checkedConvert(
        'submax_values',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) =>
                  (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
            )
            .toList(),
      ),
      submaxActivityId: $checkedConvert(
        'submax_activity_id',
        (v) => (v as List<dynamic>?)
            ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
            .toList(),
      ),
      startIndex: $checkedConvert(
        'start_index',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      endIndex: $checkedConvert(
        'end_index',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      activityId: $checkedConvert(
        'activity_id',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$PaceCurveTypeEnumEnumMap, v),
      ),
      paceModels: $checkedConvert(
        'paceModels',
        (v) => (v as List<dynamic>?)
            ?.map((e) => PaceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'filterLabel': 'filter_label',
    'startDateLocal': 'start_date_local',
    'endDateLocal': 'end_date_local',
    'movingTime': 'moving_time',
    'trainingLoad': 'training_load',
    'submaxValues': 'submax_values',
    'submaxActivityId': 'submax_activity_id',
    'startIndex': 'start_index',
    'endIndex': 'end_index',
    'activityId': 'activity_id',
  },
);

Map<String, dynamic> _$PaceCurveToJson(PaceCurve instance) => <String, dynamic>{
  'id': ?instance.id,
  'filters': ?instance.filters?.map((e) => e.toJson()).toList(),
  'label': ?instance.label,
  'filter_label': ?instance.filterLabel,
  'percentile': ?instance.percentile,
  'start_date_local': ?instance.startDateLocal,
  'end_date_local': ?instance.endDateLocal,
  'days': ?instance.days,
  'moving_time': ?instance.movingTime,
  'training_load': ?instance.trainingLoad,
  'weight': ?instance.weight,
  'distance': ?instance.distance,
  'values': ?instance.values,
  'submax_values': ?instance.submaxValues,
  'submax_activity_id': ?instance.submaxActivityId,
  'start_index': ?instance.startIndex,
  'end_index': ?instance.endIndex,
  'activity_id': ?instance.activityId,
  'type': ?_$PaceCurveTypeEnumEnumMap[instance.type],
  'paceModels': ?instance.paceModels?.map((e) => e.toJson()).toList(),
};

const _$PaceCurveTypeEnumEnumMap = {
  PaceCurveTypeEnum.POWER: 'POWER',
  PaceCurveTypeEnum.HR: 'HR',
  PaceCurveTypeEnum.PACE: 'PACE',
  PaceCurveTypeEnum.GAP: 'GAP',
};
