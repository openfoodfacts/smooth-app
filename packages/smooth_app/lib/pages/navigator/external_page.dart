import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path/path.dart' as path;
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/query/product_query.dart';

/// This screen is only used for deep links!
///
/// A screen opening a [path] relative to the OFF website.
///
/// Unfortunately the deep link we receive doesn't contain the base URL
/// (eg: de.openfoodfacts.org), that's why we try to guess it with the country
/// and the locale of the user
class ExternalPage extends StatefulWidget {
  const ExternalPage({required this.path, Key? key})
      : assert(path != ''),
        super(key: key);

  final String path;

  @override
  State<ExternalPage> createState() => _ExternalPageState();
}

class _ExternalPageState extends State<ExternalPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // First let's try with https://{country}.openfoodfacts.org
      final OpenFoodFactsCountry country = ProductQuery.getCountry();

      String? url;
      url = path.join(
        'https://${country.offTag}.openfoodfacts.org',
        widget.path,
      );

      if (await _testUrl(url)) {
        url = null;
      }

      // If that's not OK, let's try with world.openfoodfacts.org?lc={language}
      if (url == null) {
        final OpenFoodFactsLanguage language = ProductQuery.getLanguage();

        url = path.join(
          'https://world.openfoodfacts.org',
          widget.path,
        );

        url = '$url?lc=${language.offTag}';
      }

      if (Platform.isAndroid) {
        await tabs.launch(
          url,
          customTabsOption: const tabs.CustomTabsOption(
            showPageTitle: true,
          ),
        );
      } else {
        await LaunchUrlHelper.launchURL(url, false);
      }

      if (mounted) {
        AppNavigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  /// Check if an URL exist
  Future<bool> _testUrl(String url) {
    return http
        .head(Uri.parse(url))
        .then((http.Response value) => value.statusCode != 404);
  }
}
