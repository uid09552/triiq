//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/folder.dart';
import 'package:triiq/client/intervalls/src/model/chat_member.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Chat {
  /// Returns a new [Chat] instance.
  Chat({

     this.id,

     this.type,

     this.coachingGroup,

     this.updated,

     this.name,

     this.picture,

     this.description,

     this.url,

     this.slug,

     this.pub,

     this.joinPolicy,

     this.sidebarLogo,

     this.sidebarColor,

     this.sidebarDark,

     this.sidebarTopColor,

     this.hideMembers,

     this.membersCannotChat,

     this.primaryGroup,

     this.coins,

     this.members,

     this.athleteId,

     this.activityId,

     this.otherAthleteId,

     this.otherAthleteSex,

     this.followsYou,

     this.youFollow,

     this.role,

     this.newMessageCount,

     this.kicked,

     this.kickedById,

     this.lastSeenMessageId,

     this.muteUntil,

     this.sharedFolders,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final ChatTypeEnum? type;



  @JsonKey(
    
    name: r'coaching_group',
    required: false,
    includeIfNull: false,
  )


  final DateTime? coachingGroup;



  @JsonKey(
    
    name: r'updated',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updated;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'picture',
    required: false,
    includeIfNull: false,
  )


  final String? picture;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'pub',
    required: false,
    includeIfNull: false,
  )


  final bool? pub;



  @JsonKey(
    
    name: r'join_policy',
    required: false,
    includeIfNull: false,
  )


  final ChatJoinPolicyEnum? joinPolicy;



  @JsonKey(
    
    name: r'sidebar_logo',
    required: false,
    includeIfNull: false,
  )


  final String? sidebarLogo;



  @JsonKey(
    
    name: r'sidebar_color',
    required: false,
    includeIfNull: false,
  )


  final String? sidebarColor;



  @JsonKey(
    
    name: r'sidebar_dark',
    required: false,
    includeIfNull: false,
  )


  final bool? sidebarDark;



  @JsonKey(
    
    name: r'sidebar_top_color',
    required: false,
    includeIfNull: false,
  )


  final String? sidebarTopColor;



  @JsonKey(
    
    name: r'hide_members',
    required: false,
    includeIfNull: false,
  )


  final bool? hideMembers;



  @JsonKey(
    
    name: r'members_cannot_chat',
    required: false,
    includeIfNull: false,
  )


  final bool? membersCannotChat;



  @JsonKey(
    
    name: r'primary_group',
    required: false,
    includeIfNull: false,
  )


  final bool? primaryGroup;



  @JsonKey(
    
    name: r'coins',
    required: false,
    includeIfNull: false,
  )


  final double? coins;



  @JsonKey(
    
    name: r'members',
    required: false,
    includeIfNull: false,
  )


  final List<ChatMember>? members;



  @JsonKey(
    
    name: r'athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? athleteId;



  @JsonKey(
    
    name: r'activity_id',
    required: false,
    includeIfNull: false,
  )


  final String? activityId;



  @JsonKey(
    
    name: r'other_athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? otherAthleteId;



  @JsonKey(
    
    name: r'other_athlete_sex',
    required: false,
    includeIfNull: false,
  )


  final String? otherAthleteSex;



  @JsonKey(
    
    name: r'follows_you',
    required: false,
    includeIfNull: false,
  )


  final String? followsYou;



  @JsonKey(
    
    name: r'you_follow',
    required: false,
    includeIfNull: false,
  )


  final String? youFollow;



  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final ChatRoleEnum? role;



  @JsonKey(
    
    name: r'new_message_count',
    required: false,
    includeIfNull: false,
  )


  final int? newMessageCount;



  @JsonKey(
    
    name: r'kicked',
    required: false,
    includeIfNull: false,
  )


  final DateTime? kicked;



  @JsonKey(
    
    name: r'kicked_by_id',
    required: false,
    includeIfNull: false,
  )


  final String? kickedById;



  @JsonKey(
    
    name: r'last_seen_message_id',
    required: false,
    includeIfNull: false,
  )


  final int? lastSeenMessageId;



  @JsonKey(
    
    name: r'mute_until',
    required: false,
    includeIfNull: false,
  )


  final DateTime? muteUntil;



  @JsonKey(
    
    name: r'sharedFolders',
    required: false,
    includeIfNull: false,
  )


  final List<Folder>? sharedFolders;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Chat &&
      other.id == id &&
      other.type == type &&
      other.coachingGroup == coachingGroup &&
      other.updated == updated &&
      other.name == name &&
      other.picture == picture &&
      other.description == description &&
      other.url == url &&
      other.slug == slug &&
      other.pub == pub &&
      other.joinPolicy == joinPolicy &&
      other.sidebarLogo == sidebarLogo &&
      other.sidebarColor == sidebarColor &&
      other.sidebarDark == sidebarDark &&
      other.sidebarTopColor == sidebarTopColor &&
      other.hideMembers == hideMembers &&
      other.membersCannotChat == membersCannotChat &&
      other.primaryGroup == primaryGroup &&
      other.coins == coins &&
      other.members == members &&
      other.athleteId == athleteId &&
      other.activityId == activityId &&
      other.otherAthleteId == otherAthleteId &&
      other.otherAthleteSex == otherAthleteSex &&
      other.followsYou == followsYou &&
      other.youFollow == youFollow &&
      other.role == role &&
      other.newMessageCount == newMessageCount &&
      other.kicked == kicked &&
      other.kickedById == kickedById &&
      other.lastSeenMessageId == lastSeenMessageId &&
      other.muteUntil == muteUntil &&
      other.sharedFolders == sharedFolders;

    @override
    int get hashCode =>
        id.hashCode +
        type.hashCode +
        coachingGroup.hashCode +
        updated.hashCode +
        name.hashCode +
        picture.hashCode +
        description.hashCode +
        url.hashCode +
        slug.hashCode +
        pub.hashCode +
        joinPolicy.hashCode +
        sidebarLogo.hashCode +
        sidebarColor.hashCode +
        sidebarDark.hashCode +
        sidebarTopColor.hashCode +
        hideMembers.hashCode +
        membersCannotChat.hashCode +
        primaryGroup.hashCode +
        coins.hashCode +
        members.hashCode +
        athleteId.hashCode +
        activityId.hashCode +
        otherAthleteId.hashCode +
        otherAthleteSex.hashCode +
        followsYou.hashCode +
        youFollow.hashCode +
        role.hashCode +
        newMessageCount.hashCode +
        kicked.hashCode +
        kickedById.hashCode +
        lastSeenMessageId.hashCode +
        muteUntil.hashCode +
        sharedFolders.hashCode;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ChatTypeEnum {
@JsonValue(r'PRIVATE')
PRIVATE(r'PRIVATE'),
@JsonValue(r'GROUP')
GROUP(r'GROUP'),
@JsonValue(r'ACTIVITY')
ACTIVITY(r'ACTIVITY');

const ChatTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ChatJoinPolicyEnum {
@JsonValue(r'OPEN')
OPEN(r'OPEN'),
@JsonValue(r'ASK')
ASK(r'ASK'),
@JsonValue(r'INVITE_ONLY')
INVITE_ONLY(r'INVITE_ONLY');

const ChatJoinPolicyEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ChatRoleEnum {
@JsonValue(r'MEMBER')
MEMBER(r'MEMBER'),
@JsonValue(r'FOLLOWER')
FOLLOWER(r'FOLLOWER'),
@JsonValue(r'COACH')
COACH(r'COACH'),
@JsonValue(r'ADMIN')
ADMIN(r'ADMIN');

const ChatRoleEnum(this.value);

final String value;

@override
String toString() => value;
}


