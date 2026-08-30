// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_stream.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityStreamCWProxy {
  ActivityStream type(String? type);

  ActivityStream name(String? name);

  ActivityStream data(Object? data);

  ActivityStream data2(Object? data2);

  ActivityStream valueTypeIsArray(bool? valueTypeIsArray);

  ActivityStream anomalies(List<Anomaly>? anomalies);

  ActivityStream custom(bool? custom);

  ActivityStream allNull(bool? allNull);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityStream(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityStream(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityStream call({
    String? type,
    String? name,
    Object? data,
    Object? data2,
    bool? valueTypeIsArray,
    List<Anomaly>? anomalies,
    bool? custom,
    bool? allNull,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityStream.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityStream.copyWith.fieldName(...)`
class _$ActivityStreamCWProxyImpl implements _$ActivityStreamCWProxy {
  const _$ActivityStreamCWProxyImpl(this._value);

  final ActivityStream _value;

  @override
  ActivityStream type(String? type) => this(type: type);

  @override
  ActivityStream name(String? name) => this(name: name);

  @override
  ActivityStream data(Object? data) => this(data: data);

  @override
  ActivityStream data2(Object? data2) => this(data2: data2);

  @override
  ActivityStream valueTypeIsArray(bool? valueTypeIsArray) =>
      this(valueTypeIsArray: valueTypeIsArray);

  @override
  ActivityStream anomalies(List<Anomaly>? anomalies) =>
      this(anomalies: anomalies);

  @override
  ActivityStream custom(bool? custom) => this(custom: custom);

  @override
  ActivityStream allNull(bool? allNull) => this(allNull: allNull);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityStream(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityStream(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityStream call({
    Object? type = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? data2 = const $CopyWithPlaceholder(),
    Object? valueTypeIsArray = const $CopyWithPlaceholder(),
    Object? anomalies = const $CopyWithPlaceholder(),
    Object? custom = const $CopyWithPlaceholder(),
    Object? allNull = const $CopyWithPlaceholder(),
  }) {
    return ActivityStream(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Object?,
      data2: data2 == const $CopyWithPlaceholder()
          ? _value.data2
          // ignore: cast_nullable_to_non_nullable
          : data2 as Object?,
      valueTypeIsArray: valueTypeIsArray == const $CopyWithPlaceholder()
          ? _value.valueTypeIsArray
          // ignore: cast_nullable_to_non_nullable
          : valueTypeIsArray as bool?,
      anomalies: anomalies == const $CopyWithPlaceholder()
          ? _value.anomalies
          // ignore: cast_nullable_to_non_nullable
          : anomalies as List<Anomaly>?,
      custom: custom == const $CopyWithPlaceholder()
          ? _value.custom
          // ignore: cast_nullable_to_non_nullable
          : custom as bool?,
      allNull: allNull == const $CopyWithPlaceholder()
          ? _value.allNull
          // ignore: cast_nullable_to_non_nullable
          : allNull as bool?,
    );
  }
}

extension $ActivityStreamCopyWith on ActivityStream {
  /// Returns a callable class that can be used as follows: `instanceOfActivityStream.copyWith(...)` or like so:`instanceOfActivityStream.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityStreamCWProxy get copyWith => _$ActivityStreamCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityStream _$ActivityStreamFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityStream', json, ($checkedConvert) {
      final val = ActivityStream(
        type: $checkedConvert('type', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        data: $checkedConvert('data', (v) => v),
        data2: $checkedConvert('data2', (v) => v),
        valueTypeIsArray: $checkedConvert(
          'valueTypeIsArray',
          (v) => v as bool?,
        ),
        anomalies: $checkedConvert(
          'anomalies',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Anomaly.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        custom: $checkedConvert('custom', (v) => v as bool?),
        allNull: $checkedConvert('allNull', (v) => v as bool?),
      );
      return val;
    });

Map<String, dynamic> _$ActivityStreamToJson(ActivityStream instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'name': ?instance.name,
      'data': ?instance.data,
      'data2': ?instance.data2,
      'valueTypeIsArray': ?instance.valueTypeIsArray,
      'anomalies': ?instance.anomalies?.map((e) => e.toJson()).toList(),
      'custom': ?instance.custom,
      'allNull': ?instance.allNull,
    };
