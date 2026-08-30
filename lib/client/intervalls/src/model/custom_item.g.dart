// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomItemCWProxy {
  CustomItem id(int? id);

  CustomItem athleteId(String? athleteId);

  CustomItem type(CustomItemTypeEnum? type);

  CustomItem visibility(CustomItemVisibilityEnum? visibility);

  CustomItem name(String? name);

  CustomItem description(String? description);

  CustomItem image(String? image);

  CustomItem content(Map<String, Object>? content);

  CustomItem usageCount(int? usageCount);

  CustomItem index(int? index);

  CustomItem hideScript(bool? hideScript);

  CustomItem hiddenById(String? hiddenById);

  CustomItem updated(DateTime? updated);

  CustomItem fromAthlete(AthleteSearchResult? fromAthlete);

  CustomItem fromId(int? fromId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomItem(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomItem call({
    int? id,
    String? athleteId,
    CustomItemTypeEnum? type,
    CustomItemVisibilityEnum? visibility,
    String? name,
    String? description,
    String? image,
    Map<String, Object>? content,
    int? usageCount,
    int? index,
    bool? hideScript,
    String? hiddenById,
    DateTime? updated,
    AthleteSearchResult? fromAthlete,
    int? fromId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomItem.copyWith.fieldName(...)`
class _$CustomItemCWProxyImpl implements _$CustomItemCWProxy {
  const _$CustomItemCWProxyImpl(this._value);

  final CustomItem _value;

  @override
  CustomItem id(int? id) => this(id: id);

  @override
  CustomItem athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  CustomItem type(CustomItemTypeEnum? type) => this(type: type);

  @override
  CustomItem visibility(CustomItemVisibilityEnum? visibility) =>
      this(visibility: visibility);

  @override
  CustomItem name(String? name) => this(name: name);

  @override
  CustomItem description(String? description) => this(description: description);

  @override
  CustomItem image(String? image) => this(image: image);

  @override
  CustomItem content(Map<String, Object>? content) => this(content: content);

  @override
  CustomItem usageCount(int? usageCount) => this(usageCount: usageCount);

  @override
  CustomItem index(int? index) => this(index: index);

  @override
  CustomItem hideScript(bool? hideScript) => this(hideScript: hideScript);

  @override
  CustomItem hiddenById(String? hiddenById) => this(hiddenById: hiddenById);

  @override
  CustomItem updated(DateTime? updated) => this(updated: updated);

  @override
  CustomItem fromAthlete(AthleteSearchResult? fromAthlete) =>
      this(fromAthlete: fromAthlete);

  @override
  CustomItem fromId(int? fromId) => this(fromId: fromId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomItem(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? image = const $CopyWithPlaceholder(),
    Object? content = const $CopyWithPlaceholder(),
    Object? usageCount = const $CopyWithPlaceholder(),
    Object? index = const $CopyWithPlaceholder(),
    Object? hideScript = const $CopyWithPlaceholder(),
    Object? hiddenById = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? fromAthlete = const $CopyWithPlaceholder(),
    Object? fromId = const $CopyWithPlaceholder(),
  }) {
    return CustomItem(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CustomItemTypeEnum?,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as CustomItemVisibilityEnum?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      image: image == const $CopyWithPlaceholder()
          ? _value.image
          // ignore: cast_nullable_to_non_nullable
          : image as String?,
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as Map<String, Object>?,
      usageCount: usageCount == const $CopyWithPlaceholder()
          ? _value.usageCount
          // ignore: cast_nullable_to_non_nullable
          : usageCount as int?,
      index: index == const $CopyWithPlaceholder()
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int?,
      hideScript: hideScript == const $CopyWithPlaceholder()
          ? _value.hideScript
          // ignore: cast_nullable_to_non_nullable
          : hideScript as bool?,
      hiddenById: hiddenById == const $CopyWithPlaceholder()
          ? _value.hiddenById
          // ignore: cast_nullable_to_non_nullable
          : hiddenById as String?,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as DateTime?,
      fromAthlete: fromAthlete == const $CopyWithPlaceholder()
          ? _value.fromAthlete
          // ignore: cast_nullable_to_non_nullable
          : fromAthlete as AthleteSearchResult?,
      fromId: fromId == const $CopyWithPlaceholder()
          ? _value.fromId
          // ignore: cast_nullable_to_non_nullable
          : fromId as int?,
    );
  }
}

extension $CustomItemCopyWith on CustomItem {
  /// Returns a callable class that can be used as follows: `instanceOfCustomItem.copyWith(...)` or like so:`instanceOfCustomItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomItemCWProxy get copyWith => _$CustomItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomItem _$CustomItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CustomItem',
  json,
  ($checkedConvert) {
    final val = CustomItem(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      athleteId: $checkedConvert('athlete_id', (v) => v as String?),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$CustomItemTypeEnumEnumMap, v),
      ),
      visibility: $checkedConvert(
        'visibility',
        (v) => $enumDecodeNullable(_$CustomItemVisibilityEnumEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      image: $checkedConvert('image', (v) => v as String?),
      content: $checkedConvert(
        'content',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      usageCount: $checkedConvert('usage_count', (v) => (v as num?)?.toInt()),
      index: $checkedConvert('index', (v) => (v as num?)?.toInt()),
      hideScript: $checkedConvert('hide_script', (v) => v as bool?),
      hiddenById: $checkedConvert('hidden_by_id', (v) => v as String?),
      updated: $checkedConvert(
        'updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      fromAthlete: $checkedConvert(
        'from_athlete',
        (v) => v == null
            ? null
            : AthleteSearchResult.fromJson(v as Map<String, dynamic>),
      ),
      fromId: $checkedConvert('from_id', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'athleteId': 'athlete_id',
    'usageCount': 'usage_count',
    'hideScript': 'hide_script',
    'hiddenById': 'hidden_by_id',
    'fromAthlete': 'from_athlete',
    'fromId': 'from_id',
  },
);

Map<String, dynamic> _$CustomItemToJson(CustomItem instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'athlete_id': ?instance.athleteId,
      'type': ?_$CustomItemTypeEnumEnumMap[instance.type],
      'visibility': ?_$CustomItemVisibilityEnumEnumMap[instance.visibility],
      'name': ?instance.name,
      'description': ?instance.description,
      'image': ?instance.image,
      'content': ?instance.content,
      'usage_count': ?instance.usageCount,
      'index': ?instance.index,
      'hide_script': ?instance.hideScript,
      'hidden_by_id': ?instance.hiddenById,
      'updated': ?instance.updated?.toIso8601String(),
      'from_athlete': ?instance.fromAthlete?.toJson(),
      'from_id': ?instance.fromId,
    };

const _$CustomItemTypeEnumEnumMap = {
  CustomItemTypeEnum.FITNESS_CHART: 'FITNESS_CHART',
  CustomItemTypeEnum.FITNESS_TABLE: 'FITNESS_TABLE',
  CustomItemTypeEnum.TRACE_CHART: 'TRACE_CHART',
  CustomItemTypeEnum.INPUT_FIELD: 'INPUT_FIELD',
  CustomItemTypeEnum.ACTIVITY_FIELD: 'ACTIVITY_FIELD',
  CustomItemTypeEnum.INTERVAL_FIELD: 'INTERVAL_FIELD',
  CustomItemTypeEnum.ACTIVITY_STREAM: 'ACTIVITY_STREAM',
  CustomItemTypeEnum.ACTIVITY_CHART: 'ACTIVITY_CHART',
  CustomItemTypeEnum.ACTIVITY_HISTOGRAM: 'ACTIVITY_HISTOGRAM',
  CustomItemTypeEnum.ACTIVITY_HEATMAP: 'ACTIVITY_HEATMAP',
  CustomItemTypeEnum.ACTIVITY_MAP: 'ACTIVITY_MAP',
  CustomItemTypeEnum.ACTIVITY_PANEL: 'ACTIVITY_PANEL',
  CustomItemTypeEnum.ZONES: 'ZONES',
};

const _$CustomItemVisibilityEnumEnumMap = {
  CustomItemVisibilityEnum.PRIVATE: 'PRIVATE',
  CustomItemVisibilityEnum.FOLLOWERS: 'FOLLOWERS',
  CustomItemVisibilityEnum.PUBLIC: 'PUBLIC',
};
