import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountDeletionWebview extends StatefulWidget {
  @override
  State<AccountDeletionWebview> createState() => _AccountDeletionWebviewState();
}

class _AccountDeletionWebviewState extends State<AccountDeletionWebview> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    _controller.loadRequest(_getUri());
  }

  Uri _getUri() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String subject = appLocalizations.account_deletion_subject;
    final String? userId = OpenFoodAPIConfiguration.globalUser?.userId;
    return Uri(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: AppBar(),
      body: WebViewWidget(
        controller: WebViewController(),
      ),
    );
  }
}
