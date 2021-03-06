// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  ///
  /// ifOFF (is Open Food Facts)
  /// when true add language identifier at start
  ///
  /// !!!
  /// NO  https://de.openfoodfacts.org/...
  /// YES https://   openfoodfacts.org/...
  /// !!!
  ///

  Future<void> launchURL(BuildContext context, String url, bool isOFF) async {
    String openURL;
    String localeString;

    if (isOFF) {
      //Get countrycode

      final Locale locale = Localizations.localeOf(context);
      if (locale.countryCode.toString() == null) {
        localeString = 'world.';
      } else {
        localeString = '${locale.countryCode.toString()}.';
      }
      print('locale = $localeString');

      //Check + Add to url
      if (!url.contains('https://openfoodfacts')) {
        throw 'Error do not use local identifier';
      }
      print('url1 $url');
      //url.replaceAll(from, replace)
      openURL = url.replaceAll('https://openfoodfacts.org/',
          'https://${localeString}openfoodfacts.org/');
    } else {
      openURL = url;
    }

    if (await canLaunch(openURL)) {
      await launch(openURL);
    } else {
      throw 'Could not launch $url';
    }
    return;
  }
}
