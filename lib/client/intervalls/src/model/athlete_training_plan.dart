//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/folder.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_training_plan.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteTrainingPlan {
  /// Returns a new [AthleteTrainingPlan] instance.
  AthleteTrainingPlan({
    this.athleteId,

    this.trainingPlanId,

    this.trainingPlanStartDate,

    this.timezone,

    this.trainingPlanLastApplied,

    this.trainingPlan,

    this.trainingPlanAlias,
  });

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'training_plan_id', required: false, includeIfNull: false)
  final int? trainingPlanId;

  @JsonKey(
    name: r'training_plan_start_date',
    required: false,
    includeIfNull: false,
  )
  final String? trainingPlanStartDate;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(
    name: r'training_plan_last_applied',
    required: false,
    includeIfNull: false,
  )
  final DateTime? trainingPlanLastApplied;

  @JsonKey(name: r'training_plan', required: false, includeIfNull: false)
  final Folder? trainingPlan;

  @JsonKey(name: r'training_plan_alias', required: false, includeIfNull: false)
  final String? trainingPlanAlias;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AthleteTrainingPlan &&
          other.athleteId == athleteId &&
          other.trainingPlanId == trainingPlanId &&
          other.trainingPlanStartDate == trainingPlanStartDate &&
          other.timezone == timezone &&
          other.trainingPlanLastApplied == trainingPlanLastApplied &&
          other.trainingPlan == trainingPlan &&
          other.trainingPlanAlias == trainingPlanAlias;

  @override
  int get hashCode =>
      athleteId.hashCode +
      trainingPlanId.hashCode +
      trainingPlanStartDate.hashCode +
      timezone.hashCode +
      trainingPlanLastApplied.hashCode +
      trainingPlan.hashCode +
      trainingPlanAlias.hashCode;

  factory AthleteTrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$AthleteTrainingPlanFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteTrainingPlanToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
