// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curve.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CurveCWProxy {
  Curve id(String? id);

  Curve coefficients(List<double>? coefficients);

  Curve r2(double? r2);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Curve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Curve(...).copyWith(id: 12, name: "My name")
  /// ````
  Curve call({String? id, List<double>? coefficients, double? r2});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCurve.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCurve.copyWith.fieldName(...)`
class _$CurveCWProxyImpl implements _$CurveCWProxy {
  const _$CurveCWProxyImpl(this._value);

  final Curve _value;

  @override
  Curve id(String? id) => this(id: id);

  @override
  Curve coefficients(List<double>? coefficients) =>
      this(coefficients: coefficients);

  @override
  Curve r2(double? r2) => this(r2: r2);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Curve(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Curve(...).copyWith(id: 12, name: "My name")
  /// ````
  Curve call({
    Object? id = const $CopyWithPlaceholder(),
    Object? coefficients = const $CopyWithPlaceholder(),
    Object? r2 = const $CopyWithPlaceholder(),
  }) {
    return Curve(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      coefficients: coefficients == const $CopyWithPlaceholder()
          ? _value.coefficients
          // ignore: cast_nullable_to_non_nullable
          : coefficients as List<double>?,
      r2: r2 == const $CopyWithPlaceholder()
          ? _value.r2
          // ignore: cast_nullable_to_non_nullable
          : r2 as double?,
    );
  }
}

extension $CurveCopyWith on Curve {
  /// Returns a callable class that can be used as follows: `instanceOfCurve.copyWith(...)` or like so:`instanceOfCurve.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CurveCWProxy get copyWith => _$CurveCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Curve _$CurveFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Curve', json, ($checkedConvert) {
      final val = Curve(
        id: $checkedConvert('id', (v) => v as String?),
        coefficients: $checkedConvert(
          'coefficients',
          (v) =>
              (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
        ),
        r2: $checkedConvert('r2', (v) => (v as num?)?.toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$CurveToJson(Curve instance) => <String, dynamic>{
  'id': ?instance.id,
  'coefficients': ?instance.coefficients,
  'r2': ?instance.r2,
};
