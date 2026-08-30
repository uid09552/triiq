//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'effort.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Effort {
  /// Returns a new [Effort] instance.
  Effort({

     this.startIndex,

     this.endIndex,

     this.average,

     this.duration,

     this.distance,
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
    
    name: r'average',
    required: false,
    includeIfNull: false,
  )


  final double? average;



  @JsonKey(
    
    name: r'duration',
    required: false,
    includeIfNull: false,
  )


  final int? duration;



  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Effort &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.average == average &&
      other.duration == duration &&
      other.distance == distance;

    @override
    int get hashCode =>
        startIndex.hashCode +
        endIndex.hashCode +
        average.hashCode +
        duration.hashCode +
        distance.hashCode;

  factory Effort.fromJson(Map<String, dynamic> json) => _$EffortFromJson(json);

  Map<String, dynamic> toJson() => _$EffortToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

