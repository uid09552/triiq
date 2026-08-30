//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coach_tick.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoachTick {
  /// Returns a new [CoachTick] instance.
  CoachTick({

     this.id,

     this.text,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final int? id;



  @JsonKey(
    
    name: r'text',
    required: false,
    includeIfNull: false,
  )


  final String? text;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CoachTick &&
      other.id == id &&
      other.text == text;

    @override
    int get hashCode =>
        id.hashCode +
        text.hashCode;

  factory CoachTick.fromJson(Map<String, dynamic> json) => _$CoachTickFromJson(json);

  Map<String, dynamic> toJson() => _$CoachTickToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

