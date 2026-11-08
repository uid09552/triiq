//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forecast.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Forecast {
  /// Returns a new [Forecast] instance.
  Forecast({
    this.id,

    this.provider,

    this.location,

    this.label,

    this.lat,

    this.lon,

    this.enabled,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'provider', required: false, includeIfNull: false)
  final ForecastProviderEnum? provider;

  @JsonKey(name: r'location', required: false, includeIfNull: false)
  final String? location;

  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  @JsonKey(name: r'lat', required: false, includeIfNull: false)
  final double? lat;

  @JsonKey(name: r'lon', required: false, includeIfNull: false)
  final double? lon;

  @JsonKey(name: r'enabled', required: false, includeIfNull: false)
  final bool? enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Forecast &&
          other.id == id &&
          other.provider == provider &&
          other.location == location &&
          other.label == label &&
          other.lat == lat &&
          other.lon == lon &&
          other.enabled == enabled;

  @override
  int get hashCode =>
      id.hashCode +
      provider.hashCode +
      location.hashCode +
      label.hashCode +
      lat.hashCode +
      lon.hashCode +
      enabled.hashCode;

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ForecastProviderEnum {
  @JsonValue(r'OPEN_WEATHER')
  OPEN_WEATHER(r'OPEN_WEATHER');

  const ForecastProviderEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
