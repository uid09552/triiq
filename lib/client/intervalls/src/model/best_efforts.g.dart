// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_efforts.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BestEffortsCWProxy {
  BestEfforts efforts(List<Effort>? efforts);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BestEfforts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BestEfforts(...).copyWith(id: 12, name: "My name")
  /// ````
  BestEfforts call({List<Effort>? efforts});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBestEfforts.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBestEfforts.copyWith.fieldName(...)`
class _$BestEffortsCWProxyImpl implements _$BestEffortsCWProxy {
  const _$BestEffortsCWProxyImpl(this._value);

  final BestEfforts _value;

  @override
  BestEfforts efforts(List<Effort>? efforts) => this(efforts: efforts);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BestEfforts(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BestEfforts(...).copyWith(id: 12, name: "My name")
  /// ````
  BestEfforts call({Object? efforts = const $CopyWithPlaceholder()}) {
    return BestEfforts(
      efforts: efforts == const $CopyWithPlaceholder()
          ? _value.efforts
          // ignore: cast_nullable_to_non_nullable
          : efforts as List<Effort>?,
    );
  }
}

extension $BestEffortsCopyWith on BestEfforts {
  /// Returns a callable class that can be used as follows: `instanceOfBestEfforts.copyWith(...)` or like so:`instanceOfBestEfforts.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BestEffortsCWProxy get copyWith => _$BestEffortsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BestEfforts _$BestEffortsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BestEfforts', json, ($checkedConvert) {
      final val = BestEfforts(
        efforts: $checkedConvert(
          'efforts',
          (v) => (v as List<dynamic>?)
              ?.map((e) => Effort.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BestEffortsToJson(BestEfforts instance) =>
    <String, dynamic>{
      'efforts': ?instance.efforts?.map((e) => e.toJson()).toList(),
    };
