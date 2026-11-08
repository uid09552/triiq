//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bucket.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Bucket {
  /// Returns a new [Bucket] instance.
  Bucket({
    this.start,

    this.secs,

    this.movingSecs,

    this.watts,

    this.hr,

    this.cadence,
  });

  @JsonKey(name: r'start', required: false, includeIfNull: false)
  final int? start;

  @JsonKey(name: r'secs', required: false, includeIfNull: false)
  final int? secs;

  @JsonKey(name: r'movingSecs', required: false, includeIfNull: false)
  final int? movingSecs;

  @JsonKey(name: r'watts', required: false, includeIfNull: false)
  final double? watts;

  @JsonKey(name: r'hr', required: false, includeIfNull: false)
  final double? hr;

  @JsonKey(name: r'cadence', required: false, includeIfNull: false)
  final int? cadence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bucket &&
          other.start == start &&
          other.secs == secs &&
          other.movingSecs == movingSecs &&
          other.watts == watts &&
          other.hr == hr &&
          other.cadence == cadence;

  @override
  int get hashCode =>
      start.hashCode +
      secs.hashCode +
      movingSecs.hashCode +
      watts.hashCode +
      hr.hashCode +
      cadence.hashCode;

  factory Bucket.fromJson(Map<String, dynamic> json) => _$BucketFromJson(json);

  Map<String, dynamic> toJson() => _$BucketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
