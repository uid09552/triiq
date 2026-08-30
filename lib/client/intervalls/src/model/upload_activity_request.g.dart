// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_activity_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadActivityRequestCWProxy {
  UploadActivityRequest file(MultipartFile file);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadActivityRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadActivityRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadActivityRequest call({MultipartFile file});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadActivityRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadActivityRequest.copyWith.fieldName(...)`
class _$UploadActivityRequestCWProxyImpl
    implements _$UploadActivityRequestCWProxy {
  const _$UploadActivityRequestCWProxyImpl(this._value);

  final UploadActivityRequest _value;

  @override
  UploadActivityRequest file(MultipartFile file) => this(file: file);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadActivityRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadActivityRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadActivityRequest call({Object? file = const $CopyWithPlaceholder()}) {
    return UploadActivityRequest(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as MultipartFile,
    );
  }
}

extension $UploadActivityRequestCopyWith on UploadActivityRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUploadActivityRequest.copyWith(...)` or like so:`instanceOfUploadActivityRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadActivityRequestCWProxy get copyWith =>
      _$UploadActivityRequestCWProxyImpl(this);
}
