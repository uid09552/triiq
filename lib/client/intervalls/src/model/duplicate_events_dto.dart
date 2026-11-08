//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'duplicate_events_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DuplicateEventsDTO {
  /// Returns a new [DuplicateEventsDTO] instance.
  DuplicateEventsDTO({this.numCopies, this.weeksBetween, this.eventIds});

  @JsonKey(name: r'numCopies', required: false, includeIfNull: false)
  final int? numCopies;

  @JsonKey(name: r'weeksBetween', required: false, includeIfNull: false)
  final int? weeksBetween;

  @JsonKey(name: r'eventIds', required: false, includeIfNull: false)
  final List<int>? eventIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateEventsDTO &&
          other.numCopies == numCopies &&
          other.weeksBetween == weeksBetween &&
          other.eventIds == eventIds;

  @override
  int get hashCode =>
      numCopies.hashCode + weeksBetween.hashCode + eventIds.hashCode;

  factory DuplicateEventsDTO.fromJson(Map<String, dynamic> json) =>
      _$DuplicateEventsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$DuplicateEventsDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
