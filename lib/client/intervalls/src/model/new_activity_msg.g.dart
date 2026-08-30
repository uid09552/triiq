// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_activity_msg.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NewActivityMsgCWProxy {
  NewActivityMsg content(String? content);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewActivityMsg(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewActivityMsg(...).copyWith(id: 12, name: "My name")
  /// ````
  NewActivityMsg call({String? content});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNewActivityMsg.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNewActivityMsg.copyWith.fieldName(...)`
class _$NewActivityMsgCWProxyImpl implements _$NewActivityMsgCWProxy {
  const _$NewActivityMsgCWProxyImpl(this._value);

  final NewActivityMsg _value;

  @override
  NewActivityMsg content(String? content) => this(content: content);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NewActivityMsg(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NewActivityMsg(...).copyWith(id: 12, name: "My name")
  /// ````
  NewActivityMsg call({Object? content = const $CopyWithPlaceholder()}) {
    return NewActivityMsg(
      content: content == const $CopyWithPlaceholder()
          ? _value.content
          // ignore: cast_nullable_to_non_nullable
          : content as String?,
    );
  }
}

extension $NewActivityMsgCopyWith on NewActivityMsg {
  /// Returns a callable class that can be used as follows: `instanceOfNewActivityMsg.copyWith(...)` or like so:`instanceOfNewActivityMsg.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NewActivityMsgCWProxy get copyWith => _$NewActivityMsgCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewActivityMsg _$NewActivityMsgFromJson(Map<String, dynamic> json) =>
    $checkedCreate('NewActivityMsg', json, ($checkedConvert) {
      final val = NewActivityMsg(
        content: $checkedConvert('content', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$NewActivityMsgToJson(NewActivityMsg instance) =>
    <String, dynamic>{'content': ?instance.content};
