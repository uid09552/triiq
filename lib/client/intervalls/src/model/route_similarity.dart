//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/athlete_route.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_similarity.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RouteSimilarity {
  /// Returns a new [RouteSimilarity] instance.
  RouteSimilarity({

     this.route,

     this.routeDistance,

     this.routeActivityCount,

     this.other,

     this.otherDistance,

     this.otherActivityCount,

     this.similarity,

     this.bounds,
  });

  @JsonKey(
    
    name: r'route',
    required: false,
    includeIfNull: false,
  )


  final AthleteRoute? route;



  @JsonKey(
    
    name: r'route_distance',
    required: false,
    includeIfNull: false,
  )


  final double? routeDistance;



  @JsonKey(
    
    name: r'route_activity_count',
    required: false,
    includeIfNull: false,
  )


  final int? routeActivityCount;



  @JsonKey(
    
    name: r'other',
    required: false,
    includeIfNull: false,
  )


  final AthleteRoute? other;



  @JsonKey(
    
    name: r'other_distance',
    required: false,
    includeIfNull: false,
  )


  final double? otherDistance;



  @JsonKey(
    
    name: r'other_activity_count',
    required: false,
    includeIfNull: false,
  )


  final int? otherActivityCount;



  @JsonKey(
    
    name: r'similarity',
    required: false,
    includeIfNull: false,
  )


  final double? similarity;



  @JsonKey(
    
    name: r'bounds',
    required: false,
    includeIfNull: false,
  )


  final List<List<double>>? bounds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RouteSimilarity &&
      other.route == route &&
      other.routeDistance == routeDistance &&
      other.routeActivityCount == routeActivityCount &&
      other.other == other &&
      other.otherDistance == otherDistance &&
      other.otherActivityCount == otherActivityCount &&
      other.similarity == similarity &&
      other.bounds == bounds;

    @override
    int get hashCode =>
        route.hashCode +
        routeDistance.hashCode +
        routeActivityCount.hashCode +
        other.hashCode +
        otherDistance.hashCode +
        otherActivityCount.hashCode +
        similarity.hashCode +
        bounds.hashCode;

  factory RouteSimilarity.fromJson(Map<String, dynamic> json) => _$RouteSimilarityFromJson(json);

  Map<String, dynamic> toJson() => _$RouteSimilarityToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

