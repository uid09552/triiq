// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_with.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SharedWithCWProxy {
  SharedWith id(String? id);

  SharedWith name(String? name);

  SharedWith profileMedium(String? profileMedium);

  SharedWith city(String? city);

  SharedWith state(String? state);

  SharedWith country(String? country);

  SharedWith timezone(String? timezone);

  SharedWith sex(String? sex);

  SharedWith bio(String? bio);

  SharedWith website(String? website);

  SharedWith email(String? email);

  SharedWith canEdit(bool? canEdit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharedWith(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharedWith(...).copyWith(id: 12, name: "My name")
  /// ````
  SharedWith call({
    String? id,
    String? name,
    String? profileMedium,
    String? city,
    String? state,
    String? country,
    String? timezone,
    String? sex,
    String? bio,
    String? website,
    String? email,
    bool? canEdit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSharedWith.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSharedWith.copyWith.fieldName(...)`
class _$SharedWithCWProxyImpl implements _$SharedWithCWProxy {
  const _$SharedWithCWProxyImpl(this._value);

  final SharedWith _value;

  @override
  SharedWith id(String? id) => this(id: id);

  @override
  SharedWith name(String? name) => this(name: name);

  @override
  SharedWith profileMedium(String? profileMedium) =>
      this(profileMedium: profileMedium);

  @override
  SharedWith city(String? city) => this(city: city);

  @override
  SharedWith state(String? state) => this(state: state);

  @override
  SharedWith country(String? country) => this(country: country);

  @override
  SharedWith timezone(String? timezone) => this(timezone: timezone);

  @override
  SharedWith sex(String? sex) => this(sex: sex);

  @override
  SharedWith bio(String? bio) => this(bio: bio);

  @override
  SharedWith website(String? website) => this(website: website);

  @override
  SharedWith email(String? email) => this(email: email);

  @override
  SharedWith canEdit(bool? canEdit) => this(canEdit: canEdit);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharedWith(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharedWith(...).copyWith(id: 12, name: "My name")
  /// ````
  SharedWith call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? profileMedium = const $CopyWithPlaceholder(),
    Object? city = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? country = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? bio = const $CopyWithPlaceholder(),
    Object? website = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? canEdit = const $CopyWithPlaceholder(),
  }) {
    return SharedWith(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      profileMedium: profileMedium == const $CopyWithPlaceholder()
          ? _value.profileMedium
          // ignore: cast_nullable_to_non_nullable
          : profileMedium as String?,
      city: city == const $CopyWithPlaceholder()
          ? _value.city
          // ignore: cast_nullable_to_non_nullable
          : city as String?,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String?,
      country: country == const $CopyWithPlaceholder()
          ? _value.country
          // ignore: cast_nullable_to_non_nullable
          : country as String?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as String?,
      bio: bio == const $CopyWithPlaceholder()
          ? _value.bio
          // ignore: cast_nullable_to_non_nullable
          : bio as String?,
      website: website == const $CopyWithPlaceholder()
          ? _value.website
          // ignore: cast_nullable_to_non_nullable
          : website as String?,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      canEdit: canEdit == const $CopyWithPlaceholder()
          ? _value.canEdit
          // ignore: cast_nullable_to_non_nullable
          : canEdit as bool?,
    );
  }
}

extension $SharedWithCopyWith on SharedWith {
  /// Returns a callable class that can be used as follows: `instanceOfSharedWith.copyWith(...)` or like so:`instanceOfSharedWith.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SharedWithCWProxy get copyWith => _$SharedWithCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharedWith _$SharedWithFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SharedWith', json, ($checkedConvert) {
      final val = SharedWith(
        id: $checkedConvert('id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        profileMedium: $checkedConvert('profile_medium', (v) => v as String?),
        city: $checkedConvert('city', (v) => v as String?),
        state: $checkedConvert('state', (v) => v as String?),
        country: $checkedConvert('country', (v) => v as String?),
        timezone: $checkedConvert('timezone', (v) => v as String?),
        sex: $checkedConvert('sex', (v) => v as String?),
        bio: $checkedConvert('bio', (v) => v as String?),
        website: $checkedConvert('website', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
        canEdit: $checkedConvert('canEdit', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'profileMedium': 'profile_medium'});

Map<String, dynamic> _$SharedWithToJson(SharedWith instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': ?instance.name,
      'profile_medium': ?instance.profileMedium,
      'city': ?instance.city,
      'state': ?instance.state,
      'country': ?instance.country,
      'timezone': ?instance.timezone,
      'sex': ?instance.sex,
      'bio': ?instance.bio,
      'website': ?instance.website,
      'email': ?instance.email,
      'canEdit': ?instance.canEdit,
    };
