//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anomaly.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Anomaly {
  /// Returns a new [Anomaly] instance.
  Anomaly({this.startIndex, this.endIndex, this.value, this.valueEnd});

  @JsonKey(name: r'start_index', required: false, includeIfNull: false)
  final int? startIndex;

  @JsonKey(name: r'end_index', required: false, includeIfNull: false)
  final int? endIndex;

  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final int? value;

  @JsonKey(name: r'valueEnd', required: false, includeIfNull: false)
  final int? valueEnd;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Anomaly &&
          other.startIndex == startIndex &&
          other.endIndex == endIndex &&
          other.value == value &&
          other.valueEnd == valueEnd;

  @override
  int get hashCode =>
      startIndex.hashCode +
      endIndex.hashCode +
      value.hashCode +
      valueEnd.hashCode;

  factory Anomaly.fromJson(Map<String, dynamic> json) =>
      _$AnomalyFromJson(json);

  Map<String, dynamic> toJson() => _$AnomalyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
