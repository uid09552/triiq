//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ignore.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Ignore {
  /// Returns a new [Ignore] instance.
  Ignore({

     this.startIndex,

     this.endIndex,

     this.power,

     this.pace,

     this.hr,
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
    
    name: r'power',
    required: false,
    includeIfNull: false,
  )


  final bool? power;



  @JsonKey(
    
    name: r'pace',
    required: false,
    includeIfNull: false,
  )


  final bool? pace;



  @JsonKey(
    
    name: r'hr',
    required: false,
    includeIfNull: false,
  )


  final bool? hr;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Ignore &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.power == power &&
      other.pace == pace &&
      other.hr == hr;

    @override
    int get hashCode =>
        startIndex.hashCode +
        endIndex.hashCode +
        power.hashCode +
        pace.hashCode +
        hr.hashCode;

  factory Ignore.fromJson(Map<String, dynamic> json) => _$IgnoreFromJson(json);

  Map<String, dynamic> toJson() => _$IgnoreToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

