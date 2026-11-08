//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'power_model.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PowerModel {
  /// Returns a new [PowerModel] instance.
  PowerModel({
    this.type,

    this.criticalPower,

    this.wPrime,

    this.pMax,

    this.inputPointIndexes,

    this.ftp,
  });

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final PowerModelTypeEnum? type;

  @JsonKey(name: r'criticalPower', required: false, includeIfNull: false)
  final int? criticalPower;

  @JsonKey(name: r'wPrime', required: false, includeIfNull: false)
  final int? wPrime;

  @JsonKey(name: r'pMax', required: false, includeIfNull: false)
  final int? pMax;

  @JsonKey(name: r'inputPointIndexes', required: false, includeIfNull: false)
  final List<int>? inputPointIndexes;

  @JsonKey(name: r'ftp', required: false, includeIfNull: false)
  final int? ftp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerModel &&
          other.type == type &&
          other.criticalPower == criticalPower &&
          other.wPrime == wPrime &&
          other.pMax == pMax &&
          other.inputPointIndexes == inputPointIndexes &&
          other.ftp == ftp;

  @override
  int get hashCode =>
      type.hashCode +
      criticalPower.hashCode +
      wPrime.hashCode +
      pMax.hashCode +
      inputPointIndexes.hashCode +
      ftp.hashCode;

  factory PowerModel.fromJson(Map<String, dynamic> json) =>
      _$PowerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PowerModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PowerModelTypeEnum {
  @JsonValue(r'MS_2P')
  MS_2P(r'MS_2P'),
  @JsonValue(r'MORTON_3P')
  MORTON_3P(r'MORTON_3P'),
  @JsonValue(r'FFT_CURVES')
  FFT_CURVES(r'FFT_CURVES'),
  @JsonValue(r'ECP')
  ECP(r'ECP');

  const PowerModelTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
