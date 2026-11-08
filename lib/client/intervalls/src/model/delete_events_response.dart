//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delete_events_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeleteEventsResponse {
  /// Returns a new [DeleteEventsResponse] instance.
  DeleteEventsResponse({this.eventsDeleted});

  @JsonKey(name: r'eventsDeleted', required: false, includeIfNull: false)
  final int? eventsDeleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteEventsResponse && other.eventsDeleted == eventsDeleted;

  @override
  int get hashCode => eventsDeleted.hashCode;

  factory DeleteEventsResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteEventsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteEventsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
