//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/message.dart';
import 'package:triiq/client/intervalls/src/model/chat.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendResponse {
  /// Returns a new [SendResponse] instance.
  SendResponse({this.id, this.message, this.newChat});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'message', required: false, includeIfNull: false)
  final Message? message;

  @JsonKey(name: r'new_chat', required: false, includeIfNull: false)
  final Chat? newChat;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendResponse &&
          other.id == id &&
          other.message == message &&
          other.newChat == newChat;

  @override
  int get hashCode => id.hashCode + message.hashCode + newChat.hashCode;

  factory SendResponse.fromJson(Map<String, dynamic> json) =>
      _$SendResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SendResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
