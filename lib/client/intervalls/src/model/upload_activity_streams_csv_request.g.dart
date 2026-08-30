// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_activity_streams_csv_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadActivityStreamsCSVRequestCWProxy {
  UploadActivityStreamsCSVRequest file(MultipartFile file);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadActivityStreamsCSVRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadActivityStreamsCSVRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadActivityStreamsCSVRequest call({MultipartFile file});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadActivityStreamsCSVRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadActivityStreamsCSVRequest.copyWith.fieldName(...)`
class _$UploadActivityStreamsCSVRequestCWProxyImpl
    implements _$UploadActivityStreamsCSVRequestCWProxy {
  const _$UploadActivityStreamsCSVRequestCWProxyImpl(this._value);

  final UploadActivityStreamsCSVRequest _value;

  @override
  UploadActivityStreamsCSVRequest file(MultipartFile file) => this(file: file);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadActivityStreamsCSVRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadActivityStreamsCSVRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadActivityStreamsCSVRequest call({
    Object? file = const $CopyWithPlaceholder(),
  }) {
    return UploadActivityStreamsCSVRequest(
      file: file == const $CopyWithPlaceholder()
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as MultipartFile,
    );
  }
}

extension $UploadActivityStreamsCSVRequestCopyWith
    on UploadActivityStreamsCSVRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUploadActivityStreamsCSVRequest.copyWith(...)` or like so:`instanceOfUploadActivityStreamsCSVRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadActivityStreamsCSVRequestCWProxy get copyWith =>
      _$UploadActivityStreamsCSVRequestCWProxyImpl(this);
}
