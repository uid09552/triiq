// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_plan_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApplyPlanDTOCWProxy {
  ApplyPlanDTO startDateLocal(String? startDateLocal);

  ApplyPlanDTO folderId(int? folderId);

  ApplyPlanDTO extraWorkouts(List<Workout>? extraWorkouts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyPlanDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyPlanDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyPlanDTO call({
    String? startDateLocal,
    int? folderId,
    List<Workout>? extraWorkouts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApplyPlanDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApplyPlanDTO.copyWith.fieldName(...)`
class _$ApplyPlanDTOCWProxyImpl implements _$ApplyPlanDTOCWProxy {
  const _$ApplyPlanDTOCWProxyImpl(this._value);

  final ApplyPlanDTO _value;

  @override
  ApplyPlanDTO startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  ApplyPlanDTO folderId(int? folderId) => this(folderId: folderId);

  @override
  ApplyPlanDTO extraWorkouts(List<Workout>? extraWorkouts) =>
      this(extraWorkouts: extraWorkouts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyPlanDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyPlanDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyPlanDTO call({
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? folderId = const $CopyWithPlaceholder(),
    Object? extraWorkouts = const $CopyWithPlaceholder(),
  }) {
    return ApplyPlanDTO(
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      folderId: folderId == const $CopyWithPlaceholder()
          ? _value.folderId
          // ignore: cast_nullable_to_non_nullable
          : folderId as int?,
      extraWorkouts: extraWorkouts == const $CopyWithPlaceholder()
          ? _value.extraWorkouts
          // ignore: cast_nullable_to_non_nullable
          : extraWorkouts as List<Workout>?,
    );
  }
}

extension $ApplyPlanDTOCopyWith on ApplyPlanDTO {
  /// Returns a callable class that can be used as follows: `instanceOfApplyPlanDTO.copyWith(...)` or like so:`instanceOfApplyPlanDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApplyPlanDTOCWProxy get copyWith => _$ApplyPlanDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyPlanDTO _$ApplyPlanDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ApplyPlanDTO',
      json,
      ($checkedConvert) {
        final val = ApplyPlanDTO(
          startDateLocal: $checkedConvert(
            'start_date_local',
            (v) => v as String?,
          ),
          folderId: $checkedConvert('folder_id', (v) => (v as num?)?.toInt()),
          extraWorkouts: $checkedConvert(
            'extra_workouts',
            (v) => (v as List<dynamic>?)
                ?.map((e) => Workout.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'startDateLocal': 'start_date_local',
        'folderId': 'folder_id',
        'extraWorkouts': 'extra_workouts',
      },
    );

Map<String, dynamic> _$ApplyPlanDTOToJson(
  ApplyPlanDTO instance,
) => <String, dynamic>{
  'start_date_local': ?instance.startDateLocal,
  'folder_id': ?instance.folderId,
  'extra_workouts': ?instance.extraWorkouts?.map((e) => e.toJson()).toList(),
};
