//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plot.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Plot {
  /// Returns a new [Plot] instance.
  Plot({this.maxBpm, this.minBpm, this.secs, this.cumulativeSecs});

  @JsonKey(name: r'max_bpm', required: false, includeIfNull: false)
  final int? maxBpm;

  @JsonKey(name: r'min_bpm', required: false, includeIfNull: false)
  final int? minBpm;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final List<int>? secs;

  @JsonKey(name: r'cumulative_secs', required: false, includeIfNull: false)
  final List<int>? cumulativeSecs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plot &&
          other.maxBpm == maxBpm &&
          other.minBpm == minBpm &&
          other.secs == secs &&
          other.cumulativeSecs == cumulativeSecs;

  @override
  int get hashCode =>
      maxBpm.hashCode +
      minBpm.hashCode +
      secs.hashCode +
      cumulativeSecs.hashCode;

  factory Plot.fromJson(Map<String, dynamic> json) => _$PlotFromJson(json);

  Map<String, dynamic> toJson() => _$PlotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
