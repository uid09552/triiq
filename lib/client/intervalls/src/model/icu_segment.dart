//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icu_segment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IcuSegment {
  /// Returns a new [IcuSegment] instance.
  IcuSegment({
    this.id,

    this.startIndex,

    this.endIndex,

    this.name,

    this.segmentId,

    this.starred,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'start_index', required: false, includeIfNull: false)
  final int? startIndex;

  @JsonKey(name: r'end_index', required: false, includeIfNull: false)
  final int? endIndex;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'segment_id', required: false, includeIfNull: false)
  final int? segmentId;

  @JsonKey(name: r'starred', required: false, includeIfNull: false)
  final bool? starred;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IcuSegment &&
          other.id == id &&
          other.startIndex == startIndex &&
          other.endIndex == endIndex &&
          other.name == name &&
          other.segmentId == segmentId &&
          other.starred == starred;

  @override
  int get hashCode =>
      id.hashCode +
      startIndex.hashCode +
      endIndex.hashCode +
      name.hashCode +
      segmentId.hashCode +
      starred.hashCode;

  factory IcuSegment.fromJson(Map<String, dynamic> json) =>
      _$IcuSegmentFromJson(json);

  Map<String, dynamic> toJson() => _$IcuSegmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
