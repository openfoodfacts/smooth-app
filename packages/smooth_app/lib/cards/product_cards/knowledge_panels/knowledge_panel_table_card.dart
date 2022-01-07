import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

/// ColumnGroup is a group of columns collapsed into a single column. Purpose of
/// this is to show a dropdown menu which the users can use to select which column
/// to display. A group can also have a single column, in which case there will
/// be no dropdown on the UI.
class ColumnGroup {
  ColumnGroup({
    this.currentColumnIndex,
    this.currentColumn,
    required this.columns,
  });

  /// The index of the column that is displayed in the [ColumnGroup].
  int? currentColumnIndex;

  /// [KnowledgePanelTableColumn] that is displayed in the [ColumnGroup].
  KnowledgePanelTableColumn? currentColumn;

  /// List of columns in this [ColumnGroup].
  final List<KnowledgePanelTableColumn> columns;
}

/// Represents the data in a single cell in this table.
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
  // [columnGroup] is set only for cells that have [isHeader = true]. This is used
  // to show a dropdown of other column headers in the group for this column.
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
  List<ColumnGroup> columnGroups = <ColumnGroup>[];

  @override
  void initState() {
    super.initState();
    // Build [columnGroups] for the first time.
    int index = 0;
    // Used to locate [columnGroup] for a given [column.columnGroupId].
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
        // Try to find the group if it already exists.
        final bool groupExists =
            groupIdToColumnGroup.containsKey(column.columnGroupId);
        if (!groupExists) {
          // Create a group since one doesn't exist yet.
          final ColumnGroup newGroup =
              ColumnGroup(columns: <KnowledgePanelTableColumn>[]);
          columnGroups.add(newGroup);
          groupIdToColumnGroup[column.columnGroupId!] = newGroup;
        }
        // Look up the already existing or newly created group.
        final ColumnGroup group = groupIdToColumnGroup[column.columnGroupId!]!;
        // If [showByDefault] is true, set this as the currentColumn on the group.
        // As a safeguard (in case no column has [showByDefault] as true, also set currentColumn if it isn't set yet.
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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final List<List<Widget>> rowsWidgets =
          _buildRowWidgets(_buildRowCells(), constraints);
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

  List<List<TableCell>> _buildRowCells() {
    final List<List<TableCell>> rows = <List<TableCell>>[];
    rows.add(<TableCell>[]);
    // Only [displayableColumnIndices] columns will be displayed.
    final List<int> displayableColumnIndices = <int>[];
    for (final ColumnGroup columnGroup in columnGroups) {
      final KnowledgePanelTableColumn column = columnGroup.currentColumn!;
      final String text = column.textForSmallScreens ?? column.text;
      displayableColumnIndices.add(columnGroup.currentColumnIndex!);
      switch (column.type) {
        case null:
        case KnowledgePanelColumnType.TEXT:
          rows[0].add(
            TableCell(
                text: text,
                color: Colors.grey,
                isHeader: true,
                columnGroup: columnGroup),
          );
          break;
        case KnowledgePanelColumnType.PERCENT:
          // TODO(jasmeet): Implement percent knowledge panels.
          rows[0].add(
            TableCell(
                text: text,
                color: Colors.grey,
                isHeader: true,
                columnGroup: columnGroup),
          );
          break;
      }
    }
    for (final KnowledgePanelTableRowElement row in widget.tableElement.rows) {
      rows.add(<TableCell>[]);
      int index = -1;
      for (final KnowledgePanelTableCell cell in row.values) {
        index++;
        if (!displayableColumnIndices.contains(index)) {
          // This cell is not displayable.
          continue;
        }
        rows[rows.length - 1].add(
          TableCell(
              text: cell.text,
              color: getTextColorFromKnowledgePanelElementEvaluation(
                  cell.evaluation ?? Evaluation.UNKNOWN),
              isHeader: false),
        );
      }
    }
    return rows;
  }

  List<List<Widget>> _buildRowWidgets(
      List<List<TableCell>> rows, BoxConstraints constraints) {
    // [availableWidth] is parent's width - total padding we want in between columns.
    final double availableWidth = constraints.maxWidth - LARGE_SPACE;
    // [columnMaxLength] contains the length of the largest cell in the columns.
    // This helps us assign a dynamic width to the column depending upon the
    // largest cell in the column.
    final List<int> columnMaxLength = <int>[];
    // Cells with a lot of text can get very large, we don't want to allocate
    // most of [availableWidth] to columns with large cells. So we cap the cell length
    // considered for width allocation to [kMaxCellLengthInARow]. Cells with
    // text larger than this limit will be wrapped in multiple rows.
    const int maxCellLengthInARow = 50;
    for (final List<TableCell> row in rows) {
      int index = 0;
      for (final TableCell cell in row) {
        if (cell.isHeader) {
          // Set value for the header row.
          columnMaxLength.add(cell.text.length);
        } else {
          if (cell.text.length > columnMaxLength[index]) {
            columnMaxLength[index] = min(maxCellLengthInARow, cell.text.length);
          }
        }
        index++;
      }
    }
    // We now allocate width to each column as follows:
    // [availableWidth] / [column's largest cell width] * [totalMaxColumnWidth].
    final int totalMaxColumnWidth =
        columnMaxLength.reduce((int sum, int width) => sum + width);

    final List<List<Widget>> rowsWidgets = <List<Widget>>[];
    for (final List<TableCell> row in rows) {
      final List<Widget> rowWidgets = <Widget>[];
      int index = 0;
      for (final TableCell cell in row) {
        final double cellWidth =
            availableWidth / totalMaxColumnWidth * columnMaxLength[index++];
        rowWidgets.add(
          _buildTableCellWidget(
            context: context,
            cell: cell,
            cellWidth: cellWidth,
          ),
        );
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
      // non-header cells and columnGroups with a single column are simple html text widgets.
      textWidget = SizedBox(
        width: cellWidth,
        child: HtmlWidget(
          cell.text,
          textStyle: style,
        ),
      );
    } else {
      // Now we finally render [ColumnGroup]s as drop down menus.
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
                    // 24 px buffer is to allow the dropdown arrow icon.
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
                    break;
                  }
                  i++;
                }
                // Since we have modified [currentColumn], re-rendering the
                // widget will automagically select [selectedColumn].
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
