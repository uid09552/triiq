//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hr_load_model.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HRLoadModel {
  /// Returns a new [HRLoadModel] instance.
  HRLoadModel({

     this.type,

     this.icuTrainingLoad,

     this.trainingDataCount,
  });

  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final HRLoadModelTypeEnum? type;



  @JsonKey(
    
    name: r'icu_training_load',
    required: false,
    includeIfNull: false,
  )


  final int? icuTrainingLoad;



  @JsonKey(
    
    name: r'trainingDataCount',
    required: false,
    includeIfNull: false,
  )


  final int? trainingDataCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HRLoadModel &&
      other.type == type &&
      other.icuTrainingLoad == icuTrainingLoad &&
      other.trainingDataCount == trainingDataCount;

    @override
    int get hashCode =>
        type.hashCode +
        icuTrainingLoad.hashCode +
        trainingDataCount.hashCode;

  factory HRLoadModel.fromJson(Map<String, dynamic> json) => _$HRLoadModelFromJson(json);

  Map<String, dynamic> toJson() => _$HRLoadModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum HRLoadModelTypeEnum {
@JsonValue(r'AVG_HR')
AVG_HR(r'AVG_HR'),
@JsonValue(r'HR_ZONES')
HR_ZONES(r'HR_ZONES'),
@JsonValue(r'HRSS')
HRSS(r'HRSS');

const HRLoadModelTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


