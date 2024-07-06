import 'package:openfoodfacts/openfoodfacts.dart';

/// Generic helper about emoji display.
class EmojiHelper {
  const EmojiHelper._();

  /// Returns the country flag emoji.
  ///
  /// cf. https://emojipedia.org/flag-italy
  static String? getCountryEmoji(final OpenFoodFactsCountry? country) {
    if (country == null) {
      return null;
    }
    return getEmojiByCountryCode(country.offTag);
  }

  static String? getEmojiByCountryCode(final String countryCode) {
    if (countryCode.isEmpty) {
      return null;
    }
    return _getCountryEmojiFromUnicode(countryCode);
  }

  static const int _emojiCountryLetterA = 0x1F1E6;
  static const int _asciiCapitalA = 65;
  static const int _asciiCapitalZ = 90;

  static String? _getCountryEmojiFromUnicode(final String unicode) {
    final String? countryLetterEmoji1 = _getCountryLetterEmoji(
      unicode.substring(0, 1),
    );
    if (countryLetterEmoji1 == null) {
      return null;
    }
    //OpenFoodFactsCountry
    final String? countryLetterEmoji2 = _getCountryLetterEmoji(
      unicode.substring(1, 2),
    );
    if (countryLetterEmoji2 == null) {
      return null;
    }
    return '$countryLetterEmoji1$countryLetterEmoji2';
  }

  static String? _getCountryLetterEmoji(final String letter) {
    final int ascii = letter.toUpperCase().codeUnitAt(0);
    if (ascii < _asciiCapitalA || ascii > _asciiCapitalZ) {
      return null;
    }
    final int code = _emojiCountryLetterA + ascii - _asciiCapitalA;
    return String.fromCharCode(code);
  }
}
