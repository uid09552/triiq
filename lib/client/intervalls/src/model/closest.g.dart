// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closest.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ClosestCWProxy {
  Closest startSecs(int? startSecs);

  Closest p1Index(int? p1Index);

  Closest p2Index(int? p2Index);

  Closest p3Index(int? p3Index);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Closest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Closest(...).copyWith(id: 12, name: "My name")
  /// ````
  Closest call({int? startSecs, int? p1Index, int? p2Index, int? p3Index});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfClosest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfClosest.copyWith.fieldName(...)`
class _$ClosestCWProxyImpl implements _$ClosestCWProxy {
  const _$ClosestCWProxyImpl(this._value);

  final Closest _value;

  @override
  Closest startSecs(int? startSecs) => this(startSecs: startSecs);

  @override
  Closest p1Index(int? p1Index) => this(p1Index: p1Index);

  @override
  Closest p2Index(int? p2Index) => this(p2Index: p2Index);

  @override
  Closest p3Index(int? p3Index) => this(p3Index: p3Index);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Closest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Closest(...).copyWith(id: 12, name: "My name")
  /// ````
  Closest call({
    Object? startSecs = const $CopyWithPlaceholder(),
    Object? p1Index = const $CopyWithPlaceholder(),
    Object? p2Index = const $CopyWithPlaceholder(),
    Object? p3Index = const $CopyWithPlaceholder(),
  }) {
    return Closest(
      startSecs: startSecs == const $CopyWithPlaceholder()
          ? _value.startSecs
          // ignore: cast_nullable_to_non_nullable
          : startSecs as int?,
      p1Index: p1Index == const $CopyWithPlaceholder()
          ? _value.p1Index
          // ignore: cast_nullable_to_non_nullable
          : p1Index as int?,
      p2Index: p2Index == const $CopyWithPlaceholder()
          ? _value.p2Index
          // ignore: cast_nullable_to_non_nullable
          : p2Index as int?,
      p3Index: p3Index == const $CopyWithPlaceholder()
          ? _value.p3Index
          // ignore: cast_nullable_to_non_nullable
          : p3Index as int?,
    );
  }
}

extension $ClosestCopyWith on Closest {
  /// Returns a callable class that can be used as follows: `instanceOfClosest.copyWith(...)` or like so:`instanceOfClosest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ClosestCWProxy get copyWith => _$ClosestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Closest _$ClosestFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Closest',
  json,
  ($checkedConvert) {
    final val = Closest(
      startSecs: $checkedConvert('start_secs', (v) => (v as num?)?.toInt()),
      p1Index: $checkedConvert('p1_index', (v) => (v as num?)?.toInt()),
      p2Index: $checkedConvert('p2_index', (v) => (v as num?)?.toInt()),
      p3Index: $checkedConvert('p3_index', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'startSecs': 'start_secs',
    'p1Index': 'p1_index',
    'p2Index': 'p2_index',
    'p3Index': 'p3_index',
  },
);

Map<String, dynamic> _$ClosestToJson(Closest instance) => <String, dynamic>{
  'start_secs': ?instance.startSecs,
  'p1_index': ?instance.p1Index,
  'p2_index': ?instance.p2Index,
  'p3_index': ?instance.p3Index,
};
