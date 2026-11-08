//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'with_count.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WithCount {
  /// Returns a new [WithCount] instance.
  WithCount({
    this.athleteId,

    this.routeId,

    this.name,

    this.renameActivities,

    this.commute,

    this.tags,

    this.description,

    this.replacedByRouteId,

    this.latlngs,

    this.distance,

    this.activityCount,

    this.mostRecentId,

    this.mostRecentStartDateLocal,

    this.mostRecentType,
  });

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'route_id', required: false, includeIfNull: false)
  final int? routeId;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'rename_activities', required: false, includeIfNull: false)
  final bool? renameActivities;

  @JsonKey(name: r'commute', required: false, includeIfNull: false)
  final bool? commute;

  @JsonKey(name: r'tags', required: false, includeIfNull: false)
  final List<String>? tags;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'replaced_by_route_id', required: false, includeIfNull: false)
  final int? replacedByRouteId;

  @JsonKey(name: r'latlngs', required: false, includeIfNull: false)
  final List<List<double>>? latlngs;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'activity_count', required: false, includeIfNull: false)
  final int? activityCount;

  @JsonKey(name: r'most_recent_id', required: false, includeIfNull: false)
  final String? mostRecentId;

  @JsonKey(
    name: r'most_recent_start_date_local',
    required: false,
    includeIfNull: false,
  )
  final String? mostRecentStartDateLocal;

  @JsonKey(name: r'most_recent_type', required: false, includeIfNull: false)
  final String? mostRecentType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithCount &&
          other.athleteId == athleteId &&
          other.routeId == routeId &&
          other.name == name &&
          other.renameActivities == renameActivities &&
          other.commute == commute &&
          other.tags == tags &&
          other.description == description &&
          other.replacedByRouteId == replacedByRouteId &&
          other.latlngs == latlngs &&
          other.distance == distance &&
          other.activityCount == activityCount &&
          other.mostRecentId == mostRecentId &&
          other.mostRecentStartDateLocal == mostRecentStartDateLocal &&
          other.mostRecentType == mostRecentType;

  @override
  int get hashCode =>
      athleteId.hashCode +
      routeId.hashCode +
      name.hashCode +
      renameActivities.hashCode +
      commute.hashCode +
      tags.hashCode +
      description.hashCode +
      replacedByRouteId.hashCode +
      latlngs.hashCode +
      distance.hashCode +
      activityCount.hashCode +
      mostRecentId.hashCode +
      mostRecentStartDateLocal.hashCode +
      mostRecentType.hashCode;

  factory WithCount.fromJson(Map<String, dynamic> json) =>
      _$WithCountFromJson(json);

  Map<String, dynamic> toJson() => _$WithCountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
