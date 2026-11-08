//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'display.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Display {
  /// Returns a new [Display] instance.
  Display({
    this.colorScheme,

    this.lowIntensity,

    this.highIntensity,

    this.lowLoad,

    this.highLoad,

    this.usePairedWorkoutColor,

    this.ignoreWorkoutColors,

    this.showAverageHR,

    this.showNormalizedWatts,

    this.showLoad,

    this.showWork,

    this.showWorkAboveFTP,

    this.showWeightLifted,

    this.showAveragePower,

    this.showRPE,

    this.showFeel,

    this.showPace,

    this.showGAP,

    this.showIntensity,

    this.showName,

    this.showIntervals,

    this.showSkylineChart,

    this.showPairedWorkoutChart,

    this.showDescription,

    this.showStartTime,

    this.preciseDistance,

    this.shrinkWarmup,

    this.shrinkCooldown,

    this.shrinkCommute,

    this.color,

    this.color2,
  });

  @JsonKey(name: r'colorScheme', required: false, includeIfNull: false)
  final String? colorScheme;

  @JsonKey(name: r'lowIntensity', required: false, includeIfNull: false)
  final int? lowIntensity;

  @JsonKey(name: r'highIntensity', required: false, includeIfNull: false)
  final int? highIntensity;

  @JsonKey(name: r'lowLoad', required: false, includeIfNull: false)
  final int? lowLoad;

  @JsonKey(name: r'highLoad', required: false, includeIfNull: false)
  final int? highLoad;

  @JsonKey(
    name: r'usePairedWorkoutColor',
    required: false,
    includeIfNull: false,
  )
  final bool? usePairedWorkoutColor;

  @JsonKey(name: r'ignoreWorkoutColors', required: false, includeIfNull: false)
  final bool? ignoreWorkoutColors;

  @JsonKey(name: r'showAverageHR', required: false, includeIfNull: false)
  final bool? showAverageHR;

  @JsonKey(name: r'showNormalizedWatts', required: false, includeIfNull: false)
  final bool? showNormalizedWatts;

  @JsonKey(name: r'showLoad', required: false, includeIfNull: false)
  final bool? showLoad;

  @JsonKey(name: r'showWork', required: false, includeIfNull: false)
  final bool? showWork;

  @JsonKey(name: r'showWorkAboveFTP', required: false, includeIfNull: false)
  final bool? showWorkAboveFTP;

  @JsonKey(name: r'showWeightLifted', required: false, includeIfNull: false)
  final bool? showWeightLifted;

  @JsonKey(name: r'showAveragePower', required: false, includeIfNull: false)
  final bool? showAveragePower;

  @JsonKey(name: r'showRPE', required: false, includeIfNull: false)
  final bool? showRPE;

  @JsonKey(name: r'showFeel', required: false, includeIfNull: false)
  final bool? showFeel;

  @JsonKey(name: r'showPace', required: false, includeIfNull: false)
  final bool? showPace;

  @JsonKey(name: r'showGAP', required: false, includeIfNull: false)
  final bool? showGAP;

  @JsonKey(name: r'showIntensity', required: false, includeIfNull: false)
  final bool? showIntensity;

  @JsonKey(name: r'showName', required: false, includeIfNull: false)
  final bool? showName;

  @JsonKey(name: r'showIntervals', required: false, includeIfNull: false)
  final bool? showIntervals;

  @JsonKey(name: r'showSkylineChart', required: false, includeIfNull: false)
  final bool? showSkylineChart;

  @JsonKey(
    name: r'showPairedWorkoutChart',
    required: false,
    includeIfNull: false,
  )
  final bool? showPairedWorkoutChart;

  @JsonKey(name: r'showDescription', required: false, includeIfNull: false)
  final bool? showDescription;

  @JsonKey(name: r'showStartTime', required: false, includeIfNull: false)
  final bool? showStartTime;

  @JsonKey(name: r'preciseDistance', required: false, includeIfNull: false)
  final bool? preciseDistance;

  @JsonKey(name: r'shrinkWarmup', required: false, includeIfNull: false)
  final bool? shrinkWarmup;

  @JsonKey(name: r'shrinkCooldown', required: false, includeIfNull: false)
  final bool? shrinkCooldown;

  @JsonKey(name: r'shrinkCommute', required: false, includeIfNull: false)
  final bool? shrinkCommute;

  @JsonKey(name: r'color', required: false, includeIfNull: false)
  final String? color;

  @JsonKey(name: r'color2', required: false, includeIfNull: false)
  final String? color2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Display &&
          other.colorScheme == colorScheme &&
          other.lowIntensity == lowIntensity &&
          other.highIntensity == highIntensity &&
          other.lowLoad == lowLoad &&
          other.highLoad == highLoad &&
          other.usePairedWorkoutColor == usePairedWorkoutColor &&
          other.ignoreWorkoutColors == ignoreWorkoutColors &&
          other.showAverageHR == showAverageHR &&
          other.showNormalizedWatts == showNormalizedWatts &&
          other.showLoad == showLoad &&
          other.showWork == showWork &&
          other.showWorkAboveFTP == showWorkAboveFTP &&
          other.showWeightLifted == showWeightLifted &&
          other.showAveragePower == showAveragePower &&
          other.showRPE == showRPE &&
          other.showFeel == showFeel &&
          other.showPace == showPace &&
          other.showGAP == showGAP &&
          other.showIntensity == showIntensity &&
          other.showName == showName &&
          other.showIntervals == showIntervals &&
          other.showSkylineChart == showSkylineChart &&
          other.showPairedWorkoutChart == showPairedWorkoutChart &&
          other.showDescription == showDescription &&
          other.showStartTime == showStartTime &&
          other.preciseDistance == preciseDistance &&
          other.shrinkWarmup == shrinkWarmup &&
          other.shrinkCooldown == shrinkCooldown &&
          other.shrinkCommute == shrinkCommute &&
          other.color == color &&
          other.color2 == color2;

  @override
  int get hashCode =>
      colorScheme.hashCode +
      lowIntensity.hashCode +
      highIntensity.hashCode +
      lowLoad.hashCode +
      highLoad.hashCode +
      usePairedWorkoutColor.hashCode +
      ignoreWorkoutColors.hashCode +
      showAverageHR.hashCode +
      showNormalizedWatts.hashCode +
      showLoad.hashCode +
      showWork.hashCode +
      showWorkAboveFTP.hashCode +
      showWeightLifted.hashCode +
      showAveragePower.hashCode +
      showRPE.hashCode +
      showFeel.hashCode +
      showPace.hashCode +
      showGAP.hashCode +
      showIntensity.hashCode +
      showName.hashCode +
      showIntervals.hashCode +
      showSkylineChart.hashCode +
      showPairedWorkoutChart.hashCode +
      showDescription.hashCode +
      showStartTime.hashCode +
      preciseDistance.hashCode +
      shrinkWarmup.hashCode +
      shrinkCooldown.hashCode +
      shrinkCommute.hashCode +
      color.hashCode +
      color2.hashCode;

  factory Display.fromJson(Map<String, dynamic> json) =>
      _$DisplayFromJson(json);

  Map<String, dynamic> toJson() => _$DisplayToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
