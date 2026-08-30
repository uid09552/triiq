// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_hr_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityHRCurveCWProxy {
  ActivityHRCurve id(String? id);

  ActivityHRCurve startDateLocal(String? startDateLocal);

  ActivityHRCurve weight(double? weight);

  ActivityHRCurve bpm(List<int>? bpm);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityHRCurve call({
    String? id,
    String? startDateLocal,
    double? weight,
    List<int>? bpm,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityHRCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityHRCurve.copyWith.fieldName(...)`
class _$ActivityHRCurveCWProxyImpl implements _$ActivityHRCurveCWProxy {
  const _$ActivityHRCurveCWProxyImpl(this._value);

  final ActivityHRCurve _value;

  @override
  ActivityHRCurve id(String? id) => this(id: id);

  @override
  ActivityHRCurve startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  ActivityHRCurve weight(double? weight) => this(weight: weight);

  @override
  ActivityHRCurve bpm(List<int>? bpm) => this(bpm: bpm);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityHRCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityHRCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityHRCurve call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? bpm = const $CopyWithPlaceholder(),
  }) {
    return ActivityHRCurve(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      weight: weight == const $CopyWithPlaceholder()
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as double?,
      bpm: bpm == const $CopyWithPlaceholder()
          ? _value.bpm
          // ignore: cast_nullable_to_non_nullable
          : bpm as List<int>?,
    );
  }
}

extension $ActivityHRCurveCopyWith on ActivityHRCurve {
  /// Returns a callable class that can be used as follows: `instanceOfActivityHRCurve.copyWith(...)` or like so:`instanceOfActivityHRCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityHRCurveCWProxy get copyWith => _$ActivityHRCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityHRCurve _$ActivityHRCurveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityHRCurve', json, ($checkedConvert) {
      final val = ActivityHRCurve(
        id: $checkedConvert('id', (v) => v as String?),
        startDateLocal: $checkedConvert(
          'start_date_local',
          (v) => v as String?,
        ),
        weight: $checkedConvert('weight', (v) => (v as num?)?.toDouble()),
        bpm: $checkedConvert(
          'bpm',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'startDateLocal': 'start_date_local'});

Map<String, dynamic> _$ActivityHRCurveToJson(ActivityHRCurve instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'start_date_local': ?instance.startDateLocal,
      'weight': ?instance.weight,
      'bpm': ?instance.bpm,
    };
