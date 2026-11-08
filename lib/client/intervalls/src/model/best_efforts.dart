//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/effort.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'best_efforts.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BestEfforts {
  /// Returns a new [BestEfforts] instance.
  BestEfforts({this.efforts});

  @JsonKey(name: r'efforts', required: false, includeIfNull: false)
  final List<Effort>? efforts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BestEfforts && other.efforts == efforts;

  @override
  int get hashCode => efforts.hashCode;

  factory BestEfforts.fromJson(Map<String, dynamic> json) =>
      _$BestEffortsFromJson(json);

  Map<String, dynamic> toJson() => _$BestEffortsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
