// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttachmentCWProxy {
  Attachment id(String? id);

  Attachment filename(String? filename);

  Attachment mimetype(String? mimetype);

  Attachment url(String? url);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    String? id,
    String? filename,
    String? mimetype,
    String? url,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttachment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttachment.copyWith.fieldName(...)`
class _$AttachmentCWProxyImpl implements _$AttachmentCWProxy {
  const _$AttachmentCWProxyImpl(this._value);

  final Attachment _value;

  @override
  Attachment id(String? id) => this(id: id);

  @override
  Attachment filename(String? filename) => this(filename: filename);

  @override
  Attachment mimetype(String? mimetype) => this(mimetype: mimetype);

  @override
  Attachment url(String? url) => this(url: url);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? filename = const $CopyWithPlaceholder(),
    Object? mimetype = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
  }) {
    return Attachment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String?,
      mimetype: mimetype == const $CopyWithPlaceholder()
          ? _value.mimetype
          // ignore: cast_nullable_to_non_nullable
          : mimetype as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
    );
  }
}

extension $AttachmentCopyWith on Attachment {
  /// Returns a callable class that can be used as follows: `instanceOfAttachment.copyWith(...)` or like so:`instanceOfAttachment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttachmentCWProxy get copyWith => _$AttachmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Attachment', json, ($checkedConvert) {
      final val = Attachment(
        id: $checkedConvert('id', (v) => v as String?),
        filename: $checkedConvert('filename', (v) => v as String?),
        mimetype: $checkedConvert('mimetype', (v) => v as String?),
        url: $checkedConvert('url', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'filename': ?instance.filename,
      'mimetype': ?instance.mimetype,
      'url': ?instance.url,
    };
