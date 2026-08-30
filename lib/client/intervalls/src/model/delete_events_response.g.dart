// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_events_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeleteEventsResponseCWProxy {
  DeleteEventsResponse eventsDeleted(int? eventsDeleted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteEventsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteEventsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteEventsResponse call({int? eventsDeleted});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeleteEventsResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeleteEventsResponse.copyWith.fieldName(...)`
class _$DeleteEventsResponseCWProxyImpl
    implements _$DeleteEventsResponseCWProxy {
  const _$DeleteEventsResponseCWProxyImpl(this._value);

  final DeleteEventsResponse _value;

  @override
  DeleteEventsResponse eventsDeleted(int? eventsDeleted) =>
      this(eventsDeleted: eventsDeleted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeleteEventsResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeleteEventsResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DeleteEventsResponse call({
    Object? eventsDeleted = const $CopyWithPlaceholder(),
  }) {
    return DeleteEventsResponse(
      eventsDeleted: eventsDeleted == const $CopyWithPlaceholder()
          ? _value.eventsDeleted
          // ignore: cast_nullable_to_non_nullable
          : eventsDeleted as int?,
    );
  }
}

extension $DeleteEventsResponseCopyWith on DeleteEventsResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDeleteEventsResponse.copyWith(...)` or like so:`instanceOfDeleteEventsResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeleteEventsResponseCWProxy get copyWith =>
      _$DeleteEventsResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteEventsResponse _$DeleteEventsResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DeleteEventsResponse', json, ($checkedConvert) {
  final val = DeleteEventsResponse(
    eventsDeleted: $checkedConvert(
      'eventsDeleted',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DeleteEventsResponseToJson(
  DeleteEventsResponse instance,
) => <String, dynamic>{'eventsDeleted': ?instance.eventsDeleted};
