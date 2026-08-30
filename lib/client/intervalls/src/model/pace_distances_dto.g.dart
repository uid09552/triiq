// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pace_distances_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaceDistancesDTOCWProxy {
  PaceDistancesDTO distances(List<double>? distances);

  PaceDistancesDTO defaults(List<double>? defaults);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceDistancesDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceDistancesDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceDistancesDTO call({List<double>? distances, List<double>? defaults});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaceDistancesDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaceDistancesDTO.copyWith.fieldName(...)`
class _$PaceDistancesDTOCWProxyImpl implements _$PaceDistancesDTOCWProxy {
  const _$PaceDistancesDTOCWProxyImpl(this._value);

  final PaceDistancesDTO _value;

  @override
  PaceDistancesDTO distances(List<double>? distances) =>
      this(distances: distances);

  @override
  PaceDistancesDTO defaults(List<double>? defaults) => this(defaults: defaults);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceDistancesDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceDistancesDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceDistancesDTO call({
    Object? distances = const $CopyWithPlaceholder(),
    Object? defaults = const $CopyWithPlaceholder(),
  }) {
    return PaceDistancesDTO(
      distances: distances == const $CopyWithPlaceholder()
          ? _value.distances
          // ignore: cast_nullable_to_non_nullable
          : distances as List<double>?,
      defaults: defaults == const $CopyWithPlaceholder()
          ? _value.defaults
          // ignore: cast_nullable_to_non_nullable
          : defaults as List<double>?,
    );
  }
}

extension $PaceDistancesDTOCopyWith on PaceDistancesDTO {
  /// Returns a callable class that can be used as follows: `instanceOfPaceDistancesDTO.copyWith(...)` or like so:`instanceOfPaceDistancesDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaceDistancesDTOCWProxy get copyWith => _$PaceDistancesDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaceDistancesDTO _$PaceDistancesDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaceDistancesDTO', json, ($checkedConvert) {
      final val = PaceDistancesDTO(
        distances: $checkedConvert(
          'distances',
          (v) =>
              (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
        ),
        defaults: $checkedConvert(
          'defaults',
          (v) =>
              (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PaceDistancesDTOToJson(PaceDistancesDTO instance) =>
    <String, dynamic>{
      'distances': ?instance.distances,
      'defaults': ?instance.defaults,
    };
