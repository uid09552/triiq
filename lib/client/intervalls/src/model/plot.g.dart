// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plot.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PlotCWProxy {
  Plot maxBpm(int? maxBpm);

  Plot minBpm(int? minBpm);

  Plot secs(List<int>? secs);

  Plot cumulativeSecs(List<int>? cumulativeSecs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Plot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Plot(...).copyWith(id: 12, name: "My name")
  /// ````
  Plot call({
    int? maxBpm,
    int? minBpm,
    List<int>? secs,
    List<int>? cumulativeSecs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPlot.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPlot.copyWith.fieldName(...)`
class _$PlotCWProxyImpl implements _$PlotCWProxy {
  const _$PlotCWProxyImpl(this._value);

  final Plot _value;

  @override
  Plot maxBpm(int? maxBpm) => this(maxBpm: maxBpm);

  @override
  Plot minBpm(int? minBpm) => this(minBpm: minBpm);

  @override
  Plot secs(List<int>? secs) => this(secs: secs);

  @override
  Plot cumulativeSecs(List<int>? cumulativeSecs) =>
      this(cumulativeSecs: cumulativeSecs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Plot(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Plot(...).copyWith(id: 12, name: "My name")
  /// ````
  Plot call({
    Object? maxBpm = const $CopyWithPlaceholder(),
    Object? minBpm = const $CopyWithPlaceholder(),
    Object? secs = const $CopyWithPlaceholder(),
    Object? cumulativeSecs = const $CopyWithPlaceholder(),
  }) {
    return Plot(
      maxBpm: maxBpm == const $CopyWithPlaceholder()
          ? _value.maxBpm
          // ignore: cast_nullable_to_non_nullable
          : maxBpm as int?,
      minBpm: minBpm == const $CopyWithPlaceholder()
          ? _value.minBpm
          // ignore: cast_nullable_to_non_nullable
          : minBpm as int?,
      secs: secs == const $CopyWithPlaceholder()
          ? _value.secs
          // ignore: cast_nullable_to_non_nullable
          : secs as List<int>?,
      cumulativeSecs: cumulativeSecs == const $CopyWithPlaceholder()
          ? _value.cumulativeSecs
          // ignore: cast_nullable_to_non_nullable
          : cumulativeSecs as List<int>?,
    );
  }
}

extension $PlotCopyWith on Plot {
  /// Returns a callable class that can be used as follows: `instanceOfPlot.copyWith(...)` or like so:`instanceOfPlot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PlotCWProxy get copyWith => _$PlotCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plot _$PlotFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Plot',
  json,
  ($checkedConvert) {
    final val = Plot(
      maxBpm: $checkedConvert('max_bpm', (v) => (v as num?)?.toInt()),
      minBpm: $checkedConvert('min_bpm', (v) => (v as num?)?.toInt()),
      secs: $checkedConvert(
        'secs',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      cumulativeSecs: $checkedConvert(
        'cumulative_secs',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'maxBpm': 'max_bpm',
    'minBpm': 'min_bpm',
    'cumulativeSecs': 'cumulative_secs',
  },
);

Map<String, dynamic> _$PlotToJson(Plot instance) => <String, dynamic>{
  'max_bpm': ?instance.maxBpm,
  'min_bpm': ?instance.minBpm,
  'secs': ?instance.secs,
  'cumulative_secs': ?instance.cumulativeSecs,
};
