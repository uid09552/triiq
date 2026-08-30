// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_search_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AthleteSearchResultCWProxy {
  AthleteSearchResult id(String? id);

  AthleteSearchResult name(String? name);

  AthleteSearchResult profileMedium(String? profileMedium);

  AthleteSearchResult city(String? city);

  AthleteSearchResult state(String? state);

  AthleteSearchResult country(String? country);

  AthleteSearchResult timezone(String? timezone);

  AthleteSearchResult sex(String? sex);

  AthleteSearchResult bio(String? bio);

  AthleteSearchResult website(String? website);

  AthleteSearchResult email(String? email);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteSearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteSearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteSearchResult call({
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
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAthleteSearchResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAthleteSearchResult.copyWith.fieldName(...)`
class _$AthleteSearchResultCWProxyImpl implements _$AthleteSearchResultCWProxy {
  const _$AthleteSearchResultCWProxyImpl(this._value);

  final AthleteSearchResult _value;

  @override
  AthleteSearchResult id(String? id) => this(id: id);

  @override
  AthleteSearchResult name(String? name) => this(name: name);

  @override
  AthleteSearchResult profileMedium(String? profileMedium) =>
      this(profileMedium: profileMedium);

  @override
  AthleteSearchResult city(String? city) => this(city: city);

  @override
  AthleteSearchResult state(String? state) => this(state: state);

  @override
  AthleteSearchResult country(String? country) => this(country: country);

  @override
  AthleteSearchResult timezone(String? timezone) => this(timezone: timezone);

  @override
  AthleteSearchResult sex(String? sex) => this(sex: sex);

  @override
  AthleteSearchResult bio(String? bio) => this(bio: bio);

  @override
  AthleteSearchResult website(String? website) => this(website: website);

  @override
  AthleteSearchResult email(String? email) => this(email: email);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AthleteSearchResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AthleteSearchResult(...).copyWith(id: 12, name: "My name")
  /// ````
  AthleteSearchResult call({
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
  }) {
    return AthleteSearchResult(
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
    );
  }
}

extension $AthleteSearchResultCopyWith on AthleteSearchResult {
  /// Returns a callable class that can be used as follows: `instanceOfAthleteSearchResult.copyWith(...)` or like so:`instanceOfAthleteSearchResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AthleteSearchResultCWProxy get copyWith =>
      _$AthleteSearchResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteSearchResult _$AthleteSearchResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AthleteSearchResult', json, ($checkedConvert) {
      final val = AthleteSearchResult(
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
      );
      return val;
    }, fieldKeyMap: const {'profileMedium': 'profile_medium'});

Map<String, dynamic> _$AthleteSearchResultToJson(
  AthleteSearchResult instance,
) => <String, dynamic>{
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
};
