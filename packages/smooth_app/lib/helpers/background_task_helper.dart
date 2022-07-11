/// Helper class for serialization and deserialization of data for the background task
class BackgroundInputData {
  BackgroundInputData({
    required this.barcode,
    required this.imageField,
    required this.imageUri,
    required this.counter,
    required this.languageCode,
  });

  BackgroundInputData.fromJson(Map<String, dynamic> json)
      : barcode = json['barcode'] as String,
        imageField = json['imageField'] as String,
        imageUri = json['imageUri'] as String,
        counter = json['counter'] as int,
        languageCode = json['languageCode'] as String;

  final String barcode;
  final String imageField;
  final String imageUri;
  int counter;
  final String languageCode;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'barcode': barcode,
        'imageField': imageField,
        'imageUri': imageUri,
        'counter': counter,
        'languageCode': languageCode,
      };
}
