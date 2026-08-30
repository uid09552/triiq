// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RankCWProxy {
  Rank position(Map<String, double>? position);

  Rank watts(Map<String, double>? watts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Rank(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Rank(...).copyWith(id: 12, name: "My name")
  /// ````
  Rank call({Map<String, double>? position, Map<String, double>? watts});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRank.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRank.copyWith.fieldName(...)`
class _$RankCWProxyImpl implements _$RankCWProxy {
  const _$RankCWProxyImpl(this._value);

  final Rank _value;

  @override
  Rank position(Map<String, double>? position) => this(position: position);

  @override
  Rank watts(Map<String, double>? watts) => this(watts: watts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Rank(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Rank(...).copyWith(id: 12, name: "My name")
  /// ````
  Rank call({
    Object? position = const $CopyWithPlaceholder(),
    Object? watts = const $CopyWithPlaceholder(),
  }) {
    return Rank(
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as Map<String, double>?,
      watts: watts == const $CopyWithPlaceholder()
          ? _value.watts
          // ignore: cast_nullable_to_non_nullable
          : watts as Map<String, double>?,
    );
  }
}

extension $RankCopyWith on Rank {
  /// Returns a callable class that can be used as follows: `instanceOfRank.copyWith(...)` or like so:`instanceOfRank.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RankCWProxy get copyWith => _$RankCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rank _$RankFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Rank', json, ($checkedConvert) {
      final val = Rank(
        position: $checkedConvert(
          'position',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
        ),
        watts: $checkedConvert(
          'watts',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RankToJson(Rank instance) => <String, dynamic>{
  'position': ?instance.position,
  'watts': ?instance.watts,
};
