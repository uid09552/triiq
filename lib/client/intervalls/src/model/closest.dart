//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'closest.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Closest {
  /// Returns a new [Closest] instance.
  Closest({this.startSecs, this.p1Index, this.p2Index, this.p3Index});

  @JsonKey(name: r'start_secs', required: false, includeIfNull: false)
  final int? startSecs;

  @JsonKey(name: r'p1_index', required: false, includeIfNull: false)
  final int? p1Index;

  @JsonKey(name: r'p2_index', required: false, includeIfNull: false)
  final int? p2Index;

  @JsonKey(name: r'p3_index', required: false, includeIfNull: false)
  final int? p3Index;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Closest &&
          other.startSecs == startSecs &&
          other.p1Index == p1Index &&
          other.p2Index == p2Index &&
          other.p3Index == p3Index;

  @override
  int get hashCode =>
      startSecs.hashCode +
      p1Index.hashCode +
      p2Index.hashCode +
      p3Index.hashCode;

  factory Closest.fromJson(Map<String, dynamic> json) =>
      _$ClosestFromJson(json);

  Map<String, dynamic> toJson() => _$ClosestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
