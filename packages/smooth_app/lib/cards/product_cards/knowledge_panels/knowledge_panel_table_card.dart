import 'package:flutter/material.dart';
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
    final List<List<Widget>> columnCells = <List<Widget>>[];
    for (final KnowledgePanelTableColumn column in tableElement.columns) {
      switch(column.type) {
        case KnowledgePanelColumnType.TEXT:
          columnCells.add(
            <Widget>[
              _buildTableCell(
                context: context,
                text: column.text,
                textColor: Colors.grey,
                isFirstCell: column == tableElement.columns.first,
                isHeader: true,
              )
            ],
          );
          break;
        case KnowledgePanelColumnType.PERCENT:
        // TODO(jasmeet): Implement percent knowledge panels.
          columnCells.add(
            <Widget>[
              _buildTableCell(
                context: context,
                text: column.text,
                textColor: Colors.grey,
                isFirstCell: column == tableElement.columns.first,
                isHeader: true,
              )
            ],
          );
          break;
      }
    }
    for (final KnowledgePanelTableRowElement row in tableElement.rows) {
      int i = 0;
      for (final KnowledgePanelTableCell cell in row.values) {
        columnCells[i++].add(
          _buildTableCell(
            context: context,
            text: cell.text,
            isFirstCell: cell == row.values.first,
            textColor: getTextColorFromKnowledgePanelElementEvaluation(
                cell.evaluation ?? Evaluation.UNKNOWN),
          ),
        );
      }
    }
    return Row(
      children: <Widget>[
        for (List<Widget> column in columnCells)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: column,
            ),
          )
      ],
    );
  }

  Widget _buildTableCell({
    required BuildContext context,
    required String text,
    Color? textColor,
    bool isFirstCell = false,
    bool isHeader = false,
  }) {
    TextStyle style = Theme.of(context).textTheme.bodyText2!;
    if (textColor != null) {
      style = style.apply(color: textColor);
    }
    final Widget textWidget = Text(
      text,
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    // Cells that are not the first ones in a row get a right padding.
    if (!isFirstCell) {
      padding = padding.add(const EdgeInsets.only(left: MEDIUM_SPACE));
    }
    // header cells get a vertical padding.
    if (isHeader) {
      padding = padding.add(const EdgeInsets.symmetric(vertical: SMALL_SPACE));
    }
    return Padding(padding: padding, child: textWidget);
  }
}
