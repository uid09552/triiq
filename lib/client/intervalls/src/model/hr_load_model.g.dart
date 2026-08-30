// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hr_load_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HRLoadModelCWProxy {
  HRLoadModel type(HRLoadModelTypeEnum? type);

  HRLoadModel icuTrainingLoad(int? icuTrainingLoad);

  HRLoadModel trainingDataCount(int? trainingDataCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HRLoadModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HRLoadModel(...).copyWith(id: 12, name: "My name")
  /// ````
  HRLoadModel call({
    HRLoadModelTypeEnum? type,
    int? icuTrainingLoad,
    int? trainingDataCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHRLoadModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHRLoadModel.copyWith.fieldName(...)`
class _$HRLoadModelCWProxyImpl implements _$HRLoadModelCWProxy {
  const _$HRLoadModelCWProxyImpl(this._value);

  final HRLoadModel _value;

  @override
  HRLoadModel type(HRLoadModelTypeEnum? type) => this(type: type);

  @override
  HRLoadModel icuTrainingLoad(int? icuTrainingLoad) =>
      this(icuTrainingLoad: icuTrainingLoad);

  @override
  HRLoadModel trainingDataCount(int? trainingDataCount) =>
      this(trainingDataCount: trainingDataCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HRLoadModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HRLoadModel(...).copyWith(id: 12, name: "My name")
  /// ````
  HRLoadModel call({
    Object? type = const $CopyWithPlaceholder(),
    Object? icuTrainingLoad = const $CopyWithPlaceholder(),
    Object? trainingDataCount = const $CopyWithPlaceholder(),
  }) {
    return HRLoadModel(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as HRLoadModelTypeEnum?,
      icuTrainingLoad: icuTrainingLoad == const $CopyWithPlaceholder()
          ? _value.icuTrainingLoad
          // ignore: cast_nullable_to_non_nullable
          : icuTrainingLoad as int?,
      trainingDataCount: trainingDataCount == const $CopyWithPlaceholder()
          ? _value.trainingDataCount
          // ignore: cast_nullable_to_non_nullable
          : trainingDataCount as int?,
    );
  }
}

extension $HRLoadModelCopyWith on HRLoadModel {
  /// Returns a callable class that can be used as follows: `instanceOfHRLoadModel.copyWith(...)` or like so:`instanceOfHRLoadModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HRLoadModelCWProxy get copyWith => _$HRLoadModelCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HRLoadModel _$HRLoadModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HRLoadModel', json, ($checkedConvert) {
      final val = HRLoadModel(
        type: $checkedConvert(
          'type',
          (v) => $enumDecodeNullable(_$HRLoadModelTypeEnumEnumMap, v),
        ),
        icuTrainingLoad: $checkedConvert(
          'icu_training_load',
          (v) => (v as num?)?.toInt(),
        ),
        trainingDataCount: $checkedConvert(
          'trainingDataCount',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'icuTrainingLoad': 'icu_training_load'});

Map<String, dynamic> _$HRLoadModelToJson(HRLoadModel instance) =>
    <String, dynamic>{
      'type': ?_$HRLoadModelTypeEnumEnumMap[instance.type],
      'icu_training_load': ?instance.icuTrainingLoad,
      'trainingDataCount': ?instance.trainingDataCount,
    };

const _$HRLoadModelTypeEnumEnumMap = {
  HRLoadModelTypeEnum.AVG_HR: 'AVG_HR',
  HRLoadModelTypeEnum.HR_ZONES: 'HR_ZONES',
  HRLoadModelTypeEnum.HRSS: 'HRSS',
};
