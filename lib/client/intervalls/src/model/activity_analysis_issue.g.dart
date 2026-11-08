// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_analysis_issue.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActivityAnalysisIssueCWProxy {
  ActivityAnalysisIssue type(ActivityAnalysisIssueTypeEnum? type);

  ActivityAnalysisIssue message(String? message);

  ActivityAnalysisIssue customItemId(int? customItemId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityAnalysisIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityAnalysisIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityAnalysisIssue call({
    ActivityAnalysisIssueTypeEnum? type,
    String? message,
    int? customItemId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActivityAnalysisIssue.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActivityAnalysisIssue.copyWith.fieldName(...)`
class _$ActivityAnalysisIssueCWProxyImpl
    implements _$ActivityAnalysisIssueCWProxy {
  const _$ActivityAnalysisIssueCWProxyImpl(this._value);

  final ActivityAnalysisIssue _value;

  @override
  ActivityAnalysisIssue type(ActivityAnalysisIssueTypeEnum? type) =>
      this(type: type);

  @override
  ActivityAnalysisIssue message(String? message) => this(message: message);

  @override
  ActivityAnalysisIssue customItemId(int? customItemId) =>
      this(customItemId: customItemId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActivityAnalysisIssue(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActivityAnalysisIssue(...).copyWith(id: 12, name: "My name")
  /// ````
  ActivityAnalysisIssue call({
    Object? type = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? customItemId = const $CopyWithPlaceholder(),
  }) {
    return ActivityAnalysisIssue(
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as ActivityAnalysisIssueTypeEnum?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String?,
      customItemId: customItemId == const $CopyWithPlaceholder()
          ? _value.customItemId
          // ignore: cast_nullable_to_non_nullable
          : customItemId as int?,
    );
  }
}

extension $ActivityAnalysisIssueCopyWith on ActivityAnalysisIssue {
  /// Returns a callable class that can be used as follows: `instanceOfActivityAnalysisIssue.copyWith(...)` or like so:`instanceOfActivityAnalysisIssue.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActivityAnalysisIssueCWProxy get copyWith =>
      _$ActivityAnalysisIssueCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityAnalysisIssue _$ActivityAnalysisIssueFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ActivityAnalysisIssue', json, ($checkedConvert) {
  final val = ActivityAnalysisIssue(
    type: $checkedConvert(
      'type',
      (v) => $enumDecodeNullable(_$ActivityAnalysisIssueTypeEnumEnumMap, v),
    ),
    message: $checkedConvert('message', (v) => v as String?),
    customItemId: $checkedConvert(
      'custom_item_id',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
}, fieldKeyMap: const {'customItemId': 'custom_item_id'});

Map<String, dynamic> _$ActivityAnalysisIssueToJson(
  ActivityAnalysisIssue instance,
) => <String, dynamic>{
  'type': ?_$ActivityAnalysisIssueTypeEnumEnumMap[instance.type],
  'message': ?instance.message,
  'custom_item_id': ?instance.customItemId,
};

const _$ActivityAnalysisIssueTypeEnumEnumMap = {
  ActivityAnalysisIssueTypeEnum.scriptFailed: 'script_failed',
};
