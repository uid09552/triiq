// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_streams_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateStreamsResultCWProxy {
  UpdateStreamsResult updated(List<String>? updated);

  UpdateStreamsResult deleted(List<String>? deleted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateStreamsResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateStreamsResult(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateStreamsResult call({List<String>? updated, List<String>? deleted});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateStreamsResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateStreamsResult.copyWith.fieldName(...)`
class _$UpdateStreamsResultCWProxyImpl implements _$UpdateStreamsResultCWProxy {
  const _$UpdateStreamsResultCWProxyImpl(this._value);

  final UpdateStreamsResult _value;

  @override
  UpdateStreamsResult updated(List<String>? updated) => this(updated: updated);

  @override
  UpdateStreamsResult deleted(List<String>? deleted) => this(deleted: deleted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateStreamsResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateStreamsResult(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateStreamsResult call({
    Object? updated = const $CopyWithPlaceholder(),
    Object? deleted = const $CopyWithPlaceholder(),
  }) {
    return UpdateStreamsResult(
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as List<String>?,
      deleted: deleted == const $CopyWithPlaceholder()
          ? _value.deleted
          // ignore: cast_nullable_to_non_nullable
          : deleted as List<String>?,
    );
  }
}

extension $UpdateStreamsResultCopyWith on UpdateStreamsResult {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateStreamsResult.copyWith(...)` or like so:`instanceOfUpdateStreamsResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateStreamsResultCWProxy get copyWith =>
      _$UpdateStreamsResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateStreamsResult _$UpdateStreamsResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateStreamsResult', json, ($checkedConvert) {
      final val = UpdateStreamsResult(
        updated: $checkedConvert(
          'updated',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        deleted: $checkedConvert(
          'deleted',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateStreamsResultToJson(
  UpdateStreamsResult instance,
) => <String, dynamic>{
  'updated': ?instance.updated,
  'deleted': ?instance.deleted,
};
