import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/KnowledgePanel.dart';
import 'package:openfoodfacts/model/KnowledgePanelElement.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';

// Cells with a lot of text can get very large, we don't want to allocate
// most of [availableWidth] to columns with large cells. So we cap the cell length
// considered for width allocation to [kMaxCellLengthInARow]. Cells with
// text larger than this limit will be wrapped in multiple rows.
const int kMaxCellLengthInARow = 40;

// Minimum length of a cell, without this a column may look unnaturally small
// when put next to larger columns.
const int kMinCellLengthInARow = 20;

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
  final List<ColumnGroup> _columnGroups = <ColumnGroup>[];
  final List<int> _columnsMaxLength = <int>[];

  @override
  void initState() {
    super.initState();
    _initColumnGroups();
    _initColumnsMaxLength();
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
    for (final ColumnGroup columnGroup in _columnGroups) {
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
            isHeader: false,
          ),
        );
      }
    }
    return rows;
  }

  List<List<Widget>> _buildRowWidgets(
      List<List<TableCell>> rows, BoxConstraints constraints) {
    // [availableWidth] is parent's width - total padding we want in between columns.
    final double availableWidth = constraints.maxWidth - LARGE_SPACE;
    // We now allocate width to each column as follows:
    // [availableWidth] / [column's largest cell width] * [totalMaxColumnWidth].
    final int totalMaxColumnWidth =
        _columnsMaxLength.reduce((int sum, int width) => sum + width);

    final List<List<Widget>> rowsWidgets = <List<Widget>>[];
    for (final List<TableCell> row in rows) {
      final List<Widget> rowWidgets = <Widget>[];
      int index = 0;
      for (final TableCell cell in row) {
        final double cellWidth =
            availableWidth / totalMaxColumnWidth * _columnsMaxLength[index++];
        rowWidgets.add(
          TableCellWidget(
              cell: cell,
              cellWidth: cellWidth,
              tableElement: widget.tableElement,
              rebuildTable: setState),
        );
      }
      rowsWidgets.add(rowWidgets);
    }
    return rowsWidgets;
  }

  void _initColumnGroups() {
    int index = 0;
    // Used to locate [columnGroup] for a given [column.columnGroupId].
    final Map<String, ColumnGroup> groupIdToColumnGroup =
        <String, ColumnGroup>{};
    for (final KnowledgePanelTableColumn column
        in widget.tableElement.columns) {
      if (column.columnGroupId == null) {
        // Doesn't belong to a group, create a group with just this column.
        _columnGroups.add(
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
          _columnGroups.add(newGroup);
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

  void _initColumnsMaxLength() {
    final List<List<TableCell>> rows = _buildRowCells();
    // [columnMaxLength] contains the length of the largest cell in the columns.
    // This helps us assign a dynamic width to the column depending upon the
    // largest cell in the column.
    for (final List<TableCell> row in rows) {
      int index = 0;
      for (final TableCell cell in row) {
        if (cell.isHeader) {
          // Set value for the header row.
          _columnsMaxLength.add(cell.text.length);
        } else {
          if (cell.text.length > _columnsMaxLength[index]) {
            _columnsMaxLength[index] = max(kMinCellLengthInARow,
                min(kMaxCellLengthInARow, cell.text.length));
          }
        }
        index++;
      }
    }
  }
}

class TableCellWidget extends StatefulWidget {
  const TableCellWidget({
    required this.cell,
    required this.cellWidth,
    required this.tableElement,
    required this.rebuildTable,
  });

  final TableCell cell;
  final double cellWidth;
  final KnowledgePanelTableElement tableElement;
  final void Function(VoidCallback fn) rebuildTable;

  @override
  State<TableCellWidget> createState() => _TableCellWidgetState();
}

class _TableCellWidgetState extends State<TableCellWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = const EdgeInsets.only(bottom: VERY_SMALL_SPACE);
    // header cells get a bigger vertical padding.
    if (widget.cell.isHeader) {
      padding = const EdgeInsets.symmetric(vertical: SMALL_SPACE);
    }
    TextStyle style = Theme.of(context).textTheme.bodyText2!;
    if (widget.cell.color != null) {
      style = style.apply(color: widget.cell.color);
    }
    if (!widget.cell.isHeader || widget.cell.columnGroup!.columns.length == 1) {
      return _buildHtmlCell(padding, style);
    }
    return _buildDropDownColumnHeader(padding, style);
  }

  Widget _buildHtmlCell(EdgeInsets padding, TextStyle style) {
    String cellText = widget.cell.text;
    if (!_isExpanded) {
      const String htmlStyle = '''
        "text-overflow: ellipsis;
         overflow: hidden;
         max-lines: 2;"
        ''';
      cellText = '<div style=$htmlStyle>${widget.cell.text}</div>';
    }
    return InkWell(
      onTap: () => setState(() {
        _isExpanded = true;
      }),
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: widget.cellWidth,
          child: SmoothHtmlWidget(
            cellText,
            textStyle: style,
          ),
        ),
      ),
    );
  }

  Widget _buildDropDownColumnHeader(EdgeInsets padding, TextStyle style) {
    // Now we finally render [ColumnGroup]s as drop down menus.
    return Padding(
      padding: padding,
      child: SizedBox(
        width: widget.cellWidth,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            child: DropdownButton<KnowledgePanelTableColumn>(
              value: widget.cell.columnGroup!.currentColumn,
              items: widget.cell.columnGroup!.columns
                  .map((KnowledgePanelTableColumn column) {
                return DropdownMenuItem<KnowledgePanelTableColumn>(
                  value: column,
                  child: Container(
                    // 24 dp buffer is to allow the dropdown arrow icon to be displayed.
                    constraints: BoxConstraints(maxWidth: widget.cellWidth - 24)
                        .normalize(),
                    child: Text(column.textForSmallScreens ?? column.text),
                  ),
                );
              }).toList(),
              onChanged: (KnowledgePanelTableColumn? selectedColumn) {
                widget.cell.columnGroup!.currentColumn = selectedColumn;
                int i = 0;
                for (final KnowledgePanelTableColumn column
                    in widget.tableElement.columns) {
                  if (column == selectedColumn) {
                    widget.cell.columnGroup!.currentColumnIndex = i;
                    // Since we have modified [currentColumn], re-rendering the
                    // table will automagically select [selectedColumn].
                    widget.rebuildTable(() {});
                    return;
                  }
                  i++;
                }
              },
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}
