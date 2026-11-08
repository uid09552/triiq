//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_error.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PushError {
  /// Returns a new [PushError] instance.
  PushError({this.service, this.message, this.date});

  @JsonKey(name: r'service', required: false, includeIfNull: false)
  final String? service;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final String? message;

  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final DateTime? date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushError &&
          other.service == service &&
          other.message == message &&
          other.date == date;

  @override
  int get hashCode => service.hashCode + message.hashCode + date.hashCode;

  factory PushError.fromJson(Map<String, dynamic> json) =>
      _$PushErrorFromJson(json);

  Map<String, dynamic> toJson() => _$PushErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
