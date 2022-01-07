import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

const int kMaxCellLengthInARow = 50;

class ColumnGroup {
  ColumnGroup(
      {this.currentColumnIndex, this.currentColumn, required this.columns});

  int? currentColumnIndex;
  KnowledgePanelTableColumn? currentColumn;
  final List<KnowledgePanelTableColumn> columns;
}

class TableCell {
  TableCell({
    required this.text,
    required this.color,
    required this.isHeader,
    this.columnGroup,
  });

  final String text;
  final Color? color;
  final bool isHeader;
  // ColumnGroup is set for header cells.
  final ColumnGroup? columnGroup;
}

class KnowledgePanelTableCard extends StatefulWidget {
  const KnowledgePanelTableCard({
    required this.tableElement,
  });

  final KnowledgePanelTableElement tableElement;

  @override
  State<KnowledgePanelTableCard> createState() =>
      _KnowledgePanelTableCardState();
}

class _KnowledgePanelTableCardState extends State<KnowledgePanelTableCard> {
  List<ColumnGroup> columnGroups = [];

  @override
  void initState() {
    super.initState();
    // Build columnGroups
    int index = 0;
    final Map<String, ColumnGroup> groupIdToColumnGroup =
        <String, ColumnGroup>{};
    for (final KnowledgePanelTableColumn column
        in widget.tableElement.columns) {
      if (column.columnGroupId == null) {
        // Doesn't belong to a group, create a group with just this column.
        columnGroups.add(
          ColumnGroup(
            currentColumnIndex: index,
            currentColumn: column,
            columns: <KnowledgePanelTableColumn>[column],
          ),
        );
      } else {
        final bool groupExists =
            groupIdToColumnGroup.containsKey(column.columnGroupId);
        if (!groupExists) {
          final ColumnGroup newGroup =
              ColumnGroup(columns: <KnowledgePanelTableColumn>[]);
          columnGroups.add(newGroup);
          groupIdToColumnGroup[column.columnGroupId!] = newGroup;
        }
        final ColumnGroup group = groupIdToColumnGroup[column.columnGroupId!]!;
        // If no current column data is set, set it.
        // If it's set and if [showByDefault] is true for this column, set it with this column's data.
        if (column.showByDefault ?? false || group.currentColumn == null) {
          group.currentColumnIndex = index;
          group.currentColumn = column;
        }
        group.columns.add(column);
      }
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<TableCell>> rows = <List<TableCell>>[];
    rows.add(<TableCell>[]);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final List<int> displayableColumnIndices = <int>[];
      for (final ColumnGroup columnGroup in columnGroups) {
        final KnowledgePanelTableColumn column = columnGroup.currentColumn!;
        final String text = column.textForSmallScreens ?? column.text;
        displayableColumnIndices.add(columnGroup.currentColumnIndex!);
        switch (column.type) {
          case null:
          case KnowledgePanelColumnType.TEXT:
            rows[0].add(TableCell(
                text: text,
                color: Colors.grey,
                isHeader: true,
                columnGroup: columnGroup));
            break;
          case KnowledgePanelColumnType.PERCENT:
            // TODO(jasmeet): Implement percent knowledge panels.
            rows[0].add(TableCell(
                text: text,
                color: Colors.grey,
                isHeader: true,
                columnGroup: columnGroup));
            break;
        }
      }
      for (final KnowledgePanelTableRowElement row
          in widget.tableElement.rows) {
        rows.add(<TableCell>[]);
        int index = -1;
        for (final KnowledgePanelTableCell cell in row.values) {
          index++;
          if (!displayableColumnIndices.contains(index)) {
            // This cell is not displayable.
            continue;
          }
          rows[rows.length - 1].add(TableCell(
              text: cell.text,
              color: getTextColorFromKnowledgePanelElementEvaluation(
                  cell.evaluation ?? Evaluation.UNKNOWN),
              isHeader: false));
        }
      }
      final List<List<Widget>> rowsWidgets =
          _buildRowWidgets(rows, constraints);
      return Column(
        children: <Widget>[
          for (List<Widget> row in rowsWidgets)
            Row(
              children: row,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            )
        ],
      );
    });
  }

  List<List<Widget>> _buildRowWidgets(
      List<List<TableCell>> rows, BoxConstraints constraints) {
    // [availableWidth] is parent's width - total padding we want in between columns.
    final double availableWidth = constraints.maxWidth - LARGE_SPACE;
    // [columnMaxLength] contains the maximum length of the cells in the columns.
    // This helps us assign a dynamic width to the column depending upon the
    // length of it's cells.
    final List<int> columnMaxLength = <int>[];
    for (final List<TableCell> row in rows) {
      int index = 0;
      for (final TableCell cell in row) {
        if (cell.isHeader) {
          // Set value for the header row.
          columnMaxLength.add(cell.text.length);
        } else {
          if (cell.text.length > columnMaxLength[index]) {
            columnMaxLength[index] =
                min(kMaxCellLengthInARow, cell.text.length);
          }
        }
        index++;
      }
    }
    final int totalMaxColumnWidth =
        columnMaxLength.reduce((int sum, int width) => sum + width);

    final List<List<Widget>> rowsWidgets = <List<Widget>>[];
    for (final List<TableCell> row in rows) {
      final List<Widget> rowWidgets = <Widget>[];
      int index = 0;
      for (final TableCell cell in row) {
        final double cellWidth =
            availableWidth / totalMaxColumnWidth * columnMaxLength[index++];
        rowWidgets.add(_buildTableCellWidget(
          context: context,
          cell: cell,
          cellWidth: cellWidth,
        ));
      }
      rowsWidgets.add(rowWidgets);
    }
    return rowsWidgets;
  }

  Widget _buildTableCellWidget({
    required BuildContext context,
    required TableCell cell,
    required double cellWidth,
  }) {
    EdgeInsetsGeometry padding =
        const EdgeInsets.only(bottom: VERY_SMALL_SPACE);
    // header cells get a bigger vertical padding.
    if (cell.isHeader) {
      padding = const EdgeInsets.symmetric(vertical: SMALL_SPACE);
    }
    TextStyle style = Theme.of(context).textTheme.bodyText2!;
    if (cell.color != null) {
      style = style.apply(color: cell.color);
    }
    Widget textWidget;
    if (!cell.isHeader || cell.columnGroup!.columns.length == 1) {
      textWidget = SizedBox(
        width: cellWidth,
        child: HtmlWidget(
          cell.text,
          textStyle: style,
        ),
      );
    } else {
      textWidget = SizedBox(
        width: cellWidth,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            child: DropdownButton<KnowledgePanelTableColumn>(
              value: cell.columnGroup!.currentColumn,
              items: cell.columnGroup!.columns
                  .map((KnowledgePanelTableColumn column) {
                return DropdownMenuItem<KnowledgePanelTableColumn>(
                  value: column,
                  child: Container(
                    // 24 px buffer is to allow the dropdown arrow.
                    constraints:
                        BoxConstraints(maxWidth: cellWidth - 24).normalize(),
                    child: Text(column.textForSmallScreens ?? column.text),
                  ),
                );
              }).toList(),
              onChanged: (KnowledgePanelTableColumn? selectedColumn) {
                cell.columnGroup!.currentColumn = selectedColumn;
                int i = 0;
                for (final KnowledgePanelTableColumn column
                    in widget.tableElement.columns) {
                  if (column == selectedColumn) {
                    cell.columnGroup!.currentColumnIndex = i;
                  }
                  i++;
                }
                setState(() {});
              },
              style: style,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: padding,
      child: textWidget,
    );
  }
}
