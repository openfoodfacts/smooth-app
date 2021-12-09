import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

class KnowledgePanelTableCard extends StatelessWidget {
  const KnowledgePanelTableCard({
    required this.tableElement,
  });

  final KnowledgePanelTableElement tableElement;

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> rows = <List<Widget>>[];
    rows.add(<Widget>[]);
        return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Dynamically calculate the width of each cell = Available space / total columns.
          final double cellWidth = (constraints.maxWidth - 32) / tableElement.columns.length;
          for (final KnowledgePanelTableColumn column in tableElement.columns) {
            switch (column.type) {
              case null:
              case KnowledgePanelColumnType.TEXT:
                rows[0].add(
                    _buildTableCell(
                      context: context,
                      text: column.text,
                      cellWidth: cellWidth,
                      textColor: Colors.grey,
                      isFirstCell: column == tableElement.columns.first,
                      isHeader: true,
                    )
                );
                break;
              case KnowledgePanelColumnType.PERCENT:
              // TODO(jasmeet): Implement percent knowledge panels.
                rows[0].add(
                    _buildTableCell(
                      context: context,
                      text: column.text,
                      cellWidth: cellWidth,
                      textColor: Colors.grey,
                      isFirstCell: column == tableElement.columns.first,
                      isHeader: true,
                    )
                );
                break;
            }
          }
          for (final KnowledgePanelTableRowElement row in tableElement.rows) {
            rows.add(<Widget>[]);
            for (final KnowledgePanelTableCell cell in row.values) {
              rows[rows.length - 1].add(
                _buildTableCell(
                  context: context,
                  text: cell.text,
                  cellWidth: cellWidth,
                  isFirstCell: cell == row.values.first,
                  textColor: getTextColorFromKnowledgePanelElementEvaluation(
                      cell.evaluation ?? Evaluation.UNKNOWN),
                ),
              );
            }
          }
          return Column(
            children: <Widget>[
              for (List<Widget> row in rows)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: row,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                )
            ],
          );
       });
  }

  Widget _buildTableCell({
    required BuildContext context,
    required String text,
    required double cellWidth,
    Color? textColor,
    bool isFirstCell = false,
    bool isHeader = false,
  }) {
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    // Cells that are not the first ones in a row get a right padding.
    if (!isFirstCell) {
      padding = padding.add(const EdgeInsets.only(left: MEDIUM_SPACE));
    }
    // header cells get a vertical padding.
    if (isHeader) {
      padding = padding.add(const EdgeInsets.symmetric(vertical: SMALL_SPACE));
    }
    TextStyle style = Theme.of(context).textTheme.bodyText2!;
    const double lineHeight = 1.2;
    if (textColor != null) {
      style = style.copyWith(color: textColor, overflow: TextOverflow.ellipsis, height: lineHeight);
    }
    final double maxHeight = style.fontSize! * lineHeight * 3;
    final double minHeight = style.fontSize! * lineHeight * 1.5;
    return Padding(padding: padding, child: ConstrainedBox(constraints: BoxConstraints(minWidth: cellWidth, maxWidth: cellWidth, minHeight: minHeight, maxHeight: maxHeight), child: HtmlWidget(text, textStyle: style, )),);
  }
}
