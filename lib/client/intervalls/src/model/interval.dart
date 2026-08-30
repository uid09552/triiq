//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'interval.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Interval {
  /// Returns a new [Interval] instance.
  Interval({

     this.startIndex,

     this.distance,

     this.movingTime,

     this.elapsedTime,

     this.averageWatts,

     this.averageWattsAlt,

     this.averageWattsAltAcc,

     this.minWatts,

     this.maxWatts,

     this.averageWattsKg,

     this.maxWattsKg,

     this.intensity,

     this.w5sVariability,

     this.weightedAverageWatts,

     this.trainingLoad,

     this.joules,

     this.joulesAboveFtp,

     this.decoupling,

     this.avgLrBalance,

     this.averageDfaA1,

     this.averageEpoc,

     this.wbalStart,

     this.wbalEnd,

     this.averageRespiration,

     this.averageTidalVolume,

     this.averageTidalVolumeMin,

     this.zone,

     this.zoneMinWatts,

     this.zoneMaxWatts,

     this.averageSpeed,

     this.minSpeed,

     this.maxSpeed,

     this.gap,

     this.averageHeartrate,

     this.minHeartrate,

     this.maxHeartrate,

     this.averageCadence,

     this.minCadence,

     this.maxCadence,

     this.averageTorque,

     this.minTorque,

     this.maxTorque,

     this.totalElevationGain,

     this.minAltitude,

     this.maxAltitude,

     this.averageGradient,

     this.averageSmo2,

     this.averageThb,

     this.averageSmo22,

     this.averageThb2,

     this.averageLactate,

     this.minLactate,

     this.maxLactate,

     this.averageStanceTime,

     this.averageVerticalOscillation,

     this.averageVerticalRatio,

     this.averageStepLength,

     this.averageStanceTimePercent,

     this.averageStanceTimeBalance,

     this.averageVerticalSpeed,

     this.averageLegSpringStiffness,

     this.averageImpactLoadingRate,

     this.averageTemp,

     this.averageWeatherTemp,

     this.averageFeelsLike,

     this.averageWindSpeed,

     this.averageWindGust,

     this.prevailingWindDeg,

     this.averageYaw,

     this.headwindPercent,

     this.tailwindPercent,

     this.strainScore,

     this.ssPMax,

     this.ssWPrime,

     this.ssCp,

     this.id,

     this.type,

     this.endIndex,

     this.groupId,

     this.segmentEffortIds,

     this.startTime,

     this.endTime,

     this.label,

     this.averageStride,
  });

  @JsonKey(
    
    name: r'start_index',
    required: false,
    includeIfNull: false,
  )


  final int? startIndex;



  @JsonKey(
    
    name: r'distance',
    required: false,
    includeIfNull: false,
  )


  final double? distance;



  @JsonKey(
    
    name: r'moving_time',
    required: false,
    includeIfNull: false,
  )


  final int? movingTime;



  @JsonKey(
    
    name: r'elapsed_time',
    required: false,
    includeIfNull: false,
  )


  final int? elapsedTime;



  @JsonKey(
    
    name: r'average_watts',
    required: false,
    includeIfNull: false,
  )


  final int? averageWatts;



  @JsonKey(
    
    name: r'average_watts_alt',
    required: false,
    includeIfNull: false,
  )


  final int? averageWattsAlt;



  @JsonKey(
    
    name: r'average_watts_alt_acc',
    required: false,
    includeIfNull: false,
  )


  final int? averageWattsAltAcc;



  @JsonKey(
    
    name: r'min_watts',
    required: false,
    includeIfNull: false,
  )


  final int? minWatts;



  @JsonKey(
    
    name: r'max_watts',
    required: false,
    includeIfNull: false,
  )


  final int? maxWatts;



  @JsonKey(
    
    name: r'average_watts_kg',
    required: false,
    includeIfNull: false,
  )


  final double? averageWattsKg;



  @JsonKey(
    
    name: r'max_watts_kg',
    required: false,
    includeIfNull: false,
  )


  final double? maxWattsKg;



  @JsonKey(
    
    name: r'intensity',
    required: false,
    includeIfNull: false,
  )


  final int? intensity;



  @JsonKey(
    
    name: r'w5s_variability',
    required: false,
    includeIfNull: false,
  )


  final double? w5sVariability;



  @JsonKey(
    
    name: r'weighted_average_watts',
    required: false,
    includeIfNull: false,
  )


  final int? weightedAverageWatts;



  @JsonKey(
    
    name: r'training_load',
    required: false,
    includeIfNull: false,
  )


  final double? trainingLoad;



  @JsonKey(
    
    name: r'joules',
    required: false,
    includeIfNull: false,
  )


  final int? joules;



  @JsonKey(
    
    name: r'joules_above_ftp',
    required: false,
    includeIfNull: false,
  )


  final int? joulesAboveFtp;



  @JsonKey(
    
    name: r'decoupling',
    required: false,
    includeIfNull: false,
  )


  final double? decoupling;



  @JsonKey(
    
    name: r'avg_lr_balance',
    required: false,
    includeIfNull: false,
  )


  final double? avgLrBalance;



  @JsonKey(
    
    name: r'average_dfa_a1',
    required: false,
    includeIfNull: false,
  )


  final double? averageDfaA1;



  @JsonKey(
    
    name: r'average_epoc',
    required: false,
    includeIfNull: false,
  )


  final double? averageEpoc;



  @JsonKey(
    
    name: r'wbal_start',
    required: false,
    includeIfNull: false,
  )


  final int? wbalStart;



  @JsonKey(
    
    name: r'wbal_end',
    required: false,
    includeIfNull: false,
  )


  final int? wbalEnd;



  @JsonKey(
    
    name: r'average_respiration',
    required: false,
    includeIfNull: false,
  )


  final double? averageRespiration;



  @JsonKey(
    
    name: r'average_tidal_volume',
    required: false,
    includeIfNull: false,
  )


  final double? averageTidalVolume;



  @JsonKey(
    
    name: r'average_tidal_volume_min',
    required: false,
    includeIfNull: false,
  )


  final double? averageTidalVolumeMin;



  @JsonKey(
    
    name: r'zone',
    required: false,
    includeIfNull: false,
  )


  final int? zone;



  @JsonKey(
    
    name: r'zone_min_watts',
    required: false,
    includeIfNull: false,
  )


  final int? zoneMinWatts;



  @JsonKey(
    
    name: r'zone_max_watts',
    required: false,
    includeIfNull: false,
  )


  final int? zoneMaxWatts;



  @JsonKey(
    
    name: r'average_speed',
    required: false,
    includeIfNull: false,
  )


  final double? averageSpeed;



  @JsonKey(
    
    name: r'min_speed',
    required: false,
    includeIfNull: false,
  )


  final double? minSpeed;



  @JsonKey(
    
    name: r'max_speed',
    required: false,
    includeIfNull: false,
  )


  final double? maxSpeed;



  @JsonKey(
    
    name: r'gap',
    required: false,
    includeIfNull: false,
  )


  final double? gap;



  @JsonKey(
    
    name: r'average_heartrate',
    required: false,
    includeIfNull: false,
  )


  final int? averageHeartrate;



  @JsonKey(
    
    name: r'min_heartrate',
    required: false,
    includeIfNull: false,
  )


  final int? minHeartrate;



  @JsonKey(
    
    name: r'max_heartrate',
    required: false,
    includeIfNull: false,
  )


  final int? maxHeartrate;



  @JsonKey(
    
    name: r'average_cadence',
    required: false,
    includeIfNull: false,
  )


  final double? averageCadence;



  @JsonKey(
    
    name: r'min_cadence',
    required: false,
    includeIfNull: false,
  )


  final int? minCadence;



  @JsonKey(
    
    name: r'max_cadence',
    required: false,
    includeIfNull: false,
  )


  final int? maxCadence;



  @JsonKey(
    
    name: r'average_torque',
    required: false,
    includeIfNull: false,
  )


  final double? averageTorque;



  @JsonKey(
    
    name: r'min_torque',
    required: false,
    includeIfNull: false,
  )


  final double? minTorque;



  @JsonKey(
    
    name: r'max_torque',
    required: false,
    includeIfNull: false,
  )


  final double? maxTorque;



  @JsonKey(
    
    name: r'total_elevation_gain',
    required: false,
    includeIfNull: false,
  )


  final double? totalElevationGain;



  @JsonKey(
    
    name: r'min_altitude',
    required: false,
    includeIfNull: false,
  )


  final double? minAltitude;



  @JsonKey(
    
    name: r'max_altitude',
    required: false,
    includeIfNull: false,
  )


  final double? maxAltitude;



  @JsonKey(
    
    name: r'average_gradient',
    required: false,
    includeIfNull: false,
  )


  final double? averageGradient;



  @JsonKey(
    
    name: r'average_smo2',
    required: false,
    includeIfNull: false,
  )


  final double? averageSmo2;



  @JsonKey(
    
    name: r'average_thb',
    required: false,
    includeIfNull: false,
  )


  final double? averageThb;



  @JsonKey(
    
    name: r'average_smo2_2',
    required: false,
    includeIfNull: false,
  )


  final double? averageSmo22;



  @JsonKey(
    
    name: r'average_thb_2',
    required: false,
    includeIfNull: false,
  )


  final double? averageThb2;



  @JsonKey(
    
    name: r'average_lactate',
    required: false,
    includeIfNull: false,
  )


  final double? averageLactate;



  @JsonKey(
    
    name: r'min_lactate',
    required: false,
    includeIfNull: false,
  )


  final double? minLactate;



  @JsonKey(
    
    name: r'max_lactate',
    required: false,
    includeIfNull: false,
  )


  final double? maxLactate;



  @JsonKey(
    
    name: r'average_stance_time',
    required: false,
    includeIfNull: false,
  )


  final double? averageStanceTime;



  @JsonKey(
    
    name: r'average_vertical_oscillation',
    required: false,
    includeIfNull: false,
  )


  final double? averageVerticalOscillation;



  @JsonKey(
    
    name: r'average_vertical_ratio',
    required: false,
    includeIfNull: false,
  )


  final double? averageVerticalRatio;



  @JsonKey(
    
    name: r'average_step_length',
    required: false,
    includeIfNull: false,
  )


  final double? averageStepLength;



  @JsonKey(
    
    name: r'average_stance_time_percent',
    required: false,
    includeIfNull: false,
  )


  final double? averageStanceTimePercent;



  @JsonKey(
    
    name: r'average_stance_time_balance',
    required: false,
    includeIfNull: false,
  )


  final double? averageStanceTimeBalance;



  @JsonKey(
    
    name: r'average_vertical_speed',
    required: false,
    includeIfNull: false,
  )


  final double? averageVerticalSpeed;



  @JsonKey(
    
    name: r'average_leg_spring_stiffness',
    required: false,
    includeIfNull: false,
  )


  final double? averageLegSpringStiffness;



  @JsonKey(
    
    name: r'average_impact_loading_rate',
    required: false,
    includeIfNull: false,
  )


  final double? averageImpactLoadingRate;



  @JsonKey(
    
    name: r'average_temp',
    required: false,
    includeIfNull: false,
  )


  final double? averageTemp;



  @JsonKey(
    
    name: r'average_weather_temp',
    required: false,
    includeIfNull: false,
  )


  final double? averageWeatherTemp;



  @JsonKey(
    
    name: r'average_feels_like',
    required: false,
    includeIfNull: false,
  )


  final double? averageFeelsLike;



  @JsonKey(
    
    name: r'average_wind_speed',
    required: false,
    includeIfNull: false,
  )


  final double? averageWindSpeed;



  @JsonKey(
    
    name: r'average_wind_gust',
    required: false,
    includeIfNull: false,
  )


  final double? averageWindGust;



  @JsonKey(
    
    name: r'prevailing_wind_deg',
    required: false,
    includeIfNull: false,
  )


  final int? prevailingWindDeg;



  @JsonKey(
    
    name: r'average_yaw',
    required: false,
    includeIfNull: false,
  )


  final double? averageYaw;



  @JsonKey(
    
    name: r'headwind_percent',
    required: false,
    includeIfNull: false,
  )


  final double? headwindPercent;



  @JsonKey(
    
    name: r'tailwind_percent',
    required: false,
    includeIfNull: false,
  )


  final double? tailwindPercent;



  @JsonKey(
    
    name: r'strain_score',
    required: false,
    includeIfNull: false,
  )


  final double? strainScore;



  @JsonKey(
    
    name: r'ss_p_max',
    required: false,
    includeIfNull: false,
  )


  final double? ssPMax;



  @JsonKey(
    
    name: r'ss_w_prime',
    required: false,
    includeIfNull: false,
  )


  final double? ssWPrime;



  @JsonKey(
    
    name: r'ss_cp',
    required: false,
    includeIfNull: false,
  )


  final double? ssCp;



  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final IntervalTypeEnum? type;



  @JsonKey(
    
    name: r'end_index',
    required: false,
    includeIfNull: false,
  )


  final int? endIndex;



  @JsonKey(
    
    name: r'group_id',
    required: false,
    includeIfNull: false,
  )


  final String? groupId;



  @JsonKey(
    
    name: r'segment_effort_ids',
    required: false,
    includeIfNull: false,
  )


  final List<int>? segmentEffortIds;



  @JsonKey(
    
    name: r'start_time',
    required: false,
    includeIfNull: false,
  )


  final int? startTime;



  @JsonKey(
    
    name: r'end_time',
    required: false,
    includeIfNull: false,
  )


  final int? endTime;



  @JsonKey(
    
    name: r'label',
    required: false,
    includeIfNull: false,
  )


  final String? label;



  @JsonKey(
    
    name: r'average_stride',
    required: false,
    includeIfNull: false,
  )


  final double? averageStride;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Interval &&
      other.startIndex == startIndex &&
      other.distance == distance &&
      other.movingTime == movingTime &&
      other.elapsedTime == elapsedTime &&
      other.averageWatts == averageWatts &&
      other.averageWattsAlt == averageWattsAlt &&
      other.averageWattsAltAcc == averageWattsAltAcc &&
      other.minWatts == minWatts &&
      other.maxWatts == maxWatts &&
      other.averageWattsKg == averageWattsKg &&
      other.maxWattsKg == maxWattsKg &&
      other.intensity == intensity &&
      other.w5sVariability == w5sVariability &&
      other.weightedAverageWatts == weightedAverageWatts &&
      other.trainingLoad == trainingLoad &&
      other.joules == joules &&
      other.joulesAboveFtp == joulesAboveFtp &&
      other.decoupling == decoupling &&
      other.avgLrBalance == avgLrBalance &&
      other.averageDfaA1 == averageDfaA1 &&
      other.averageEpoc == averageEpoc &&
      other.wbalStart == wbalStart &&
      other.wbalEnd == wbalEnd &&
      other.averageRespiration == averageRespiration &&
      other.averageTidalVolume == averageTidalVolume &&
      other.averageTidalVolumeMin == averageTidalVolumeMin &&
      other.zone == zone &&
      other.zoneMinWatts == zoneMinWatts &&
      other.zoneMaxWatts == zoneMaxWatts &&
      other.averageSpeed == averageSpeed &&
      other.minSpeed == minSpeed &&
      other.maxSpeed == maxSpeed &&
      other.gap == gap &&
      other.averageHeartrate == averageHeartrate &&
      other.minHeartrate == minHeartrate &&
      other.maxHeartrate == maxHeartrate &&
      other.averageCadence == averageCadence &&
      other.minCadence == minCadence &&
      other.maxCadence == maxCadence &&
      other.averageTorque == averageTorque &&
      other.minTorque == minTorque &&
      other.maxTorque == maxTorque &&
      other.totalElevationGain == totalElevationGain &&
      other.minAltitude == minAltitude &&
      other.maxAltitude == maxAltitude &&
      other.averageGradient == averageGradient &&
      other.averageSmo2 == averageSmo2 &&
      other.averageThb == averageThb &&
      other.averageSmo22 == averageSmo22 &&
      other.averageThb2 == averageThb2 &&
      other.averageLactate == averageLactate &&
      other.minLactate == minLactate &&
      other.maxLactate == maxLactate &&
      other.averageStanceTime == averageStanceTime &&
      other.averageVerticalOscillation == averageVerticalOscillation &&
      other.averageVerticalRatio == averageVerticalRatio &&
      other.averageStepLength == averageStepLength &&
      other.averageStanceTimePercent == averageStanceTimePercent &&
      other.averageStanceTimeBalance == averageStanceTimeBalance &&
      other.averageVerticalSpeed == averageVerticalSpeed &&
      other.averageLegSpringStiffness == averageLegSpringStiffness &&
      other.averageImpactLoadingRate == averageImpactLoadingRate &&
      other.averageTemp == averageTemp &&
      other.averageWeatherTemp == averageWeatherTemp &&
      other.averageFeelsLike == averageFeelsLike &&
      other.averageWindSpeed == averageWindSpeed &&
      other.averageWindGust == averageWindGust &&
      other.prevailingWindDeg == prevailingWindDeg &&
      other.averageYaw == averageYaw &&
      other.headwindPercent == headwindPercent &&
      other.tailwindPercent == tailwindPercent &&
      other.strainScore == strainScore &&
      other.ssPMax == ssPMax &&
      other.ssWPrime == ssWPrime &&
      other.ssCp == ssCp &&
      other.id == id &&
      other.type == type &&
      other.endIndex == endIndex &&
      other.groupId == groupId &&
      other.segmentEffortIds == segmentEffortIds &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.label == label &&
      other.averageStride == averageStride;

    @override
    int get hashCode =>
        startIndex.hashCode +
        distance.hashCode +
        movingTime.hashCode +
        elapsedTime.hashCode +
        averageWatts.hashCode +
        averageWattsAlt.hashCode +
        averageWattsAltAcc.hashCode +
        minWatts.hashCode +
        maxWatts.hashCode +
        averageWattsKg.hashCode +
        maxWattsKg.hashCode +
        intensity.hashCode +
        w5sVariability.hashCode +
        weightedAverageWatts.hashCode +
        trainingLoad.hashCode +
        joules.hashCode +
        joulesAboveFtp.hashCode +
        decoupling.hashCode +
        avgLrBalance.hashCode +
        averageDfaA1.hashCode +
        averageEpoc.hashCode +
        wbalStart.hashCode +
        wbalEnd.hashCode +
        averageRespiration.hashCode +
        averageTidalVolume.hashCode +
        averageTidalVolumeMin.hashCode +
        zone.hashCode +
        zoneMinWatts.hashCode +
        zoneMaxWatts.hashCode +
        averageSpeed.hashCode +
        minSpeed.hashCode +
        maxSpeed.hashCode +
        gap.hashCode +
        averageHeartrate.hashCode +
        minHeartrate.hashCode +
        maxHeartrate.hashCode +
        averageCadence.hashCode +
        minCadence.hashCode +
        maxCadence.hashCode +
        averageTorque.hashCode +
        minTorque.hashCode +
        maxTorque.hashCode +
        totalElevationGain.hashCode +
        minAltitude.hashCode +
        maxAltitude.hashCode +
        averageGradient.hashCode +
        averageSmo2.hashCode +
        averageThb.hashCode +
        averageSmo22.hashCode +
        averageThb2.hashCode +
        averageLactate.hashCode +
        minLactate.hashCode +
        maxLactate.hashCode +
        averageStanceTime.hashCode +
        averageVerticalOscillation.hashCode +
        averageVerticalRatio.hashCode +
        averageStepLength.hashCode +
        averageStanceTimePercent.hashCode +
        averageStanceTimeBalance.hashCode +
        averageVerticalSpeed.hashCode +
        averageLegSpringStiffness.hashCode +
        averageImpactLoadingRate.hashCode +
        averageTemp.hashCode +
        averageWeatherTemp.hashCode +
        averageFeelsLike.hashCode +
        averageWindSpeed.hashCode +
        averageWindGust.hashCode +
        prevailingWindDeg.hashCode +
        averageYaw.hashCode +
        headwindPercent.hashCode +
        tailwindPercent.hashCode +
        strainScore.hashCode +
        ssPMax.hashCode +
        ssWPrime.hashCode +
        ssCp.hashCode +
        id.hashCode +
        type.hashCode +
        endIndex.hashCode +
        groupId.hashCode +
        segmentEffortIds.hashCode +
        startTime.hashCode +
        endTime.hashCode +
        label.hashCode +
        averageStride.hashCode;

  factory Interval.fromJson(Map<String, dynamic> json) => _$IntervalFromJson(json);

  Map<String, dynamic> toJson() => _$IntervalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum IntervalTypeEnum {
@JsonValue(r'RECOVERY')
RECOVERY(r'RECOVERY'),
@JsonValue(r'WORK')
WORK(r'WORK');

const IntervalTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


