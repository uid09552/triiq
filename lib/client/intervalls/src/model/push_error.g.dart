// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PushErrorCWProxy {
  PushError service(String? service);

  PushError message(String? message);

  PushError date(DateTime? date);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushError(...).copyWith(id: 12, name: "My name")
  /// ````
  PushError call({String? service, String? message, DateTime? date});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPushError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPushError.copyWith.fieldName(...)`
class _$PushErrorCWProxyImpl implements _$PushErrorCWProxy {
  const _$PushErrorCWProxyImpl(this._value);

  final PushError _value;

  @override
  PushError service(String? service) => this(service: service);

  @override
  PushError message(String? message) => this(message: message);

  @override
  PushError date(DateTime? date) => this(date: date);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PushError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PushError(...).copyWith(id: 12, name: "My name")
  /// ````
  PushError call({
    Object? service = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
  }) {
    return PushError(
      service: service == const $CopyWithPlaceholder()
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime?,
    );
  }
}

extension $PushErrorCopyWith on PushError {
  /// Returns a callable class that can be used as follows: `instanceOfPushError.copyWith(...)` or like so:`instanceOfPushError.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PushErrorCWProxy get copyWith => _$PushErrorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushError _$PushErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PushError', json, ($checkedConvert) {
      final val = PushError(
        service: $checkedConvert('service', (v) => v as String?),
        message: $checkedConvert('message', (v) => v as String?),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PushErrorToJson(PushError instance) => <String, dynamic>{
  'service': ?instance.service,
  'message': ?instance.message,
  'date': ?instance.date?.toIso8601String(),
};
