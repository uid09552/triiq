//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pace_distances_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaceDistancesDTO {
  /// Returns a new [PaceDistancesDTO] instance.
  PaceDistancesDTO({this.distances, this.defaults});

  @JsonKey(name: r'distances', required: false, includeIfNull: false)
  final List<double>? distances;

  @JsonKey(name: r'defaults', required: false, includeIfNull: false)
  final List<double>? defaults;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaceDistancesDTO &&
          other.distances == distances &&
          other.defaults == defaults;

  @override
  int get hashCode => distances.hashCode + defaults.hashCode;

  factory PaceDistancesDTO.fromJson(Map<String, dynamic> json) =>
      _$PaceDistancesDTOFromJson(json);

  Map<String, dynamic> toJson() => _$PaceDistancesDTOToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
