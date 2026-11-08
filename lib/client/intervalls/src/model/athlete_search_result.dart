//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_search_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteSearchResult {
  /// Returns a new [AthleteSearchResult] instance.
  AthleteSearchResult({
    this.id,

    this.name,

    this.profileMedium,

    this.city,

    this.state,

    this.country,

    this.timezone,

    this.sex,

    this.bio,

    this.website,

    this.email,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'profile_medium', required: false, includeIfNull: false)
  final String? profileMedium;

  @JsonKey(name: r'city', required: false, includeIfNull: false)
  final String? city;

  @JsonKey(name: r'state', required: false, includeIfNull: false)
  final String? state;

  @JsonKey(name: r'country', required: false, includeIfNull: false)
  final String? country;

  @JsonKey(name: r'timezone', required: false, includeIfNull: false)
  final String? timezone;

  @JsonKey(name: r'sex', required: false, includeIfNull: false)
  final String? sex;

  @JsonKey(name: r'bio', required: false, includeIfNull: false)
  final String? bio;

  @JsonKey(name: r'website', required: false, includeIfNull: false)
  final String? website;

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AthleteSearchResult &&
          other.id == id &&
          other.name == name &&
          other.profileMedium == profileMedium &&
          other.city == city &&
          other.state == state &&
          other.country == country &&
          other.timezone == timezone &&
          other.sex == sex &&
          other.bio == bio &&
          other.website == website &&
          other.email == email;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      profileMedium.hashCode +
      city.hashCode +
      state.hashCode +
      country.hashCode +
      timezone.hashCode +
      sex.hashCode +
      bio.hashCode +
      website.hashCode +
      email.hashCode;

  factory AthleteSearchResult.fromJson(Map<String, dynamic> json) =>
      _$AthleteSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteSearchResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
