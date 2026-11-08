//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_connections.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteConnections {
  /// Returns a new [AthleteConnections] instance.
  AthleteConnections({
    this.id,

    this.garminHealthConnected,

    this.garminTrainingConnected,

    this.polarConnected,

    this.suuntoConnected,

    this.corosConnected,

    this.concept2Connected,

    this.zeppConnected,

    this.huaweiConnected,

    this.wahooConnected,

    this.zwiftConnected,

    this.ouraConnected,

    this.whoopConnected,

    this.stravaConnected,

    this.dropboxConnected,

    this.hammerheadConnected,

    this.tpVirtualConnected,

    this.rouvyConnected,

    this.mywhooshConnected,

    this.biketerraConnected,

    this.tymewearConnected,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(
    name: r'garmin_health_connected',
    required: false,
    includeIfNull: false,
  )
  final bool? garminHealthConnected;

  @JsonKey(
    name: r'garmin_training_connected',
    required: false,
    includeIfNull: false,
  )
  final bool? garminTrainingConnected;

  @JsonKey(name: r'polar_connected', required: false, includeIfNull: false)
  final bool? polarConnected;

  @JsonKey(name: r'suunto_connected', required: false, includeIfNull: false)
  final bool? suuntoConnected;

  @JsonKey(name: r'coros_connected', required: false, includeIfNull: false)
  final bool? corosConnected;

  @JsonKey(name: r'concept2_connected', required: false, includeIfNull: false)
  final bool? concept2Connected;

  @JsonKey(name: r'zepp_connected', required: false, includeIfNull: false)
  final bool? zeppConnected;

  @JsonKey(name: r'huawei_connected', required: false, includeIfNull: false)
  final bool? huaweiConnected;

  @JsonKey(name: r'wahoo_connected', required: false, includeIfNull: false)
  final bool? wahooConnected;

  @JsonKey(name: r'zwift_connected', required: false, includeIfNull: false)
  final bool? zwiftConnected;

  @JsonKey(name: r'oura_connected', required: false, includeIfNull: false)
  final bool? ouraConnected;

  @JsonKey(name: r'whoop_connected', required: false, includeIfNull: false)
  final bool? whoopConnected;

  @JsonKey(name: r'strava_connected', required: false, includeIfNull: false)
  final bool? stravaConnected;

  @JsonKey(name: r'dropbox_connected', required: false, includeIfNull: false)
  final bool? dropboxConnected;

  @JsonKey(name: r'hammerhead_connected', required: false, includeIfNull: false)
  final bool? hammerheadConnected;

  @JsonKey(name: r'tp_virtual_connected', required: false, includeIfNull: false)
  final bool? tpVirtualConnected;

  @JsonKey(name: r'rouvy_connected', required: false, includeIfNull: false)
  final bool? rouvyConnected;

  @JsonKey(name: r'mywhoosh_connected', required: false, includeIfNull: false)
  final bool? mywhooshConnected;

  @JsonKey(name: r'biketerra_connected', required: false, includeIfNull: false)
  final bool? biketerraConnected;

  @JsonKey(name: r'tymewear_connected', required: false, includeIfNull: false)
  final bool? tymewearConnected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AthleteConnections &&
          other.id == id &&
          other.garminHealthConnected == garminHealthConnected &&
          other.garminTrainingConnected == garminTrainingConnected &&
          other.polarConnected == polarConnected &&
          other.suuntoConnected == suuntoConnected &&
          other.corosConnected == corosConnected &&
          other.concept2Connected == concept2Connected &&
          other.zeppConnected == zeppConnected &&
          other.huaweiConnected == huaweiConnected &&
          other.wahooConnected == wahooConnected &&
          other.zwiftConnected == zwiftConnected &&
          other.ouraConnected == ouraConnected &&
          other.whoopConnected == whoopConnected &&
          other.stravaConnected == stravaConnected &&
          other.dropboxConnected == dropboxConnected &&
          other.hammerheadConnected == hammerheadConnected &&
          other.tpVirtualConnected == tpVirtualConnected &&
          other.rouvyConnected == rouvyConnected &&
          other.mywhooshConnected == mywhooshConnected &&
          other.biketerraConnected == biketerraConnected &&
          other.tymewearConnected == tymewearConnected;

  @override
  int get hashCode =>
      id.hashCode +
      garminHealthConnected.hashCode +
      garminTrainingConnected.hashCode +
      polarConnected.hashCode +
      suuntoConnected.hashCode +
      corosConnected.hashCode +
      concept2Connected.hashCode +
      zeppConnected.hashCode +
      huaweiConnected.hashCode +
      wahooConnected.hashCode +
      zwiftConnected.hashCode +
      ouraConnected.hashCode +
      whoopConnected.hashCode +
      stravaConnected.hashCode +
      dropboxConnected.hashCode +
      hammerheadConnected.hashCode +
      tpVirtualConnected.hashCode +
      rouvyConnected.hashCode +
      mywhooshConnected.hashCode +
      biketerraConnected.hashCode +
      tymewearConnected.hashCode;

  factory AthleteConnections.fromJson(Map<String, dynamic> json) =>
      _$AthleteConnectionsFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteConnectionsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
