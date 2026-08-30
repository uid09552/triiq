//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/activity_id.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UploadResponse {
  /// Returns a new [UploadResponse] instance.
  UploadResponse({

     this.icuAthleteId,

     this.id,

     this.activities,
  });

  @JsonKey(
    
    name: r'icu_athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? icuAthleteId;



  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'activities',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityId>? activities;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UploadResponse &&
      other.icuAthleteId == icuAthleteId &&
      other.id == id &&
      other.activities == activities;

    @override
    int get hashCode =>
        icuAthleteId.hashCode +
        id.hashCode +
        activities.hashCode;

  factory UploadResponse.fromJson(Map<String, dynamic> json) => _$UploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

