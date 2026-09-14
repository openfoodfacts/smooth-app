import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_cell_width_computer.dart';

/// Represents the data in a single cell in this table.
class SmoothTableCell {
  SmoothTableCell({
    required this.text,
    required this.isHeader,
    this.leftAlign = true,
    this.color,
    this.iconUrl,
    this.percent,
  });

  final String text;
  final bool isHeader;
  final bool leftAlign;
  final Color? color;
  final String? iconUrl;
  final double? percent;

  static const double _cellItemSize = DEFAULT_ICON_SIZE;
  static const double _cellItemPadding = VERY_SMALL_SPACE;
  static const double _cellPercentageWidth = 4 * _cellItemSize;

  double getWidth(final KnowledgePanelTableCellWidthComputer computer) {
    double result = computer
        .computeTextSize(
          text,
          isHeader ? computer.headerTextStyle : computer.textStyle,
        )
        .width;
    if (iconUrl != null) {
      result += _cellItemSize + 2 * _cellItemPadding;
    }
    if (percent != null) {
      result += _cellPercentageWidth + 2 * _cellItemPadding;
    }
    return result;
  }

  Widget getWidget({
    required final BuildContext context,
    required final KnowledgePanelTableCellWidthComputer computer,
  }) {
    final TextStyle style = isHeader
        ? computer.headerTextStyle
        : computer.textStyle;

    final StringBuffer styleBuilder = StringBuffer(
      'text-overflow: ellipsis;'
      'overflow: hidden;'
      'max-lines: 2;',
    );

    if (color != null) {
      styleBuilder.write(
        'color: rgba('
        '${(color!.r * 255.0).round().clamp(0, 255)},'
        '${(color!.g * 255.0).round().clamp(0, 255)},'
        '${(color!.b * 255.0).round().clamp(0, 255)},'
        '${color!.a}'
        ');',
      );
    }

    final bool isDark = Theme.brightnessOf(context) == Brightness.dark;
    final Color foreground, background;
    if (isDark) {
      foreground = Colors.white.withAlpha(192);
      background = Colors.black.withAlpha(192);
    } else {
      foreground = Colors.black.withAlpha(192);
      background = Colors.grey.withAlpha(64);
    }

    final Widget? iconWidget = iconUrl == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(_cellItemPadding),
            child: AbstractCache.best(
              iconUrl: iconUrl,
              width: _cellItemSize,
              height: _cellItemSize,
              color: foreground,
            ),
          );
    final double? clampedPercent = percent == null
        ? null
        : clampDouble(percent!, 0, 100);
    final Widget? percentWidget = clampedPercent == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(_cellItemPadding),
            child: Row(
              children: <Widget>[
                Container(
                  height: _cellItemSize,
                  width: _cellPercentageWidth * clampedPercent / 100,
                  color: foreground,
                ),
                Container(
                  height: _cellItemSize,
                  width: _cellPercentageWidth * (100 - clampedPercent) / 100,
                  color: background,
                ),
              ],
            ),
          );

    final String cellText = '<div style="$styleBuilder">$text</div>';
    final Widget textWidget = SmoothHtmlWidget(
      cellText,
      textStyle: style,
      isSelectable: false,
    );

    return iconWidget == null && percentWidget == null
        ? textWidget
        : Row(children: <Widget>[?iconWidget, ?percentWidget, textWidget]);
  }
}
