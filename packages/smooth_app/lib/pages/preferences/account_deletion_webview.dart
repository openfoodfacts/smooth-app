import 'package:flutter/material.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AccountDeletionWebview extends StatefulWidget {
  @override
  State<AccountDeletionWebview> createState() => _AccountDeletionWebviewState();
}

class _AccountDeletionWebviewState extends State<AccountDeletionWebview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()..loadRequest(_getUri());
  }

  Uri _getUri() => Uri(
    scheme: 'https',
    host: 'blog.openfoodfacts.org',
    pathSegments: <String>['en', 'account-deletion'],
  );

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: SmoothAppBar(),
      body: WebViewWidget(controller: _controller),
    );
  }
}
