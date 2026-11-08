//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_search_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivitySearchResult {
  /// Returns a new [ActivitySearchResult] instance.
  ActivitySearchResult({
    this.id,

    this.name,

    this.startDateLocal,

    this.type,

    this.race,

    this.distance,

    this.movingTime,

    this.tags,

    this.description,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'start_date_local', required: false, includeIfNull: false)
  final String? startDateLocal;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final String? type;

  @JsonKey(name: r'race', required: false, includeIfNull: false)
  final bool? race;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'tags', required: false, includeIfNull: false)
  final List<String>? tags;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivitySearchResult &&
          other.id == id &&
          other.name == name &&
          other.startDateLocal == startDateLocal &&
          other.type == type &&
          other.race == race &&
          other.distance == distance &&
          other.movingTime == movingTime &&
          other.tags == tags &&
          other.description == description;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      startDateLocal.hashCode +
      type.hashCode +
      race.hashCode +
      distance.hashCode +
      movingTime.hashCode +
      tags.hashCode +
      description.hashCode;

  factory ActivitySearchResult.fromJson(Map<String, dynamic> json) =>
      _$ActivitySearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$ActivitySearchResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
