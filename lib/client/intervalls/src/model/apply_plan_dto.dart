//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/workout.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apply_plan_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApplyPlanDTO {
  /// Returns a new [ApplyPlanDTO] instance.
  ApplyPlanDTO({

     this.startDateLocal,

     this.folderId,

     this.extraWorkouts,
  });

  @JsonKey(
    
    name: r'start_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? startDateLocal;



  @JsonKey(
    
    name: r'folder_id',
    required: false,
    includeIfNull: false,
  )


  final int? folderId;



  @JsonKey(
    
    name: r'extra_workouts',
    required: false,
    includeIfNull: false,
  )


  final List<Workout>? extraWorkouts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApplyPlanDTO &&
      other.startDateLocal == startDateLocal &&
      other.folderId == folderId &&
      other.extraWorkouts == extraWorkouts;

    @override
    int get hashCode =>
        startDateLocal.hashCode +
        folderId.hashCode +
        extraWorkouts.hashCode;

  factory ApplyPlanDTO.fromJson(Map<String, dynamic> json) => _$ApplyPlanDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyPlanDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

