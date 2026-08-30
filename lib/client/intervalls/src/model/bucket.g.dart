// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BucketCWProxy {
  Bucket start(int? start);

  Bucket secs(int? secs);

  Bucket movingSecs(int? movingSecs);

  Bucket watts(double? watts);

  Bucket hr(double? hr);

  Bucket cadence(int? cadence);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bucket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bucket(...).copyWith(id: 12, name: "My name")
  /// ````
  Bucket call({
    int? start,
    int? secs,
    int? movingSecs,
    double? watts,
    double? hr,
    int? cadence,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBucket.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBucket.copyWith.fieldName(...)`
class _$BucketCWProxyImpl implements _$BucketCWProxy {
  const _$BucketCWProxyImpl(this._value);

  final Bucket _value;

  @override
  Bucket start(int? start) => this(start: start);

  @override
  Bucket secs(int? secs) => this(secs: secs);

  @override
  Bucket movingSecs(int? movingSecs) => this(movingSecs: movingSecs);

  @override
  Bucket watts(double? watts) => this(watts: watts);

  @override
  Bucket hr(double? hr) => this(hr: hr);

  @override
  Bucket cadence(int? cadence) => this(cadence: cadence);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bucket(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bucket(...).copyWith(id: 12, name: "My name")
  /// ````
  Bucket call({
    Object? start = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
    Object? movingSecs = const $CopyWithPlaceholder(),
    Object? watts = const $CopyWithPlaceholder(),
    Object? hr = const $CopyWithPlaceholder(),
    Object? cadence = const $CopyWithPlaceholder(),
  }) {
    return Bucket(
      start: start == const $CopyWithPlaceholder()
          ? _value.start
          // ignore: cast_nullable_to_non_nullable
          : start as int?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as int?,
      movingSecs: movingSecs == const $CopyWithPlaceholder()
          ? _value.movingSecs
          // ignore: cast_nullable_to_non_nullable
          : movingSecs as int?,
      watts: watts == const $CopyWithPlaceholder()
          ? _value.watts
          // ignore: cast_nullable_to_non_nullable
          : watts as double?,
      hr: hr == const $CopyWithPlaceholder()
          ? _value.hr
          // ignore: cast_nullable_to_non_nullable
          : hr as double?,
      cadence: cadence == const $CopyWithPlaceholder()
          ? _value.cadence
          // ignore: cast_nullable_to_non_nullable
          : cadence as int?,
    );
  }
}

extension $BucketCopyWith on Bucket {
  /// Returns a callable class that can be used as follows: `instanceOfBucket.copyWith(...)` or like so:`instanceOfBucket.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BucketCWProxy get copyWith => _$BucketCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bucket _$BucketFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Bucket', json, ($checkedConvert) {
      final val = Bucket(
        start: $checkedConvert('start', (v) => (v as num?)?.toInt()),
        secs: $checkedConvert('secs', (v) => (v as num?)?.toInt()),
        movingSecs: $checkedConvert('movingSecs', (v) => (v as num?)?.toInt()),
        watts: $checkedConvert('watts', (v) => (v as num?)?.toDouble()),
        hr: $checkedConvert('hr', (v) => (v as num?)?.toDouble()),
        cadence: $checkedConvert('cadence', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$BucketToJson(Bucket instance) => <String, dynamic>{
  'start': ?instance.start,
  'secs': ?instance.secs,
  'movingSecs': ?instance.movingSecs,
  'watts': ?instance.watts,
  'hr': ?instance.hr,
  'cadence': ?instance.cadence,
};
