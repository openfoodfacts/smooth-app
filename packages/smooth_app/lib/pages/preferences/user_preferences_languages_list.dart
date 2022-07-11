import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';

class LanguageName {
  LanguageName({
    required this.englishName,
    required this.nameInLanguage,
  });

  final String englishName;
  final String nameInLanguage;
}

class Pair<Key, Value> {
  Pair({
    required this.first,
    required this.second,
  });
  final Key first;
  final Value second;
}

class Languages {
  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      GlobalMaterialLocalizations.delegate;

  Map<OpenFoodFactsLanguage, LanguageName> openFoodFactsLanguagesList =
      <OpenFoodFactsLanguage, LanguageName>{
    OpenFoodFactsLanguage.AFAR:
        LanguageName(englishName: 'Afar', nameInLanguage: 'Afar'),
    OpenFoodFactsLanguage.AFRIKAANS:
        LanguageName(englishName: 'Afrikaans', nameInLanguage: 'Afrikaans'),
    OpenFoodFactsLanguage.AKAN:
        LanguageName(englishName: 'Akan', nameInLanguage: 'Akan'),
    OpenFoodFactsLanguage.AMHARIC:
        LanguageName(englishName: 'Amharic', nameInLanguage: 'አማርኛ'),
    OpenFoodFactsLanguage.ARABIC:
        LanguageName(englishName: 'Arabic', nameInLanguage: 'عربى'),
    OpenFoodFactsLanguage.ARAGONESE:
        LanguageName(englishName: 'Aragonese', nameInLanguage: 'Aragonés'),
    OpenFoodFactsLanguage.ASSAMESE:
        LanguageName(englishName: 'Assamese', nameInLanguage: 'অসমীয়া'),
    OpenFoodFactsLanguage.AVAR:
        LanguageName(englishName: 'Avar', nameInLanguage: 'Авар'),
    OpenFoodFactsLanguage.AVESTAN:
        LanguageName(englishName: 'Avestan', nameInLanguage: 'Avesta'),
    OpenFoodFactsLanguage.AYMARA:
        LanguageName(englishName: 'Aymara', nameInLanguage: 'Aymar aru'),
    OpenFoodFactsLanguage.AZERBAIJANI:
        LanguageName(englishName: 'Azerbaijani', nameInLanguage: 'Azərbaycan'),
    OpenFoodFactsLanguage.BELARUSIAN:
        LanguageName(englishName: 'Belarusian', nameInLanguage: 'беларускi'),
    OpenFoodFactsLanguage.BULGARIAN:
        LanguageName(englishName: 'Bulgarian', nameInLanguage: 'български'),
    OpenFoodFactsLanguage.BAMBARA:
        LanguageName(englishName: 'Bambara', nameInLanguage: 'Bamanankan'),
    OpenFoodFactsLanguage.BASHKIR:
        LanguageName(englishName: 'Bashkir', nameInLanguage: 'башҡорт тілі'),
    OpenFoodFactsLanguage.BENGALI:
        LanguageName(englishName: 'Bengali', nameInLanguage: 'বাংলা'),
    OpenFoodFactsLanguage.BIHARI_LANGUAGES: LanguageName(
        englishName: 'Bihari Languages', nameInLanguage: 'Bihari Languages'),
    OpenFoodFactsLanguage.BISLAMA:
        LanguageName(englishName: 'Bislama', nameInLanguage: 'Bislama'),
    OpenFoodFactsLanguage.TIBETAN_LANGUAGE:
        LanguageName(englishName: 'Tibetan', nameInLanguage: 'Tibetan'),
    OpenFoodFactsLanguage.BRETON:
        LanguageName(englishName: 'Breton', nameInLanguage: 'Breton'),
    OpenFoodFactsLanguage.BOSNIAN:
        LanguageName(englishName: 'Bosnian', nameInLanguage: 'bosanski'),
    OpenFoodFactsLanguage.CATALAN:
        LanguageName(englishName: 'Catalan', nameInLanguage: 'català'),
    OpenFoodFactsLanguage.CHECHEN:
        LanguageName(englishName: 'Chechen', nameInLanguage: 'Chechen'),
    OpenFoodFactsLanguage.CHEWA:
        LanguageName(englishName: 'Chewa', nameInLanguage: 'Chewa'),
    OpenFoodFactsLanguage.CHAMORRO:
        LanguageName(englishName: 'Chamorro', nameInLanguage: 'Chamoru'),
    OpenFoodFactsLanguage.CHURCH_SLAVONIC: LanguageName(
        englishName: 'Church Slavonic', nameInLanguage: 'Church Slavonic'),
    OpenFoodFactsLanguage.CORSICAN:
        LanguageName(englishName: 'Corsican', nameInLanguage: 'Corsu'),
    OpenFoodFactsLanguage.CREE:
        LanguageName(englishName: 'Cree', nameInLanguage: 'ᐃᓄᒃᑎᑐᑦ'),
    OpenFoodFactsLanguage.CZECH:
        LanguageName(englishName: 'Czech', nameInLanguage: 'čeština'),
    OpenFoodFactsLanguage.CHUVASH:
        LanguageName(englishName: 'Chuvash', nameInLanguage: 'Chuvash'),
    OpenFoodFactsLanguage.WELSH:
        LanguageName(englishName: 'Welsh', nameInLanguage: 'Cymraeg'),
    OpenFoodFactsLanguage.DANISH:
        LanguageName(englishName: 'Danish', nameInLanguage: 'dansk'),
    OpenFoodFactsLanguage.DZONGKHA_LANGUAGE:
        LanguageName(englishName: 'Dzongkha', nameInLanguage: 'Dzongkha'),
    OpenFoodFactsLanguage.GERMAN:
        LanguageName(englishName: 'German', nameInLanguage: 'Deutsch'),
    OpenFoodFactsLanguage.MODERN_GREEK:
        LanguageName(englishName: 'Greek', nameInLanguage: 'Ελληνικά'),
    OpenFoodFactsLanguage.ENGLISH:
        LanguageName(englishName: 'English', nameInLanguage: 'English'),
    OpenFoodFactsLanguage.ESPERANTO:
        LanguageName(englishName: 'Esperanto', nameInLanguage: 'Esperanto'),
    OpenFoodFactsLanguage.SPANISH:
        LanguageName(englishName: 'Spanish', nameInLanguage: 'Español'),
    OpenFoodFactsLanguage.ESTONIAN:
        LanguageName(englishName: 'Estonian', nameInLanguage: 'eestikeel'),
    OpenFoodFactsLanguage.EWE:
        LanguageName(englishName: 'Ewe', nameInLanguage: 'Eʋegbe'),
    OpenFoodFactsLanguage.BASQUE:
        LanguageName(englishName: 'Basque', nameInLanguage: 'euskara'),
    OpenFoodFactsLanguage.PERSIAN:
        LanguageName(englishName: 'Persian', nameInLanguage: 'فارسی'),
    OpenFoodFactsLanguage.FINNISH:
        LanguageName(englishName: 'Finnish', nameInLanguage: 'Suomalainen'),
    OpenFoodFactsLanguage.FAROESE:
        LanguageName(englishName: 'Faroese', nameInLanguage: 'Faroese'),
    OpenFoodFactsLanguage.FRENCH:
        LanguageName(englishName: 'French', nameInLanguage: 'Français'),
    OpenFoodFactsLanguage.FIJIAN_LANGUAGE:
        LanguageName(englishName: 'Fijian', nameInLanguage: 'Fijian'),
    OpenFoodFactsLanguage.FULA_LANGUAGE:
        LanguageName(englishName: 'Fula', nameInLanguage: 'Fula'),
    OpenFoodFactsLanguage.IRISH:
        LanguageName(englishName: 'Irish', nameInLanguage: 'Gaeilge'),
    OpenFoodFactsLanguage.SCOTTISH_GAELIC: LanguageName(
        englishName: 'ScotsGaelic', nameInLanguage: 'ScottishGaelic'),
    OpenFoodFactsLanguage.GALICIAN:
        LanguageName(englishName: 'Galician', nameInLanguage: 'galego'),
    OpenFoodFactsLanguage.GREENLANDIC:
        LanguageName(englishName: 'Greenlandic', nameInLanguage: 'Greenlandic'),
    OpenFoodFactsLanguage.GIKUYU:
        LanguageName(englishName: 'Gikuyu', nameInLanguage: 'Gikuyu'),
    OpenFoodFactsLanguage.GUARANI:
        LanguageName(englishName: 'Guaraní', nameInLanguage: 'Guaraní'),
    OpenFoodFactsLanguage.GUJARATI:
        LanguageName(englishName: 'Gujarati', nameInLanguage: 'ગુજરાતી'),
    OpenFoodFactsLanguage.HAUSA:
        LanguageName(englishName: 'Hausa', nameInLanguage: 'હૌસા'),
    OpenFoodFactsLanguage.HEBREW:
        LanguageName(englishName: 'Hebrew', nameInLanguage: 'עִברִית'),
    OpenFoodFactsLanguage.HERERO:
        LanguageName(englishName: 'Herero', nameInLanguage: 'Herero'),
    OpenFoodFactsLanguage.HINDI:
        LanguageName(englishName: 'Hindi', nameInLanguage: 'हिन्दी'),
    OpenFoodFactsLanguage.HIRI_MOTU:
        LanguageName(englishName: 'HiriMotu', nameInLanguage: 'HiriMotu'),
    OpenFoodFactsLanguage.CROATIAN:
        LanguageName(englishName: 'Croatian', nameInLanguage: 'Hrvatski'),
    OpenFoodFactsLanguage.HAITIAN_CREOLE:
        LanguageName(englishName: 'HaitianCreole', nameInLanguage: 'ayisyen'),
    OpenFoodFactsLanguage.HUNGARIAN:
        LanguageName(englishName: 'Hungarian', nameInLanguage: 'Magyar'),
    OpenFoodFactsLanguage.ARMENIAN:
        LanguageName(englishName: 'Armenian', nameInLanguage: 'հայերեն'),
    OpenFoodFactsLanguage.INDONESIAN: LanguageName(
        englishName: 'Indonesian', nameInLanguage: 'bahasaIndonesia'),
    OpenFoodFactsLanguage.NUOSU_LANGUAGE:
        LanguageName(englishName: 'SichuanYi', nameInLanguage: 'SichuanYi'),
    OpenFoodFactsLanguage.ICELANDIC:
        LanguageName(englishName: 'Icelandic', nameInLanguage: 'íslenskur'),
    OpenFoodFactsLanguage.IDO:
        LanguageName(englishName: 'Ido', nameInLanguage: 'Ido'),
    OpenFoodFactsLanguage.ITALIAN:
        LanguageName(englishName: 'Italian', nameInLanguage: 'Italiano'),
    OpenFoodFactsLanguage.INUKTITUT:
        LanguageName(englishName: 'Inuktitut', nameInLanguage: 'Inuktitut'),
    OpenFoodFactsLanguage.INTERLINGUA:
        LanguageName(englishName: 'Interlingua', nameInLanguage: 'Interlingua'),
    OpenFoodFactsLanguage.INUPIAT_LANGUAGE:
        LanguageName(englishName: 'Inupiaq', nameInLanguage: 'Inupiaq'),
    OpenFoodFactsLanguage.INTERLINGUE:
        LanguageName(englishName: 'Interlingue', nameInLanguage: 'Interlingue'),
    OpenFoodFactsLanguage.IGBO_LANGUAGE:
        LanguageName(englishName: 'Igbo', nameInLanguage: 'Igbo'),
    OpenFoodFactsLanguage.JAPANESE:
        LanguageName(englishName: 'Japanese', nameInLanguage: '日本語'),
    OpenFoodFactsLanguage.JAVANESE:
        LanguageName(englishName: 'Javanese', nameInLanguage: 'basajawa'),
    OpenFoodFactsLanguage.GEORGIAN:
        LanguageName(englishName: 'Georgian', nameInLanguage: 'ქართული'),
    OpenFoodFactsLanguage.KANURI:
        LanguageName(englishName: 'Kanuri', nameInLanguage: 'Kanuri'),
    OpenFoodFactsLanguage.KASHMIRI:
        LanguageName(englishName: 'Kashmiri', nameInLanguage: 'कश्मीरी'),
    OpenFoodFactsLanguage.KAZAKH:
        LanguageName(englishName: 'Kazakh', nameInLanguage: 'қазақ'),
    OpenFoodFactsLanguage.KANNADA:
        LanguageName(englishName: 'Kannada', nameInLanguage: 'ಕನ್ನಡ'),
    OpenFoodFactsLanguage.KINYARWANDA:
        LanguageName(englishName: 'Kinyarwanda', nameInLanguage: 'Kinyarwanda'),
    OpenFoodFactsLanguage.KOREAN:
        LanguageName(englishName: 'Korean', nameInLanguage: '한국인'),
    OpenFoodFactsLanguage.KOMI:
        LanguageName(englishName: 'Komi', nameInLanguage: 'коми кыв'),
    OpenFoodFactsLanguage.KONGO_LANGUAGE:
        LanguageName(englishName: 'Kongo', nameInLanguage: 'Kongo'),
    OpenFoodFactsLanguage.KURDISH:
        LanguageName(englishName: 'Kurdish', nameInLanguage: 'Kurdî'),
    OpenFoodFactsLanguage.KWANYAMA:
        LanguageName(englishName: 'Kwanyama', nameInLanguage: 'Kwanyama'),
    OpenFoodFactsLanguage.CORNISH:
        LanguageName(englishName: 'Cornish', nameInLanguage: 'Cornish'),
    OpenFoodFactsLanguage.KIRUNDI:
        LanguageName(englishName: 'Kirundi', nameInLanguage: 'Kirundi'),
    OpenFoodFactsLanguage.KYRGYZ:
        LanguageName(englishName: 'Kirghiz', nameInLanguage: 'Кыргызча'),
    OpenFoodFactsLanguage.LATIN:
        LanguageName(englishName: 'Latin', nameInLanguage: 'latīnum'),
    OpenFoodFactsLanguage.LUXEMBOURGISH: LanguageName(
        englishName: 'Luxembourgish', nameInLanguage: 'lëtzebuergesch'),
    OpenFoodFactsLanguage.LAO:
        LanguageName(englishName: 'Lao', nameInLanguage: 'ພາສາລາວ'),
    OpenFoodFactsLanguage.LATVIAN:
        LanguageName(englishName: 'Latvian', nameInLanguage: 'latviski'),
    OpenFoodFactsLanguage.LITHUANIAN:
        LanguageName(englishName: 'Lithuanian', nameInLanguage: 'lietuvių'),
    OpenFoodFactsLanguage.LINGALA_LANGUAGE:
        LanguageName(englishName: 'Lingala', nameInLanguage: 'Lingala'),
    OpenFoodFactsLanguage.LIMBURGISH_LANGUAGE:
        LanguageName(englishName: 'Limburgish', nameInLanguage: 'Limburgish'),
    OpenFoodFactsLanguage.LUBA_KATANGA_LANGUAGE: LanguageName(
        englishName: 'Luba Katanga', nameInLanguage: 'Luba Katanga'),
    OpenFoodFactsLanguage.LUGANDA:
        LanguageName(englishName: 'Luganda', nameInLanguage: 'Luganda'),
    OpenFoodFactsLanguage.MALAGASY:
        LanguageName(englishName: 'Malagasy', nameInLanguage: 'Malagasy'),
    OpenFoodFactsLanguage.MACEDONIAN:
        LanguageName(englishName: 'Macedonian', nameInLanguage: 'македонски'),
    OpenFoodFactsLanguage.MAORI:
        LanguageName(englishName: 'Maori', nameInLanguage: 'മലയാളം'),
    OpenFoodFactsLanguage.MARSHALLESE:
        LanguageName(englishName: 'Marshallese', nameInLanguage: 'Ebon'),
    OpenFoodFactsLanguage.MONGOLIAN:
        LanguageName(englishName: 'Mongolian', nameInLanguage: 'Монгол'),
    OpenFoodFactsLanguage.MANX:
        LanguageName(englishName: 'Manx', nameInLanguage: 'Gaelg'),
    OpenFoodFactsLanguage.MARATHI:
        LanguageName(englishName: 'Marathi', nameInLanguage: 'मराठी'),
    OpenFoodFactsLanguage.MALAY:
        LanguageName(englishName: 'Malay', nameInLanguage: 'Melayu'),
    OpenFoodFactsLanguage.MALAYALAM:
        LanguageName(englishName: 'Malayalam', nameInLanguage: 'മലയാളം'),
    OpenFoodFactsLanguage.MALDIVIAN_LANGUAGE:
        LanguageName(englishName: 'Maldivian', nameInLanguage: 'Maldivian'),
    OpenFoodFactsLanguage.MALTESE:
        LanguageName(englishName: 'Maltese', nameInLanguage: 'Malti'),
    OpenFoodFactsLanguage.MOLDOVAN:
        LanguageName(englishName: 'Moldovan', nameInLanguage: 'Moldovenească'),
    OpenFoodFactsLanguage.BURMESE:
        LanguageName(englishName: 'Burmese', nameInLanguage: 'မြန်မာဘာသာ'),
    OpenFoodFactsLanguage.BOKMAL: LanguageName(
        englishName: 'NorwegianBokmål', nameInLanguage: 'Norskbokmål'),
    OpenFoodFactsLanguage.NAVAJO:
        LanguageName(englishName: 'Navajo', nameInLanguage: 'Diné bizaad'),
    OpenFoodFactsLanguage.NEPALI:
        LanguageName(englishName: 'Nepali', nameInLanguage: 'नेपाली'),
    OpenFoodFactsLanguage.NAURUAN:
        LanguageName(englishName: 'Nauruan', nameInLanguage: 'Nauru'),
    OpenFoodFactsLanguage.NDONGA_DIALECT:
        LanguageName(englishName: 'Ndonga', nameInLanguage: 'Ndonga'),
    OpenFoodFactsLanguage.DUTCH:
        LanguageName(englishName: 'Dutch', nameInLanguage: 'Nederlands'),
    OpenFoodFactsLanguage.NYNORSK: LanguageName(
        englishName: 'NorwegianNynorsk', nameInLanguage: 'Norsknynorsk'),
    OpenFoodFactsLanguage.NORWEGIAN:
        LanguageName(englishName: 'Norwegian', nameInLanguage: 'norsk'),
    OpenFoodFactsLanguage.NORTHERN_NDEBELE_LANGUAGE: LanguageName(
        englishName: 'Northern Ndebele', nameInLanguage: 'Northern Ndebele'),
    OpenFoodFactsLanguage.NORTHERN_SAMI: LanguageName(
        englishName: 'Northern Sami', nameInLanguage: 'Sámegiella'),
    OpenFoodFactsLanguage.SAMOAN:
        LanguageName(englishName: 'Samoan', nameInLanguage: 'Gagana Sāmoa'),
    OpenFoodFactsLanguage.SOUTHERN_NDEBELE: LanguageName(
        englishName: 'SouthNdebele', nameInLanguage: 'SouthNdebele'),
    OpenFoodFactsLanguage.OCCITAN:
        LanguageName(englishName: 'Occitan', nameInLanguage: 'Occitan'),
    OpenFoodFactsLanguage.OLD_CHURCH_SLAVONIC: LanguageName(
        englishName: 'Old Church Slavonic',
        nameInLanguage: 'Old Church Slavonic'),
    OpenFoodFactsLanguage.OSSETIAN:
        LanguageName(englishName: 'Ossetian', nameInLanguage: 'Ossetian'),
    OpenFoodFactsLanguage.OROMO:
        LanguageName(englishName: 'Oromo', nameInLanguage: 'Oromoo'),
    OpenFoodFactsLanguage.ODIA:
        LanguageName(englishName: 'Odia', nameInLanguage: 'ଓଡ଼ିଆ'),
    OpenFoodFactsLanguage.OJIBWE:
        LanguageName(englishName: 'Ojibwe', nameInLanguage: 'ᐊᓂᔑᓈᐯᒧᐎᓐ'),
    OpenFoodFactsLanguage.PALI:
        LanguageName(englishName: 'Pali', nameInLanguage: 'Pali'),
    OpenFoodFactsLanguage.PASHTO:
        LanguageName(englishName: 'Pashto', nameInLanguage: 'پښتو'),
    OpenFoodFactsLanguage.PUNJABI:
        LanguageName(englishName: 'Panjabi', nameInLanguage: 'Panjabi'),
    OpenFoodFactsLanguage.POLISH:
        LanguageName(englishName: 'Polish', nameInLanguage: 'Polski'),
    OpenFoodFactsLanguage.PORTUGUESE:
        LanguageName(englishName: 'Portuguese', nameInLanguage: 'Português'),
    OpenFoodFactsLanguage.QUECHUA_LANGUAGES:
        LanguageName(englishName: 'Quechua', nameInLanguage: 'Runasimi'),
    OpenFoodFactsLanguage.ROMANSH:
        LanguageName(englishName: 'Romansh', nameInLanguage: 'Romansh'),
    OpenFoodFactsLanguage.ROMANIAN:
        LanguageName(englishName: 'Romanian', nameInLanguage: 'Română'),
    OpenFoodFactsLanguage.RUSSIAN:
        LanguageName(englishName: 'Russian', nameInLanguage: 'Русский'),
    OpenFoodFactsLanguage.SANSKRIT:
        LanguageName(englishName: 'Sanskrit', nameInLanguage: 'संस्कृत'),
    OpenFoodFactsLanguage.SARDINIAN_LANGUAGE:
        LanguageName(englishName: 'Sardinian', nameInLanguage: 'Sardinian'),
    OpenFoodFactsLanguage.SINDHI:
        LanguageName(englishName: 'Sindhi', nameInLanguage: 'سنڌي'),
    OpenFoodFactsLanguage.SANGO:
        LanguageName(englishName: 'Sangro', nameInLanguage: 'Sango'),
    OpenFoodFactsLanguage.SINHALA:
        LanguageName(englishName: 'Sinhala', nameInLanguage: 'සිංහල'),
    OpenFoodFactsLanguage.SLOVAK:
        LanguageName(englishName: 'Slovak', nameInLanguage: 'Slovenčina'),
    OpenFoodFactsLanguage.SLOVENE:
        LanguageName(englishName: 'Slovenian', nameInLanguage: 'Slovenščina'),
    OpenFoodFactsLanguage.SHONA:
        LanguageName(englishName: 'Shona', nameInLanguage: 'Shona'),
    OpenFoodFactsLanguage.SOMALI:
        LanguageName(englishName: 'Somali', nameInLanguage: 'Soomaali'),
    OpenFoodFactsLanguage.ALBANIAN:
        LanguageName(englishName: 'Albanian', nameInLanguage: 'shqiptare'),
    OpenFoodFactsLanguage.SERBIAN:
        LanguageName(englishName: 'Serbian', nameInLanguage: 'Српски'),
    OpenFoodFactsLanguage.SWAZI:
        LanguageName(englishName: 'Swati', nameInLanguage: 'Swati'),
    OpenFoodFactsLanguage.SOTHO: LanguageName(
        englishName: 'SouthernSotho', nameInLanguage: 'SouthernSotho'),
    OpenFoodFactsLanguage.SUNDANESE_LANGUAGE:
        LanguageName(englishName: 'Sundanese', nameInLanguage: 'Basa Sunda'),
    OpenFoodFactsLanguage.SWEDISH:
        LanguageName(englishName: 'Swedish', nameInLanguage: 'svenska'),
    OpenFoodFactsLanguage.SWAHILI:
        LanguageName(englishName: 'Swahili', nameInLanguage: 'kiswahili'),
    OpenFoodFactsLanguage.TAMIL:
        LanguageName(englishName: 'Tamil', nameInLanguage: 'தமிழ்'),
    OpenFoodFactsLanguage.TELUGU:
        LanguageName(englishName: 'Telugu', nameInLanguage: 'తెలుగు'),
    OpenFoodFactsLanguage.TAJIK:
        LanguageName(englishName: 'Tajik', nameInLanguage: 'тоҷикӣ'),
    OpenFoodFactsLanguage.THAI:
        LanguageName(englishName: 'Thai', nameInLanguage: 'ไทย'),
    OpenFoodFactsLanguage.TIGRINYA:
        LanguageName(englishName: 'Tigrinya', nameInLanguage: 'ትግሪኛ'),
    OpenFoodFactsLanguage.TAGALOG:
        LanguageName(englishName: 'Tagalog', nameInLanguage: 'Tagalog'),
    OpenFoodFactsLanguage.TSWANA:
        LanguageName(englishName: 'Setswana', nameInLanguage: 'Setswana'),
    OpenFoodFactsLanguage.TURKISH:
        LanguageName(englishName: 'Turkish', nameInLanguage: 'Türk'),
    OpenFoodFactsLanguage.TURKMEN:
        LanguageName(englishName: 'Turkmen', nameInLanguage: 'Türkmen'),
    OpenFoodFactsLanguage.TSONGA:
        LanguageName(englishName: 'Tsonga', nameInLanguage: 'Tsonga'),
    OpenFoodFactsLanguage.TATAR:
        LanguageName(englishName: 'Tatar', nameInLanguage: 'Татар'),
    OpenFoodFactsLanguage.TONGAN_LANGUAGE:
        LanguageName(englishName: 'Tongan', nameInLanguage: 'Tongan'),
    OpenFoodFactsLanguage.TWI:
        LanguageName(englishName: 'Twi', nameInLanguage: 'Twi'),
    OpenFoodFactsLanguage.TAHITIAN:
        LanguageName(englishName: 'Tahitian', nameInLanguage: 'Tahitian'),
    OpenFoodFactsLanguage.UYGHUR:
        LanguageName(englishName: 'Uighur', nameInLanguage: 'ئۇيغۇر'),
    OpenFoodFactsLanguage.UKRAINIAN:
        LanguageName(englishName: 'Ukrainian', nameInLanguage: 'Українська'),
    OpenFoodFactsLanguage.URDU:
        LanguageName(englishName: 'Urdu', nameInLanguage: 'اردو'),
    OpenFoodFactsLanguage.UZBEK:
        LanguageName(englishName: 'Uzbek', nameInLanguage: '"ozbek"'),
    OpenFoodFactsLanguage.VENDA:
        LanguageName(englishName: 'Venda', nameInLanguage: 'Venda'),
    OpenFoodFactsLanguage.VIETNAMESE:
        LanguageName(englishName: 'Vietnamese', nameInLanguage: 'TiếngViệt'),
    OpenFoodFactsLanguage.VOLAPUK:
        LanguageName(englishName: 'Volapuk', nameInLanguage: 'Volapuk'),
    OpenFoodFactsLanguage.WEST_FRISIAN: LanguageName(
        englishName: 'West Frisian', nameInLanguage: 'West Frisian'),
    OpenFoodFactsLanguage.WOLOF:
        LanguageName(englishName: 'Wolof', nameInLanguage: 'Wolof'),
    OpenFoodFactsLanguage.XHOSA:
        LanguageName(englishName: 'Xhosa', nameInLanguage: 'isiXhosa'),
    OpenFoodFactsLanguage.YIDDISH:
        LanguageName(englishName: 'Yiddish', nameInLanguage: 'יידיש'),
    OpenFoodFactsLanguage.YORUBA:
        LanguageName(englishName: 'Yoruba', nameInLanguage: 'Yoruba'),
    OpenFoodFactsLanguage.CHINESE:
        LanguageName(englishName: 'Chinese', nameInLanguage: '中文'),
    OpenFoodFactsLanguage.ZHUANG_LANGUAGES:
        LanguageName(englishName: 'Zhuang', nameInLanguage: 'Zhuang'),
    OpenFoodFactsLanguage.ZULU:
        LanguageName(englishName: 'Zulu', nameInLanguage: 'ខ្មែរ'),
  };

