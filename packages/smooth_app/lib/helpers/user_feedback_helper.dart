import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';

// ignore: avoid_classes_with_only_static_members
class UserFeedbackHelper {
  static String getFeedbackFormLink() {
    final String languageCode = ProductQuery.getLanguage().code;
    if (languageCode == 'en') {
      return 'https://forms.gle/AuNZG6fXyAPqN5tL7';
    } else if (languageCode == 'de') {
      return 'https://forms.gle/vCurhD2Y3ewS1YPv5';
    } else if (languageCode == 'es') {
      return 'https://forms.gle/CSMmuzR8i4LJBjbM9';
    } else if (languageCode == 'fr') {
      return 'https://forms.gle/cTR4wqGmW7pGUiaBA';
    } else if (languageCode == 'it') {
      return 'https://forms.gle/9HcCLFznym1ByQgB6';
    } else {
      return 'https://forms.gle/AuNZG6fXyAPqN5tL7';
    }
  }
}
