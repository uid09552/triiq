//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gear_stats.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GearStats {
  /// Returns a new [GearStats] instance.
  GearStats({

     this.distance,

     this.elapsedTime,

     this.movingTime,

     this.activities,
  });

  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;



  @JsonKey(
    
    name: r'elapsed_time',
    required: false,
    includeIfNull: false,
  )


  final double? elapsedTime;



  @JsonKey(
    
    name: r'moving_time',
    required: false,
    includeIfNull: false,
  )


  final double? movingTime;



  @JsonKey(
    
    name: r'activities',
    required: false,
    includeIfNull: false,
  )


  final int? activities;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GearStats &&
      other.distance == distance &&
      other.elapsedTime == elapsedTime &&
      other.movingTime == movingTime &&
      other.activities == activities;

    @override
    int get hashCode =>
        distance.hashCode +
        elapsedTime.hashCode +
        movingTime.hashCode +
        activities.hashCode;

  factory GearStats.fromJson(Map<String, dynamic> json) => _$GearStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GearStatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

