// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_wellness_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadWellnessRequestCWProxy {
  UploadWellnessRequest file(MultipartFile file);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadWellnessRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadWellnessRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadWellnessRequest call({MultipartFile file});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadWellnessRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadWellnessRequest.copyWith.fieldName(...)`
class _$UploadWellnessRequestCWProxyImpl
    implements _$UploadWellnessRequestCWProxy {
  const _$UploadWellnessRequestCWProxyImpl(this._value);

  final UploadWellnessRequest _value;

  @override
  UploadWellnessRequest file(MultipartFile file) => this(file: file);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadWellnessRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadWellnessRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadWellnessRequest call({Object? file = const $CopyWithPlaceholder()}) {
    return UploadWellnessRequest(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as MultipartFile,
    );
  }
}

extension $UploadWellnessRequestCopyWith on UploadWellnessRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUploadWellnessRequest.copyWith(...)` or like so:`instanceOfUploadWellnessRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadWellnessRequestCWProxy get copyWith =>
      _$UploadWellnessRequestCWProxyImpl(this);
}
