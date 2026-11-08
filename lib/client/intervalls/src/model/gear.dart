//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_filter.dart';
import 'package:triiq/client/intervalls/src/model/gear_reminder.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gear.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Gear {
  /// Returns a new [Gear] instance.
  Gear({
    this.id,

    this.athleteId,

    this.type,

    this.name,

    this.purchased,

    this.notes,

    this.distance,

    this.time,

    this.activities,

    this.useElapsedTime,

    this.retired,

    this.componentIds,

    this.reminders,

    this.activityFilters,

    this.component,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'athlete_id', required: false, includeIfNull: false)
  final String? athleteId;

  @JsonKey(name: r'type', required: false, includeIfNull: false)
  final GearTypeEnum? type;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'purchased', required: false, includeIfNull: false)
  final String? purchased;

  @JsonKey(name: r'notes', required: false, includeIfNull: false)
  final String? notes;

  @JsonKey(name: r'distance', required: false, includeIfNull: false)
  final double? distance;

  @JsonKey(name: r'time', required: false, includeIfNull: false)
  final double? time;

  @JsonKey(name: r'activities', required: false, includeIfNull: false)
  final int? activities;

  @JsonKey(name: r'use_elapsed_time', required: false, includeIfNull: false)
  final bool? useElapsedTime;

  @JsonKey(name: r'retired', required: false, includeIfNull: false)
  final String? retired;

  @JsonKey(name: r'component_ids', required: false, includeIfNull: false)
  final List<String>? componentIds;

  @JsonKey(name: r'reminders', required: false, includeIfNull: false)
  final List<GearReminder>? reminders;

  @JsonKey(name: r'activity_filters', required: false, includeIfNull: false)
  final List<ActivityFilter>? activityFilters;

  @JsonKey(name: r'component', required: false, includeIfNull: false)
  final bool? component;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gear &&
          other.id == id &&
          other.athleteId == athleteId &&
          other.type == type &&
          other.name == name &&
          other.purchased == purchased &&
          other.notes == notes &&
          other.distance == distance &&
          other.time == time &&
          other.activities == activities &&
          other.useElapsedTime == useElapsedTime &&
          other.retired == retired &&
          other.componentIds == componentIds &&
          other.reminders == reminders &&
          other.activityFilters == activityFilters &&
          other.component == component;

  @override
  int get hashCode =>
      id.hashCode +
      athleteId.hashCode +
      type.hashCode +
      name.hashCode +
      purchased.hashCode +
      notes.hashCode +
      distance.hashCode +
      time.hashCode +
      activities.hashCode +
      useElapsedTime.hashCode +
      retired.hashCode +
      componentIds.hashCode +
      reminders.hashCode +
      activityFilters.hashCode +
      component.hashCode;

  factory Gear.fromJson(Map<String, dynamic> json) => _$GearFromJson(json);

  Map<String, dynamic> toJson() => _$GearToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum GearTypeEnum {
  @JsonValue(r'Bike')
  bike(r'Bike'),
  @JsonValue(r'Shoes')
  shoes(r'Shoes'),
  @JsonValue(r'Wetsuit')
  wetsuit(r'Wetsuit'),
  @JsonValue(r'RowingMachine')
  rowingMachine(r'RowingMachine'),
  @JsonValue(r'Skis')
  skis(r'Skis'),
  @JsonValue(r'Snowboard')
  snowboard(r'Snowboard'),
  @JsonValue(r'Boat')
  boat(r'Boat'),
  @JsonValue(r'Board')
  board(r'Board'),
  @JsonValue(r'Equipment')
  equipment(r'Equipment'),
  @JsonValue(r'Accessories')
  accessories(r'Accessories'),
  @JsonValue(r'Apparel')
  apparel(r'Apparel'),
  @JsonValue(r'Computer')
  computer(r'Computer'),
  @JsonValue(r'Light')
  light(r'Light'),
  @JsonValue(r'Battery')
  battery(r'Battery'),
  @JsonValue(r'Brake')
  brake(r'Brake'),
  @JsonValue(r'BrakePads')
  brakePads(r'BrakePads'),
  @JsonValue(r'Rotor')
  rotor(r'Rotor'),
  @JsonValue(r'Drivetrain')
  drivetrain(r'Drivetrain'),
  @JsonValue(r'BottomBracket')
  bottomBracket(r'BottomBracket'),
  @JsonValue(r'Cassette')
  cassette(r'Cassette'),
  @JsonValue(r'Chain')
  chain(r'Chain'),
  @JsonValue(r'Chainrings')
  chainrings(r'Chainrings'),
  @JsonValue(r'Crankset')
  crankset(r'Crankset'),
  @JsonValue(r'Derailleur')
  derailleur(r'Derailleur'),
  @JsonValue(r'Pedals')
  pedals(r'Pedals'),
  @JsonValue(r'Lever')
  lever(r'Lever'),
  @JsonValue(r'Cable')
  cable(r'Cable'),
  @JsonValue(r'Frame')
  frame(r'Frame'),
  @JsonValue(r'Fork')
  fork(r'Fork'),
  @JsonValue(r'Handlebar')
  handlebar(r'Handlebar'),
  @JsonValue(r'Headset')
  headset(r'Headset'),
  @JsonValue(r'Saddle')
  saddle(r'Saddle'),
  @JsonValue(r'Seatpost')
  seatpost(r'Seatpost'),
  @JsonValue(r'Shock')
  shock(r'Shock'),
  @JsonValue(r'Stem')
  stem(r'Stem'),
  @JsonValue(r'Axel')
  axel(r'Axel'),
  @JsonValue(r'Hub')
  hub(r'Hub'),
  @JsonValue(r'Trainer')
  trainer(r'Trainer'),
  @JsonValue(r'Tube')
  tube(r'Tube'),
  @JsonValue(r'Tyre')
  tyre(r'Tyre'),
  @JsonValue(r'Wheel')
  wheel(r'Wheel'),
  @JsonValue(r'Wheelset')
  wheelset(r'Wheelset'),
  @JsonValue(r'PowerMeter')
  powerMeter(r'PowerMeter'),
  @JsonValue(r'Cleats')
  cleats(r'Cleats'),
  @JsonValue(r'CyclingShoes')
  cyclingShoes(r'CyclingShoes'),
  @JsonValue(r'Paddle')
  paddle(r'Paddle');

  const GearTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
