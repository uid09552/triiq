// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_route.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteRouteCWProxy {
  AthleteRoute athleteId(String? athleteId);

  AthleteRoute routeId(int? routeId);

  AthleteRoute name(String? name);

  AthleteRoute renameActivities(bool? renameActivities);

  AthleteRoute commute(bool? commute);

  AthleteRoute tags(List<String>? tags);

  AthleteRoute description(String? description);

  AthleteRoute replacedByRouteId(int? replacedByRouteId);

  AthleteRoute latlngs(List<List<double>>? latlngs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteRoute(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteRoute(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteRoute call({
    String? athleteId,
    int? routeId,
    String? name,
    bool? renameActivities,
    bool? commute,
    List<String>? tags,
    String? description,
    int? replacedByRouteId,
    List<List<double>>? latlngs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteRoute.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteRoute.copyWith.fieldName(...)`
class _$AthleteRouteCWProxyImpl implements _$AthleteRouteCWProxy {
  const _$AthleteRouteCWProxyImpl(this._value);

  final AthleteRoute _value;

  @override
  AthleteRoute athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  AthleteRoute routeId(int? routeId) => this(routeId: routeId);

  @override
  AthleteRoute name(String? name) => this(name: name);

  @override
  AthleteRoute renameActivities(bool? renameActivities) =>
      this(renameActivities: renameActivities);

  @override
  AthleteRoute commute(bool? commute) => this(commute: commute);

  @override
  AthleteRoute tags(List<String>? tags) => this(tags: tags);

  @override
  AthleteRoute description(String? description) =>
      this(description: description);

  @override
  AthleteRoute replacedByRouteId(int? replacedByRouteId) =>
      this(replacedByRouteId: replacedByRouteId);

  @override
  AthleteRoute latlngs(List<List<double>>? latlngs) => this(latlngs: latlngs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteRoute(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteRoute(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteRoute call({
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? routeId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? renameActivities = const $CopyWithPlaceholder(),
    Object? commute = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? replacedByRouteId = const $CopyWithPlaceholder(),
    Object? latlngs = const $CopyWithPlaceholder(),
  }) {
    return AthleteRoute(
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      routeId: routeId == const $CopyWithPlaceholder()
          ? _value.routeId
          // ignore: cast_nullable_to_non_nullable
          : routeId as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      renameActivities: renameActivities == const $CopyWithPlaceholder()
          ? _value.renameActivities
          // ignore: cast_nullable_to_non_nullable
          : renameActivities as bool?,
      commute: commute == const $CopyWithPlaceholder()
          ? _value.commute
          // ignore: cast_nullable_to_non_nullable
          : commute as bool?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      replacedByRouteId: replacedByRouteId == const $CopyWithPlaceholder()
          ? _value.replacedByRouteId
          // ignore: cast_nullable_to_non_nullable
          : replacedByRouteId as int?,
      latlngs: latlngs == const $CopyWithPlaceholder()
          ? _value.latlngs
          // ignore: cast_nullable_to_non_nullable
          : latlngs as List<List<double>>?,
    );
  }
}

extension $AthleteRouteCopyWith on AthleteRoute {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteRoute.copyWith(...)` or like so:`instanceOfAthleteRoute.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteRouteCWProxy get copyWith => _$AthleteRouteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteRoute _$AthleteRouteFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AthleteRoute',
      json,
      ($checkedConvert) {
        final val = AthleteRoute(
          athleteId: $checkedConvert('athlete_id', (v) => v as String?),
          routeId: $checkedConvert('route_id', (v) => (v as num?)?.toInt()),
          name: $checkedConvert('name', (v) => v as String?),
          renameActivities: $checkedConvert(
            'rename_activities',
            (v) => v as bool?,
          ),
          commute: $checkedConvert('commute', (v) => v as bool?),
          tags: $checkedConvert(
            'tags',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          description: $checkedConvert('description', (v) => v as String?),
          replacedByRouteId: $checkedConvert(
            'replaced_by_route_id',
            (v) => (v as num?)?.toInt(),
          ),
          latlngs: $checkedConvert(
            'latlngs',
            (v) => (v as List<dynamic>?)
                ?.map(
                  (e) => (e as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList(),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'athleteId': 'athlete_id',
        'routeId': 'route_id',
        'renameActivities': 'rename_activities',
        'replacedByRouteId': 'replaced_by_route_id',
      },
    );

Map<String, dynamic> _$AthleteRouteToJson(AthleteRoute instance) =>
    <String, dynamic>{
      'athlete_id': ?instance.athleteId,
      'route_id': ?instance.routeId,
      'name': ?instance.name,
      'rename_activities': ?instance.renameActivities,
      'commute': ?instance.commute,
      'tags': ?instance.tags,
      'description': ?instance.description,
      'replaced_by_route_id': ?instance.replacedByRouteId,
      'latlngs': ?instance.latlngs,
    };
