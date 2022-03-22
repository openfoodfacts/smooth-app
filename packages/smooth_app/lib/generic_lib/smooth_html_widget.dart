import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';

class SmoothHtmlWidget extends StatelessWidget {
  const SmoothHtmlWidget(this.html, {this.textStyle});

  final String html;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: textStyle,
      onTapUrl: (String url) async {
        await LaunchUrlHelper.launchURL(url, false);
        return true;
      },
      isSelectable: true,
      enableCaching: false,
    );
  }
}
