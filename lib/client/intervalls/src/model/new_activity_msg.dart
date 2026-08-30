//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_activity_msg.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NewActivityMsg {
  /// Returns a new [NewActivityMsg] instance.
  NewActivityMsg({

     this.content,
  });

  @JsonKey(
    
    name: r'content',
    required: false,
    includeIfNull: false,
  )


  final String? content;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NewActivityMsg &&
      other.content == content;

    @override
    int get hashCode =>
        content.hashCode;

  factory NewActivityMsg.fromJson(Map<String, dynamic> json) => _$NewActivityMsgFromJson(json);

  Map<String, dynamic> toJson() => _$NewActivityMsgToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

