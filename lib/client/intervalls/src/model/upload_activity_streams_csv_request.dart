//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dio/dio.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_activity_streams_csv_request.g.dart';

@CopyWith()
class UploadActivityStreamsCSVRequest {
  /// Returns a new [UploadActivityStreamsCSVRequest] instance.
  UploadActivityStreamsCSVRequest({required this.file});

  /// Activity streams CSV file
  @JsonKey(ignore: true)
  final MultipartFile file;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadActivityStreamsCSVRequest && other.file == file;

  @override
  int get hashCode => file.hashCode;

  // `file` is a multipart/form-data body and cannot be represented as JSON.
  factory UploadActivityStreamsCSVRequest.fromJson(Map<String, dynamic> json) =>
      throw UnsupportedError(
        'UploadActivityStreamsCSVRequest cannot be deserialized from JSON.',
      );

  Map<String, dynamic> toJson() => throw UnsupportedError(
    'UploadActivityStreamsCSVRequest cannot be serialized to JSON; use FormData instead.',
  );

  @override
  String toString() {
    return toJson().toString();
  }
}
