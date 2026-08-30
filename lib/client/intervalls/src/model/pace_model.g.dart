// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pace_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaceModelCWProxy {
  PaceModel type(PaceModelTypeEnum? type);

  PaceModel criticalSpeed(double? criticalSpeed);

  PaceModel dPrime(double? dPrime);

  PaceModel r2(double? r2);

  PaceModel inputPointIndexes(List<int>? inputPointIndexes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceModel call({
    PaceModelTypeEnum? type,
    double? criticalSpeed,
    double? dPrime,
    double? r2,
    List<int>? inputPointIndexes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaceModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaceModel.copyWith.fieldName(...)`
class _$PaceModelCWProxyImpl implements _$PaceModelCWProxy {
  const _$PaceModelCWProxyImpl(this._value);

  final PaceModel _value;

  @override
  PaceModel type(PaceModelTypeEnum? type) => this(type: type);

  @override
  PaceModel criticalSpeed(double? criticalSpeed) =>
      this(criticalSpeed: criticalSpeed);

  @override
  PaceModel dPrime(double? dPrime) => this(dPrime: dPrime);

  @override
  PaceModel r2(double? r2) => this(r2: r2);

  @override
  PaceModel inputPointIndexes(List<int>? inputPointIndexes) =>
      this(inputPointIndexes: inputPointIndexes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaceModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaceModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PaceModel call({
    Object? type = const $CopyWithPlaceholder(),
    Object? criticalSpeed = const $CopyWithPlaceholder(),
    Object? dPrime = const $CopyWithPlaceholder(),
    Object? r2 = const $CopyWithPlaceholder(),
    Object? inputPointIndexes = const $CopyWithPlaceholder(),
  }) {
    return PaceModel(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PaceModelTypeEnum?,
      criticalSpeed: criticalSpeed == const $CopyWithPlaceholder()
          ? _value.criticalSpeed
          // ignore: cast_nullable_to_non_nullable
          : criticalSpeed as double?,
      dPrime: dPrime == const $CopyWithPlaceholder()
          ? _value.dPrime
          // ignore: cast_nullable_to_non_nullable
          : dPrime as double?,
      r2: r2 == const $CopyWithPlaceholder()
          ? _value.r2
          // ignore: cast_nullable_to_non_nullable
          : r2 as double?,
      inputPointIndexes: inputPointIndexes == const $CopyWithPlaceholder()
          ? _value.inputPointIndexes
          // ignore: cast_nullable_to_non_nullable
          : inputPointIndexes as List<int>?,
    );
  }
}

extension $PaceModelCopyWith on PaceModel {
  /// Returns a callable class that can be used as follows: `instanceOfPaceModel.copyWith(...)` or like so:`instanceOfPaceModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaceModelCWProxy get copyWith => _$PaceModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaceModel _$PaceModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaceModel', json, ($checkedConvert) {
      final val = PaceModel(
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$PaceModelTypeEnumEnumMap, v),
        ),
        criticalSpeed: $checkedConvert(
          'criticalSpeed',
          (v) => (v as num?)?.toDouble(),
        ),
        dPrime: $checkedConvert('dPrime', (v) => (v as num?)?.toDouble()),
        r2: $checkedConvert('r2', (v) => (v as num?)?.toDouble()),
        inputPointIndexes: $checkedConvert(
          'inputPointIndexes',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PaceModelToJson(PaceModel instance) => <String, dynamic>{
  'type': ?_$PaceModelTypeEnumEnumMap[instance.type],
  'criticalSpeed': ?instance.criticalSpeed,
  'dPrime': ?instance.dPrime,
  'r2': ?instance.r2,
  'inputPointIndexes': ?instance.inputPointIndexes,
};

const _$PaceModelTypeEnumEnumMap = {PaceModelTypeEnum.CS: 'CS'};
