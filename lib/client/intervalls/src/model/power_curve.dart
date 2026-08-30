//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/power_model.dart';
import 'package:triiq/client/intervalls/src/model/activity_filter.dart';
import 'package:triiq/client/intervalls/src/model/rank.dart';
import 'package:triiq/client/intervalls/src/model/plot.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'power_curve.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PowerCurve {
  /// Returns a new [PowerCurve] instance.
  PowerCurve({

     this.id,

     this.afterKj,

     this.filters,

     this.label,

     this.filterLabel,

     this.percentile,

     this.startDateLocal,

     this.endDateLocal,

     this.days,

     this.movingTime,

     this.trainingLoad,

     this.weight,

     this.secs,

     this.values,

     this.submaxValues,

     this.submaxActivityId,

     this.startIndex,

     this.endIndex,

     this.activityId,

     this.wattsPerKg,

     this.wkgActivityId,

     this.submaxWattsPerKg,

     this.submaxWkgActivityId,

     this.powerModels,

     this.ranks,

     this.mapPlot,

     this.streamType,

     this.streamName,

     this.watts,

     this.vo2max5m,

     this.compoundScore5m,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'after_kj',
    required: false,
    includeIfNull: false,
  )


  final int? afterKj;



  @JsonKey(
    
    name: r'filters',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityFilter>? filters;



  @JsonKey(
    
    name: r'label',
    required: false,
    includeIfNull: false,
  )


  final String? label;



  @JsonKey(
    
    name: r'filter_label',
    required: false,
    includeIfNull: false,
  )


  final String? filterLabel;



  @JsonKey(
    
    name: r'percentile',
    required: false,
    includeIfNull: false,
  )


  final double? percentile;



  @JsonKey(
    
    name: r'start_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? startDateLocal;



  @JsonKey(
    
    name: r'end_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? endDateLocal;



  @JsonKey(
    
    name: r'days',
    required: false,
    includeIfNull: false,
  )


  final int? days;



  @JsonKey(
    
    name: r'moving_time',
    required: false,
    includeIfNull: false,
  )


  final int? movingTime;



  @JsonKey(
    
    name: r'training_load',
    required: false,
    includeIfNull: false,
  )


  final int? trainingLoad;



  @JsonKey(
    
    name: r'weight',
    required: false,
    includeIfNull: false,
  )


  final double? weight;



  @JsonKey(
    
    name: r'secs',
    required: false,
    includeIfNull: false,
  )


  final List<int>? secs;



  @JsonKey(
    
    name: r'values',
    required: false,
    includeIfNull: false,
  )


  final List<int>? values;



  @JsonKey(
    
    name: r'submax_values',
    required: false,
    includeIfNull: false,
  )


  final List<List<int>>? submaxValues;



  @JsonKey(
    
    name: r'submax_activity_id',
    required: false,
    includeIfNull: false,
  )


  final List<List<String>>? submaxActivityId;



  @JsonKey(
    
    name: r'start_index',
    required: false,
    includeIfNull: false,
  )


  final List<int>? startIndex;



  @JsonKey(
    
    name: r'end_index',
    required: false,
    includeIfNull: false,
  )


  final List<int>? endIndex;



  @JsonKey(
    
    name: r'activity_id',
    required: false,
    includeIfNull: false,
  )


  final List<String>? activityId;



  @JsonKey(
    
    name: r'watts_per_kg',
    required: false,
    includeIfNull: false,
  )


  final List<double>? wattsPerKg;



  @JsonKey(
    
    name: r'wkg_activity_id',
    required: false,
    includeIfNull: false,
  )


  final List<String>? wkgActivityId;



  @JsonKey(
    
    name: r'submax_watts_per_kg',
    required: false,
    includeIfNull: false,
  )


  final List<List<double>>? submaxWattsPerKg;



  @JsonKey(
    
    name: r'submax_wkg_activity_id',
    required: false,
    includeIfNull: false,
  )


  final List<List<String>>? submaxWkgActivityId;



  @JsonKey(
    
    name: r'powerModels',
    required: false,
    includeIfNull: false,
  )


  final List<PowerModel>? powerModels;



  @JsonKey(
    
    name: r'ranks',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Rank>? ranks;



  @JsonKey(
    
    name: r'mapPlot',
    required: false,
    includeIfNull: false,
  )


  final Plot? mapPlot;



  @JsonKey(
    
    name: r'stream_type',
    required: false,
    includeIfNull: false,
  )


  final String? streamType;



  @JsonKey(
    
    name: r'stream_name',
    required: false,
    includeIfNull: false,
  )


  final String? streamName;



  @JsonKey(
    
    name: r'watts',
    required: false,
    includeIfNull: false,
  )


  final List<int>? watts;



  @JsonKey(
    
    name: r'vo2max_5m',
    required: false,
    includeIfNull: false,
  )


  final double? vo2max5m;



  @JsonKey(
    
    name: r'compound_score_5m',
    required: false,
    includeIfNull: false,
  )


  final double? compoundScore5m;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PowerCurve &&
      other.id == id &&
      other.afterKj == afterKj &&
      other.filters == filters &&
      other.label == label &&
      other.filterLabel == filterLabel &&
      other.percentile == percentile &&
      other.startDateLocal == startDateLocal &&
      other.endDateLocal == endDateLocal &&
      other.days == days &&
      other.movingTime == movingTime &&
      other.trainingLoad == trainingLoad &&
      other.weight == weight &&
      other.secs == secs &&
      other.values == values &&
      other.submaxValues == submaxValues &&
      other.submaxActivityId == submaxActivityId &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.activityId == activityId &&
      other.wattsPerKg == wattsPerKg &&
      other.wkgActivityId == wkgActivityId &&
      other.submaxWattsPerKg == submaxWattsPerKg &&
      other.submaxWkgActivityId == submaxWkgActivityId &&
      other.powerModels == powerModels &&
      other.ranks == ranks &&
      other.mapPlot == mapPlot &&
      other.streamType == streamType &&
      other.streamName == streamName &&
      other.watts == watts &&
      other.vo2max5m == vo2max5m &&
      other.compoundScore5m == compoundScore5m;

    @override
    int get hashCode =>
        id.hashCode +
        afterKj.hashCode +
        filters.hashCode +
        label.hashCode +
        filterLabel.hashCode +
        percentile.hashCode +
        startDateLocal.hashCode +
        endDateLocal.hashCode +
        days.hashCode +
        movingTime.hashCode +
        trainingLoad.hashCode +
        weight.hashCode +
        secs.hashCode +
        values.hashCode +
        submaxValues.hashCode +
        submaxActivityId.hashCode +
        startIndex.hashCode +
        endIndex.hashCode +
        activityId.hashCode +
        wattsPerKg.hashCode +
        wkgActivityId.hashCode +
        submaxWattsPerKg.hashCode +
        submaxWkgActivityId.hashCode +
        powerModels.hashCode +
        ranks.hashCode +
        mapPlot.hashCode +
        streamType.hashCode +
        streamName.hashCode +
        watts.hashCode +
        vo2max5m.hashCode +
        compoundScore5m.hashCode;

  factory PowerCurve.fromJson(Map<String, dynamic> json) => _$PowerCurveFromJson(json);

  Map<String, dynamic> toJson() => _$PowerCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

