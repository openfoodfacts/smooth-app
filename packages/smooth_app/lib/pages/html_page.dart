import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';

/// Displays in widgets a HTML page
class HtmlPage extends StatelessWidget {
  const HtmlPage({
    required this.pageTitle,
    required this.htmlString,
  });

  final String pageTitle;
  final String htmlString;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(pageTitle)),
        body: SingleChildScrollView(child: SmoothHtmlWidget(htmlString)),
      );
}
