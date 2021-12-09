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
      final double cellWidth =
          (constraints.maxWidth - 32) / tableElement.columns.length;
      for (final KnowledgePanelTableColumn column in tableElement.columns) {
        switch (column.type) {
          case null:
          case KnowledgePanelColumnType.TEXT:
            rows[0].add(_buildTableCell(
              context: context,
              text: column.text,
              cellWidth: cellWidth,
              textColor: Colors.grey,
              isHeader: true,
            ));
            break;
          case KnowledgePanelColumnType.PERCENT:
            // TODO(jasmeet): Implement percent knowledge panels.
            rows[0].add(_buildTableCell(
              context: context,
              text: column.text,
              cellWidth: cellWidth,
              textColor: Colors.grey,
              isHeader: true,
            ));
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
    bool isHeader = false,
  }) {
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 2);
    // header cells get a bigger vertical padding.
    if (isHeader) {
      padding = padding.add(const EdgeInsets.symmetric(vertical: SMALL_SPACE));
    }
    TextStyle style = Theme.of(context).textTheme.bodyText2!;
    if (textColor != null) {
      style = style.copyWith(
          color: textColor);
    }
    return Padding(
      padding: padding,
      child: SizedBox(width: cellWidth,
          child: HtmlWidget(
            text,
            textStyle: style,
          )),
    );
  }
}
