//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/pos.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_charts.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityCharts {
  /// Returns a new [ActivityCharts] instance.
  ActivityCharts({

     this.home,

     this.power,

     this.hr,

     this.pace,

     this.data,
  });

  @JsonKey(
    
    name: r'home',
    required: false,
    includeIfNull: false,
  )


  final List<Pos>? home;



  @JsonKey(
    
    name: r'power',
    required: false,
    includeIfNull: false,
  )


  final List<Pos>? power;



  @JsonKey(
    
    name: r'hr',
    required: false,
    includeIfNull: false,
  )


  final List<Pos>? hr;



  @JsonKey(
    
    name: r'pace',
    required: false,
    includeIfNull: false,
  )


  final List<Pos>? pace;



  @JsonKey(
    
    name: r'data',
    required: false,
    includeIfNull: false,
  )


  final List<Pos>? data;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityCharts &&
      other.home == home &&
      other.power == power &&
      other.hr == hr &&
      other.pace == pace &&
      other.data == data;

    @override
    int get hashCode =>
        home.hashCode +
        power.hashCode +
        hr.hashCode +
        pace.hashCode +
        data.hashCode;

  factory ActivityCharts.fromJson(Map<String, dynamic> json) => _$ActivityChartsFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityChartsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

