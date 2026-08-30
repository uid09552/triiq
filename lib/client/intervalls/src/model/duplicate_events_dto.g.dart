// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_events_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DuplicateEventsDTOCWProxy {
  DuplicateEventsDTO numCopies(int? numCopies);

  DuplicateEventsDTO weeksBetween(int? weeksBetween);

  DuplicateEventsDTO eventIds(List<int>? eventIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DuplicateEventsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DuplicateEventsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  DuplicateEventsDTO call({
    int? numCopies,
    int? weeksBetween,
    List<int>? eventIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDuplicateEventsDTO.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDuplicateEventsDTO.copyWith.fieldName(...)`
class _$DuplicateEventsDTOCWProxyImpl implements _$DuplicateEventsDTOCWProxy {
  const _$DuplicateEventsDTOCWProxyImpl(this._value);

  final DuplicateEventsDTO _value;

  @override
  DuplicateEventsDTO numCopies(int? numCopies) => this(numCopies: numCopies);

  @override
  DuplicateEventsDTO weeksBetween(int? weeksBetween) =>
      this(weeksBetween: weeksBetween);

  @override
  DuplicateEventsDTO eventIds(List<int>? eventIds) => this(eventIds: eventIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DuplicateEventsDTO(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DuplicateEventsDTO(...).copyWith(id: 12, name: "My name")
  /// ````
  DuplicateEventsDTO call({
    Object? numCopies = const $CopyWithPlaceholder(),
    Object? weeksBetween = const $CopyWithPlaceholder(),
    Object? eventIds = const $CopyWithPlaceholder(),
  }) {
    return DuplicateEventsDTO(
      numCopies: numCopies == const $CopyWithPlaceholder()
          ? _value.numCopies
          // ignore: cast_nullable_to_non_nullable
          : numCopies as int?,
      weeksBetween: weeksBetween == const $CopyWithPlaceholder()
          ? _value.weeksBetween
          // ignore: cast_nullable_to_non_nullable
          : weeksBetween as int?,
      eventIds: eventIds == const $CopyWithPlaceholder()
          ? _value.eventIds
          // ignore: cast_nullable_to_non_nullable
          : eventIds as List<int>?,
    );
  }
}

extension $DuplicateEventsDTOCopyWith on DuplicateEventsDTO {
  /// Returns a callable class that can be used as follows: `instanceOfDuplicateEventsDTO.copyWith(...)` or like so:`instanceOfDuplicateEventsDTO.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DuplicateEventsDTOCWProxy get copyWith =>
      _$DuplicateEventsDTOCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DuplicateEventsDTO _$DuplicateEventsDTOFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DuplicateEventsDTO', json, ($checkedConvert) {
      final val = DuplicateEventsDTO(
        numCopies: $checkedConvert('numCopies', (v) => (v as num?)?.toInt()),
        weeksBetween: $checkedConvert(
          'weeksBetween',
          (v) => (v as num?)?.toInt(),
        ),
        eventIds: $checkedConvert(
          'eventIds',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DuplicateEventsDTOToJson(DuplicateEventsDTO instance) =>
    <String, dynamic>{
      'numCopies': ?instance.numCopies,
      'weeksBetween': ?instance.weeksBetween,
      'eventIds': ?instance.eventIds,
    };
