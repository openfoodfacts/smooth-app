import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/string_extension.dart';

class Languages {
  factory Languages() {
    return _instance ??= const Languages._();
  }

  const Languages._();

  static Languages? _instance;

  static const LocalizationsDelegate<MaterialLocalizations> _delegate =
      GlobalMaterialLocalizations.delegate;

  static const Map<OpenFoodFactsLanguage, String> _namesInLanguage =
      <OpenFoodFactsLanguage, String>{
        OpenFoodFactsLanguage.AFAR: 'Afar',
        OpenFoodFactsLanguage.AFRIKAANS: 'Afrikaans',
        OpenFoodFactsLanguage.AKAN: 'Akan',
        OpenFoodFactsLanguage.AMHARIC: 'አማርኛ',
        OpenFoodFactsLanguage.ARABIC: 'عربى',
        OpenFoodFactsLanguage.ARAGONESE: 'Aragonés',
        OpenFoodFactsLanguage.ASSAMESE: 'অসমীয়া',
        OpenFoodFactsLanguage.AVAR: 'Авар',
        OpenFoodFactsLanguage.AVESTAN: 'Avesta',
        OpenFoodFactsLanguage.AYMARA: 'Aymar aru',
        OpenFoodFactsLanguage.AZERBAIJANI: 'Azərbaycan',
        OpenFoodFactsLanguage.BELARUSIAN: 'беларускi',
        OpenFoodFactsLanguage.BULGARIAN: 'български',
        OpenFoodFactsLanguage.BAMBARA: 'Bamanankan',
        OpenFoodFactsLanguage.BASHKIR: 'башҡорт тілі',
        OpenFoodFactsLanguage.BENGALI: 'বাংলা',
        OpenFoodFactsLanguage.BIHARI_LANGUAGES: 'Bihari Languages',
        OpenFoodFactsLanguage.BISLAMA: 'Bislama',
        OpenFoodFactsLanguage.TIBETAN_LANGUAGE: 'Tibetan',
        OpenFoodFactsLanguage.BRETON: 'Breton',
        OpenFoodFactsLanguage.BOSNIAN: 'bosanski',
        OpenFoodFactsLanguage.CATALAN: 'català',
        OpenFoodFactsLanguage.CHECHEN: 'Chechen',
        OpenFoodFactsLanguage.CHEWA: 'Chewa',
        OpenFoodFactsLanguage.CHAMORRO: 'Chamoru',
        OpenFoodFactsLanguage.CHURCH_SLAVONIC: 'Church Slavonic',
        OpenFoodFactsLanguage.CORSICAN: 'Corsu',
        OpenFoodFactsLanguage.CREE: 'ᐃᓄᒃᑎᑐᑦ',
        OpenFoodFactsLanguage.CZECH: 'čeština',
        OpenFoodFactsLanguage.CHUVASH: 'Chuvash',
        OpenFoodFactsLanguage.WELSH: 'Cymraeg',
        OpenFoodFactsLanguage.DANISH: 'dansk',
        OpenFoodFactsLanguage.DZONGKHA_LANGUAGE: 'Dzongkha',
        OpenFoodFactsLanguage.GERMAN: 'Deutsch',
        OpenFoodFactsLanguage.MODERN_GREEK: 'Ελληνικά',
        OpenFoodFactsLanguage.ENGLISH: 'English',
        OpenFoodFactsLanguage.ESPERANTO: 'Esperanto',
        OpenFoodFactsLanguage.SPANISH: 'Español',
        OpenFoodFactsLanguage.ESTONIAN: 'eestikeel',
        OpenFoodFactsLanguage.EWE: 'Eʋegbe',
        OpenFoodFactsLanguage.BASQUE: 'euskara',
        OpenFoodFactsLanguage.PERSIAN: 'فارسی',
        OpenFoodFactsLanguage.FINNISH: 'Suomi',
        OpenFoodFactsLanguage.FAROESE: 'Faroese',
        OpenFoodFactsLanguage.FRENCH: 'Français',
        OpenFoodFactsLanguage.FIJIAN_LANGUAGE: 'Fijian',
        OpenFoodFactsLanguage.FULA_LANGUAGE: 'Fula',
        OpenFoodFactsLanguage.IRISH: 'Gaeilge',
        OpenFoodFactsLanguage.SCOTTISH_GAELIC: 'ScottishGaelic',
        OpenFoodFactsLanguage.GALICIAN: 'galego',
        OpenFoodFactsLanguage.GREENLANDIC: 'Greenlandic',
        OpenFoodFactsLanguage.GIKUYU: 'Gikuyu',
        OpenFoodFactsLanguage.GUARANI: 'Guaraní',
        OpenFoodFactsLanguage.GUJARATI: 'ગુજરાતી',
        OpenFoodFactsLanguage.HAUSA: 'હૌસા',
        OpenFoodFactsLanguage.HEBREW: 'עִברִית',
        OpenFoodFactsLanguage.HERERO: 'Herero',
        OpenFoodFactsLanguage.HINDI: 'हिन्दी',
        OpenFoodFactsLanguage.HIRI_MOTU: 'HiriMotu',
        OpenFoodFactsLanguage.CROATIAN: 'Hrvatski',
        OpenFoodFactsLanguage.HAITIAN_CREOLE: 'ayisyen',
        OpenFoodFactsLanguage.HUNGARIAN: 'Magyar',
        OpenFoodFactsLanguage.ARMENIAN: 'հայերեն',
        OpenFoodFactsLanguage.INDONESIAN: 'bahasaIndonesia',
        OpenFoodFactsLanguage.NUOSU_LANGUAGE: 'SichuanYi',
        OpenFoodFactsLanguage.ICELANDIC: 'íslenskur',
        OpenFoodFactsLanguage.IDO: 'Ido',
        OpenFoodFactsLanguage.ITALIAN: 'Italiano',
        OpenFoodFactsLanguage.INUKTITUT: 'Inuktitut',
        OpenFoodFactsLanguage.INTERLINGUA: 'Interlingua',
        OpenFoodFactsLanguage.INUPIAT_LANGUAGE: 'Inupiaq',
        OpenFoodFactsLanguage.INTERLINGUE: 'Interlingue',
        OpenFoodFactsLanguage.IGBO_LANGUAGE: 'Igbo',
        OpenFoodFactsLanguage.JAPANESE: '日本語',
        OpenFoodFactsLanguage.JAVANESE: 'basajawa',
        OpenFoodFactsLanguage.GEORGIAN: 'ქართული',
        OpenFoodFactsLanguage.KANURI: 'Kanuri',
        OpenFoodFactsLanguage.KASHMIRI: 'कश्मीरी',
        OpenFoodFactsLanguage.KAZAKH: 'қазақ',
        OpenFoodFactsLanguage.KANNADA: 'ಕನ್ನಡ',
        OpenFoodFactsLanguage.KINYARWANDA: 'Kinyarwanda',
        OpenFoodFactsLanguage.KOREAN: '한국인',
        OpenFoodFactsLanguage.KOMI: 'коми кыв',
        OpenFoodFactsLanguage.KONGO_LANGUAGE: 'Kongo',
        OpenFoodFactsLanguage.KURDISH: 'Kurdî',
        OpenFoodFactsLanguage.KWANYAMA: 'Kwanyama',
        OpenFoodFactsLanguage.CORNISH: 'Cornish',
        OpenFoodFactsLanguage.KIRUNDI: 'Kirundi',
        OpenFoodFactsLanguage.KYRGYZ: 'Кыргызча',
        OpenFoodFactsLanguage.LATIN: 'latīnum',
        OpenFoodFactsLanguage.LUXEMBOURGISH: 'lëtzebuergesch',
        OpenFoodFactsLanguage.LAO: 'ພາສາລາວ',
        OpenFoodFactsLanguage.LATVIAN: 'latviski',
        OpenFoodFactsLanguage.LITHUANIAN: 'lietuvių',
        OpenFoodFactsLanguage.LINGALA_LANGUAGE: 'Lingala',
        OpenFoodFactsLanguage.LIMBURGISH_LANGUAGE: 'Limburgish',
        OpenFoodFactsLanguage.LUBA_KATANGA_LANGUAGE: 'Luba Katanga',
        OpenFoodFactsLanguage.LUGANDA: 'Luganda',
        OpenFoodFactsLanguage.MALAGASY: 'Malagasy',
        OpenFoodFactsLanguage.MACEDONIAN: 'македонски',
        OpenFoodFactsLanguage.MAORI: 'മലയാളം',
        OpenFoodFactsLanguage.MARSHALLESE: 'Ebon',
        OpenFoodFactsLanguage.MONGOLIAN: 'Монгол',
        OpenFoodFactsLanguage.MANX: 'Gaelg',
        OpenFoodFactsLanguage.MARATHI: 'मराठी',
        OpenFoodFactsLanguage.MALAY: 'Melayu',
        OpenFoodFactsLanguage.MALAYALAM: 'മലയാളം',
        OpenFoodFactsLanguage.MALDIVIAN_LANGUAGE: 'Maldivian',
        OpenFoodFactsLanguage.MALTESE: 'Malti',
        OpenFoodFactsLanguage.MOLDOVAN: 'Moldovenească',
        OpenFoodFactsLanguage.BURMESE: 'မြန်မာဘာသာ',
        OpenFoodFactsLanguage.BOKMAL: 'Norskbokmål',
        OpenFoodFactsLanguage.NAVAJO: 'Diné bizaad',
        OpenFoodFactsLanguage.NEPALI: 'नेपाली',
        OpenFoodFactsLanguage.NAURUAN: 'Nauru',
        OpenFoodFactsLanguage.NDONGA_DIALECT: 'Ndonga',
        OpenFoodFactsLanguage.DUTCH: 'Nederlands',
        OpenFoodFactsLanguage.NYNORSK: 'Norsknynorsk',
        OpenFoodFactsLanguage.NORWEGIAN: 'norsk',
        OpenFoodFactsLanguage.NORTHERN_NDEBELE_LANGUAGE: 'Northern Ndebele',
        OpenFoodFactsLanguage.NORTHERN_SAMI: 'Sámegiella',
        OpenFoodFactsLanguage.SAMOAN: 'Gagana Sāmoa',
        OpenFoodFactsLanguage.SOUTHERN_NDEBELE: 'SouthNdebele',
        OpenFoodFactsLanguage.OCCITAN: 'Occitan',
        OpenFoodFactsLanguage.OLD_CHURCH_SLAVONIC: 'Old Church Slavonic',
        OpenFoodFactsLanguage.OSSETIAN: 'Ossetian',
        OpenFoodFactsLanguage.OROMO: 'Oromoo',
        OpenFoodFactsLanguage.ODIA: 'ଓଡ଼ିଆ',
        OpenFoodFactsLanguage.OJIBWE: 'ᐊᓂᔑᓈᐯᒧᐎᓐ',
        OpenFoodFactsLanguage.PALI: 'Pali',
        OpenFoodFactsLanguage.PASHTO: 'پښتو',
        OpenFoodFactsLanguage.PUNJABI: 'Panjabi',
        OpenFoodFactsLanguage.POLISH: 'Polski',
        OpenFoodFactsLanguage.PORTUGUESE: 'Português',
        OpenFoodFactsLanguage.QUECHUA_LANGUAGES: 'Runasimi',
        OpenFoodFactsLanguage.ROMANSH: 'Romansh',
        OpenFoodFactsLanguage.ROMANIAN: 'Română',
        OpenFoodFactsLanguage.RUSSIAN: 'Русский',
        OpenFoodFactsLanguage.SANSKRIT: 'संस्कृत',
        OpenFoodFactsLanguage.SARDINIAN_LANGUAGE: 'Sardinian',
        OpenFoodFactsLanguage.SINDHI: 'سنڌي',
        OpenFoodFactsLanguage.SANGO: 'Sango',
        OpenFoodFactsLanguage.SINHALA: 'සිංහල',
        OpenFoodFactsLanguage.SLOVAK: 'Slovenčina',
        OpenFoodFactsLanguage.SLOVENE: 'Slovenščina',
        OpenFoodFactsLanguage.SHONA: 'Shona',
        OpenFoodFactsLanguage.SOMALI: 'Soomaali',
        OpenFoodFactsLanguage.ALBANIAN: 'shqiptare',
        OpenFoodFactsLanguage.SERBIAN: 'Српски',
        OpenFoodFactsLanguage.SWAZI: 'Swati',
        OpenFoodFactsLanguage.SOTHO: 'SouthernSotho',
        OpenFoodFactsLanguage.SUNDANESE_LANGUAGE: 'Basa Sunda',
        OpenFoodFactsLanguage.SWEDISH: 'svenska',
        OpenFoodFactsLanguage.SWAHILI: 'kiswahili',
        OpenFoodFactsLanguage.TAMIL: 'தமிழ்',
        OpenFoodFactsLanguage.TELUGU: 'తెలుగు',
        OpenFoodFactsLanguage.TAJIK: 'тоҷикӣ',
        OpenFoodFactsLanguage.THAI: 'ไทย',
        OpenFoodFactsLanguage.TIGRINYA: 'ትግሪኛ',
        OpenFoodFactsLanguage.TAGALOG: 'Tagalog',
        OpenFoodFactsLanguage.TSWANA: 'Setswana',
        OpenFoodFactsLanguage.TURKISH: 'Türk',
        OpenFoodFactsLanguage.TURKMEN: 'Türkmen',
        OpenFoodFactsLanguage.TSONGA: 'Tsonga',
        OpenFoodFactsLanguage.TATAR: 'Татар',
        OpenFoodFactsLanguage.TONGAN_LANGUAGE: 'Tongan',
        OpenFoodFactsLanguage.TWI: 'Twi',
        OpenFoodFactsLanguage.TAHITIAN: 'Tahitian',
        OpenFoodFactsLanguage.UYGHUR: 'ئۇيغۇر',
        OpenFoodFactsLanguage.UKRAINIAN: 'Українська',
        OpenFoodFactsLanguage.URDU: 'اردو',
        OpenFoodFactsLanguage.UZBEK: '"ozbek"',
        OpenFoodFactsLanguage.VENDA: 'Venda',
        OpenFoodFactsLanguage.VIETNAMESE: 'TiếngViệt',
        OpenFoodFactsLanguage.VOLAPUK: 'Volapuk',
        OpenFoodFactsLanguage.WEST_FRISIAN: 'West Frisian',
        OpenFoodFactsLanguage.WOLOF: 'Wolof',
        OpenFoodFactsLanguage.XHOSA: 'isiXhosa',
        OpenFoodFactsLanguage.YIDDISH: 'יידיש',
        OpenFoodFactsLanguage.YORUBA: 'Yoruba',
        OpenFoodFactsLanguage.CHINESE: '中文',
        OpenFoodFactsLanguage.ZHUANG_LANGUAGES: 'Zhuang',
        OpenFoodFactsLanguage.ZULU: 'ខ្មែរ',
      };

  List<OpenFoodFactsLanguage> getSupportedLanguagesNameInEnglish() {
    final List<OpenFoodFactsLanguage> languages = <OpenFoodFactsLanguage>[];

    _namesInLanguage.forEach((OpenFoodFactsLanguage lc, String _) {
      if (_delegate.isSupported(Locale(lc.code))) {
        languages.add(lc);
      }
    });

    return languages;
  }

  String getNameInEnglish(final OpenFoodFactsLanguage language) => language
      .toString()
      .split('.')
      .last
      .split('_')
      .join(' ')
      .toLowerCase()
      .capitalize();

  String getNameInLanguage(final OpenFoodFactsLanguage language) =>
      _namesInLanguage[language] ??
      _namesInLanguage[OpenFoodFactsLanguage.ENGLISH]!;
}
