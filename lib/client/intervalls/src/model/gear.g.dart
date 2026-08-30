// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GearCWProxy {
  Gear id(String? id);

  Gear athleteId(String? athleteId);

  Gear type(GearTypeEnum? type);

  Gear name(String? name);

  Gear purchased(String? purchased);

  Gear notes(String? notes);

  Gear distance(double? distance);

  Gear time(double? time);

  Gear activities(int? activities);

  Gear useElapsedTime(bool? useElapsedTime);

  Gear retired(String? retired);

  Gear componentIds(List<String>? componentIds);

  Gear reminders(List<GearReminder>? reminders);

  Gear activityFilters(List<ActivityFilter>? activityFilters);

  Gear component(bool? component);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Gear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Gear(...).copyWith(id: 12, name: "My name")
  /// ````
  Gear call({
    String? id,
    String? athleteId,
    GearTypeEnum? type,
    String? name,
    String? purchased,
    String? notes,
    double? distance,
    double? time,
    int? activities,
    bool? useElapsedTime,
    String? retired,
    List<String>? componentIds,
    List<GearReminder>? reminders,
    List<ActivityFilter>? activityFilters,
    bool? component,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGear.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGear.copyWith.fieldName(...)`
class _$GearCWProxyImpl implements _$GearCWProxy {
  const _$GearCWProxyImpl(this._value);

  final Gear _value;

  @override
  Gear id(String? id) => this(id: id);

  @override
  Gear athleteId(String? athleteId) => this(athleteId: athleteId);

  @override
  Gear type(GearTypeEnum? type) => this(type: type);

  @override
  Gear name(String? name) => this(name: name);

  @override
  Gear purchased(String? purchased) => this(purchased: purchased);

  @override
  Gear notes(String? notes) => this(notes: notes);

  @override
  Gear distance(double? distance) => this(distance: distance);

  @override
  Gear time(double? time) => this(time: time);

  @override
  Gear activities(int? activities) => this(activities: activities);

  @override
  Gear useElapsedTime(bool? useElapsedTime) =>
      this(useElapsedTime: useElapsedTime);

  @override
  Gear retired(String? retired) => this(retired: retired);

  @override
  Gear componentIds(List<String>? componentIds) =>
      this(componentIds: componentIds);

  @override
  Gear reminders(List<GearReminder>? reminders) => this(reminders: reminders);

  @override
  Gear activityFilters(List<ActivityFilter>? activityFilters) =>
      this(activityFilters: activityFilters);

  @override
  Gear component(bool? component) => this(component: component);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Gear(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Gear(...).copyWith(id: 12, name: "My name")
  /// ````
  Gear call({
    Object? id = const $CopyWithPlaceholder(),
    Object? athleteId = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? purchased = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? time = const $CopyWithPlaceholder(),
    Object? activities = const $CopyWithPlaceholder(),
    Object? useElapsedTime = const $CopyWithPlaceholder(),
    Object? retired = const $CopyWithPlaceholder(),
    Object? componentIds = const $CopyWithPlaceholder(),
    Object? reminders = const $CopyWithPlaceholder(),
    Object? activityFilters = const $CopyWithPlaceholder(),
    Object? component = const $CopyWithPlaceholder(),
  }) {
    return Gear(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      athleteId: athleteId == const $CopyWithPlaceholder()
          ? _value.athleteId
          // ignore: cast_nullable_to_non_nullable
          : athleteId as String?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as GearTypeEnum?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      purchased: purchased == const $CopyWithPlaceholder()
          ? _value.purchased
          // ignore: cast_nullable_to_non_nullable
          : purchased as String?,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as double?,
      time: time == const $CopyWithPlaceholder()
          ? _value.time
          // ignore: cast_nullable_to_non_nullable
          : time as double?,
      activities: activities == const $CopyWithPlaceholder()
          ? _value.activities
          // ignore: cast_nullable_to_non_nullable
          : activities as int?,
      useElapsedTime: useElapsedTime == const $CopyWithPlaceholder()
          ? _value.useElapsedTime
          // ignore: cast_nullable_to_non_nullable
          : useElapsedTime as bool?,
      retired: retired == const $CopyWithPlaceholder()
          ? _value.retired
          // ignore: cast_nullable_to_non_nullable
          : retired as String?,
      componentIds: componentIds == const $CopyWithPlaceholder()
          ? _value.componentIds
          // ignore: cast_nullable_to_non_nullable
          : componentIds as List<String>?,
      reminders: reminders == const $CopyWithPlaceholder()
          ? _value.reminders
          // ignore: cast_nullable_to_non_nullable
          : reminders as List<GearReminder>?,
      activityFilters: activityFilters == const $CopyWithPlaceholder()
          ? _value.activityFilters
          // ignore: cast_nullable_to_non_nullable
          : activityFilters as List<ActivityFilter>?,
      component: component == const $CopyWithPlaceholder()
          ? _value.component
          // ignore: cast_nullable_to_non_nullable
          : component as bool?,
    );
  }
}

extension $GearCopyWith on Gear {
  /// Returns a callable class that can be used as follows: `instanceOfGear.copyWith(...)` or like so:`instanceOfGear.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GearCWProxy get copyWith => _$GearCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gear _$GearFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Gear',
  json,
  ($checkedConvert) {
    final val = Gear(
      id: $checkedConvert('id', (v) => v as String?),
      athleteId: $checkedConvert('athlete_id', (v) => v as String?),
      type: $checkedConvert(
        'type',
        (v) => $enumDecodeNullable(_$GearTypeEnumEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String?),
      purchased: $checkedConvert('purchased', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      distance: $checkedConvert('distance', (v) => (v as num?)?.toDouble()),
      time: $checkedConvert('time', (v) => (v as num?)?.toDouble()),
      activities: $checkedConvert('activities', (v) => (v as num?)?.toInt()),
      useElapsedTime: $checkedConvert('use_elapsed_time', (v) => v as bool?),
      retired: $checkedConvert('retired', (v) => v as String?),
      componentIds: $checkedConvert(
        'component_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      reminders: $checkedConvert(
        'reminders',
        (v) => (v as List<dynamic>?)
            ?.map((e) => GearReminder.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      activityFilters: $checkedConvert(
        'activity_filters',
        (v) => (v as List<dynamic>?)
            ?.map((e) => ActivityFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      component: $checkedConvert('component', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'athleteId': 'athlete_id',
    'useElapsedTime': 'use_elapsed_time',
    'componentIds': 'component_ids',
    'activityFilters': 'activity_filters',
  },
);

Map<String, dynamic> _$GearToJson(Gear instance) => <String, dynamic>{
  'id': ?instance.id,
  'athlete_id': ?instance.athleteId,
  'type': ?_$GearTypeEnumEnumMap[instance.type],
  'name': ?instance.name,
  'purchased': ?instance.purchased,
  'notes': ?instance.notes,
  'distance': ?instance.distance,
  'time': ?instance.time,
  'activities': ?instance.activities,
  'use_elapsed_time': ?instance.useElapsedTime,
  'retired': ?instance.retired,
  'component_ids': ?instance.componentIds,
  'reminders': ?instance.reminders?.map((e) => e.toJson()).toList(),
  'activity_filters': ?instance.activityFilters
      ?.map((e) => e.toJson())
      .toList(),
  'component': ?instance.component,
};

const _$GearTypeEnumEnumMap = {
  GearTypeEnum.bike: 'Bike',
  GearTypeEnum.shoes: 'Shoes',
  GearTypeEnum.wetsuit: 'Wetsuit',
  GearTypeEnum.rowingMachine: 'RowingMachine',
  GearTypeEnum.skis: 'Skis',
  GearTypeEnum.snowboard: 'Snowboard',
  GearTypeEnum.boat: 'Boat',
  GearTypeEnum.board: 'Board',
  GearTypeEnum.equipment: 'Equipment',
  GearTypeEnum.accessories: 'Accessories',
  GearTypeEnum.apparel: 'Apparel',
  GearTypeEnum.computer: 'Computer',
  GearTypeEnum.light: 'Light',
  GearTypeEnum.battery: 'Battery',
  GearTypeEnum.brake: 'Brake',
  GearTypeEnum.brakePads: 'BrakePads',
  GearTypeEnum.rotor: 'Rotor',
  GearTypeEnum.drivetrain: 'Drivetrain',
  GearTypeEnum.bottomBracket: 'BottomBracket',
  GearTypeEnum.cassette: 'Cassette',
  GearTypeEnum.chain: 'Chain',
  GearTypeEnum.chainrings: 'Chainrings',
  GearTypeEnum.crankset: 'Crankset',
  GearTypeEnum.derailleur: 'Derailleur',
  GearTypeEnum.pedals: 'Pedals',
  GearTypeEnum.lever: 'Lever',
  GearTypeEnum.cable: 'Cable',
  GearTypeEnum.frame: 'Frame',
  GearTypeEnum.fork: 'Fork',
  GearTypeEnum.handlebar: 'Handlebar',
  GearTypeEnum.headset: 'Headset',
  GearTypeEnum.saddle: 'Saddle',
  GearTypeEnum.seatpost: 'Seatpost',
  GearTypeEnum.shock: 'Shock',
  GearTypeEnum.stem: 'Stem',
  GearTypeEnum.axel: 'Axel',
  GearTypeEnum.hub: 'Hub',
  GearTypeEnum.trainer: 'Trainer',
  GearTypeEnum.tube: 'Tube',
  GearTypeEnum.tyre: 'Tyre',
  GearTypeEnum.wheel: 'Wheel',
  GearTypeEnum.wheelset: 'Wheelset',
  GearTypeEnum.powerMeter: 'PowerMeter',
  GearTypeEnum.cleats: 'Cleats',
  GearTypeEnum.cyclingShoes: 'CyclingShoes',
  GearTypeEnum.paddle: 'Paddle',
};
