// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatCWProxy {
  Chat id(int? id);

  Chat type(ChatTypeEnum? type);

  Chat coachingGroup(DateTime? coachingGroup);

  Chat updated(DateTime? updated);

  Chat name(String? name);

  Chat picture(String? picture);

  Chat description(String? description);

  Chat url(String? url);

  Chat slug(String? slug);

  Chat pub(bool? pub);

  Chat joinPolicy(ChatJoinPolicyEnum? joinPolicy);

  Chat sidebarLogo(String? sidebarLogo);

  Chat sidebarColor(String? sidebarColor);

  Chat sidebarDark(bool? sidebarDark);

  Chat sidebarTopColor(String? sidebarTopColor);

  Chat hideMembers(bool? hideMembers);

  Chat membersCannotChat(bool? membersCannotChat);

  Chat primaryGroup(bool? primaryGroup);

  Chat coins(double? coins);

  Chat members(List<ChatMember>? members);

  Chat athleteId(String? athleteId);

  Chat activityId(String? activityId);

  Chat otherAthleteId(String? otherAthleteId);

  Chat otherAthleteSex(String? otherAthleteSex);

  Chat followsYou(String? followsYou);

  Chat youFollow(String? youFollow);

  Chat role(ChatRoleEnum? role);

  Chat newMessageCount(int? newMessageCount);

  Chat kicked(DateTime? kicked);

  Chat kickedById(String? kickedById);

  Chat lastSeenMessageId(int? lastSeenMessageId);

  Chat muteUntil(DateTime? muteUntil);

  Chat sharedFolders(List<Folder>? sharedFolders);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Chat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Chat(...).copyWith(id: 12, name: "My name")
  /// ````
  Chat call({
    int? id,
    ChatTypeEnum? type,
    DateTime? coachingGroup,
    DateTime? updated,
    String? name,
    String? picture,
    String? description,
    String? url,
    String? slug,
    bool? pub,
    ChatJoinPolicyEnum? joinPolicy,
    String? sidebarLogo,
    String? sidebarColor,
    bool? sidebarDark,
    String? sidebarTopColor,
    bool? hideMembers,
    bool? membersCannotChat,
    bool? primaryGroup,
    double? coins,
    List<ChatMember>? members,
    String? athleteId,
    String? activityId,
    String? otherAthleteId,
    String? otherAthleteSex,
    String? followsYou,
    String? youFollow,
    ChatRoleEnum? role,
    int? newMessageCount,
    DateTime? kicked,
    String? kickedById,
    int? lastSeenMessageId,
    DateTime? muteUntil,
    List<Folder>? sharedFolders,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChat.copyWith.fieldName(...)`
class _$ChatCWProxyImpl implements _$ChatCWProxy {
  const _$ChatCWProxyImpl(this._value);

  final Chat _value;

  @override
  Chat id(int? id) => this(id: id);

  @override
  Chat type(ChatTypeEnum? type) => this(type: type);

  @override
  Chat coachingGroup(DateTime? coachingGroup) =>
      this(coachingGroup: coachingGroup);

  @override
  Chat updated(DateTime? updated) => this(updated: updated);

  @override
  Chat name(String? name) => this(name: name);

  @override
  Chat picture(String? picture) => this(picture: picture);

  @override
  Chat description(String? description) => this(description: description);

  @override
  Chat url(String? url) => this(url: url);

  @override
  Chat slug(String? slug) => this(slug: slug);

  @override
  Chat pub(bool? pub) => this(pub: pub);

  @override
  Chat joinPolicy(ChatJoinPolicyEnum? joinPolicy) =>
      this(joinPolicy: joinPolicy);

  @override
  Chat sidebarLogo(String? sidebarLogo) => this(sidebarLogo: sidebarLogo);

  @override
  Chat sidebarColor(String? sidebarColor) => this(sidebarColor: sidebarColor);

  @override
  Chat sidebarDark(bool? sidebarDark) => this(sidebarDark: sidebarDark);

  @override
  Chat sidebarTopColor(String? sidebarTopColor) =>
      this(sidebarTopColor: sidebarTopColor);

  @override
  Chat hideMembers(bool? hideMembers) => this(hideMembers: hideMembers);

  @override
  Chat membersCannotChat(bool? membersCannotChat) =>
      this(membersCannotChat: membersCannotChat);

  @override
  Chat primaryGroup(bool? primaryGroup) => this(primaryGroup: primaryGroup);

  @override
  Chat coins(double? coins) => this(coins: coins);

  @override
  Chat members(List<ChatMember>? members) => this(members: members);

  @override
  Chat athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  Chat activityId(String? activityId) => this(activityId: activityId);

  @override
  Chat otherAthleteId(String? otherAthleteId) =>
      this(otherAthleteId: otherAthleteId);

  @override
  Chat otherAthleteSex(String? otherAthleteSex) =>
      this(otherAthleteSex: otherAthleteSex);

  @override
  Chat followsYou(String? followsYou) => this(followsYou: followsYou);

  @override
  Chat youFollow(String? youFollow) => this(youFollow: youFollow);

  @override
  Chat role(ChatRoleEnum? role) => this(role: role);

  @override
  Chat newMessageCount(int? newMessageCount) =>
      this(newMessageCount: newMessageCount);

  @override
  Chat kicked(DateTime? kicked) => this(kicked: kicked);

  @override
  Chat kickedById(String? kickedById) => this(kickedById: kickedById);

  @override
  Chat lastSeenMessageId(int? lastSeenMessageId) =>
      this(lastSeenMessageId: lastSeenMessageId);

  @override
  Chat muteUntil(DateTime? muteUntil) => this(muteUntil: muteUntil);

  @override
  Chat sharedFolders(List<Folder>? sharedFolders) =>
      this(sharedFolders: sharedFolders);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Chat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Chat(...).copyWith(id: 12, name: "My name")
  /// ````
  Chat call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? coachingGroup = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? picture = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? slug = const $CopyWithPlaceholder(),
    Object? pub = const $CopyWithPlaceholder(),
    Object? joinPolicy = const $CopyWithPlaceholder(),
    Object? sidebarLogo = const $CopyWithPlaceholder(),
    Object? sidebarColor = const $CopyWithPlaceholder(),
    Object? sidebarDark = const $CopyWithPlaceholder(),
    Object? sidebarTopColor = const $CopyWithPlaceholder(),
    Object? hideMembers = const $CopyWithPlaceholder(),
    Object? membersCannotChat = const $CopyWithPlaceholder(),
    Object? primaryGroup = const $CopyWithPlaceholder(),
    Object? coins = const $CopyWithPlaceholder(),
    Object? members = const $CopyWithPlaceholder(),
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? activityId = const $CopyWithPlaceholder(),
    Object? otherAthleteId = const $CopyWithPlaceholder(),
    Object? otherAthleteSex = const $CopyWithPlaceholder(),
    Object? followsYou = const $CopyWithPlaceholder(),
    Object? youFollow = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? newMessageCount = const $CopyWithPlaceholder(),
    Object? kicked = const $CopyWithPlaceholder(),
    Object? kickedById = const $CopyWithPlaceholder(),
    Object? lastSeenMessageId = const $CopyWithPlaceholder(),
    Object? muteUntil = const $CopyWithPlaceholder(),
    Object? sharedFolders = const $CopyWithPlaceholder(),
  }) {
    return Chat(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ChatTypeEnum?,
      coachingGroup: coachingGroup == const $CopyWithPlaceholder()
          ? _value.coachingGroup
          // ignore: cast_nullable_to_non_nullable
          : coachingGroup as DateTime?,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as DateTime?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      picture: picture == const $CopyWithPlaceholder()
          ? _value.picture
          // ignore: cast_nullable_to_non_nullable
          : picture as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String?,
      slug: slug == const $CopyWithPlaceholder()
          ? _value.slug
          // ignore: cast_nullable_to_non_nullable
          : slug as String?,
      pub: pub == const $CopyWithPlaceholder()
          ? _value.pub
          // ignore: cast_nullable_to_non_nullable
          : pub as bool?,
      joinPolicy: joinPolicy == const $CopyWithPlaceholder()
          ? _value.joinPolicy
          // ignore: cast_nullable_to_non_nullable
          : joinPolicy as ChatJoinPolicyEnum?,
      sidebarLogo: sidebarLogo == const $CopyWithPlaceholder()
          ? _value.sidebarLogo
          // ignore: cast_nullable_to_non_nullable
          : sidebarLogo as String?,
      sidebarColor: sidebarColor == const $CopyWithPlaceholder()
          ? _value.sidebarColor
          // ignore: cast_nullable_to_non_nullable
          : sidebarColor as String?,
      sidebarDark: sidebarDark == const $CopyWithPlaceholder()
          ? _value.sidebarDark
          // ignore: cast_nullable_to_non_nullable
          : sidebarDark as bool?,
      sidebarTopColor: sidebarTopColor == const $CopyWithPlaceholder()
          ? _value.sidebarTopColor
          // ignore: cast_nullable_to_non_nullable
          : sidebarTopColor as String?,
      hideMembers: hideMembers == const $CopyWithPlaceholder()
          ? _value.hideMembers
          // ignore: cast_nullable_to_non_nullable
          : hideMembers as bool?,
      membersCannotChat: membersCannotChat == const $CopyWithPlaceholder()
          ? _value.membersCannotChat
          // ignore: cast_nullable_to_non_nullable
          : membersCannotChat as bool?,
      primaryGroup: primaryGroup == const $CopyWithPlaceholder()
          ? _value.primaryGroup
          // ignore: cast_nullable_to_non_nullable
          : primaryGroup as bool?,
      coins: coins == const $CopyWithPlaceholder()
          ? _value.coins
          // ignore: cast_nullable_to_non_nullable
          : coins as double?,
      members: members == const $CopyWithPlaceholder()
          ? _value.members
          // ignore: cast_nullable_to_non_nullable
          : members as List<ChatMember>?,
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      activityId: activityId == const $CopyWithPlaceholder()
          ? _value.activityId
          // ignore: cast_nullable_to_non_nullable
          : activityId as String?,
      otherAthleteId: otherAthleteId == const $CopyWithPlaceholder()
          ? _value.otherAthleteId
          // ignore: cast_nullable_to_non_nullable
          : otherAthleteId as String?,
      otherAthleteSex: otherAthleteSex == const $CopyWithPlaceholder()
          ? _value.otherAthleteSex
          // ignore: cast_nullable_to_non_nullable
          : otherAthleteSex as String?,
      followsYou: followsYou == const $CopyWithPlaceholder()
          ? _value.followsYou
          // ignore: cast_nullable_to_non_nullable
          : followsYou as String?,
      youFollow: youFollow == const $CopyWithPlaceholder()
          ? _value.youFollow
          // ignore: cast_nullable_to_non_nullable
          : youFollow as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as ChatRoleEnum?,
      newMessageCount: newMessageCount == const $CopyWithPlaceholder()
          ? _value.newMessageCount
          // ignore: cast_nullable_to_non_nullable
          : newMessageCount as int?,
      kicked: kicked == const $CopyWithPlaceholder()
          ? _value.kicked
          // ignore: cast_nullable_to_non_nullable
          : kicked as DateTime?,
      kickedById: kickedById == const $CopyWithPlaceholder()
          ? _value.kickedById
          // ignore: cast_nullable_to_non_nullable
          : kickedById as String?,
      lastSeenMessageId: lastSeenMessageId == const $CopyWithPlaceholder()
          ? _value.lastSeenMessageId
          // ignore: cast_nullable_to_non_nullable
          : lastSeenMessageId as int?,
      muteUntil: muteUntil == const $CopyWithPlaceholder()
          ? _value.muteUntil
          // ignore: cast_nullable_to_non_nullable
          : muteUntil as DateTime?,
      sharedFolders: sharedFolders == const $CopyWithPlaceholder()
          ? _value.sharedFolders
          // ignore: cast_nullable_to_non_nullable
          : sharedFolders as List<Folder>?,
    );
  }
}

extension $ChatCopyWith on Chat {
  /// Returns a callable class that can be used as follows: `instanceOfChat.copyWith(...)` or like so:`instanceOfChat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatCWProxy get copyWith => _$ChatCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Chat',
  json,
  ($checkedConvert) {
    final val = Chat(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$ChatTypeEnumEnumMap, v),
      ),
      coachingGroup: $checkedConvert(
        'coaching_group',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updated: $checkedConvert(
        'updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      name: $checkedConvert('name', (v) => v as String?),
      picture: $checkedConvert('picture', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      url: $checkedConvert('url', (v) => v as String?),
      slug: $checkedConvert('slug', (v) => v as String?),
      pub: $checkedConvert('pub', (v) => v as bool?),
      joinPolicy: $checkedConvert(
        'join_policy',
        (v) => $enumDecodeNullable(_$ChatJoinPolicyEnumEnumMap, v),
      ),
      sidebarLogo: $checkedConvert('sidebar_logo', (v) => v as String?),
      sidebarColor: $checkedConvert('sidebar_color', (v) => v as String?),
      sidebarDark: $checkedConvert('sidebar_dark', (v) => v as bool?),
      sidebarTopColor: $checkedConvert(
        'sidebar_top_color',
        (v) => v as String?,
      ),
      hideMembers: $checkedConvert('hide_members', (v) => v as bool?),
      membersCannotChat: $checkedConvert(
        'members_cannot_chat',
        (v) => v as bool?,
      ),
      primaryGroup: $checkedConvert('primary_group', (v) => v as bool?),
      coins: $checkedConvert('coins', (v) => (v as num?)?.toDouble()),
      members: $checkedConvert(
        'members',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ChatMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      athleteId: $checkedConvert('athlete_id', (v) => v as String?),
      activityId: $checkedConvert('activity_id', (v) => v as String?),
      otherAthleteId: $checkedConvert('other_athlete_id', (v) => v as String?),
      otherAthleteSex: $checkedConvert(
        'other_athlete_sex',
        (v) => v as String?,
      ),
      followsYou: $checkedConvert('follows_you', (v) => v as String?),
      youFollow: $checkedConvert('you_follow', (v) => v as String?),
      role: $checkedConvert(
        'role',
        (v) => $enumDecodeNullable(_$ChatRoleEnumEnumMap, v),
      ),
      newMessageCount: $checkedConvert(
        'new_message_count',
        (v) => (v as num?)?.toInt(),
      ),
      kicked: $checkedConvert(
        'kicked',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      kickedById: $checkedConvert('kicked_by_id', (v) => v as String?),
      lastSeenMessageId: $checkedConvert(
        'last_seen_message_id',
        (v) => (v as num?)?.toInt(),
      ),
      muteUntil: $checkedConvert(
        'mute_until',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sharedFolders: $checkedConvert(
        'sharedFolders',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Folder.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'coachingGroup': 'coaching_group',
    'joinPolicy': 'join_policy',
    'sidebarLogo': 'sidebar_logo',
    'sidebarColor': 'sidebar_color',
    'sidebarDark': 'sidebar_dark',
    'sidebarTopColor': 'sidebar_top_color',
    'hideMembers': 'hide_members',
    'membersCannotChat': 'members_cannot_chat',
    'primaryGroup': 'primary_group',
    'athleteId': 'athlete_id',
    'activityId': 'activity_id',
    'otherAthleteId': 'other_athlete_id',
    'otherAthleteSex': 'other_athlete_sex',
    'followsYou': 'follows_you',
    'youFollow': 'you_follow',
    'newMessageCount': 'new_message_count',
    'kickedById': 'kicked_by_id',
    'lastSeenMessageId': 'last_seen_message_id',
    'muteUntil': 'mute_until',
  },
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': ?instance.id,
  'type': ?_$ChatTypeEnumEnumMap[instance.type],
  'coaching_group': ?instance.coachingGroup?.toIso8601String(),
  'updated': ?instance.updated?.toIso8601String(),
  'name': ?instance.name,
  'picture': ?instance.picture,
  'description': ?instance.description,
  'url': ?instance.url,
  'slug': ?instance.slug,
  'pub': ?instance.pub,
  'join_policy': ?_$ChatJoinPolicyEnumEnumMap[instance.joinPolicy],
  'sidebar_logo': ?instance.sidebarLogo,
  'sidebar_color': ?instance.sidebarColor,
  'sidebar_dark': ?instance.sidebarDark,
  'sidebar_top_color': ?instance.sidebarTopColor,
  'hide_members': ?instance.hideMembers,
  'members_cannot_chat': ?instance.membersCannotChat,
  'primary_group': ?instance.primaryGroup,
  'coins': ?instance.coins,
  'members': ?instance.members?.map((e) => e.toJson()).toList(),
  'athlete_id': ?instance.athleteId,
  'activity_id': ?instance.activityId,
  'other_athlete_id': ?instance.otherAthleteId,
  'other_athlete_sex': ?instance.otherAthleteSex,
  'follows_you': ?instance.followsYou,
  'you_follow': ?instance.youFollow,
  'role': ?_$ChatRoleEnumEnumMap[instance.role],
  'new_message_count': ?instance.newMessageCount,
  'kicked': ?instance.kicked?.toIso8601String(),
  'kicked_by_id': ?instance.kickedById,
  'last_seen_message_id': ?instance.lastSeenMessageId,
  'mute_until': ?instance.muteUntil?.toIso8601String(),
  'sharedFolders': ?instance.sharedFolders?.map((e) => e.toJson()).toList(),
};

const _$ChatTypeEnumEnumMap = {
  ChatTypeEnum.PRIVATE: 'PRIVATE',
  ChatTypeEnum.GROUP: 'GROUP',
  ChatTypeEnum.ACTIVITY: 'ACTIVITY',
};

const _$ChatJoinPolicyEnumEnumMap = {
  ChatJoinPolicyEnum.OPEN: 'OPEN',
  ChatJoinPolicyEnum.ASK: 'ASK',
  ChatJoinPolicyEnum.INVITE_ONLY: 'INVITE_ONLY',
};

const _$ChatRoleEnumEnumMap = {
  ChatRoleEnum.MEMBER: 'MEMBER',
  ChatRoleEnum.FOLLOWER: 'FOLLOWER',
  ChatRoleEnum.COACH: 'COACH',
  ChatRoleEnum.ADMIN: 'ADMIN',
};
