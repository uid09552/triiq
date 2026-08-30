//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/forecast.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_config.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeatherConfig {
  /// Returns a new [WeatherConfig] instance.
  WeatherConfig({

     this.forecasts,
  });

  @JsonKey(
    
    name: r'forecasts',
    required: false,
    includeIfNull: false,
  )


  final List<Forecast>? forecasts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeatherConfig &&
      other.forecasts == forecasts;

    @override
    int get hashCode =>
        forecasts.hashCode;

  factory WeatherConfig.fromJson(Map<String, dynamic> json) => _$WeatherConfigFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherConfigToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

