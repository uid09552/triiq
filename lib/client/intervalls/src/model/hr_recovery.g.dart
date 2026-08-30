// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_recovery.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HRRecoveryCWProxy {
  HRRecovery startIndex(int? startIndex);

  HRRecovery endIndex(int? endIndex);

  HRRecovery startTime(int? startTime);

  HRRecovery endTime(int? endTime);

  HRRecovery startBpm(int? startBpm);

  HRRecovery endBpm(int? endBpm);

  HRRecovery averageWatts(int? averageWatts);

  HRRecovery hrr(int? hrr);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HRRecovery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HRRecovery(...).copyWith(id: 12, name: "My name")
  /// ````
  HRRecovery call({
    int? startIndex,
    int? endIndex,
    int? startTime,
    int? endTime,
    int? startBpm,
    int? endBpm,
    int? averageWatts,
    int? hrr,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHRRecovery.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHRRecovery.copyWith.fieldName(...)`
class _$HRRecoveryCWProxyImpl implements _$HRRecoveryCWProxy {
  const _$HRRecoveryCWProxyImpl(this._value);

  final HRRecovery _value;

  @override
  HRRecovery startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  HRRecovery endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  HRRecovery startTime(int? startTime) => this(startTime: startTime);

  @override
  HRRecovery endTime(int? endTime) => this(endTime: endTime);

  @override
  HRRecovery startBpm(int? startBpm) => this(startBpm: startBpm);

  @override
  HRRecovery endBpm(int? endBpm) => this(endBpm: endBpm);

  @override
  HRRecovery averageWatts(int? averageWatts) =>
      this(averageWatts: averageWatts);

  @override
  HRRecovery hrr(int? hrr) => this(hrr: hrr);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HRRecovery(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HRRecovery(...).copyWith(id: 12, name: "My name")
  /// ````
  HRRecovery call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? endTime = const $CopyWithPlaceholder(),
    Object? startBpm = const $CopyWithPlaceholder(),
    Object? endBpm = const $CopyWithPlaceholder(),
    Object? averageWatts = const $CopyWithPlaceholder(),
    Object? hrr = const $CopyWithPlaceholder(),
  }) {
    return HRRecovery(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as int?,
      endTime: endTime == const $CopyWithPlaceholder()
          ? _value.endTime
          // ignore: cast_nullable_to_non_nullable
          : endTime as int?,
      startBpm: startBpm == const $CopyWithPlaceholder()
          ? _value.startBpm
          // ignore: cast_nullable_to_non_nullable
          : startBpm as int?,
      endBpm: endBpm == const $CopyWithPlaceholder()
          ? _value.endBpm
          // ignore: cast_nullable_to_non_nullable
          : endBpm as int?,
      averageWatts: averageWatts == const $CopyWithPlaceholder()
          ? _value.averageWatts
          // ignore: cast_nullable_to_non_nullable
          : averageWatts as int?,
      hrr: hrr == const $CopyWithPlaceholder()
          ? _value.hrr
          // ignore: cast_nullable_to_non_nullable
          : hrr as int?,
    );
  }
}

extension $HRRecoveryCopyWith on HRRecovery {
  /// Returns a callable class that can be used as follows: `instanceOfHRRecovery.copyWith(...)` or like so:`instanceOfHRRecovery.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HRRecoveryCWProxy get copyWith => _$HRRecoveryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HRRecovery _$HRRecoveryFromJson(Map<String, dynamic> json) => $checkedCreate(
  'HRRecovery',
  json,
  ($checkedConvert) {
    final val = HRRecovery(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      startTime: $checkedConvert('start_time', (v) => (v as num?)?.toInt()),
      endTime: $checkedConvert('end_time', (v) => (v as num?)?.toInt()),
      startBpm: $checkedConvert('start_bpm', (v) => (v as num?)?.toInt()),
      endBpm: $checkedConvert('end_bpm', (v) => (v as num?)?.toInt()),
      averageWatts: $checkedConvert(
        'average_watts',
        (v) => (v as num?)?.toInt(),
      ),
      hrr: $checkedConvert('hrr', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'startIndex': 'start_index',
    'endIndex': 'end_index',
    'startTime': 'start_time',
    'endTime': 'end_time',
    'startBpm': 'start_bpm',
    'endBpm': 'end_bpm',
    'averageWatts': 'average_watts',
  },
);

Map<String, dynamic> _$HRRecoveryToJson(HRRecovery instance) =>
    <String, dynamic>{
      'start_index': ?instance.startIndex,
      'end_index': ?instance.endIndex,
      'start_time': ?instance.startTime,
      'end_time': ?instance.endTime,
      'start_bpm': ?instance.startBpm,
      'end_bpm': ?instance.endBpm,
      'average_watts': ?instance.averageWatts,
      'hrr': ?instance.hrr,
    };
