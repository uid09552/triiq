//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/time.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_point.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeatherPoint {
  /// Returns a new [WeatherPoint] instance.
  WeatherPoint({this.latitude, this.longitude, this.times});

  @JsonKey(name: r'latitude', required: false, includeIfNull: false)
  final double? latitude;

  @JsonKey(name: r'longitude', required: false, includeIfNull: false)
  final double? longitude;

  @JsonKey(name: r'times', required: false, includeIfNull: false)
  final List<Time>? times;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherPoint &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.times == times;

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode + times.hashCode;

  factory WeatherPoint.fromJson(Map<String, dynamic> json) =>
      _$WeatherPointFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
