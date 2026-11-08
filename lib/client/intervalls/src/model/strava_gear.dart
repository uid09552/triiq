//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'strava_gear.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StravaGear {
  /// Returns a new [StravaGear] instance.
  StravaGear({this.id, this.name, this.distance, this.primary});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'primary', required: false, includeIfNull: false)
  final bool? primary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StravaGear &&
          other.id == id &&
          other.name == name &&
          other.distance == distance &&
          other.primary == primary;

  @override
  int get hashCode =>
      id.hashCode + name.hashCode + distance.hashCode + primary.hashCode;

  factory StravaGear.fromJson(Map<String, dynamic> json) =>
      _$StravaGearFromJson(json);

  Map<String, dynamic> toJson() => _$StravaGearToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
