//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'marker.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Marker {
  /// Returns a new [Marker] instance.
  Marker({
    this.lat,

    this.lng,

    this.name,

    this.description,

    this.icon,

    this.color,
  });

  @JsonKey(name: r'lat', required: false, includeIfNull: false)
  final double? lat;

  @JsonKey(name: r'lng', required: false, includeIfNull: false)
  final double? lng;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'icon', required: false, includeIfNull: false)
  final String? icon;

  @JsonKey(name: r'color', required: false, includeIfNull: false)
  final String? color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Marker &&
          other.lat == lat &&
          other.lng == lng &&
          other.name == name &&
          other.description == description &&
          other.icon == icon &&
          other.color == color;

  @override
  int get hashCode =>
      lat.hashCode +
      lng.hashCode +
      name.hashCode +
      description.hashCode +
      icon.hashCode +
      color.hashCode;

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);

  Map<String, dynamic> toJson() => _$MarkerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
