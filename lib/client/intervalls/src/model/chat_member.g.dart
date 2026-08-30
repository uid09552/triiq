// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChatMemberCWProxy {
  ChatMember athleteId(String? athleteId);

  ChatMember name(String? name);

  ChatMember profileMedium(String? profileMedium);

  ChatMember role(ChatMemberRoleEnum? role);

  ChatMember coach(bool? coach);

  ChatMember plan(ChatMemberPlanEnum? plan);

  ChatMember acceptedCoachingGroup(DateTime? acceptedCoachingGroup);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatMember(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatMember call({
    String? athleteId,
    String? name,
    String? profileMedium,
    ChatMemberRoleEnum? role,
    bool? coach,
    ChatMemberPlanEnum? plan,
    DateTime? acceptedCoachingGroup,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChatMember.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChatMember.copyWith.fieldName(...)`
class _$ChatMemberCWProxyImpl implements _$ChatMemberCWProxy {
  const _$ChatMemberCWProxyImpl(this._value);

  final ChatMember _value;

  @override
  ChatMember athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  ChatMember name(String? name) => this(name: name);

  @override
  ChatMember profileMedium(String? profileMedium) =>
      this(profileMedium: profileMedium);

  @override
  ChatMember role(ChatMemberRoleEnum? role) => this(role: role);

  @override
  ChatMember coach(bool? coach) => this(coach: coach);

  @override
  ChatMember plan(ChatMemberPlanEnum? plan) => this(plan: plan);

  @override
  ChatMember acceptedCoachingGroup(DateTime? acceptedCoachingGroup) =>
      this(acceptedCoachingGroup: acceptedCoachingGroup);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChatMember(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChatMember(...).copyWith(id: 12, name: "My name")
  /// ````
  ChatMember call({
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? profileMedium = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? coach = const $CopyWithPlaceholder(),
    Object? plan = const $CopyWithPlaceholder(),
    Object? acceptedCoachingGroup = const $CopyWithPlaceholder(),
  }) {
    return ChatMember(
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      profileMedium: profileMedium == const $CopyWithPlaceholder()
          ? _value.profileMedium
          // ignore: cast_nullable_to_non_nullable
          : profileMedium as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as ChatMemberRoleEnum?,
      coach: coach == const $CopyWithPlaceholder()
          ? _value.coach
          // ignore: cast_nullable_to_non_nullable
          : coach as bool?,
      plan: plan == const $CopyWithPlaceholder()
          ? _value.plan
          // ignore: cast_nullable_to_non_nullable
          : plan as ChatMemberPlanEnum?,
      acceptedCoachingGroup:
          acceptedCoachingGroup == const $CopyWithPlaceholder()
          ? _value.acceptedCoachingGroup
          // ignore: cast_nullable_to_non_nullable
          : acceptedCoachingGroup as DateTime?,
    );
  }
}

extension $ChatMemberCopyWith on ChatMember {
  /// Returns a callable class that can be used as follows: `instanceOfChatMember.copyWith(...)` or like so:`instanceOfChatMember.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChatMemberCWProxy get copyWith => _$ChatMemberCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMember _$ChatMemberFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ChatMember',
  json,
  ($checkedConvert) {
    final val = ChatMember(
      athleteId: $checkedConvert('athlete_id', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      profileMedium: $checkedConvert('profile_medium', (v) => v as String?),
      role: $checkedConvert(
        'role',
        (v) => $enumDecodeNullable(_$ChatMemberRoleEnumEnumMap, v),
      ),
      coach: $checkedConvert('coach', (v) => v as bool?),
      plan: $checkedConvert(
        'plan',
        (v) => $enumDecodeNullable(_$ChatMemberPlanEnumEnumMap, v),
      ),
      acceptedCoachingGroup: $checkedConvert(
        'accepted_coaching_group',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'athleteId': 'athlete_id',
    'profileMedium': 'profile_medium',
    'acceptedCoachingGroup': 'accepted_coaching_group',
  },
);

Map<String, dynamic> _$ChatMemberToJson(
  ChatMember instance,
) => <String, dynamic>{
  'athlete_id': ?instance.athleteId,
  'name': ?instance.name,
  'profile_medium': ?instance.profileMedium,
  'role': ?_$ChatMemberRoleEnumEnumMap[instance.role],
  'coach': ?instance.coach,
  'plan': ?_$ChatMemberPlanEnumEnumMap[instance.plan],
  'accepted_coaching_group': ?instance.acceptedCoachingGroup?.toIso8601String(),
};

const _$ChatMemberRoleEnumEnumMap = {
  ChatMemberRoleEnum.MEMBER: 'MEMBER',
  ChatMemberRoleEnum.FOLLOWER: 'FOLLOWER',
  ChatMemberRoleEnum.COACH: 'COACH',
  ChatMemberRoleEnum.ADMIN: 'ADMIN',
};

const _$ChatMemberPlanEnumEnumMap = {
  ChatMemberPlanEnum.FREE: 'FREE',
  ChatMemberPlanEnum.PREMIUM: 'PREMIUM',
  ChatMemberPlanEnum.SUPPORTER: 'SUPPORTER',
  ChatMemberPlanEnum.WHITELABEL: 'WHITELABEL',
};
