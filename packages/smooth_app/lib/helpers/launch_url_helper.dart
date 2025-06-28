import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlHelper {
  const LaunchUrlHelper._();

  static Future<void> launchURLAndFollowDeepLinks(
    BuildContext context,
    String url,
  ) async {
    assert(url.isNotEmpty);

    if (url.startsWith(
      RegExp(
        r'http(s)?://[a-z\-]*.open(food|beauty|products|petfood)facts.(net|org)',
      ),
    )) {
      AnalyticsHelper.trackOutlink(url: url);
      GoRouter.of(context).push(url);
    } else {
      return launchURL(url);
    }
  }

  /// Launches the url in an external browser.
  static Future<void> launchURL(String url, {LaunchMode? mode}) async {
    AnalyticsHelper.trackOutlink(url: url);

    try {
      await launchUrl(
        Uri.parse(url),
        mode:
            mode ??
            (Platform.isAndroid
                ? LaunchMode.externalApplication
                : LaunchMode.platformDefault),
      );
    } catch (e) {
      throw 'Could not launch $url,Error: $e';
    }
  }

  /// Launches the URL in a WebView if it's an OFF link or an external browser.
  static Future<void> launchURLInWebViewOrBrowser(
    BuildContext context,
    String url, {
    LaunchMode? mode,
  }) async {
    if (url.startsWith(
      RegExp(
        r'http(s)?://[a-z\-]*.open(food|beauty|products|petfood)facts.(net|org)',
      ),
    )) {
      AppNavigator.of(context).push(AppRoutes.EXTERNAL_WEBVIEW(url));
    } else {
      return launchURL(url, mode: mode);
    }
  }
}
