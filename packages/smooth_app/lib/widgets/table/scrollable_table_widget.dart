import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_cell_width_computer.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/table/smooth_table.dart';
import 'package:smooth_app/widgets/table/smooth_table_cell.dart';
import 'package:smooth_app/widgets/table/table_extractor.dart';

/// Scrollable table widget, roughly computed from an HTML table.
class ScrollableTableWidget extends StatefulWidget {
  const ScrollableTableWidget(this.smoothTable, {super.key});

  ScrollableTableWidget.fromHtml(final String html)
    : this(TableExtractor().extract(html));

  final SmoothTable smoothTable;

  @override
  State<ScrollableTableWidget> createState() => _ScrollableTableWidgetState();
}

class _ScrollableTableWidgetState extends State<ScrollableTableWidget> {
  late List<double> _columnsMaxLength;
  late KnowledgePanelTableCellWidthComputer _computer;

  static const double _scrollPadding = SMALL_SPACE;
  static const double _dividerSize = 1;
  static const double _padding = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computer = KnowledgePanelTableCellWidthComputer(
      textScaler: MediaQuery.textScalerOf(context),
      textStyle: DefaultTextStyle.of(context).style,
      headerTextStyle: DefaultTextStyle.of(
        context,
      ).style.merge(const TextStyle(fontWeight: FontWeight.bold)),
    );
    _columnsMaxLength = widget.smoothTable.getColumnsMaxLength(_computer);
  }

  @override
  void didUpdateWidget(covariant ScrollableTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.smoothTable != oldWidget.smoothTable) {
      _columnsMaxLength = widget.smoothTable.getColumnsMaxLength(_computer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        final List<double> widths = SmoothTable.clampWidths(
          _columnsMaxLength,
          maxColWidth: max(
            constraints.maxWidth * .45,
            // at least an icon + a percentage should be visible
            SmoothTableCell.iconWidth +
                SmoothTableCell.percentageWidth +
                2 * _padding,
          ),
          minColWidth: LARGE_SPACE,
          colPadding: _padding,
        );

        final List<List<Widget>> widgets = <List<Widget>>[];
        widgets.add(<Widget>[const SizedBox(height: _dividerSize)]);

        final bool lightTheme = context.lightTheme();

        int rowIndex = -1;
        for (final List<SmoothTableCell> row in widget.smoothTable.cells) {
          rowIndex++;
          final Color? color;
          if (lightTheme) {
            color = rowIndex == 0
                ? Colors.grey[300]
                : rowIndex.isEven
                ? Colors.grey[200]
                : Colors.grey[100];
          } else {
            color = rowIndex == 0
                ? Colors.grey[900]
                : rowIndex.isEven
                ? Colors.grey[800]
                : Colors.grey[700];
          }
          final List<Widget> rowWidgets = <Widget>[];
          rowWidgets.add(const SizedBox(width: _dividerSize));
          int colIndex = 0;
          for (final SmoothTableCell cell in row) {
            rowWidgets.add(
              Tooltip(
                message: cell.text,
                child: SizedBox(
                  width: widths[colIndex],
                  height: 48,
                  child: Container(
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.all(_padding),
                      child: Align(
                        alignment: AlignmentGeometry.centerLeft,
                        child: cell.getWidget(
                          context: context,
                          computer: _computer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            rowWidgets.add(const SizedBox(width: _dividerSize));

            colIndex++;
          }
          widgets.add(rowWidgets);
          widgets.add(<Widget>[
            const SizedBox(width: _dividerSize, height: _dividerSize),
          ]);
        }

        return Padding(
          padding: const EdgeInsets.all(_scrollPadding),
          child: Container(
            color: lightTheme ? Colors.black : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final List<Widget> row in widgets) Row(children: row),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
