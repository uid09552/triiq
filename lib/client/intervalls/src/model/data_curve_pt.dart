//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_curve_pt.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataCurvePt {
  /// Returns a new [DataCurvePt] instance.
  DataCurvePt({this.startIndex, this.endIndex, this.secs, this.value});

  @JsonKey(name: r'start_index', required: false, includeIfNull: false)
  final int? startIndex;

  @JsonKey(name: r'end_index', required: false, includeIfNull: false)
  final int? endIndex;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final int? secs;

  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final int? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCurvePt &&
          other.startIndex == startIndex &&
          other.endIndex == endIndex &&
          other.secs == secs &&
          other.value == value;

  @override
  int get hashCode =>
      startIndex.hashCode + endIndex.hashCode + secs.hashCode + value.hashCode;

  factory DataCurvePt.fromJson(Map<String, dynamic> json) =>
      _$DataCurvePtFromJson(json);

  Map<String, dynamic> toJson() => _$DataCurvePtToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
