// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_training_plan_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteTrainingPlanUpdateCWProxy {
  AthleteTrainingPlanUpdate id(String? id);

  AthleteTrainingPlanUpdate trainingPlanId(int? trainingPlanId);

  AthleteTrainingPlanUpdate trainingPlanStartDate(
    String? trainingPlanStartDate,
  );

  AthleteTrainingPlanUpdate trainingPlanAlias(String? trainingPlanAlias);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingPlanUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingPlanUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingPlanUpdate call({
    String? id,
    int? trainingPlanId,
    String? trainingPlanStartDate,
    String? trainingPlanAlias,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteTrainingPlanUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteTrainingPlanUpdate.copyWith.fieldName(...)`
class _$AthleteTrainingPlanUpdateCWProxyImpl
    implements _$AthleteTrainingPlanUpdateCWProxy {
  const _$AthleteTrainingPlanUpdateCWProxyImpl(this._value);

  final AthleteTrainingPlanUpdate _value;

  @override
  AthleteTrainingPlanUpdate id(String? id) => this(id: id);

  @override
  AthleteTrainingPlanUpdate trainingPlanId(int? trainingPlanId) =>
      this(trainingPlanId: trainingPlanId);

  @override
  AthleteTrainingPlanUpdate trainingPlanStartDate(
    String? trainingPlanStartDate,
  ) => this(trainingPlanStartDate: trainingPlanStartDate);

  @override
  AthleteTrainingPlanUpdate trainingPlanAlias(String? trainingPlanAlias) =>
      this(trainingPlanAlias: trainingPlanAlias);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingPlanUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingPlanUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingPlanUpdate call({
    Object? id = const $CopyWithPlaceholder(),
    Object? trainingPlanId = const $CopyWithPlaceholder(),
    Object? trainingPlanStartDate = const $CopyWithPlaceholder(),
    Object? trainingPlanAlias = const $CopyWithPlaceholder(),
  }) {
    return AthleteTrainingPlanUpdate(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      trainingPlanId: trainingPlanId == const $CopyWithPlaceholder()
          ? _value.trainingPlanId
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanId as int?,
      trainingPlanStartDate:
          trainingPlanStartDate == const $CopyWithPlaceholder()
          ? _value.trainingPlanStartDate
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanStartDate as String?,
      trainingPlanAlias: trainingPlanAlias == const $CopyWithPlaceholder()
          ? _value.trainingPlanAlias
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanAlias as String?,
    );
  }
}

extension $AthleteTrainingPlanUpdateCopyWith on AthleteTrainingPlanUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteTrainingPlanUpdate.copyWith(...)` or like so:`instanceOfAthleteTrainingPlanUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteTrainingPlanUpdateCWProxy get copyWith =>
      _$AthleteTrainingPlanUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteTrainingPlanUpdate _$AthleteTrainingPlanUpdateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'AthleteTrainingPlanUpdate',
  json,
  ($checkedConvert) {
    final val = AthleteTrainingPlanUpdate(
      id: $checkedConvert('id', (v) => v as String?),
      trainingPlanId: $checkedConvert(
        'training_plan_id',
        (v) => (v as num?)?.toInt(),
      ),
      trainingPlanStartDate: $checkedConvert(
        'training_plan_start_date',
        (v) => v as String?,
      ),
      trainingPlanAlias: $checkedConvert(
        'training_plan_alias',
        (v) => v as String?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'trainingPlanId': 'training_plan_id',
    'trainingPlanStartDate': 'training_plan_start_date',
    'trainingPlanAlias': 'training_plan_alias',
  },
);

Map<String, dynamic> _$AthleteTrainingPlanUpdateToJson(
  AthleteTrainingPlanUpdate instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'training_plan_id': ?instance.trainingPlanId,
  'training_plan_start_date': ?instance.trainingPlanStartDate,
  'training_plan_alias': ?instance.trainingPlanAlias,
};
