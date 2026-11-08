//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/category_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'summary_with_cats.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SummaryWithCats {
  /// Returns a new [SummaryWithCats] instance.
  SummaryWithCats({
    this.count,

    this.time,

    this.movingTime,

    this.elapsedTime,

    this.calories,

    this.totalElevationGain,

    this.trainingLoad,

    this.srpe,

    this.distance,

    this.eftp,

    this.eftpPerKg,

    this.date,

    this.athleteId,

    this.athleteName,

    this.email,

    this.externalId,

    this.fitness,

    this.fatigue,

    this.form,

    this.rampRate,

    this.weight,

    this.timeInZones,

    this.timeInZonesTot,

    this.byCategory,

    this.mostRecentWellnessId,
  });

  @JsonKey(name: r'count', required: false, includeIfNull: false)
  final int? count;

  @JsonKey(name: r'time', required: false, includeIfNull: false)
  final int? time;

  @JsonKey(name: r'moving_time', required: false, includeIfNull: false)
  final int? movingTime;

  @JsonKey(name: r'elapsed_time', required: false, includeIfNull: false)
  final int? elapsedTime;

  @JsonKey(name: r'calories', required: false, includeIfNull: false)
  final int? calories;

  @JsonKey(name: r'total_elevation_gain', required: false, includeIfNull: false)
  final double? totalElevationGain;

  @JsonKey(name: r'training_load', required: false, includeIfNull: false)
  final int? trainingLoad;

  @JsonKey(name: r'srpe', required: false, includeIfNull: false)
  final int? srpe;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'eftp', required: false, includeIfNull: false)
  final double? eftp;

  @JsonKey(name: r'eftpPerKg', required: false, includeIfNull: false)
  final double? eftpPerKg;

  @JsonKey(name: r'date', required: false, includeIfNull: false)
  final String? date;

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'athlete_name', required: false, includeIfNull: false)
  final String? athleteName;

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'external_id', required: false, includeIfNull: false)
  final String? externalId;

  @JsonKey(name: r'fitness', required: false, includeIfNull: false)
  final double? fitness;

  @JsonKey(name: r'fatigue', required: false, includeIfNull: false)
  final double? fatigue;

  @JsonKey(name: r'form', required: false, includeIfNull: false)
  final double? form;

  @JsonKey(name: r'rampRate', required: false, includeIfNull: false)
  final double? rampRate;

  @JsonKey(name: r'weight', required: false, includeIfNull: false)
  final double? weight;

  @JsonKey(name: r'timeInZones', required: false, includeIfNull: false)
  final List<int>? timeInZones;

  @JsonKey(name: r'timeInZonesTot', required: false, includeIfNull: false)
  final int? timeInZonesTot;

  @JsonKey(name: r'byCategory', required: false, includeIfNull: false)
  final List<CategorySummary>? byCategory;

  @JsonKey(name: r'mostRecentWellnessId', required: false, includeIfNull: false)
  final String? mostRecentWellnessId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryWithCats &&
          other.count == count &&
          other.time == time &&
          other.movingTime == movingTime &&
          other.elapsedTime == elapsedTime &&
          other.calories == calories &&
          other.totalElevationGain == totalElevationGain &&
          other.trainingLoad == trainingLoad &&
          other.srpe == srpe &&
          other.distance == distance &&
          other.eftp == eftp &&
          other.eftpPerKg == eftpPerKg &&
          other.date == date &&
          other.athleteId == athleteId &&
          other.athleteName == athleteName &&
          other.email == email &&
          other.externalId == externalId &&
          other.fitness == fitness &&
          other.fatigue == fatigue &&
          other.form == form &&
          other.rampRate == rampRate &&
          other.weight == weight &&
          other.timeInZones == timeInZones &&
          other.timeInZonesTot == timeInZonesTot &&
          other.byCategory == byCategory &&
          other.mostRecentWellnessId == mostRecentWellnessId;

  @override
  int get hashCode =>
      count.hashCode +
      time.hashCode +
      movingTime.hashCode +
      elapsedTime.hashCode +
      calories.hashCode +
      totalElevationGain.hashCode +
      trainingLoad.hashCode +
      srpe.hashCode +
      distance.hashCode +
      eftp.hashCode +
      eftpPerKg.hashCode +
      date.hashCode +
      athleteId.hashCode +
      athleteName.hashCode +
      email.hashCode +
      externalId.hashCode +
      fitness.hashCode +
      fatigue.hashCode +
      form.hashCode +
      rampRate.hashCode +
      weight.hashCode +
      timeInZones.hashCode +
      timeInZonesTot.hashCode +
      byCategory.hashCode +
      mostRecentWellnessId.hashCode;

  factory SummaryWithCats.fromJson(Map<String, dynamic> json) =>
      _$SummaryWithCatsFromJson(json);

  Map<String, dynamic> toJson() => _$SummaryWithCatsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
