import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/preferences/country_selector/openfoodfacts_country_iso2code_extension.dart';
import 'package:smooth_app/pages/prices/emoji_helper.dart';

extension OpenFoodFactsCountryEmojiExtension on OpenFoodFactsCountry {
  String get emoji => EmojiHelper.getEmojiByCountryCode(iso2Code) ?? '';
}

