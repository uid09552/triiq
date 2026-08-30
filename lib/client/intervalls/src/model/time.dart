//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Time {
  /// Returns a new [Time] instance.
  Time({

     this.startSecs,

     this.endSecs,

     this.index,

     this.temp,

     this.feelsLike,

     this.humidity,

     this.windSpeed,

     this.windDeg,

     this.windGust,

     this.rain,

     this.showers,

     this.snow,

     this.clouds,

     this.pressure,

     this.weatherCode,
  });

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
    
    name: r'index',
    required: false,
    includeIfNull: false,
  )


  final int? index;



  @JsonKey(
    
    name: r'temp',
    required: false,
    includeIfNull: false,
  )


  final double? temp;



  @JsonKey(
    
    name: r'feels_like',
    required: false,
    includeIfNull: false,
  )


  final double? feelsLike;



  @JsonKey(
    
    name: r'humidity',
    required: false,
    includeIfNull: false,
  )


  final int? humidity;



  @JsonKey(
    
    name: r'wind_speed',
    required: false,
    includeIfNull: false,
  )


  final double? windSpeed;



  @JsonKey(
    
    name: r'wind_deg',
    required: false,
    includeIfNull: false,
  )


  final int? windDeg;



  @JsonKey(
    
    name: r'wind_gust',
    required: false,
    includeIfNull: false,
  )


  final double? windGust;



  @JsonKey(
    
    name: r'rain',
    required: false,
    includeIfNull: false,
  )


  final double? rain;



  @JsonKey(
    
    name: r'showers',
    required: false,
    includeIfNull: false,
  )


  final double? showers;



  @JsonKey(
    
    name: r'snow',
    required: false,
    includeIfNull: false,
  )


  final double? snow;



  @JsonKey(
    
    name: r'clouds',
    required: false,
    includeIfNull: false,
  )


  final int? clouds;



  @JsonKey(
    
    name: r'pressure',
    required: false,
    includeIfNull: false,
  )


  final double? pressure;



  @JsonKey(
    
    name: r'weather_code',
    required: false,
    includeIfNull: false,
  )


  final int? weatherCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Time &&
      other.startSecs == startSecs &&
      other.endSecs == endSecs &&
      other.index == index &&
      other.temp == temp &&
      other.feelsLike == feelsLike &&
      other.humidity == humidity &&
      other.windSpeed == windSpeed &&
      other.windDeg == windDeg &&
      other.windGust == windGust &&
      other.rain == rain &&
      other.showers == showers &&
      other.snow == snow &&
      other.clouds == clouds &&
      other.pressure == pressure &&
      other.weatherCode == weatherCode;

    @override
    int get hashCode =>
        startSecs.hashCode +
        endSecs.hashCode +
        index.hashCode +
        temp.hashCode +
        feelsLike.hashCode +
        humidity.hashCode +
        windSpeed.hashCode +
        windDeg.hashCode +
        windGust.hashCode +
        rain.hashCode +
        showers.hashCode +
        snow.hashCode +
        clouds.hashCode +
        pressure.hashCode +
        weatherCode.hashCode;

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);

  Map<String, dynamic> toJson() => _$TimeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

