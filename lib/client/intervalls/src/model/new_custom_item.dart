//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/athlete_search_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_custom_item.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NewCustomItem {
  /// Returns a new [NewCustomItem] instance.
  NewCustomItem({
    this.id,

    this.athleteId,

    this.type,

    this.visibility,

    this.name,

    this.description,

    this.image,

    this.content,

    this.usageCount,

    this.index,

    this.hideScript,

    this.hiddenById,

    this.updated,

    this.fromAthlete,

    this.fromId,

    this.requiredItemsCreated,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final NewCustomItemTypeEnum? type;

  @JsonKey(name: r'visibility', required: false, includeIfNull: false)
  final NewCustomItemVisibilityEnum? visibility;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'image', required: false, includeIfNull: false)
  final String? image;

  @JsonKey(name: r'content', required: false, includeIfNull: false)
  final Map<String, Object>? content;

  @JsonKey(name: r'usage_count', required: false, includeIfNull: false)
  final int? usageCount;

  @JsonKey(name: r'index', required: false, includeIfNull: false)
  final int? index;

  @JsonKey(name: r'hide_script', required: false, includeIfNull: false)
  final bool? hideScript;

  @JsonKey(name: r'hidden_by_id', required: false, includeIfNull: false)
  final String? hiddenById;

  @JsonKey(name: r'updated', required: false, includeIfNull: false)
  final DateTime? updated;

  @JsonKey(name: r'from_athlete', required: false, includeIfNull: false)
  final AthleteSearchResult? fromAthlete;

  @JsonKey(name: r'from_id', required: false, includeIfNull: false)
  final int? fromId;

  @JsonKey(
    name: r'required_items_created',
    required: false,
    includeIfNull: false,
  )
  final List<NewCustomItem>? requiredItemsCreated;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewCustomItem &&
          other.id == id &&
          other.athleteId == athleteId &&
          other.type == type &&
          other.visibility == visibility &&
          other.name == name &&
          other.description == description &&
          other.image == image &&
          other.content == content &&
          other.usageCount == usageCount &&
          other.index == index &&
          other.hideScript == hideScript &&
          other.hiddenById == hiddenById &&
          other.updated == updated &&
          other.fromAthlete == fromAthlete &&
          other.fromId == fromId &&
          other.requiredItemsCreated == requiredItemsCreated;

  @override
  int get hashCode =>
      id.hashCode +
      athleteId.hashCode +
      type.hashCode +
      visibility.hashCode +
      name.hashCode +
      description.hashCode +
      image.hashCode +
      content.hashCode +
      usageCount.hashCode +
      index.hashCode +
      hideScript.hashCode +
      hiddenById.hashCode +
      updated.hashCode +
      fromAthlete.hashCode +
      fromId.hashCode +
      requiredItemsCreated.hashCode;

  factory NewCustomItem.fromJson(Map<String, dynamic> json) =>
      _$NewCustomItemFromJson(json);

  Map<String, dynamic> toJson() => _$NewCustomItemToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum NewCustomItemTypeEnum {
  @JsonValue(r'FITNESS_CHART')
  FITNESS_CHART(r'FITNESS_CHART'),
  @JsonValue(r'FITNESS_TABLE')
  FITNESS_TABLE(r'FITNESS_TABLE'),
  @JsonValue(r'TRACE_CHART')
  TRACE_CHART(r'TRACE_CHART'),
  @JsonValue(r'INPUT_FIELD')
  INPUT_FIELD(r'INPUT_FIELD'),
  @JsonValue(r'ACTIVITY_FIELD')
  ACTIVITY_FIELD(r'ACTIVITY_FIELD'),
  @JsonValue(r'INTERVAL_FIELD')
  INTERVAL_FIELD(r'INTERVAL_FIELD'),
  @JsonValue(r'ACTIVITY_STREAM')
  ACTIVITY_STREAM(r'ACTIVITY_STREAM'),
  @JsonValue(r'ACTIVITY_CHART')
  ACTIVITY_CHART(r'ACTIVITY_CHART'),
  @JsonValue(r'ACTIVITY_HISTOGRAM')
  ACTIVITY_HISTOGRAM(r'ACTIVITY_HISTOGRAM'),
  @JsonValue(r'ACTIVITY_HEATMAP')
  ACTIVITY_HEATMAP(r'ACTIVITY_HEATMAP'),
  @JsonValue(r'ACTIVITY_MAP')
  ACTIVITY_MAP(r'ACTIVITY_MAP'),
  @JsonValue(r'ACTIVITY_PANEL')
  ACTIVITY_PANEL(r'ACTIVITY_PANEL'),
  @JsonValue(r'ZONES')
  ZONES(r'ZONES');

  const NewCustomItemTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum NewCustomItemVisibilityEnum {
  @JsonValue(r'PRIVATE')
  PRIVATE(r'PRIVATE'),
  @JsonValue(r'FOLLOWERS')
  FOLLOWERS(r'FOLLOWERS'),
  @JsonValue(r'PUBLIC')
  PUBLIC(r'PUBLIC');

  const NewCustomItemVisibilityEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
