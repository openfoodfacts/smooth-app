import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_fake_button.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_marker_chip.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_marker_decimal.dart';

class SmoothHtmlWidgetFactory extends WidgetFactory {
  SmoothHtmlWidgetFactory({required this.onLinkClicked});

  final Function(String link) onLinkClicked;

  @override
  Widget buildText(
    BuildTree tree,
    InheritedProperties resolved,
    InlineSpan text,
  ) {
    if ((text as TextSpan).text == '→ ' && text.children?.isNotEmpty == true) {
      /// Create a fake button if it's within the text
      return SmoothHtmlFakeButton(children: text.children!);
    } else if (<String>['li', 'ul'].contains(tree.element.localName)) {
      /// Add some bottom padding to the list items
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 14.0),
        child: SelectableText.rich(
          TextSpan(
            children: <InlineSpan>[text],
            style: resolved.prepareTextStyle().copyWith(height: 1.6),
          ),
        ),
      );
    } else {
      return SelectableText.rich(
        TextSpan(
          children: <InlineSpan>[text],
          style: resolved.prepareTextStyle(),
        ),
      );
    }
  }

  @override
  Widget buildListMarker(
    BuildTree tree,
    InheritedProperties resolved,
    String listStyleType,
    int index,
  ) {
    if (listStyleType == 'disc') {
      return const SmoothHtmlChip();
    } else if (listStyleType == 'decimal') {
      return SmoothHtmlDecimal(index: index);
    } else {
      return super.buildListMarker(tree, resolved, listStyleType, index)!;
    }
  }

  @override
  Future<bool> onTapUrl(String url) async {
    onLinkClicked(url);
    return true;
  }
}
