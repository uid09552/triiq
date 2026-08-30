// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_profile.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteProfileCWProxy {
  AthleteProfile athlete(AthleteForProfile? athlete);

  AthleteProfile sharedFolders(List<Folder>? sharedFolders);

  AthleteProfile customItems(List<CustomItem>? customItems);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteProfile call({
    AthleteForProfile? athlete,
    List<Folder>? sharedFolders,
    List<CustomItem>? customItems,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteProfile.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteProfile.copyWith.fieldName(...)`
class _$AthleteProfileCWProxyImpl implements _$AthleteProfileCWProxy {
  const _$AthleteProfileCWProxyImpl(this._value);

  final AthleteProfile _value;

  @override
  AthleteProfile athlete(AthleteForProfile? athlete) => this(athlete: athlete);

  @override
  AthleteProfile sharedFolders(List<Folder>? sharedFolders) =>
      this(sharedFolders: sharedFolders);

  @override
  AthleteProfile customItems(List<CustomItem>? customItems) =>
      this(customItems: customItems);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteProfile(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteProfile(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteProfile call({
    Object? athlete = const $CopyWithPlaceholder(),
    Object? sharedFolders = const $CopyWithPlaceholder(),
    Object? customItems = const $CopyWithPlaceholder(),
  }) {
    return AthleteProfile(
      athlete: athlete == const $CopyWithPlaceholder()
          ? _value.athlete
          // ignore: cast_nullable_to_non_nullable
          : athlete as AthleteForProfile?,
      sharedFolders: sharedFolders == const $CopyWithPlaceholder()
          ? _value.sharedFolders
          // ignore: cast_nullable_to_non_nullable
          : sharedFolders as List<Folder>?,
      customItems: customItems == const $CopyWithPlaceholder()
          ? _value.customItems
          // ignore: cast_nullable_to_non_nullable
          : customItems as List<CustomItem>?,
    );
  }
}

extension $AthleteProfileCopyWith on AthleteProfile {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteProfile.copyWith(...)` or like so:`instanceOfAthleteProfile.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteProfileCWProxy get copyWith => _$AthleteProfileCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteProfile _$AthleteProfileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AthleteProfile', json, ($checkedConvert) {
      final val = AthleteProfile(
        athlete: $checkedConvert(
          'athlete',
          (v) => v == null
              ? null
              : AthleteForProfile.fromJson(v as Map<String, dynamic>),
        ),
        sharedFolders: $checkedConvert(
          'sharedFolders',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Folder.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        customItems: $checkedConvert(
          'customItems',
          (v) => (v as List<dynamic>?)
              ?.map((e) => CustomItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AthleteProfileToJson(AthleteProfile instance) =>
    <String, dynamic>{
      'athlete': ?instance.athlete?.toJson(),
      'sharedFolders': ?instance.sharedFolders?.map((e) => e.toJson()).toList(),
      'customItems': ?instance.customItems?.map((e) => e.toJson()).toList(),
    };
