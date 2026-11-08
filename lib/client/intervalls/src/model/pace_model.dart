//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pace_model.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaceModel {
  /// Returns a new [PaceModel] instance.
  PaceModel({
    this.type,

    this.criticalSpeed,

    this.dPrime,

    this.r2,

    this.inputPointIndexes,
  });

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final PaceModelTypeEnum? type;

  @JsonKey(name: r'criticalSpeed', required: false, includeIfNull: false)
  final double? criticalSpeed;

  @JsonKey(name: r'dPrime', required: false, includeIfNull: false)
  final double? dPrime;

  @JsonKey(name: r'r2', required: false, includeIfNull: false)
  final double? r2;

  @JsonKey(name: r'inputPointIndexes', required: false, includeIfNull: false)
  final List<int>? inputPointIndexes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaceModel &&
          other.type == type &&
          other.criticalSpeed == criticalSpeed &&
          other.dPrime == dPrime &&
          other.r2 == r2 &&
          other.inputPointIndexes == inputPointIndexes;

  @override
  int get hashCode =>
      type.hashCode +
      criticalSpeed.hashCode +
      dPrime.hashCode +
      r2.hashCode +
      inputPointIndexes.hashCode;

  factory PaceModel.fromJson(Map<String, dynamic> json) =>
      _$PaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaceModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PaceModelTypeEnum {
  @JsonValue(r'CS')
  CS(r'CS');

  const PaceModelTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
