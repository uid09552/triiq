//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_route.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteRoute {
  /// Returns a new [AthleteRoute] instance.
  AthleteRoute({
    this.athleteId,

    this.routeId,

    this.name,

    this.renameActivities,

    this.commute,

    this.tags,

    this.description,

    this.replacedByRouteId,

    this.latlngs,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AthleteRoute &&
          other.athleteId == athleteId &&
          other.routeId == routeId &&
          other.name == name &&
          other.renameActivities == renameActivities &&
          other.commute == commute &&
          other.tags == tags &&
          other.description == description &&
          other.replacedByRouteId == replacedByRouteId &&
          other.latlngs == latlngs;

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
      latlngs.hashCode;

  factory AthleteRoute.fromJson(Map<String, dynamic> json) =>
      _$AthleteRouteFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteRouteToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
