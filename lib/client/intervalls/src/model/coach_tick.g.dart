// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_tick.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoachTickCWProxy {
  CoachTick id(int? id);

  CoachTick text(String? text);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachTick(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachTick(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachTick call({int? id, String? text});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoachTick.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoachTick.copyWith.fieldName(...)`
class _$CoachTickCWProxyImpl implements _$CoachTickCWProxy {
  const _$CoachTickCWProxyImpl(this._value);

  final CoachTick _value;

  @override
  CoachTick id(int? id) => this(id: id);

  @override
  CoachTick text(String? text) => this(text: text);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoachTick(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoachTick(...).copyWith(id: 12, name: "My name")
  /// ````
  CoachTick call({
    Object? id = const $CopyWithPlaceholder(),
    Object? text = const $CopyWithPlaceholder(),
  }) {
    return CoachTick(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      text: text == const $CopyWithPlaceholder()
          ? _value.text
          // ignore: cast_nullable_to_non_nullable
          : text as String?,
    );
  }
}

extension $CoachTickCopyWith on CoachTick {
  /// Returns a callable class that can be used as follows: `instanceOfCoachTick.copyWith(...)` or like so:`instanceOfCoachTick.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoachTickCWProxy get copyWith => _$CoachTickCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachTick _$CoachTickFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoachTick', json, ($checkedConvert) {
      final val = CoachTick(
        id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
        text: $checkedConvert('text', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CoachTickToJson(CoachTick instance) => <String, dynamic>{
  'id': ?instance.id,
  'text': ?instance.text,
};
