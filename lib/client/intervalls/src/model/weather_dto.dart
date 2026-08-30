//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/forecast.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_dto.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeatherDTO {
  /// Returns a new [WeatherDTO] instance.
  WeatherDTO({

     this.forecasts,
  });

  @JsonKey(
    
    name: r'forecasts',
    required: false,
    includeIfNull: false,
  )


  final List<Forecast>? forecasts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is WeatherDTO &&
      other.forecasts == forecasts;

    @override
    int get hashCode =>
        forecasts.hashCode;

  factory WeatherDTO.fromJson(Map<String, dynamic> json) => _$WeatherDTOFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

