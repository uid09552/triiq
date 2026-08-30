//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_hr_curve.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_hr_curve_payload.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityHRCurvePayload {
  /// Returns a new [ActivityHRCurvePayload] instance.
  ActivityHRCurvePayload({

     this.secs,

     this.curves,
  });

  @JsonKey(
    
    name: r'secs',
    required: false,
    includeIfNull: false,
  )


  final List<int>? secs;



  @JsonKey(
    
    name: r'curves',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityHRCurve>? curves;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityHRCurvePayload &&
      other.secs == secs &&
      other.curves == curves;

    @override
    int get hashCode =>
        secs.hashCode +
        curves.hashCode;

  factory ActivityHRCurvePayload.fromJson(Map<String, dynamic> json) => _$ActivityHRCurvePayloadFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityHRCurvePayloadToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

