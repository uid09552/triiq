//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_power_curve.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityPowerCurve {
  /// Returns a new [ActivityPowerCurve] instance.
  ActivityPowerCurve({

     this.id,

     this.startDateLocal,

     this.weight,

     this.watts,
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
    
    name: r'watts',
    required: false,
    includeIfNull: false,
  )


  final List<int>? watts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityPowerCurve &&
      other.id == id &&
      other.startDateLocal == startDateLocal &&
      other.weight == weight &&
      other.watts == watts;

    @override
    int get hashCode =>
        id.hashCode +
        startDateLocal.hashCode +
        weight.hashCode +
        watts.hashCode;

  factory ActivityPowerCurve.fromJson(Map<String, dynamic> json) => _$ActivityPowerCurveFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityPowerCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

