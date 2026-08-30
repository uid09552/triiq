// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_search_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivitySearchResultCWProxy {
  ActivitySearchResult id(String? id);

  ActivitySearchResult name(String? name);

  ActivitySearchResult startDateLocal(String? startDateLocal);

  ActivitySearchResult type(String? type);

  ActivitySearchResult race(bool? race);

  ActivitySearchResult distance(double? distance);

  ActivitySearchResult movingTime(int? movingTime);

  ActivitySearchResult tags(List<String>? tags);

  ActivitySearchResult description(String? description);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivitySearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivitySearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivitySearchResult call({
    String? id,
    String? name,
    String? startDateLocal,
    String? type,
    bool? race,
    double? distance,
    int? movingTime,
    List<String>? tags,
    String? description,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivitySearchResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivitySearchResult.copyWith.fieldName(...)`
class _$ActivitySearchResultCWProxyImpl
    implements _$ActivitySearchResultCWProxy {
  const _$ActivitySearchResultCWProxyImpl(this._value);

  final ActivitySearchResult _value;

  @override
  ActivitySearchResult id(String? id) => this(id: id);

  @override
  ActivitySearchResult name(String? name) => this(name: name);

  @override
  ActivitySearchResult startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  ActivitySearchResult type(String? type) => this(type: type);

  @override
  ActivitySearchResult race(bool? race) => this(race: race);

  @override
  ActivitySearchResult distance(double? distance) => this(distance: distance);

  @override
  ActivitySearchResult movingTime(int? movingTime) =>
      this(movingTime: movingTime);

  @override
  ActivitySearchResult tags(List<String>? tags) => this(tags: tags);

  @override
  ActivitySearchResult description(String? description) =>
      this(description: description);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivitySearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivitySearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivitySearchResult call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? race = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
  }) {
    return ActivitySearchResult(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String?,
      race: race == const $CopyWithPlaceholder()
          ? _value.race
          // ignore: cast_nullable_to_non_nullable
          : race as bool?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as int?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
    );
  }
}

extension $ActivitySearchResultCopyWith on ActivitySearchResult {
  /// Returns a callable class that can be used as follows: `instanceOfActivitySearchResult.copyWith(...)` or like so:`instanceOfActivitySearchResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivitySearchResultCWProxy get copyWith =>
      _$ActivitySearchResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivitySearchResult _$ActivitySearchResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ActivitySearchResult',
  json,
  ($checkedConvert) {
    final val = ActivitySearchResult(
      id: $checkedConvert('id', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      startDateLocal: $checkedConvert('start_date_local', (v) => v as String?),
      type: $checkedConvert('type', (v) => v as String?),
      race: $checkedConvert('race', (v) => v as bool?),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      movingTime: $checkedConvert('moving_time', (v) => (v as num?)?.toInt()),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      description: $checkedConvert('description', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'startDateLocal': 'start_date_local',
    'movingTime': 'moving_time',
  },
);

Map<String, dynamic> _$ActivitySearchResultToJson(
  ActivitySearchResult instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'name': ?instance.name,
  'start_date_local': ?instance.startDateLocal,
  'type': ?instance.type,
  'race': ?instance.race,
  'distance': ?instance.distance,
  'moving_time': ?instance.movingTime,
  'tags': ?instance.tags,
  'description': ?instance.description,
};
