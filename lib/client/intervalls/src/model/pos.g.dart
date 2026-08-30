// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PosCWProxy {
  Pos id(String? id);

  Pos width(String? width);

  Pos height(String? height);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pos(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pos(...).copyWith(id: 12, name: "My name")
  /// ````
  Pos call({String? id, String? width, String? height});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPos.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPos.copyWith.fieldName(...)`
class _$PosCWProxyImpl implements _$PosCWProxy {
  const _$PosCWProxyImpl(this._value);

  final Pos _value;

  @override
  Pos id(String? id) => this(id: id);

  @override
  Pos width(String? width) => this(width: width);

  @override
  Pos height(String? height) => this(height: height);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pos(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pos(...).copyWith(id: 12, name: "My name")
  /// ````
  Pos call({
    Object? id = const $CopyWithPlaceholder(),
    Object? width = const $CopyWithPlaceholder(),
    Object? height = const $CopyWithPlaceholder(),
  }) {
    return Pos(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      width: width == const $CopyWithPlaceholder()
          ? _value.width
          // ignore: cast_nullable_to_non_nullable
          : width as String?,
      height: height == const $CopyWithPlaceholder()
          ? _value.height
          // ignore: cast_nullable_to_non_nullable
          : height as String?,
    );
  }
}

extension $PosCopyWith on Pos {
  /// Returns a callable class that can be used as follows: `instanceOfPos.copyWith(...)` or like so:`instanceOfPos.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PosCWProxy get copyWith => _$PosCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pos _$PosFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Pos', json, ($checkedConvert) {
      final val = Pos(
        id: $checkedConvert('id', (v) => v as String?),
        width: $checkedConvert('width', (v) => v as String?),
        height: $checkedConvert('height', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PosToJson(Pos instance) => <String, dynamic>{
  'id': ?instance.id,
  'width': ?instance.width,
  'height': ?instance.height,
};
