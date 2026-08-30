//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rank.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Rank {
  /// Returns a new [Rank] instance.
  Rank({

     this.position,

     this.watts,
  });

  @JsonKey(
    
    name: r'position',
    required: false,
    includeIfNull: false,
  )


  final Map<String, double>? position;



  @JsonKey(
    
    name: r'watts',
    required: false,
    includeIfNull: false,
  )


  final Map<String, double>? watts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Rank &&
      other.position == position &&
      other.watts == watts;

    @override
    int get hashCode =>
        position.hashCode +
        watts.hashCode;

  factory Rank.fromJson(Map<String, dynamic> json) => _$RankFromJson(json);

  Map<String, dynamic> toJson() => _$RankToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

