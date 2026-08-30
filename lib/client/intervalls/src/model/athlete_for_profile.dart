//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_for_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteForProfile {
  /// Returns a new [AthleteForProfile] instance.
  AthleteForProfile({

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

     this.countries,

     this.languages,

     this.icuCoach,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'profile_medium',
    required: false,
    includeIfNull: false,
  )


  final String? profileMedium;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'sex',
    required: false,
    includeIfNull: false,
  )


  final String? sex;



  @JsonKey(
    
    name: r'bio',
    required: false,
    includeIfNull: false,
  )


  final String? bio;



  @JsonKey(
    
    name: r'website',
    required: false,
    includeIfNull: false,
  )


  final String? website;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'countries',
    required: false,
    includeIfNull: false,
  )


  final List<String>? countries;



  @JsonKey(
    
    name: r'languages',
    required: false,
    includeIfNull: false,
  )


  final List<String>? languages;



  @JsonKey(
    
    name: r'icu_coach',
    required: false,
    includeIfNull: false,
  )


  final bool? icuCoach;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AthleteForProfile &&
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
      other.email == email &&
      other.countries == countries &&
      other.languages == languages &&
      other.icuCoach == icuCoach;

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
        email.hashCode +
        countries.hashCode +
        languages.hashCode +
        icuCoach.hashCode;

  factory AthleteForProfile.fromJson(Map<String, dynamic> json) => _$AthleteForProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteForProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

