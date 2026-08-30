//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hidden.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Hidden {
  /// Returns a new [Hidden] instance.
  Hidden({

     this.id,

     this.icuAthleteId,

     this.startDateLocal,

     this.source_,

     this.note,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'icu_athlete_id',
    required: false,
    includeIfNull: false,
  )


  final String? icuAthleteId;



  @JsonKey(
    
    name: r'start_date_local',
    required: false,
    includeIfNull: false,
  )


  final String? startDateLocal;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final HiddenSource_Enum? source_;



  @JsonKey(
    
    name: r'_note',
    required: false,
    includeIfNull: false,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Hidden &&
      other.id == id &&
      other.icuAthleteId == icuAthleteId &&
      other.startDateLocal == startDateLocal &&
      other.source_ == source_ &&
      other.note == note;

    @override
    int get hashCode =>
        id.hashCode +
        icuAthleteId.hashCode +
        startDateLocal.hashCode +
        source_.hashCode +
        note.hashCode;

  factory Hidden.fromJson(Map<String, dynamic> json) => _$HiddenFromJson(json);

  Map<String, dynamic> toJson() => _$HiddenToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum HiddenSource_Enum {
@JsonValue(r'STRAVA')
STRAVA(r'STRAVA'),
@JsonValue(r'UPLOAD')
UPLOAD(r'UPLOAD'),
@JsonValue(r'MANUAL')
MANUAL(r'MANUAL'),
@JsonValue(r'GARMIN_CONNECT')
GARMIN_CONNECT(r'GARMIN_CONNECT'),
@JsonValue(r'OAUTH_CLIENT')
OAUTH_CLIENT(r'OAUTH_CLIENT'),
@JsonValue(r'DROPBOX')
DROPBOX(r'DROPBOX'),
@JsonValue(r'POLAR')
POLAR(r'POLAR'),
@JsonValue(r'SUUNTO')
SUUNTO(r'SUUNTO'),
@JsonValue(r'COROS')
COROS(r'COROS'),
@JsonValue(r'WAHOO')
WAHOO(r'WAHOO'),
@JsonValue(r'ZWIFT')
ZWIFT(r'ZWIFT'),
@JsonValue(r'ZEPP')
ZEPP(r'ZEPP'),
@JsonValue(r'CONCEPT2')
CONCEPT2(r'CONCEPT2'),
@JsonValue(r'HUAWEI')
HUAWEI(r'HUAWEI');

const HiddenSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


