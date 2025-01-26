import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:smooth_app/generic_lib/html/smooth_html_factory.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class SmoothHtmlWidget extends StatelessWidget {
  const SmoothHtmlWidget(
    this.htmlString, {
    this.textStyle,
    this.isSelectable = true,
  });

  final String htmlString;
  final TextStyle? textStyle;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlString,
      textStyle: textStyle,
      customStylesBuilder: (dom.Element element) =>
          element.classes.contains('unknown_ingredient')
              ? <String, String>{
                  'font-weight': 'bold',
                }
              : null,
      onTapUrl: (String url) async {
        try {
          await LaunchUrlHelper.launchURL(url);
        } catch (_) {
          if (context.mounted) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);

            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              SnackBar(
                content: Text(appLocalizations.link_cant_be_opened),
              ),
            );
          }
        }

        return true;
      },
      factoryBuilder: () => isSelectable
          ? SmoothHtmlWidgetFactory(
              onLinkClicked: (String url) =>
                  LaunchUrlHelper.launchURLInWebViewOrBrowser(context, url),
            )
          : WidgetFactory(),
      enableCaching: false,
    );
  }
}
