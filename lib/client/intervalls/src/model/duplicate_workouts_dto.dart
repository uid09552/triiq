//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'duplicate_workouts_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DuplicateWorkoutsDTO {
  /// Returns a new [DuplicateWorkoutsDTO] instance.
  DuplicateWorkoutsDTO({this.numCopies, this.weeksBetween, this.workoutIds});

  @JsonKey(name: r'numCopies', required: false, includeIfNull: false)
  final int? numCopies;

  @JsonKey(name: r'weeksBetween', required: false, includeIfNull: false)
  final int? weeksBetween;

  @JsonKey(name: r'workoutIds', required: false, includeIfNull: false)
  final List<int>? workoutIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuplicateWorkoutsDTO &&
          other.numCopies == numCopies &&
          other.weeksBetween == weeksBetween &&
          other.workoutIds == workoutIds;

  @override
  int get hashCode =>
      numCopies.hashCode + weeksBetween.hashCode + workoutIds.hashCode;

  factory DuplicateWorkoutsDTO.fromJson(Map<String, dynamic> json) =>
      _$DuplicateWorkoutsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$DuplicateWorkoutsDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
