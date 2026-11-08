//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_power_curve.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_power_curve_payload.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityPowerCurvePayload {
  /// Returns a new [ActivityPowerCurvePayload] instance.
  ActivityPowerCurvePayload({this.afterKj, this.secs, this.curves});

  @JsonKey(name: r'after_kj', required: false, includeIfNull: false)
  final int? afterKj;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final List<int>? secs;

  @JsonKey(name: r'curves', required: false, includeIfNull: false)
  final List<ActivityPowerCurve>? curves;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityPowerCurvePayload &&
          other.afterKj == afterKj &&
          other.secs == secs &&
          other.curves == curves;

  @override
  int get hashCode => afterKj.hashCode + secs.hashCode + curves.hashCode;

  factory ActivityPowerCurvePayload.fromJson(Map<String, dynamic> json) =>
      _$ActivityPowerCurvePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityPowerCurvePayloadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
