import 'package:openfoodfacts/openfoodfacts.dart';

// TODO(monsieurtanuki): move to off-dart?
extension LocationOSMTypeExtension on LocationOSMType {
  String get short => offTag.substring(0, 1);
}
