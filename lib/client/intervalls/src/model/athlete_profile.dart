//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/athlete_for_profile.dart';
import 'package:triiq/client/intervalls/src/model/folder.dart';
import 'package:triiq/client/intervalls/src/model/custom_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'athlete_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AthleteProfile {
  /// Returns a new [AthleteProfile] instance.
  AthleteProfile({

     this.athlete,

     this.sharedFolders,

     this.customItems,
  });

  @JsonKey(
    
    name: r'athlete',
    required: false,
    includeIfNull: false,
  )


  final AthleteForProfile? athlete;



  @JsonKey(
    
    name: r'sharedFolders',
    required: false,
    includeIfNull: false,
  )


  final List<Folder>? sharedFolders;



  @JsonKey(
    
    name: r'customItems',
    required: false,
    includeIfNull: false,
  )


  final List<CustomItem>? customItems;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AthleteProfile &&
      other.athlete == athlete &&
      other.sharedFolders == sharedFolders &&
      other.customItems == customItems;

    @override
    int get hashCode =>
        athlete.hashCode +
        sharedFolders.hashCode +
        customItems.hashCode;

  factory AthleteProfile.fromJson(Map<String, dynamic> json) => _$AthleteProfileFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

