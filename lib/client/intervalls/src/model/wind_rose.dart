//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wind_rose.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WindRose {
  /// Returns a new [WindRose] instance.
  WindRose({this.avgSpeed, this.count});

  @JsonKey(name: r'avg_speed', required: false, includeIfNull: false)
  final List<double>? avgSpeed;

  @JsonKey(name: r'count', required: false, includeIfNull: false)
  final List<int>? count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindRose && other.avgSpeed == avgSpeed && other.count == count;

  @override
  int get hashCode => avgSpeed.hashCode + count.hashCode;

  factory WindRose.fromJson(Map<String, dynamic> json) =>
      _$WindRoseFromJson(json);

  Map<String, dynamic> toJson() => _$WindRoseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
