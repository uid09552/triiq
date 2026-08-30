// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icu_segment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IcuSegmentCWProxy {
  IcuSegment id(int? id);

  IcuSegment startIndex(int? startIndex);

  IcuSegment endIndex(int? endIndex);

  IcuSegment name(String? name);

  IcuSegment segmentId(int? segmentId);

  IcuSegment starred(bool? starred);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IcuSegment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IcuSegment(...).copyWith(id: 12, name: "My name")
  /// ````
  IcuSegment call({
    int? id,
    int? startIndex,
    int? endIndex,
    String? name,
    int? segmentId,
    bool? starred,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIcuSegment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIcuSegment.copyWith.fieldName(...)`
class _$IcuSegmentCWProxyImpl implements _$IcuSegmentCWProxy {
  const _$IcuSegmentCWProxyImpl(this._value);

  final IcuSegment _value;

  @override
  IcuSegment id(int? id) => this(id: id);

  @override
  IcuSegment startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  IcuSegment endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  IcuSegment name(String? name) => this(name: name);

  @override
  IcuSegment segmentId(int? segmentId) => this(segmentId: segmentId);

  @override
  IcuSegment starred(bool? starred) => this(starred: starred);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IcuSegment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IcuSegment(...).copyWith(id: 12, name: "My name")
  /// ````
  IcuSegment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? segmentId = const $CopyWithPlaceholder(),
    Object? starred = const $CopyWithPlaceholder(),
  }) {
    return IcuSegment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      segmentId: segmentId == const $CopyWithPlaceholder()
          ? _value.segmentId
          // ignore: cast_nullable_to_non_nullable
          : segmentId as int?,
      starred: starred == const $CopyWithPlaceholder()
          ? _value.starred
          // ignore: cast_nullable_to_non_nullable
          : starred as bool?,
    );
  }
}

extension $IcuSegmentCopyWith on IcuSegment {
  /// Returns a callable class that can be used as follows: `instanceOfIcuSegment.copyWith(...)` or like so:`instanceOfIcuSegment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IcuSegmentCWProxy get copyWith => _$IcuSegmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IcuSegment _$IcuSegmentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'IcuSegment',
  json,
  ($checkedConvert) {
    final val = IcuSegment(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      name: $checkedConvert('name', (v) => v as String?),
      segmentId: $checkedConvert('segment_id', (v) => (v as num?)?.toInt()),
      starred: $checkedConvert('starred', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'startIndex': 'start_index',
    'endIndex': 'end_index',
    'segmentId': 'segment_id',
  },
);

Map<String, dynamic> _$IcuSegmentToJson(IcuSegment instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'start_index': ?instance.startIndex,
      'end_index': ?instance.endIndex,
      'name': ?instance.name,
      'segment_id': ?instance.segmentId,
      'starred': ?instance.starred,
    };
