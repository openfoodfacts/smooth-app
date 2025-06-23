import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart' as path_lib;
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';
import 'package:url_launcher/url_launcher.dart';

/// This screen is only used for deep links!
///
/// A screen opening a [path] relative to the OFF website.
///
/// Unfortunately the deep link we receive doesn't contain the base URL
/// (eg: de.openfoodfacts.org), that's why we try to guess it with the country
/// and the locale of the user
class ExternalPage extends StatefulWidget {
  const ExternalPage({
    required this.path,
    super.key,
  }) : assert(path != '');

  final String path;

  @override
  State<ExternalPage> createState() => _ExternalPageState();

  static Future<String> rewritePath(String pathUrl) async {
    if (pathUrl.startsWith('http')) {
      return pathUrl;
    }
    // First let's try with https://{country}.openfoodfacts.org
    final OpenFoodFactsCountry country = ProductQuery.getCountry();

    String? url = path_lib.join(
      'https://${country.offTag}.openfoodfacts.org',
      pathUrl,
    );

    if (await _testUrl(url)) {
      url = null;
    }

    // If that's not OK, let's try with world.openfoodfacts.org?lc={language}
    if (url == null) {
      final OpenFoodFactsLanguage language = ProductQuery.getLanguage();

      url = path_lib.join(
        'https://world.openfoodfacts.org',
        pathUrl,
      );

      url = '$url?lc=${language.offTag}';
    }

    return url;
  }

  /// Check if an URL exist
  static Future<bool> _testUrl(String url) {
    return http
        .head(Uri.parse(url))
        .then((http.Response value) => value.statusCode != 404);
  }
}

class _ExternalPageState extends State<ExternalPage> {
  @override
  void initState() {
    super.initState();

    onNextFrame(() async {
      try {
        final String url = await ExternalPage.rewritePath(widget.path);

        if (Platform.isAndroid) {
          /// Custom tabs
          WidgetsFlutterBinding.ensureInitialized();
          await tabs.launchUrl(
            Uri.parse(url),
            customTabsOptions: const tabs.CustomTabsOptions(
                showTitle: true,
                browser: tabs.CustomTabsBrowserConfiguration()),
          );
        } else {
          /// The default browser
          await LaunchUrlHelper.launchURL(
            url,
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        Logs.e('Unable to open an external link', ex: e);
        if (mounted) {
          SmoothFloatingMessage(
            message:
                AppLocalizations.of(context).url_not_supported(widget.path),
            type: SmoothFloatingMessageType.error,
          ).show(
            context,
            duration: SnackBarDuration.long,
            alignment: Alignment.bottomCenter,
          );
        }
      } finally {
        if (mounted) {
          final bool success = AppNavigator.of(context).pop();
          if (!success) {
            /// This page was called with the go() without an history
            /// (mainly for an external deep link)
            GoRouter.of(context).go('/');
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
