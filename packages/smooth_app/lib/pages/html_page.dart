import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Displays in widgets a HTML page
class HtmlPage extends StatelessWidget {
  const HtmlPage({required this.pageTitle, required this.htmlString});

  final String pageTitle;
  final String htmlString;

  @override
  Widget build(BuildContext context) => SmoothScaffold(
    appBar: SmoothAppBar(title: Text(pageTitle)),
    body: SingleChildScrollView(child: SmoothHtmlWidget(htmlString)),
  );
}
