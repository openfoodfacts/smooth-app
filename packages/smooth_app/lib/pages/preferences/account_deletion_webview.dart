import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountDeletionWebview extends StatefulWidget {
  @override
  AccountDeletionWebviewState createState() => AccountDeletionWebviewState();
}

class AccountDeletionWebviewState extends State<AccountDeletionWebview> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
  }

  String _getUrl(UserPreferences userPreferences) {
    final String langageCode = userPreferences.appLanguageCode ??
        Localizations.localeOf(context).toString();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String subject = appLocalizations.account_deletion_subject;
    final String pathSegment = appLocalizations.account_deletion_path_segment;

    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;

    final Uri uri = Uri(
        scheme: 'https',
        host: 'blog.openfoodfacts.org',
        pathSegments: <String>[
          langageCode,
          pathSegment,
        ],
        queryParameters: <String, String>{
          'your-subject': subject,
          if (userId != null && userId.isEmail)
            'your-mail': userId
          else if (userId != null)
            'your-name': userId
        });

    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    return SmoothScaffold(
      appBar: AppBar(),
      body: WebView(
        initialUrl: _getUrl(userPreferences),
      ),
    );
  }
}
