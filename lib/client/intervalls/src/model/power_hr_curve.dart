//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'power_hr_curve.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PowerHRCurve {
  /// Returns a new [PowerHRCurve] instance.
  PowerHRCurve({

     this.athleteId,

     this.start,

     this.end,

     this.minWatts,

     this.maxWatts,

     this.bucketSize,

     this.bpm,

     this.cadence,

     this.minutes,

     this.lthr,

     this.maxHr,

     this.ftp,
  });

  @JsonKey(
    
    name: r'athleteId',
    required: false,
    includeIfNull: false,
  )


  final String? athleteId;



  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final String? start;



  @JsonKey(
    
    name: r'end',
    required: false,
    includeIfNull: false,
  )


  final String? end;



  @JsonKey(
    
    name: r'minWatts',
    required: false,
    includeIfNull: false,
  )


  final int? minWatts;



  @JsonKey(
    
    name: r'maxWatts',
    required: false,
    includeIfNull: false,
  )


  final int? maxWatts;



  @JsonKey(
    
    name: r'bucketSize',
    required: false,
    includeIfNull: false,
  )


  final int? bucketSize;



  @JsonKey(
    
    name: r'bpm',
    required: false,
    includeIfNull: false,
  )


  final List<int>? bpm;



  @JsonKey(
    
    name: r'cadence',
    required: false,
    includeIfNull: false,
  )


  final List<int>? cadence;



  @JsonKey(
    
    name: r'minutes',
    required: false,
    includeIfNull: false,
  )


  final List<int>? minutes;



  @JsonKey(
    
    name: r'lthr',
    required: false,
    includeIfNull: false,
  )


  final int? lthr;



  @JsonKey(
    
    name: r'max_hr',
    required: false,
    includeIfNull: false,
  )


  final int? maxHr;



  @JsonKey(
    
    name: r'ftp',
    required: false,
    includeIfNull: false,
  )


  final int? ftp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PowerHRCurve &&
      other.athleteId == athleteId &&
      other.start == start &&
      other.end == end &&
      other.minWatts == minWatts &&
      other.maxWatts == maxWatts &&
      other.bucketSize == bucketSize &&
      other.bpm == bpm &&
      other.cadence == cadence &&
      other.minutes == minutes &&
      other.lthr == lthr &&
      other.maxHr == maxHr &&
      other.ftp == ftp;

    @override
    int get hashCode =>
        athleteId.hashCode +
        start.hashCode +
        end.hashCode +
        minWatts.hashCode +
        maxWatts.hashCode +
        bucketSize.hashCode +
        bpm.hashCode +
        cadence.hashCode +
        minutes.hashCode +
        lthr.hashCode +
        maxHr.hashCode +
        ftp.hashCode;

  factory PowerHRCurve.fromJson(Map<String, dynamic> json) => _$PowerHRCurveFromJson(json);

  Map<String, dynamic> toJson() => _$PowerHRCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

