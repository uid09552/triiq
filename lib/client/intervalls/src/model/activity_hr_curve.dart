//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_hr_curve.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityHRCurve {
  /// Returns a new [ActivityHRCurve] instance.
  ActivityHRCurve({

     this.id,

     this.startDateLocal,

     this.weight,

     this.bpm,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'start_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? startDateLocal;



  @JsonKey(
    
    name: r'weight',
    required: false,
    includeIfNull: false,
  )


  final double? weight;



  @JsonKey(
    
    name: r'bpm',
    required: false,
    includeIfNull: false,
  )


  final List<int>? bpm;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityHRCurve &&
      other.id == id &&
      other.startDateLocal == startDateLocal &&
      other.weight == weight &&
      other.bpm == bpm;

    @override
    int get hashCode =>
        id.hashCode +
        startDateLocal.hashCode +
        weight.hashCode +
        bpm.hashCode;

  factory ActivityHRCurve.fromJson(Map<String, dynamic> json) => _$ActivityHRCurveFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityHRCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

