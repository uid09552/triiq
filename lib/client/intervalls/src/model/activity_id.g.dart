// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_id.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityIdCWProxy {
  ActivityId icuAthleteId(String? icuAthleteId);

  ActivityId id(String? id);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityId(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityId(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityId call({String? icuAthleteId, String? id});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityId.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityId.copyWith.fieldName(...)`
class _$ActivityIdCWProxyImpl implements _$ActivityIdCWProxy {
  const _$ActivityIdCWProxyImpl(this._value);

  final ActivityId _value;

  @override
  ActivityId icuAthleteId(String? icuAthleteId) =>
      this(icuAthleteId: icuAthleteId);

  @override
  ActivityId id(String? id) => this(id: id);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityId(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityId(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityId call({
    Object? icuAthleteId = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
  }) {
    return ActivityId(
      icuAthleteId: icuAthleteId == const $CopyWithPlaceholder()
          ? _value.icuAthleteId
          // ignore: cast_nullable_to_non_nullable
          : icuAthleteId as String?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
    );
  }
}

extension $ActivityIdCopyWith on ActivityId {
  /// Returns a callable class that can be used as follows: `instanceOfActivityId.copyWith(...)` or like so:`instanceOfActivityId.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityIdCWProxy get copyWith => _$ActivityIdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityId _$ActivityIdFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityId', json, ($checkedConvert) {
      final val = ActivityId(
        icuAthleteId: $checkedConvert('icu_athlete_id', (v) => v as String?),
        id: $checkedConvert('id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'icuAthleteId': 'icu_athlete_id'});

Map<String, dynamic> _$ActivityIdToJson(ActivityId instance) =>
    <String, dynamic>{
      'icu_athlete_id': ?instance.icuAthleteId,
      'id': ?instance.id,
    };
