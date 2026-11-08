//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'doomed_event.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DoomedEvent {
  /// Returns a new [DoomedEvent] instance.
  DoomedEvent({this.id, this.externalId});

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: r'external_id', required: false, includeIfNull: false)
  final String? externalId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoomedEvent && other.id == id && other.externalId == externalId;

  @override
  int get hashCode => id.hashCode + externalId.hashCode;

  factory DoomedEvent.fromJson(Map<String, dynamic> json) =>
      _$DoomedEventFromJson(json);

  Map<String, dynamic> toJson() => _$DoomedEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
