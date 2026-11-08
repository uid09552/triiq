//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/anomaly.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_stream.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityStream {
  /// Returns a new [ActivityStream] instance.
  ActivityStream({
    this.type,

    this.name,

    this.data,

    this.data2,

    this.valueTypeIsArray,

    this.anomalies,

    this.custom,

    this.allNull,
  });

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final String? type;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Object? data;

  @JsonKey(name: r'data2', required: false, includeIfNull: false)
  final Object? data2;

  @JsonKey(name: r'valueTypeIsArray', required: false, includeIfNull: false)
  final bool? valueTypeIsArray;

  @JsonKey(name: r'anomalies', required: false, includeIfNull: false)
  final List<Anomaly>? anomalies;

  @JsonKey(name: r'custom', required: false, includeIfNull: false)
  final bool? custom;

  @JsonKey(name: r'allNull', required: false, includeIfNull: false)
  final bool? allNull;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityStream &&
          other.type == type &&
          other.name == name &&
          other.data == data &&
          other.data2 == data2 &&
          other.valueTypeIsArray == valueTypeIsArray &&
          other.anomalies == anomalies &&
          other.custom == custom &&
          other.allNull == allNull;

  @override
  int get hashCode =>
      type.hashCode +
      name.hashCode +
      data.hashCode +
      data2.hashCode +
      valueTypeIsArray.hashCode +
      anomalies.hashCode +
      custom.hashCode +
      allNull.hashCode;

  factory ActivityStream.fromJson(Map<String, dynamic> json) =>
      _$ActivityStreamFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityStreamToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
