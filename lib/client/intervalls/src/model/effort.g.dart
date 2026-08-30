// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effort.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EffortCWProxy {
  Effort startIndex(int? startIndex);

  Effort endIndex(int? endIndex);

  Effort average(double? average);

  Effort duration(int? duration);

  Effort distance(double? distance);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Effort(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Effort(...).copyWith(id: 12, name: "My name")
  /// ````
  Effort call({
    int? startIndex,
    int? endIndex,
    double? average,
    int? duration,
    double? distance,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEffort.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEffort.copyWith.fieldName(...)`
class _$EffortCWProxyImpl implements _$EffortCWProxy {
  const _$EffortCWProxyImpl(this._value);

  final Effort _value;

  @override
  Effort startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  Effort endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  Effort average(double? average) => this(average: average);

  @override
  Effort duration(int? duration) => this(duration: duration);

  @override
  Effort distance(double? distance) => this(distance: distance);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Effort(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Effort(...).copyWith(id: 12, name: "My name")
  /// ````
  Effort call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? average = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
  }) {
    return Effort(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      average: average == const $CopyWithPlaceholder()
          ? _value.average
          // ignore: cast_nullable_to_non_nullable
          : average as double?,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as int?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
    );
  }
}

extension $EffortCopyWith on Effort {
  /// Returns a callable class that can be used as follows: `instanceOfEffort.copyWith(...)` or like so:`instanceOfEffort.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EffortCWProxy get copyWith => _$EffortCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Effort _$EffortFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Effort',
  json,
  ($checkedConvert) {
    final val = Effort(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      average: $checkedConvert('average', (v) => (v as num?)?.toDouble()),
      duration: $checkedConvert('duration', (v) => (v as num?)?.toInt()),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
    );
    return val;
  },
  fieldKeyMap: const {'startIndex': 'start_index', 'endIndex': 'end_index'},
);

Map<String, dynamic> _$EffortToJson(Effort instance) => <String, dynamic>{
  'start_index': ?instance.startIndex,
  'end_index': ?instance.endIndex,
  'average': ?instance.average,
  'duration': ?instance.duration,
  'distance': ?instance.distance,
};
