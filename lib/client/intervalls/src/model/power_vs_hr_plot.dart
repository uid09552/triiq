//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/curve.dart';
import 'package:triiq/client/intervalls/src/model/bucket.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'power_vs_hr_plot.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PowerVsHRPlot {
  /// Returns a new [PowerVsHRPlot] instance.
  PowerVsHRPlot({

     this.bucketSize,

     this.warmup,

     this.cooldown,

     this.elapsedTime,

     this.hrLag,

     this.powerHr,

     this.powerHrFirst,

     this.powerHrSecond,

     this.decoupling,

     this.powerHrZ2,

     this.medianCadenceZ2,

     this.avgCadenceZ2,

     this.hrZ2BucketCount,

     this.start,

     this.mid,

     this.end,

     this.series,

     this.curves,

     this.ratioCoefficients,
  });

  @JsonKey(
    
    name: r'bucketSize',
    required: false,
    includeIfNull: false,
  )


  final int? bucketSize;



  @JsonKey(
    
    name: r'warmup',
    required: false,
    includeIfNull: false,
  )


  final int? warmup;



  @JsonKey(
    
    name: r'cooldown',
    required: false,
    includeIfNull: false,
  )


  final int? cooldown;



  @JsonKey(
    
    name: r'elapsedTime',
    required: false,
    includeIfNull: false,
  )


  final int? elapsedTime;



  @JsonKey(
    
    name: r'hrLag',
    required: false,
    includeIfNull: false,
  )


  final int? hrLag;



  @JsonKey(
    
    name: r'powerHr',
    required: false,
    includeIfNull: false,
  )


  final double? powerHr;



  @JsonKey(
    
    name: r'powerHrFirst',
    required: false,
    includeIfNull: false,
  )


  final double? powerHrFirst;



  @JsonKey(
    
    name: r'powerHrSecond',
    required: false,
    includeIfNull: false,
  )


  final double? powerHrSecond;



  @JsonKey(
    
    name: r'decoupling',
    required: false,
    includeIfNull: false,
  )


  final double? decoupling;



  @JsonKey(
    
    name: r'powerHrZ2',
    required: false,
    includeIfNull: false,
  )


  final double? powerHrZ2;



  @JsonKey(
    
    name: r'medianCadenceZ2',
    required: false,
    includeIfNull: false,
  )


  final int? medianCadenceZ2;



  @JsonKey(
    
    name: r'avgCadenceZ2',
    required: false,
    includeIfNull: false,
  )


  final int? avgCadenceZ2;



  @JsonKey(
    
    name: r'hrZ2BucketCount',
    required: false,
    includeIfNull: false,
  )


  final int? hrZ2BucketCount;



  @JsonKey(
    
    name: r'start',
    required: false,
    includeIfNull: false,
  )


  final int? start;



  @JsonKey(
    
    name: r'mid',
    required: false,
    includeIfNull: false,
  )


  final int? mid;



  @JsonKey(
    
    name: r'end',
    required: false,
    includeIfNull: false,
  )


  final int? end;



  @JsonKey(
    
    name: r'series',
    required: false,
    includeIfNull: false,
  )


  final List<Bucket>? series;



  @JsonKey(
    
    name: r'curves',
    required: false,
    includeIfNull: false,
  )


  final List<Curve>? curves;



  @JsonKey(
    
    name: r'ratioCoefficients',
    required: false,
    includeIfNull: false,
  )


  final List<double>? ratioCoefficients;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PowerVsHRPlot &&
      other.bucketSize == bucketSize &&
      other.warmup == warmup &&
      other.cooldown == cooldown &&
      other.elapsedTime == elapsedTime &&
      other.hrLag == hrLag &&
      other.powerHr == powerHr &&
      other.powerHrFirst == powerHrFirst &&
      other.powerHrSecond == powerHrSecond &&
      other.decoupling == decoupling &&
      other.powerHrZ2 == powerHrZ2 &&
      other.medianCadenceZ2 == medianCadenceZ2 &&
      other.avgCadenceZ2 == avgCadenceZ2 &&
      other.hrZ2BucketCount == hrZ2BucketCount &&
      other.start == start &&
      other.mid == mid &&
      other.end == end &&
      other.series == series &&
      other.curves == curves &&
      other.ratioCoefficients == ratioCoefficients;

    @override
    int get hashCode =>
        bucketSize.hashCode +
        warmup.hashCode +
        cooldown.hashCode +
        elapsedTime.hashCode +
        hrLag.hashCode +
        powerHr.hashCode +
        powerHrFirst.hashCode +
        powerHrSecond.hashCode +
        decoupling.hashCode +
        powerHrZ2.hashCode +
        medianCadenceZ2.hashCode +
        avgCadenceZ2.hashCode +
        hrZ2BucketCount.hashCode +
        start.hashCode +
        mid.hashCode +
        end.hashCode +
        series.hashCode +
        curves.hashCode +
        ratioCoefficients.hashCode;

  factory PowerVsHRPlot.fromJson(Map<String, dynamic> json) => _$PowerVsHRPlotFromJson(json);

  Map<String, dynamic> toJson() => _$PowerVsHRPlotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

