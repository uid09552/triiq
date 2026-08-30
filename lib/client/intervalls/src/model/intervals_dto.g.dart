// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervals_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IntervalsDTOCWProxy {
  IntervalsDTO id(String? id);

  IntervalsDTO analyzed(DateTime? analyzed);

  IntervalsDTO icuIntervals(List<Interval>? icuIntervals);

  IntervalsDTO icuGroups(List<IntervalGroup>? icuGroups);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntervalsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntervalsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  IntervalsDTO call({
    String? id,
    DateTime? analyzed,
    List<Interval>? icuIntervals,
    List<IntervalGroup>? icuGroups,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIntervalsDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIntervalsDTO.copyWith.fieldName(...)`
class _$IntervalsDTOCWProxyImpl implements _$IntervalsDTOCWProxy {
  const _$IntervalsDTOCWProxyImpl(this._value);

  final IntervalsDTO _value;

  @override
  IntervalsDTO id(String? id) => this(id: id);

  @override
  IntervalsDTO analyzed(DateTime? analyzed) => this(analyzed: analyzed);

  @override
  IntervalsDTO icuIntervals(List<Interval>? icuIntervals) =>
      this(icuIntervals: icuIntervals);

  @override
  IntervalsDTO icuGroups(List<IntervalGroup>? icuGroups) =>
      this(icuGroups: icuGroups);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IntervalsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IntervalsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  IntervalsDTO call({
    Object? id = const $CopyWithPlaceholder(),
    Object? analyzed = const $CopyWithPlaceholder(),
    Object? icuIntervals = const $CopyWithPlaceholder(),
    Object? icuGroups = const $CopyWithPlaceholder(),
  }) {
    return IntervalsDTO(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      analyzed: analyzed == const $CopyWithPlaceholder()
          ? _value.analyzed
          // ignore: cast_nullable_to_non_nullable
          : analyzed as DateTime?,
      icuIntervals: icuIntervals == const $CopyWithPlaceholder()
          ? _value.icuIntervals
          // ignore: cast_nullable_to_non_nullable
          : icuIntervals as List<Interval>?,
      icuGroups: icuGroups == const $CopyWithPlaceholder()
          ? _value.icuGroups
          // ignore: cast_nullable_to_non_nullable
          : icuGroups as List<IntervalGroup>?,
    );
  }
}

extension $IntervalsDTOCopyWith on IntervalsDTO {
  /// Returns a callable class that can be used as follows: `instanceOfIntervalsDTO.copyWith(...)` or like so:`instanceOfIntervalsDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntervalsDTOCWProxy get copyWith => _$IntervalsDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntervalsDTO _$IntervalsDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'IntervalsDTO',
      json,
      ($checkedConvert) {
        final val = IntervalsDTO(
          id: $checkedConvert('id', (v) => v as String?),
          analyzed: $checkedConvert(
            'analyzed',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          icuIntervals: $checkedConvert(
            'icu_intervals',
            (v) => (v as List<dynamic>?)
                ?.map((e) => Interval.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          icuGroups: $checkedConvert(
            'icu_groups',
            (v) => (v as List<dynamic>?)
                ?.map((e) => IntervalGroup.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'icuIntervals': 'icu_intervals',
        'icuGroups': 'icu_groups',
      },
    );

Map<String, dynamic> _$IntervalsDTOToJson(IntervalsDTO instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'analyzed': ?instance.analyzed?.toIso8601String(),
      'icu_intervals': ?instance.icuIntervals?.map((e) => e.toJson()).toList(),
      'icu_groups': ?instance.icuGroups?.map((e) => e.toJson()).toList(),
    };
