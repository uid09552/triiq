//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_streams_result.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateStreamsResult {
  /// Returns a new [UpdateStreamsResult] instance.
  UpdateStreamsResult({

     this.updated,

     this.deleted,
  });

  @JsonKey(
    
    name: r'updated',
    required: false,
    includeIfNull: false,
  )


  final List<String>? updated;



  @JsonKey(
    
    name: r'deleted',
    required: false,
    includeIfNull: false,
  )


  final List<String>? deleted;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateStreamsResult &&
      other.updated == updated &&
      other.deleted == deleted;

    @override
    int get hashCode =>
        updated.hashCode +
        deleted.hashCode;

  factory UpdateStreamsResult.fromJson(Map<String, dynamic> json) => _$UpdateStreamsResultFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateStreamsResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

