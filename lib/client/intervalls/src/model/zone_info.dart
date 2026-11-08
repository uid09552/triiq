//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zone_info.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ZoneInfo {
  /// Returns a new [ZoneInfo] instance.
  ZoneInfo({
    this.id,

    this.start,

    this.end,

    this.startValue,

    this.endValue,

    this.secs,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'start', required: false, includeIfNull: false)
  final double? start;

  @JsonKey(name: r'end', required: false, includeIfNull: false)
  final double? end;

  @JsonKey(name: r'start_value', required: false, includeIfNull: false)
  final double? startValue;

  @JsonKey(name: r'end_value', required: false, includeIfNull: false)
  final double? endValue;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final int? secs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneInfo &&
          other.id == id &&
          other.start == start &&
          other.end == end &&
          other.startValue == startValue &&
          other.endValue == endValue &&
          other.secs == secs;

  @override
  int get hashCode =>
      id.hashCode +
      start.hashCode +
      end.hashCode +
      startValue.hashCode +
      endValue.hashCode +
      secs.hashCode;

  factory ZoneInfo.fromJson(Map<String, dynamic> json) =>
      _$ZoneInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneInfoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
