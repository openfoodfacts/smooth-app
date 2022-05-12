import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_selectable_text/fwfh_selectable_text.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class SmoothHtmlWidget extends StatelessWidget {
  const SmoothHtmlWidget(this.htmlString, {this.textStyle});

  final String htmlString;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlString,
      textStyle: textStyle,
      onTapUrl: (String url) async {
        await LaunchUrlHelper.launchURL(url, false);
        return true;
      },
      factoryBuilder: () => SelectableHtmlWidgetFactory(),
      enableCaching: false,
    );
  }
}

class SelectableHtmlWidgetFactory extends WidgetFactory
    with SelectableTextFactory {}
