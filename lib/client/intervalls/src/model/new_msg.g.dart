// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_msg.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NewMsgCWProxy {
  NewMsg id(int? id);

  NewMsg newChat(Chat? newChat);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewMsg(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewMsg(...).copyWith(id: 12, name: "My name")
  /// ````
  NewMsg call({int? id, Chat? newChat});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNewMsg.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNewMsg.copyWith.fieldName(...)`
class _$NewMsgCWProxyImpl implements _$NewMsgCWProxy {
  const _$NewMsgCWProxyImpl(this._value);

  final NewMsg _value;

  @override
  NewMsg id(int? id) => this(id: id);

  @override
  NewMsg newChat(Chat? newChat) => this(newChat: newChat);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewMsg(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewMsg(...).copyWith(id: 12, name: "My name")
  /// ````
  NewMsg call({
    Object? id = const $CopyWithPlaceholder(),
    Object? newChat = const $CopyWithPlaceholder(),
  }) {
    return NewMsg(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      newChat: newChat == const $CopyWithPlaceholder()
          ? _value.newChat
          // ignore: cast_nullable_to_non_nullable
          : newChat as Chat?,
    );
  }
}

extension $NewMsgCopyWith on NewMsg {
  /// Returns a callable class that can be used as follows: `instanceOfNewMsg.copyWith(...)` or like so:`instanceOfNewMsg.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NewMsgCWProxy get copyWith => _$NewMsgCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewMsg _$NewMsgFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NewMsg', json, ($checkedConvert) {
      final val = NewMsg(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        newChat: $checkedConvert(
          'new_chat',
          (v) => v == null ? null : Chat.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'newChat': 'new_chat'});

Map<String, dynamic> _$NewMsgToJson(NewMsg instance) => <String, dynamic>{
  'id': ?instance.id,
  'new_chat': ?instance.newChat?.toJson(),
};
