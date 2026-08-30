//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Attachment {
  /// Returns a new [Attachment] instance.
  Attachment({

     this.id,

     this.filename,

     this.mimetype,

     this.url,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'filename',
    required: false,
    includeIfNull: false,
  )


  final String? filename;



  @JsonKey(
    
    name: r'mimetype',
    required: false,
    includeIfNull: false,
  )


  final String? mimetype;



  @JsonKey(
    
    name: r'url',
    required: false,
    includeIfNull: false,
  )


  final String? url;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Attachment &&
      other.id == id &&
      other.filename == filename &&
      other.mimetype == mimetype &&
      other.url == url;

    @override
    int get hashCode =>
        id.hashCode +
        filename.hashCode +
        mimetype.hashCode +
        url.hashCode;

  factory Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

