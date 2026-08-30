//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/chat.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_msg.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NewMsg {
  /// Returns a new [NewMsg] instance.
  NewMsg({

     this.id,

     this.newChat,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'new_chat',
    required: false,
    includeIfNull: false,
  )


  final Chat? newChat;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NewMsg &&
      other.id == id &&
      other.newChat == newChat;

    @override
    int get hashCode =>
        id.hashCode +
        newChat.hashCode;

  factory NewMsg.fromJson(Map<String, dynamic> json) => _$NewMsgFromJson(json);

  Map<String, dynamic> toJson() => _$NewMsgToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

