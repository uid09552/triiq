//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/interval_group.dart';
import 'package:triiq/client/intervalls/src/model/interval.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'intervals_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IntervalsDTO {
  /// Returns a new [IntervalsDTO] instance.
  IntervalsDTO({this.id, this.analyzed, this.icuIntervals, this.icuGroups});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'analyzed', required: false, includeIfNull: false)
  final DateTime? analyzed;

  @JsonKey(name: r'icu_intervals', required: false, includeIfNull: false)
  final List<Interval>? icuIntervals;

  @JsonKey(name: r'icu_groups', required: false, includeIfNull: false)
  final List<IntervalGroup>? icuGroups;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalsDTO &&
          other.id == id &&
          other.analyzed == analyzed &&
          other.icuIntervals == icuIntervals &&
          other.icuGroups == icuGroups;

  @override
  int get hashCode =>
      id.hashCode +
      analyzed.hashCode +
      icuIntervals.hashCode +
      icuGroups.hashCode;

  factory IntervalsDTO.fromJson(Map<String, dynamic> json) =>
      _$IntervalsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$IntervalsDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
