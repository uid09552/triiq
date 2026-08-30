// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interval.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IntervalCWProxy {
  Interval startIndex(int? startIndex);

  Interval distance(double? distance);

  Interval movingTime(int? movingTime);

  Interval elapsedTime(int? elapsedTime);

  Interval averageWatts(int? averageWatts);

  Interval averageWattsAlt(int? averageWattsAlt);

  Interval averageWattsAltAcc(int? averageWattsAltAcc);

  Interval minWatts(int? minWatts);

  Interval maxWatts(int? maxWatts);

  Interval averageWattsKg(double? averageWattsKg);

  Interval maxWattsKg(double? maxWattsKg);

  Interval intensity(int? intensity);

  Interval w5sVariability(double? w5sVariability);

  Interval weightedAverageWatts(int? weightedAverageWatts);

  Interval trainingLoad(double? trainingLoad);

  Interval joules(int? joules);

  Interval joulesAboveFtp(int? joulesAboveFtp);

  Interval decoupling(double? decoupling);

  Interval avgLrBalance(double? avgLrBalance);

  Interval averageDfaA1(double? averageDfaA1);

  Interval averageEpoc(double? averageEpoc);

  Interval wbalStart(int? wbalStart);

  Interval wbalEnd(int? wbalEnd);

  Interval averageRespiration(double? averageRespiration);

  Interval averageTidalVolume(double? averageTidalVolume);

  Interval averageTidalVolumeMin(double? averageTidalVolumeMin);

  Interval zone(int? zone);

  Interval zoneMinWatts(int? zoneMinWatts);

  Interval zoneMaxWatts(int? zoneMaxWatts);

  Interval averageSpeed(double? averageSpeed);

  Interval minSpeed(double? minSpeed);

  Interval maxSpeed(double? maxSpeed);

  Interval gap(double? gap);

  Interval averageHeartrate(int? averageHeartrate);

  Interval minHeartrate(int? minHeartrate);

  Interval maxHeartrate(int? maxHeartrate);

  Interval averageCadence(double? averageCadence);

  Interval minCadence(int? minCadence);

  Interval maxCadence(int? maxCadence);

  Interval averageTorque(double? averageTorque);

  Interval minTorque(double? minTorque);

  Interval maxTorque(double? maxTorque);

  Interval totalElevationGain(double? totalElevationGain);

  Interval minAltitude(double? minAltitude);

  Interval maxAltitude(double? maxAltitude);

  Interval averageGradient(double? averageGradient);

  Interval averageSmo2(double? averageSmo2);

  Interval averageThb(double? averageThb);

  Interval averageSmo22(double? averageSmo22);

  Interval averageThb2(double? averageThb2);

  Interval averageLactate(double? averageLactate);

  Interval minLactate(double? minLactate);

  Interval maxLactate(double? maxLactate);

  Interval averageStanceTime(double? averageStanceTime);

  Interval averageVerticalOscillation(double? averageVerticalOscillation);

  Interval averageVerticalRatio(double? averageVerticalRatio);

  Interval averageStepLength(double? averageStepLength);

  Interval averageStanceTimePercent(double? averageStanceTimePercent);

  Interval averageStanceTimeBalance(double? averageStanceTimeBalance);

  Interval averageVerticalSpeed(double? averageVerticalSpeed);

  Interval averageLegSpringStiffness(double? averageLegSpringStiffness);

  Interval averageImpactLoadingRate(double? averageImpactLoadingRate);

  Interval averageTemp(double? averageTemp);

  Interval averageWeatherTemp(double? averageWeatherTemp);

  Interval averageFeelsLike(double? averageFeelsLike);

  Interval averageWindSpeed(double? averageWindSpeed);

  Interval averageWindGust(double? averageWindGust);

  Interval prevailingWindDeg(int? prevailingWindDeg);

  Interval averageYaw(double? averageYaw);

  Interval headwindPercent(double? headwindPercent);

  Interval tailwindPercent(double? tailwindPercent);

  Interval strainScore(double? strainScore);

  Interval ssPMax(double? ssPMax);

  Interval ssWPrime(double? ssWPrime);

  Interval ssCp(double? ssCp);

  Interval id(int? id);

  Interval type(IntervalTypeEnum? type);

  Interval endIndex(int? endIndex);

  Interval groupId(String? groupId);

  Interval segmentEffortIds(List<int>? segmentEffortIds);

  Interval startTime(int? startTime);

  Interval endTime(int? endTime);

  Interval label(String? label);

  Interval averageStride(double? averageStride);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Interval(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Interval(...).copyWith(id: 12, name: "My name")
  /// ````
  Interval call({
    int? startIndex,
    double? distance,
    int? movingTime,
    int? elapsedTime,
    int? averageWatts,
    int? averageWattsAlt,
    int? averageWattsAltAcc,
    int? minWatts,
    int? maxWatts,
    double? averageWattsKg,
    double? maxWattsKg,
    int? intensity,
    double? w5sVariability,
    int? weightedAverageWatts,
    double? trainingLoad,
    int? joules,
    int? joulesAboveFtp,
    double? decoupling,
    double? avgLrBalance,
    double? averageDfaA1,
    double? averageEpoc,
    int? wbalStart,
    int? wbalEnd,
    double? averageRespiration,
    double? averageTidalVolume,
    double? averageTidalVolumeMin,
    int? zone,
    int? zoneMinWatts,
    int? zoneMaxWatts,
    double? averageSpeed,
    double? minSpeed,
    double? maxSpeed,
    double? gap,
    int? averageHeartrate,
    int? minHeartrate,
    int? maxHeartrate,
    double? averageCadence,
    int? minCadence,
    int? maxCadence,
    double? averageTorque,
    double? minTorque,
    double? maxTorque,
    double? totalElevationGain,
    double? minAltitude,
    double? maxAltitude,
    double? averageGradient,
    double? averageSmo2,
    double? averageThb,
    double? averageSmo22,
    double? averageThb2,
    double? averageLactate,
    double? minLactate,
    double? maxLactate,
    double? averageStanceTime,
    double? averageVerticalOscillation,
    double? averageVerticalRatio,
    double? averageStepLength,
    double? averageStanceTimePercent,
    double? averageStanceTimeBalance,
    double? averageVerticalSpeed,
    double? averageLegSpringStiffness,
    double? averageImpactLoadingRate,
    double? averageTemp,
    double? averageWeatherTemp,
    double? averageFeelsLike,
    double? averageWindSpeed,
    double? averageWindGust,
    int? prevailingWindDeg,
    double? averageYaw,
    double? headwindPercent,
    double? tailwindPercent,
    double? strainScore,
    double? ssPMax,
    double? ssWPrime,
    double? ssCp,
    int? id,
    IntervalTypeEnum? type,
    int? endIndex,
    String? groupId,
    List<int>? segmentEffortIds,
    int? startTime,
    int? endTime,
    String? label,
    double? averageStride,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInterval.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInterval.copyWith.fieldName(...)`
class _$IntervalCWProxyImpl implements _$IntervalCWProxy {
  const _$IntervalCWProxyImpl(this._value);

  final Interval _value;

  @override
  Interval startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  Interval distance(double? distance) => this(distance: distance);

  @override
  Interval movingTime(int? movingTime) => this(movingTime: movingTime);

  @override
  Interval elapsedTime(int? elapsedTime) => this(elapsedTime: elapsedTime);

  @override
  Interval averageWatts(int? averageWatts) => this(averageWatts: averageWatts);

  @override
  Interval averageWattsAlt(int? averageWattsAlt) =>
      this(averageWattsAlt: averageWattsAlt);

  @override
  Interval averageWattsAltAcc(int? averageWattsAltAcc) =>
      this(averageWattsAltAcc: averageWattsAltAcc);

  @override
  Interval minWatts(int? minWatts) => this(minWatts: minWatts);

  @override
  Interval maxWatts(int? maxWatts) => this(maxWatts: maxWatts);

  @override
  Interval averageWattsKg(double? averageWattsKg) =>
      this(averageWattsKg: averageWattsKg);

  @override
  Interval maxWattsKg(double? maxWattsKg) => this(maxWattsKg: maxWattsKg);

  @override
  Interval intensity(int? intensity) => this(intensity: intensity);

  @override
  Interval w5sVariability(double? w5sVariability) =>
      this(w5sVariability: w5sVariability);

  @override
  Interval weightedAverageWatts(int? weightedAverageWatts) =>
      this(weightedAverageWatts: weightedAverageWatts);

  @override
  Interval trainingLoad(double? trainingLoad) =>
      this(trainingLoad: trainingLoad);

  @override
  Interval joules(int? joules) => this(joules: joules);

  @override
  Interval joulesAboveFtp(int? joulesAboveFtp) =>
      this(joulesAboveFtp: joulesAboveFtp);

  @override
  Interval decoupling(double? decoupling) => this(decoupling: decoupling);

  @override
  Interval avgLrBalance(double? avgLrBalance) =>
      this(avgLrBalance: avgLrBalance);

  @override
  Interval averageDfaA1(double? averageDfaA1) =>
      this(averageDfaA1: averageDfaA1);

  @override
  Interval averageEpoc(double? averageEpoc) => this(averageEpoc: averageEpoc);

  @override
  Interval wbalStart(int? wbalStart) => this(wbalStart: wbalStart);

  @override
  Interval wbalEnd(int? wbalEnd) => this(wbalEnd: wbalEnd);

  @override
  Interval averageRespiration(double? averageRespiration) =>
      this(averageRespiration: averageRespiration);

  @override
  Interval averageTidalVolume(double? averageTidalVolume) =>
      this(averageTidalVolume: averageTidalVolume);

  @override
  Interval averageTidalVolumeMin(double? averageTidalVolumeMin) =>
      this(averageTidalVolumeMin: averageTidalVolumeMin);

  @override
  Interval zone(int? zone) => this(zone: zone);

  @override
  Interval zoneMinWatts(int? zoneMinWatts) => this(zoneMinWatts: zoneMinWatts);

  @override
  Interval zoneMaxWatts(int? zoneMaxWatts) => this(zoneMaxWatts: zoneMaxWatts);

  @override
  Interval averageSpeed(double? averageSpeed) =>
      this(averageSpeed: averageSpeed);

  @override
  Interval minSpeed(double? minSpeed) => this(minSpeed: minSpeed);

  @override
  Interval maxSpeed(double? maxSpeed) => this(maxSpeed: maxSpeed);

  @override
  Interval gap(double? gap) => this(gap: gap);

  @override
  Interval averageHeartrate(int? averageHeartrate) =>
      this(averageHeartrate: averageHeartrate);

  @override
  Interval minHeartrate(int? minHeartrate) => this(minHeartrate: minHeartrate);

  @override
  Interval maxHeartrate(int? maxHeartrate) => this(maxHeartrate: maxHeartrate);

  @override
  Interval averageCadence(double? averageCadence) =>
      this(averageCadence: averageCadence);

  @override
  Interval minCadence(int? minCadence) => this(minCadence: minCadence);

  @override
  Interval maxCadence(int? maxCadence) => this(maxCadence: maxCadence);

  @override
  Interval averageTorque(double? averageTorque) =>
      this(averageTorque: averageTorque);

  @override
  Interval minTorque(double? minTorque) => this(minTorque: minTorque);

  @override
  Interval maxTorque(double? maxTorque) => this(maxTorque: maxTorque);

  @override
  Interval totalElevationGain(double? totalElevationGain) =>
      this(totalElevationGain: totalElevationGain);

  @override
  Interval minAltitude(double? minAltitude) => this(minAltitude: minAltitude);

  @override
  Interval maxAltitude(double? maxAltitude) => this(maxAltitude: maxAltitude);

  @override
  Interval averageGradient(double? averageGradient) =>
      this(averageGradient: averageGradient);

  @override
  Interval averageSmo2(double? averageSmo2) => this(averageSmo2: averageSmo2);

  @override
  Interval averageThb(double? averageThb) => this(averageThb: averageThb);

  @override
  Interval averageSmo22(double? averageSmo22) =>
      this(averageSmo22: averageSmo22);

  @override
  Interval averageThb2(double? averageThb2) => this(averageThb2: averageThb2);

  @override
  Interval averageLactate(double? averageLactate) =>
      this(averageLactate: averageLactate);

  @override
  Interval minLactate(double? minLactate) => this(minLactate: minLactate);

  @override
  Interval maxLactate(double? maxLactate) => this(maxLactate: maxLactate);

  @override
  Interval averageStanceTime(double? averageStanceTime) =>
      this(averageStanceTime: averageStanceTime);

  @override
  Interval averageVerticalOscillation(double? averageVerticalOscillation) =>
      this(averageVerticalOscillation: averageVerticalOscillation);

  @override
  Interval averageVerticalRatio(double? averageVerticalRatio) =>
      this(averageVerticalRatio: averageVerticalRatio);

  @override
  Interval averageStepLength(double? averageStepLength) =>
      this(averageStepLength: averageStepLength);

  @override
  Interval averageStanceTimePercent(double? averageStanceTimePercent) =>
      this(averageStanceTimePercent: averageStanceTimePercent);

  @override
  Interval averageStanceTimeBalance(double? averageStanceTimeBalance) =>
      this(averageStanceTimeBalance: averageStanceTimeBalance);

  @override
  Interval averageVerticalSpeed(double? averageVerticalSpeed) =>
      this(averageVerticalSpeed: averageVerticalSpeed);

  @override
  Interval averageLegSpringStiffness(double? averageLegSpringStiffness) =>
      this(averageLegSpringStiffness: averageLegSpringStiffness);

  @override
  Interval averageImpactLoadingRate(double? averageImpactLoadingRate) =>
      this(averageImpactLoadingRate: averageImpactLoadingRate);

  @override
  Interval averageTemp(double? averageTemp) => this(averageTemp: averageTemp);

  @override
  Interval averageWeatherTemp(double? averageWeatherTemp) =>
      this(averageWeatherTemp: averageWeatherTemp);

  @override
  Interval averageFeelsLike(double? averageFeelsLike) =>
      this(averageFeelsLike: averageFeelsLike);

  @override
  Interval averageWindSpeed(double? averageWindSpeed) =>
      this(averageWindSpeed: averageWindSpeed);

  @override
  Interval averageWindGust(double? averageWindGust) =>
      this(averageWindGust: averageWindGust);

  @override
  Interval prevailingWindDeg(int? prevailingWindDeg) =>
      this(prevailingWindDeg: prevailingWindDeg);

  @override
  Interval averageYaw(double? averageYaw) => this(averageYaw: averageYaw);

  @override
  Interval headwindPercent(double? headwindPercent) =>
      this(headwindPercent: headwindPercent);

  @override
  Interval tailwindPercent(double? tailwindPercent) =>
      this(tailwindPercent: tailwindPercent);

  @override
  Interval strainScore(double? strainScore) => this(strainScore: strainScore);

  @override
  Interval ssPMax(double? ssPMax) => this(ssPMax: ssPMax);

  @override
  Interval ssWPrime(double? ssWPrime) => this(ssWPrime: ssWPrime);

  @override
  Interval ssCp(double? ssCp) => this(ssCp: ssCp);

  @override
  Interval id(int? id) => this(id: id);

  @override
  Interval type(IntervalTypeEnum? type) => this(type: type);

  @override
  Interval endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  Interval groupId(String? groupId) => this(groupId: groupId);

  @override
  Interval segmentEffortIds(List<int>? segmentEffortIds) =>
      this(segmentEffortIds: segmentEffortIds);

  @override
  Interval startTime(int? startTime) => this(startTime: startTime);

  @override
  Interval endTime(int? endTime) => this(endTime: endTime);

  @override
  Interval label(String? label) => this(label: label);

  @override
  Interval averageStride(double? averageStride) =>
      this(averageStride: averageStride);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Interval(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Interval(...).copyWith(id: 12, name: "My name")
  /// ````
  Interval call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? elapsedTime = const $CopyWithPlaceholder(),
    Object? averageWatts = const $CopyWithPlaceholder(),
    Object? averageWattsAlt = const $CopyWithPlaceholder(),
    Object? averageWattsAltAcc = const $CopyWithPlaceholder(),
    Object? minWatts = const $CopyWithPlaceholder(),
    Object? maxWatts = const $CopyWithPlaceholder(),
    Object? averageWattsKg = const $CopyWithPlaceholder(),
    Object? maxWattsKg = const $CopyWithPlaceholder(),
    Object? intensity = const $CopyWithPlaceholder(),
    Object? w5sVariability = const $CopyWithPlaceholder(),
    Object? weightedAverageWatts = const $CopyWithPlaceholder(),
    Object? trainingLoad = const $CopyWithPlaceholder(),
    Object? joules = const $CopyWithPlaceholder(),
    Object? joulesAboveFtp = const $CopyWithPlaceholder(),
    Object? decoupling = const $CopyWithPlaceholder(),
    Object? avgLrBalance = const $CopyWithPlaceholder(),
    Object? averageDfaA1 = const $CopyWithPlaceholder(),
    Object? averageEpoc = const $CopyWithPlaceholder(),
    Object? wbalStart = const $CopyWithPlaceholder(),
    Object? wbalEnd = const $CopyWithPlaceholder(),
    Object? averageRespiration = const $CopyWithPlaceholder(),
    Object? averageTidalVolume = const $CopyWithPlaceholder(),
    Object? averageTidalVolumeMin = const $CopyWithPlaceholder(),
    Object? zone = const $CopyWithPlaceholder(),
    Object? zoneMinWatts = const $CopyWithPlaceholder(),
    Object? zoneMaxWatts = const $CopyWithPlaceholder(),
    Object? averageSpeed = const $CopyWithPlaceholder(),
    Object? minSpeed = const $CopyWithPlaceholder(),
    Object? maxSpeed = const $CopyWithPlaceholder(),
    Object? gap = const $CopyWithPlaceholder(),
    Object? averageHeartrate = const $CopyWithPlaceholder(),
    Object? minHeartrate = const $CopyWithPlaceholder(),
    Object? maxHeartrate = const $CopyWithPlaceholder(),
    Object? averageCadence = const $CopyWithPlaceholder(),
    Object? minCadence = const $CopyWithPlaceholder(),
    Object? maxCadence = const $CopyWithPlaceholder(),
    Object? averageTorque = const $CopyWithPlaceholder(),
    Object? minTorque = const $CopyWithPlaceholder(),
    Object? maxTorque = const $CopyWithPlaceholder(),
    Object? totalElevationGain = const $CopyWithPlaceholder(),
    Object? minAltitude = const $CopyWithPlaceholder(),
    Object? maxAltitude = const $CopyWithPlaceholder(),
    Object? averageGradient = const $CopyWithPlaceholder(),
    Object? averageSmo2 = const $CopyWithPlaceholder(),
    Object? averageThb = const $CopyWithPlaceholder(),
    Object? averageSmo22 = const $CopyWithPlaceholder(),
    Object? averageThb2 = const $CopyWithPlaceholder(),
    Object? averageLactate = const $CopyWithPlaceholder(),
    Object? minLactate = const $CopyWithPlaceholder(),
    Object? maxLactate = const $CopyWithPlaceholder(),
    Object? averageStanceTime = const $CopyWithPlaceholder(),
    Object? averageVerticalOscillation = const $CopyWithPlaceholder(),
    Object? averageVerticalRatio = const $CopyWithPlaceholder(),
    Object? averageStepLength = const $CopyWithPlaceholder(),
    Object? averageStanceTimePercent = const $CopyWithPlaceholder(),
    Object? averageStanceTimeBalance = const $CopyWithPlaceholder(),
    Object? averageVerticalSpeed = const $CopyWithPlaceholder(),
    Object? averageLegSpringStiffness = const $CopyWithPlaceholder(),
    Object? averageImpactLoadingRate = const $CopyWithPlaceholder(),
    Object? averageTemp = const $CopyWithPlaceholder(),
    Object? averageWeatherTemp = const $CopyWithPlaceholder(),
    Object? averageFeelsLike = const $CopyWithPlaceholder(),
    Object? averageWindSpeed = const $CopyWithPlaceholder(),
    Object? averageWindGust = const $CopyWithPlaceholder(),
    Object? prevailingWindDeg = const $CopyWithPlaceholder(),
    Object? averageYaw = const $CopyWithPlaceholder(),
    Object? headwindPercent = const $CopyWithPlaceholder(),
    Object? tailwindPercent = const $CopyWithPlaceholder(),
    Object? strainScore = const $CopyWithPlaceholder(),
    Object? ssPMax = const $CopyWithPlaceholder(),
    Object? ssWPrime = const $CopyWithPlaceholder(),
    Object? ssCp = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? groupId = const $CopyWithPlaceholder(),
    Object? segmentEffortIds = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? endTime = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? averageStride = const $CopyWithPlaceholder(),
  }) {
    return Interval(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as int?,
      elapsedTime: elapsedTime == const $CopyWithPlaceholder()
          ? _value.elapsedTime
          // ignore: cast_nullable_to_non_nullable
          : elapsedTime as int?,
      averageWatts: averageWatts == const $CopyWithPlaceholder()
          ? _value.averageWatts
          // ignore: cast_nullable_to_non_nullable
          : averageWatts as int?,
      averageWattsAlt: averageWattsAlt == const $CopyWithPlaceholder()
          ? _value.averageWattsAlt
          // ignore: cast_nullable_to_non_nullable
          : averageWattsAlt as int?,
      averageWattsAltAcc: averageWattsAltAcc == const $CopyWithPlaceholder()
          ? _value.averageWattsAltAcc
          // ignore: cast_nullable_to_non_nullable
          : averageWattsAltAcc as int?,
      minWatts: minWatts == const $CopyWithPlaceholder()
          ? _value.minWatts
          // ignore: cast_nullable_to_non_nullable
          : minWatts as int?,
      maxWatts: maxWatts == const $CopyWithPlaceholder()
          ? _value.maxWatts
          // ignore: cast_nullable_to_non_nullable
          : maxWatts as int?,
      averageWattsKg: averageWattsKg == const $CopyWithPlaceholder()
          ? _value.averageWattsKg
          // ignore: cast_nullable_to_non_nullable
          : averageWattsKg as double?,
      maxWattsKg: maxWattsKg == const $CopyWithPlaceholder()
          ? _value.maxWattsKg
          // ignore: cast_nullable_to_non_nullable
          : maxWattsKg as double?,
      intensity: intensity == const $CopyWithPlaceholder()
          ? _value.intensity
          // ignore: cast_nullable_to_non_nullable
          : intensity as int?,
      w5sVariability: w5sVariability == const $CopyWithPlaceholder()
          ? _value.w5sVariability
          // ignore: cast_nullable_to_non_nullable
          : w5sVariability as double?,
      weightedAverageWatts: weightedAverageWatts == const $CopyWithPlaceholder()
          ? _value.weightedAverageWatts
          // ignore: cast_nullable_to_non_nullable
          : weightedAverageWatts as int?,
      trainingLoad: trainingLoad == const $CopyWithPlaceholder()
          ? _value.trainingLoad
          // ignore: cast_nullable_to_non_nullable
          : trainingLoad as double?,
      joules: joules == const $CopyWithPlaceholder()
          ? _value.joules
          // ignore: cast_nullable_to_non_nullable
          : joules as int?,
      joulesAboveFtp: joulesAboveFtp == const $CopyWithPlaceholder()
          ? _value.joulesAboveFtp
          // ignore: cast_nullable_to_non_nullable
          : joulesAboveFtp as int?,
      decoupling: decoupling == const $CopyWithPlaceholder()
          ? _value.decoupling
          // ignore: cast_nullable_to_non_nullable
          : decoupling as double?,
      avgLrBalance: avgLrBalance == const $CopyWithPlaceholder()
          ? _value.avgLrBalance
          // ignore: cast_nullable_to_non_nullable
          : avgLrBalance as double?,
      averageDfaA1: averageDfaA1 == const $CopyWithPlaceholder()
          ? _value.averageDfaA1
          // ignore: cast_nullable_to_non_nullable
          : averageDfaA1 as double?,
      averageEpoc: averageEpoc == const $CopyWithPlaceholder()
          ? _value.averageEpoc
          // ignore: cast_nullable_to_non_nullable
          : averageEpoc as double?,
      wbalStart: wbalStart == const $CopyWithPlaceholder()
          ? _value.wbalStart
          // ignore: cast_nullable_to_non_nullable
          : wbalStart as int?,
      wbalEnd: wbalEnd == const $CopyWithPlaceholder()
          ? _value.wbalEnd
          // ignore: cast_nullable_to_non_nullable
          : wbalEnd as int?,
      averageRespiration: averageRespiration == const $CopyWithPlaceholder()
          ? _value.averageRespiration
          // ignore: cast_nullable_to_non_nullable
          : averageRespiration as double?,
      averageTidalVolume: averageTidalVolume == const $CopyWithPlaceholder()
          ? _value.averageTidalVolume
          // ignore: cast_nullable_to_non_nullable
          : averageTidalVolume as double?,
      averageTidalVolumeMin:
          averageTidalVolumeMin == const $CopyWithPlaceholder()
          ? _value.averageTidalVolumeMin
          // ignore: cast_nullable_to_non_nullable
          : averageTidalVolumeMin as double?,
      zone: zone == const $CopyWithPlaceholder()
          ? _value.zone
          // ignore: cast_nullable_to_non_nullable
          : zone as int?,
      zoneMinWatts: zoneMinWatts == const $CopyWithPlaceholder()
          ? _value.zoneMinWatts
          // ignore: cast_nullable_to_non_nullable
          : zoneMinWatts as int?,
      zoneMaxWatts: zoneMaxWatts == const $CopyWithPlaceholder()
          ? _value.zoneMaxWatts
          // ignore: cast_nullable_to_non_nullable
          : zoneMaxWatts as int?,
      averageSpeed: averageSpeed == const $CopyWithPlaceholder()
          ? _value.averageSpeed
          // ignore: cast_nullable_to_non_nullable
          : averageSpeed as double?,
      minSpeed: minSpeed == const $CopyWithPlaceholder()
          ? _value.minSpeed
          // ignore: cast_nullable_to_non_nullable
          : minSpeed as double?,
      maxSpeed: maxSpeed == const $CopyWithPlaceholder()
          ? _value.maxSpeed
          // ignore: cast_nullable_to_non_nullable
          : maxSpeed as double?,
      gap: gap == const $CopyWithPlaceholder()
          ? _value.gap
          // ignore: cast_nullable_to_non_nullable
          : gap as double?,
      averageHeartrate: averageHeartrate == const $CopyWithPlaceholder()
          ? _value.averageHeartrate
          // ignore: cast_nullable_to_non_nullable
          : averageHeartrate as int?,
      minHeartrate: minHeartrate == const $CopyWithPlaceholder()
          ? _value.minHeartrate
          // ignore: cast_nullable_to_non_nullable
          : minHeartrate as int?,
      maxHeartrate: maxHeartrate == const $CopyWithPlaceholder()
          ? _value.maxHeartrate
          // ignore: cast_nullable_to_non_nullable
          : maxHeartrate as int?,
      averageCadence: averageCadence == const $CopyWithPlaceholder()
          ? _value.averageCadence
          // ignore: cast_nullable_to_non_nullable
          : averageCadence as double?,
      minCadence: minCadence == const $CopyWithPlaceholder()
          ? _value.minCadence
          // ignore: cast_nullable_to_non_nullable
          : minCadence as int?,
      maxCadence: maxCadence == const $CopyWithPlaceholder()
          ? _value.maxCadence
          // ignore: cast_nullable_to_non_nullable
          : maxCadence as int?,
      averageTorque: averageTorque == const $CopyWithPlaceholder()
          ? _value.averageTorque
          // ignore: cast_nullable_to_non_nullable
          : averageTorque as double?,
      minTorque: minTorque == const $CopyWithPlaceholder()
          ? _value.minTorque
          // ignore: cast_nullable_to_non_nullable
          : minTorque as double?,
      maxTorque: maxTorque == const $CopyWithPlaceholder()
          ? _value.maxTorque
          // ignore: cast_nullable_to_non_nullable
          : maxTorque as double?,
      totalElevationGain: totalElevationGain == const $CopyWithPlaceholder()
          ? _value.totalElevationGain
          // ignore: cast_nullable_to_non_nullable
          : totalElevationGain as double?,
      minAltitude: minAltitude == const $CopyWithPlaceholder()
          ? _value.minAltitude
          // ignore: cast_nullable_to_non_nullable
          : minAltitude as double?,
      maxAltitude: maxAltitude == const $CopyWithPlaceholder()
          ? _value.maxAltitude
          // ignore: cast_nullable_to_non_nullable
          : maxAltitude as double?,
      averageGradient: averageGradient == const $CopyWithPlaceholder()
          ? _value.averageGradient
          // ignore: cast_nullable_to_non_nullable
          : averageGradient as double?,
      averageSmo2: averageSmo2 == const $CopyWithPlaceholder()
          ? _value.averageSmo2
          // ignore: cast_nullable_to_non_nullable
          : averageSmo2 as double?,
      averageThb: averageThb == const $CopyWithPlaceholder()
          ? _value.averageThb
          // ignore: cast_nullable_to_non_nullable
          : averageThb as double?,
      averageSmo22: averageSmo22 == const $CopyWithPlaceholder()
          ? _value.averageSmo22
          // ignore: cast_nullable_to_non_nullable
          : averageSmo22 as double?,
      averageThb2: averageThb2 == const $CopyWithPlaceholder()
          ? _value.averageThb2
          // ignore: cast_nullable_to_non_nullable
          : averageThb2 as double?,
      averageLactate: averageLactate == const $CopyWithPlaceholder()
          ? _value.averageLactate
          // ignore: cast_nullable_to_non_nullable
          : averageLactate as double?,
      minLactate: minLactate == const $CopyWithPlaceholder()
          ? _value.minLactate
          // ignore: cast_nullable_to_non_nullable
          : minLactate as double?,
      maxLactate: maxLactate == const $CopyWithPlaceholder()
          ? _value.maxLactate
          // ignore: cast_nullable_to_non_nullable
          : maxLactate as double?,
      averageStanceTime: averageStanceTime == const $CopyWithPlaceholder()
          ? _value.averageStanceTime
          // ignore: cast_nullable_to_non_nullable
          : averageStanceTime as double?,
      averageVerticalOscillation:
          averageVerticalOscillation == const $CopyWithPlaceholder()
          ? _value.averageVerticalOscillation
          // ignore: cast_nullable_to_non_nullable
          : averageVerticalOscillation as double?,
      averageVerticalRatio: averageVerticalRatio == const $CopyWithPlaceholder()
          ? _value.averageVerticalRatio
          // ignore: cast_nullable_to_non_nullable
          : averageVerticalRatio as double?,
      averageStepLength: averageStepLength == const $CopyWithPlaceholder()
          ? _value.averageStepLength
          // ignore: cast_nullable_to_non_nullable
          : averageStepLength as double?,
      averageStanceTimePercent:
          averageStanceTimePercent == const $CopyWithPlaceholder()
          ? _value.averageStanceTimePercent
          // ignore: cast_nullable_to_non_nullable
          : averageStanceTimePercent as double?,
      averageStanceTimeBalance:
          averageStanceTimeBalance == const $CopyWithPlaceholder()
          ? _value.averageStanceTimeBalance
          // ignore: cast_nullable_to_non_nullable
          : averageStanceTimeBalance as double?,
      averageVerticalSpeed: averageVerticalSpeed == const $CopyWithPlaceholder()
          ? _value.averageVerticalSpeed
          // ignore: cast_nullable_to_non_nullable
          : averageVerticalSpeed as double?,
      averageLegSpringStiffness:
          averageLegSpringStiffness == const $CopyWithPlaceholder()
          ? _value.averageLegSpringStiffness
          // ignore: cast_nullable_to_non_nullable
          : averageLegSpringStiffness as double?,
      averageImpactLoadingRate:
          averageImpactLoadingRate == const $CopyWithPlaceholder()
          ? _value.averageImpactLoadingRate
          // ignore: cast_nullable_to_non_nullable
          : averageImpactLoadingRate as double?,
      averageTemp: averageTemp == const $CopyWithPlaceholder()
          ? _value.averageTemp
          // ignore: cast_nullable_to_non_nullable
          : averageTemp as double?,
      averageWeatherTemp: averageWeatherTemp == const $CopyWithPlaceholder()
          ? _value.averageWeatherTemp
          // ignore: cast_nullable_to_non_nullable
          : averageWeatherTemp as double?,
      averageFeelsLike: averageFeelsLike == const $CopyWithPlaceholder()
          ? _value.averageFeelsLike
          // ignore: cast_nullable_to_non_nullable
          : averageFeelsLike as double?,
      averageWindSpeed: averageWindSpeed == const $CopyWithPlaceholder()
          ? _value.averageWindSpeed
          // ignore: cast_nullable_to_non_nullable
          : averageWindSpeed as double?,
      averageWindGust: averageWindGust == const $CopyWithPlaceholder()
          ? _value.averageWindGust
          // ignore: cast_nullable_to_non_nullable
          : averageWindGust as double?,
      prevailingWindDeg: prevailingWindDeg == const $CopyWithPlaceholder()
          ? _value.prevailingWindDeg
          // ignore: cast_nullable_to_non_nullable
          : prevailingWindDeg as int?,
      averageYaw: averageYaw == const $CopyWithPlaceholder()
          ? _value.averageYaw
          // ignore: cast_nullable_to_non_nullable
          : averageYaw as double?,
      headwindPercent: headwindPercent == const $CopyWithPlaceholder()
          ? _value.headwindPercent
          // ignore: cast_nullable_to_non_nullable
          : headwindPercent as double?,
      tailwindPercent: tailwindPercent == const $CopyWithPlaceholder()
          ? _value.tailwindPercent
          // ignore: cast_nullable_to_non_nullable
          : tailwindPercent as double?,
      strainScore: strainScore == const $CopyWithPlaceholder()
          ? _value.strainScore
          // ignore: cast_nullable_to_non_nullable
          : strainScore as double?,
      ssPMax: ssPMax == const $CopyWithPlaceholder()
          ? _value.ssPMax
          // ignore: cast_nullable_to_non_nullable
          : ssPMax as double?,
      ssWPrime: ssWPrime == const $CopyWithPlaceholder()
          ? _value.ssWPrime
          // ignore: cast_nullable_to_non_nullable
          : ssWPrime as double?,
      ssCp: ssCp == const $CopyWithPlaceholder()
          ? _value.ssCp
          // ignore: cast_nullable_to_non_nullable
          : ssCp as double?,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as IntervalTypeEnum?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      groupId: groupId == const $CopyWithPlaceholder()
          ? _value.groupId
          // ignore: cast_nullable_to_non_nullable
          : groupId as String?,
      segmentEffortIds: segmentEffortIds == const $CopyWithPlaceholder()
          ? _value.segmentEffortIds
          // ignore: cast_nullable_to_non_nullable
          : segmentEffortIds as List<int>?,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as int?,
      endTime: endTime == const $CopyWithPlaceholder()
          ? _value.endTime
          // ignore: cast_nullable_to_non_nullable
          : endTime as int?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String?,
      averageStride: averageStride == const $CopyWithPlaceholder()
          ? _value.averageStride
          // ignore: cast_nullable_to_non_nullable
          : averageStride as double?,
    );
  }
}

extension $IntervalCopyWith on Interval {
  /// Returns a callable class that can be used as follows: `instanceOfInterval.copyWith(...)` or like so:`instanceOfInterval.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IntervalCWProxy get copyWith => _$IntervalCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interval _$IntervalFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Interval',
  json,
  ($checkedConvert) {
    final val = Interval(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      movingTime: $checkedConvert('moving_time', (v) => (v as num?)?.toInt()),
      elapsedTime: $checkedConvert('elapsed_time', (v) => (v as num?)?.toInt()),
      averageWatts: $checkedConvert(
        'average_watts',
        (v) => (v as num?)?.toInt(),
      ),
      averageWattsAlt: $checkedConvert(
        'average_watts_alt',
        (v) => (v as num?)?.toInt(),
      ),
      averageWattsAltAcc: $checkedConvert(
        'average_watts_alt_acc',
        (v) => (v as num?)?.toInt(),
      ),
      minWatts: $checkedConvert('min_watts', (v) => (v as num?)?.toInt()),
      maxWatts: $checkedConvert('max_watts', (v) => (v as num?)?.toInt()),
      averageWattsKg: $checkedConvert(
        'average_watts_kg',
        (v) => (v as num?)?.toDouble(),
      ),
      maxWattsKg: $checkedConvert(
        'max_watts_kg',
        (v) => (v as num?)?.toDouble(),
      ),
      intensity: $checkedConvert('intensity', (v) => (v as num?)?.toInt()),
      w5sVariability: $checkedConvert(
        'w5s_variability',
        (v) => (v as num?)?.toDouble(),
      ),
      weightedAverageWatts: $checkedConvert(
        'weighted_average_watts',
        (v) => (v as num?)?.toInt(),
      ),
      trainingLoad: $checkedConvert(
        'training_load',
        (v) => (v as num?)?.toDouble(),
      ),
      joules: $checkedConvert('joules', (v) => (v as num?)?.toInt()),
      joulesAboveFtp: $checkedConvert(
        'joules_above_ftp',
        (v) => (v as num?)?.toInt(),
      ),
      decoupling: $checkedConvert('decoupling', (v) => (v as num?)?.toDouble()),
      avgLrBalance: $checkedConvert(
        'avg_lr_balance',
        (v) => (v as num?)?.toDouble(),
      ),
      averageDfaA1: $checkedConvert(
        'average_dfa_a1',
        (v) => (v as num?)?.toDouble(),
      ),
      averageEpoc: $checkedConvert(
        'average_epoc',
        (v) => (v as num?)?.toDouble(),
      ),
      wbalStart: $checkedConvert('wbal_start', (v) => (v as num?)?.toInt()),
      wbalEnd: $checkedConvert('wbal_end', (v) => (v as num?)?.toInt()),
      averageRespiration: $checkedConvert(
        'average_respiration',
        (v) => (v as num?)?.toDouble(),
      ),
      averageTidalVolume: $checkedConvert(
        'average_tidal_volume',
        (v) => (v as num?)?.toDouble(),
      ),
      averageTidalVolumeMin: $checkedConvert(
        'average_tidal_volume_min',
        (v) => (v as num?)?.toDouble(),
      ),
      zone: $checkedConvert('zone', (v) => (v as num?)?.toInt()),
      zoneMinWatts: $checkedConvert(
        'zone_min_watts',
        (v) => (v as num?)?.toInt(),
      ),
      zoneMaxWatts: $checkedConvert(
        'zone_max_watts',
        (v) => (v as num?)?.toInt(),
      ),
      averageSpeed: $checkedConvert(
        'average_speed',
        (v) => (v as num?)?.toDouble(),
      ),
      minSpeed: $checkedConvert('min_speed', (v) => (v as num?)?.toDouble()),
      maxSpeed: $checkedConvert('max_speed', (v) => (v as num?)?.toDouble()),
      gap: $checkedConvert('gap', (v) => (v as num?)?.toDouble()),
      averageHeartrate: $checkedConvert(
        'average_heartrate',
        (v) => (v as num?)?.toInt(),
      ),
      minHeartrate: $checkedConvert(
        'min_heartrate',
        (v) => (v as num?)?.toInt(),
      ),
      maxHeartrate: $checkedConvert(
        'max_heartrate',
        (v) => (v as num?)?.toInt(),
      ),
      averageCadence: $checkedConvert(
        'average_cadence',
        (v) => (v as num?)?.toDouble(),
      ),
      minCadence: $checkedConvert('min_cadence', (v) => (v as num?)?.toInt()),
      maxCadence: $checkedConvert('max_cadence', (v) => (v as num?)?.toInt()),
      averageTorque: $checkedConvert(
        'average_torque',
        (v) => (v as num?)?.toDouble(),
      ),
      minTorque: $checkedConvert('min_torque', (v) => (v as num?)?.toDouble()),
      maxTorque: $checkedConvert('max_torque', (v) => (v as num?)?.toDouble()),
      totalElevationGain: $checkedConvert(
        'total_elevation_gain',
        (v) => (v as num?)?.toDouble(),
      ),
      minAltitude: $checkedConvert(
        'min_altitude',
        (v) => (v as num?)?.toDouble(),
      ),
      maxAltitude: $checkedConvert(
        'max_altitude',
        (v) => (v as num?)?.toDouble(),
      ),
      averageGradient: $checkedConvert(
        'average_gradient',
        (v) => (v as num?)?.toDouble(),
      ),
      averageSmo2: $checkedConvert(
        'average_smo2',
        (v) => (v as num?)?.toDouble(),
      ),
      averageThb: $checkedConvert(
        'average_thb',
        (v) => (v as num?)?.toDouble(),
      ),
      averageSmo22: $checkedConvert(
        'average_smo2_2',
        (v) => (v as num?)?.toDouble(),
      ),
      averageThb2: $checkedConvert(
        'average_thb_2',
        (v) => (v as num?)?.toDouble(),
      ),
      averageLactate: $checkedConvert(
        'average_lactate',
        (v) => (v as num?)?.toDouble(),
      ),
      minLactate: $checkedConvert(
        'min_lactate',
        (v) => (v as num?)?.toDouble(),
      ),
      maxLactate: $checkedConvert(
        'max_lactate',
        (v) => (v as num?)?.toDouble(),
      ),
      averageStanceTime: $checkedConvert(
        'average_stance_time',
        (v) => (v as num?)?.toDouble(),
      ),
      averageVerticalOscillation: $checkedConvert(
        'average_vertical_oscillation',
        (v) => (v as num?)?.toDouble(),
      ),
      averageVerticalRatio: $checkedConvert(
        'average_vertical_ratio',
        (v) => (v as num?)?.toDouble(),
      ),
      averageStepLength: $checkedConvert(
        'average_step_length',
        (v) => (v as num?)?.toDouble(),
      ),
      averageStanceTimePercent: $checkedConvert(
        'average_stance_time_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      averageStanceTimeBalance: $checkedConvert(
        'average_stance_time_balance',
        (v) => (v as num?)?.toDouble(),
      ),
      averageVerticalSpeed: $checkedConvert(
        'average_vertical_speed',
        (v) => (v as num?)?.toDouble(),
      ),
      averageLegSpringStiffness: $checkedConvert(
        'average_leg_spring_stiffness',
        (v) => (v as num?)?.toDouble(),
      ),
      averageImpactLoadingRate: $checkedConvert(
        'average_impact_loading_rate',
        (v) => (v as num?)?.toDouble(),
      ),
      averageTemp: $checkedConvert(
        'average_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      averageWeatherTemp: $checkedConvert(
        'average_weather_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      averageFeelsLike: $checkedConvert(
        'average_feels_like',
        (v) => (v as num?)?.toDouble(),
      ),
      averageWindSpeed: $checkedConvert(
        'average_wind_speed',
        (v) => (v as num?)?.toDouble(),
      ),
      averageWindGust: $checkedConvert(
        'average_wind_gust',
        (v) => (v as num?)?.toDouble(),
      ),
      prevailingWindDeg: $checkedConvert(
        'prevailing_wind_deg',
        (v) => (v as num?)?.toInt(),
      ),
      averageYaw: $checkedConvert(
        'average_yaw',
        (v) => (v as num?)?.toDouble(),
      ),
      headwindPercent: $checkedConvert(
        'headwind_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      tailwindPercent: $checkedConvert(
        'tailwind_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      strainScore: $checkedConvert(
        'strain_score',
        (v) => (v as num?)?.toDouble(),
      ),
      ssPMax: $checkedConvert('ss_p_max', (v) => (v as num?)?.toDouble()),
      ssWPrime: $checkedConvert('ss_w_prime', (v) => (v as num?)?.toDouble()),
      ssCp: $checkedConvert('ss_cp', (v) => (v as num?)?.toDouble()),
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$IntervalTypeEnumEnumMap, v),
      ),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      groupId: $checkedConvert('group_id', (v) => v as String?),
      segmentEffortIds: $checkedConvert(
        'segment_effort_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      startTime: $checkedConvert('start_time', (v) => (v as num?)?.toInt()),
      endTime: $checkedConvert('end_time', (v) => (v as num?)?.toInt()),
      label: $checkedConvert('label', (v) => v as String?),
      averageStride: $checkedConvert(
        'average_stride',
        (v) => (v as num?)?.toDouble(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'startIndex': 'start_index',
    'movingTime': 'moving_time',
    'elapsedTime': 'elapsed_time',
    'averageWatts': 'average_watts',
    'averageWattsAlt': 'average_watts_alt',
    'averageWattsAltAcc': 'average_watts_alt_acc',
    'minWatts': 'min_watts',
    'maxWatts': 'max_watts',
    'averageWattsKg': 'average_watts_kg',
    'maxWattsKg': 'max_watts_kg',
    'w5sVariability': 'w5s_variability',
    'weightedAverageWatts': 'weighted_average_watts',
    'trainingLoad': 'training_load',
    'joulesAboveFtp': 'joules_above_ftp',
    'avgLrBalance': 'avg_lr_balance',
    'averageDfaA1': 'average_dfa_a1',
    'averageEpoc': 'average_epoc',
    'wbalStart': 'wbal_start',
    'wbalEnd': 'wbal_end',
    'averageRespiration': 'average_respiration',
    'averageTidalVolume': 'average_tidal_volume',
    'averageTidalVolumeMin': 'average_tidal_volume_min',
    'zoneMinWatts': 'zone_min_watts',
    'zoneMaxWatts': 'zone_max_watts',
    'averageSpeed': 'average_speed',
    'minSpeed': 'min_speed',
    'maxSpeed': 'max_speed',
    'averageHeartrate': 'average_heartrate',
    'minHeartrate': 'min_heartrate',
    'maxHeartrate': 'max_heartrate',
    'averageCadence': 'average_cadence',
    'minCadence': 'min_cadence',
    'maxCadence': 'max_cadence',
    'averageTorque': 'average_torque',
    'minTorque': 'min_torque',
    'maxTorque': 'max_torque',
    'totalElevationGain': 'total_elevation_gain',
    'minAltitude': 'min_altitude',
    'maxAltitude': 'max_altitude',
    'averageGradient': 'average_gradient',
    'averageSmo2': 'average_smo2',
    'averageThb': 'average_thb',
    'averageSmo22': 'average_smo2_2',
    'averageThb2': 'average_thb_2',
    'averageLactate': 'average_lactate',
    'minLactate': 'min_lactate',
    'maxLactate': 'max_lactate',
    'averageStanceTime': 'average_stance_time',
    'averageVerticalOscillation': 'average_vertical_oscillation',
    'averageVerticalRatio': 'average_vertical_ratio',
    'averageStepLength': 'average_step_length',
    'averageStanceTimePercent': 'average_stance_time_percent',
    'averageStanceTimeBalance': 'average_stance_time_balance',
    'averageVerticalSpeed': 'average_vertical_speed',
    'averageLegSpringStiffness': 'average_leg_spring_stiffness',
    'averageImpactLoadingRate': 'average_impact_loading_rate',
    'averageTemp': 'average_temp',
    'averageWeatherTemp': 'average_weather_temp',
    'averageFeelsLike': 'average_feels_like',
    'averageWindSpeed': 'average_wind_speed',
    'averageWindGust': 'average_wind_gust',
    'prevailingWindDeg': 'prevailing_wind_deg',
    'averageYaw': 'average_yaw',
    'headwindPercent': 'headwind_percent',
    'tailwindPercent': 'tailwind_percent',
    'strainScore': 'strain_score',
    'ssPMax': 'ss_p_max',
    'ssWPrime': 'ss_w_prime',
    'ssCp': 'ss_cp',
    'endIndex': 'end_index',
    'groupId': 'group_id',
    'segmentEffortIds': 'segment_effort_ids',
    'startTime': 'start_time',
    'endTime': 'end_time',
    'averageStride': 'average_stride',
  },
);

Map<String, dynamic> _$IntervalToJson(Interval instance) => <String, dynamic>{
  'start_index': ?instance.startIndex,
  'distance': ?instance.distance,
  'moving_time': ?instance.movingTime,
  'elapsed_time': ?instance.elapsedTime,
  'average_watts': ?instance.averageWatts,
  'average_watts_alt': ?instance.averageWattsAlt,
  'average_watts_alt_acc': ?instance.averageWattsAltAcc,
  'min_watts': ?instance.minWatts,
  'max_watts': ?instance.maxWatts,
  'average_watts_kg': ?instance.averageWattsKg,
  'max_watts_kg': ?instance.maxWattsKg,
  'intensity': ?instance.intensity,
  'w5s_variability': ?instance.w5sVariability,
  'weighted_average_watts': ?instance.weightedAverageWatts,
  'training_load': ?instance.trainingLoad,
  'joules': ?instance.joules,
  'joules_above_ftp': ?instance.joulesAboveFtp,
  'decoupling': ?instance.decoupling,
  'avg_lr_balance': ?instance.avgLrBalance,
  'average_dfa_a1': ?instance.averageDfaA1,
  'average_epoc': ?instance.averageEpoc,
  'wbal_start': ?instance.wbalStart,
  'wbal_end': ?instance.wbalEnd,
  'average_respiration': ?instance.averageRespiration,
  'average_tidal_volume': ?instance.averageTidalVolume,
  'average_tidal_volume_min': ?instance.averageTidalVolumeMin,
  'zone': ?instance.zone,
  'zone_min_watts': ?instance.zoneMinWatts,
  'zone_max_watts': ?instance.zoneMaxWatts,
  'average_speed': ?instance.averageSpeed,
  'min_speed': ?instance.minSpeed,
  'max_speed': ?instance.maxSpeed,
  'gap': ?instance.gap,
  'average_heartrate': ?instance.averageHeartrate,
  'min_heartrate': ?instance.minHeartrate,
  'max_heartrate': ?instance.maxHeartrate,
  'average_cadence': ?instance.averageCadence,
  'min_cadence': ?instance.minCadence,
  'max_cadence': ?instance.maxCadence,
  'average_torque': ?instance.averageTorque,
  'min_torque': ?instance.minTorque,
  'max_torque': ?instance.maxTorque,
  'total_elevation_gain': ?instance.totalElevationGain,
  'min_altitude': ?instance.minAltitude,
  'max_altitude': ?instance.maxAltitude,
  'average_gradient': ?instance.averageGradient,
  'average_smo2': ?instance.averageSmo2,
  'average_thb': ?instance.averageThb,
  'average_smo2_2': ?instance.averageSmo22,
  'average_thb_2': ?instance.averageThb2,
  'average_lactate': ?instance.averageLactate,
  'min_lactate': ?instance.minLactate,
  'max_lactate': ?instance.maxLactate,
  'average_stance_time': ?instance.averageStanceTime,
  'average_vertical_oscillation': ?instance.averageVerticalOscillation,
  'average_vertical_ratio': ?instance.averageVerticalRatio,
  'average_step_length': ?instance.averageStepLength,
  'average_stance_time_percent': ?instance.averageStanceTimePercent,
  'average_stance_time_balance': ?instance.averageStanceTimeBalance,
  'average_vertical_speed': ?instance.averageVerticalSpeed,
  'average_leg_spring_stiffness': ?instance.averageLegSpringStiffness,
  'average_impact_loading_rate': ?instance.averageImpactLoadingRate,
  'average_temp': ?instance.averageTemp,
  'average_weather_temp': ?instance.averageWeatherTemp,
  'average_feels_like': ?instance.averageFeelsLike,
  'average_wind_speed': ?instance.averageWindSpeed,
  'average_wind_gust': ?instance.averageWindGust,
  'prevailing_wind_deg': ?instance.prevailingWindDeg,
  'average_yaw': ?instance.averageYaw,
  'headwind_percent': ?instance.headwindPercent,
  'tailwind_percent': ?instance.tailwindPercent,
  'strain_score': ?instance.strainScore,
  'ss_p_max': ?instance.ssPMax,
  'ss_w_prime': ?instance.ssWPrime,
  'ss_cp': ?instance.ssCp,
  'id': ?instance.id,
  'type': ?_$IntervalTypeEnumEnumMap[instance.type],
  'end_index': ?instance.endIndex,
  'group_id': ?instance.groupId,
  'segment_effort_ids': ?instance.segmentEffortIds,
  'start_time': ?instance.startTime,
  'end_time': ?instance.endTime,
  'label': ?instance.label,
  'average_stride': ?instance.averageStride,
};

const _$IntervalTypeEnumEnumMap = {
  IntervalTypeEnum.RECOVERY: 'RECOVERY',
  IntervalTypeEnum.WORK: 'WORK',
};
