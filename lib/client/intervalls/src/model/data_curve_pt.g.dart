// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_curve_pt.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCurvePtCWProxy {
  DataCurvePt startIndex(int? startIndex);

  DataCurvePt endIndex(int? endIndex);

  DataCurvePt secs(int? secs);

  DataCurvePt value(int? value);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurvePt(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurvePt(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurvePt call({int? startIndex, int? endIndex, int? secs, int? value});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCurvePt.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCurvePt.copyWith.fieldName(...)`
class _$DataCurvePtCWProxyImpl implements _$DataCurvePtCWProxy {
  const _$DataCurvePtCWProxyImpl(this._value);

  final DataCurvePt _value;

  @override
  DataCurvePt startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  DataCurvePt endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  DataCurvePt secs(int? secs) => this(secs: secs);

  @override
  DataCurvePt value(int? value) => this(value: value);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCurvePt(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCurvePt(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCurvePt call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return DataCurvePt(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as int?,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as int?,
    );
  }
}

extension $DataCurvePtCopyWith on DataCurvePt {
  /// Returns a callable class that can be used as follows: `instanceOfDataCurvePt.copyWith(...)` or like so:`instanceOfDataCurvePt.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCurvePtCWProxy get copyWith => _$DataCurvePtCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCurvePt _$DataCurvePtFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DataCurvePt',
  json,
  ($checkedConvert) {
    final val = DataCurvePt(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      secs: $checkedConvert('secs', (v) => (v as num?)?.toInt()),
      value: $checkedConvert('value', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {'startIndex': 'start_index', 'endIndex': 'end_index'},
);

Map<String, dynamic> _$DataCurvePtToJson(DataCurvePt instance) =>
    <String, dynamic>{
      'start_index': ?instance.startIndex,
      'end_index': ?instance.endIndex,
      'secs': ?instance.secs,
      'value': ?instance.value,
    };
