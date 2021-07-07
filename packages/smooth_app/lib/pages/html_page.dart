import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

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
        body: SingleChildScrollView(child: HtmlWidget(htmlString)),
      );
}
