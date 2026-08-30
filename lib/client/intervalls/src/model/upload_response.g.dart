// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadResponseCWProxy {
  UploadResponse icuAthleteId(String? icuAthleteId);

  UploadResponse id(String? id);

  UploadResponse activities(List<ActivityId>? activities);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadResponse call({
    String? icuAthleteId,
    String? id,
    List<ActivityId>? activities,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadResponse.copyWith.fieldName(...)`
class _$UploadResponseCWProxyImpl implements _$UploadResponseCWProxy {
  const _$UploadResponseCWProxyImpl(this._value);

  final UploadResponse _value;

  @override
  UploadResponse icuAthleteId(String? icuAthleteId) =>
      this(icuAthleteId: icuAthleteId);

  @override
  UploadResponse id(String? id) => this(id: id);

  @override
  UploadResponse activities(List<ActivityId>? activities) =>
      this(activities: activities);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadResponse call({
    Object? icuAthleteId = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
  }) {
    return UploadResponse(
      icuAthleteId: icuAthleteId == const $CopyWithPlaceholder()
          ? _value.icuAthleteId
          // ignore: cast_nullable_to_non_nullable
          : icuAthleteId as String?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      activities: activities == const $CopyWithPlaceholder()
          ? _value.activities
          // ignore: cast_nullable_to_non_nullable
          : activities as List<ActivityId>?,
    );
  }
}

extension $UploadResponseCopyWith on UploadResponse {
  /// Returns a callable class that can be used as follows: `instanceOfUploadResponse.copyWith(...)` or like so:`instanceOfUploadResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadResponseCWProxy get copyWith => _$UploadResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadResponse _$UploadResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UploadResponse', json, ($checkedConvert) {
      final val = UploadResponse(
        icuAthleteId: $checkedConvert('icu_athlete_id', (v) => v as String?),
        id: $checkedConvert('id', (v) => v as String?),
        activities: $checkedConvert(
          'activities',
          (v) => (v as List<dynamic>?)
              ?.map((e) => ActivityId.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'icuAthleteId': 'icu_athlete_id'});

Map<String, dynamic> _$UploadResponseToJson(UploadResponse instance) =>
    <String, dynamic>{
      'icu_athlete_id': ?instance.icuAthleteId,
      'id': ?instance.id,
      'activities': ?instance.activities?.map((e) => e.toJson()).toList(),
    };
