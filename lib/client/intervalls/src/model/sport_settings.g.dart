// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SportSettingsCWProxy {
  SportSettings id(int? id);

  SportSettings athleteId(String? athleteId);

  SportSettings types(List<SportSettingsTypesEnum>? types);

  SportSettings warmupTime(int? warmupTime);

  SportSettings cooldownTime(int? cooldownTime);

  SportSettings ftp(int? ftp);

  SportSettings indoorFtp(int? indoorFtp);

  SportSettings wPrime(int? wPrime);

  SportSettings pMax(int? pMax);

  SportSettings powerZones(List<int>? powerZones);

  SportSettings sweetSpotMin(int? sweetSpotMin);

  SportSettings sweetSpotMax(int? sweetSpotMax);

  SportSettings powerSpikeThreshold(int? powerSpikeThreshold);

  SportSettings powerZoneNames(List<String>? powerZoneNames);

  SportSettings ftpEstMinSecs(int? ftpEstMinSecs);

  SportSettings useLapsForPowerIntervals(bool? useLapsForPowerIntervals);

  SportSettings keepAllLapsForPowerIntervals(
    bool? keepAllLapsForPowerIntervals,
  );

  SportSettings powerIntervalsStartLocked(bool? powerIntervalsStartLocked);

  SportSettings afterKj0(int? afterKj0);

  SportSettings afterKj1(int? afterKj1);

  SportSettings powerField(String? powerField);

  SportSettings lthr(int? lthr);

  SportSettings maxHr(int? maxHr);

  SportSettings hrZones(List<int>? hrZones);

  SportSettings hrZoneNames(List<String>? hrZoneNames);

  SportSettings hrLoadType(SportSettingsHrLoadTypeEnum? hrLoadType);

  SportSettings hrrcMinPercent(double? hrrcMinPercent);

  SportSettings thresholdPace(double? thresholdPace);

  SportSettings paceUnits(SportSettingsPaceUnitsEnum? paceUnits);

  SportSettings paceZones(List<double>? paceZones);

  SportSettings paceZoneNames(List<String>? paceZoneNames);

  SportSettings paceLoadType(SportSettingsPaceLoadTypeEnum? paceLoadType);

  SportSettings gapModel(SportSettingsGapModelEnum? gapModel);

  SportSettings elevationCorrection(
    SportSettingsElevationCorrectionEnum? elevationCorrection,
  );

  SportSettings useGapZoneTimes(bool? useGapZoneTimes);

  SportSettings bestEffortDistances(List<double>? bestEffortDistances);

  SportSettings paceCurveStart(double? paceCurveStart);

  SportSettings loadOrder(SportSettingsLoadOrderEnum? loadOrder);

  SportSettings tizOrder(SportSettingsTizOrderEnum? tizOrder);

  SportSettings workoutOrder(SportSettingsWorkoutOrderEnum? workoutOrder);

  SportSettings intervalDisplay(
    SportSettingsIntervalDisplayEnum? intervalDisplay,
  );

  SportSettings defaultGearId(String? defaultGearId);

  SportSettings defaultIndoorGearId(String? defaultIndoorGearId);

  SportSettings extractWorkouts(bool? extractWorkouts);

  SportSettings showPauses(int? showPauses);

  SportSettings ignoreVelocity(bool? ignoreVelocity);

  SportSettings defaultWorkoutTime(String? defaultWorkoutTime);

  SportSettings updateActivityNameFromWorkout(
    bool? updateActivityNameFromWorkout,
  );

  SportSettings created(DateTime? created);

  SportSettings updated(DateTime? updated);

  SportSettings mmpModel(PowerModel? mmpModel);

  SportSettings display(Display? display);

  SportSettings activityFieldIds(List<int>? activityFieldIds);

  SportSettings activityCharts(ActivityCharts? activityCharts);

  SportSettings customFieldIds(List<int>? customFieldIds);

  SportSettings customFieldValues(Map<String, Object>? customFieldValues);

  SportSettings customZonesIds(List<int>? customZonesIds);

  SportSettings calendarTileActivityPanelId(int? calendarTileActivityPanelId);

  SportSettings other(bool? other);

  SportSettings iseFTPSupported(bool? iseFTPSupported);

  SportSettings useDistanceForIntervals(bool? useDistanceForIntervals);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SportSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SportSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SportSettings call({
    int? id,
    String? athleteId,
    List<SportSettingsTypesEnum>? types,
    int? warmupTime,
    int? cooldownTime,
    int? ftp,
    int? indoorFtp,
    int? wPrime,
    int? pMax,
    List<int>? powerZones,
    int? sweetSpotMin,
    int? sweetSpotMax,
    int? powerSpikeThreshold,
    List<String>? powerZoneNames,
    int? ftpEstMinSecs,
    bool? useLapsForPowerIntervals,
    bool? keepAllLapsForPowerIntervals,
    bool? powerIntervalsStartLocked,
    int? afterKj0,
    int? afterKj1,
    String? powerField,
    int? lthr,
    int? maxHr,
    List<int>? hrZones,
    List<String>? hrZoneNames,
    SportSettingsHrLoadTypeEnum? hrLoadType,
    double? hrrcMinPercent,
    double? thresholdPace,
    SportSettingsPaceUnitsEnum? paceUnits,
    List<double>? paceZones,
    List<String>? paceZoneNames,
    SportSettingsPaceLoadTypeEnum? paceLoadType,
    SportSettingsGapModelEnum? gapModel,
    SportSettingsElevationCorrectionEnum? elevationCorrection,
    bool? useGapZoneTimes,
    List<double>? bestEffortDistances,
    double? paceCurveStart,
    SportSettingsLoadOrderEnum? loadOrder,
    SportSettingsTizOrderEnum? tizOrder,
    SportSettingsWorkoutOrderEnum? workoutOrder,
    SportSettingsIntervalDisplayEnum? intervalDisplay,
    String? defaultGearId,
    String? defaultIndoorGearId,
    bool? extractWorkouts,
    int? showPauses,
    bool? ignoreVelocity,
    String? defaultWorkoutTime,
    bool? updateActivityNameFromWorkout,
    DateTime? created,
    DateTime? updated,
    PowerModel? mmpModel,
    Display? display,
    List<int>? activityFieldIds,
    ActivityCharts? activityCharts,
    List<int>? customFieldIds,
    Map<String, Object>? customFieldValues,
    List<int>? customZonesIds,
    int? calendarTileActivityPanelId,
    bool? other,
    bool? iseFTPSupported,
    bool? useDistanceForIntervals,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSportSettings.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSportSettings.copyWith.fieldName(...)`
class _$SportSettingsCWProxyImpl implements _$SportSettingsCWProxy {
  const _$SportSettingsCWProxyImpl(this._value);

  final SportSettings _value;

  @override
  SportSettings id(int? id) => this(id: id);

  @override
  SportSettings athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  SportSettings types(List<SportSettingsTypesEnum>? types) =>
      this(types: types);

  @override
  SportSettings warmupTime(int? warmupTime) => this(warmupTime: warmupTime);

  @override
  SportSettings cooldownTime(int? cooldownTime) =>
      this(cooldownTime: cooldownTime);

  @override
  SportSettings ftp(int? ftp) => this(ftp: ftp);

  @override
  SportSettings indoorFtp(int? indoorFtp) => this(indoorFtp: indoorFtp);

  @override
  SportSettings wPrime(int? wPrime) => this(wPrime: wPrime);

  @override
  SportSettings pMax(int? pMax) => this(pMax: pMax);

  @override
  SportSettings powerZones(List<int>? powerZones) =>
      this(powerZones: powerZones);

  @override
  SportSettings sweetSpotMin(int? sweetSpotMin) =>
      this(sweetSpotMin: sweetSpotMin);

  @override
  SportSettings sweetSpotMax(int? sweetSpotMax) =>
      this(sweetSpotMax: sweetSpotMax);

  @override
  SportSettings powerSpikeThreshold(int? powerSpikeThreshold) =>
      this(powerSpikeThreshold: powerSpikeThreshold);

  @override
  SportSettings powerZoneNames(List<String>? powerZoneNames) =>
      this(powerZoneNames: powerZoneNames);

  @override
  SportSettings ftpEstMinSecs(int? ftpEstMinSecs) =>
      this(ftpEstMinSecs: ftpEstMinSecs);

  @override
  SportSettings useLapsForPowerIntervals(bool? useLapsForPowerIntervals) =>
      this(useLapsForPowerIntervals: useLapsForPowerIntervals);

  @override
  SportSettings keepAllLapsForPowerIntervals(
    bool? keepAllLapsForPowerIntervals,
  ) => this(keepAllLapsForPowerIntervals: keepAllLapsForPowerIntervals);

  @override
  SportSettings powerIntervalsStartLocked(bool? powerIntervalsStartLocked) =>
      this(powerIntervalsStartLocked: powerIntervalsStartLocked);

  @override
  SportSettings afterKj0(int? afterKj0) => this(afterKj0: afterKj0);

  @override
  SportSettings afterKj1(int? afterKj1) => this(afterKj1: afterKj1);

  @override
  SportSettings powerField(String? powerField) => this(powerField: powerField);

  @override
  SportSettings lthr(int? lthr) => this(lthr: lthr);

  @override
  SportSettings maxHr(int? maxHr) => this(maxHr: maxHr);

  @override
  SportSettings hrZones(List<int>? hrZones) => this(hrZones: hrZones);

  @override
  SportSettings hrZoneNames(List<String>? hrZoneNames) =>
      this(hrZoneNames: hrZoneNames);

  @override
  SportSettings hrLoadType(SportSettingsHrLoadTypeEnum? hrLoadType) =>
      this(hrLoadType: hrLoadType);

  @override
  SportSettings hrrcMinPercent(double? hrrcMinPercent) =>
      this(hrrcMinPercent: hrrcMinPercent);

  @override
  SportSettings thresholdPace(double? thresholdPace) =>
      this(thresholdPace: thresholdPace);

  @override
  SportSettings paceUnits(SportSettingsPaceUnitsEnum? paceUnits) =>
      this(paceUnits: paceUnits);

  @override
  SportSettings paceZones(List<double>? paceZones) =>
      this(paceZones: paceZones);

  @override
  SportSettings paceZoneNames(List<String>? paceZoneNames) =>
      this(paceZoneNames: paceZoneNames);

  @override
  SportSettings paceLoadType(SportSettingsPaceLoadTypeEnum? paceLoadType) =>
      this(paceLoadType: paceLoadType);

  @override
  SportSettings gapModel(SportSettingsGapModelEnum? gapModel) =>
      this(gapModel: gapModel);

  @override
  SportSettings elevationCorrection(
    SportSettingsElevationCorrectionEnum? elevationCorrection,
  ) => this(elevationCorrection: elevationCorrection);

  @override
  SportSettings useGapZoneTimes(bool? useGapZoneTimes) =>
      this(useGapZoneTimes: useGapZoneTimes);

  @override
  SportSettings bestEffortDistances(List<double>? bestEffortDistances) =>
      this(bestEffortDistances: bestEffortDistances);

  @override
  SportSettings paceCurveStart(double? paceCurveStart) =>
      this(paceCurveStart: paceCurveStart);

  @override
  SportSettings loadOrder(SportSettingsLoadOrderEnum? loadOrder) =>
      this(loadOrder: loadOrder);

  @override
  SportSettings tizOrder(SportSettingsTizOrderEnum? tizOrder) =>
      this(tizOrder: tizOrder);

  @override
  SportSettings workoutOrder(SportSettingsWorkoutOrderEnum? workoutOrder) =>
      this(workoutOrder: workoutOrder);

  @override
  SportSettings intervalDisplay(
    SportSettingsIntervalDisplayEnum? intervalDisplay,
  ) => this(intervalDisplay: intervalDisplay);

  @override
  SportSettings defaultGearId(String? defaultGearId) =>
      this(defaultGearId: defaultGearId);

  @override
  SportSettings defaultIndoorGearId(String? defaultIndoorGearId) =>
      this(defaultIndoorGearId: defaultIndoorGearId);

  @override
  SportSettings extractWorkouts(bool? extractWorkouts) =>
      this(extractWorkouts: extractWorkouts);

  @override
  SportSettings showPauses(int? showPauses) => this(showPauses: showPauses);

  @override
  SportSettings ignoreVelocity(bool? ignoreVelocity) =>
      this(ignoreVelocity: ignoreVelocity);

  @override
  SportSettings defaultWorkoutTime(String? defaultWorkoutTime) =>
      this(defaultWorkoutTime: defaultWorkoutTime);

  @override
  SportSettings updateActivityNameFromWorkout(
    bool? updateActivityNameFromWorkout,
  ) => this(updateActivityNameFromWorkout: updateActivityNameFromWorkout);

  @override
  SportSettings created(DateTime? created) => this(created: created);

  @override
  SportSettings updated(DateTime? updated) => this(updated: updated);

  @override
  SportSettings mmpModel(PowerModel? mmpModel) => this(mmpModel: mmpModel);

  @override
  SportSettings display(Display? display) => this(display: display);

  @override
  SportSettings activityFieldIds(List<int>? activityFieldIds) =>
      this(activityFieldIds: activityFieldIds);

  @override
  SportSettings activityCharts(ActivityCharts? activityCharts) =>
      this(activityCharts: activityCharts);

  @override
  SportSettings customFieldIds(List<int>? customFieldIds) =>
      this(customFieldIds: customFieldIds);

  @override
  SportSettings customFieldValues(Map<String, Object>? customFieldValues) =>
      this(customFieldValues: customFieldValues);

  @override
  SportSettings customZonesIds(List<int>? customZonesIds) =>
      this(customZonesIds: customZonesIds);

  @override
  SportSettings calendarTileActivityPanelId(int? calendarTileActivityPanelId) =>
      this(calendarTileActivityPanelId: calendarTileActivityPanelId);

  @override
  SportSettings other(bool? other) => this(other: other);

  @override
  SportSettings iseFTPSupported(bool? iseFTPSupported) =>
      this(iseFTPSupported: iseFTPSupported);

  @override
  SportSettings useDistanceForIntervals(bool? useDistanceForIntervals) =>
      this(useDistanceForIntervals: useDistanceForIntervals);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SportSettings(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SportSettings(...).copyWith(id: 12, name: "My name")
  /// ````
  SportSettings call({
    Object? id = const $CopyWithPlaceholder(),
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? types = const $CopyWithPlaceholder(),
    Object? warmupTime = const $CopyWithPlaceholder(),
    Object? cooldownTime = const $CopyWithPlaceholder(),
    Object? ftp = const $CopyWithPlaceholder(),
    Object? indoorFtp = const $CopyWithPlaceholder(),
    Object? wPrime = const $CopyWithPlaceholder(),
    Object? pMax = const $CopyWithPlaceholder(),
    Object? powerZones = const $CopyWithPlaceholder(),
    Object? sweetSpotMin = const $CopyWithPlaceholder(),
    Object? sweetSpotMax = const $CopyWithPlaceholder(),
    Object? powerSpikeThreshold = const $CopyWithPlaceholder(),
    Object? powerZoneNames = const $CopyWithPlaceholder(),
    Object? ftpEstMinSecs = const $CopyWithPlaceholder(),
    Object? useLapsForPowerIntervals = const $CopyWithPlaceholder(),
    Object? keepAllLapsForPowerIntervals = const $CopyWithPlaceholder(),
    Object? powerIntervalsStartLocked = const $CopyWithPlaceholder(),
    Object? afterKj0 = const $CopyWithPlaceholder(),
    Object? afterKj1 = const $CopyWithPlaceholder(),
    Object? powerField = const $CopyWithPlaceholder(),
    Object? lthr = const $CopyWithPlaceholder(),
    Object? maxHr = const $CopyWithPlaceholder(),
    Object? hrZones = const $CopyWithPlaceholder(),
    Object? hrZoneNames = const $CopyWithPlaceholder(),
    Object? hrLoadType = const $CopyWithPlaceholder(),
    Object? hrrcMinPercent = const $CopyWithPlaceholder(),
    Object? thresholdPace = const $CopyWithPlaceholder(),
    Object? paceUnits = const $CopyWithPlaceholder(),
    Object? paceZones = const $CopyWithPlaceholder(),
    Object? paceZoneNames = const $CopyWithPlaceholder(),
    Object? paceLoadType = const $CopyWithPlaceholder(),
    Object? gapModel = const $CopyWithPlaceholder(),
    Object? elevationCorrection = const $CopyWithPlaceholder(),
    Object? useGapZoneTimes = const $CopyWithPlaceholder(),
    Object? bestEffortDistances = const $CopyWithPlaceholder(),
    Object? paceCurveStart = const $CopyWithPlaceholder(),
    Object? loadOrder = const $CopyWithPlaceholder(),
    Object? tizOrder = const $CopyWithPlaceholder(),
    Object? workoutOrder = const $CopyWithPlaceholder(),
    Object? intervalDisplay = const $CopyWithPlaceholder(),
    Object? defaultGearId = const $CopyWithPlaceholder(),
    Object? defaultIndoorGearId = const $CopyWithPlaceholder(),
    Object? extractWorkouts = const $CopyWithPlaceholder(),
    Object? showPauses = const $CopyWithPlaceholder(),
    Object? ignoreVelocity = const $CopyWithPlaceholder(),
    Object? defaultWorkoutTime = const $CopyWithPlaceholder(),
    Object? updateActivityNameFromWorkout = const $CopyWithPlaceholder(),
    Object? created = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? mmpModel = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
    Object? activityFieldIds = const $CopyWithPlaceholder(),
    Object? activityCharts = const $CopyWithPlaceholder(),
    Object? customFieldIds = const $CopyWithPlaceholder(),
    Object? customFieldValues = const $CopyWithPlaceholder(),
    Object? customZonesIds = const $CopyWithPlaceholder(),
    Object? calendarTileActivityPanelId = const $CopyWithPlaceholder(),
    Object? other = const $CopyWithPlaceholder(),
    Object? iseFTPSupported = const $CopyWithPlaceholder(),
    Object? useDistanceForIntervals = const $CopyWithPlaceholder(),
  }) {
    return SportSettings(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int?,
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      types: types == const $CopyWithPlaceholder()
          ? _value.types
          // ignore: cast_nullable_to_non_nullable
          : types as List<SportSettingsTypesEnum>?,
      warmupTime: warmupTime == const $CopyWithPlaceholder()
          ? _value.warmupTime
          // ignore: cast_nullable_to_non_nullable
          : warmupTime as int?,
      cooldownTime: cooldownTime == const $CopyWithPlaceholder()
          ? _value.cooldownTime
          // ignore: cast_nullable_to_non_nullable
          : cooldownTime as int?,
      ftp: ftp == const $CopyWithPlaceholder()
          ? _value.ftp
          // ignore: cast_nullable_to_non_nullable
          : ftp as int?,
      indoorFtp: indoorFtp == const $CopyWithPlaceholder()
          ? _value.indoorFtp
          // ignore: cast_nullable_to_non_nullable
          : indoorFtp as int?,
      wPrime: wPrime == const $CopyWithPlaceholder()
          ? _value.wPrime
          // ignore: cast_nullable_to_non_nullable
          : wPrime as int?,
      pMax: pMax == const $CopyWithPlaceholder()
          ? _value.pMax
          // ignore: cast_nullable_to_non_nullable
          : pMax as int?,
      powerZones: powerZones == const $CopyWithPlaceholder()
          ? _value.powerZones
          // ignore: cast_nullable_to_non_nullable
          : powerZones as List<int>?,
      sweetSpotMin: sweetSpotMin == const $CopyWithPlaceholder()
          ? _value.sweetSpotMin
          // ignore: cast_nullable_to_non_nullable
          : sweetSpotMin as int?,
      sweetSpotMax: sweetSpotMax == const $CopyWithPlaceholder()
          ? _value.sweetSpotMax
          // ignore: cast_nullable_to_non_nullable
          : sweetSpotMax as int?,
      powerSpikeThreshold: powerSpikeThreshold == const $CopyWithPlaceholder()
          ? _value.powerSpikeThreshold
          // ignore: cast_nullable_to_non_nullable
          : powerSpikeThreshold as int?,
      powerZoneNames: powerZoneNames == const $CopyWithPlaceholder()
          ? _value.powerZoneNames
          // ignore: cast_nullable_to_non_nullable
          : powerZoneNames as List<String>?,
      ftpEstMinSecs: ftpEstMinSecs == const $CopyWithPlaceholder()
          ? _value.ftpEstMinSecs
          // ignore: cast_nullable_to_non_nullable
          : ftpEstMinSecs as int?,
      useLapsForPowerIntervals:
          useLapsForPowerIntervals == const $CopyWithPlaceholder()
          ? _value.useLapsForPowerIntervals
          // ignore: cast_nullable_to_non_nullable
          : useLapsForPowerIntervals as bool?,
      keepAllLapsForPowerIntervals:
          keepAllLapsForPowerIntervals == const $CopyWithPlaceholder()
          ? _value.keepAllLapsForPowerIntervals
          // ignore: cast_nullable_to_non_nullable
          : keepAllLapsForPowerIntervals as bool?,
      powerIntervalsStartLocked:
          powerIntervalsStartLocked == const $CopyWithPlaceholder()
          ? _value.powerIntervalsStartLocked
          // ignore: cast_nullable_to_non_nullable
          : powerIntervalsStartLocked as bool?,
      afterKj0: afterKj0 == const $CopyWithPlaceholder()
          ? _value.afterKj0
          // ignore: cast_nullable_to_non_nullable
          : afterKj0 as int?,
      afterKj1: afterKj1 == const $CopyWithPlaceholder()
          ? _value.afterKj1
          // ignore: cast_nullable_to_non_nullable
          : afterKj1 as int?,
      powerField: powerField == const $CopyWithPlaceholder()
          ? _value.powerField
          // ignore: cast_nullable_to_non_nullable
          : powerField as String?,
      lthr: lthr == const $CopyWithPlaceholder()
          ? _value.lthr
          // ignore: cast_nullable_to_non_nullable
          : lthr as int?,
      maxHr: maxHr == const $CopyWithPlaceholder()
          ? _value.maxHr
          // ignore: cast_nullable_to_non_nullable
          : maxHr as int?,
      hrZones: hrZones == const $CopyWithPlaceholder()
          ? _value.hrZones
          // ignore: cast_nullable_to_non_nullable
          : hrZones as List<int>?,
      hrZoneNames: hrZoneNames == const $CopyWithPlaceholder()
          ? _value.hrZoneNames
          // ignore: cast_nullable_to_non_nullable
          : hrZoneNames as List<String>?,
      hrLoadType: hrLoadType == const $CopyWithPlaceholder()
          ? _value.hrLoadType
          // ignore: cast_nullable_to_non_nullable
          : hrLoadType as SportSettingsHrLoadTypeEnum?,
      hrrcMinPercent: hrrcMinPercent == const $CopyWithPlaceholder()
          ? _value.hrrcMinPercent
          // ignore: cast_nullable_to_non_nullable
          : hrrcMinPercent as double?,
      thresholdPace: thresholdPace == const $CopyWithPlaceholder()
          ? _value.thresholdPace
          // ignore: cast_nullable_to_non_nullable
          : thresholdPace as double?,
      paceUnits: paceUnits == const $CopyWithPlaceholder()
          ? _value.paceUnits
          // ignore: cast_nullable_to_non_nullable
          : paceUnits as SportSettingsPaceUnitsEnum?,
      paceZones: paceZones == const $CopyWithPlaceholder()
          ? _value.paceZones
          // ignore: cast_nullable_to_non_nullable
          : paceZones as List<double>?,
      paceZoneNames: paceZoneNames == const $CopyWithPlaceholder()
          ? _value.paceZoneNames
          // ignore: cast_nullable_to_non_nullable
          : paceZoneNames as List<String>?,
      paceLoadType: paceLoadType == const $CopyWithPlaceholder()
          ? _value.paceLoadType
          // ignore: cast_nullable_to_non_nullable
          : paceLoadType as SportSettingsPaceLoadTypeEnum?,
      gapModel: gapModel == const $CopyWithPlaceholder()
          ? _value.gapModel
          // ignore: cast_nullable_to_non_nullable
          : gapModel as SportSettingsGapModelEnum?,
      elevationCorrection: elevationCorrection == const $CopyWithPlaceholder()
          ? _value.elevationCorrection
          // ignore: cast_nullable_to_non_nullable
          : elevationCorrection as SportSettingsElevationCorrectionEnum?,
      useGapZoneTimes: useGapZoneTimes == const $CopyWithPlaceholder()
          ? _value.useGapZoneTimes
          // ignore: cast_nullable_to_non_nullable
          : useGapZoneTimes as bool?,
      bestEffortDistances: bestEffortDistances == const $CopyWithPlaceholder()
          ? _value.bestEffortDistances
          // ignore: cast_nullable_to_non_nullable
          : bestEffortDistances as List<double>?,
      paceCurveStart: paceCurveStart == const $CopyWithPlaceholder()
          ? _value.paceCurveStart
          // ignore: cast_nullable_to_non_nullable
          : paceCurveStart as double?,
      loadOrder: loadOrder == const $CopyWithPlaceholder()
          ? _value.loadOrder
          // ignore: cast_nullable_to_non_nullable
          : loadOrder as SportSettingsLoadOrderEnum?,
      tizOrder: tizOrder == const $CopyWithPlaceholder()
          ? _value.tizOrder
          // ignore: cast_nullable_to_non_nullable
          : tizOrder as SportSettingsTizOrderEnum?,
      workoutOrder: workoutOrder == const $CopyWithPlaceholder()
          ? _value.workoutOrder
          // ignore: cast_nullable_to_non_nullable
          : workoutOrder as SportSettingsWorkoutOrderEnum?,
      intervalDisplay: intervalDisplay == const $CopyWithPlaceholder()
          ? _value.intervalDisplay
          // ignore: cast_nullable_to_non_nullable
          : intervalDisplay as SportSettingsIntervalDisplayEnum?,
      defaultGearId: defaultGearId == const $CopyWithPlaceholder()
          ? _value.defaultGearId
          // ignore: cast_nullable_to_non_nullable
          : defaultGearId as String?,
      defaultIndoorGearId: defaultIndoorGearId == const $CopyWithPlaceholder()
          ? _value.defaultIndoorGearId
          // ignore: cast_nullable_to_non_nullable
          : defaultIndoorGearId as String?,
      extractWorkouts: extractWorkouts == const $CopyWithPlaceholder()
          ? _value.extractWorkouts
          // ignore: cast_nullable_to_non_nullable
          : extractWorkouts as bool?,
      showPauses: showPauses == const $CopyWithPlaceholder()
          ? _value.showPauses
          // ignore: cast_nullable_to_non_nullable
          : showPauses as int?,
      ignoreVelocity: ignoreVelocity == const $CopyWithPlaceholder()
          ? _value.ignoreVelocity
          // ignore: cast_nullable_to_non_nullable
          : ignoreVelocity as bool?,
      defaultWorkoutTime: defaultWorkoutTime == const $CopyWithPlaceholder()
          ? _value.defaultWorkoutTime
          // ignore: cast_nullable_to_non_nullable
          : defaultWorkoutTime as String?,
      updateActivityNameFromWorkout:
          updateActivityNameFromWorkout == const $CopyWithPlaceholder()
          ? _value.updateActivityNameFromWorkout
          // ignore: cast_nullable_to_non_nullable
          : updateActivityNameFromWorkout as bool?,
      created: created == const $CopyWithPlaceholder()
          ? _value.created
          // ignore: cast_nullable_to_non_nullable
          : created as DateTime?,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as DateTime?,
      mmpModel: mmpModel == const $CopyWithPlaceholder()
          ? _value.mmpModel
          // ignore: cast_nullable_to_non_nullable
          : mmpModel as PowerModel?,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as Display?,
      activityFieldIds: activityFieldIds == const $CopyWithPlaceholder()
          ? _value.activityFieldIds
          // ignore: cast_nullable_to_non_nullable
          : activityFieldIds as List<int>?,
      activityCharts: activityCharts == const $CopyWithPlaceholder()
          ? _value.activityCharts
          // ignore: cast_nullable_to_non_nullable
          : activityCharts as ActivityCharts?,
      customFieldIds: customFieldIds == const $CopyWithPlaceholder()
          ? _value.customFieldIds
          // ignore: cast_nullable_to_non_nullable
          : customFieldIds as List<int>?,
      customFieldValues: customFieldValues == const $CopyWithPlaceholder()
          ? _value.customFieldValues
          // ignore: cast_nullable_to_non_nullable
          : customFieldValues as Map<String, Object>?,
      customZonesIds: customZonesIds == const $CopyWithPlaceholder()
          ? _value.customZonesIds
          // ignore: cast_nullable_to_non_nullable
          : customZonesIds as List<int>?,
      calendarTileActivityPanelId:
          calendarTileActivityPanelId == const $CopyWithPlaceholder()
          ? _value.calendarTileActivityPanelId
          // ignore: cast_nullable_to_non_nullable
          : calendarTileActivityPanelId as int?,
      other: other == const $CopyWithPlaceholder()
          ? _value.other
          // ignore: cast_nullable_to_non_nullable
          : other as bool?,
      iseFTPSupported: iseFTPSupported == const $CopyWithPlaceholder()
          ? _value.iseFTPSupported
          // ignore: cast_nullable_to_non_nullable
          : iseFTPSupported as bool?,
      useDistanceForIntervals:
          useDistanceForIntervals == const $CopyWithPlaceholder()
          ? _value.useDistanceForIntervals
          // ignore: cast_nullable_to_non_nullable
          : useDistanceForIntervals as bool?,
    );
  }
}

extension $SportSettingsCopyWith on SportSettings {
  /// Returns a callable class that can be used as follows: `instanceOfSportSettings.copyWith(...)` or like so:`instanceOfSportSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SportSettingsCWProxy get copyWith => _$SportSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportSettings _$SportSettingsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SportSettings',
  json,
  ($checkedConvert) {
    final val = SportSettings(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      athleteId: $checkedConvert('athlete_id', (v) => v as String?),
      types: $checkedConvert(
        'types',
        (v) => (v as List<dynamic>?)
            ?.map((e) => $enumDecode(_$SportSettingsTypesEnumEnumMap, e))
            .toList(),
      ),
      warmupTime: $checkedConvert('warmup_time', (v) => (v as num?)?.toInt()),
      cooldownTime: $checkedConvert(
        'cooldown_time',
        (v) => (v as num?)?.toInt(),
      ),
      ftp: $checkedConvert('ftp', (v) => (v as num?)?.toInt()),
      indoorFtp: $checkedConvert('indoor_ftp', (v) => (v as num?)?.toInt()),
      wPrime: $checkedConvert('w_prime', (v) => (v as num?)?.toInt()),
      pMax: $checkedConvert('p_max', (v) => (v as num?)?.toInt()),
      powerZones: $checkedConvert(
        'power_zones',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      sweetSpotMin: $checkedConvert(
        'sweet_spot_min',
        (v) => (v as num?)?.toInt(),
      ),
      sweetSpotMax: $checkedConvert(
        'sweet_spot_max',
        (v) => (v as num?)?.toInt(),
      ),
      powerSpikeThreshold: $checkedConvert(
        'power_spike_threshold',
        (v) => (v as num?)?.toInt(),
      ),
      powerZoneNames: $checkedConvert(
        'power_zone_names',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      ftpEstMinSecs: $checkedConvert(
        'ftp_est_min_secs',
        (v) => (v as num?)?.toInt(),
      ),
      useLapsForPowerIntervals: $checkedConvert(
        'use_laps_for_power_intervals',
        (v) => v as bool?,
      ),
      keepAllLapsForPowerIntervals: $checkedConvert(
        'keep_all_laps_for_power_intervals',
        (v) => v as bool?,
      ),
      powerIntervalsStartLocked: $checkedConvert(
        'power_intervals_start_locked',
        (v) => v as bool?,
      ),
      afterKj0: $checkedConvert('after_kj0', (v) => (v as num?)?.toInt()),
      afterKj1: $checkedConvert('after_kj1', (v) => (v as num?)?.toInt()),
      powerField: $checkedConvert('power_field', (v) => v as String?),
      lthr: $checkedConvert('lthr', (v) => (v as num?)?.toInt()),
      maxHr: $checkedConvert('max_hr', (v) => (v as num?)?.toInt()),
      hrZones: $checkedConvert(
        'hr_zones',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      hrZoneNames: $checkedConvert(
        'hr_zone_names',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      hrLoadType: $checkedConvert(
        'hr_load_type',
        (v) => $enumDecodeNullable(_$SportSettingsHrLoadTypeEnumEnumMap, v),
      ),
      hrrcMinPercent: $checkedConvert(
        'hrrc_min_percent',
        (v) => (v as num?)?.toDouble(),
      ),
      thresholdPace: $checkedConvert(
        'threshold_pace',
        (v) => (v as num?)?.toDouble(),
      ),
      paceUnits: $checkedConvert(
        'pace_units',
        (v) => $enumDecodeNullable(_$SportSettingsPaceUnitsEnumEnumMap, v),
      ),
      paceZones: $checkedConvert(
        'pace_zones',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      paceZoneNames: $checkedConvert(
        'pace_zone_names',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      paceLoadType: $checkedConvert(
        'pace_load_type',
        (v) => $enumDecodeNullable(_$SportSettingsPaceLoadTypeEnumEnumMap, v),
      ),
      gapModel: $checkedConvert(
        'gap_model',
        (v) => $enumDecodeNullable(_$SportSettingsGapModelEnumEnumMap, v),
      ),
      elevationCorrection: $checkedConvert(
        'elevation_correction',
        (v) => $enumDecodeNullable(
          _$SportSettingsElevationCorrectionEnumEnumMap,
          v,
        ),
      ),
      useGapZoneTimes: $checkedConvert('use_gap_zone_times', (v) => v as bool?),
      bestEffortDistances: $checkedConvert(
        'best_effort_distances',
        (v) =>
            (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
      ),
      paceCurveStart: $checkedConvert(
        'pace_curve_start',
        (v) => (v as num?)?.toDouble(),
      ),
      loadOrder: $checkedConvert(
        'load_order',
        (v) => $enumDecodeNullable(_$SportSettingsLoadOrderEnumEnumMap, v),
      ),
      tizOrder: $checkedConvert(
        'tiz_order',
        (v) => $enumDecodeNullable(_$SportSettingsTizOrderEnumEnumMap, v),
      ),
      workoutOrder: $checkedConvert(
        'workout_order',
        (v) => $enumDecodeNullable(_$SportSettingsWorkoutOrderEnumEnumMap, v),
      ),
      intervalDisplay: $checkedConvert(
        'interval_display',
        (v) =>
            $enumDecodeNullable(_$SportSettingsIntervalDisplayEnumEnumMap, v),
      ),
      defaultGearId: $checkedConvert('default_gear_id', (v) => v as String?),
      defaultIndoorGearId: $checkedConvert(
        'default_indoor_gear_id',
        (v) => v as String?,
      ),
      extractWorkouts: $checkedConvert('extract_workouts', (v) => v as bool?),
      showPauses: $checkedConvert('show_pauses', (v) => (v as num?)?.toInt()),
      ignoreVelocity: $checkedConvert('ignore_velocity', (v) => v as bool?),
      defaultWorkoutTime: $checkedConvert(
        'default_workout_time',
        (v) => v as String?,
      ),
      updateActivityNameFromWorkout: $checkedConvert(
        'update_activity_name_from_workout',
        (v) => v as bool?,
      ),
      created: $checkedConvert(
        'created',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updated: $checkedConvert(
        'updated',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      mmpModel: $checkedConvert(
        'mmp_model',
        (v) =>
            v == null ? null : PowerModel.fromJson(v as Map<String, dynamic>),
      ),
      display: $checkedConvert(
        'display',
        (v) => v == null ? null : Display.fromJson(v as Map<String, dynamic>),
      ),
      activityFieldIds: $checkedConvert(
        'activity_field_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      activityCharts: $checkedConvert(
        'activity_charts',
        (v) => v == null
            ? null
            : ActivityCharts.fromJson(v as Map<String, dynamic>),
      ),
      customFieldIds: $checkedConvert(
        'custom_field_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      customFieldValues: $checkedConvert(
        'custom_field_values',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
      customZonesIds: $checkedConvert(
        'custom_zones_ids',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      calendarTileActivityPanelId: $checkedConvert(
        'calendar_tile_activity_panel_id',
        (v) => (v as num?)?.toInt(),
      ),
      other: $checkedConvert('other', (v) => v as bool?),
      iseFTPSupported: $checkedConvert('iseFTPSupported', (v) => v as bool?),
      useDistanceForIntervals: $checkedConvert(
        'use_distance_for_intervals',
        (v) => v as bool?,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'athleteId': 'athlete_id',
    'warmupTime': 'warmup_time',
    'cooldownTime': 'cooldown_time',
    'indoorFtp': 'indoor_ftp',
    'wPrime': 'w_prime',
    'pMax': 'p_max',
    'powerZones': 'power_zones',
    'sweetSpotMin': 'sweet_spot_min',
    'sweetSpotMax': 'sweet_spot_max',
    'powerSpikeThreshold': 'power_spike_threshold',
    'powerZoneNames': 'power_zone_names',
    'ftpEstMinSecs': 'ftp_est_min_secs',
    'useLapsForPowerIntervals': 'use_laps_for_power_intervals',
    'keepAllLapsForPowerIntervals': 'keep_all_laps_for_power_intervals',
    'powerIntervalsStartLocked': 'power_intervals_start_locked',
    'afterKj0': 'after_kj0',
    'afterKj1': 'after_kj1',
    'powerField': 'power_field',
    'maxHr': 'max_hr',
    'hrZones': 'hr_zones',
    'hrZoneNames': 'hr_zone_names',
    'hrLoadType': 'hr_load_type',
    'hrrcMinPercent': 'hrrc_min_percent',
    'thresholdPace': 'threshold_pace',
    'paceUnits': 'pace_units',
    'paceZones': 'pace_zones',
    'paceZoneNames': 'pace_zone_names',
    'paceLoadType': 'pace_load_type',
    'gapModel': 'gap_model',
    'elevationCorrection': 'elevation_correction',
    'useGapZoneTimes': 'use_gap_zone_times',
    'bestEffortDistances': 'best_effort_distances',
    'paceCurveStart': 'pace_curve_start',
    'loadOrder': 'load_order',
    'tizOrder': 'tiz_order',
    'workoutOrder': 'workout_order',
    'intervalDisplay': 'interval_display',
    'defaultGearId': 'default_gear_id',
    'defaultIndoorGearId': 'default_indoor_gear_id',
    'extractWorkouts': 'extract_workouts',
    'showPauses': 'show_pauses',
    'ignoreVelocity': 'ignore_velocity',
    'defaultWorkoutTime': 'default_workout_time',
    'updateActivityNameFromWorkout': 'update_activity_name_from_workout',
    'mmpModel': 'mmp_model',
    'activityFieldIds': 'activity_field_ids',
    'activityCharts': 'activity_charts',
    'customFieldIds': 'custom_field_ids',
    'customFieldValues': 'custom_field_values',
    'customZonesIds': 'custom_zones_ids',
    'calendarTileActivityPanelId': 'calendar_tile_activity_panel_id',
    'useDistanceForIntervals': 'use_distance_for_intervals',
  },
);

Map<String, dynamic> _$SportSettingsToJson(
  SportSettings instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'athlete_id': ?instance.athleteId,
  'types': ?instance.types
      ?.map((e) => _$SportSettingsTypesEnumEnumMap[e]!)
      .toList(),
  'warmup_time': ?instance.warmupTime,
  'cooldown_time': ?instance.cooldownTime,
  'ftp': ?instance.ftp,
  'indoor_ftp': ?instance.indoorFtp,
  'w_prime': ?instance.wPrime,
  'p_max': ?instance.pMax,
  'power_zones': ?instance.powerZones,
  'sweet_spot_min': ?instance.sweetSpotMin,
  'sweet_spot_max': ?instance.sweetSpotMax,
  'power_spike_threshold': ?instance.powerSpikeThreshold,
  'power_zone_names': ?instance.powerZoneNames,
  'ftp_est_min_secs': ?instance.ftpEstMinSecs,
  'use_laps_for_power_intervals': ?instance.useLapsForPowerIntervals,
  'keep_all_laps_for_power_intervals': ?instance.keepAllLapsForPowerIntervals,
  'power_intervals_start_locked': ?instance.powerIntervalsStartLocked,
  'after_kj0': ?instance.afterKj0,
  'after_kj1': ?instance.afterKj1,
  'power_field': ?instance.powerField,
  'lthr': ?instance.lthr,
  'max_hr': ?instance.maxHr,
  'hr_zones': ?instance.hrZones,
  'hr_zone_names': ?instance.hrZoneNames,
  'hr_load_type': ?_$SportSettingsHrLoadTypeEnumEnumMap[instance.hrLoadType],
  'hrrc_min_percent': ?instance.hrrcMinPercent,
  'threshold_pace': ?instance.thresholdPace,
  'pace_units': ?_$SportSettingsPaceUnitsEnumEnumMap[instance.paceUnits],
  'pace_zones': ?instance.paceZones,
  'pace_zone_names': ?instance.paceZoneNames,
  'pace_load_type':
      ?_$SportSettingsPaceLoadTypeEnumEnumMap[instance.paceLoadType],
  'gap_model': ?_$SportSettingsGapModelEnumEnumMap[instance.gapModel],
  'elevation_correction':
      ?_$SportSettingsElevationCorrectionEnumEnumMap[instance
          .elevationCorrection],
  'use_gap_zone_times': ?instance.useGapZoneTimes,
  'best_effort_distances': ?instance.bestEffortDistances,
  'pace_curve_start': ?instance.paceCurveStart,
  'load_order': ?_$SportSettingsLoadOrderEnumEnumMap[instance.loadOrder],
  'tiz_order': ?_$SportSettingsTizOrderEnumEnumMap[instance.tizOrder],
  'workout_order':
      ?_$SportSettingsWorkoutOrderEnumEnumMap[instance.workoutOrder],
  'interval_display':
      ?_$SportSettingsIntervalDisplayEnumEnumMap[instance.intervalDisplay],
  'default_gear_id': ?instance.defaultGearId,
  'default_indoor_gear_id': ?instance.defaultIndoorGearId,
  'extract_workouts': ?instance.extractWorkouts,
  'show_pauses': ?instance.showPauses,
  'ignore_velocity': ?instance.ignoreVelocity,
  'default_workout_time': ?instance.defaultWorkoutTime,
  'update_activity_name_from_workout': ?instance.updateActivityNameFromWorkout,
  'created': ?instance.created?.toIso8601String(),
  'updated': ?instance.updated?.toIso8601String(),
  'mmp_model': ?instance.mmpModel?.toJson(),
  'display': ?instance.display?.toJson(),
  'activity_field_ids': ?instance.activityFieldIds,
  'activity_charts': ?instance.activityCharts?.toJson(),
  'custom_field_ids': ?instance.customFieldIds,
  'custom_field_values': ?instance.customFieldValues,
  'custom_zones_ids': ?instance.customZonesIds,
  'calendar_tile_activity_panel_id': ?instance.calendarTileActivityPanelId,
  'other': ?instance.other,
  'iseFTPSupported': ?instance.iseFTPSupported,
  'use_distance_for_intervals': ?instance.useDistanceForIntervals,
};

const _$SportSettingsTypesEnumEnumMap = {
  SportSettingsTypesEnum.ride: 'Ride',
  SportSettingsTypesEnum.run: 'Run',
  SportSettingsTypesEnum.swim: 'Swim',
  SportSettingsTypesEnum.weightTraining: 'WeightTraining',
  SportSettingsTypesEnum.hike: 'Hike',
  SportSettingsTypesEnum.walk: 'Walk',
  SportSettingsTypesEnum.alpineSki: 'AlpineSki',
  SportSettingsTypesEnum.backcountrySki: 'BackcountrySki',
  SportSettingsTypesEnum.badminton: 'Badminton',
  SportSettingsTypesEnum.canoeing: 'Canoeing',
  SportSettingsTypesEnum.crossfit: 'Crossfit',
  SportSettingsTypesEnum.eBikeRide: 'EBikeRide',
  SportSettingsTypesEnum.eMountainBikeRide: 'EMountainBikeRide',
  SportSettingsTypesEnum.elliptical: 'Elliptical',
  SportSettingsTypesEnum.golf: 'Golf',
  SportSettingsTypesEnum.gravelRide: 'GravelRide',
  SportSettingsTypesEnum.trackRide: 'TrackRide',
  SportSettingsTypesEnum.handcycle: 'Handcycle',
  SportSettingsTypesEnum.highIntensityIntervalTraining:
      'HighIntensityIntervalTraining',
  SportSettingsTypesEnum.hockey: 'Hockey',
  SportSettingsTypesEnum.iceSkate: 'IceSkate',
  SportSettingsTypesEnum.inlineSkate: 'InlineSkate',
  SportSettingsTypesEnum.kayaking: 'Kayaking',
  SportSettingsTypesEnum.kitesurf: 'Kitesurf',
  SportSettingsTypesEnum.mountainBikeRide: 'MountainBikeRide',
  SportSettingsTypesEnum.cyclocross: 'Cyclocross',
  SportSettingsTypesEnum.nordicSki: 'NordicSki',
  SportSettingsTypesEnum.openWaterSwim: 'OpenWaterSwim',
  SportSettingsTypesEnum.padel: 'Padel',
  SportSettingsTypesEnum.pilates: 'Pilates',
  SportSettingsTypesEnum.pickleball: 'Pickleball',
  SportSettingsTypesEnum.racquetball: 'Racquetball',
  SportSettingsTypesEnum.rugby: 'Rugby',
  SportSettingsTypesEnum.rockClimbing: 'RockClimbing',
  SportSettingsTypesEnum.rollerSki: 'RollerSki',
  SportSettingsTypesEnum.rowing: 'Rowing',
  SportSettingsTypesEnum.sail: 'Sail',
  SportSettingsTypesEnum.skateboard: 'Skateboard',
  SportSettingsTypesEnum.snowboard: 'Snowboard',
  SportSettingsTypesEnum.snowshoe: 'Snowshoe',
  SportSettingsTypesEnum.soccer: 'Soccer',
  SportSettingsTypesEnum.squash: 'Squash',
  SportSettingsTypesEnum.stairStepper: 'StairStepper',
  SportSettingsTypesEnum.standUpPaddling: 'StandUpPaddling',
  SportSettingsTypesEnum.surfing: 'Surfing',
  SportSettingsTypesEnum.tableTennis: 'TableTennis',
  SportSettingsTypesEnum.tennis: 'Tennis',
  SportSettingsTypesEnum.trailRun: 'TrailRun',
  SportSettingsTypesEnum.transition: 'Transition',
  SportSettingsTypesEnum.velomobile: 'Velomobile',
  SportSettingsTypesEnum.virtualRide: 'VirtualRide',
  SportSettingsTypesEnum.virtualRow: 'VirtualRow',
  SportSettingsTypesEnum.virtualRun: 'VirtualRun',
  SportSettingsTypesEnum.virtualSki: 'VirtualSki',
  SportSettingsTypesEnum.waterSport: 'WaterSport',
  SportSettingsTypesEnum.wheelchair: 'Wheelchair',
  SportSettingsTypesEnum.windsurf: 'Windsurf',
  SportSettingsTypesEnum.workout: 'Workout',
  SportSettingsTypesEnum.yoga: 'Yoga',
  SportSettingsTypesEnum.other: 'Other',
};

const _$SportSettingsHrLoadTypeEnumEnumMap = {
  SportSettingsHrLoadTypeEnum.AVG_HR: 'AVG_HR',
  SportSettingsHrLoadTypeEnum.HR_ZONES: 'HR_ZONES',
  SportSettingsHrLoadTypeEnum.HRSS: 'HRSS',
};

const _$SportSettingsPaceUnitsEnumEnumMap = {
  SportSettingsPaceUnitsEnum.SECS_100M: 'SECS_100M',
  SportSettingsPaceUnitsEnum.SECS_100Y: 'SECS_100Y',
  SportSettingsPaceUnitsEnum.MINS_KM: 'MINS_KM',
  SportSettingsPaceUnitsEnum.MINS_MILE: 'MINS_MILE',
  SportSettingsPaceUnitsEnum.SECS_500M: 'SECS_500M',
  SportSettingsPaceUnitsEnum.SECS_400M: 'SECS_400M',
  SportSettingsPaceUnitsEnum.SECS_250M: 'SECS_250M',
  SportSettingsPaceUnitsEnum.NONE: 'NONE',
};

const _$SportSettingsPaceLoadTypeEnumEnumMap = {
  SportSettingsPaceLoadTypeEnum.SWIM: 'SWIM',
  SportSettingsPaceLoadTypeEnum.RUN: 'RUN',
};

const _$SportSettingsGapModelEnumEnumMap = {
  SportSettingsGapModelEnum.NONE: 'NONE',
  SportSettingsGapModelEnum.STRAVA_RUN: 'STRAVA_RUN',
};

const _$SportSettingsElevationCorrectionEnumEnumMap = {
  SportSettingsElevationCorrectionEnum.NO: 'NO',
  SportSettingsElevationCorrectionEnum.AUTO: 'AUTO',
  SportSettingsElevationCorrectionEnum.YES: 'YES',
};

const _$SportSettingsLoadOrderEnumEnumMap = {
  SportSettingsLoadOrderEnum.POWER_HR_PACE: 'POWER_HR_PACE',
  SportSettingsLoadOrderEnum.POWER_PACE_HR: 'POWER_PACE_HR',
  SportSettingsLoadOrderEnum.HR_POWER_PACE: 'HR_POWER_PACE',
  SportSettingsLoadOrderEnum.HR_PACE_POWER: 'HR_PACE_POWER',
  SportSettingsLoadOrderEnum.PACE_POWER_HR: 'PACE_POWER_HR',
  SportSettingsLoadOrderEnum.PACE_HR_POWER: 'PACE_HR_POWER',
};

const _$SportSettingsTizOrderEnumEnumMap = {
  SportSettingsTizOrderEnum.POWER_HR_PACE: 'POWER_HR_PACE',
  SportSettingsTizOrderEnum.POWER_PACE_HR: 'POWER_PACE_HR',
  SportSettingsTizOrderEnum.HR_POWER_PACE: 'HR_POWER_PACE',
  SportSettingsTizOrderEnum.HR_PACE_POWER: 'HR_PACE_POWER',
  SportSettingsTizOrderEnum.PACE_POWER_HR: 'PACE_POWER_HR',
  SportSettingsTizOrderEnum.PACE_HR_POWER: 'PACE_HR_POWER',
};

const _$SportSettingsWorkoutOrderEnumEnumMap = {
  SportSettingsWorkoutOrderEnum.POWER_HR_PACE: 'POWER_HR_PACE',
  SportSettingsWorkoutOrderEnum.POWER_PACE_HR: 'POWER_PACE_HR',
  SportSettingsWorkoutOrderEnum.HR_POWER_PACE: 'HR_POWER_PACE',
  SportSettingsWorkoutOrderEnum.HR_PACE_POWER: 'HR_PACE_POWER',
  SportSettingsWorkoutOrderEnum.PACE_POWER_HR: 'PACE_POWER_HR',
  SportSettingsWorkoutOrderEnum.PACE_HR_POWER: 'PACE_HR_POWER',
};

const _$SportSettingsIntervalDisplayEnumEnumMap = {
  SportSettingsIntervalDisplayEnum.POWER_HR_PACE: 'POWER_HR_PACE',
  SportSettingsIntervalDisplayEnum.POWER_PACE_HR: 'POWER_PACE_HR',
  SportSettingsIntervalDisplayEnum.HR_POWER_PACE: 'HR_POWER_PACE',
  SportSettingsIntervalDisplayEnum.HR_PACE_POWER: 'HR_PACE_POWER',
  SportSettingsIntervalDisplayEnum.PACE_POWER_HR: 'PACE_POWER_HR',
  SportSettingsIntervalDisplayEnum.PACE_HR_POWER: 'PACE_HR_POWER',
};
