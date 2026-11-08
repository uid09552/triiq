// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_filter.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityFilterCWProxy {
  ActivityFilter id(int? id);

  ActivityFilter fieldId(ActivityFilterFieldIdEnum? fieldId);

  ActivityFilter code(String? code);

  ActivityFilter operator_(String? operator_);

  ActivityFilter value(Object? value);

  ActivityFilter not(bool? not);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityFilter call({
    int? id,
    ActivityFilterFieldIdEnum? fieldId,
    String? code,
    String? operator_,
    Object? value,
    bool? not,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityFilter.copyWith.fieldName(...)`
class _$ActivityFilterCWProxyImpl implements _$ActivityFilterCWProxy {
  const _$ActivityFilterCWProxyImpl(this._value);

  final ActivityFilter _value;

  @override
  ActivityFilter id(int? id) => this(id: id);

  @override
  ActivityFilter fieldId(ActivityFilterFieldIdEnum? fieldId) =>
      this(fieldId: fieldId);

  @override
  ActivityFilter code(String? code) => this(code: code);

  @override
  ActivityFilter operator_(String? operator_) => this(operator_: operator_);

  @override
  ActivityFilter value(Object? value) => this(value: value);

  @override
  ActivityFilter not(bool? not) => this(not: not);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityFilter call({
    Object? id = const $CopyWithPlaceholder(),
    Object? fieldId = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? operator_ = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? not = const $CopyWithPlaceholder(),
  }) {
    return ActivityFilter(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      fieldId: fieldId == const $CopyWithPlaceholder()
          ? _value.fieldId
          // ignore: cast_nullable_to_non_nullable
          : fieldId as ActivityFilterFieldIdEnum?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      operator_: operator_ == const $CopyWithPlaceholder()
          ? _value.operator_
          // ignore: cast_nullable_to_non_nullable
          : operator_ as String?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as Object?,
      not: not == const $CopyWithPlaceholder()
          ? _value.not
          // ignore: cast_nullable_to_non_nullable
          : not as bool?,
    );
  }
}

extension $ActivityFilterCopyWith on ActivityFilter {
  /// Returns a callable class that can be used as follows: `instanceOfActivityFilter.copyWith(...)` or like so:`instanceOfActivityFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityFilterCWProxy get copyWith => _$ActivityFilterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityFilter _$ActivityFilterFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityFilter', json, ($checkedConvert) {
      final val = ActivityFilter(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        fieldId: $checkedConvert(
          'field_id',
          (v) => $enumDecodeNullable(_$ActivityFilterFieldIdEnumEnumMap, v),
        ),
        code: $checkedConvert('code', (v) => v as String?),
        operator_: $checkedConvert('operator', (v) => v as String?),
        value: $checkedConvert('value', (v) => v),
        not: $checkedConvert('not', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'fieldId': 'field_id', 'operator_': 'operator'});

Map<String, dynamic> _$ActivityFilterToJson(ActivityFilter instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'field_id': ?_$ActivityFilterFieldIdEnumEnumMap[instance.fieldId],
      'code': ?instance.code,
      'operator': ?instance.operator_,
      'value': ?instance.value,
      'not': ?instance.not,
    };

const _$ActivityFilterFieldIdEnumEnumMap = {
  ActivityFilterFieldIdEnum.type: 'type',
  ActivityFilterFieldIdEnum.indoor: 'indoor',
  ActivityFilterFieldIdEnum.name: 'name',
  ActivityFilterFieldIdEnum.notName: 'notName',
  ActivityFilterFieldIdEnum.description: 'description',
  ActivityFilterFieldIdEnum.movingTime: 'moving_time',
  ActivityFilterFieldIdEnum.elapsedTime: 'elapsed_time',
  ActivityFilterFieldIdEnum.coastingTime: 'coasting_time',
  ActivityFilterFieldIdEnum.distance: 'distance',
  ActivityFilterFieldIdEnum.climbing: 'climbing',
  ActivityFilterFieldIdEnum.load: 'load',
  ActivityFilterFieldIdEnum.source_: 'source',
  ActivityFilterFieldIdEnum.race: 'race',
  ActivityFilterFieldIdEnum.averageHeartrate: 'average_heartrate',
  ActivityFilterFieldIdEnum.maxHeartrate: 'max_heartrate',
  ActivityFilterFieldIdEnum.hrrc: 'hrrc',
  ActivityFilterFieldIdEnum.averagePower: 'average_power',
  ActivityFilterFieldIdEnum.normPower: 'norm_power',
  ActivityFilterFieldIdEnum.pace: 'pace',
  ActivityFilterFieldIdEnum.gap: 'gap',
  ActivityFilterFieldIdEnum.averageSpeed: 'average_speed',
  ActivityFilterFieldIdEnum.maxSpeed: 'max_speed',
  ActivityFilterFieldIdEnum.variabilityIndex: 'variability_index',
  ActivityFilterFieldIdEnum.intensity: 'intensity',
  ActivityFilterFieldIdEnum.averageCadence: 'average_cadence',
  ActivityFilterFieldIdEnum.averageCadenceZ2: 'average_cadence_z2',
  ActivityFilterFieldIdEnum.averageTemp: 'average_temp',
  ActivityFilterFieldIdEnum.calories: 'calories',
  ActivityFilterFieldIdEnum.work: 'work',
  ActivityFilterFieldIdEnum.workAboveFtp: 'work_above_ftp',
  ActivityFilterFieldIdEnum.maxWbalDepletion: 'max_wbal_depletion',
  ActivityFilterFieldIdEnum.efficiency: 'efficiency',
  ActivityFilterFieldIdEnum.powerHr: 'power_hr',
  ActivityFilterFieldIdEnum.powerHrZ2: 'power_hr_z2',
  ActivityFilterFieldIdEnum.powerHrZ2Mins: 'power_hr_z2_mins',
  ActivityFilterFieldIdEnum.rpe: 'rpe',
  ActivityFilterFieldIdEnum.feel: 'feel',
  ActivityFilterFieldIdEnum.sessionRpe: 'session_rpe',
  ActivityFilterFieldIdEnum.kgLifted: 'kg_lifted',
  ActivityFilterFieldIdEnum.powerMeter: 'power_meter',
  ActivityFilterFieldIdEnum.powerMeterSerial: 'power_meter_serial',
  ActivityFilterFieldIdEnum.gearName: 'gear_name',
  ActivityFilterFieldIdEnum.trimp: 'trimp',
  ActivityFilterFieldIdEnum.custom: 'custom',
  ActivityFilterFieldIdEnum.tags: 'tags',
  ActivityFilterFieldIdEnum.deviceName: 'device_name',
  ActivityFilterFieldIdEnum.compliance: 'compliance',
  ActivityFilterFieldIdEnum.polarizationIndex: 'polarization_index',
  ActivityFilterFieldIdEnum.dayOfWeek: 'day_of_week',
  ActivityFilterFieldIdEnum.averageAltitude: 'average_altitude',
  ActivityFilterFieldIdEnum.minAltitude: 'min_altitude',
  ActivityFilterFieldIdEnum.maxAltitude: 'max_altitude',
  ActivityFilterFieldIdEnum.startTime: 'start_time',
  ActivityFilterFieldIdEnum.routeId: 'route_id',
};
