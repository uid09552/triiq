// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HiddenCWProxy {
  Hidden id(String? id);

  Hidden icuAthleteId(String? icuAthleteId);

  Hidden startDateLocal(String? startDateLocal);

  Hidden source_(HiddenSource_Enum? source_);

  Hidden note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Hidden(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Hidden(...).copyWith(id: 12, name: "My name")
  /// ````
  Hidden call({
    String? id,
    String? icuAthleteId,
    String? startDateLocal,
    HiddenSource_Enum? source_,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHidden.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHidden.copyWith.fieldName(...)`
class _$HiddenCWProxyImpl implements _$HiddenCWProxy {
  const _$HiddenCWProxyImpl(this._value);

  final Hidden _value;

  @override
  Hidden id(String? id) => this(id: id);

  @override
  Hidden icuAthleteId(String? icuAthleteId) => this(icuAthleteId: icuAthleteId);

  @override
  Hidden startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  Hidden source_(HiddenSource_Enum? source_) => this(source_: source_);

  @override
  Hidden note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Hidden(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Hidden(...).copyWith(id: 12, name: "My name")
  /// ````
  Hidden call({
    Object? id = const $CopyWithPlaceholder(),
    Object? icuAthleteId = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return Hidden(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      icuAthleteId: icuAthleteId == const $CopyWithPlaceholder()
          ? _value.icuAthleteId
          // ignore: cast_nullable_to_non_nullable
          : icuAthleteId as String?,
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as HiddenSource_Enum?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $HiddenCopyWith on Hidden {
  /// Returns a callable class that can be used as follows: `instanceOfHidden.copyWith(...)` or like so:`instanceOfHidden.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HiddenCWProxy get copyWith => _$HiddenCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hidden _$HiddenFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Hidden',
  json,
  ($checkedConvert) {
    final val = Hidden(
      id: $checkedConvert('id', (v) => v as String?),
      icuAthleteId: $checkedConvert('icu_athlete_id', (v) => v as String?),
      startDateLocal: $checkedConvert('start_date_local', (v) => v as String?),
      source_: $checkedConvert(
        'source',
        (v) => $enumDecodeNullable(_$HiddenSource_EnumEnumMap, v),
      ),
      note: $checkedConvert('_note', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'icuAthleteId': 'icu_athlete_id',
    'startDateLocal': 'start_date_local',
    'source_': 'source',
    'note': '_note',
  },
);

Map<String, dynamic> _$HiddenToJson(Hidden instance) => <String, dynamic>{
  'id': ?instance.id,
  'icu_athlete_id': ?instance.icuAthleteId,
  'start_date_local': ?instance.startDateLocal,
  'source': ?_$HiddenSource_EnumEnumMap[instance.source_],
  '_note': ?instance.note,
};

const _$HiddenSource_EnumEnumMap = {
  HiddenSource_Enum.STRAVA: 'STRAVA',
  HiddenSource_Enum.UPLOAD: 'UPLOAD',
  HiddenSource_Enum.MANUAL: 'MANUAL',
  HiddenSource_Enum.GARMIN_CONNECT: 'GARMIN_CONNECT',
  HiddenSource_Enum.OAUTH_CLIENT: 'OAUTH_CLIENT',
  HiddenSource_Enum.DROPBOX: 'DROPBOX',
  HiddenSource_Enum.POLAR: 'POLAR',
  HiddenSource_Enum.SUUNTO: 'SUUNTO',
  HiddenSource_Enum.COROS: 'COROS',
  HiddenSource_Enum.WAHOO: 'WAHOO',
  HiddenSource_Enum.ZWIFT: 'ZWIFT',
  HiddenSource_Enum.ZEPP: 'ZEPP',
  HiddenSource_Enum.CONCEPT2: 'CONCEPT2',
  HiddenSource_Enum.HUAWEI: 'HUAWEI',
};
