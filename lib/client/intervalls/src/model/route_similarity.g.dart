// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_similarity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RouteSimilarityCWProxy {
  RouteSimilarity route(AthleteRoute? route);

  RouteSimilarity routeDistance(double? routeDistance);

  RouteSimilarity routeActivityCount(int? routeActivityCount);

  RouteSimilarity other(AthleteRoute? other);

  RouteSimilarity otherDistance(double? otherDistance);

  RouteSimilarity otherActivityCount(int? otherActivityCount);

  RouteSimilarity similarity(double? similarity);

  RouteSimilarity bounds(List<List<double>>? bounds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RouteSimilarity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RouteSimilarity(...).copyWith(id: 12, name: "My name")
  /// ````
  RouteSimilarity call({
    AthleteRoute? route,
    double? routeDistance,
    int? routeActivityCount,
    AthleteRoute? other,
    double? otherDistance,
    int? otherActivityCount,
    double? similarity,
    List<List<double>>? bounds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRouteSimilarity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRouteSimilarity.copyWith.fieldName(...)`
class _$RouteSimilarityCWProxyImpl implements _$RouteSimilarityCWProxy {
  const _$RouteSimilarityCWProxyImpl(this._value);

  final RouteSimilarity _value;

  @override
  RouteSimilarity route(AthleteRoute? route) => this(route: route);

  @override
  RouteSimilarity routeDistance(double? routeDistance) =>
      this(routeDistance: routeDistance);

  @override
  RouteSimilarity routeActivityCount(int? routeActivityCount) =>
      this(routeActivityCount: routeActivityCount);

  @override
  RouteSimilarity other(AthleteRoute? other) => this(other: other);

  @override
  RouteSimilarity otherDistance(double? otherDistance) =>
      this(otherDistance: otherDistance);

  @override
  RouteSimilarity otherActivityCount(int? otherActivityCount) =>
      this(otherActivityCount: otherActivityCount);

  @override
  RouteSimilarity similarity(double? similarity) =>
      this(similarity: similarity);

  @override
  RouteSimilarity bounds(List<List<double>>? bounds) => this(bounds: bounds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RouteSimilarity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RouteSimilarity(...).copyWith(id: 12, name: "My name")
  /// ````
  RouteSimilarity call({
    Object? route = const $CopyWithPlaceholder(),
    Object? routeDistance = const $CopyWithPlaceholder(),
    Object? routeActivityCount = const $CopyWithPlaceholder(),
    Object? other = const $CopyWithPlaceholder(),
    Object? otherDistance = const $CopyWithPlaceholder(),
    Object? otherActivityCount = const $CopyWithPlaceholder(),
    Object? similarity = const $CopyWithPlaceholder(),
    Object? bounds = const $CopyWithPlaceholder(),
  }) {
    return RouteSimilarity(
      route: route == const $CopyWithPlaceholder()
          ? _value.route
          // ignore: cast_nullable_to_non_nullable
          : route as AthleteRoute?,
      routeDistance: routeDistance == const $CopyWithPlaceholder()
          ? _value.routeDistance
          // ignore: cast_nullable_to_non_nullable
          : routeDistance as double?,
      routeActivityCount: routeActivityCount == const $CopyWithPlaceholder()
          ? _value.routeActivityCount
          // ignore: cast_nullable_to_non_nullable
          : routeActivityCount as int?,
      other: other == const $CopyWithPlaceholder()
          ? _value.other
          // ignore: cast_nullable_to_non_nullable
          : other as AthleteRoute?,
      otherDistance: otherDistance == const $CopyWithPlaceholder()
          ? _value.otherDistance
          // ignore: cast_nullable_to_non_nullable
          : otherDistance as double?,
      otherActivityCount: otherActivityCount == const $CopyWithPlaceholder()
          ? _value.otherActivityCount
          // ignore: cast_nullable_to_non_nullable
          : otherActivityCount as int?,
      similarity: similarity == const $CopyWithPlaceholder()
          ? _value.similarity
          // ignore: cast_nullable_to_non_nullable
          : similarity as double?,
      bounds: bounds == const $CopyWithPlaceholder()
          ? _value.bounds
          // ignore: cast_nullable_to_non_nullable
          : bounds as List<List<double>>?,
    );
  }
}

extension $RouteSimilarityCopyWith on RouteSimilarity {
  /// Returns a callable class that can be used as follows: `instanceOfRouteSimilarity.copyWith(...)` or like so:`instanceOfRouteSimilarity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RouteSimilarityCWProxy get copyWith => _$RouteSimilarityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteSimilarity _$RouteSimilarityFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RouteSimilarity',
  json,
  ($checkedConvert) {
    final val = RouteSimilarity(
      route: $checkedConvert(
        'route',
        (v) =>
            v == null ? null : AthleteRoute.fromJson(v as Map<String, dynamic>),
      ),
      routeDistance: $checkedConvert(
        'route_distance',
        (v) => (v as num?)?.toDouble(),
      ),
      routeActivityCount: $checkedConvert(
        'route_activity_count',
        (v) => (v as num?)?.toInt(),
      ),
      other: $checkedConvert(
        'other',
        (v) =>
            v == null ? null : AthleteRoute.fromJson(v as Map<String, dynamic>),
      ),
      otherDistance: $checkedConvert(
        'other_distance',
        (v) => (v as num?)?.toDouble(),
      ),
      otherActivityCount: $checkedConvert(
        'other_activity_count',
        (v) => (v as num?)?.toInt(),
      ),
      similarity: $checkedConvert('similarity', (v) => (v as num?)?.toDouble()),
      bounds: $checkedConvert(
        'bounds',
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
    'routeDistance': 'route_distance',
    'routeActivityCount': 'route_activity_count',
    'otherDistance': 'other_distance',
    'otherActivityCount': 'other_activity_count',
  },
);

Map<String, dynamic> _$RouteSimilarityToJson(RouteSimilarity instance) =>
    <String, dynamic>{
      'route': ?instance.route?.toJson(),
      'route_distance': ?instance.routeDistance,
      'route_activity_count': ?instance.routeActivityCount,
      'other': ?instance.other?.toJson(),
      'other_distance': ?instance.otherDistance,
      'other_activity_count': ?instance.otherActivityCount,
      'similarity': ?instance.similarity,
      'bounds': ?instance.bounds,
    };
