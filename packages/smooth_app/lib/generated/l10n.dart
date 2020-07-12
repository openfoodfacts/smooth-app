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

  /// `Enter a barcode, category or product name`
  String get searchHintText {
    return Intl.message(
      'Enter a barcode, category or product name',
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

  /// `showAll`
  String get showAll {
    return Intl.message(
      'showAll',
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

  /// `Collaboration Page`
  String get collaborationPage {
    return Intl.message(
      'Collaboration Page',
      name: 'collaborationPage',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
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