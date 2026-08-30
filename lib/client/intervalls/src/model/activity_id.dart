//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity_id.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ActivityId {
  /// Returns a new [ActivityId] instance.
  ActivityId({

     this.icuAthleteId,

     this.id,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is ActivityId &&
      other.icuAthleteId == icuAthleteId &&
      other.id == id;

    @override
    int get hashCode =>
        icuAthleteId.hashCode +
        id.hashCode;

  factory ActivityId.fromJson(Map<String, dynamic> json) => _$ActivityIdFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityIdToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

