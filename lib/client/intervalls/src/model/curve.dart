//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'curve.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Curve {
  /// Returns a new [Curve] instance.
  Curve({this.id, this.coefficients, this.r2});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'coefficients', required: false, includeIfNull: false)
  final List<double>? coefficients;

  @JsonKey(name: r'r2', required: false, includeIfNull: false)
  final double? r2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Curve &&
          other.id == id &&
          other.coefficients == coefficients &&
          other.r2 == r2;

  @override
  int get hashCode => id.hashCode + coefficients.hashCode + r2.hashCode;

  factory Curve.fromJson(Map<String, dynamic> json) => _$CurveFromJson(json);

  Map<String, dynamic> toJson() => _$CurveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
