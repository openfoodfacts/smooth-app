import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/external_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Instead of Custom Tabs / Browser with [ExternalPage], we force some links
/// in a WebView
/// The path can be relative to the OFF website or not.
class ExternalPageInAWebView extends StatefulWidget {
  const ExternalPageInAWebView({
    required this.path,
    required this.pageName,
    super.key,
  }) : assert(path != '');

  final String path;
  final String? pageName;

  @override
  State<ExternalPageInAWebView> createState() => _ExternalPageInAWebViewState();
}

class _ExternalPageInAWebViewState extends State<ExternalPageInAWebView> {
  final WebViewController _controller = WebViewController();
  String? _initialUrl;
  String? _pageTitle;
  int _progress = 100;

  @override
  void initState() {
    super.initState();

    onNextFrame(() {
      if (context.darkTheme(listen: false)) {
        _controller.setBackgroundColor(Colors.black);
      }
    });

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) async {
          if (progress < 100) {
            _pageTitle = AppLocalizations.of(context).loading;
          } else {
            _pageTitle = await _controller.getTitle();
          }
          _progress = progress;
          setState(() {});
        },
        onPageFinished: (String url) async {
          _pageTitle = await _controller.getTitle();
          setState(() {});
        },
      ),
    );

    Future.wait(<Future<void>>[
      _setUserAgent(),
      _fixUrl(),
    ]).then((_) => setState(() {}));
  }

  Future<void> _fixUrl() async {
    _initialUrl = await ExternalPage.rewritePath(widget.path);
    _controller.loadRequest(Uri.parse(_initialUrl!));
    setState(() {});
  }

  Future<void> _setUserAgent() async {
    final StringBuffer userAgent = StringBuffer();
    userAgent.write(await _controller.getUserAgent() ?? 'Mozilla/5.0');
    userAgent.write(' Smoothie OpenFoodFactsMobile/');

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    userAgent.write(packageInfo.version);
    userAgent.write('(');
    userAgent.write(packageInfo.buildNumber);
    userAgent.write(')');

    _controller.setUserAgent(userAgent.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_initialUrl == null) {
      return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(widget.pageName ?? AppLocalizations.of(context).loading),
          leading: const CloseButton(),
        ),
        body: const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    } else {
      return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(
            _pageTitle ??
                widget.pageName ??
                AppLocalizations.of(context).loading,
          ),
          leading: const CloseButton(),
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size(double.infinity, 5.0),
                  child: LinearProgressIndicator(
                    value: _progress / 100,
                  ),
                )
              : null,
        ),
        bottomNavigationBar: _WebViewBottomBar(controller: _controller),
        body: RefreshIndicator(
          onRefresh: () => _controller.reload(),
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.setNavigationDelegate(NavigationDelegate());
    super.dispose();
  }
}

class _WebViewBottomBar extends StatelessWidget {
  const _WebViewBottomBar({
    required this.controller,
  });

  final WebViewController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Container(
      color: AppBarTheme.of(context).backgroundColor,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: VERY_SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: VERY_SMALL_SPACE + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: appLocalizations.previous_label,
              enableFeedback: true,
              onPressed: () => controller.goBack(),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: appLocalizations.next_label,
              enableFeedback: true,
              onPressed: () => controller.goForward(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: appLocalizations.label_reload,
              enableFeedback: true,
              onPressed: () => controller.reload(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: appLocalizations.share,
              enableFeedback: true,
              onPressed: () async {
                final String? url = await controller.currentUrl();
                if (url == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SmoothFloatingSnackbar(
                        content: Text(appLocalizations.error_occurred),
                        duration: SnackBarDuration.medium,
                      ),
                    );
                  }
                  return;
                }

                Share.shareUri(Uri.parse(url));
              },
            ),
          ],
        ),
      ),
    );
  }
}
