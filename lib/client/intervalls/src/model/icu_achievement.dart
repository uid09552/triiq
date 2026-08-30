//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/data_curve_pt.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'icu_achievement.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IcuAchievement {
  /// Returns a new [IcuAchievement] instance.
  IcuAchievement({

     this.id,

     this.type,

     this.message,

     this.watts,

     this.secs,

     this.value,

     this.distance,

     this.pace,

     this.point,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final IcuAchievementTypeEnum? type;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(
    
    name: r'watts',
    required: false,
    includeIfNull: false,
  )


  final int? watts;



  @JsonKey(
    
    name: r'secs',
    required: false,
    includeIfNull: false,
  )


  final int? secs;



  @JsonKey(
    
    name: r'value',
    required: false,
    includeIfNull: false,
  )


  final int? value;



  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;



  @JsonKey(
    
    name: r'pace',
    required: false,
    includeIfNull: false,
  )


  final double? pace;



  @JsonKey(
    
    name: r'point',
    required: false,
    includeIfNull: false,
  )


  final DataCurvePt? point;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IcuAchievement &&
      other.id == id &&
      other.type == type &&
      other.message == message &&
      other.watts == watts &&
      other.secs == secs &&
      other.value == value &&
      other.distance == distance &&
      other.pace == pace &&
      other.point == point;

    @override
    int get hashCode =>
        id.hashCode +
        type.hashCode +
        message.hashCode +
        watts.hashCode +
        secs.hashCode +
        value.hashCode +
        distance.hashCode +
        pace.hashCode +
        point.hashCode;

  factory IcuAchievement.fromJson(Map<String, dynamic> json) => _$IcuAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$IcuAchievementToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum IcuAchievementTypeEnum {
@JsonValue(r'BEST_POWER')
BEST_POWER(r'BEST_POWER'),
@JsonValue(r'FTP_UP')
FTP_UP(r'FTP_UP'),
@JsonValue(r'LTHR_UP')
LTHR_UP(r'LTHR_UP'),
@JsonValue(r'BEST_PACE')
BEST_PACE(r'BEST_PACE');

const IcuAchievementTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


