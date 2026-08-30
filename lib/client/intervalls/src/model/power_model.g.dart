// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'power_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PowerModelCWProxy {
  PowerModel type(PowerModelTypeEnum? type);

  PowerModel criticalPower(int? criticalPower);

  PowerModel wPrime(int? wPrime);

  PowerModel pMax(int? pMax);

  PowerModel inputPointIndexes(List<int>? inputPointIndexes);

  PowerModel ftp(int? ftp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PowerModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PowerModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PowerModel call({
    PowerModelTypeEnum? type,
    int? criticalPower,
    int? wPrime,
    int? pMax,
    List<int>? inputPointIndexes,
    int? ftp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPowerModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPowerModel.copyWith.fieldName(...)`
class _$PowerModelCWProxyImpl implements _$PowerModelCWProxy {
  const _$PowerModelCWProxyImpl(this._value);

  final PowerModel _value;

  @override
  PowerModel type(PowerModelTypeEnum? type) => this(type: type);

  @override
  PowerModel criticalPower(int? criticalPower) =>
      this(criticalPower: criticalPower);

  @override
  PowerModel wPrime(int? wPrime) => this(wPrime: wPrime);

  @override
  PowerModel pMax(int? pMax) => this(pMax: pMax);

  @override
  PowerModel inputPointIndexes(List<int>? inputPointIndexes) =>
      this(inputPointIndexes: inputPointIndexes);

  @override
  PowerModel ftp(int? ftp) => this(ftp: ftp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PowerModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PowerModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PowerModel call({
    Object? type = const $CopyWithPlaceholder(),
    Object? criticalPower = const $CopyWithPlaceholder(),
    Object? wPrime = const $CopyWithPlaceholder(),
    Object? pMax = const $CopyWithPlaceholder(),
    Object? inputPointIndexes = const $CopyWithPlaceholder(),
    Object? ftp = const $CopyWithPlaceholder(),
  }) {
    return PowerModel(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as PowerModelTypeEnum?,
      criticalPower: criticalPower == const $CopyWithPlaceholder()
          ? _value.criticalPower
          // ignore: cast_nullable_to_non_nullable
          : criticalPower as int?,
      wPrime: wPrime == const $CopyWithPlaceholder()
          ? _value.wPrime
          // ignore: cast_nullable_to_non_nullable
          : wPrime as int?,
      pMax: pMax == const $CopyWithPlaceholder()
          ? _value.pMax
          // ignore: cast_nullable_to_non_nullable
          : pMax as int?,
      inputPointIndexes: inputPointIndexes == const $CopyWithPlaceholder()
          ? _value.inputPointIndexes
          // ignore: cast_nullable_to_non_nullable
          : inputPointIndexes as List<int>?,
      ftp: ftp == const $CopyWithPlaceholder()
          ? _value.ftp
          // ignore: cast_nullable_to_non_nullable
          : ftp as int?,
    );
  }
}

extension $PowerModelCopyWith on PowerModel {
  /// Returns a callable class that can be used as follows: `instanceOfPowerModel.copyWith(...)` or like so:`instanceOfPowerModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PowerModelCWProxy get copyWith => _$PowerModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PowerModel _$PowerModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PowerModel', json, ($checkedConvert) {
      final val = PowerModel(
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$PowerModelTypeEnumEnumMap, v),
        ),
        criticalPower: $checkedConvert(
          'criticalPower',
          (v) => (v as num?)?.toInt(),
        ),
        wPrime: $checkedConvert('wPrime', (v) => (v as num?)?.toInt()),
        pMax: $checkedConvert('pMax', (v) => (v as num?)?.toInt()),
        inputPointIndexes: $checkedConvert(
          'inputPointIndexes',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        ftp: $checkedConvert('ftp', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$PowerModelToJson(PowerModel instance) =>
    <String, dynamic>{
      'type': ?_$PowerModelTypeEnumEnumMap[instance.type],
      'criticalPower': ?instance.criticalPower,
      'wPrime': ?instance.wPrime,
      'pMax': ?instance.pMax,
      'inputPointIndexes': ?instance.inputPointIndexes,
      'ftp': ?instance.ftp,
    };

const _$PowerModelTypeEnumEnumMap = {
  PowerModelTypeEnum.MS_2P: 'MS_2P',
  PowerModelTypeEnum.MORTON_3P: 'MORTON_3P',
  PowerModelTypeEnum.FFT_CURVES: 'FFT_CURVES',
  PowerModelTypeEnum.ECP: 'ECP',
};
