//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gear_reminder.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GearReminder {
  /// Returns a new [GearReminder] instance.
  GearReminder({

     this.id,

     this.gearId,

     this.name,

     this.distance,

     this.time,

     this.activities,

     this.days,

     this.lastReset,

     this.startingDistance,

     this.startingTime,

     this.startingActivities,

     this.snoozedUntil,

     this.percentUsed,

     this.distanceUsed,

     this.timeUsed,

     this.activitiesUsed,

     this.daysUsed,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'gear_id',
    required: false,
    includeIfNull: false,
  )


  final String? gearId;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;



  @JsonKey(
    
    name: r'time',
    required: false,
    includeIfNull: false,
  )


  final double? time;



  @JsonKey(
    
    name: r'activities',
    required: false,
    includeIfNull: false,
  )


  final int? activities;



  @JsonKey(
    
    name: r'days',
    required: false,
    includeIfNull: false,
  )


  final int? days;



  @JsonKey(
    
    name: r'last_reset',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastReset;



  @JsonKey(
    
    name: r'starting_distance',
    required: false,
    includeIfNull: false,
  )


  final double? startingDistance;



  @JsonKey(
    
    name: r'starting_time',
    required: false,
    includeIfNull: false,
  )


  final double? startingTime;



  @JsonKey(
    
    name: r'starting_activities',
    required: false,
    includeIfNull: false,
  )


  final int? startingActivities;



  @JsonKey(
    
    name: r'snoozed_until',
    required: false,
    includeIfNull: false,
  )


  final DateTime? snoozedUntil;



  @JsonKey(
    
    name: r'percent_used',
    required: false,
    includeIfNull: false,
  )


  final double? percentUsed;



  @JsonKey(
    
    name: r'distance_used',
    required: false,
    includeIfNull: false,
  )


  final double? distanceUsed;



  @JsonKey(
    
    name: r'time_used',
    required: false,
    includeIfNull: false,
  )


  final double? timeUsed;



  @JsonKey(
    
    name: r'activities_used',
    required: false,
    includeIfNull: false,
  )


  final int? activitiesUsed;



  @JsonKey(
    
    name: r'days_used',
    required: false,
    includeIfNull: false,
  )


  final int? daysUsed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GearReminder &&
      other.id == id &&
      other.gearId == gearId &&
      other.name == name &&
      other.distance == distance &&
      other.time == time &&
      other.activities == activities &&
      other.days == days &&
      other.lastReset == lastReset &&
      other.startingDistance == startingDistance &&
      other.startingTime == startingTime &&
      other.startingActivities == startingActivities &&
      other.snoozedUntil == snoozedUntil &&
      other.percentUsed == percentUsed &&
      other.distanceUsed == distanceUsed &&
      other.timeUsed == timeUsed &&
      other.activitiesUsed == activitiesUsed &&
      other.daysUsed == daysUsed;

    @override
    int get hashCode =>
        id.hashCode +
        gearId.hashCode +
        name.hashCode +
        distance.hashCode +
        time.hashCode +
        activities.hashCode +
        days.hashCode +
        lastReset.hashCode +
        startingDistance.hashCode +
        startingTime.hashCode +
        startingActivities.hashCode +
        snoozedUntil.hashCode +
        percentUsed.hashCode +
        distanceUsed.hashCode +
        timeUsed.hashCode +
        activitiesUsed.hashCode +
        daysUsed.hashCode;

  factory GearReminder.fromJson(Map<String, dynamic> json) => _$GearReminderFromJson(json);

  Map<String, dynamic> toJson() => _$GearReminderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

