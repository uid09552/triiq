//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_training_plan_update.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteTrainingPlanUpdate {
  /// Returns a new [AthleteTrainingPlanUpdate] instance.
  AthleteTrainingPlanUpdate({

     this.id,

     this.trainingPlanId,

     this.trainingPlanStartDate,

     this.trainingPlanAlias,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'training_plan_id',
    required: false,
    includeIfNull: false,
  )


  final int? trainingPlanId;



  @JsonKey(
    
    name: r'training_plan_start_date',
    required: false,
    includeIfNull: false,
  )


  final String? trainingPlanStartDate;



  @JsonKey(
    
    name: r'training_plan_alias',
    required: false,
    includeIfNull: false,
  )


  final String? trainingPlanAlias;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AthleteTrainingPlanUpdate &&
      other.id == id &&
      other.trainingPlanId == trainingPlanId &&
      other.trainingPlanStartDate == trainingPlanStartDate &&
      other.trainingPlanAlias == trainingPlanAlias;

    @override
    int get hashCode =>
        id.hashCode +
        trainingPlanId.hashCode +
        trainingPlanStartDate.hashCode +
        trainingPlanAlias.hashCode;

  factory AthleteTrainingPlanUpdate.fromJson(Map<String, dynamic> json) => _$AthleteTrainingPlanUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteTrainingPlanUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

