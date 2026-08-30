// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SendResponseCWProxy {
  SendResponse id(int? id);

  SendResponse message(Message? message);

  SendResponse newChat(Chat? newChat);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SendResponse call({int? id, Message? message, Chat? newChat});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSendResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSendResponse.copyWith.fieldName(...)`
class _$SendResponseCWProxyImpl implements _$SendResponseCWProxy {
  const _$SendResponseCWProxyImpl(this._value);

  final SendResponse _value;

  @override
  SendResponse id(int? id) => this(id: id);

  @override
  SendResponse message(Message? message) => this(message: message);

  @override
  SendResponse newChat(Chat? newChat) => this(newChat: newChat);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SendResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SendResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SendResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? newChat = const $CopyWithPlaceholder(),
  }) {
    return SendResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as Message?,
      newChat: newChat == const $CopyWithPlaceholder()
          ? _value.newChat
          // ignore: cast_nullable_to_non_nullable
          : newChat as Chat?,
    );
  }
}

extension $SendResponseCopyWith on SendResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSendResponse.copyWith(...)` or like so:`instanceOfSendResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SendResponseCWProxy get copyWith => _$SendResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendResponse _$SendResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SendResponse', json, ($checkedConvert) {
      final val = SendResponse(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        message: $checkedConvert(
          'message',
          (v) => v == null ? null : Message.fromJson(v as Map<String, dynamic>),
        ),
        newChat: $checkedConvert(
          'new_chat',
          (v) => v == null ? null : Chat.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'newChat': 'new_chat'});

Map<String, dynamic> _$SendResponseToJson(SendResponse instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'message': ?instance.message?.toJson(),
      'new_chat': ?instance.newChat?.toJson(),
    };
