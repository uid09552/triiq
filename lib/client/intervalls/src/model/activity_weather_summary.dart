//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/wind_rose.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_weather_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityWeatherSummary {
  /// Returns a new [ActivityWeatherSummary] instance.
  ActivityWeatherSummary({

     this.startIndex,

     this.endIndex,

     this.startSecs,

     this.endSecs,

     this.movingTime,

     this.wholeActivity,

     this.windSpeed,

     this.windGust,

     this.apparentWindSpeed,

     this.apparentWindGust,

     this.averageTemp,

     this.minTemp,

     this.maxTemp,

     this.averageWeatherTemp,

     this.minWeatherTemp,

     this.maxWeatherTemp,

     this.averageFeelsLike,

     this.minFeelsLike,

     this.maxFeelsLike,

     this.averageWindSpeed,

     this.minWindSpeed,

     this.maxWindSpeed,

     this.averageWindGust,

     this.minWindGust,

     this.maxWindGust,

     this.prevailingWindDeg,

     this.averageYaw,

     this.headwindPercent,

     this.tailwindPercent,

     this.maxRain,

     this.maxShowers,

     this.maxSnow,

     this.averageClouds,

     this.description,
  });

  @JsonKey(
    
    name: r'start_index',
    required: false,
    includeIfNull: false,
  )


  final int? startIndex;



  @JsonKey(
    
    name: r'end_index',
    required: false,
    includeIfNull: false,
  )


  final int? endIndex;



  @JsonKey(
    
    name: r'start_secs',
    required: false,
    includeIfNull: false,
  )


  final int? startSecs;



  @JsonKey(
    
    name: r'end_secs',
    required: false,
    includeIfNull: false,
  )


  final int? endSecs;



  @JsonKey(
    
    name: r'moving_time',
    required: false,
    includeIfNull: false,
  )


  final int? movingTime;



  @JsonKey(
    
    name: r'whole_activity',
    required: false,
    includeIfNull: false,
  )


  final bool? wholeActivity;



  @JsonKey(
    
    name: r'wind_speed',
    required: false,
    includeIfNull: false,
  )


  final WindRose? windSpeed;



  @JsonKey(
    
    name: r'wind_gust',
    required: false,
    includeIfNull: false,
  )


  final WindRose? windGust;



  @JsonKey(
    
    name: r'apparent_wind_speed',
    required: false,
    includeIfNull: false,
  )


  final WindRose? apparentWindSpeed;



  @JsonKey(
    
    name: r'apparent_wind_gust',
    required: false,
    includeIfNull: false,
  )


  final WindRose? apparentWindGust;



  @JsonKey(
    
    name: r'average_temp',
    required: false,
    includeIfNull: false,
  )


  final double? averageTemp;



  @JsonKey(
    
    name: r'min_temp',
    required: false,
    includeIfNull: false,
  )


  final int? minTemp;



  @JsonKey(
    
    name: r'max_temp',
    required: false,
    includeIfNull: false,
  )


  final int? maxTemp;



  @JsonKey(
    
    name: r'average_weather_temp',
    required: false,
    includeIfNull: false,
  )


  final double? averageWeatherTemp;



  @JsonKey(
    
    name: r'min_weather_temp',
    required: false,
    includeIfNull: false,
  )


  final double? minWeatherTemp;



  @JsonKey(
    
    name: r'max_weather_temp',
    required: false,
    includeIfNull: false,
  )


  final double? maxWeatherTemp;



  @JsonKey(
    
    name: r'average_feels_like',
    required: false,
    includeIfNull: false,
  )


  final double? averageFeelsLike;



  @JsonKey(
    
    name: r'min_feels_like',
    required: false,
    includeIfNull: false,
  )


  final double? minFeelsLike;



  @JsonKey(
    
    name: r'max_feels_like',
    required: false,
    includeIfNull: false,
  )


  final double? maxFeelsLike;



  @JsonKey(
    
    name: r'average_wind_speed',
    required: false,
    includeIfNull: false,
  )


  final double? averageWindSpeed;



  @JsonKey(
    
    name: r'min_wind_speed',
    required: false,
    includeIfNull: false,
  )


  final double? minWindSpeed;



  @JsonKey(
    
    name: r'max_wind_speed',
    required: false,
    includeIfNull: false,
  )


  final double? maxWindSpeed;



  @JsonKey(
    
    name: r'average_wind_gust',
    required: false,
    includeIfNull: false,
  )


  final double? averageWindGust;



  @JsonKey(
    
    name: r'min_wind_gust',
    required: false,
    includeIfNull: false,
  )


  final double? minWindGust;



  @JsonKey(
    
    name: r'max_wind_gust',
    required: false,
    includeIfNull: false,
  )


  final double? maxWindGust;



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
    
    name: r'max_rain',
    required: false,
    includeIfNull: false,
  )


  final double? maxRain;



  @JsonKey(
    
    name: r'max_showers',
    required: false,
    includeIfNull: false,
  )


  final double? maxShowers;



  @JsonKey(
    
    name: r'max_snow',
    required: false,
    includeIfNull: false,
  )


  final double? maxSnow;



  @JsonKey(
    
    name: r'average_clouds',
    required: false,
    includeIfNull: false,
  )


  final int? averageClouds;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityWeatherSummary &&
      other.startIndex == startIndex &&
      other.endIndex == endIndex &&
      other.startSecs == startSecs &&
      other.endSecs == endSecs &&
      other.movingTime == movingTime &&
      other.wholeActivity == wholeActivity &&
      other.windSpeed == windSpeed &&
      other.windGust == windGust &&
      other.apparentWindSpeed == apparentWindSpeed &&
      other.apparentWindGust == apparentWindGust &&
      other.averageTemp == averageTemp &&
      other.minTemp == minTemp &&
      other.maxTemp == maxTemp &&
      other.averageWeatherTemp == averageWeatherTemp &&
      other.minWeatherTemp == minWeatherTemp &&
      other.maxWeatherTemp == maxWeatherTemp &&
      other.averageFeelsLike == averageFeelsLike &&
      other.minFeelsLike == minFeelsLike &&
      other.maxFeelsLike == maxFeelsLike &&
      other.averageWindSpeed == averageWindSpeed &&
      other.minWindSpeed == minWindSpeed &&
      other.maxWindSpeed == maxWindSpeed &&
      other.averageWindGust == averageWindGust &&
      other.minWindGust == minWindGust &&
      other.maxWindGust == maxWindGust &&
      other.prevailingWindDeg == prevailingWindDeg &&
      other.averageYaw == averageYaw &&
      other.headwindPercent == headwindPercent &&
      other.tailwindPercent == tailwindPercent &&
      other.maxRain == maxRain &&
      other.maxShowers == maxShowers &&
      other.maxSnow == maxSnow &&
      other.averageClouds == averageClouds &&
      other.description == description;

    @override
    int get hashCode =>
        startIndex.hashCode +
        endIndex.hashCode +
        startSecs.hashCode +
        endSecs.hashCode +
        movingTime.hashCode +
        wholeActivity.hashCode +
        windSpeed.hashCode +
        windGust.hashCode +
        apparentWindSpeed.hashCode +
        apparentWindGust.hashCode +
        averageTemp.hashCode +
        minTemp.hashCode +
        maxTemp.hashCode +
        averageWeatherTemp.hashCode +
        minWeatherTemp.hashCode +
        maxWeatherTemp.hashCode +
        averageFeelsLike.hashCode +
        minFeelsLike.hashCode +
        maxFeelsLike.hashCode +
        averageWindSpeed.hashCode +
        minWindSpeed.hashCode +
        maxWindSpeed.hashCode +
        averageWindGust.hashCode +
        minWindGust.hashCode +
        maxWindGust.hashCode +
        prevailingWindDeg.hashCode +
        averageYaw.hashCode +
        headwindPercent.hashCode +
        tailwindPercent.hashCode +
        maxRain.hashCode +
        maxShowers.hashCode +
        maxSnow.hashCode +
        averageClouds.hashCode +
        description.hashCode;

  factory ActivityWeatherSummary.fromJson(Map<String, dynamic> json) => _$ActivityWeatherSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityWeatherSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

