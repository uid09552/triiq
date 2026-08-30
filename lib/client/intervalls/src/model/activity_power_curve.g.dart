// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_power_curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityPowerCurveCWProxy {
  ActivityPowerCurve id(String? id);

  ActivityPowerCurve startDateLocal(String? startDateLocal);

  ActivityPowerCurve weight(double? weight);

  ActivityPowerCurve watts(List<int>? watts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityPowerCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityPowerCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityPowerCurve call({
    String? id,
    String? startDateLocal,
    double? weight,
    List<int>? watts,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityPowerCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityPowerCurve.copyWith.fieldName(...)`
class _$ActivityPowerCurveCWProxyImpl implements _$ActivityPowerCurveCWProxy {
  const _$ActivityPowerCurveCWProxyImpl(this._value);

  final ActivityPowerCurve _value;

  @override
  ActivityPowerCurve id(String? id) => this(id: id);

  @override
  ActivityPowerCurve startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  ActivityPowerCurve weight(double? weight) => this(weight: weight);

  @override
  ActivityPowerCurve watts(List<int>? watts) => this(watts: watts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityPowerCurve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityPowerCurve(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityPowerCurve call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? watts = const $CopyWithPlaceholder(),
  }) {
    return ActivityPowerCurve(
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
      watts: watts == const $CopyWithPlaceholder()
          ? _value.watts
          // ignore: cast_nullable_to_non_nullable
          : watts as List<int>?,
    );
  }
}

extension $ActivityPowerCurveCopyWith on ActivityPowerCurve {
  /// Returns a callable class that can be used as follows: `instanceOfActivityPowerCurve.copyWith(...)` or like so:`instanceOfActivityPowerCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityPowerCurveCWProxy get copyWith =>
      _$ActivityPowerCurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityPowerCurve _$ActivityPowerCurveFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ActivityPowerCurve',
      json,
      ($checkedConvert) {
        final val = ActivityPowerCurve(
          id: $checkedConvert('id', (v) => v as String?),
          startDateLocal: $checkedConvert(
            'start_date_local',
            (v) => v as String?,
          ),
          weight: $checkedConvert('weight', (v) => (v as num?)?.toDouble()),
          watts: $checkedConvert(
            'watts',
            (v) =>
                (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'startDateLocal': 'start_date_local'},
    );

Map<String, dynamic> _$ActivityPowerCurveToJson(ActivityPowerCurve instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'start_date_local': ?instance.startDateLocal,
      'weight': ?instance.weight,
      'watts': ?instance.watts,
    };
