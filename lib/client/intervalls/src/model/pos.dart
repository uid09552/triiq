//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pos.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Pos {
  /// Returns a new [Pos] instance.
  Pos({

     this.id,

     this.width,

     this.height,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'width',
    required: false,
    includeIfNull: false,
  )


  final String? width;



  @JsonKey(
    
    name: r'height',
    required: false,
    includeIfNull: false,
  )


  final String? height;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Pos &&
      other.id == id &&
      other.width == width &&
      other.height == height;

    @override
    int get hashCode =>
        id.hashCode +
        width.hashCode +
        height.hashCode;

  factory Pos.fromJson(Map<String, dynamic> json) => _$PosFromJson(json);

  Map<String, dynamic> toJson() => _$PosToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

