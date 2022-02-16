import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlHelper {
  LaunchUrlHelper._();

  /// ifOFF true adds the users country code in front of the url
  /// Throws a error when already populated
  /// YES https://   openfoodfacts.org/...
  /// NO  https://de.openfoodfacts.org/...
  ///
  static Future<void> launchURL(String url, bool isOFF) async {
    if (isOFF) {
      if (!url.contains('https://openfoodfacts.')) {
        throw 'Error do not use local identifier in url';
      }

      String? countryCode = WidgetsBinding.instance == null
          ? null
          : WidgetsBinding.instance!.window.locale.countryCode;

      if (countryCode == null) {
        countryCode = 'world.';
      } else {
        countryCode = '$countryCode.';
      }

      url = url.replaceAll(
          'https://openfoodfacts.', 'https://${countryCode}openfoodfacts.');
    }

    AnalyticsHelper.trackOpenLink(url: url);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
