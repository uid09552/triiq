//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/attachment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'workout.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Workout {
  /// Returns a new [Workout] instance.
  Workout({

     this.athleteId,

     this.id,

     this.icuTrainingLoad,

     this.name,

     this.description,

     this.type,

     this.indoor,

     this.color,

     this.movingTime,

     this.updated,

     this.joules,

     this.joulesAboveFtp,

     this.workoutDoc,

     this.folderId,

     this.day,

     this.days,

     this.planApplied,

     this.hideFromAthlete,

     this.target,

     this.targets,

     this.carbsPerHour,

     this.tags,

     this.attachments,

     this.time,

     this.subType,

     this.forWeek,

     this.distance,

     this.icuIntensity,
  });

  @JsonKey(
    
    name: r'athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? athleteId;



  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'icu_training_load',
    required: false,
    includeIfNull: false,
  )


  final int? icuTrainingLoad;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final String? type;



  @JsonKey(
    
    name: r'indoor',
    required: false,
    includeIfNull: false,
  )


  final bool? indoor;



  @JsonKey(
    
    name: r'color',
    required: false,
    includeIfNull: false,
  )


  final String? color;



  @JsonKey(
    
    name: r'moving_time',
    required: false,
    includeIfNull: false,
  )


  final int? movingTime;



  @JsonKey(
    
    name: r'updated',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updated;



  @JsonKey(
    
    name: r'joules',
    required: false,
    includeIfNull: false,
  )


  final int? joules;



  @JsonKey(
    
    name: r'joules_above_ftp',
    required: false,
    includeIfNull: false,
  )


  final int? joulesAboveFtp;



  @JsonKey(
    
    name: r'workout_doc',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? workoutDoc;



  @JsonKey(
    
    name: r'folder_id',
    required: false,
    includeIfNull: false,
  )


  final int? folderId;



  @JsonKey(
    
    name: r'day',
    required: false,
    includeIfNull: false,
  )


  final int? day;



  @JsonKey(
    
    name: r'days',
    required: false,
    includeIfNull: false,
  )


  final int? days;



  @JsonKey(
    
    name: r'plan_applied',
    required: false,
    includeIfNull: false,
  )


  final DateTime? planApplied;



  @JsonKey(
    
    name: r'hide_from_athlete',
    required: false,
    includeIfNull: false,
  )


  final bool? hideFromAthlete;



  @JsonKey(
    
    name: r'target',
    required: false,
    includeIfNull: false,
  )


  final WorkoutTargetEnum? target;



  @JsonKey(
    
    name: r'targets',
    required: false,
    includeIfNull: false,
  )


  final List<WorkoutTargetsEnum>? targets;



  @JsonKey(
    
    name: r'carbs_per_hour',
    required: false,
    includeIfNull: false,
  )


  final int? carbsPerHour;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(
    
    name: r'attachments',
    required: false,
    includeIfNull: false,
  )


  final List<Attachment>? attachments;



  @JsonKey(
    
    name: r'time',
    required: false,
    includeIfNull: false,
  )


  final String? time;



  @JsonKey(
    
    name: r'sub_type',
    required: false,
    includeIfNull: false,
  )


  final WorkoutSubTypeEnum? subType;



  @JsonKey(
    
    name: r'for_week',
    required: false,
    includeIfNull: false,
  )


  final bool? forWeek;



  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;



  @JsonKey(
    
    name: r'icu_intensity',
    required: false,
    includeIfNull: false,
  )


  final double? icuIntensity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Workout &&
      other.athleteId == athleteId &&
      other.id == id &&
      other.icuTrainingLoad == icuTrainingLoad &&
      other.name == name &&
      other.description == description &&
      other.type == type &&
      other.indoor == indoor &&
      other.color == color &&
      other.movingTime == movingTime &&
      other.updated == updated &&
      other.joules == joules &&
      other.joulesAboveFtp == joulesAboveFtp &&
      other.workoutDoc == workoutDoc &&
      other.folderId == folderId &&
      other.day == day &&
      other.days == days &&
      other.planApplied == planApplied &&
      other.hideFromAthlete == hideFromAthlete &&
      other.target == target &&
      other.targets == targets &&
      other.carbsPerHour == carbsPerHour &&
      other.tags == tags &&
      other.attachments == attachments &&
      other.time == time &&
      other.subType == subType &&
      other.forWeek == forWeek &&
      other.distance == distance &&
      other.icuIntensity == icuIntensity;

    @override
    int get hashCode =>
        athleteId.hashCode +
        id.hashCode +
        icuTrainingLoad.hashCode +
        name.hashCode +
        description.hashCode +
        type.hashCode +
        indoor.hashCode +
        color.hashCode +
        movingTime.hashCode +
        updated.hashCode +
        joules.hashCode +
        joulesAboveFtp.hashCode +
        workoutDoc.hashCode +
        folderId.hashCode +
        day.hashCode +
        days.hashCode +
        planApplied.hashCode +
        hideFromAthlete.hashCode +
        target.hashCode +
        targets.hashCode +
        carbsPerHour.hashCode +
        tags.hashCode +
        attachments.hashCode +
        time.hashCode +
        subType.hashCode +
        forWeek.hashCode +
        distance.hashCode +
        icuIntensity.hashCode;

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum WorkoutTargetEnum {
@JsonValue(r'AUTO')
AUTO(r'AUTO'),
@JsonValue(r'POWER')
POWER(r'POWER'),
@JsonValue(r'HR')
HR(r'HR'),
@JsonValue(r'PACE')
PACE(r'PACE');

const WorkoutTargetEnum(this.value);

final String value;

@override
String toString() => value;
}


enum WorkoutTargetsEnum {
@JsonValue(r'AUTO')
AUTO(r'AUTO'),
@JsonValue(r'POWER')
POWER(r'POWER'),
@JsonValue(r'HR')
HR(r'HR'),
@JsonValue(r'PACE')
PACE(r'PACE');

const WorkoutTargetsEnum(this.value);

final String value;

@override
String toString() => value;
}


enum WorkoutSubTypeEnum {
@JsonValue(r'NONE')
NONE(r'NONE'),
@JsonValue(r'COMMUTE')
COMMUTE(r'COMMUTE'),
@JsonValue(r'WARMUP')
WARMUP(r'WARMUP'),
@JsonValue(r'COOLDOWN')
COOLDOWN(r'COOLDOWN'),
@JsonValue(r'RACE')
RACE(r'RACE');

const WorkoutSubTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


