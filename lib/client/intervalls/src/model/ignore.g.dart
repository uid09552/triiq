// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ignore.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IgnoreCWProxy {
  Ignore startIndex(int? startIndex);

  Ignore endIndex(int? endIndex);

  Ignore power(bool? power);

  Ignore pace(bool? pace);

  Ignore hr(bool? hr);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ignore(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ignore(...).copyWith(id: 12, name: "My name")
  /// ````
  Ignore call({
    int? startIndex,
    int? endIndex,
    bool? power,
    bool? pace,
    bool? hr,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIgnore.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIgnore.copyWith.fieldName(...)`
class _$IgnoreCWProxyImpl implements _$IgnoreCWProxy {
  const _$IgnoreCWProxyImpl(this._value);

  final Ignore _value;

  @override
  Ignore startIndex(int? startIndex) => this(startIndex: startIndex);

  @override
  Ignore endIndex(int? endIndex) => this(endIndex: endIndex);

  @override
  Ignore power(bool? power) => this(power: power);

  @override
  Ignore pace(bool? pace) => this(pace: pace);

  @override
  Ignore hr(bool? hr) => this(hr: hr);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Ignore(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Ignore(...).copyWith(id: 12, name: "My name")
  /// ````
  Ignore call({
    Object? startIndex = const $CopyWithPlaceholder(),
    Object? endIndex = const $CopyWithPlaceholder(),
    Object? power = const $CopyWithPlaceholder(),
    Object? pace = const $CopyWithPlaceholder(),
    Object? hr = const $CopyWithPlaceholder(),
  }) {
    return Ignore(
      startIndex: startIndex == const $CopyWithPlaceholder()
          ? _value.startIndex
          // ignore: cast_nullable_to_non_nullable
          : startIndex as int?,
      endIndex: endIndex == const $CopyWithPlaceholder()
          ? _value.endIndex
          // ignore: cast_nullable_to_non_nullable
          : endIndex as int?,
      power: power == const $CopyWithPlaceholder()
          ? _value.power
          // ignore: cast_nullable_to_non_nullable
          : power as bool?,
      pace: pace == const $CopyWithPlaceholder()
          ? _value.pace
          // ignore: cast_nullable_to_non_nullable
          : pace as bool?,
      hr: hr == const $CopyWithPlaceholder()
          ? _value.hr
          // ignore: cast_nullable_to_non_nullable
          : hr as bool?,
    );
  }
}

extension $IgnoreCopyWith on Ignore {
  /// Returns a callable class that can be used as follows: `instanceOfIgnore.copyWith(...)` or like so:`instanceOfIgnore.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IgnoreCWProxy get copyWith => _$IgnoreCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ignore _$IgnoreFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Ignore',
  json,
  ($checkedConvert) {
    final val = Ignore(
      startIndex: $checkedConvert('start_index', (v) => (v as num?)?.toInt()),
      endIndex: $checkedConvert('end_index', (v) => (v as num?)?.toInt()),
      power: $checkedConvert('power', (v) => v as bool?),
      pace: $checkedConvert('pace', (v) => v as bool?),
      hr: $checkedConvert('hr', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {'startIndex': 'start_index', 'endIndex': 'end_index'},
);

Map<String, dynamic> _$IgnoreToJson(Ignore instance) => <String, dynamic>{
  'start_index': ?instance.startIndex,
  'end_index': ?instance.endIndex,
  'power': ?instance.power,
  'pace': ?instance.pace,
  'hr': ?instance.hr,
};
