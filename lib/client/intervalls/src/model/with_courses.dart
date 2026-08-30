//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/athlete_search_result.dart';
import 'package:triiq/client/intervalls/src/model/course.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'with_courses.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WithCourses {
  /// Returns a new [WithCourses] instance.
  WithCourses({

     this.id,

     this.externalId,

     this.slug,

     this.athleteId,

     this.category,

     this.types,

     this.name,

     this.startDateLocal,

     this.updated,

     this.visibility,

     this.chatId,

     this.description,

     this.website,

     this.closingDateLocal,

     this.location,

     this.address,

     this.country,

     this.region,

     this.lat,

     this.lon,

     this.routeFile,

     this.polyline,

     this.bannerImageUrl,

     this.bannerImageWidth,

     this.bannerImageHeight,

     this.usageCount,

     this.isDuplicateVotes,

     this.duplicateIds,

     this.owner,

     this.courses,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'external_id',
    required: false,
    includeIfNull: false,
  )


  final String? externalId;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? athleteId;



  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final WithCoursesCategoryEnum? category;



  @JsonKey(
    
    name: r'types',
    required: false,
    includeIfNull: false,
  )


  final List<WithCoursesTypesEnum>? types;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'start_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? startDateLocal;



  @JsonKey(
    
    name: r'updated',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updated;



  @JsonKey(
    
    name: r'visibility',
    required: false,
    includeIfNull: false,
  )


  final WithCoursesVisibilityEnum? visibility;



  @JsonKey(
    
    name: r'chat_id',
    required: false,
    includeIfNull: false,
  )


  final int? chatId;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'website',
    required: false,
    includeIfNull: false,
  )


  final String? website;



  @JsonKey(
    
    name: r'closing_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? closingDateLocal;



  @JsonKey(
    
    name: r'location',
    required: false,
    includeIfNull: false,
  )


  final String? location;



  @JsonKey(
    
    name: r'address',
    required: false,
    includeIfNull: false,
  )


  final String? address;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    
    name: r'region',
    required: false,
    includeIfNull: false,
  )


  final String? region;



  @JsonKey(
    
    name: r'lat',
    required: false,
    includeIfNull: false,
  )


  final double? lat;



  @JsonKey(
    
    name: r'lon',
    required: false,
    includeIfNull: false,
  )


  final double? lon;



  @JsonKey(
    
    name: r'route_file',
    required: false,
    includeIfNull: false,
  )


  final String? routeFile;



  @JsonKey(
    
    name: r'polyline',
    required: false,
    includeIfNull: false,
  )


  final String? polyline;



  @JsonKey(
    
    name: r'banner_image_url',
    required: false,
    includeIfNull: false,
  )


  final String? bannerImageUrl;



  @JsonKey(
    
    name: r'banner_image_width',
    required: false,
    includeIfNull: false,
  )


  final int? bannerImageWidth;



  @JsonKey(
    
    name: r'banner_image_height',
    required: false,
    includeIfNull: false,
  )


  final int? bannerImageHeight;



  @JsonKey(
    
    name: r'usage_count',
    required: false,
    includeIfNull: false,
  )


  final int? usageCount;



  @JsonKey(
    
    name: r'is_duplicate_votes',
    required: false,
    includeIfNull: false,
  )


  final int? isDuplicateVotes;



  @JsonKey(
    
    name: r'duplicate_ids',
    required: false,
    includeIfNull: false,
  )


  final List<int>? duplicateIds;



  @JsonKey(
    
    name: r'owner',
    required: false,
    includeIfNull: false,
  )


  final AthleteSearchResult? owner;



  @JsonKey(
    
    name: r'courses',
    required: false,
    includeIfNull: false,
  )


  final List<Course>? courses;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WithCourses &&
      other.id == id &&
      other.externalId == externalId &&
      other.slug == slug &&
      other.athleteId == athleteId &&
      other.category == category &&
      other.types == types &&
      other.name == name &&
      other.startDateLocal == startDateLocal &&
      other.updated == updated &&
      other.visibility == visibility &&
      other.chatId == chatId &&
      other.description == description &&
      other.website == website &&
      other.closingDateLocal == closingDateLocal &&
      other.location == location &&
      other.address == address &&
      other.country == country &&
      other.region == region &&
      other.lat == lat &&
      other.lon == lon &&
      other.routeFile == routeFile &&
      other.polyline == polyline &&
      other.bannerImageUrl == bannerImageUrl &&
      other.bannerImageWidth == bannerImageWidth &&
      other.bannerImageHeight == bannerImageHeight &&
      other.usageCount == usageCount &&
      other.isDuplicateVotes == isDuplicateVotes &&
      other.duplicateIds == duplicateIds &&
      other.owner == owner &&
      other.courses == courses;

    @override
    int get hashCode =>
        id.hashCode +
        externalId.hashCode +
        slug.hashCode +
        athleteId.hashCode +
        category.hashCode +
        types.hashCode +
        name.hashCode +
        startDateLocal.hashCode +
        updated.hashCode +
        visibility.hashCode +
        chatId.hashCode +
        description.hashCode +
        website.hashCode +
        closingDateLocal.hashCode +
        location.hashCode +
        address.hashCode +
        country.hashCode +
        region.hashCode +
        lat.hashCode +
        lon.hashCode +
        routeFile.hashCode +
        polyline.hashCode +
        bannerImageUrl.hashCode +
        bannerImageWidth.hashCode +
        bannerImageHeight.hashCode +
        usageCount.hashCode +
        isDuplicateVotes.hashCode +
        duplicateIds.hashCode +
        owner.hashCode +
        courses.hashCode;

  factory WithCourses.fromJson(Map<String, dynamic> json) => _$WithCoursesFromJson(json);

  Map<String, dynamic> toJson() => _$WithCoursesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum WithCoursesCategoryEnum {
@JsonValue(r'RACE')
RACE(r'RACE'),
@JsonValue(r'WORKOUT')
WORKOUT(r'WORKOUT'),
@JsonValue(r'HIDDEN')
HIDDEN(r'HIDDEN');

const WithCoursesCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}


enum WithCoursesTypesEnum {
@JsonValue(r'Ride')
ride(r'Ride'),
@JsonValue(r'Run')
run(r'Run'),
@JsonValue(r'Swim')
swim(r'Swim'),
@JsonValue(r'WeightTraining')
weightTraining(r'WeightTraining'),
@JsonValue(r'Hike')
hike(r'Hike'),
@JsonValue(r'Walk')
walk(r'Walk'),
@JsonValue(r'AlpineSki')
alpineSki(r'AlpineSki'),
@JsonValue(r'BackcountrySki')
backcountrySki(r'BackcountrySki'),
@JsonValue(r'Badminton')
badminton(r'Badminton'),
@JsonValue(r'Canoeing')
canoeing(r'Canoeing'),
@JsonValue(r'Crossfit')
crossfit(r'Crossfit'),
@JsonValue(r'EBikeRide')
eBikeRide(r'EBikeRide'),
@JsonValue(r'EMountainBikeRide')
eMountainBikeRide(r'EMountainBikeRide'),
@JsonValue(r'Elliptical')
elliptical(r'Elliptical'),
@JsonValue(r'Golf')
golf(r'Golf'),
@JsonValue(r'GravelRide')
gravelRide(r'GravelRide'),
@JsonValue(r'TrackRide')
trackRide(r'TrackRide'),
@JsonValue(r'Handcycle')
handcycle(r'Handcycle'),
@JsonValue(r'HighIntensityIntervalTraining')
highIntensityIntervalTraining(r'HighIntensityIntervalTraining'),
@JsonValue(r'Hockey')
hockey(r'Hockey'),
@JsonValue(r'IceSkate')
iceSkate(r'IceSkate'),
@JsonValue(r'InlineSkate')
inlineSkate(r'InlineSkate'),
@JsonValue(r'Kayaking')
kayaking(r'Kayaking'),
@JsonValue(r'Kitesurf')
kitesurf(r'Kitesurf'),
@JsonValue(r'MountainBikeRide')
mountainBikeRide(r'MountainBikeRide'),
@JsonValue(r'Cyclocross')
cyclocross(r'Cyclocross'),
@JsonValue(r'NordicSki')
nordicSki(r'NordicSki'),
@JsonValue(r'OpenWaterSwim')
openWaterSwim(r'OpenWaterSwim'),
@JsonValue(r'Padel')
padel(r'Padel'),
@JsonValue(r'Pilates')
pilates(r'Pilates'),
@JsonValue(r'Pickleball')
pickleball(r'Pickleball'),
@JsonValue(r'Racquetball')
racquetball(r'Racquetball'),
@JsonValue(r'Rugby')
rugby(r'Rugby'),
@JsonValue(r'RockClimbing')
rockClimbing(r'RockClimbing'),
@JsonValue(r'RollerSki')
rollerSki(r'RollerSki'),
@JsonValue(r'Rowing')
rowing(r'Rowing'),
@JsonValue(r'Sail')
sail(r'Sail'),
@JsonValue(r'Skateboard')
skateboard(r'Skateboard'),
@JsonValue(r'Snowboard')
snowboard(r'Snowboard'),
@JsonValue(r'Snowshoe')
snowshoe(r'Snowshoe'),
@JsonValue(r'Soccer')
soccer(r'Soccer'),
@JsonValue(r'Squash')
squash(r'Squash'),
@JsonValue(r'StairStepper')
stairStepper(r'StairStepper'),
@JsonValue(r'StandUpPaddling')
standUpPaddling(r'StandUpPaddling'),
@JsonValue(r'Surfing')
surfing(r'Surfing'),
@JsonValue(r'TableTennis')
tableTennis(r'TableTennis'),
@JsonValue(r'Tennis')
tennis(r'Tennis'),
@JsonValue(r'TrailRun')
trailRun(r'TrailRun'),
@JsonValue(r'Transition')
transition(r'Transition'),
@JsonValue(r'Velomobile')
velomobile(r'Velomobile'),
@JsonValue(r'VirtualRide')
virtualRide(r'VirtualRide'),
@JsonValue(r'VirtualRow')
virtualRow(r'VirtualRow'),
@JsonValue(r'VirtualRun')
virtualRun(r'VirtualRun'),
@JsonValue(r'VirtualSki')
virtualSki(r'VirtualSki'),
@JsonValue(r'WaterSport')
waterSport(r'WaterSport'),
@JsonValue(r'Wheelchair')
wheelchair(r'Wheelchair'),
@JsonValue(r'Windsurf')
windsurf(r'Windsurf'),
@JsonValue(r'Workout')
workout(r'Workout'),
@JsonValue(r'Yoga')
yoga(r'Yoga'),
@JsonValue(r'Other')
other(r'Other');

const WithCoursesTypesEnum(this.value);

final String value;

@override
String toString() => value;
}


enum WithCoursesVisibilityEnum {
@JsonValue(r'PUBLIC')
PUBLIC(r'PUBLIC'),
@JsonValue(r'GROUP')
GROUP(r'GROUP');

const WithCoursesVisibilityEnum(this.value);

final String value;

@override
String toString() => value;
}


