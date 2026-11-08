//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity.dart';
import 'package:triiq/client/intervalls/src/model/data_curve.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_curve_set_power_curve.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataCurveSetPowerCurve {
  /// Returns a new [DataCurveSetPowerCurve] instance.
  DataCurveSetPowerCurve({this.list, this.activities});

  @JsonKey(name: r'list', required: false, includeIfNull: false)
  final List<DataCurve>? list;

  @JsonKey(name: r'activities', required: false, includeIfNull: false)
  final Map<String, Activity>? activities;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCurveSetPowerCurve &&
          other.list == list &&
          other.activities == activities;

  @override
  int get hashCode => list.hashCode + activities.hashCode;

  factory DataCurveSetPowerCurve.fromJson(Map<String, dynamic> json) =>
      _$DataCurveSetPowerCurveFromJson(json);

  Map<String, dynamic> toJson() => _$DataCurveSetPowerCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
