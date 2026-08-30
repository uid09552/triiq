// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_charts.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityChartsCWProxy {
  ActivityCharts home(List<Pos>? home);

  ActivityCharts power(List<Pos>? power);

  ActivityCharts hr(List<Pos>? hr);

  ActivityCharts pace(List<Pos>? pace);

  ActivityCharts data(List<Pos>? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityCharts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityCharts(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityCharts call({
    List<Pos>? home,
    List<Pos>? power,
    List<Pos>? hr,
    List<Pos>? pace,
    List<Pos>? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityCharts.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityCharts.copyWith.fieldName(...)`
class _$ActivityChartsCWProxyImpl implements _$ActivityChartsCWProxy {
  const _$ActivityChartsCWProxyImpl(this._value);

  final ActivityCharts _value;

  @override
  ActivityCharts home(List<Pos>? home) => this(home: home);

  @override
  ActivityCharts power(List<Pos>? power) => this(power: power);

  @override
  ActivityCharts hr(List<Pos>? hr) => this(hr: hr);

  @override
  ActivityCharts pace(List<Pos>? pace) => this(pace: pace);

  @override
  ActivityCharts data(List<Pos>? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityCharts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityCharts(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityCharts call({
    Object? home = const $CopyWithPlaceholder(),
    Object? power = const $CopyWithPlaceholder(),
    Object? hr = const $CopyWithPlaceholder(),
    Object? pace = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ActivityCharts(
      home: home == const $CopyWithPlaceholder()
          ? _value.home
          // ignore: cast_nullable_to_non_nullable
          : home as List<Pos>?,
      power: power == const $CopyWithPlaceholder()
          ? _value.power
          // ignore: cast_nullable_to_non_nullable
          : power as List<Pos>?,
      hr: hr == const $CopyWithPlaceholder()
          ? _value.hr
          // ignore: cast_nullable_to_non_nullable
          : hr as List<Pos>?,
      pace: pace == const $CopyWithPlaceholder()
          ? _value.pace
          // ignore: cast_nullable_to_non_nullable
          : pace as List<Pos>?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<Pos>?,
    );
  }
}

extension $ActivityChartsCopyWith on ActivityCharts {
  /// Returns a callable class that can be used as follows: `instanceOfActivityCharts.copyWith(...)` or like so:`instanceOfActivityCharts.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityChartsCWProxy get copyWith => _$ActivityChartsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityCharts _$ActivityChartsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ActivityCharts', json, ($checkedConvert) {
      final val = ActivityCharts(
        home: $checkedConvert(
          'home',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Pos.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        power: $checkedConvert(
          'power',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Pos.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        hr: $checkedConvert(
          'hr',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Pos.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        pace: $checkedConvert(
          'pace',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Pos.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Pos.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ActivityChartsToJson(ActivityCharts instance) =>
    <String, dynamic>{
      'home': ?instance.home?.map((e) => e.toJson()).toList(),
      'power': ?instance.power?.map((e) => e.toJson()).toList(),
      'hr': ?instance.hr?.map((e) => e.toJson()).toList(),
      'pace': ?instance.pace?.map((e) => e.toJson()).toList(),
      'data': ?instance.data?.map((e) => e.toJson()).toList(),
    };
