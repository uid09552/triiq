//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_analysis_issue.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityAnalysisIssue {
  /// Returns a new [ActivityAnalysisIssue] instance.
  ActivityAnalysisIssue({

     this.type,

     this.message,

     this.customItemId,
  });

  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final ActivityAnalysisIssueTypeEnum? type;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;



  @JsonKey(
    
    name: r'custom_item_id',
    required: false,
    includeIfNull: false,
  )


  final int? customItemId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityAnalysisIssue &&
      other.type == type &&
      other.message == message &&
      other.customItemId == customItemId;

    @override
    int get hashCode =>
        type.hashCode +
        message.hashCode +
        customItemId.hashCode;

  factory ActivityAnalysisIssue.fromJson(Map<String, dynamic> json) => _$ActivityAnalysisIssueFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityAnalysisIssueToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ActivityAnalysisIssueTypeEnum {
@JsonValue(r'script_failed')
scriptFailed(r'script_failed');

const ActivityAnalysisIssueTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


