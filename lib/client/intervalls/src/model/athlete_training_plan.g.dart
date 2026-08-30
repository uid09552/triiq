// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_training_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteTrainingPlanCWProxy {
  AthleteTrainingPlan athleteId(String? athleteId);

  AthleteTrainingPlan trainingPlanId(int? trainingPlanId);

  AthleteTrainingPlan trainingPlanStartDate(String? trainingPlanStartDate);

  AthleteTrainingPlan timezone(String? timezone);

  AthleteTrainingPlan trainingPlanLastApplied(
    DateTime? trainingPlanLastApplied,
  );

  AthleteTrainingPlan trainingPlan(Folder? trainingPlan);

  AthleteTrainingPlan trainingPlanAlias(String? trainingPlanAlias);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingPlan call({
    String? athleteId,
    int? trainingPlanId,
    String? trainingPlanStartDate,
    String? timezone,
    DateTime? trainingPlanLastApplied,
    Folder? trainingPlan,
    String? trainingPlanAlias,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteTrainingPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteTrainingPlan.copyWith.fieldName(...)`
class _$AthleteTrainingPlanCWProxyImpl implements _$AthleteTrainingPlanCWProxy {
  const _$AthleteTrainingPlanCWProxyImpl(this._value);

  final AthleteTrainingPlan _value;

  @override
  AthleteTrainingPlan athleteId(String? athleteId) =>
      this(athleteId: athleteId);

  @override
  AthleteTrainingPlan trainingPlanId(int? trainingPlanId) =>
      this(trainingPlanId: trainingPlanId);

  @override
  AthleteTrainingPlan trainingPlanStartDate(String? trainingPlanStartDate) =>
      this(trainingPlanStartDate: trainingPlanStartDate);

  @override
  AthleteTrainingPlan timezone(String? timezone) => this(timezone: timezone);

  @override
  AthleteTrainingPlan trainingPlanLastApplied(
    DateTime? trainingPlanLastApplied,
  ) => this(trainingPlanLastApplied: trainingPlanLastApplied);

  @override
  AthleteTrainingPlan trainingPlan(Folder? trainingPlan) =>
      this(trainingPlan: trainingPlan);

  @override
  AthleteTrainingPlan trainingPlanAlias(String? trainingPlanAlias) =>
      this(trainingPlanAlias: trainingPlanAlias);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteTrainingPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteTrainingPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteTrainingPlan call({
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? trainingPlanId = const $CopyWithPlaceholder(),
    Object? trainingPlanStartDate = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? trainingPlanLastApplied = const $CopyWithPlaceholder(),
    Object? trainingPlan = const $CopyWithPlaceholder(),
    Object? trainingPlanAlias = const $CopyWithPlaceholder(),
  }) {
    return AthleteTrainingPlan(
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      trainingPlanId: trainingPlanId == const $CopyWithPlaceholder()
          ? _value.trainingPlanId
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanId as int?,
      trainingPlanStartDate:
          trainingPlanStartDate == const $CopyWithPlaceholder()
          ? _value.trainingPlanStartDate
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanStartDate as String?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      trainingPlanLastApplied:
          trainingPlanLastApplied == const $CopyWithPlaceholder()
          ? _value.trainingPlanLastApplied
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanLastApplied as DateTime?,
      trainingPlan: trainingPlan == const $CopyWithPlaceholder()
          ? _value.trainingPlan
          // ignore: cast_nullable_to_non_nullable
          : trainingPlan as Folder?,
      trainingPlanAlias: trainingPlanAlias == const $CopyWithPlaceholder()
          ? _value.trainingPlanAlias
          // ignore: cast_nullable_to_non_nullable
          : trainingPlanAlias as String?,
    );
  }
}

extension $AthleteTrainingPlanCopyWith on AthleteTrainingPlan {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteTrainingPlan.copyWith(...)` or like so:`instanceOfAthleteTrainingPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteTrainingPlanCWProxy get copyWith =>
      _$AthleteTrainingPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteTrainingPlan _$AthleteTrainingPlanFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AthleteTrainingPlan',
      json,
      ($checkedConvert) {
        final val = AthleteTrainingPlan(
          athleteId: $checkedConvert('athlete_id', (v) => v as String?),
          trainingPlanId: $checkedConvert(
            'training_plan_id',
            (v) => (v as num?)?.toInt(),
          ),
          trainingPlanStartDate: $checkedConvert(
            'training_plan_start_date',
            (v) => v as String?,
          ),
          timezone: $checkedConvert('timezone', (v) => v as String?),
          trainingPlanLastApplied: $checkedConvert(
            'training_plan_last_applied',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          trainingPlan: $checkedConvert(
            'training_plan',
            (v) =>
                v == null ? null : Folder.fromJson(v as Map<String, dynamic>),
          ),
          trainingPlanAlias: $checkedConvert(
            'training_plan_alias',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'athleteId': 'athlete_id',
        'trainingPlanId': 'training_plan_id',
        'trainingPlanStartDate': 'training_plan_start_date',
        'trainingPlanLastApplied': 'training_plan_last_applied',
        'trainingPlan': 'training_plan',
        'trainingPlanAlias': 'training_plan_alias',
      },
    );

Map<String, dynamic> _$AthleteTrainingPlanToJson(
  AthleteTrainingPlan instance,
) => <String, dynamic>{
  'athlete_id': ?instance.athleteId,
  'training_plan_id': ?instance.trainingPlanId,
  'training_plan_start_date': ?instance.trainingPlanStartDate,
  'timezone': ?instance.timezone,
  'training_plan_last_applied': ?instance.trainingPlanLastApplied
      ?.toIso8601String(),
  'training_plan': ?instance.trainingPlan?.toJson(),
  'training_plan_alias': ?instance.trainingPlanAlias,
};