  List<Pair<String, OpenFoodFactsLanguage>> getSupportedLanguagesEnglishName() {
    final List<Pair<String, OpenFoodFactsLanguage>> languages =
        <Pair<String, OpenFoodFactsLanguage>>[];
    openFoodFactsLanguagesList.forEach(
        (OpenFoodFactsLanguage language, LanguageName languageName) => <void>{
              if (delegate.isSupported(Locale(language.code)))
                <void>{
                  languages.add(Pair<String, OpenFoodFactsLanguage>(
                      first: languageName.englishName, second: language))
                }
            });
    return languages;
  }

  LanguageName getLanguageNameFromLangCode(String langCode) {
    OpenFoodFactsLanguage openFoodFactsLanguage = OpenFoodFactsLanguage.ENGLISH;

    openFoodFactsLanguagesList.forEach(
        (OpenFoodFactsLanguage language, LanguageName languageName) => <void>{
              if (language.code == langCode) openFoodFactsLanguage = language
            });
    return openFoodFactsLanguagesList[openFoodFactsLanguage]!;
  }

  LanguageName getLanguageName(OpenFoodFactsLanguage offlc) {
    if (openFoodFactsLanguagesList.containsKey(offlc)) {
      return openFoodFactsLanguagesList[offlc]!;
    }
    // Unreachable Code
    return openFoodFactsLanguagesList[OpenFoodFactsLanguage.ENGLISH]!;
  }
}
