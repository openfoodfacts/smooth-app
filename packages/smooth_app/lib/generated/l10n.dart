// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Search.\nFind the perfect product`
  String get searchTitle {
    return Intl.message(
      'Search.\nFind the perfect product',
      name: 'searchTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter a barcode or keywords`
  String get searchHintText {
    return Intl.message(
      'Enter a barcode or keywords',
      name: 'searchHintText',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Show all`
  String get showAll {
    return Intl.message(
      'Show all',
      name: 'showAll',
      desc: '',
      args: [],
    );
  }

  /// `Scan products`
  String get scanProductTitle {
    return Intl.message(
      'Scan products',
      name: 'scanProductTitle',
      desc: '',
      args: [],
    );
  }

  /// `Testers settings`
  String get testerSettingTitle {
    return Intl.message(
      'Testers settings',
      name: 'testerSettingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use ML Kit powered scanner`
  String get useMLKitText {
    return Intl.message(
      'Use ML Kit powered scanner',
      name: 'useMLKitText',
      desc: '',
      args: [],
    );
  }

  /// `Organization Page`
  String get organizationPage {
    return Intl.message(
      'Organization Page',
      name: 'organizationPage',
      desc: '',
      args: [],
    );
  }

  /// `Contribution Page`
  String get contributionPage {
    return Intl.message(
      'Contribution Page',
      name: 'contributionPage',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Page`
  String get trackingPage {
    return Intl.message(
      'Tracking Page',
      name: 'trackingPage',
      desc: '',
      args: [],
    );
  }

  /// `My Preferences`
  String get preferencesText {
    return Intl.message(
      'My Preferences',
      name: 'preferencesText',
      desc: '',
      args: [],
    );
  }

  /// `Mandatory`
  String get mandatory {
    return Intl.message(
      'Mandatory',
      name: 'mandatory',
      desc: '',
      args: [],
    );
  }

  /// `Accountable`
  String get accountable {
    return Intl.message(
      'Accountable',
      name: 'accountable',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get saveButtonText {
    return Intl.message(
      'Save',
      name: 'saveButtonText',
      desc: '',
      args: [],
    );
  }

  /// `My personalized ranking`
  String get myPersonalizedRanking {
    return Intl.message(
      'My personalized ranking',
      name: 'myPersonalizedRanking',
      desc: '',
      args: [],
    );
  }

  /// `Products you scan will appear here`
  String get scannerProductsEmpty {
    return Intl.message(
      'Products you scan will appear here',
      name: 'scannerProductsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `We're still working on this feature, stay tuned`
  String get featureInProgress {
    return Intl.message(
      'We\'re still working on this feature, stay tuned',
      name: 'featureInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Configure my preferences`
  String get configurePreferences {
    return Intl.message(
      'Configure my preferences',
      name: 'configurePreferences',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Unknown brand`
  String get unknownBrand {
    return Intl.message(
      'Unknown brand',
      name: 'unknownBrand',
      desc: '',
      args: [],
    );
  }

  /// `Unknown product name`
  String get unknownProductName {
    return Intl.message(
      'Unknown product name',
      name: 'unknownProductName',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition`
  String get nutrition {
    return Intl.message(
      'Nutrition',
      name: 'nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Ingredients`
  String get ingredients {
    return Intl.message(
      'Ingredients',
      name: 'ingredients',
      desc: '',
      args: [],
    );
  }

  /// `Ecology`
  String get ecology {
    return Intl.message(
      'Ecology',
      name: 'ecology',
      desc: '',
      args: [],
    );
  }

  /// `My preferences`
  String get myPreferences {
    return Intl.message(
      'My preferences',
      name: 'myPreferences',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'aa', countryCode: 'ER'),
      Locale.fromSubtags(languageCode: 'ach'),
      Locale.fromSubtags(languageCode: 'af', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'ak', countryCode: 'GH'),
      Locale.fromSubtags(languageCode: 'am', countryCode: 'ET'),
      Locale.fromSubtags(languageCode: 'ar', countryCode: 'SA'),
      Locale.fromSubtags(languageCode: 'as', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ast'),
      Locale.fromSubtags(languageCode: 'az', countryCode: 'AZ'),
      Locale.fromSubtags(languageCode: 'be', countryCode: 'BY'),
      Locale.fromSubtags(languageCode: 'ber'),
      Locale.fromSubtags(languageCode: 'bg', countryCode: 'BG'),
      Locale.fromSubtags(languageCode: 'bm', countryCode: 'ML'),
      Locale.fromSubtags(languageCode: 'bn', countryCode: 'BD'),
      Locale.fromSubtags(languageCode: 'bo', countryCode: 'BT'),
      Locale.fromSubtags(languageCode: 'br', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'bs', countryCode: 'BA'),
      Locale.fromSubtags(languageCode: 'ca', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'ce', countryCode: 'CE'),
      Locale.fromSubtags(languageCode: 'chr'),
      Locale.fromSubtags(languageCode: 'co', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'crs'),
      Locale.fromSubtags(languageCode: 'cs', countryCode: 'CZ'),
      Locale.fromSubtags(languageCode: 'cv', countryCode: 'CU'),
      Locale.fromSubtags(languageCode: 'cy', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'da', countryCode: 'DK'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'el', countryCode: 'GR'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'AU'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'eo', countryCode: 'UY'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'et', countryCode: 'EE'),
      Locale.fromSubtags(languageCode: 'eu', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'fa', countryCode: 'IR'),
      Locale.fromSubtags(languageCode: 'fi', countryCode: 'FI'),
      Locale.fromSubtags(languageCode: 'fil'),
      Locale.fromSubtags(languageCode: 'fo', countryCode: 'FO'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'ga', countryCode: 'IE'),
      Locale.fromSubtags(languageCode: 'gd', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'gl', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'gu', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ha', countryCode: 'HG'),
      Locale.fromSubtags(languageCode: 'he', countryCode: 'IL'),
      Locale.fromSubtags(languageCode: 'hi', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'hr', countryCode: 'HR'),
      Locale.fromSubtags(languageCode: 'ht', countryCode: 'HT'),
      Locale.fromSubtags(languageCode: 'hu', countryCode: 'HU'),
      Locale.fromSubtags(languageCode: 'hy', countryCode: 'AM'),
      Locale.fromSubtags(languageCode: 'id', countryCode: 'ID'),
      Locale.fromSubtags(languageCode: 'ii', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'is', countryCode: 'IS'),
      Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      Locale.fromSubtags(languageCode: 'iu', countryCode: 'NU'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
      Locale.fromSubtags(languageCode: 'jv', countryCode: 'ID'),
      Locale.fromSubtags(languageCode: 'ka', countryCode: 'GE'),
      Locale.fromSubtags(languageCode: 'kab'),
      Locale.fromSubtags(languageCode: 'kk', countryCode: 'KZ'),
      Locale.fromSubtags(languageCode: 'km', countryCode: 'KH'),
      Locale.fromSubtags(languageCode: 'kn', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ko', countryCode: 'KR'),
      Locale.fromSubtags(languageCode: 'ku', countryCode: 'TR'),
      Locale.fromSubtags(languageCode: 'kw', countryCode: 'GB'),
      Locale.fromSubtags(languageCode: 'ky', countryCode: 'KG'),
      Locale.fromSubtags(languageCode: 'la', countryCode: 'LA'),
      Locale.fromSubtags(languageCode: 'lb', countryCode: 'LU'),
      Locale.fromSubtags(languageCode: 'lo', countryCode: 'LA'),
      Locale.fromSubtags(languageCode: 'lol'),
      Locale.fromSubtags(languageCode: 'lt', countryCode: 'LT'),
      Locale.fromSubtags(languageCode: 'lv', countryCode: 'LV'),
      Locale.fromSubtags(languageCode: 'mg', countryCode: 'MG'),
      Locale.fromSubtags(languageCode: 'mi', countryCode: 'NZ'),
      Locale.fromSubtags(languageCode: 'ml', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'mn', countryCode: 'MN'),
      Locale.fromSubtags(languageCode: 'mr', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'ms', countryCode: 'MY'),
      Locale.fromSubtags(languageCode: 'mt', countryCode: 'MT'),
      Locale.fromSubtags(languageCode: 'my', countryCode: 'MM'),
      Locale.fromSubtags(languageCode: 'nb', countryCode: 'NO'),
      Locale.fromSubtags(languageCode: 'ne', countryCode: 'NP'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'BE'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL'),
      Locale.fromSubtags(languageCode: 'nn', countryCode: 'NO'),
      Locale.fromSubtags(languageCode: 'no', countryCode: 'NO'),
      Locale.fromSubtags(languageCode: 'nr', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'oc', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'pa', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
      Locale.fromSubtags(languageCode: 'qu', countryCode: 'PE'),
      Locale.fromSubtags(languageCode: 'rm', countryCode: 'CH'),
      Locale.fromSubtags(languageCode: 'ro', countryCode: 'RO'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'sa', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'sat'),
      Locale.fromSubtags(languageCode: 'sc', countryCode: 'IT'),
      Locale.fromSubtags(languageCode: 'sco'),
      Locale.fromSubtags(languageCode: 'sd', countryCode: 'PK'),
      Locale.fromSubtags(languageCode: 'sg', countryCode: 'CF'),
      Locale.fromSubtags(languageCode: 'si', countryCode: 'LK'),
      Locale.fromSubtags(languageCode: 'sk', countryCode: 'SK'),
      Locale.fromSubtags(languageCode: 'sl', countryCode: 'SI'),
      Locale.fromSubtags(languageCode: 'sma'),
      Locale.fromSubtags(languageCode: 'sn', countryCode: 'ZW'),
      Locale.fromSubtags(languageCode: 'so', countryCode: 'SO'),
      Locale.fromSubtags(languageCode: 'son'),
      Locale.fromSubtags(languageCode: 'sq', countryCode: 'AL'),
      Locale.fromSubtags(languageCode: 'sr', countryCode: 'CS'),
      Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Cyrl', countryCode: 'ME'),
      Locale.fromSubtags(languageCode: 'sr', countryCode: 'SP'),
      Locale.fromSubtags(languageCode: 'ss', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'st', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'sv', countryCode: 'SE'),
      Locale.fromSubtags(languageCode: 'sw', countryCode: 'KE'),
      Locale.fromSubtags(languageCode: 'ta', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'te', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'tg', countryCode: 'TJ'),
      Locale.fromSubtags(languageCode: 'th', countryCode: 'TH'),
      Locale.fromSubtags(languageCode: 'ti', countryCode: 'ER'),
      Locale.fromSubtags(languageCode: 'tl', countryCode: 'PH'),
      Locale.fromSubtags(languageCode: 'tn', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
      Locale.fromSubtags(languageCode: 'ts', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'tt', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'tw', countryCode: 'TW'),
      Locale.fromSubtags(languageCode: 'ty', countryCode: 'PF'),
      Locale.fromSubtags(languageCode: 'tzl'),
      Locale.fromSubtags(languageCode: 'ug', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'uk', countryCode: 'UA'),
      Locale.fromSubtags(languageCode: 'ur', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'uz', countryCode: 'UZ'),
      Locale.fromSubtags(languageCode: 'val'),
      Locale.fromSubtags(languageCode: 've', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'vec'),
      Locale.fromSubtags(languageCode: 'vi', countryCode: 'VN'),
      Locale.fromSubtags(languageCode: 'vls'),
      Locale.fromSubtags(languageCode: 'wa', countryCode: 'BE'),
      Locale.fromSubtags(languageCode: 'wo', countryCode: 'SN'),
      Locale.fromSubtags(languageCode: 'xh', countryCode: 'ZA'),
      Locale.fromSubtags(languageCode: 'yi', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'yo', countryCode: 'NG'),
      Locale.fromSubtags(languageCode: 'zea'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'HK'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
      Locale.fromSubtags(languageCode: 'zu', countryCode: 'ZA'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}