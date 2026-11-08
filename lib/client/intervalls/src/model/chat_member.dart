//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_member.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChatMember {
  /// Returns a new [ChatMember] instance.
  ChatMember({
    this.athleteId,

    this.name,

    this.profileMedium,

    this.role,

    this.coach,

    this.plan,

    this.acceptedCoachingGroup,
  });

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'profile_medium', required: false, includeIfNull: false)
  final String? profileMedium;

  @JsonKey(name: r'role', required: false, includeIfNull: false)
  final ChatMemberRoleEnum? role;

  @JsonKey(name: r'coach', required: false, includeIfNull: false)
  final bool? coach;

  @JsonKey(name: r'plan', required: false, includeIfNull: false)
  final ChatMemberPlanEnum? plan;

  @JsonKey(
    name: r'accepted_coaching_group',
    required: false,
    includeIfNull: false,
  )
  final DateTime? acceptedCoachingGroup;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMember &&
          other.athleteId == athleteId &&
          other.name == name &&
          other.profileMedium == profileMedium &&
          other.role == role &&
          other.coach == coach &&
          other.plan == plan &&
          other.acceptedCoachingGroup == acceptedCoachingGroup;

  @override
  int get hashCode =>
      athleteId.hashCode +
      name.hashCode +
      profileMedium.hashCode +
      role.hashCode +
      coach.hashCode +
      plan.hashCode +
      acceptedCoachingGroup.hashCode;

  factory ChatMember.fromJson(Map<String, dynamic> json) =>
      _$ChatMemberFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ChatMemberRoleEnum {
  @JsonValue(r'MEMBER')
  MEMBER(r'MEMBER'),
  @JsonValue(r'FOLLOWER')
  FOLLOWER(r'FOLLOWER'),
  @JsonValue(r'COACH')
  COACH(r'COACH'),
  @JsonValue(r'ADMIN')
  ADMIN(r'ADMIN');

  const ChatMemberRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ChatMemberPlanEnum {
  @JsonValue(r'FREE')
  FREE(r'FREE'),
  @JsonValue(r'PREMIUM')
  PREMIUM(r'PREMIUM'),
  @JsonValue(r'SUPPORTER')
  SUPPORTER(r'SUPPORTER'),
  @JsonValue(r'WHITELABEL')
  WHITELABEL(r'WHITELABEL');

  const ChatMemberPlanEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
