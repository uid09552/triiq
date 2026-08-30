//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_weather.dart';
import 'package:triiq/client/intervalls/src/model/athlete_route.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_data.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MapData {
  /// Returns a new [MapData] instance.
  MapData({

     this.bounds,

     this.latlngs,

     this.route,

     this.weather,
  });

  @JsonKey(
    
    name: r'bounds',
    required: false,
    includeIfNull: false,
  )


  final List<List<double>>? bounds;



  @JsonKey(
    
    name: r'latlngs',
    required: false,
    includeIfNull: false,
  )


  final List<List<double>>? latlngs;



  @JsonKey(
    
    name: r'route',
    required: false,
    includeIfNull: false,
  )


  final AthleteRoute? route;



  @JsonKey(
    
    name: r'weather',
    required: false,
    includeIfNull: false,
  )


  final ActivityWeather? weather;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MapData &&
      other.bounds == bounds &&
      other.latlngs == latlngs &&
      other.route == route &&
      other.weather == weather;

    @override
    int get hashCode =>
        bounds.hashCode +
        latlngs.hashCode +
        route.hashCode +
        weather.hashCode;

  factory MapData.fromJson(Map<String, dynamic> json) => _$MapDataFromJson(json);

  Map<String, dynamic> toJson() => _$MapDataToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

