//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Message {
  /// Returns a new [Message] instance.
  Message({

     this.id,

     this.athleteId,

     this.name,

     this.created,

     this.type,

     this.content,

     this.activityId,

     this.startIndex,

     this.endIndex,

     this.answer,

     this.activity,

     this.attachmentUrl,

     this.attachmentMimeType,

     this.deleted,

     this.deletedById,

     this.joinGroupId,

     this.acceptCoachingGroupId,

     this.seen,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? athleteId;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'created',
    required: false,
    includeIfNull: false,
  )


  final DateTime? created;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final MessageTypeEnum? type;



  @JsonKey(
    
    name: r'content',
    required: false,
    includeIfNull: false,
  )


  final String? content;



  @JsonKey(
    
    name: r'activity_id',
    required: false,
    includeIfNull: false,
  )


  final String? activityId;



  @JsonKey(
    
    name: r'start_index',
    required: false,
    includeIfNull: false,
  )


  final int? startIndex;



  @JsonKey(
    
    name: r'end_index',
    required: false,
    includeIfNull: false,
  )


  final int? endIndex;



  @JsonKey(
    
    name: r'answer',
    required: false,
    includeIfNull: false,
  )


  final String? answer;



  @JsonKey(
    
    name: r'activity',
    required: false,
    includeIfNull: false,
  )


  final Activity? activity;



  @JsonKey(
    
    name: r'attachment_url',
    required: false,
    includeIfNull: false,
  )


  final String? attachmentUrl;



  @JsonKey(
    
    name: r'attachment_mime_type',
    required: false,
    includeIfNull: false,
  )


  final String? attachmentMimeType;



  @JsonKey(
    
    name: r'deleted',
    required: false,
    includeIfNull: false,
  )


  final DateTime? deleted;



  @JsonKey(
    
    name: r'deleted_by_id',
    required: false,
    includeIfNull: false,
  )


  final String? deletedById;



  @JsonKey(
    
    name: r'join_group_id',
    required: false,
    includeIfNull: false,
  )


  final int? joinGroupId;



  @JsonKey(
    
    name: r'accept_coaching_group_id',
    required: false,
    includeIfNull: false,
  )


  final int? acceptCoachingGroupId;



  @JsonKey(
    
    name: r'seen',
    required: false,
    includeIfNull: false,
  )


  final bool? seen;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Message &&
      other.id == id &&
      other.athleteId == athleteId &&
      other.name == name &&
      other.created == created &&
      other.type == type &&
      other.content == content &&
      other.activityId == activityId &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.answer == answer &&
      other.activity == activity &&
      other.attachmentUrl == attachmentUrl &&
      other.attachmentMimeType == attachmentMimeType &&
      other.deleted == deleted &&
      other.deletedById == deletedById &&
      other.joinGroupId == joinGroupId &&
      other.acceptCoachingGroupId == acceptCoachingGroupId &&
      other.seen == seen;

    @override
    int get hashCode =>
        id.hashCode +
        athleteId.hashCode +
        name.hashCode +
        created.hashCode +
        type.hashCode +
        content.hashCode +
        activityId.hashCode +
        startIndex.hashCode +
        endIndex.hashCode +
        answer.hashCode +
        activity.hashCode +
        attachmentUrl.hashCode +
        attachmentMimeType.hashCode +
        deleted.hashCode +
        deletedById.hashCode +
        joinGroupId.hashCode +
        acceptCoachingGroupId.hashCode +
        seen.hashCode;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MessageTypeEnum {
@JsonValue(r'TEXT')
TEXT(r'TEXT'),
@JsonValue(r'FOLLOW_REQ')
FOLLOW_REQ(r'FOLLOW_REQ'),
@JsonValue(r'COACH_REQ')
COACH_REQ(r'COACH_REQ'),
@JsonValue(r'COACH_ME_REQ')
COACH_ME_REQ(r'COACH_ME_REQ'),
@JsonValue(r'ACTIVITY')
ACTIVITY(r'ACTIVITY'),
@JsonValue(r'NOTE')
NOTE(r'NOTE'),
@JsonValue(r'JOIN_REQ')
JOIN_REQ(r'JOIN_REQ'),
@JsonValue(r'ACCEPT_COACHING_GROUP')
ACCEPT_COACHING_GROUP(r'ACCEPT_COACHING_GROUP');

const MessageTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


