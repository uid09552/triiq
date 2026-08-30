// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anomaly.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AnomalyCWProxy {
  Anomaly startIndex(int? startIndex);

  Anomaly endIndex(int? endIndex);

  Anomaly value(int? value);

  Anomaly valueEnd(int? valueEnd);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Anomaly(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Anomaly(...).copyWith(id: 12, name: "My name")
  /// ````
  Anomaly call({int? startIndex, int? endIndex, int? value, int? valueEnd});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAnomaly.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAnomaly.copyWith.fieldName(...)`
class _$AnomalyCWProxyImpl implements _$AnomalyCWProxy {
  const _$AnomalyCWProxyImpl(this._value);

  final Anomaly _value;

  @override
  Anomaly startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  Anomaly endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  Anomaly value(int? value) => this(value: value);

  @override
  Anomaly valueEnd(int? valueEnd) => this(valueEnd: valueEnd);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Anomaly(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Anomaly(...).copyWith(id: 12, name: "My name")
  /// ````
  Anomaly call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? valueEnd = const $CopyWithPlaceholder(),
  }) {
    return Anomaly(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as int?,
      valueEnd: valueEnd == const $CopyWithPlaceholder()
          ? _value.valueEnd
          // ignore: cast_nullable_to_non_nullable
          : valueEnd as int?,
    );
  }
}

extension $AnomalyCopyWith on Anomaly {
  /// Returns a callable class that can be used as follows: `instanceOfAnomaly.copyWith(...)` or like so:`instanceOfAnomaly.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AnomalyCWProxy get copyWith => _$AnomalyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Anomaly _$AnomalyFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Anomaly',
  json,
  ($checkedConvert) {
    final val = Anomaly(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      value: $checkedConvert('value', (v) => (v as num?)?.toInt()),
      valueEnd: $checkedConvert('valueEnd', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'startIndex': 'start_index', 'endIndex': 'end_index'},
);

Map<String, dynamic> _$AnomalyToJson(Anomaly instance) => <String, dynamic>{
  'start_index': ?instance.startIndex,
  'end_index': ?instance.endIndex,
  'value': ?instance.value,
  'valueEnd': ?instance.valueEnd,
};
