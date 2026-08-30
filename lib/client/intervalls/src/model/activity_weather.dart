//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/weather_point.dart';
import 'package:triiq/client/intervalls/src/model/closest.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_weather.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityWeather {
  /// Returns a new [ActivityWeather] instance.
  ActivityWeather({

     this.points,

     this.closestPoints,
  });

  @JsonKey(
    
    name: r'points',
    required: false,
    includeIfNull: false,
  )


  final List<WeatherPoint>? points;



  @JsonKey(
    
    name: r'closest_points',
    required: false,
    includeIfNull: false,
  )


  final List<Closest>? closestPoints;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityWeather &&
      other.points == points &&
      other.closestPoints == closestPoints;

    @override
    int get hashCode =>
        points.hashCode +
        closestPoints.hashCode;

  factory ActivityWeather.fromJson(Map<String, dynamic> json) => _$ActivityWeatherFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityWeatherToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

