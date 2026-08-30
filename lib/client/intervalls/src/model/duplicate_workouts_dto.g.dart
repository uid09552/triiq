// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_workouts_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DuplicateWorkoutsDTOCWProxy {
  DuplicateWorkoutsDTO numCopies(int? numCopies);

  DuplicateWorkoutsDTO weeksBetween(int? weeksBetween);

  DuplicateWorkoutsDTO workoutIds(List<int>? workoutIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DuplicateWorkoutsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DuplicateWorkoutsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  DuplicateWorkoutsDTO call({
    int? numCopies,
    int? weeksBetween,
    List<int>? workoutIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDuplicateWorkoutsDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDuplicateWorkoutsDTO.copyWith.fieldName(...)`
class _$DuplicateWorkoutsDTOCWProxyImpl
    implements _$DuplicateWorkoutsDTOCWProxy {
  const _$DuplicateWorkoutsDTOCWProxyImpl(this._value);

  final DuplicateWorkoutsDTO _value;

  @override
  DuplicateWorkoutsDTO numCopies(int? numCopies) => this(numCopies: numCopies);

  @override
  DuplicateWorkoutsDTO weeksBetween(int? weeksBetween) =>
      this(weeksBetween: weeksBetween);

  @override
  DuplicateWorkoutsDTO workoutIds(List<int>? workoutIds) =>
      this(workoutIds: workoutIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DuplicateWorkoutsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DuplicateWorkoutsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  DuplicateWorkoutsDTO call({
    Object? numCopies = const $CopyWithPlaceholder(),
    Object? weeksBetween = const $CopyWithPlaceholder(),
    Object? workoutIds = const $CopyWithPlaceholder(),
  }) {
    return DuplicateWorkoutsDTO(
      numCopies: numCopies == const $CopyWithPlaceholder()
          ? _value.numCopies
          // ignore: cast_nullable_to_non_nullable
          : numCopies as int?,
      weeksBetween: weeksBetween == const $CopyWithPlaceholder()
          ? _value.weeksBetween
          // ignore: cast_nullable_to_non_nullable
          : weeksBetween as int?,
      workoutIds: workoutIds == const $CopyWithPlaceholder()
          ? _value.workoutIds
          // ignore: cast_nullable_to_non_nullable
          : workoutIds as List<int>?,
    );
  }
}

extension $DuplicateWorkoutsDTOCopyWith on DuplicateWorkoutsDTO {
  /// Returns a callable class that can be used as follows: `instanceOfDuplicateWorkoutsDTO.copyWith(...)` or like so:`instanceOfDuplicateWorkoutsDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DuplicateWorkoutsDTOCWProxy get copyWith =>
      _$DuplicateWorkoutsDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuplicateWorkoutsDTO _$DuplicateWorkoutsDTOFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DuplicateWorkoutsDTO', json, ($checkedConvert) {
  final val = DuplicateWorkoutsDTO(
    numCopies: $checkedConvert('numCopies', (v) => (v as num?)?.toInt()),
    weeksBetween: $checkedConvert('weeksBetween', (v) => (v as num?)?.toInt()),
    workoutIds: $checkedConvert(
      'workoutIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DuplicateWorkoutsDTOToJson(
  DuplicateWorkoutsDTO instance,
) => <String, dynamic>{
  'numCopies': ?instance.numCopies,
  'weeksBetween': ?instance.weeksBetween,
  'workoutIds': ?instance.workoutIds,
};
