// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'power_hr_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PowerHRCurveCWProxy {
  PowerHRCurve athleteId(String? athleteId);

  PowerHRCurve start(String? start);

  PowerHRCurve end(String? end);

  PowerHRCurve minWatts(int? minWatts);

  PowerHRCurve maxWatts(int? maxWatts);

  PowerHRCurve bucketSize(int? bucketSize);

  PowerHRCurve bpm(List<int>? bpm);

  PowerHRCurve cadence(List<int>? cadence);

  PowerHRCurve minutes(List<int>? minutes);

  PowerHRCurve lthr(int? lthr);

  PowerHRCurve maxHr(int? maxHr);

  PowerHRCurve ftp(int? ftp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PowerHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PowerHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  PowerHRCurve call({
    String? athleteId,
    String? start,
    String? end,
    int? minWatts,
    int? maxWatts,
    int? bucketSize,
    List<int>? bpm,
    List<int>? cadence,
    List<int>? minutes,
    int? lthr,
    int? maxHr,
    int? ftp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPowerHRCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPowerHRCurve.copyWith.fieldName(...)`
class _$PowerHRCurveCWProxyImpl implements _$PowerHRCurveCWProxy {
  const _$PowerHRCurveCWProxyImpl(this._value);

  final PowerHRCurve _value;

  @override
  PowerHRCurve athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  PowerHRCurve start(String? start) => this(start: start);

  @override
  PowerHRCurve end(String? end) => this(end: end);

  @override
  PowerHRCurve minWatts(int? minWatts) => this(minWatts: minWatts);

  @override
  PowerHRCurve maxWatts(int? maxWatts) => this(maxWatts: maxWatts);

  @override
  PowerHRCurve bucketSize(int? bucketSize) => this(bucketSize: bucketSize);

  @override
  PowerHRCurve bpm(List<int>? bpm) => this(bpm: bpm);

  @override
  PowerHRCurve cadence(List<int>? cadence) => this(cadence: cadence);

  @override
  PowerHRCurve minutes(List<int>? minutes) => this(minutes: minutes);

  @override
  PowerHRCurve lthr(int? lthr) => this(lthr: lthr);

  @override
  PowerHRCurve maxHr(int? maxHr) => this(maxHr: maxHr);

  @override
  PowerHRCurve ftp(int? ftp) => this(ftp: ftp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PowerHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PowerHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  PowerHRCurve call({
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? start = const $CopyWithPlaceholder(),
    Object? end = const $CopyWithPlaceholder(),
    Object? minWatts = const $CopyWithPlaceholder(),
    Object? maxWatts = const $CopyWithPlaceholder(),
    Object? bucketSize = const $CopyWithPlaceholder(),
    Object? bpm = const $CopyWithPlaceholder(),
    Object? cadence = const $CopyWithPlaceholder(),
    Object? minutes = const $CopyWithPlaceholder(),
    Object? lthr = const $CopyWithPlaceholder(),
    Object? maxHr = const $CopyWithPlaceholder(),
    Object? ftp = const $CopyWithPlaceholder(),
  }) {
    return PowerHRCurve(
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as String?,
      end: end == const $CopyWithPlaceholder()
          ? _value.end
          // ignore: cast_nullable_to_non_nullable
          : end as String?,
      minWatts: minWatts == const $CopyWithPlaceholder()
          ? _value.minWatts
          // ignore: cast_nullable_to_non_nullable
          : minWatts as int?,
      maxWatts: maxWatts == const $CopyWithPlaceholder()
          ? _value.maxWatts
          // ignore: cast_nullable_to_non_nullable
          : maxWatts as int?,
      bucketSize: bucketSize == const $CopyWithPlaceholder()
          ? _value.bucketSize
          // ignore: cast_nullable_to_non_nullable
          : bucketSize as int?,
      bpm: bpm == const $CopyWithPlaceholder()
          ? _value.bpm
          // ignore: cast_nullable_to_non_nullable
          : bpm as List<int>?,
      cadence: cadence == const $CopyWithPlaceholder()
          ? _value.cadence
          // ignore: cast_nullable_to_non_nullable
          : cadence as List<int>?,
      minutes: minutes == const $CopyWithPlaceholder()
          ? _value.minutes
          // ignore: cast_nullable_to_non_nullable
          : minutes as List<int>?,
      lthr: lthr == const $CopyWithPlaceholder()
          ? _value.lthr
          // ignore: cast_nullable_to_non_nullable
          : lthr as int?,
      maxHr: maxHr == const $CopyWithPlaceholder()
          ? _value.maxHr
          // ignore: cast_nullable_to_non_nullable
          : maxHr as int?,
      ftp: ftp == const $CopyWithPlaceholder()
          ? _value.ftp
          // ignore: cast_nullable_to_non_nullable
          : ftp as int?,
    );
  }
}

extension $PowerHRCurveCopyWith on PowerHRCurve {
  /// Returns a callable class that can be used as follows: `instanceOfPowerHRCurve.copyWith(...)` or like so:`instanceOfPowerHRCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PowerHRCurveCWProxy get copyWith => _$PowerHRCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PowerHRCurve _$PowerHRCurveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PowerHRCurve', json, ($checkedConvert) {
      final val = PowerHRCurve(
        athleteId: $checkedConvert('athleteId', (v) => v as String?),
        start: $checkedConvert('start', (v) => v as String?),
        end: $checkedConvert('end', (v) => v as String?),
        minWatts: $checkedConvert('minWatts', (v) => (v as num?)?.toInt()),
        maxWatts: $checkedConvert('maxWatts', (v) => (v as num?)?.toInt()),
        bucketSize: $checkedConvert('bucketSize', (v) => (v as num?)?.toInt()),
        bpm: $checkedConvert(
          'bpm',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        cadence: $checkedConvert(
          'cadence',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        minutes: $checkedConvert(
          'minutes',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        lthr: $checkedConvert('lthr', (v) => (v as num?)?.toInt()),
        maxHr: $checkedConvert('max_hr', (v) => (v as num?)?.toInt()),
        ftp: $checkedConvert('ftp', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'maxHr': 'max_hr'});

Map<String, dynamic> _$PowerHRCurveToJson(PowerHRCurve instance) =>
    <String, dynamic>{
      'athleteId': ?instance.athleteId,
      'start': ?instance.start,
      'end': ?instance.end,
      'minWatts': ?instance.minWatts,
      'maxWatts': ?instance.maxWatts,
      'bucketSize': ?instance.bucketSize,
      'bpm': ?instance.bpm,
      'cadence': ?instance.cadence,
      'minutes': ?instance.minutes,
      'lthr': ?instance.lthr,
      'max_hr': ?instance.maxHr,
      'ftp': ?instance.ftp,
    };
