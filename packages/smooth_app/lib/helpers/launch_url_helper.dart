import 'dart:io';

import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlHelper {
  LaunchUrlHelper._();

  /// Launches the url in an external browser.
  static Future<void> launchURL(String url) async {
    AnalyticsHelper.trackOutlink(url: url);

    try {
      await launchUrl(
        Uri.parse(url),
        mode: Platform.isAndroid
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } catch (e) {
      throw 'Could not launch $url,Error: $e';
    }
  }
}
