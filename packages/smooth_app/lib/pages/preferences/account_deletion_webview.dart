import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountDeletionWebview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WebViewController controller = WebViewController();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String subject = appLocalizations.account_deletion_subject;
    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;

    controller.loadRequest(
      Uri(
        scheme: 'https',
        host: 'blog.openfoodfacts.org',
        pathSegments: <String>[
          'en',
          'account-deletion',
        ],
        queryParameters: <String, String>{
          'your-subject': subject,
          if (userId != null && userId.isEmail)
            'your-mail': userId
          else if (userId != null)
            'your-name': userId
        },
      ),
    );

    return SmoothScaffold(
      appBar: AppBar(),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
