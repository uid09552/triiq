// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityCWProxy {
  Activity id(String? id);

  Activity startDateLocal(String? startDateLocal);

  Activity type(String? type);

  Activity icuIgnoreTime(bool? icuIgnoreTime);

  Activity icuPmCp(int? icuPmCp);

  Activity icuPmWPrime(int? icuPmWPrime);

  Activity icuPmPMax(int? icuPmPMax);

  Activity icuPmFtp(int? icuPmFtp);

  Activity icuPmFtpSecs(int? icuPmFtpSecs);

  Activity icuPmFtpWatts(int? icuPmFtpWatts);

  Activity icuIgnorePower(bool? icuIgnorePower);

  Activity icuRollingCp(double? icuRollingCp);

  Activity icuRollingWPrime(double? icuRollingWPrime);

  Activity icuRollingPMax(double? icuRollingPMax);

  Activity icuRollingFtp(int? icuRollingFtp);

  Activity icuRollingFtpDelta(int? icuRollingFtpDelta);

  Activity icuTrainingLoad(int? icuTrainingLoad);

  Activity icuAtl(double? icuAtl);

  Activity icuCtl(double? icuCtl);

  Activity ssPMax(double? ssPMax);

  Activity ssWPrime(double? ssWPrime);

  Activity ssCp(double? ssCp);

  Activity pairedEventId(int? pairedEventId);

  Activity icuFtp(int? icuFtp);

  Activity icuJoules(int? icuJoules);

  Activity icuRecordingTime(int? icuRecordingTime);

  Activity elapsedTime(int? elapsedTime);

  Activity icuWeightedAvgWatts(int? icuWeightedAvgWatts);

  Activity carbsUsed(int? carbsUsed);

  Activity name(String? name);

  Activity description(String? description);

  Activity startDate(String? startDate);

  Activity distance(double? distance);

  Activity icuDistance(double? icuDistance);

  Activity movingTime(int? movingTime);

  Activity coastingTime(int? coastingTime);

  Activity totalElevationGain(double? totalElevationGain);

  Activity totalElevationLoss(double? totalElevationLoss);

  Activity timezone(String? timezone);

  Activity trainer(bool? trainer);

  Activity subType(ActivitySubTypeEnum? subType);

  Activity commute(bool? commute);

  Activity race(bool? race);

  Activity maxSpeed(double? maxSpeed);

  Activity averageSpeed(double? averageSpeed);

  Activity deviceWatts(bool? deviceWatts);

  Activity hasHeartrate(bool? hasHeartrate);

  Activity maxHeartrate(int? maxHeartrate);

  Activity averageHeartrate(int? averageHeartrate);

  Activity averageCadence(double? averageCadence);

  Activity calories(int? calories);

  Activity averageTemp(double? averageTemp);

  Activity minTemp(int? minTemp);

  Activity maxTemp(int? maxTemp);

  Activity avgLrBalance(double? avgLrBalance);

  Activity averageStanceTime(double? averageStanceTime);

  Activity averageVerticalOscillation(double? averageVerticalOscillation);

  Activity averageVerticalRatio(double? averageVerticalRatio);

  Activity averageStepLength(double? averageStepLength);

  Activity averageStanceTimePercent(double? averageStanceTimePercent);

  Activity averageStanceTimeBalance(double? averageStanceTimeBalance);

  Activity averageVerticalSpeed(double? averageVerticalSpeed);

  Activity averageLegSpringStiffness(double? averageLegSpringStiffness);

  Activity averageImpactLoadingRate(double? averageImpactLoadingRate);

  Activity gap(double? gap);

  Activity gapModel(ActivityGapModelEnum? gapModel);

  Activity useElevationCorrection(bool? useElevationCorrection);

  Activity gear(StravaGear? gear);

  Activity perceivedExertion(double? perceivedExertion);

  Activity deviceName(String? deviceName);

  Activity powerMeter(String? powerMeter);

  Activity powerMeterSerial(String? powerMeterSerial);

  Activity powerMeterBattery(String? powerMeterBattery);

  Activity crankLength(double? crankLength);

  Activity externalId(String? externalId);

  Activity fileSportIndex(int? fileSportIndex);

  Activity fileType(String? fileType);

  Activity icuAthleteId(String? icuAthleteId);

  Activity created(DateTime? created);

  Activity icuSyncDate(DateTime? icuSyncDate);

  Activity analyzed(DateTime? analyzed);

  Activity icuWPrime(int? icuWPrime);

  Activity pMax(int? pMax);

  Activity thresholdPace(double? thresholdPace);

  Activity icuHrZones(List<int>? icuHrZones);

  Activity paceZones(List<double>? paceZones);

  Activity lthr(int? lthr);

  Activity icuRestingHr(int? icuRestingHr);

  Activity icuWeight(double? icuWeight);

  Activity icuPowerZones(List<int>? icuPowerZones);

  Activity icuSweetSpotMin(int? icuSweetSpotMin);

  Activity icuSweetSpotMax(int? icuSweetSpotMax);

  Activity icuPowerSpikeThreshold(int? icuPowerSpikeThreshold);

  Activity trimp(double? trimp);

  Activity icuWarmupTime(int? icuWarmupTime);

  Activity icuCooldownTime(int? icuCooldownTime);

  Activity icuChatId(int? icuChatId);

  Activity icuIgnoreHr(bool? icuIgnoreHr);

  Activity ignoreVelocity(bool? ignoreVelocity);

  Activity ignorePace(bool? ignorePace);

  Activity ignoreParts(List<Ignore>? ignoreParts);

  Activity icuTrainingLoadData(int? icuTrainingLoadData);

  Activity intervalSummary(List<String>? intervalSummary);

  Activity skylineChartBytes(String? skylineChartBytes);

  Activity streamTypes(List<String>? streamTypes);

  Activity hasWeather(bool? hasWeather);

  Activity hasSegments(bool? hasSegments);

  Activity powerFieldNames(List<String>? powerFieldNames);

  Activity powerField(String? powerField);

  Activity icuZoneTimes(List<ZoneTime>? icuZoneTimes);

  Activity icuHrZoneTimes(List<int>? icuHrZoneTimes);

  Activity paceZoneTimes(List<int>? paceZoneTimes);

  Activity gapZoneTimes(List<int>? gapZoneTimes);

  Activity useGapZoneTimes(bool? useGapZoneTimes);

  Activity customZones(List<ZoneSet>? customZones);

  Activity tizOrder(ActivityTizOrderEnum? tizOrder);

  Activity polarizationIndex(double? polarizationIndex);

  Activity icuAchievements(List<IcuAchievement>? icuAchievements);

  Activity icuIntervalsEdited(bool? icuIntervalsEdited);

  Activity lockIntervals(bool? lockIntervals);

  Activity icuLapCount(int? icuLapCount);

  Activity icuJoulesAboveFtp(int? icuJoulesAboveFtp);

  Activity icuMaxWbalDepletion(int? icuMaxWbalDepletion);

  Activity icuHrr(HRRecovery? icuHrr);

  Activity icuSyncError(String? icuSyncError);

  Activity icuColor(String? icuColor);

  Activity icuPowerHrZ2(double? icuPowerHrZ2);

  Activity icuPowerHrZ2Mins(int? icuPowerHrZ2Mins);

  Activity icuCadenceZ2(int? icuCadenceZ2);

  Activity icuRpe(int? icuRpe);

  Activity feel(int? feel);

  Activity kgLifted(double? kgLifted);

  Activity decoupling(double? decoupling);

  Activity icuMedianTimeDelta(int? icuMedianTimeDelta);

  Activity p30sExponent(double? p30sExponent);

  Activity workoutShiftSecs(int? workoutShiftSecs);

  Activity stravaId(String? stravaId);

  Activity lengths(int? lengths);

  Activity poolLength(double? poolLength);

  Activity compliance(double? compliance);

  Activity coachTick(int? coachTick);

  Activity source_(ActivitySource_Enum? source_);

  Activity oauthClientId(int? oauthClientId);

  Activity oauthClientName(String? oauthClientName);

  Activity averageAltitude(double? averageAltitude);

  Activity minAltitude(double? minAltitude);

  Activity maxAltitude(double? maxAltitude);

  Activity powerLoad(int? powerLoad);

  Activity hrLoad(int? hrLoad);

  Activity paceLoad(int? paceLoad);

  Activity hrLoadType(ActivityHrLoadTypeEnum? hrLoadType);

  Activity paceLoadType(ActivityPaceLoadTypeEnum? paceLoadType);

  Activity tags(List<String>? tags);

  Activity attachments(List<Attachment>? attachments);

  Activity recordingStops(List<int>? recordingStops);

  Activity averageWeatherTemp(double? averageWeatherTemp);

  Activity minWeatherTemp(double? minWeatherTemp);

  Activity maxWeatherTemp(double? maxWeatherTemp);

  Activity averageFeelsLike(double? averageFeelsLike);

  Activity minFeelsLike(double? minFeelsLike);

  Activity maxFeelsLike(double? maxFeelsLike);

  Activity averageWindSpeed(double? averageWindSpeed);

  Activity averageWindGust(double? averageWindGust);

  Activity prevailingWindDeg(int? prevailingWindDeg);

  Activity headwindPercent(double? headwindPercent);

  Activity tailwindPercent(double? tailwindPercent);

  Activity averageClouds(int? averageClouds);

  Activity maxRain(double? maxRain);

  Activity maxSnow(double? maxSnow);

  Activity carbsIngested(int? carbsIngested);

  Activity routeId(int? routeId);

  Activity analysisIssues(List<ActivityAnalysisIssue>? analysisIssues);

  Activity icuIntensity(double? icuIntensity);

  Activity pace(double? pace);

  Activity icuEfficiencyFactor(double? icuEfficiencyFactor);

  Activity athleteMaxHr(int? athleteMaxHr);

  Activity group(String? group);

  Activity icuPowerHr(double? icuPowerHr);

  Activity sessionRpe(int? sessionRpe);

  Activity averageStride(double? averageStride);

  Activity icuAverageWatts(int? icuAverageWatts);

  Activity icuVariabilityIndex(double? icuVariabilityIndex);

  Activity strainScore(double? strainScore);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Activity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Activity(...).copyWith(id: 12, name: "My name")
  /// ````
  Activity call({
    String? id,
    String? startDateLocal,
    String? type,
    bool? icuIgnoreTime,
    int? icuPmCp,
    int? icuPmWPrime,
    int? icuPmPMax,
    int? icuPmFtp,
    int? icuPmFtpSecs,
    int? icuPmFtpWatts,
    bool? icuIgnorePower,
    double? icuRollingCp,
    double? icuRollingWPrime,
    double? icuRollingPMax,
    int? icuRollingFtp,
    int? icuRollingFtpDelta,
    int? icuTrainingLoad,
    double? icuAtl,
    double? icuCtl,
    double? ssPMax,
    double? ssWPrime,
    double? ssCp,
    int? pairedEventId,
    int? icuFtp,
    int? icuJoules,
    int? icuRecordingTime,
    int? elapsedTime,
    int? icuWeightedAvgWatts,
    int? carbsUsed,
    String? name,
    String? description,
    String? startDate,
    double? distance,
    double? icuDistance,
    int? movingTime,
    int? coastingTime,
    double? totalElevationGain,
    double? totalElevationLoss,
    String? timezone,
    bool? trainer,
    ActivitySubTypeEnum? subType,
    bool? commute,
    bool? race,
    double? maxSpeed,
    double? averageSpeed,
    bool? deviceWatts,
    bool? hasHeartrate,
    int? maxHeartrate,
    int? averageHeartrate,
    double? averageCadence,
    int? calories,
    double? averageTemp,
    int? minTemp,
    int? maxTemp,
    double? avgLrBalance,
    double? averageStanceTime,
    double? averageVerticalOscillation,
    double? averageVerticalRatio,
    double? averageStepLength,
    double? averageStanceTimePercent,
    double? averageStanceTimeBalance,
    double? averageVerticalSpeed,
    double? averageLegSpringStiffness,
    double? averageImpactLoadingRate,
    double? gap,
    ActivityGapModelEnum? gapModel,
    bool? useElevationCorrection,
    StravaGear? gear,
    double? perceivedExertion,
    String? deviceName,
    String? powerMeter,
    String? powerMeterSerial,
    String? powerMeterBattery,
    double? crankLength,
    String? externalId,
    int? fileSportIndex,
    String? fileType,
    String? icuAthleteId,
    DateTime? created,
    DateTime? icuSyncDate,
    DateTime? analyzed,
    int? icuWPrime,
    int? pMax,
    double? thresholdPace,
    List<int>? icuHrZones,
    List<double>? paceZones,
    int? lthr,
    int? icuRestingHr,
    double? icuWeight,
    List<int>? icuPowerZones,
    int? icuSweetSpotMin,
    int? icuSweetSpotMax,
    int? icuPowerSpikeThreshold,
    double? trimp,
    int? icuWarmupTime,
    int? icuCooldownTime,
    int? icuChatId,
    bool? icuIgnoreHr,
    bool? ignoreVelocity,
    bool? ignorePace,
    List<Ignore>? ignoreParts,
    int? icuTrainingLoadData,
    List<String>? intervalSummary,
    String? skylineChartBytes,
    List<String>? streamTypes,
    bool? hasWeather,
    bool? hasSegments,
    List<String>? powerFieldNames,
    String? powerField,
    List<ZoneTime>? icuZoneTimes,
    List<int>? icuHrZoneTimes,
    List<int>? paceZoneTimes,
    List<int>? gapZoneTimes,
    bool? useGapZoneTimes,
    List<ZoneSet>? customZones,
    ActivityTizOrderEnum? tizOrder,
    double? polarizationIndex,
    List<IcuAchievement>? icuAchievements,
    bool? icuIntervalsEdited,
    bool? lockIntervals,
    int? icuLapCount,
    int? icuJoulesAboveFtp,
    int? icuMaxWbalDepletion,
    HRRecovery? icuHrr,
    String? icuSyncError,
    String? icuColor,
    double? icuPowerHrZ2,
    int? icuPowerHrZ2Mins,
    int? icuCadenceZ2,
    int? icuRpe,
    int? feel,
    double? kgLifted,
    double? decoupling,
    int? icuMedianTimeDelta,
    double? p30sExponent,
    int? workoutShiftSecs,
    String? stravaId,
    int? lengths,
    double? poolLength,
    double? compliance,
    int? coachTick,
    ActivitySource_Enum? source_,
    int? oauthClientId,
    String? oauthClientName,
    double? averageAltitude,
    double? minAltitude,
    double? maxAltitude,
    int? powerLoad,
    int? hrLoad,
    int? paceLoad,
    ActivityHrLoadTypeEnum? hrLoadType,
    ActivityPaceLoadTypeEnum? paceLoadType,
    List<String>? tags,
    List<Attachment>? attachments,
    List<int>? recordingStops,
    double? averageWeatherTemp,
    double? minWeatherTemp,
    double? maxWeatherTemp,
    double? averageFeelsLike,
    double? minFeelsLike,
    double? maxFeelsLike,
    double? averageWindSpeed,
    double? averageWindGust,
    int? prevailingWindDeg,
    double? headwindPercent,
    double? tailwindPercent,
    int? averageClouds,
    double? maxRain,
    double? maxSnow,
    int? carbsIngested,
    int? routeId,
    List<ActivityAnalysisIssue>? analysisIssues,
    double? icuIntensity,
    double? pace,
    double? icuEfficiencyFactor,
    int? athleteMaxHr,
    String? group,
    double? icuPowerHr,
    int? sessionRpe,
    double? averageStride,
    int? icuAverageWatts,
    double? icuVariabilityIndex,
    double? strainScore,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivity.copyWith.fieldName(...)`
class _$ActivityCWProxyImpl implements _$ActivityCWProxy {
  const _$ActivityCWProxyImpl(this._value);

  final Activity _value;

  @override
  Activity id(String? id) => this(id: id);

  @override
  Activity startDateLocal(String? startDateLocal) =>
      this(startDateLocal: startDateLocal);

  @override
  Activity type(String? type) => this(type: type);

  @override
  Activity icuIgnoreTime(bool? icuIgnoreTime) =>
      this(icuIgnoreTime: icuIgnoreTime);

  @override
  Activity icuPmCp(int? icuPmCp) => this(icuPmCp: icuPmCp);

  @override
  Activity icuPmWPrime(int? icuPmWPrime) => this(icuPmWPrime: icuPmWPrime);

  @override
  Activity icuPmPMax(int? icuPmPMax) => this(icuPmPMax: icuPmPMax);

  @override
  Activity icuPmFtp(int? icuPmFtp) => this(icuPmFtp: icuPmFtp);

  @override
  Activity icuPmFtpSecs(int? icuPmFtpSecs) => this(icuPmFtpSecs: icuPmFtpSecs);

  @override
  Activity icuPmFtpWatts(int? icuPmFtpWatts) =>
      this(icuPmFtpWatts: icuPmFtpWatts);

  @override
  Activity icuIgnorePower(bool? icuIgnorePower) =>
      this(icuIgnorePower: icuIgnorePower);

  @override
  Activity icuRollingCp(double? icuRollingCp) =>
      this(icuRollingCp: icuRollingCp);

  @override
  Activity icuRollingWPrime(double? icuRollingWPrime) =>
      this(icuRollingWPrime: icuRollingWPrime);

  @override
  Activity icuRollingPMax(double? icuRollingPMax) =>
      this(icuRollingPMax: icuRollingPMax);

  @override
  Activity icuRollingFtp(int? icuRollingFtp) =>
      this(icuRollingFtp: icuRollingFtp);

  @override
  Activity icuRollingFtpDelta(int? icuRollingFtpDelta) =>
      this(icuRollingFtpDelta: icuRollingFtpDelta);

  @override
  Activity icuTrainingLoad(int? icuTrainingLoad) =>
      this(icuTrainingLoad: icuTrainingLoad);

  @override
  Activity icuAtl(double? icuAtl) => this(icuAtl: icuAtl);

  @override
  Activity icuCtl(double? icuCtl) => this(icuCtl: icuCtl);

  @override
  Activity ssPMax(double? ssPMax) => this(ssPMax: ssPMax);

  @override
  Activity ssWPrime(double? ssWPrime) => this(ssWPrime: ssWPrime);

  @override
  Activity ssCp(double? ssCp) => this(ssCp: ssCp);

  @override
  Activity pairedEventId(int? pairedEventId) =>
      this(pairedEventId: pairedEventId);

  @override
  Activity icuFtp(int? icuFtp) => this(icuFtp: icuFtp);

  @override
  Activity icuJoules(int? icuJoules) => this(icuJoules: icuJoules);

  @override
  Activity icuRecordingTime(int? icuRecordingTime) =>
      this(icuRecordingTime: icuRecordingTime);

  @override
  Activity elapsedTime(int? elapsedTime) => this(elapsedTime: elapsedTime);

  @override
  Activity icuWeightedAvgWatts(int? icuWeightedAvgWatts) =>
      this(icuWeightedAvgWatts: icuWeightedAvgWatts);

  @override
  Activity carbsUsed(int? carbsUsed) => this(carbsUsed: carbsUsed);

  @override
  Activity name(String? name) => this(name: name);

  @override
  Activity description(String? description) => this(description: description);

  @override
  Activity startDate(String? startDate) => this(startDate: startDate);

  @override
  Activity distance(double? distance) => this(distance: distance);

  @override
  Activity icuDistance(double? icuDistance) => this(icuDistance: icuDistance);

  @override
  Activity movingTime(int? movingTime) => this(movingTime: movingTime);

  @override
  Activity coastingTime(int? coastingTime) => this(coastingTime: coastingTime);

  @override
  Activity totalElevationGain(double? totalElevationGain) =>
      this(totalElevationGain: totalElevationGain);

  @override
  Activity totalElevationLoss(double? totalElevationLoss) =>
      this(totalElevationLoss: totalElevationLoss);

  @override
  Activity timezone(String? timezone) => this(timezone: timezone);

  @override
  Activity trainer(bool? trainer) => this(trainer: trainer);

  @override
  Activity subType(ActivitySubTypeEnum? subType) => this(subType: subType);

  @override
  Activity commute(bool? commute) => this(commute: commute);

  @override
  Activity race(bool? race) => this(race: race);

  @override
  Activity maxSpeed(double? maxSpeed) => this(maxSpeed: maxSpeed);

  @override
  Activity averageSpeed(double? averageSpeed) =>
      this(averageSpeed: averageSpeed);

  @override
  Activity deviceWatts(bool? deviceWatts) => this(deviceWatts: deviceWatts);

  @override
  Activity hasHeartrate(bool? hasHeartrate) => this(hasHeartrate: hasHeartrate);

  @override
  Activity maxHeartrate(int? maxHeartrate) => this(maxHeartrate: maxHeartrate);

  @override
  Activity averageHeartrate(int? averageHeartrate) =>
      this(averageHeartrate: averageHeartrate);

  @override
  Activity averageCadence(double? averageCadence) =>
      this(averageCadence: averageCadence);

  @override
  Activity calories(int? calories) => this(calories: calories);

  @override
  Activity averageTemp(double? averageTemp) => this(averageTemp: averageTemp);

  @override
  Activity minTemp(int? minTemp) => this(minTemp: minTemp);

  @override
  Activity maxTemp(int? maxTemp) => this(maxTemp: maxTemp);

  @override
  Activity avgLrBalance(double? avgLrBalance) =>
      this(avgLrBalance: avgLrBalance);

  @override
  Activity averageStanceTime(double? averageStanceTime) =>
      this(averageStanceTime: averageStanceTime);

  @override
  Activity averageVerticalOscillation(double? averageVerticalOscillation) =>
      this(averageVerticalOscillation: averageVerticalOscillation);

  @override
  Activity averageVerticalRatio(double? averageVerticalRatio) =>
      this(averageVerticalRatio: averageVerticalRatio);

  @override
  Activity averageStepLength(double? averageStepLength) =>
      this(averageStepLength: averageStepLength);

  @override
  Activity averageStanceTimePercent(double? averageStanceTimePercent) =>
      this(averageStanceTimePercent: averageStanceTimePercent);

  @override
  Activity averageStanceTimeBalance(double? averageStanceTimeBalance) =>
      this(averageStanceTimeBalance: averageStanceTimeBalance);

  @override
  Activity averageVerticalSpeed(double? averageVerticalSpeed) =>
      this(averageVerticalSpeed: averageVerticalSpeed);

  @override
  Activity averageLegSpringStiffness(double? averageLegSpringStiffness) =>
      this(averageLegSpringStiffness: averageLegSpringStiffness);

  @override
  Activity averageImpactLoadingRate(double? averageImpactLoadingRate) =>
      this(averageImpactLoadingRate: averageImpactLoadingRate);

  @override
  Activity gap(double? gap) => this(gap: gap);

  @override
  Activity gapModel(ActivityGapModelEnum? gapModel) => this(gapModel: gapModel);

  @override
  Activity useElevationCorrection(bool? useElevationCorrection) =>
      this(useElevationCorrection: useElevationCorrection);

  @override
  Activity gear(StravaGear? gear) => this(gear: gear);

  @override
  Activity perceivedExertion(double? perceivedExertion) =>
      this(perceivedExertion: perceivedExertion);

  @override
  Activity deviceName(String? deviceName) => this(deviceName: deviceName);

  @override
  Activity powerMeter(String? powerMeter) => this(powerMeter: powerMeter);

  @override
  Activity powerMeterSerial(String? powerMeterSerial) =>
      this(powerMeterSerial: powerMeterSerial);

  @override
  Activity powerMeterBattery(String? powerMeterBattery) =>
      this(powerMeterBattery: powerMeterBattery);

  @override
  Activity crankLength(double? crankLength) => this(crankLength: crankLength);

  @override
  Activity externalId(String? externalId) => this(externalId: externalId);

  @override
  Activity fileSportIndex(int? fileSportIndex) =>
      this(fileSportIndex: fileSportIndex);

  @override
  Activity fileType(String? fileType) => this(fileType: fileType);

  @override
  Activity icuAthleteId(String? icuAthleteId) =>
      this(icuAthleteId: icuAthleteId);

  @override
  Activity created(DateTime? created) => this(created: created);

  @override
  Activity icuSyncDate(DateTime? icuSyncDate) => this(icuSyncDate: icuSyncDate);

  @override
  Activity analyzed(DateTime? analyzed) => this(analyzed: analyzed);

  @override
  Activity icuWPrime(int? icuWPrime) => this(icuWPrime: icuWPrime);

  @override
  Activity pMax(int? pMax) => this(pMax: pMax);

  @override
  Activity thresholdPace(double? thresholdPace) =>
      this(thresholdPace: thresholdPace);

  @override
  Activity icuHrZones(List<int>? icuHrZones) => this(icuHrZones: icuHrZones);

  @override
  Activity paceZones(List<double>? paceZones) => this(paceZones: paceZones);

  @override
  Activity lthr(int? lthr) => this(lthr: lthr);

  @override
  Activity icuRestingHr(int? icuRestingHr) => this(icuRestingHr: icuRestingHr);

  @override
  Activity icuWeight(double? icuWeight) => this(icuWeight: icuWeight);

  @override
  Activity icuPowerZones(List<int>? icuPowerZones) =>
      this(icuPowerZones: icuPowerZones);

  @override
  Activity icuSweetSpotMin(int? icuSweetSpotMin) =>
      this(icuSweetSpotMin: icuSweetSpotMin);

  @override
  Activity icuSweetSpotMax(int? icuSweetSpotMax) =>
      this(icuSweetSpotMax: icuSweetSpotMax);

  @override
  Activity icuPowerSpikeThreshold(int? icuPowerSpikeThreshold) =>
      this(icuPowerSpikeThreshold: icuPowerSpikeThreshold);

  @override
  Activity trimp(double? trimp) => this(trimp: trimp);

  @override
  Activity icuWarmupTime(int? icuWarmupTime) =>
      this(icuWarmupTime: icuWarmupTime);

  @override
  Activity icuCooldownTime(int? icuCooldownTime) =>
      this(icuCooldownTime: icuCooldownTime);

  @override
  Activity icuChatId(int? icuChatId) => this(icuChatId: icuChatId);

  @override
  Activity icuIgnoreHr(bool? icuIgnoreHr) => this(icuIgnoreHr: icuIgnoreHr);

  @override
  Activity ignoreVelocity(bool? ignoreVelocity) =>
      this(ignoreVelocity: ignoreVelocity);

  @override
  Activity ignorePace(bool? ignorePace) => this(ignorePace: ignorePace);

  @override
  Activity ignoreParts(List<Ignore>? ignoreParts) =>
      this(ignoreParts: ignoreParts);

  @override
  Activity icuTrainingLoadData(int? icuTrainingLoadData) =>
      this(icuTrainingLoadData: icuTrainingLoadData);

  @override
  Activity intervalSummary(List<String>? intervalSummary) =>
      this(intervalSummary: intervalSummary);

  @override
  Activity skylineChartBytes(String? skylineChartBytes) =>
      this(skylineChartBytes: skylineChartBytes);

  @override
  Activity streamTypes(List<String>? streamTypes) =>
      this(streamTypes: streamTypes);

  @override
  Activity hasWeather(bool? hasWeather) => this(hasWeather: hasWeather);

  @override
  Activity hasSegments(bool? hasSegments) => this(hasSegments: hasSegments);

  @override
  Activity powerFieldNames(List<String>? powerFieldNames) =>
      this(powerFieldNames: powerFieldNames);

  @override
  Activity powerField(String? powerField) => this(powerField: powerField);

  @override
  Activity icuZoneTimes(List<ZoneTime>? icuZoneTimes) =>
      this(icuZoneTimes: icuZoneTimes);

  @override
  Activity icuHrZoneTimes(List<int>? icuHrZoneTimes) =>
      this(icuHrZoneTimes: icuHrZoneTimes);

  @override
  Activity paceZoneTimes(List<int>? paceZoneTimes) =>
      this(paceZoneTimes: paceZoneTimes);

  @override
  Activity gapZoneTimes(List<int>? gapZoneTimes) =>
      this(gapZoneTimes: gapZoneTimes);

  @override
  Activity useGapZoneTimes(bool? useGapZoneTimes) =>
      this(useGapZoneTimes: useGapZoneTimes);

  @override
  Activity customZones(List<ZoneSet>? customZones) =>
      this(customZones: customZones);

  @override
  Activity tizOrder(ActivityTizOrderEnum? tizOrder) => this(tizOrder: tizOrder);

  @override
  Activity polarizationIndex(double? polarizationIndex) =>
      this(polarizationIndex: polarizationIndex);

  @override
  Activity icuAchievements(List<IcuAchievement>? icuAchievements) =>
      this(icuAchievements: icuAchievements);

  @override
  Activity icuIntervalsEdited(bool? icuIntervalsEdited) =>
      this(icuIntervalsEdited: icuIntervalsEdited);

  @override
  Activity lockIntervals(bool? lockIntervals) =>
      this(lockIntervals: lockIntervals);

  @override
  Activity icuLapCount(int? icuLapCount) => this(icuLapCount: icuLapCount);

  @override
  Activity icuJoulesAboveFtp(int? icuJoulesAboveFtp) =>
      this(icuJoulesAboveFtp: icuJoulesAboveFtp);

  @override
  Activity icuMaxWbalDepletion(int? icuMaxWbalDepletion) =>
      this(icuMaxWbalDepletion: icuMaxWbalDepletion);

  @override
  Activity icuHrr(HRRecovery? icuHrr) => this(icuHrr: icuHrr);

  @override
  Activity icuSyncError(String? icuSyncError) =>
      this(icuSyncError: icuSyncError);

  @override
  Activity icuColor(String? icuColor) => this(icuColor: icuColor);

  @override
  Activity icuPowerHrZ2(double? icuPowerHrZ2) =>
      this(icuPowerHrZ2: icuPowerHrZ2);

  @override
  Activity icuPowerHrZ2Mins(int? icuPowerHrZ2Mins) =>
      this(icuPowerHrZ2Mins: icuPowerHrZ2Mins);

  @override
  Activity icuCadenceZ2(int? icuCadenceZ2) => this(icuCadenceZ2: icuCadenceZ2);

  @override
  Activity icuRpe(int? icuRpe) => this(icuRpe: icuRpe);

  @override
  Activity feel(int? feel) => this(feel: feel);

  @override
  Activity kgLifted(double? kgLifted) => this(kgLifted: kgLifted);

  @override
  Activity decoupling(double? decoupling) => this(decoupling: decoupling);

  @override
  Activity icuMedianTimeDelta(int? icuMedianTimeDelta) =>
      this(icuMedianTimeDelta: icuMedianTimeDelta);

  @override
  Activity p30sExponent(double? p30sExponent) =>
      this(p30sExponent: p30sExponent);

  @override
  Activity workoutShiftSecs(int? workoutShiftSecs) =>
      this(workoutShiftSecs: workoutShiftSecs);

  @override
  Activity stravaId(String? stravaId) => this(stravaId: stravaId);

  @override
  Activity lengths(int? lengths) => this(lengths: lengths);

  @override
  Activity poolLength(double? poolLength) => this(poolLength: poolLength);

  @override
  Activity compliance(double? compliance) => this(compliance: compliance);

  @override
  Activity coachTick(int? coachTick) => this(coachTick: coachTick);

  @override
  Activity source_(ActivitySource_Enum? source_) => this(source_: source_);

  @override
  Activity oauthClientId(int? oauthClientId) =>
      this(oauthClientId: oauthClientId);

  @override
  Activity oauthClientName(String? oauthClientName) =>
      this(oauthClientName: oauthClientName);

  @override
  Activity averageAltitude(double? averageAltitude) =>
      this(averageAltitude: averageAltitude);

  @override
  Activity minAltitude(double? minAltitude) => this(minAltitude: minAltitude);

  @override
  Activity maxAltitude(double? maxAltitude) => this(maxAltitude: maxAltitude);

  @override
  Activity powerLoad(int? powerLoad) => this(powerLoad: powerLoad);

  @override
  Activity hrLoad(int? hrLoad) => this(hrLoad: hrLoad);

  @override
  Activity paceLoad(int? paceLoad) => this(paceLoad: paceLoad);

  @override
  Activity hrLoadType(ActivityHrLoadTypeEnum? hrLoadType) =>
      this(hrLoadType: hrLoadType);

  @override
  Activity paceLoadType(ActivityPaceLoadTypeEnum? paceLoadType) =>
      this(paceLoadType: paceLoadType);

  @override
  Activity tags(List<String>? tags) => this(tags: tags);

  @override
  Activity attachments(List<Attachment>? attachments) =>
      this(attachments: attachments);

  @override
  Activity recordingStops(List<int>? recordingStops) =>
      this(recordingStops: recordingStops);

  @override
  Activity averageWeatherTemp(double? averageWeatherTemp) =>
      this(averageWeatherTemp: averageWeatherTemp);

  @override
  Activity minWeatherTemp(double? minWeatherTemp) =>
      this(minWeatherTemp: minWeatherTemp);

  @override
  Activity maxWeatherTemp(double? maxWeatherTemp) =>
      this(maxWeatherTemp: maxWeatherTemp);

  @override
  Activity averageFeelsLike(double? averageFeelsLike) =>
      this(averageFeelsLike: averageFeelsLike);

  @override
  Activity minFeelsLike(double? minFeelsLike) =>
      this(minFeelsLike: minFeelsLike);

  @override
  Activity maxFeelsLike(double? maxFeelsLike) =>
      this(maxFeelsLike: maxFeelsLike);

  @override
  Activity averageWindSpeed(double? averageWindSpeed) =>
      this(averageWindSpeed: averageWindSpeed);

  @override
  Activity averageWindGust(double? averageWindGust) =>
      this(averageWindGust: averageWindGust);

  @override
  Activity prevailingWindDeg(int? prevailingWindDeg) =>
      this(prevailingWindDeg: prevailingWindDeg);

  @override
  Activity headwindPercent(double? headwindPercent) =>
      this(headwindPercent: headwindPercent);

  @override
  Activity tailwindPercent(double? tailwindPercent) =>
      this(tailwindPercent: tailwindPercent);

  @override
  Activity averageClouds(int? averageClouds) =>
      this(averageClouds: averageClouds);

  @override
  Activity maxRain(double? maxRain) => this(maxRain: maxRain);

  @override
  Activity maxSnow(double? maxSnow) => this(maxSnow: maxSnow);

  @override
  Activity carbsIngested(int? carbsIngested) =>
      this(carbsIngested: carbsIngested);

  @override
  Activity routeId(int? routeId) => this(routeId: routeId);

  @override
  Activity analysisIssues(List<ActivityAnalysisIssue>? analysisIssues) =>
      this(analysisIssues: analysisIssues);

  @override
  Activity icuIntensity(double? icuIntensity) =>
      this(icuIntensity: icuIntensity);

  @override
  Activity pace(double? pace) => this(pace: pace);

  @override
  Activity icuEfficiencyFactor(double? icuEfficiencyFactor) =>
      this(icuEfficiencyFactor: icuEfficiencyFactor);

  @override
  Activity athleteMaxHr(int? athleteMaxHr) => this(athleteMaxHr: athleteMaxHr);

  @override
  Activity group(String? group) => this(group: group);

  @override
  Activity icuPowerHr(double? icuPowerHr) => this(icuPowerHr: icuPowerHr);

  @override
  Activity sessionRpe(int? sessionRpe) => this(sessionRpe: sessionRpe);

  @override
  Activity averageStride(double? averageStride) =>
      this(averageStride: averageStride);

  @override
  Activity icuAverageWatts(int? icuAverageWatts) =>
      this(icuAverageWatts: icuAverageWatts);

  @override
  Activity icuVariabilityIndex(double? icuVariabilityIndex) =>
      this(icuVariabilityIndex: icuVariabilityIndex);

  @override
  Activity strainScore(double? strainScore) => this(strainScore: strainScore);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Activity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Activity(...).copyWith(id: 12, name: "My name")
  /// ````
  Activity call({
    Object? id = const $CopyWithPlaceholder(),
    Object? startDateLocal = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? icuIgnoreTime = const $CopyWithPlaceholder(),
    Object? icuPmCp = const $CopyWithPlaceholder(),
    Object? icuPmWPrime = const $CopyWithPlaceholder(),
    Object? icuPmPMax = const $CopyWithPlaceholder(),
    Object? icuPmFtp = const $CopyWithPlaceholder(),
    Object? icuPmFtpSecs = const $CopyWithPlaceholder(),
    Object? icuPmFtpWatts = const $CopyWithPlaceholder(),
    Object? icuIgnorePower = const $CopyWithPlaceholder(),
    Object? icuRollingCp = const $CopyWithPlaceholder(),
    Object? icuRollingWPrime = const $CopyWithPlaceholder(),
    Object? icuRollingPMax = const $CopyWithPlaceholder(),
    Object? icuRollingFtp = const $CopyWithPlaceholder(),
    Object? icuRollingFtpDelta = const $CopyWithPlaceholder(),
    Object? icuTrainingLoad = const $CopyWithPlaceholder(),
    Object? icuAtl = const $CopyWithPlaceholder(),
    Object? icuCtl = const $CopyWithPlaceholder(),
    Object? ssPMax = const $CopyWithPlaceholder(),
    Object? ssWPrime = const $CopyWithPlaceholder(),
    Object? ssCp = const $CopyWithPlaceholder(),
    Object? pairedEventId = const $CopyWithPlaceholder(),
    Object? icuFtp = const $CopyWithPlaceholder(),
    Object? icuJoules = const $CopyWithPlaceholder(),
    Object? icuRecordingTime = const $CopyWithPlaceholder(),
    Object? elapsedTime = const $CopyWithPlaceholder(),
    Object? icuWeightedAvgWatts = const $CopyWithPlaceholder(),
    Object? carbsUsed = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? icuDistance = const $CopyWithPlaceholder(),
    Object? movingTime = const $CopyWithPlaceholder(),
    Object? coastingTime = const $CopyWithPlaceholder(),
    Object? totalElevationGain = const $CopyWithPlaceholder(),
    Object? totalElevationLoss = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? trainer = const $CopyWithPlaceholder(),
    Object? subType = const $CopyWithPlaceholder(),
    Object? commute = const $CopyWithPlaceholder(),
    Object? race = const $CopyWithPlaceholder(),
    Object? maxSpeed = const $CopyWithPlaceholder(),
    Object? averageSpeed = const $CopyWithPlaceholder(),
    Object? deviceWatts = const $CopyWithPlaceholder(),
    Object? hasHeartrate = const $CopyWithPlaceholder(),
    Object? maxHeartrate = const $CopyWithPlaceholder(),
    Object? averageHeartrate = const $CopyWithPlaceholder(),
    Object? averageCadence = const $CopyWithPlaceholder(),
    Object? calories = const $CopyWithPlaceholder(),
    Object? averageTemp = const $CopyWithPlaceholder(),
    Object? minTemp = const $CopyWithPlaceholder(),
    Object? maxTemp = const $CopyWithPlaceholder(),
    Object? avgLrBalance = const $CopyWithPlaceholder(),
    Object? averageStanceTime = const $CopyWithPlaceholder(),
    Object? averageVerticalOscillation = const $CopyWithPlaceholder(),
    Object? averageVerticalRatio = const $CopyWithPlaceholder(),
    Object? averageStepLength = const $CopyWithPlaceholder(),
    Object? averageStanceTimePercent = const $CopyWithPlaceholder(),
    Object? averageStanceTimeBalance = const $CopyWithPlaceholder(),
    Object? averageVerticalSpeed = const $CopyWithPlaceholder(),
    Object? averageLegSpringStiffness = const $CopyWithPlaceholder(),
    Object? averageImpactLoadingRate = const $CopyWithPlaceholder(),
    Object? gap = const $CopyWithPlaceholder(),
    Object? gapModel = const $CopyWithPlaceholder(),
    Object? useElevationCorrection = const $CopyWithPlaceholder(),
    Object? gear = const $CopyWithPlaceholder(),
    Object? perceivedExertion = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? powerMeter = const $CopyWithPlaceholder(),
    Object? powerMeterSerial = const $CopyWithPlaceholder(),
    Object? powerMeterBattery = const $CopyWithPlaceholder(),
    Object? crankLength = const $CopyWithPlaceholder(),
    Object? externalId = const $CopyWithPlaceholder(),
    Object? fileSportIndex = const $CopyWithPlaceholder(),
    Object? fileType = const $CopyWithPlaceholder(),
    Object? icuAthleteId = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? icuSyncDate = const $CopyWithPlaceholder(),
    Object? analyzed = const $CopyWithPlaceholder(),
    Object? icuWPrime = const $CopyWithPlaceholder(),
    Object? pMax = const $CopyWithPlaceholder(),
    Object? thresholdPace = const $CopyWithPlaceholder(),
    Object? icuHrZones = const $CopyWithPlaceholder(),
    Object? paceZones = const $CopyWithPlaceholder(),
    Object? lthr = const $CopyWithPlaceholder(),
    Object? icuRestingHr = const $CopyWithPlaceholder(),
    Object? icuWeight = const $CopyWithPlaceholder(),
    Object? icuPowerZones = const $CopyWithPlaceholder(),
    Object? icuSweetSpotMin = const $CopyWithPlaceholder(),
    Object? icuSweetSpotMax = const $CopyWithPlaceholder(),
    Object? icuPowerSpikeThreshold = const $CopyWithPlaceholder(),
    Object? trimp = const $CopyWithPlaceholder(),
    Object? icuWarmupTime = const $CopyWithPlaceholder(),
    Object? icuCooldownTime = const $CopyWithPlaceholder(),
    Object? icuChatId = const $CopyWithPlaceholder(),
    Object? icuIgnoreHr = const $CopyWithPlaceholder(),
    Object? ignoreVelocity = const $CopyWithPlaceholder(),
    Object? ignorePace = const $CopyWithPlaceholder(),
    Object? ignoreParts = const $CopyWithPlaceholder(),
    Object? icuTrainingLoadData = const $CopyWithPlaceholder(),
    Object? intervalSummary = const $CopyWithPlaceholder(),
    Object? skylineChartBytes = const $CopyWithPlaceholder(),
    Object? streamTypes = const $CopyWithPlaceholder(),
    Object? hasWeather = const $CopyWithPlaceholder(),
    Object? hasSegments = const $CopyWithPlaceholder(),
    Object? powerFieldNames = const $CopyWithPlaceholder(),
    Object? powerField = const $CopyWithPlaceholder(),
    Object? icuZoneTimes = const $CopyWithPlaceholder(),
    Object? icuHrZoneTimes = const $CopyWithPlaceholder(),
    Object? paceZoneTimes = const $CopyWithPlaceholder(),
    Object? gapZoneTimes = const $CopyWithPlaceholder(),
    Object? useGapZoneTimes = const $CopyWithPlaceholder(),
    Object? customZones = const $CopyWithPlaceholder(),
    Object? tizOrder = const $CopyWithPlaceholder(),
    Object? polarizationIndex = const $CopyWithPlaceholder(),
    Object? icuAchievements = const $CopyWithPlaceholder(),
    Object? icuIntervalsEdited = const $CopyWithPlaceholder(),
    Object? lockIntervals = const $CopyWithPlaceholder(),
    Object? icuLapCount = const $CopyWithPlaceholder(),
    Object? icuJoulesAboveFtp = const $CopyWithPlaceholder(),
    Object? icuMaxWbalDepletion = const $CopyWithPlaceholder(),
    Object? icuHrr = const $CopyWithPlaceholder(),
    Object? icuSyncError = const $CopyWithPlaceholder(),
    Object? icuColor = const $CopyWithPlaceholder(),
    Object? icuPowerHrZ2 = const $CopyWithPlaceholder(),
    Object? icuPowerHrZ2Mins = const $CopyWithPlaceholder(),
    Object? icuCadenceZ2 = const $CopyWithPlaceholder(),
    Object? icuRpe = const $CopyWithPlaceholder(),
    Object? feel = const $CopyWithPlaceholder(),
    Object? kgLifted = const $CopyWithPlaceholder(),
    Object? decoupling = const $CopyWithPlaceholder(),
    Object? icuMedianTimeDelta = const $CopyWithPlaceholder(),
    Object? p30sExponent = const $CopyWithPlaceholder(),
    Object? workoutShiftSecs = const $CopyWithPlaceholder(),
    Object? stravaId = const $CopyWithPlaceholder(),
    Object? lengths = const $CopyWithPlaceholder(),
    Object? poolLength = const $CopyWithPlaceholder(),
    Object? compliance = const $CopyWithPlaceholder(),
    Object? coachTick = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? oauthClientId = const $CopyWithPlaceholder(),
    Object? oauthClientName = const $CopyWithPlaceholder(),
    Object? averageAltitude = const $CopyWithPlaceholder(),
    Object? minAltitude = const $CopyWithPlaceholder(),
    Object? maxAltitude = const $CopyWithPlaceholder(),
    Object? powerLoad = const $CopyWithPlaceholder(),
    Object? hrLoad = const $CopyWithPlaceholder(),
    Object? paceLoad = const $CopyWithPlaceholder(),
    Object? hrLoadType = const $CopyWithPlaceholder(),
    Object? paceLoadType = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? recordingStops = const $CopyWithPlaceholder(),
    Object? averageWeatherTemp = const $CopyWithPlaceholder(),
    Object? minWeatherTemp = const $CopyWithPlaceholder(),
    Object? maxWeatherTemp = const $CopyWithPlaceholder(),
    Object? averageFeelsLike = const $CopyWithPlaceholder(),
    Object? minFeelsLike = const $CopyWithPlaceholder(),
    Object? maxFeelsLike = const $CopyWithPlaceholder(),
    Object? averageWindSpeed = const $CopyWithPlaceholder(),
    Object? averageWindGust = const $CopyWithPlaceholder(),
    Object? prevailingWindDeg = const $CopyWithPlaceholder(),
    Object? headwindPercent = const $CopyWithPlaceholder(),
    Object? tailwindPercent = const $CopyWithPlaceholder(),
    Object? averageClouds = const $CopyWithPlaceholder(),
    Object? maxRain = const $CopyWithPlaceholder(),
    Object? maxSnow = const $CopyWithPlaceholder(),
    Object? carbsIngested = const $CopyWithPlaceholder(),
    Object? routeId = const $CopyWithPlaceholder(),
    Object? analysisIssues = const $CopyWithPlaceholder(),
    Object? icuIntensity = const $CopyWithPlaceholder(),
    Object? pace = const $CopyWithPlaceholder(),
    Object? icuEfficiencyFactor = const $CopyWithPlaceholder(),
    Object? athleteMaxHr = const $CopyWithPlaceholder(),
    Object? group = const $CopyWithPlaceholder(),
    Object? icuPowerHr = const $CopyWithPlaceholder(),
    Object? sessionRpe = const $CopyWithPlaceholder(),
    Object? averageStride = const $CopyWithPlaceholder(),
    Object? icuAverageWatts = const $CopyWithPlaceholder(),
    Object? icuVariabilityIndex = const $CopyWithPlaceholder(),
    Object? strainScore = const $CopyWithPlaceholder(),
  }) {
    return Activity(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      startDateLocal: startDateLocal == const $CopyWithPlaceholder()
          ? _value.startDateLocal
          // ignore: cast_nullable_to_non_nullable
          : startDateLocal as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String?,
      icuIgnoreTime: icuIgnoreTime == const $CopyWithPlaceholder()
          ? _value.icuIgnoreTime
          // ignore: cast_nullable_to_non_nullable
          : icuIgnoreTime as bool?,
      icuPmCp: icuPmCp == const $CopyWithPlaceholder()
          ? _value.icuPmCp
          // ignore: cast_nullable_to_non_nullable
          : icuPmCp as int?,
      icuPmWPrime: icuPmWPrime == const $CopyWithPlaceholder()
          ? _value.icuPmWPrime
          // ignore: cast_nullable_to_non_nullable
          : icuPmWPrime as int?,
      icuPmPMax: icuPmPMax == const $CopyWithPlaceholder()
          ? _value.icuPmPMax
          // ignore: cast_nullable_to_non_nullable
          : icuPmPMax as int?,
      icuPmFtp: icuPmFtp == const $CopyWithPlaceholder()
          ? _value.icuPmFtp
          // ignore: cast_nullable_to_non_nullable
          : icuPmFtp as int?,
      icuPmFtpSecs: icuPmFtpSecs == const $CopyWithPlaceholder()
          ? _value.icuPmFtpSecs
          // ignore: cast_nullable_to_non_nullable
          : icuPmFtpSecs as int?,
      icuPmFtpWatts: icuPmFtpWatts == const $CopyWithPlaceholder()
          ? _value.icuPmFtpWatts
          // ignore: cast_nullable_to_non_nullable
          : icuPmFtpWatts as int?,
      icuIgnorePower: icuIgnorePower == const $CopyWithPlaceholder()
          ? _value.icuIgnorePower
          // ignore: cast_nullable_to_non_nullable
          : icuIgnorePower as bool?,
      icuRollingCp: icuRollingCp == const $CopyWithPlaceholder()
          ? _value.icuRollingCp
          // ignore: cast_nullable_to_non_nullable
          : icuRollingCp as double?,
      icuRollingWPrime: icuRollingWPrime == const $CopyWithPlaceholder()
          ? _value.icuRollingWPrime
          // ignore: cast_nullable_to_non_nullable
          : icuRollingWPrime as double?,
      icuRollingPMax: icuRollingPMax == const $CopyWithPlaceholder()
          ? _value.icuRollingPMax
          // ignore: cast_nullable_to_non_nullable
          : icuRollingPMax as double?,
      icuRollingFtp: icuRollingFtp == const $CopyWithPlaceholder()
          ? _value.icuRollingFtp
          // ignore: cast_nullable_to_non_nullable
          : icuRollingFtp as int?,
      icuRollingFtpDelta: icuRollingFtpDelta == const $CopyWithPlaceholder()
          ? _value.icuRollingFtpDelta
          // ignore: cast_nullable_to_non_nullable
          : icuRollingFtpDelta as int?,
      icuTrainingLoad: icuTrainingLoad == const $CopyWithPlaceholder()
          ? _value.icuTrainingLoad
          // ignore: cast_nullable_to_non_nullable
          : icuTrainingLoad as int?,
      icuAtl: icuAtl == const $CopyWithPlaceholder()
          ? _value.icuAtl
          // ignore: cast_nullable_to_non_nullable
          : icuAtl as double?,
      icuCtl: icuCtl == const $CopyWithPlaceholder()
          ? _value.icuCtl
          // ignore: cast_nullable_to_non_nullable
          : icuCtl as double?,
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
      pairedEventId: pairedEventId == const $CopyWithPlaceholder()
          ? _value.pairedEventId
          // ignore: cast_nullable_to_non_nullable
          : pairedEventId as int?,
      icuFtp: icuFtp == const $CopyWithPlaceholder()
          ? _value.icuFtp
          // ignore: cast_nullable_to_non_nullable
          : icuFtp as int?,
      icuJoules: icuJoules == const $CopyWithPlaceholder()
          ? _value.icuJoules
          // ignore: cast_nullable_to_non_nullable
          : icuJoules as int?,
      icuRecordingTime: icuRecordingTime == const $CopyWithPlaceholder()
          ? _value.icuRecordingTime
          // ignore: cast_nullable_to_non_nullable
          : icuRecordingTime as int?,
      elapsedTime: elapsedTime == const $CopyWithPlaceholder()
          ? _value.elapsedTime
          // ignore: cast_nullable_to_non_nullable
          : elapsedTime as int?,
      icuWeightedAvgWatts: icuWeightedAvgWatts == const $CopyWithPlaceholder()
          ? _value.icuWeightedAvgWatts
          // ignore: cast_nullable_to_non_nullable
          : icuWeightedAvgWatts as int?,
      carbsUsed: carbsUsed == const $CopyWithPlaceholder()
          ? _value.carbsUsed
          // ignore: cast_nullable_to_non_nullable
          : carbsUsed as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      description: description == const $CopyWithPlaceholder()
          ? _value.description
          // ignore: cast_nullable_to_non_nullable
          : description as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as String?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      icuDistance: icuDistance == const $CopyWithPlaceholder()
          ? _value.icuDistance
          // ignore: cast_nullable_to_non_nullable
          : icuDistance as double?,
      movingTime: movingTime == const $CopyWithPlaceholder()
          ? _value.movingTime
          // ignore: cast_nullable_to_non_nullable
          : movingTime as int?,
      coastingTime: coastingTime == const $CopyWithPlaceholder()
          ? _value.coastingTime
          // ignore: cast_nullable_to_non_nullable
          : coastingTime as int?,
      totalElevationGain: totalElevationGain == const $CopyWithPlaceholder()
          ? _value.totalElevationGain
          // ignore: cast_nullable_to_non_nullable
          : totalElevationGain as double?,
      totalElevationLoss: totalElevationLoss == const $CopyWithPlaceholder()
          ? _value.totalElevationLoss
          // ignore: cast_nullable_to_non_nullable
          : totalElevationLoss as double?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      trainer: trainer == const $CopyWithPlaceholder()
          ? _value.trainer
          // ignore: cast_nullable_to_non_nullable
          : trainer as bool?,
      subType: subType == const $CopyWithPlaceholder()
          ? _value.subType
          // ignore: cast_nullable_to_non_nullable
          : subType as ActivitySubTypeEnum?,
      commute: commute == const $CopyWithPlaceholder()
          ? _value.commute
          // ignore: cast_nullable_to_non_nullable
          : commute as bool?,
      race: race == const $CopyWithPlaceholder()
          ? _value.race
          // ignore: cast_nullable_to_non_nullable
          : race as bool?,
      maxSpeed: maxSpeed == const $CopyWithPlaceholder()
          ? _value.maxSpeed
          // ignore: cast_nullable_to_non_nullable
          : maxSpeed as double?,
      averageSpeed: averageSpeed == const $CopyWithPlaceholder()
          ? _value.averageSpeed
          // ignore: cast_nullable_to_non_nullable
          : averageSpeed as double?,
      deviceWatts: deviceWatts == const $CopyWithPlaceholder()
          ? _value.deviceWatts
          // ignore: cast_nullable_to_non_nullable
          : deviceWatts as bool?,
      hasHeartrate: hasHeartrate == const $CopyWithPlaceholder()
          ? _value.hasHeartrate
          // ignore: cast_nullable_to_non_nullable
          : hasHeartrate as bool?,
      maxHeartrate: maxHeartrate == const $CopyWithPlaceholder()
          ? _value.maxHeartrate
          // ignore: cast_nullable_to_non_nullable
          : maxHeartrate as int?,
      averageHeartrate: averageHeartrate == const $CopyWithPlaceholder()
          ? _value.averageHeartrate
          // ignore: cast_nullable_to_non_nullable
          : averageHeartrate as int?,
      averageCadence: averageCadence == const $CopyWithPlaceholder()
          ? _value.averageCadence
          // ignore: cast_nullable_to_non_nullable
          : averageCadence as double?,
      calories: calories == const $CopyWithPlaceholder()
          ? _value.calories
          // ignore: cast_nullable_to_non_nullable
          : calories as int?,
      averageTemp: averageTemp == const $CopyWithPlaceholder()
          ? _value.averageTemp
          // ignore: cast_nullable_to_non_nullable
          : averageTemp as double?,
      minTemp: minTemp == const $CopyWithPlaceholder()
          ? _value.minTemp
          // ignore: cast_nullable_to_non_nullable
          : minTemp as int?,
      maxTemp: maxTemp == const $CopyWithPlaceholder()
          ? _value.maxTemp
          // ignore: cast_nullable_to_non_nullable
          : maxTemp as int?,
      avgLrBalance: avgLrBalance == const $CopyWithPlaceholder()
          ? _value.avgLrBalance
          // ignore: cast_nullable_to_non_nullable
          : avgLrBalance as double?,
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
      gap: gap == const $CopyWithPlaceholder()
          ? _value.gap
          // ignore: cast_nullable_to_non_nullable
          : gap as double?,
      gapModel: gapModel == const $CopyWithPlaceholder()
          ? _value.gapModel
          // ignore: cast_nullable_to_non_nullable
          : gapModel as ActivityGapModelEnum?,
      useElevationCorrection:
          useElevationCorrection == const $CopyWithPlaceholder()
          ? _value.useElevationCorrection
          // ignore: cast_nullable_to_non_nullable
          : useElevationCorrection as bool?,
      gear: gear == const $CopyWithPlaceholder()
          ? _value.gear
          // ignore: cast_nullable_to_non_nullable
          : gear as StravaGear?,
      perceivedExertion: perceivedExertion == const $CopyWithPlaceholder()
          ? _value.perceivedExertion
          // ignore: cast_nullable_to_non_nullable
          : perceivedExertion as double?,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String?,
      powerMeter: powerMeter == const $CopyWithPlaceholder()
          ? _value.powerMeter
          // ignore: cast_nullable_to_non_nullable
          : powerMeter as String?,
      powerMeterSerial: powerMeterSerial == const $CopyWithPlaceholder()
          ? _value.powerMeterSerial
          // ignore: cast_nullable_to_non_nullable
          : powerMeterSerial as String?,
      powerMeterBattery: powerMeterBattery == const $CopyWithPlaceholder()
          ? _value.powerMeterBattery
          // ignore: cast_nullable_to_non_nullable
          : powerMeterBattery as String?,
      crankLength: crankLength == const $CopyWithPlaceholder()
          ? _value.crankLength
          // ignore: cast_nullable_to_non_nullable
          : crankLength as double?,
      externalId: externalId == const $CopyWithPlaceholder()
          ? _value.externalId
          // ignore: cast_nullable_to_non_nullable
          : externalId as String?,
      fileSportIndex: fileSportIndex == const $CopyWithPlaceholder()
          ? _value.fileSportIndex
          // ignore: cast_nullable_to_non_nullable
          : fileSportIndex as int?,
      fileType: fileType == const $CopyWithPlaceholder()
          ? _value.fileType
          // ignore: cast_nullable_to_non_nullable
          : fileType as String?,
      icuAthleteId: icuAthleteId == const $CopyWithPlaceholder()
          ? _value.icuAthleteId
          // ignore: cast_nullable_to_non_nullable
          : icuAthleteId as String?,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as DateTime?,
      icuSyncDate: icuSyncDate == const $CopyWithPlaceholder()
          ? _value.icuSyncDate
          // ignore: cast_nullable_to_non_nullable
          : icuSyncDate as DateTime?,
      analyzed: analyzed == const $CopyWithPlaceholder()
          ? _value.analyzed
          // ignore: cast_nullable_to_non_nullable
          : analyzed as DateTime?,
      icuWPrime: icuWPrime == const $CopyWithPlaceholder()
          ? _value.icuWPrime
          // ignore: cast_nullable_to_non_nullable
          : icuWPrime as int?,
      pMax: pMax == const $CopyWithPlaceholder()
          ? _value.pMax
          // ignore: cast_nullable_to_non_nullable
          : pMax as int?,
      thresholdPace: thresholdPace == const $CopyWithPlaceholder()
          ? _value.thresholdPace
          // ignore: cast_nullable_to_non_nullable
          : thresholdPace as double?,
      icuHrZones: icuHrZones == const $CopyWithPlaceholder()
          ? _value.icuHrZones
          // ignore: cast_nullable_to_non_nullable
          : icuHrZones as List<int>?,
      paceZones: paceZones == const $CopyWithPlaceholder()
          ? _value.paceZones
          // ignore: cast_nullable_to_non_nullable
          : paceZones as List<double>?,
      lthr: lthr == const $CopyWithPlaceholder()
          ? _value.lthr
          // ignore: cast_nullable_to_non_nullable
          : lthr as int?,
      icuRestingHr: icuRestingHr == const $CopyWithPlaceholder()
          ? _value.icuRestingHr
          // ignore: cast_nullable_to_non_nullable
          : icuRestingHr as int?,
      icuWeight: icuWeight == const $CopyWithPlaceholder()
          ? _value.icuWeight
          // ignore: cast_nullable_to_non_nullable
          : icuWeight as double?,
      icuPowerZones: icuPowerZones == const $CopyWithPlaceholder()
          ? _value.icuPowerZones
          // ignore: cast_nullable_to_non_nullable
          : icuPowerZones as List<int>?,
      icuSweetSpotMin: icuSweetSpotMin == const $CopyWithPlaceholder()
          ? _value.icuSweetSpotMin
          // ignore: cast_nullable_to_non_nullable
          : icuSweetSpotMin as int?,
      icuSweetSpotMax: icuSweetSpotMax == const $CopyWithPlaceholder()
          ? _value.icuSweetSpotMax
          // ignore: cast_nullable_to_non_nullable
          : icuSweetSpotMax as int?,
      icuPowerSpikeThreshold:
          icuPowerSpikeThreshold == const $CopyWithPlaceholder()
          ? _value.icuPowerSpikeThreshold
          // ignore: cast_nullable_to_non_nullable
          : icuPowerSpikeThreshold as int?,
      trimp: trimp == const $CopyWithPlaceholder()
          ? _value.trimp
          // ignore: cast_nullable_to_non_nullable
          : trimp as double?,
      icuWarmupTime: icuWarmupTime == const $CopyWithPlaceholder()
          ? _value.icuWarmupTime
          // ignore: cast_nullable_to_non_nullable
          : icuWarmupTime as int?,
      icuCooldownTime: icuCooldownTime == const $CopyWithPlaceholder()
          ? _value.icuCooldownTime
          // ignore: cast_nullable_to_non_nullable
          : icuCooldownTime as int?,
      icuChatId: icuChatId == const $CopyWithPlaceholder()
          ? _value.icuChatId
          // ignore: cast_nullable_to_non_nullable
          : icuChatId as int?,
      icuIgnoreHr: icuIgnoreHr == const $CopyWithPlaceholder()
          ? _value.icuIgnoreHr
          // ignore: cast_nullable_to_non_nullable
          : icuIgnoreHr as bool?,
      ignoreVelocity: ignoreVelocity == const $CopyWithPlaceholder()
          ? _value.ignoreVelocity
          // ignore: cast_nullable_to_non_nullable
          : ignoreVelocity as bool?,
      ignorePace: ignorePace == const $CopyWithPlaceholder()
          ? _value.ignorePace
          // ignore: cast_nullable_to_non_nullable
          : ignorePace as bool?,
      ignoreParts: ignoreParts == const $CopyWithPlaceholder()
          ? _value.ignoreParts
          // ignore: cast_nullable_to_non_nullable
          : ignoreParts as List<Ignore>?,
      icuTrainingLoadData: icuTrainingLoadData == const $CopyWithPlaceholder()
          ? _value.icuTrainingLoadData
          // ignore: cast_nullable_to_non_nullable
          : icuTrainingLoadData as int?,
      intervalSummary: intervalSummary == const $CopyWithPlaceholder()
          ? _value.intervalSummary
          // ignore: cast_nullable_to_non_nullable
          : intervalSummary as List<String>?,
      skylineChartBytes: skylineChartBytes == const $CopyWithPlaceholder()
          ? _value.skylineChartBytes
          // ignore: cast_nullable_to_non_nullable
          : skylineChartBytes as String?,
      streamTypes: streamTypes == const $CopyWithPlaceholder()
          ? _value.streamTypes
          // ignore: cast_nullable_to_non_nullable
          : streamTypes as List<String>?,
      hasWeather: hasWeather == const $CopyWithPlaceholder()
          ? _value.hasWeather
          // ignore: cast_nullable_to_non_nullable
          : hasWeather as bool?,
      hasSegments: hasSegments == const $CopyWithPlaceholder()
          ? _value.hasSegments
          // ignore: cast_nullable_to_non_nullable
          : hasSegments as bool?,
      powerFieldNames: powerFieldNames == const $CopyWithPlaceholder()
          ? _value.powerFieldNames
          // ignore: cast_nullable_to_non_nullable
          : powerFieldNames as List<String>?,
      powerField: powerField == const $CopyWithPlaceholder()
          ? _value.powerField
          // ignore: cast_nullable_to_non_nullable
          : powerField as String?,
      icuZoneTimes: icuZoneTimes == const $CopyWithPlaceholder()
          ? _value.icuZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : icuZoneTimes as List<ZoneTime>?,
      icuHrZoneTimes: icuHrZoneTimes == const $CopyWithPlaceholder()
          ? _value.icuHrZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : icuHrZoneTimes as List<int>?,
      paceZoneTimes: paceZoneTimes == const $CopyWithPlaceholder()
          ? _value.paceZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : paceZoneTimes as List<int>?,
      gapZoneTimes: gapZoneTimes == const $CopyWithPlaceholder()
          ? _value.gapZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : gapZoneTimes as List<int>?,
      useGapZoneTimes: useGapZoneTimes == const $CopyWithPlaceholder()
          ? _value.useGapZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : useGapZoneTimes as bool?,
      customZones: customZones == const $CopyWithPlaceholder()
          ? _value.customZones
          // ignore: cast_nullable_to_non_nullable
          : customZones as List<ZoneSet>?,
      tizOrder: tizOrder == const $CopyWithPlaceholder()
          ? _value.tizOrder
          // ignore: cast_nullable_to_non_nullable
          : tizOrder as ActivityTizOrderEnum?,
      polarizationIndex: polarizationIndex == const $CopyWithPlaceholder()
          ? _value.polarizationIndex
          // ignore: cast_nullable_to_non_nullable
          : polarizationIndex as double?,
      icuAchievements: icuAchievements == const $CopyWithPlaceholder()
          ? _value.icuAchievements
          // ignore: cast_nullable_to_non_nullable
          : icuAchievements as List<IcuAchievement>?,
      icuIntervalsEdited: icuIntervalsEdited == const $CopyWithPlaceholder()
          ? _value.icuIntervalsEdited
          // ignore: cast_nullable_to_non_nullable
          : icuIntervalsEdited as bool?,
      lockIntervals: lockIntervals == const $CopyWithPlaceholder()
          ? _value.lockIntervals
          // ignore: cast_nullable_to_non_nullable
          : lockIntervals as bool?,
      icuLapCount: icuLapCount == const $CopyWithPlaceholder()
          ? _value.icuLapCount
          // ignore: cast_nullable_to_non_nullable
          : icuLapCount as int?,
      icuJoulesAboveFtp: icuJoulesAboveFtp == const $CopyWithPlaceholder()
          ? _value.icuJoulesAboveFtp
          // ignore: cast_nullable_to_non_nullable
          : icuJoulesAboveFtp as int?,
      icuMaxWbalDepletion: icuMaxWbalDepletion == const $CopyWithPlaceholder()
          ? _value.icuMaxWbalDepletion
          // ignore: cast_nullable_to_non_nullable
          : icuMaxWbalDepletion as int?,
      icuHrr: icuHrr == const $CopyWithPlaceholder()
          ? _value.icuHrr
          // ignore: cast_nullable_to_non_nullable
          : icuHrr as HRRecovery?,
      icuSyncError: icuSyncError == const $CopyWithPlaceholder()
          ? _value.icuSyncError
          // ignore: cast_nullable_to_non_nullable
          : icuSyncError as String?,
      icuColor: icuColor == const $CopyWithPlaceholder()
          ? _value.icuColor
          // ignore: cast_nullable_to_non_nullable
          : icuColor as String?,
      icuPowerHrZ2: icuPowerHrZ2 == const $CopyWithPlaceholder()
          ? _value.icuPowerHrZ2
          // ignore: cast_nullable_to_non_nullable
          : icuPowerHrZ2 as double?,
      icuPowerHrZ2Mins: icuPowerHrZ2Mins == const $CopyWithPlaceholder()
          ? _value.icuPowerHrZ2Mins
          // ignore: cast_nullable_to_non_nullable
          : icuPowerHrZ2Mins as int?,
      icuCadenceZ2: icuCadenceZ2 == const $CopyWithPlaceholder()
          ? _value.icuCadenceZ2
          // ignore: cast_nullable_to_non_nullable
          : icuCadenceZ2 as int?,
      icuRpe: icuRpe == const $CopyWithPlaceholder()
          ? _value.icuRpe
          // ignore: cast_nullable_to_non_nullable
          : icuRpe as int?,
      feel: feel == const $CopyWithPlaceholder()
          ? _value.feel
          // ignore: cast_nullable_to_non_nullable
          : feel as int?,
      kgLifted: kgLifted == const $CopyWithPlaceholder()
          ? _value.kgLifted
          // ignore: cast_nullable_to_non_nullable
          : kgLifted as double?,
      decoupling: decoupling == const $CopyWithPlaceholder()
          ? _value.decoupling
          // ignore: cast_nullable_to_non_nullable
          : decoupling as double?,
      icuMedianTimeDelta: icuMedianTimeDelta == const $CopyWithPlaceholder()
          ? _value.icuMedianTimeDelta
          // ignore: cast_nullable_to_non_nullable
          : icuMedianTimeDelta as int?,
      p30sExponent: p30sExponent == const $CopyWithPlaceholder()
          ? _value.p30sExponent
          // ignore: cast_nullable_to_non_nullable
          : p30sExponent as double?,
      workoutShiftSecs: workoutShiftSecs == const $CopyWithPlaceholder()
          ? _value.workoutShiftSecs
          // ignore: cast_nullable_to_non_nullable
          : workoutShiftSecs as int?,
      stravaId: stravaId == const $CopyWithPlaceholder()
          ? _value.stravaId
          // ignore: cast_nullable_to_non_nullable
          : stravaId as String?,
      lengths: lengths == const $CopyWithPlaceholder()
          ? _value.lengths
          // ignore: cast_nullable_to_non_nullable
          : lengths as int?,
      poolLength: poolLength == const $CopyWithPlaceholder()
          ? _value.poolLength
          // ignore: cast_nullable_to_non_nullable
          : poolLength as double?,
      compliance: compliance == const $CopyWithPlaceholder()
          ? _value.compliance
          // ignore: cast_nullable_to_non_nullable
          : compliance as double?,
      coachTick: coachTick == const $CopyWithPlaceholder()
          ? _value.coachTick
          // ignore: cast_nullable_to_non_nullable
          : coachTick as int?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as ActivitySource_Enum?,
      oauthClientId: oauthClientId == const $CopyWithPlaceholder()
          ? _value.oauthClientId
          // ignore: cast_nullable_to_non_nullable
          : oauthClientId as int?,
      oauthClientName: oauthClientName == const $CopyWithPlaceholder()
          ? _value.oauthClientName
          // ignore: cast_nullable_to_non_nullable
          : oauthClientName as String?,
      averageAltitude: averageAltitude == const $CopyWithPlaceholder()
          ? _value.averageAltitude
          // ignore: cast_nullable_to_non_nullable
          : averageAltitude as double?,
      minAltitude: minAltitude == const $CopyWithPlaceholder()
          ? _value.minAltitude
          // ignore: cast_nullable_to_non_nullable
          : minAltitude as double?,
      maxAltitude: maxAltitude == const $CopyWithPlaceholder()
          ? _value.maxAltitude
          // ignore: cast_nullable_to_non_nullable
          : maxAltitude as double?,
      powerLoad: powerLoad == const $CopyWithPlaceholder()
          ? _value.powerLoad
          // ignore: cast_nullable_to_non_nullable
          : powerLoad as int?,
      hrLoad: hrLoad == const $CopyWithPlaceholder()
          ? _value.hrLoad
          // ignore: cast_nullable_to_non_nullable
          : hrLoad as int?,
      paceLoad: paceLoad == const $CopyWithPlaceholder()
          ? _value.paceLoad
          // ignore: cast_nullable_to_non_nullable
          : paceLoad as int?,
      hrLoadType: hrLoadType == const $CopyWithPlaceholder()
          ? _value.hrLoadType
          // ignore: cast_nullable_to_non_nullable
          : hrLoadType as ActivityHrLoadTypeEnum?,
      paceLoadType: paceLoadType == const $CopyWithPlaceholder()
          ? _value.paceLoadType
          // ignore: cast_nullable_to_non_nullable
          : paceLoadType as ActivityPaceLoadTypeEnum?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<Attachment>?,
      recordingStops: recordingStops == const $CopyWithPlaceholder()
          ? _value.recordingStops
          // ignore: cast_nullable_to_non_nullable
          : recordingStops as List<int>?,
      averageWeatherTemp: averageWeatherTemp == const $CopyWithPlaceholder()
          ? _value.averageWeatherTemp
          // ignore: cast_nullable_to_non_nullable
          : averageWeatherTemp as double?,
      minWeatherTemp: minWeatherTemp == const $CopyWithPlaceholder()
          ? _value.minWeatherTemp
          // ignore: cast_nullable_to_non_nullable
          : minWeatherTemp as double?,
      maxWeatherTemp: maxWeatherTemp == const $CopyWithPlaceholder()
          ? _value.maxWeatherTemp
          // ignore: cast_nullable_to_non_nullable
          : maxWeatherTemp as double?,
      averageFeelsLike: averageFeelsLike == const $CopyWithPlaceholder()
          ? _value.averageFeelsLike
          // ignore: cast_nullable_to_non_nullable
          : averageFeelsLike as double?,
      minFeelsLike: minFeelsLike == const $CopyWithPlaceholder()
          ? _value.minFeelsLike
          // ignore: cast_nullable_to_non_nullable
          : minFeelsLike as double?,
      maxFeelsLike: maxFeelsLike == const $CopyWithPlaceholder()
          ? _value.maxFeelsLike
          // ignore: cast_nullable_to_non_nullable
          : maxFeelsLike as double?,
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
      headwindPercent: headwindPercent == const $CopyWithPlaceholder()
          ? _value.headwindPercent
          // ignore: cast_nullable_to_non_nullable
          : headwindPercent as double?,
      tailwindPercent: tailwindPercent == const $CopyWithPlaceholder()
          ? _value.tailwindPercent
          // ignore: cast_nullable_to_non_nullable
          : tailwindPercent as double?,
      averageClouds: averageClouds == const $CopyWithPlaceholder()
          ? _value.averageClouds
          // ignore: cast_nullable_to_non_nullable
          : averageClouds as int?,
      maxRain: maxRain == const $CopyWithPlaceholder()
          ? _value.maxRain
          // ignore: cast_nullable_to_non_nullable
          : maxRain as double?,
      maxSnow: maxSnow == const $CopyWithPlaceholder()
          ? _value.maxSnow
          // ignore: cast_nullable_to_non_nullable
          : maxSnow as double?,
      carbsIngested: carbsIngested == const $CopyWithPlaceholder()
          ? _value.carbsIngested
          // ignore: cast_nullable_to_non_nullable
          : carbsIngested as int?,
      routeId: routeId == const $CopyWithPlaceholder()
          ? _value.routeId
          // ignore: cast_nullable_to_non_nullable
          : routeId as int?,
      analysisIssues: analysisIssues == const $CopyWithPlaceholder()
          ? _value.analysisIssues
          // ignore: cast_nullable_to_non_nullable
          : analysisIssues as List<ActivityAnalysisIssue>?,
      icuIntensity: icuIntensity == const $CopyWithPlaceholder()
          ? _value.icuIntensity
          // ignore: cast_nullable_to_non_nullable
          : icuIntensity as double?,
      pace: pace == const $CopyWithPlaceholder()
          ? _value.pace
          // ignore: cast_nullable_to_non_nullable
          : pace as double?,
      icuEfficiencyFactor: icuEfficiencyFactor == const $CopyWithPlaceholder()
          ? _value.icuEfficiencyFactor
          // ignore: cast_nullable_to_non_nullable
          : icuEfficiencyFactor as double?,
      athleteMaxHr: athleteMaxHr == const $CopyWithPlaceholder()
          ? _value.athleteMaxHr
          // ignore: cast_nullable_to_non_nullable
          : athleteMaxHr as int?,
      group: group == const $CopyWithPlaceholder()
          ? _value.group
          // ignore: cast_nullable_to_non_nullable
          : group as String?,
      icuPowerHr: icuPowerHr == const $CopyWithPlaceholder()
          ? _value.icuPowerHr
          // ignore: cast_nullable_to_non_nullable
          : icuPowerHr as double?,
      sessionRpe: sessionRpe == const $CopyWithPlaceholder()
          ? _value.sessionRpe
          // ignore: cast_nullable_to_non_nullable
          : sessionRpe as int?,
      averageStride: averageStride == const $CopyWithPlaceholder()
          ? _value.averageStride
          // ignore: cast_nullable_to_non_nullable
          : averageStride as double?,
      icuAverageWatts: icuAverageWatts == const $CopyWithPlaceholder()
          ? _value.icuAverageWatts
          // ignore: cast_nullable_to_non_nullable
          : icuAverageWatts as int?,
      icuVariabilityIndex: icuVariabilityIndex == const $CopyWithPlaceholder()
          ? _value.icuVariabilityIndex
          // ignore: cast_nullable_to_non_nullable
          : icuVariabilityIndex as double?,
      strainScore: strainScore == const $CopyWithPlaceholder()
          ? _value.strainScore
          // ignore: cast_nullable_to_non_nullable
          : strainScore as double?,
    );
  }
}

extension $ActivityCopyWith on Activity {
  /// Returns a callable class that can be used as follows: `instanceOfActivity.copyWith(...)` or like so:`instanceOfActivity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityCWProxy get copyWith => _$ActivityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Activity',
  json,
  ($checkedConvert) {
    final val = Activity(
      id: $checkedConvert('id', (v) => v as String?),
      startDateLocal: $checkedConvert('start_date_local', (v) => v as String?),
      type: $checkedConvert('type', (v) => v as String?),
      icuIgnoreTime: $checkedConvert('icu_ignore_time', (v) => v as bool?),
      icuPmCp: $checkedConvert('icu_pm_cp', (v) => (v as num?)?.toInt()),
      icuPmWPrime: $checkedConvert(
        'icu_pm_w_prime',
        (v) => (v as num?)?.toInt(),
      ),
      icuPmPMax: $checkedConvert('icu_pm_p_max', (v) => (v as num?)?.toInt()),
      icuPmFtp: $checkedConvert('icu_pm_ftp', (v) => (v as num?)?.toInt()),
      icuPmFtpSecs: $checkedConvert(
        'icu_pm_ftp_secs',
        (v) => (v as num?)?.toInt(),
      ),
      icuPmFtpWatts: $checkedConvert(
        'icu_pm_ftp_watts',
        (v) => (v as num?)?.toInt(),
      ),
      icuIgnorePower: $checkedConvert('icu_ignore_power', (v) => v as bool?),
      icuRollingCp: $checkedConvert(
        'icu_rolling_cp',
        (v) => (v as num?)?.toDouble(),
      ),
      icuRollingWPrime: $checkedConvert(
        'icu_rolling_w_prime',
        (v) => (v as num?)?.toDouble(),
      ),
      icuRollingPMax: $checkedConvert(
        'icu_rolling_p_max',
        (v) => (v as num?)?.toDouble(),
      ),
      icuRollingFtp: $checkedConvert(
        'icu_rolling_ftp',
        (v) => (v as num?)?.toInt(),
      ),
      icuRollingFtpDelta: $checkedConvert(
        'icu_rolling_ftp_delta',
        (v) => (v as num?)?.toInt(),
      ),
      icuTrainingLoad: $checkedConvert(
        'icu_training_load',
        (v) => (v as num?)?.toInt(),
      ),
      icuAtl: $checkedConvert('icu_atl', (v) => (v as num?)?.toDouble()),
      icuCtl: $checkedConvert('icu_ctl', (v) => (v as num?)?.toDouble()),
      ssPMax: $checkedConvert('ss_p_max', (v) => (v as num?)?.toDouble()),
      ssWPrime: $checkedConvert('ss_w_prime', (v) => (v as num?)?.toDouble()),
      ssCp: $checkedConvert('ss_cp', (v) => (v as num?)?.toDouble()),
      pairedEventId: $checkedConvert(
        'paired_event_id',
        (v) => (v as num?)?.toInt(),
      ),
      icuFtp: $checkedConvert('icu_ftp', (v) => (v as num?)?.toInt()),
      icuJoules: $checkedConvert('icu_joules', (v) => (v as num?)?.toInt()),
      icuRecordingTime: $checkedConvert(
        'icu_recording_time',
        (v) => (v as num?)?.toInt(),
      ),
      elapsedTime: $checkedConvert('elapsed_time', (v) => (v as num?)?.toInt()),
      icuWeightedAvgWatts: $checkedConvert(
        'icu_weighted_avg_watts',
        (v) => (v as num?)?.toInt(),
      ),
      carbsUsed: $checkedConvert('carbs_used', (v) => (v as num?)?.toInt()),
      name: $checkedConvert('name', (v) => v as String?),
      description: $checkedConvert('description', (v) => v as String?),
      startDate: $checkedConvert('start_date', (v) => v as String?),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      icuDistance: $checkedConvert(
        'icu_distance',
        (v) => (v as num?)?.toDouble(),
      ),
      movingTime: $checkedConvert('moving_time', (v) => (v as num?)?.toInt()),
      coastingTime: $checkedConvert(
        'coasting_time',
        (v) => (v as num?)?.toInt(),
      ),
      totalElevationGain: $checkedConvert(
        'total_elevation_gain',
        (v) => (v as num?)?.toDouble(),
      ),
      totalElevationLoss: $checkedConvert(
        'total_elevation_loss',
        (v) => (v as num?)?.toDouble(),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String?),
      trainer: $checkedConvert('trainer', (v) => v as bool?),
      subType: $checkedConvert(
        'sub_type',
        (v) => $enumDecodeNullable(_$ActivitySubTypeEnumEnumMap, v),
      ),
      commute: $checkedConvert('commute', (v) => v as bool?),
      race: $checkedConvert('race', (v) => v as bool?),
      maxSpeed: $checkedConvert('max_speed', (v) => (v as num?)?.toDouble()),
      averageSpeed: $checkedConvert(
        'average_speed',
        (v) => (v as num?)?.toDouble(),
      ),
      deviceWatts: $checkedConvert('device_watts', (v) => v as bool?),
      hasHeartrate: $checkedConvert('has_heartrate', (v) => v as bool?),
      maxHeartrate: $checkedConvert(
        'max_heartrate',
        (v) => (v as num?)?.toInt(),
      ),
      averageHeartrate: $checkedConvert(
        'average_heartrate',
        (v) => (v as num?)?.toInt(),
      ),
      averageCadence: $checkedConvert(
        'average_cadence',
        (v) => (v as num?)?.toDouble(),
      ),
      calories: $checkedConvert('calories', (v) => (v as num?)?.toInt()),
      averageTemp: $checkedConvert(
        'average_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      minTemp: $checkedConvert('min_temp', (v) => (v as num?)?.toInt()),
      maxTemp: $checkedConvert('max_temp', (v) => (v as num?)?.toInt()),
      avgLrBalance: $checkedConvert(
        'avg_lr_balance',
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
      gap: $checkedConvert('gap', (v) => (v as num?)?.toDouble()),
      gapModel: $checkedConvert(
        'gap_model',
        (v) => $enumDecodeNullable(_$ActivityGapModelEnumEnumMap, v),
      ),
      useElevationCorrection: $checkedConvert(
        'use_elevation_correction',
        (v) => v as bool?,
      ),
      gear: $checkedConvert(
        'gear',
        (v) =>
            v == null ? null : StravaGear.fromJson(v as Map<String, dynamic>),
      ),
      perceivedExertion: $checkedConvert(
        'perceived_exertion',
        (v) => (v as num?)?.toDouble(),
      ),
      deviceName: $checkedConvert('device_name', (v) => v as String?),
      powerMeter: $checkedConvert('power_meter', (v) => v as String?),
      powerMeterSerial: $checkedConvert(
        'power_meter_serial',
        (v) => v as String?,
      ),
      powerMeterBattery: $checkedConvert(
        'power_meter_battery',
        (v) => v as String?,
      ),
      crankLength: $checkedConvert(
        'crank_length',
        (v) => (v as num?)?.toDouble(),
      ),
      externalId: $checkedConvert('external_id', (v) => v as String?),
      fileSportIndex: $checkedConvert(
        'file_sport_index',
        (v) => (v as num?)?.toInt(),
      ),
      fileType: $checkedConvert('file_type', (v) => v as String?),
      icuAthleteId: $checkedConvert('icu_athlete_id', (v) => v as String?),
      created: $checkedConvert(
        'created',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuSyncDate: $checkedConvert(
        'icu_sync_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      analyzed: $checkedConvert(
        'analyzed',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      icuWPrime: $checkedConvert('icu_w_prime', (v) => (v as num?)?.toInt()),
      pMax: $checkedConvert('p_max', (v) => (v as num?)?.toInt()),
      thresholdPace: $checkedConvert(
        'threshold_pace',
        (v) => (v as num?)?.toDouble(),
      ),
      icuHrZones: $checkedConvert(
        'icu_hr_zones',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      paceZones: $checkedConvert(
        'pace_zones',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      lthr: $checkedConvert('lthr', (v) => (v as num?)?.toInt()),
      icuRestingHr: $checkedConvert(
        'icu_resting_hr',
        (v) => (v as num?)?.toInt(),
      ),
      icuWeight: $checkedConvert('icu_weight', (v) => (v as num?)?.toDouble()),
      icuPowerZones: $checkedConvert(
        'icu_power_zones',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      icuSweetSpotMin: $checkedConvert(
        'icu_sweet_spot_min',
        (v) => (v as num?)?.toInt(),
      ),
      icuSweetSpotMax: $checkedConvert(
        'icu_sweet_spot_max',
        (v) => (v as num?)?.toInt(),
      ),
      icuPowerSpikeThreshold: $checkedConvert(
        'icu_power_spike_threshold',
        (v) => (v as num?)?.toInt(),
      ),
      trimp: $checkedConvert('trimp', (v) => (v as num?)?.toDouble()),
      icuWarmupTime: $checkedConvert(
        'icu_warmup_time',
        (v) => (v as num?)?.toInt(),
      ),
      icuCooldownTime: $checkedConvert(
        'icu_cooldown_time',
        (v) => (v as num?)?.toInt(),
      ),
      icuChatId: $checkedConvert('icu_chat_id', (v) => (v as num?)?.toInt()),
      icuIgnoreHr: $checkedConvert('icu_ignore_hr', (v) => v as bool?),
      ignoreVelocity: $checkedConvert('ignore_velocity', (v) => v as bool?),
      ignorePace: $checkedConvert('ignore_pace', (v) => v as bool?),
      ignoreParts: $checkedConvert(
        'ignore_parts',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Ignore.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuTrainingLoadData: $checkedConvert(
        'icu_training_load_data',
        (v) => (v as num?)?.toInt(),
      ),
      intervalSummary: $checkedConvert(
        'interval_summary',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      skylineChartBytes: $checkedConvert(
        'skyline_chart_bytes',
        (v) => v as String?,
      ),
      streamTypes: $checkedConvert(
        'stream_types',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      hasWeather: $checkedConvert('has_weather', (v) => v as bool?),
      hasSegments: $checkedConvert('has_segments', (v) => v as bool?),
      powerFieldNames: $checkedConvert(
        'power_field_names',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      powerField: $checkedConvert('power_field', (v) => v as String?),
      icuZoneTimes: $checkedConvert(
        'icu_zone_times',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ZoneTime.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuHrZoneTimes: $checkedConvert(
        'icu_hr_zone_times',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      paceZoneTimes: $checkedConvert(
        'pace_zone_times',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      gapZoneTimes: $checkedConvert(
        'gap_zone_times',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      useGapZoneTimes: $checkedConvert('use_gap_zone_times', (v) => v as bool?),
      customZones: $checkedConvert(
        'custom_zones',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ZoneSet.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      tizOrder: $checkedConvert(
        'tiz_order',
        (v) => $enumDecodeNullable(_$ActivityTizOrderEnumEnumMap, v),
      ),
      polarizationIndex: $checkedConvert(
        'polarization_index',
        (v) => (v as num?)?.toDouble(),
      ),
      icuAchievements: $checkedConvert(
        'icu_achievements',
        (v) => (v as List<dynamic>?)
            ?.map((e) => IcuAchievement.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      icuIntervalsEdited: $checkedConvert(
        'icu_intervals_edited',
        (v) => v as bool?,
      ),
      lockIntervals: $checkedConvert('lock_intervals', (v) => v as bool?),
      icuLapCount: $checkedConvert(
        'icu_lap_count',
        (v) => (v as num?)?.toInt(),
      ),
      icuJoulesAboveFtp: $checkedConvert(
        'icu_joules_above_ftp',
        (v) => (v as num?)?.toInt(),
      ),
      icuMaxWbalDepletion: $checkedConvert(
        'icu_max_wbal_depletion',
        (v) => (v as num?)?.toInt(),
      ),
      icuHrr: $checkedConvert(
        'icu_hrr',
        (v) =>
            v == null ? null : HRRecovery.fromJson(v as Map<String, dynamic>),
      ),
      icuSyncError: $checkedConvert('icu_sync_error', (v) => v as String?),
      icuColor: $checkedConvert('icu_color', (v) => v as String?),
      icuPowerHrZ2: $checkedConvert(
        'icu_power_hr_z2',
        (v) => (v as num?)?.toDouble(),
      ),
      icuPowerHrZ2Mins: $checkedConvert(
        'icu_power_hr_z2_mins',
        (v) => (v as num?)?.toInt(),
      ),
      icuCadenceZ2: $checkedConvert(
        'icu_cadence_z2',
        (v) => (v as num?)?.toInt(),
      ),
      icuRpe: $checkedConvert('icu_rpe', (v) => (v as num?)?.toInt()),
      feel: $checkedConvert('feel', (v) => (v as num?)?.toInt()),
      kgLifted: $checkedConvert('kg_lifted', (v) => (v as num?)?.toDouble()),
      decoupling: $checkedConvert('decoupling', (v) => (v as num?)?.toDouble()),
      icuMedianTimeDelta: $checkedConvert(
        'icu_median_time_delta',
        (v) => (v as num?)?.toInt(),
      ),
      p30sExponent: $checkedConvert(
        'p30s_exponent',
        (v) => (v as num?)?.toDouble(),
      ),
      workoutShiftSecs: $checkedConvert(
        'workout_shift_secs',
        (v) => (v as num?)?.toInt(),
      ),
      stravaId: $checkedConvert('strava_id', (v) => v as String?),
      lengths: $checkedConvert('lengths', (v) => (v as num?)?.toInt()),
      poolLength: $checkedConvert(
        'pool_length',
        (v) => (v as num?)?.toDouble(),
      ),
      compliance: $checkedConvert('compliance', (v) => (v as num?)?.toDouble()),
      coachTick: $checkedConvert('coach_tick', (v) => (v as num?)?.toInt()),
      source_: $checkedConvert(
        'source',
        (v) => $enumDecodeNullable(_$ActivitySource_EnumEnumMap, v),
      ),
      oauthClientId: $checkedConvert(
        'oauth_client_id',
        (v) => (v as num?)?.toInt(),
      ),
      oauthClientName: $checkedConvert(
        'oauth_client_name',
        (v) => v as String?,
      ),
      averageAltitude: $checkedConvert(
        'average_altitude',
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
      powerLoad: $checkedConvert('power_load', (v) => (v as num?)?.toInt()),
      hrLoad: $checkedConvert('hr_load', (v) => (v as num?)?.toInt()),
      paceLoad: $checkedConvert('pace_load', (v) => (v as num?)?.toInt()),
      hrLoadType: $checkedConvert(
        'hr_load_type',
        (v) => $enumDecodeNullable(_$ActivityHrLoadTypeEnumEnumMap, v),
      ),
      paceLoadType: $checkedConvert(
        'pace_load_type',
        (v) => $enumDecodeNullable(_$ActivityPaceLoadTypeEnumEnumMap, v),
      ),
      tags: $checkedConvert(
        'tags',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      attachments: $checkedConvert(
        'attachments',
        (v) => (v as List<dynamic>?)
            ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      recordingStops: $checkedConvert(
        'recording_stops',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      averageWeatherTemp: $checkedConvert(
        'average_weather_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      minWeatherTemp: $checkedConvert(
        'min_weather_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      maxWeatherTemp: $checkedConvert(
        'max_weather_temp',
        (v) => (v as num?)?.toDouble(),
      ),
      averageFeelsLike: $checkedConvert(
        'average_feels_like',
        (v) => (v as num?)?.toDouble(),
      ),
      minFeelsLike: $checkedConvert(
        'min_feels_like',
        (v) => (v as num?)?.toDouble(),
      ),
      maxFeelsLike: $checkedConvert(
        'max_feels_like',
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
      headwindPercent: $checkedConvert(
        'headwind_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      tailwindPercent: $checkedConvert(
        'tailwind_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      averageClouds: $checkedConvert(
        'average_clouds',
        (v) => (v as num?)?.toInt(),
      ),
      maxRain: $checkedConvert('max_rain', (v) => (v as num?)?.toDouble()),
      maxSnow: $checkedConvert('max_snow', (v) => (v as num?)?.toDouble()),
      carbsIngested: $checkedConvert(
        'carbs_ingested',
        (v) => (v as num?)?.toInt(),
      ),
      routeId: $checkedConvert('route_id', (v) => (v as num?)?.toInt()),
      analysisIssues: $checkedConvert(
        'analysis_issues',
        (v) => (v as List<dynamic>?)
            ?.map(
              (e) => ActivityAnalysisIssue.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
      icuIntensity: $checkedConvert(
        'icu_intensity',
        (v) => (v as num?)?.toDouble(),
      ),
      pace: $checkedConvert('pace', (v) => (v as num?)?.toDouble()),
      icuEfficiencyFactor: $checkedConvert(
        'icu_efficiency_factor',
        (v) => (v as num?)?.toDouble(),
      ),
      athleteMaxHr: $checkedConvert(
        'athlete_max_hr',
        (v) => (v as num?)?.toInt(),
      ),
      group: $checkedConvert('group', (v) => v as String?),
      icuPowerHr: $checkedConvert(
        'icu_power_hr',
        (v) => (v as num?)?.toDouble(),
      ),
      sessionRpe: $checkedConvert('session_rpe', (v) => (v as num?)?.toInt()),
      averageStride: $checkedConvert(
        'average_stride',
        (v) => (v as num?)?.toDouble(),
      ),
      icuAverageWatts: $checkedConvert(
        'icu_average_watts',
        (v) => (v as num?)?.toInt(),
      ),
      icuVariabilityIndex: $checkedConvert(
        'icu_variability_index',
        (v) => (v as num?)?.toDouble(),
      ),
      strainScore: $checkedConvert(
        'strain_score',
        (v) => (v as num?)?.toDouble(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'startDateLocal': 'start_date_local',
    'icuIgnoreTime': 'icu_ignore_time',
    'icuPmCp': 'icu_pm_cp',
    'icuPmWPrime': 'icu_pm_w_prime',
    'icuPmPMax': 'icu_pm_p_max',
    'icuPmFtp': 'icu_pm_ftp',
    'icuPmFtpSecs': 'icu_pm_ftp_secs',
    'icuPmFtpWatts': 'icu_pm_ftp_watts',
    'icuIgnorePower': 'icu_ignore_power',
    'icuRollingCp': 'icu_rolling_cp',
    'icuRollingWPrime': 'icu_rolling_w_prime',
    'icuRollingPMax': 'icu_rolling_p_max',
    'icuRollingFtp': 'icu_rolling_ftp',
    'icuRollingFtpDelta': 'icu_rolling_ftp_delta',
    'icuTrainingLoad': 'icu_training_load',
    'icuAtl': 'icu_atl',
    'icuCtl': 'icu_ctl',
    'ssPMax': 'ss_p_max',
    'ssWPrime': 'ss_w_prime',
    'ssCp': 'ss_cp',
    'pairedEventId': 'paired_event_id',
    'icuFtp': 'icu_ftp',
    'icuJoules': 'icu_joules',
    'icuRecordingTime': 'icu_recording_time',
    'elapsedTime': 'elapsed_time',
    'icuWeightedAvgWatts': 'icu_weighted_avg_watts',
    'carbsUsed': 'carbs_used',
    'startDate': 'start_date',
    'icuDistance': 'icu_distance',
    'movingTime': 'moving_time',
    'coastingTime': 'coasting_time',
    'totalElevationGain': 'total_elevation_gain',
    'totalElevationLoss': 'total_elevation_loss',
    'subType': 'sub_type',
    'maxSpeed': 'max_speed',
    'averageSpeed': 'average_speed',
    'deviceWatts': 'device_watts',
    'hasHeartrate': 'has_heartrate',
    'maxHeartrate': 'max_heartrate',
    'averageHeartrate': 'average_heartrate',
    'averageCadence': 'average_cadence',
    'averageTemp': 'average_temp',
    'minTemp': 'min_temp',
    'maxTemp': 'max_temp',
    'avgLrBalance': 'avg_lr_balance',
    'averageStanceTime': 'average_stance_time',
    'averageVerticalOscillation': 'average_vertical_oscillation',
    'averageVerticalRatio': 'average_vertical_ratio',
    'averageStepLength': 'average_step_length',
    'averageStanceTimePercent': 'average_stance_time_percent',
    'averageStanceTimeBalance': 'average_stance_time_balance',
    'averageVerticalSpeed': 'average_vertical_speed',
    'averageLegSpringStiffness': 'average_leg_spring_stiffness',
    'averageImpactLoadingRate': 'average_impact_loading_rate',
    'gapModel': 'gap_model',
    'useElevationCorrection': 'use_elevation_correction',
    'perceivedExertion': 'perceived_exertion',
    'deviceName': 'device_name',
    'powerMeter': 'power_meter',
    'powerMeterSerial': 'power_meter_serial',
    'powerMeterBattery': 'power_meter_battery',
    'crankLength': 'crank_length',
    'externalId': 'external_id',
    'fileSportIndex': 'file_sport_index',
    'fileType': 'file_type',
    'icuAthleteId': 'icu_athlete_id',
    'icuSyncDate': 'icu_sync_date',
    'icuWPrime': 'icu_w_prime',
    'pMax': 'p_max',
    'thresholdPace': 'threshold_pace',
    'icuHrZones': 'icu_hr_zones',
    'paceZones': 'pace_zones',
    'icuRestingHr': 'icu_resting_hr',
    'icuWeight': 'icu_weight',
    'icuPowerZones': 'icu_power_zones',
    'icuSweetSpotMin': 'icu_sweet_spot_min',
    'icuSweetSpotMax': 'icu_sweet_spot_max',
    'icuPowerSpikeThreshold': 'icu_power_spike_threshold',
    'icuWarmupTime': 'icu_warmup_time',
    'icuCooldownTime': 'icu_cooldown_time',
    'icuChatId': 'icu_chat_id',
    'icuIgnoreHr': 'icu_ignore_hr',
    'ignoreVelocity': 'ignore_velocity',
    'ignorePace': 'ignore_pace',
    'ignoreParts': 'ignore_parts',
    'icuTrainingLoadData': 'icu_training_load_data',
    'intervalSummary': 'interval_summary',
    'skylineChartBytes': 'skyline_chart_bytes',
    'streamTypes': 'stream_types',
    'hasWeather': 'has_weather',
    'hasSegments': 'has_segments',
    'powerFieldNames': 'power_field_names',
    'powerField': 'power_field',
    'icuZoneTimes': 'icu_zone_times',
    'icuHrZoneTimes': 'icu_hr_zone_times',
    'paceZoneTimes': 'pace_zone_times',
    'gapZoneTimes': 'gap_zone_times',
    'useGapZoneTimes': 'use_gap_zone_times',
    'customZones': 'custom_zones',
    'tizOrder': 'tiz_order',
    'polarizationIndex': 'polarization_index',
    'icuAchievements': 'icu_achievements',
    'icuIntervalsEdited': 'icu_intervals_edited',
    'lockIntervals': 'lock_intervals',
    'icuLapCount': 'icu_lap_count',
    'icuJoulesAboveFtp': 'icu_joules_above_ftp',
    'icuMaxWbalDepletion': 'icu_max_wbal_depletion',
    'icuHrr': 'icu_hrr',
    'icuSyncError': 'icu_sync_error',
    'icuColor': 'icu_color',
    'icuPowerHrZ2': 'icu_power_hr_z2',
    'icuPowerHrZ2Mins': 'icu_power_hr_z2_mins',
    'icuCadenceZ2': 'icu_cadence_z2',
    'icuRpe': 'icu_rpe',
    'kgLifted': 'kg_lifted',
    'icuMedianTimeDelta': 'icu_median_time_delta',
    'p30sExponent': 'p30s_exponent',
    'workoutShiftSecs': 'workout_shift_secs',
    'stravaId': 'strava_id',
    'poolLength': 'pool_length',
    'coachTick': 'coach_tick',
    'source_': 'source',
    'oauthClientId': 'oauth_client_id',
    'oauthClientName': 'oauth_client_name',
    'averageAltitude': 'average_altitude',
    'minAltitude': 'min_altitude',
    'maxAltitude': 'max_altitude',
    'powerLoad': 'power_load',
    'hrLoad': 'hr_load',
    'paceLoad': 'pace_load',
    'hrLoadType': 'hr_load_type',
    'paceLoadType': 'pace_load_type',
    'recordingStops': 'recording_stops',
    'averageWeatherTemp': 'average_weather_temp',
    'minWeatherTemp': 'min_weather_temp',
    'maxWeatherTemp': 'max_weather_temp',
    'averageFeelsLike': 'average_feels_like',
    'minFeelsLike': 'min_feels_like',
    'maxFeelsLike': 'max_feels_like',
    'averageWindSpeed': 'average_wind_speed',
    'averageWindGust': 'average_wind_gust',
    'prevailingWindDeg': 'prevailing_wind_deg',
    'headwindPercent': 'headwind_percent',
    'tailwindPercent': 'tailwind_percent',
    'averageClouds': 'average_clouds',
    'maxRain': 'max_rain',
    'maxSnow': 'max_snow',
    'carbsIngested': 'carbs_ingested',
    'routeId': 'route_id',
    'analysisIssues': 'analysis_issues',
    'icuIntensity': 'icu_intensity',
    'icuEfficiencyFactor': 'icu_efficiency_factor',
    'athleteMaxHr': 'athlete_max_hr',
    'icuPowerHr': 'icu_power_hr',
    'sessionRpe': 'session_rpe',
    'averageStride': 'average_stride',
    'icuAverageWatts': 'icu_average_watts',
    'icuVariabilityIndex': 'icu_variability_index',
    'strainScore': 'strain_score',
  },
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': ?instance.id,
  'start_date_local': ?instance.startDateLocal,
  'type': ?instance.type,
  'icu_ignore_time': ?instance.icuIgnoreTime,
  'icu_pm_cp': ?instance.icuPmCp,
  'icu_pm_w_prime': ?instance.icuPmWPrime,
  'icu_pm_p_max': ?instance.icuPmPMax,
  'icu_pm_ftp': ?instance.icuPmFtp,
  'icu_pm_ftp_secs': ?instance.icuPmFtpSecs,
  'icu_pm_ftp_watts': ?instance.icuPmFtpWatts,
  'icu_ignore_power': ?instance.icuIgnorePower,
  'icu_rolling_cp': ?instance.icuRollingCp,
  'icu_rolling_w_prime': ?instance.icuRollingWPrime,
  'icu_rolling_p_max': ?instance.icuRollingPMax,
  'icu_rolling_ftp': ?instance.icuRollingFtp,
  'icu_rolling_ftp_delta': ?instance.icuRollingFtpDelta,
  'icu_training_load': ?instance.icuTrainingLoad,
  'icu_atl': ?instance.icuAtl,
  'icu_ctl': ?instance.icuCtl,
  'ss_p_max': ?instance.ssPMax,
  'ss_w_prime': ?instance.ssWPrime,
  'ss_cp': ?instance.ssCp,
  'paired_event_id': ?instance.pairedEventId,
  'icu_ftp': ?instance.icuFtp,
  'icu_joules': ?instance.icuJoules,
  'icu_recording_time': ?instance.icuRecordingTime,
  'elapsed_time': ?instance.elapsedTime,
  'icu_weighted_avg_watts': ?instance.icuWeightedAvgWatts,
  'carbs_used': ?instance.carbsUsed,
  'name': ?instance.name,
  'description': ?instance.description,
  'start_date': ?instance.startDate,
  'distance': ?instance.distance,
  'icu_distance': ?instance.icuDistance,
  'moving_time': ?instance.movingTime,
  'coasting_time': ?instance.coastingTime,
  'total_elevation_gain': ?instance.totalElevationGain,
  'total_elevation_loss': ?instance.totalElevationLoss,
  'timezone': ?instance.timezone,
  'trainer': ?instance.trainer,
  'sub_type': ?_$ActivitySubTypeEnumEnumMap[instance.subType],
  'commute': ?instance.commute,
  'race': ?instance.race,
  'max_speed': ?instance.maxSpeed,
  'average_speed': ?instance.averageSpeed,
  'device_watts': ?instance.deviceWatts,
  'has_heartrate': ?instance.hasHeartrate,
  'max_heartrate': ?instance.maxHeartrate,
  'average_heartrate': ?instance.averageHeartrate,
  'average_cadence': ?instance.averageCadence,
  'calories': ?instance.calories,
  'average_temp': ?instance.averageTemp,
  'min_temp': ?instance.minTemp,
  'max_temp': ?instance.maxTemp,
  'avg_lr_balance': ?instance.avgLrBalance,
  'average_stance_time': ?instance.averageStanceTime,
  'average_vertical_oscillation': ?instance.averageVerticalOscillation,
  'average_vertical_ratio': ?instance.averageVerticalRatio,
  'average_step_length': ?instance.averageStepLength,
  'average_stance_time_percent': ?instance.averageStanceTimePercent,
  'average_stance_time_balance': ?instance.averageStanceTimeBalance,
  'average_vertical_speed': ?instance.averageVerticalSpeed,
  'average_leg_spring_stiffness': ?instance.averageLegSpringStiffness,
  'average_impact_loading_rate': ?instance.averageImpactLoadingRate,
  'gap': ?instance.gap,
  'gap_model': ?_$ActivityGapModelEnumEnumMap[instance.gapModel],
  'use_elevation_correction': ?instance.useElevationCorrection,
  'gear': ?instance.gear?.toJson(),
  'perceived_exertion': ?instance.perceivedExertion,
  'device_name': ?instance.deviceName,
  'power_meter': ?instance.powerMeter,
  'power_meter_serial': ?instance.powerMeterSerial,
  'power_meter_battery': ?instance.powerMeterBattery,
  'crank_length': ?instance.crankLength,
  'external_id': ?instance.externalId,
  'file_sport_index': ?instance.fileSportIndex,
  'file_type': ?instance.fileType,
  'icu_athlete_id': ?instance.icuAthleteId,
  'created': ?instance.created?.toIso8601String(),
  'icu_sync_date': ?instance.icuSyncDate?.toIso8601String(),
  'analyzed': ?instance.analyzed?.toIso8601String(),
  'icu_w_prime': ?instance.icuWPrime,
  'p_max': ?instance.pMax,
  'threshold_pace': ?instance.thresholdPace,
  'icu_hr_zones': ?instance.icuHrZones,
  'pace_zones': ?instance.paceZones,
  'lthr': ?instance.lthr,
  'icu_resting_hr': ?instance.icuRestingHr,
  'icu_weight': ?instance.icuWeight,
  'icu_power_zones': ?instance.icuPowerZones,
  'icu_sweet_spot_min': ?instance.icuSweetSpotMin,
  'icu_sweet_spot_max': ?instance.icuSweetSpotMax,
  'icu_power_spike_threshold': ?instance.icuPowerSpikeThreshold,
  'trimp': ?instance.trimp,
  'icu_warmup_time': ?instance.icuWarmupTime,
  'icu_cooldown_time': ?instance.icuCooldownTime,
  'icu_chat_id': ?instance.icuChatId,
  'icu_ignore_hr': ?instance.icuIgnoreHr,
  'ignore_velocity': ?instance.ignoreVelocity,
  'ignore_pace': ?instance.ignorePace,
  'ignore_parts': ?instance.ignoreParts?.map((e) => e.toJson()).toList(),
  'icu_training_load_data': ?instance.icuTrainingLoadData,
  'interval_summary': ?instance.intervalSummary,
  'skyline_chart_bytes': ?instance.skylineChartBytes,
  'stream_types': ?instance.streamTypes,
  'has_weather': ?instance.hasWeather,
  'has_segments': ?instance.hasSegments,
  'power_field_names': ?instance.powerFieldNames,
  'power_field': ?instance.powerField,
  'icu_zone_times': ?instance.icuZoneTimes?.map((e) => e.toJson()).toList(),
  'icu_hr_zone_times': ?instance.icuHrZoneTimes,
  'pace_zone_times': ?instance.paceZoneTimes,
  'gap_zone_times': ?instance.gapZoneTimes,
  'use_gap_zone_times': ?instance.useGapZoneTimes,
  'custom_zones': ?instance.customZones?.map((e) => e.toJson()).toList(),
  'tiz_order': ?_$ActivityTizOrderEnumEnumMap[instance.tizOrder],
  'polarization_index': ?instance.polarizationIndex,
  'icu_achievements': ?instance.icuAchievements
      ?.map((e) => e.toJson())
      .toList(),
  'icu_intervals_edited': ?instance.icuIntervalsEdited,
  'lock_intervals': ?instance.lockIntervals,
  'icu_lap_count': ?instance.icuLapCount,
  'icu_joules_above_ftp': ?instance.icuJoulesAboveFtp,
  'icu_max_wbal_depletion': ?instance.icuMaxWbalDepletion,
  'icu_hrr': ?instance.icuHrr?.toJson(),
  'icu_sync_error': ?instance.icuSyncError,
  'icu_color': ?instance.icuColor,
  'icu_power_hr_z2': ?instance.icuPowerHrZ2,
  'icu_power_hr_z2_mins': ?instance.icuPowerHrZ2Mins,
  'icu_cadence_z2': ?instance.icuCadenceZ2,
  'icu_rpe': ?instance.icuRpe,
  'feel': ?instance.feel,
  'kg_lifted': ?instance.kgLifted,
  'decoupling': ?instance.decoupling,
  'icu_median_time_delta': ?instance.icuMedianTimeDelta,
  'p30s_exponent': ?instance.p30sExponent,
  'workout_shift_secs': ?instance.workoutShiftSecs,
  'strava_id': ?instance.stravaId,
  'lengths': ?instance.lengths,
  'pool_length': ?instance.poolLength,
  'compliance': ?instance.compliance,
  'coach_tick': ?instance.coachTick,
  'source': ?_$ActivitySource_EnumEnumMap[instance.source_],
  'oauth_client_id': ?instance.oauthClientId,
  'oauth_client_name': ?instance.oauthClientName,
  'average_altitude': ?instance.averageAltitude,
  'min_altitude': ?instance.minAltitude,
  'max_altitude': ?instance.maxAltitude,
  'power_load': ?instance.powerLoad,
  'hr_load': ?instance.hrLoad,
  'pace_load': ?instance.paceLoad,
  'hr_load_type': ?_$ActivityHrLoadTypeEnumEnumMap[instance.hrLoadType],
  'pace_load_type': ?_$ActivityPaceLoadTypeEnumEnumMap[instance.paceLoadType],
  'tags': ?instance.tags,
  'attachments': ?instance.attachments?.map((e) => e.toJson()).toList(),
  'recording_stops': ?instance.recordingStops,
  'average_weather_temp': ?instance.averageWeatherTemp,
  'min_weather_temp': ?instance.minWeatherTemp,
  'max_weather_temp': ?instance.maxWeatherTemp,
  'average_feels_like': ?instance.averageFeelsLike,
  'min_feels_like': ?instance.minFeelsLike,
  'max_feels_like': ?instance.maxFeelsLike,
  'average_wind_speed': ?instance.averageWindSpeed,
  'average_wind_gust': ?instance.averageWindGust,
  'prevailing_wind_deg': ?instance.prevailingWindDeg,
  'headwind_percent': ?instance.headwindPercent,
  'tailwind_percent': ?instance.tailwindPercent,
  'average_clouds': ?instance.averageClouds,
  'max_rain': ?instance.maxRain,
  'max_snow': ?instance.maxSnow,
  'carbs_ingested': ?instance.carbsIngested,
  'route_id': ?instance.routeId,
  'analysis_issues': ?instance.analysisIssues?.map((e) => e.toJson()).toList(),
  'icu_intensity': ?instance.icuIntensity,
  'pace': ?instance.pace,
  'icu_efficiency_factor': ?instance.icuEfficiencyFactor,
  'athlete_max_hr': ?instance.athleteMaxHr,
  'group': ?instance.group,
  'icu_power_hr': ?instance.icuPowerHr,
  'session_rpe': ?instance.sessionRpe,
  'average_stride': ?instance.averageStride,
  'icu_average_watts': ?instance.icuAverageWatts,
  'icu_variability_index': ?instance.icuVariabilityIndex,
  'strain_score': ?instance.strainScore,
};

const _$ActivitySubTypeEnumEnumMap = {
  ActivitySubTypeEnum.NONE: 'NONE',
  ActivitySubTypeEnum.COMMUTE: 'COMMUTE',
  ActivitySubTypeEnum.WARMUP: 'WARMUP',
  ActivitySubTypeEnum.COOLDOWN: 'COOLDOWN',
  ActivitySubTypeEnum.RACE: 'RACE',
};

const _$ActivityGapModelEnumEnumMap = {
  ActivityGapModelEnum.NONE: 'NONE',
  ActivityGapModelEnum.STRAVA_RUN: 'STRAVA_RUN',
};

const _$ActivityTizOrderEnumEnumMap = {
  ActivityTizOrderEnum.POWER_HR_PACE: 'POWER_HR_PACE',
  ActivityTizOrderEnum.POWER_PACE_HR: 'POWER_PACE_HR',
  ActivityTizOrderEnum.HR_POWER_PACE: 'HR_POWER_PACE',
  ActivityTizOrderEnum.HR_PACE_POWER: 'HR_PACE_POWER',
  ActivityTizOrderEnum.PACE_POWER_HR: 'PACE_POWER_HR',
  ActivityTizOrderEnum.PACE_HR_POWER: 'PACE_HR_POWER',
};

const _$ActivitySource_EnumEnumMap = {
  ActivitySource_Enum.STRAVA: 'STRAVA',
  ActivitySource_Enum.UPLOAD: 'UPLOAD',
  ActivitySource_Enum.MANUAL: 'MANUAL',
  ActivitySource_Enum.GARMIN_CONNECT: 'GARMIN_CONNECT',
  ActivitySource_Enum.OAUTH_CLIENT: 'OAUTH_CLIENT',
  ActivitySource_Enum.DROPBOX: 'DROPBOX',
  ActivitySource_Enum.POLAR: 'POLAR',
  ActivitySource_Enum.SUUNTO: 'SUUNTO',
  ActivitySource_Enum.COROS: 'COROS',
  ActivitySource_Enum.WAHOO: 'WAHOO',
  ActivitySource_Enum.ZWIFT: 'ZWIFT',
  ActivitySource_Enum.ZEPP: 'ZEPP',
  ActivitySource_Enum.CONCEPT2: 'CONCEPT2',
  ActivitySource_Enum.HUAWEI: 'HUAWEI',
};

const _$ActivityHrLoadTypeEnumEnumMap = {
  ActivityHrLoadTypeEnum.AVG_HR: 'AVG_HR',
  ActivityHrLoadTypeEnum.HR_ZONES: 'HR_ZONES',
  ActivityHrLoadTypeEnum.HRSS: 'HRSS',
};

const _$ActivityPaceLoadTypeEnumEnumMap = {
  ActivityPaceLoadTypeEnum.SWIM: 'SWIM',
  ActivityPaceLoadTypeEnum.RUN: 'RUN',
};
