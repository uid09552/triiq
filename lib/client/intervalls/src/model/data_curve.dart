//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_filter.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_curve.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataCurve {
  /// Returns a new [DataCurve] instance.
  DataCurve({
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

    this.distance,

    this.values,

    this.submaxValues,

    this.submaxActivityId,

    this.startIndex,

    this.endIndex,

    this.activityId,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'after_kj', required: false, includeIfNull: false)
  final int? afterKj;

  @JsonKey(name: r'filters', required: false, includeIfNull: false)
  final List<ActivityFilter>? filters;

  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  @JsonKey(name: r'filter_label', required: false, includeIfNull: false)
  final String? filterLabel;

  @JsonKey(name: r'percentile', required: false, includeIfNull: false)
  final double? percentile;

  @JsonKey(name: r'start_date_local', required: false, includeIfNull: false)
  final String? startDateLocal;

  @JsonKey(name: r'end_date_local', required: false, includeIfNull: false)
  final String? endDateLocal;

  @JsonKey(name: r'days', required: false, includeIfNull: false)
  final int? days;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'training_load', required: false, includeIfNull: false)
  final int? trainingLoad;

  @JsonKey(name: r'weight', required: false, includeIfNull: false)
  final double? weight;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final List<int>? secs;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final List<double>? distance;

  @JsonKey(name: r'values', required: false, includeIfNull: false)
  final List<int>? values;

  @JsonKey(name: r'submax_values', required: false, includeIfNull: false)
  final List<List<int>>? submaxValues;

  @JsonKey(name: r'submax_activity_id', required: false, includeIfNull: false)
  final List<List<String>>? submaxActivityId;

  @JsonKey(name: r'start_index', required: false, includeIfNull: false)
  final List<int>? startIndex;

  @JsonKey(name: r'end_index', required: false, includeIfNull: false)
  final List<int>? endIndex;

  @JsonKey(name: r'activity_id', required: false, includeIfNull: false)
  final List<String>? activityId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataCurve &&
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
          other.distance == distance &&
          other.values == values &&
          other.submaxValues == submaxValues &&
          other.submaxActivityId == submaxActivityId &&
          other.startIndex == startIndex &&
          other.endIndex == endIndex &&
          other.activityId == activityId;

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
      distance.hashCode +
      values.hashCode +
      submaxValues.hashCode +
      submaxActivityId.hashCode +
      startIndex.hashCode +
      endIndex.hashCode +
      activityId.hashCode;

  factory DataCurve.fromJson(Map<String, dynamic> json) =>
      _$DataCurveFromJson(json);

  Map<String, dynamic> toJson() => _$DataCurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
