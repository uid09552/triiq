//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/sport_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wellness.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Wellness {
  /// Returns a new [Wellness] instance.
  Wellness({
    this.id,

    this.ctl,

    this.atl,

    this.rampRate,

    this.ctlLoad,

    this.atlLoad,

    this.sportInfo,

    this.updated,

    this.weight,

    this.restingHR,

    this.hrv,

    this.hrvSDNN,

    this.menstrualPhase,

    this.menstrualPhasePredicted,

    this.kcalConsumed,

    this.sleepSecs,

    this.sleepScore,

    this.sleepQuality,

    this.avgSleepingHR,

    this.soreness,

    this.fatigue,

    this.stress,

    this.mood,

    this.motivation,

    this.injury,

    this.spO2,

    this.systolic,

    this.diastolic,

    this.hydration,

    this.hydrationVolume,

    this.readiness,

    this.baevskySI,

    this.bloodGlucose,

    this.lactate,

    this.bodyFat,

    this.abdomen,

    this.vo2max,

    this.comments,

    this.steps,

    this.respiration,

    this.carbohydrates,

    this.protein,

    this.fatTotal,

    this.locked,

    this.tempWeight,

    this.tempRestingHR,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'ctl', required: false, includeIfNull: false)
  final double? ctl;

  @JsonKey(name: r'atl', required: false, includeIfNull: false)
  final double? atl;

  @JsonKey(name: r'rampRate', required: false, includeIfNull: false)
  final double? rampRate;

  @JsonKey(name: r'ctlLoad', required: false, includeIfNull: false)
  final double? ctlLoad;

  @JsonKey(name: r'atlLoad', required: false, includeIfNull: false)
  final double? atlLoad;

  @JsonKey(name: r'sportInfo', required: false, includeIfNull: false)
  final List<SportInfo>? sportInfo;

  @JsonKey(name: r'updated', required: false, includeIfNull: false)
  final DateTime? updated;

  @JsonKey(name: r'weight', required: false, includeIfNull: false)
  final double? weight;

  @JsonKey(name: r'restingHR', required: false, includeIfNull: false)
  final int? restingHR;

  @JsonKey(name: r'hrv', required: false, includeIfNull: false)
  final double? hrv;

  @JsonKey(name: r'hrvSDNN', required: false, includeIfNull: false)
  final double? hrvSDNN;

  @JsonKey(name: r'menstrualPhase', required: false, includeIfNull: false)
  final WellnessMenstrualPhaseEnum? menstrualPhase;

  @JsonKey(
    name: r'menstrualPhasePredicted',
    required: false,
    includeIfNull: false,
  )
  final WellnessMenstrualPhasePredictedEnum? menstrualPhasePredicted;

  @JsonKey(name: r'kcalConsumed', required: false, includeIfNull: false)
  final int? kcalConsumed;

  @JsonKey(name: r'sleepSecs', required: false, includeIfNull: false)
  final int? sleepSecs;

  @JsonKey(name: r'sleepScore', required: false, includeIfNull: false)
  final double? sleepScore;

  @JsonKey(name: r'sleepQuality', required: false, includeIfNull: false)
  final int? sleepQuality;

  @JsonKey(name: r'avgSleepingHR', required: false, includeIfNull: false)
  final double? avgSleepingHR;

  @JsonKey(name: r'soreness', required: false, includeIfNull: false)
  final int? soreness;

  @JsonKey(name: r'fatigue', required: false, includeIfNull: false)
  final int? fatigue;

  @JsonKey(name: r'stress', required: false, includeIfNull: false)
  final int? stress;

  @JsonKey(name: r'mood', required: false, includeIfNull: false)
  final int? mood;

  @JsonKey(name: r'motivation', required: false, includeIfNull: false)
  final int? motivation;

  @JsonKey(name: r'injury', required: false, includeIfNull: false)
  final int? injury;

  @JsonKey(name: r'spO2', required: false, includeIfNull: false)
  final double? spO2;

  @JsonKey(name: r'systolic', required: false, includeIfNull: false)
  final int? systolic;

  @JsonKey(name: r'diastolic', required: false, includeIfNull: false)
  final int? diastolic;

  @JsonKey(name: r'hydration', required: false, includeIfNull: false)
  final int? hydration;

  @JsonKey(name: r'hydrationVolume', required: false, includeIfNull: false)
  final double? hydrationVolume;

  @JsonKey(name: r'readiness', required: false, includeIfNull: false)
  final double? readiness;

  @JsonKey(name: r'baevskySI', required: false, includeIfNull: false)
  final double? baevskySI;

  @JsonKey(name: r'bloodGlucose', required: false, includeIfNull: false)
  final double? bloodGlucose;

  @JsonKey(name: r'lactate', required: false, includeIfNull: false)
  final double? lactate;

  @JsonKey(name: r'bodyFat', required: false, includeIfNull: false)
  final double? bodyFat;

  @JsonKey(name: r'abdomen', required: false, includeIfNull: false)
  final double? abdomen;

  @JsonKey(name: r'vo2max', required: false, includeIfNull: false)
  final double? vo2max;

  @JsonKey(name: r'comments', required: false, includeIfNull: false)
  final String? comments;

  @JsonKey(name: r'steps', required: false, includeIfNull: false)
  final int? steps;

  @JsonKey(name: r'respiration', required: false, includeIfNull: false)
  final double? respiration;

  @JsonKey(name: r'carbohydrates', required: false, includeIfNull: false)
  final double? carbohydrates;

  @JsonKey(name: r'protein', required: false, includeIfNull: false)
  final double? protein;

  @JsonKey(name: r'fatTotal', required: false, includeIfNull: false)
  final double? fatTotal;

  @JsonKey(name: r'locked', required: false, includeIfNull: false)
  final bool? locked;

  @JsonKey(name: r'tempWeight', required: false, includeIfNull: false)
  final bool? tempWeight;

  @JsonKey(name: r'tempRestingHR', required: false, includeIfNull: false)
  final bool? tempRestingHR;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wellness &&
          other.id == id &&
          other.ctl == ctl &&
          other.atl == atl &&
          other.rampRate == rampRate &&
          other.ctlLoad == ctlLoad &&
          other.atlLoad == atlLoad &&
          other.sportInfo == sportInfo &&
          other.updated == updated &&
          other.weight == weight &&
          other.restingHR == restingHR &&
          other.hrv == hrv &&
          other.hrvSDNN == hrvSDNN &&
          other.menstrualPhase == menstrualPhase &&
          other.menstrualPhasePredicted == menstrualPhasePredicted &&
          other.kcalConsumed == kcalConsumed &&
          other.sleepSecs == sleepSecs &&
          other.sleepScore == sleepScore &&
          other.sleepQuality == sleepQuality &&
          other.avgSleepingHR == avgSleepingHR &&
          other.soreness == soreness &&
          other.fatigue == fatigue &&
          other.stress == stress &&
          other.mood == mood &&
          other.motivation == motivation &&
          other.injury == injury &&
          other.spO2 == spO2 &&
          other.systolic == systolic &&
          other.diastolic == diastolic &&
          other.hydration == hydration &&
          other.hydrationVolume == hydrationVolume &&
          other.readiness == readiness &&
          other.baevskySI == baevskySI &&
          other.bloodGlucose == bloodGlucose &&
          other.lactate == lactate &&
          other.bodyFat == bodyFat &&
          other.abdomen == abdomen &&
          other.vo2max == vo2max &&
          other.comments == comments &&
          other.steps == steps &&
          other.respiration == respiration &&
          other.carbohydrates == carbohydrates &&
          other.protein == protein &&
          other.fatTotal == fatTotal &&
          other.locked == locked &&
          other.tempWeight == tempWeight &&
          other.tempRestingHR == tempRestingHR;

  @override
  int get hashCode =>
      id.hashCode +
      ctl.hashCode +
      atl.hashCode +
      rampRate.hashCode +
      ctlLoad.hashCode +
      atlLoad.hashCode +
      sportInfo.hashCode +
      updated.hashCode +
      weight.hashCode +
      restingHR.hashCode +
      hrv.hashCode +
      hrvSDNN.hashCode +
      menstrualPhase.hashCode +
      menstrualPhasePredicted.hashCode +
      kcalConsumed.hashCode +
      sleepSecs.hashCode +
      sleepScore.hashCode +
      sleepQuality.hashCode +
      avgSleepingHR.hashCode +
      soreness.hashCode +
      fatigue.hashCode +
      stress.hashCode +
      mood.hashCode +
      motivation.hashCode +
      injury.hashCode +
      spO2.hashCode +
      systolic.hashCode +
      diastolic.hashCode +
      hydration.hashCode +
      hydrationVolume.hashCode +
      readiness.hashCode +
      baevskySI.hashCode +
      bloodGlucose.hashCode +
      lactate.hashCode +
      bodyFat.hashCode +
      abdomen.hashCode +
      vo2max.hashCode +
      comments.hashCode +
      steps.hashCode +
      respiration.hashCode +
      carbohydrates.hashCode +
      protein.hashCode +
      fatTotal.hashCode +
      locked.hashCode +
      tempWeight.hashCode +
      tempRestingHR.hashCode;

  factory Wellness.fromJson(Map<String, dynamic> json) =>
      _$WellnessFromJson(json);

  Map<String, dynamic> toJson() => _$WellnessToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum WellnessMenstrualPhaseEnum {
  @JsonValue(r'PERIOD')
  PERIOD(r'PERIOD'),
  @JsonValue(r'FOLLICULAR')
  FOLLICULAR(r'FOLLICULAR'),
  @JsonValue(r'OVULATING')
  OVULATING(r'OVULATING'),
  @JsonValue(r'LUTEAL')
  LUTEAL(r'LUTEAL'),
  @JsonValue(r'NONE')
  NONE(r'NONE');

  const WellnessMenstrualPhaseEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum WellnessMenstrualPhasePredictedEnum {
  @JsonValue(r'PERIOD')
  PERIOD(r'PERIOD'),
  @JsonValue(r'FOLLICULAR')
  FOLLICULAR(r'FOLLICULAR'),
  @JsonValue(r'OVULATING')
  OVULATING(r'OVULATING'),
  @JsonValue(r'LUTEAL')
  LUTEAL(r'LUTEAL'),
  @JsonValue(r'NONE')
  NONE(r'NONE');

  const WellnessMenstrualPhasePredictedEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
