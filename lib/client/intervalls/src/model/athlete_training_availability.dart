//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_training_availability.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteTrainingAvailability {
  /// Returns a new [AthleteTrainingAvailability] instance.
  AthleteTrainingAvailability({

     this.dayOfWeek,

     this.trainingAvailability,

     this.maxTrainingTime,

     this.canTrainSports,
  });

  @JsonKey(
    
    name: r'day_of_week',
    required: false,
    includeIfNull: false,
  )


  final int? dayOfWeek;



  @JsonKey(
    
    name: r'training_availability',
    required: false,
    includeIfNull: false,
  )


  final AthleteTrainingAvailabilityTrainingAvailabilityEnum? trainingAvailability;



  @JsonKey(
    
    name: r'max_training_time',
    required: false,
    includeIfNull: false,
  )


  final int? maxTrainingTime;



  @JsonKey(
    
    name: r'can_train_sports',
    required: false,
    includeIfNull: false,
  )


  final List<AthleteTrainingAvailabilityCanTrainSportsEnum>? canTrainSports;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AthleteTrainingAvailability &&
      other.dayOfWeek == dayOfWeek &&
      other.trainingAvailability == trainingAvailability &&
      other.maxTrainingTime == maxTrainingTime &&
      other.canTrainSports == canTrainSports;

    @override
    int get hashCode =>
        dayOfWeek.hashCode +
        trainingAvailability.hashCode +
        maxTrainingTime.hashCode +
        canTrainSports.hashCode;

  factory AthleteTrainingAvailability.fromJson(Map<String, dynamic> json) => _$AthleteTrainingAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteTrainingAvailabilityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AthleteTrainingAvailabilityTrainingAvailabilityEnum {
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'LIMITED')
LIMITED(r'LIMITED'),
@JsonValue(r'UNAVAILABLE')
UNAVAILABLE(r'UNAVAILABLE');

const AthleteTrainingAvailabilityTrainingAvailabilityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum AthleteTrainingAvailabilityCanTrainSportsEnum {
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

const AthleteTrainingAvailabilityCanTrainSportsEnum(this.value);

final String value;

@override
String toString() => value;
}


