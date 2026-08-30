//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hr_recovery.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HRRecovery {
  /// Returns a new [HRRecovery] instance.
  HRRecovery({

     this.startIndex,

     this.endIndex,

     this.startTime,

     this.endTime,

     this.startBpm,

     this.endBpm,

     this.averageWatts,

     this.hrr,
  });

  @JsonKey(
    
    name: r'start_index',
    required: false,
    includeIfNull: false,
  )


  final int? startIndex;



  @JsonKey(
    
    name: r'end_index',
    required: false,
    includeIfNull: false,
  )


  final int? endIndex;



  @JsonKey(
    
    name: r'start_time',
    required: false,
    includeIfNull: false,
  )


  final int? startTime;



  @JsonKey(
    
    name: r'end_time',
    required: false,
    includeIfNull: false,
  )


  final int? endTime;



  @JsonKey(
    
    name: r'start_bpm',
    required: false,
    includeIfNull: false,
  )


  final int? startBpm;



  @JsonKey(
    
    name: r'end_bpm',
    required: false,
    includeIfNull: false,
  )


  final int? endBpm;



  @JsonKey(
    
    name: r'average_watts',
    required: false,
    includeIfNull: false,
  )


  final int? averageWatts;



  @JsonKey(
    
    name: r'hrr',
    required: false,
    includeIfNull: false,
  )


  final int? hrr;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HRRecovery &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.startBpm == startBpm &&
      other.endBpm == endBpm &&
      other.averageWatts == averageWatts &&
      other.hrr == hrr;

    @override
    int get hashCode =>
        startIndex.hashCode +
        endIndex.hashCode +
        startTime.hashCode +
        endTime.hashCode +
        startBpm.hashCode +
        endBpm.hashCode +
        averageWatts.hashCode +
        hrr.hashCode;

  factory HRRecovery.fromJson(Map<String, dynamic> json) => _$HRRecoveryFromJson(json);

  Map<String, dynamic> toJson() => _$HRRecoveryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

