//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:triiq/client/intervalls/src/model/zone_info.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'zone_set.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ZoneSet {
  /// Returns a new [ZoneSet] instance.
  ZoneSet({

     this.code,

     this.zones,
  });

  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'zones',
    required: false,
    includeIfNull: false,
  )


  final List<ZoneInfo>? zones;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ZoneSet &&
      other.code == code &&
      other.zones == zones;

    @override
    int get hashCode =>
        code.hashCode +
        zones.hashCode;

  factory ZoneSet.fromJson(Map<String, dynamic> json) => _$ZoneSetFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneSetToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

