//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zone_time.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ZoneTime {
  /// Returns a new [ZoneTime] instance.
  ZoneTime({this.id, this.secs});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final int? secs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneTime && other.id == id && other.secs == secs;

  @override
  int get hashCode => id.hashCode + secs.hashCode;

  factory ZoneTime.fromJson(Map<String, dynamic> json) =>
      _$ZoneTimeFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneTimeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
