//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_filter.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityFilter {
  /// Returns a new [ActivityFilter] instance.
  ActivityFilter({
    this.id,

    this.fieldId,

    this.code,

    this.operator_,

    this.value,

    this.not,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'field_id', required: false, includeIfNull: false)
  final ActivityFilterFieldIdEnum? fieldId;

  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @JsonKey(name: r'operator', required: false, includeIfNull: false)
  final String? operator_;

  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final Object? value;

  @JsonKey(name: r'not', required: false, includeIfNull: false)
  final bool? not;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityFilter &&
          other.id == id &&
          other.fieldId == fieldId &&
          other.code == code &&
          other.operator_ == operator_ &&
          other.value == value &&
          other.not == not;

  @override
  int get hashCode =>
      id.hashCode +
      fieldId.hashCode +
      code.hashCode +
      operator_.hashCode +
      value.hashCode +
      not.hashCode;

  factory ActivityFilter.fromJson(Map<String, dynamic> json) =>
      _$ActivityFilterFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityFilterToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ActivityFilterFieldIdEnum {
  @JsonValue(r'type')
  type(r'type'),
  @JsonValue(r'indoor')
  indoor(r'indoor'),
  @JsonValue(r'name')
  name(r'name'),
  @JsonValue(r'notName')
  notName(r'notName'),
  @JsonValue(r'description')
  description(r'description'),
  @JsonValue(r'moving_time')
  movingTime(r'moving_time'),
  @JsonValue(r'elapsed_time')
  elapsedTime(r'elapsed_time'),
  @JsonValue(r'coasting_time')
  coastingTime(r'coasting_time'),
  @JsonValue(r'distance')
  distance(r'distance'),
  @JsonValue(r'climbing')
  climbing(r'climbing'),
  @JsonValue(r'load')
  load(r'load'),
  @JsonValue(r'source')
  source_(r'source'),
  @JsonValue(r'race')
  race(r'race'),
  @JsonValue(r'average_heartrate')
  averageHeartrate(r'average_heartrate'),
  @JsonValue(r'max_heartrate')
  maxHeartrate(r'max_heartrate'),
  @JsonValue(r'hrrc')
  hrrc(r'hrrc'),
  @JsonValue(r'average_power')
  averagePower(r'average_power'),
  @JsonValue(r'norm_power')
  normPower(r'norm_power'),
  @JsonValue(r'pace')
  pace(r'pace'),
  @JsonValue(r'gap')
  gap(r'gap'),
  @JsonValue(r'average_speed')
  averageSpeed(r'average_speed'),
  @JsonValue(r'max_speed')
  maxSpeed(r'max_speed'),
  @JsonValue(r'variability_index')
  variabilityIndex(r'variability_index'),
  @JsonValue(r'intensity')
  intensity(r'intensity'),
  @JsonValue(r'average_cadence')
  averageCadence(r'average_cadence'),
  @JsonValue(r'average_cadence_z2')
  averageCadenceZ2(r'average_cadence_z2'),
  @JsonValue(r'average_temp')
  averageTemp(r'average_temp'),
  @JsonValue(r'calories')
  calories(r'calories'),
  @JsonValue(r'work')
  work(r'work'),
  @JsonValue(r'work_above_ftp')
  workAboveFtp(r'work_above_ftp'),
  @JsonValue(r'max_wbal_depletion')
  maxWbalDepletion(r'max_wbal_depletion'),
  @JsonValue(r'efficiency')
  efficiency(r'efficiency'),
  @JsonValue(r'power_hr')
  powerHr(r'power_hr'),
  @JsonValue(r'power_hr_z2')
  powerHrZ2(r'power_hr_z2'),
  @JsonValue(r'power_hr_z2_mins')
  powerHrZ2Mins(r'power_hr_z2_mins'),
  @JsonValue(r'rpe')
  rpe(r'rpe'),
  @JsonValue(r'feel')
  feel(r'feel'),
  @JsonValue(r'session_rpe')
  sessionRpe(r'session_rpe'),
  @JsonValue(r'kg_lifted')
  kgLifted(r'kg_lifted'),
  @JsonValue(r'power_meter')
  powerMeter(r'power_meter'),
  @JsonValue(r'power_meter_serial')
  powerMeterSerial(r'power_meter_serial'),
  @JsonValue(r'gear_name')
  gearName(r'gear_name'),
  @JsonValue(r'trimp')
  trimp(r'trimp'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'tags')
  tags(r'tags'),
  @JsonValue(r'device_name')
  deviceName(r'device_name'),
  @JsonValue(r'compliance')
  compliance(r'compliance'),
  @JsonValue(r'polarization_index')
  polarizationIndex(r'polarization_index'),
  @JsonValue(r'day_of_week')
  dayOfWeek(r'day_of_week'),
  @JsonValue(r'average_altitude')
  averageAltitude(r'average_altitude'),
  @JsonValue(r'min_altitude')
  minAltitude(r'min_altitude'),
  @JsonValue(r'max_altitude')
  maxAltitude(r'max_altitude'),
  @JsonValue(r'start_time')
  startTime(r'start_time'),
  @JsonValue(r'route_id')
  routeId(r'route_id');

  const ActivityFilterFieldIdEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
