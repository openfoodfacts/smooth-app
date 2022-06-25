import 'package:openfoodfacts/interface/JsonObject.dart';

// TODO(monsieurtanuki): move to off-dart with correct json serializable
class OcrPackagingResult extends JsonObject {
  const OcrPackagingResult({
    this.status,
    this.textFromImageOrig,
    this.textFromImage,
  });

  factory OcrPackagingResult.fromJson(Map<String, dynamic> json) =>
      _$OcrPackagingResultFromJson(json);

  final int? status;

  final String? textFromImageOrig;

  final String? textFromImage;

  @override
  Map<String, dynamic> toJson() => _$OcrPackagingResultToJson(this);

  static OcrPackagingResult _$OcrPackagingResultFromJson(
          Map<String, dynamic> json) =>
      OcrPackagingResult(
        status: json['status'] as int?,
        textFromImageOrig: json['packaging_text_from_image_orig'] as String?,
        textFromImage: json['packaging_text_from_image'] as String?,
      );

  Map<String, dynamic> _$OcrPackagingResultToJson(
          OcrPackagingResult instance) =>
      <String, dynamic>{
        'status': instance.status,
        'packaging_text_from_image_orig': instance.textFromImageOrig,
        'packaging_text_from_image': instance.textFromImage,
      };
}
