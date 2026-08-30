// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icu_achievement.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IcuAchievementCWProxy {
  IcuAchievement id(String? id);

  IcuAchievement type(IcuAchievementTypeEnum? type);

  IcuAchievement message(String? message);

  IcuAchievement watts(int? watts);

  IcuAchievement secs(int? secs);

  IcuAchievement value(int? value);

  IcuAchievement distance(double? distance);

  IcuAchievement pace(double? pace);

  IcuAchievement point(DataCurvePt? point);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IcuAchievement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IcuAchievement(...).copyWith(id: 12, name: "My name")
  /// ````
  IcuAchievement call({
    String? id,
    IcuAchievementTypeEnum? type,
    String? message,
    int? watts,
    int? secs,
    int? value,
    double? distance,
    double? pace,
    DataCurvePt? point,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIcuAchievement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIcuAchievement.copyWith.fieldName(...)`
class _$IcuAchievementCWProxyImpl implements _$IcuAchievementCWProxy {
  const _$IcuAchievementCWProxyImpl(this._value);

  final IcuAchievement _value;

  @override
  IcuAchievement id(String? id) => this(id: id);

  @override
  IcuAchievement type(IcuAchievementTypeEnum? type) => this(type: type);

  @override
  IcuAchievement message(String? message) => this(message: message);

  @override
  IcuAchievement watts(int? watts) => this(watts: watts);

  @override
  IcuAchievement secs(int? secs) => this(secs: secs);

  @override
  IcuAchievement value(int? value) => this(value: value);

  @override
  IcuAchievement distance(double? distance) => this(distance: distance);

  @override
  IcuAchievement pace(double? pace) => this(pace: pace);

  @override
  IcuAchievement point(DataCurvePt? point) => this(point: point);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IcuAchievement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IcuAchievement(...).copyWith(id: 12, name: "My name")
  /// ````
  IcuAchievement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? watts = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? pace = const $CopyWithPlaceholder(),
    Object? point = const $CopyWithPlaceholder(),
  }) {
    return IcuAchievement(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as IcuAchievementTypeEnum?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      watts: watts == const $CopyWithPlaceholder()
          ? _value.watts
          // ignore: cast_nullable_to_non_nullable
          : watts as int?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as int?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as int?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      pace: pace == const $CopyWithPlaceholder()
          ? _value.pace
          // ignore: cast_nullable_to_non_nullable
          : pace as double?,
      point: point == const $CopyWithPlaceholder()
          ? _value.point
          // ignore: cast_nullable_to_non_nullable
          : point as DataCurvePt?,
    );
  }
}

extension $IcuAchievementCopyWith on IcuAchievement {
  /// Returns a callable class that can be used as follows: `instanceOfIcuAchievement.copyWith(...)` or like so:`instanceOfIcuAchievement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IcuAchievementCWProxy get copyWith => _$IcuAchievementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcuAchievement _$IcuAchievementFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IcuAchievement', json, ($checkedConvert) {
      final val = IcuAchievement(
        id: $checkedConvert('id', (v) => v as String?),
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$IcuAchievementTypeEnumEnumMap, v),
        ),
        message: $checkedConvert('message', (v) => v as String?),
        watts: $checkedConvert('watts', (v) => (v as num?)?.toInt()),
        secs: $checkedConvert('secs', (v) => (v as num?)?.toInt()),
        value: $checkedConvert('value', (v) => (v as num?)?.toInt()),
        distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
        pace: $checkedConvert('pace', (v) => (v as num?)?.toDouble()),
        point: $checkedConvert(
          'point',
          (v) => v == null
              ? null
              : DataCurvePt.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$IcuAchievementToJson(IcuAchievement instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'type': ?_$IcuAchievementTypeEnumEnumMap[instance.type],
      'message': ?instance.message,
      'watts': ?instance.watts,
      'secs': ?instance.secs,
      'value': ?instance.value,
      'distance': ?instance.distance,
      'pace': ?instance.pace,
      'point': ?instance.point?.toJson(),
    };

const _$IcuAchievementTypeEnumEnumMap = {
  IcuAchievementTypeEnum.BEST_POWER: 'BEST_POWER',
  IcuAchievementTypeEnum.FTP_UP: 'FTP_UP',
  IcuAchievementTypeEnum.LTHR_UP: 'LTHR_UP',
  IcuAchievementTypeEnum.BEST_PACE: 'BEST_PACE',
};
