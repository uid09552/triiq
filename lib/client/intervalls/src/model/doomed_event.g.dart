// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doomed_event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DoomedEventCWProxy {
  DoomedEvent id(int? id);

  DoomedEvent externalId(String? externalId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DoomedEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DoomedEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  DoomedEvent call({int? id, String? externalId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDoomedEvent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDoomedEvent.copyWith.fieldName(...)`
class _$DoomedEventCWProxyImpl implements _$DoomedEventCWProxy {
  const _$DoomedEventCWProxyImpl(this._value);

  final DoomedEvent _value;

  @override
  DoomedEvent id(int? id) => this(id: id);

  @override
  DoomedEvent externalId(String? externalId) => this(externalId: externalId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DoomedEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DoomedEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  DoomedEvent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? externalId = const $CopyWithPlaceholder(),
  }) {
    return DoomedEvent(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      externalId: externalId == const $CopyWithPlaceholder()
          ? _value.externalId
          // ignore: cast_nullable_to_non_nullable
          : externalId as String?,
    );
  }
}

extension $DoomedEventCopyWith on DoomedEvent {
  /// Returns a callable class that can be used as follows: `instanceOfDoomedEvent.copyWith(...)` or like so:`instanceOfDoomedEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DoomedEventCWProxy get copyWith => _$DoomedEventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoomedEvent _$DoomedEventFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DoomedEvent', json, ($checkedConvert) {
      final val = DoomedEvent(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        externalId: $checkedConvert('external_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'externalId': 'external_id'});

Map<String, dynamic> _$DoomedEventToJson(DoomedEvent instance) =>
    <String, dynamic>{'id': ?instance.id, 'external_id': ?instance.externalId};
