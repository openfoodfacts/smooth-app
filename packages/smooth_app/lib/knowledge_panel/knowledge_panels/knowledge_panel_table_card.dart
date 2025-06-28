import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/helpers/html_extension.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Cells with a lot of text can get very large, we don't want to allocate
/// most of [availableWidth] to columns with large cells. So we cap the cell length
/// considered for width allocation to [kMaxCellLengthInARow]. Cells with
/// text larger than this limit will be wrapped in multiple rows.
const int kMaxCellLengthInARow = 40;

/// Minimum length of a cell, without this a column may look unnaturally small
/// when put next to larger columns.
const int kMinCellLengthInARow = 2;
// Min length when the cell has values (eg: percent or 100g)
const int kMinCellLengthInARowValue = 4;

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
    required this.isInitiallyExpanded,
    required this.product,
  });

  final KnowledgePanelTableElement tableElement;
  final bool isInitiallyExpanded;
  final Product product;

  @override
  State<KnowledgePanelTableCard> createState() =>
      _KnowledgePanelTableCardState();
}

class _KnowledgePanelTableCardState extends State<KnowledgePanelTableCard> {
  final List<ColumnGroup> _columnGroups = <ColumnGroup>[];
  final List<int> _columnsMaxLength = <int>[];
  final List<_TableCellType> _columnsType = <_TableCellType>[];

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
        final List<List<Widget>> rowsWidgets = _buildRowWidgets(
          _buildRowCells(),
          constraints,
        );

        return Column(
          children: <Widget>[
            for (final List<Widget> row in rowsWidgets)
              Semantics(
                excludeSemantics: true,
                value: _buildSemanticsValue(row),
                child: IntrinsicHeight(child: Row(children: row)),
              ),
          ],
        );
      },
    );
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
              columnGroup: columnGroup,
            ),
          );
          break;
        case KnowledgePanelColumnType.PERCENT:
          // TODO(jasmeet): Implement percent knowledge panels.
          rows[0].add(
            TableCell(
              text: text,
              color: Colors.grey,
              isHeader: true,
              columnGroup: columnGroup,
            ),
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
              cell.evaluation ?? Evaluation.UNKNOWN,
            ),
            isHeader: false,
          ),
        );
      }
    }
    return rows;
  }

  List<List<Widget>> _buildRowWidgets(
    List<List<TableCell>> rows,
    BoxConstraints constraints,
  ) {
    // [availableWidth] is parent's width - total padding we want in between columns.
    final double availableWidth = constraints.maxWidth - LARGE_SPACE;
    // We now allocate width to each column as follows:
    // [availableWidth] / [column's largest cell width] * [totalMaxColumnWidth].
    final int totalMaxColumnWidth = _columnsMaxLength.reduce(
      (int sum, int width) => sum + width,
    );

    final List<List<Widget>> rowsWidgets = <List<Widget>>[];
    final Widget verticalDivider = _verticalDivider;
    final Widget horizontalDivider = _horizontalDivider;

    for (final List<TableCell> row in rows) {
      final List<Widget> rowWidgets = <Widget>[];
      int index = 0;
      for (final TableCell cell in row) {
        final int cellWidth =
            (availableWidth / totalMaxColumnWidth * _columnsMaxLength[index++])
                .toInt();

        Widget tableCellWidget = _TableCellWidget(
          cell: cell,
          cellType: _columnsType[index - 1],
          cellWidthPercent: cellWidth,
          tableElement: widget.tableElement,
          rebuildTable: setState,
          isInitiallyExpanded: widget.isInitiallyExpanded,
        );

        /// Add a divider below the header cell
        if (cell.isHeader) {
          tableCellWidget = Column(
            children: <Widget>[
              Expanded(child: tableCellWidget),
              horizontalDivider,
            ],
          );
        }

        rowWidgets.add(Expanded(flex: cellWidth, child: tableCellWidget));

        if (index < row.length) {
          rowWidgets.add(verticalDivider);
        }
      }
      rowsWidgets.add(rowWidgets);
    }
    return rowsWidgets;
  }

  Widget get _verticalDivider {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return VerticalDivider(
      width: 1.0,
      color: context.lightTheme()
          ? extension.primaryMedium
          : extension.primarySemiDark,
    );
  }

  Widget get _horizontalDivider {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return Divider(
      height: 1.0,
      color: context.lightTheme()
          ? extension.primaryMedium
          : extension.primarySemiDark,
    );
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
        final bool groupExists = groupIdToColumnGroup.containsKey(
          column.columnGroupId,
        );
        if (!groupExists) {
          // Create a group since one doesn't exist yet.
          final ColumnGroup newGroup = ColumnGroup(
            columns: <KnowledgePanelTableColumn>[],
          );
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

    for (final List<TableCell> row in rows) {
      int index = 0;
      for (final TableCell cell in row) {
        if (cell.isHeader) {
          _TableCellType type;
          if (cell.text == '100g') {
            type = _TableCellType.PER_100G;
          } else if (cell.text == '%') {
            type = _TableCellType.PERCENT;
          } else {
            type = _TableCellType.TEXT;
          }

          // Set value for the header row.
          _columnsMaxLength.add(
            math.max(
              cell.text.length,
              type != _TableCellType.TEXT
                  ? kMinCellLengthInARowValue
                  : kMinCellLengthInARow,
            ),
          );

          _columnsType.add(type);
        } else {
          /// When there is content, ensure the first word is fully visible
          if (_columnsType[index] != _TableCellType.TEXT) {
            _columnsMaxLength[index] = math.max(
              _columnsMaxLength[index],
              cell.text.split('(')[0].length,
            );
          } else {
            _columnsMaxLength[index] = math.max(
              _columnsMaxLength[index],
              cell.text.split(' ')[0].length,
            );
          }
        }
        index++;
      }
    }

    /// Ensure the columns are not too wide or too narrow.
    final int sum = _columnsMaxLength.sum;
    final int maxWidth = math.max((sum ~/ _columnsMaxLength.length) - 4, 1);
    final int minWidth = math.max(maxWidth ~/ 4, 1);

    for (int i = 0; i < _columnsMaxLength.length; i++) {
      if (_columnsType[i] == _TableCellType.PERCENT) {
        _columnsMaxLength[i] = math.max(_columnsMaxLength[i] + 2, minWidth);
      } else if (_columnsType[i] == _TableCellType.PER_100G) {
        _columnsMaxLength[i] = math.max(_columnsMaxLength[i], minWidth);
      } else if (_columnsMaxLength[i] > maxWidth) {
        _columnsMaxLength[i] = maxWidth;
      } else if (_columnsMaxLength[i] < minWidth) {
        _columnsMaxLength[i] = minWidth;
      }
    }
  }

  String _buildSemanticsValue(List<Widget> row) {
    final StringBuffer buffer = StringBuffer();

    for (final Widget widget in row) {
      if (widget is _TableCellWidget && widget.cell.text.isNotEmpty) {
        if (buffer.isNotEmpty) {
          buffer.write(' - ');
        }
        buffer.write(widget.cell.text);
      }
    }

    return buffer.toString();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('tableElementId', widget.tableElement.id));
    properties.add(
      DiagnosticsProperty<bool>('expanded', widget.isInitiallyExpanded),
    );
  }
}

class _TableCellWidget extends StatefulWidget {
  const _TableCellWidget({
    required this.cell,
    required this.cellType,
    required this.cellWidthPercent,
    required this.tableElement,
    required this.rebuildTable,
    required this.isInitiallyExpanded,
  });

  final TableCell cell;
  final _TableCellType cellType;
  final int cellWidthPercent;
  final KnowledgePanelTableElement tableElement;
  final void Function(VoidCallback fn) rebuildTable;
  final bool isInitiallyExpanded;

  @override
  State<_TableCellWidget> createState() => _TableCellWidgetState();
}

class _TableCellWidgetState extends State<_TableCellWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    final EdgeInsetsGeometry padding;

    if (widget.cell.isHeader) {
      padding = const EdgeInsetsDirectional.symmetric(
        vertical: SMALL_SPACE,
        horizontal: VERY_SMALL_SPACE,
      );
    } else {
      padding = const EdgeInsetsDirectional.symmetric(
        vertical: 6.0,
        horizontal: VERY_SMALL_SPACE,
      );
    }

    TextStyle style = Theme.of(context).textTheme.bodyMedium!;
    if (widget.cell.color != null) {
      /// Override the default color
      if (widget.cell.isHeader &&
          widget.cell.color!.intValue == const Color(0xFF9e9e9e).intValue) {
        if (context.lightTheme()) {
          style = style.apply(color: extension.primaryDark);
        } else {
          style = style.apply(color: extension.primaryMedium);
        }
      } else {
        style = style.apply(color: widget.cell.color);
      }
    }

    if (widget.cell.isHeader && widget.cell.columnGroup!.columns.length == 1) {
      return SizedBox(
        height: double.infinity,
        child: _buildHtmlCell(
          padding,
          style.copyWith(fontWeight: FontWeight.w600),
          isSelectable: false,
          alignment: widget.cellType.headerTextAlignment,
          backgroundColor: context.lightTheme()
              ? extension.primaryLight
              : extension.primaryUltraBlack,
        ),
      );
    } else if (!widget.cell.isHeader ||
        widget.cell.columnGroup!.columns.length == 1) {
      return _buildHtmlCell(
        padding,
        style,
        isSelectable: true,
        alignment: widget.cellType.contentTextAlignment,
      );
    }
    return _buildDropDownColumnHeader(
      padding,
      widget.cellWidthPercent,
      style.copyWith(fontWeight: FontWeight.w600),
      backgroundColor: context.lightTheme()
          ? extension.primaryLight
          : extension.primaryUltraBlack,
    );
  }

  Widget _buildHtmlCell(
    EdgeInsetsGeometry padding,
    TextStyle style, {
    required bool isSelectable,
    required AlignmentDirectional alignment,
    Color? backgroundColor,
  }) {
    final StringBuffer styleBuilder = StringBuffer(
      'text-align:${alignment.toHTMLTextAlign()}',
    );

    if (!_isExpanded) {
      styleBuilder.write('''
        text-overflow: ellipsis;
          overflow: hidden;
          max-lines: 2;
          ''');
    }

    final String cellText =
        '<div style="text-align:${alignment.toHTMLTextAlign()}">${widget.cell.text}</div>';

    final Widget child = GestureDetector(
      onTap: () => setState(() {
        _isExpanded = true;
      }),
      child: Padding(
        padding: padding,
        child: Align(
          alignment: alignment,
          child: SmoothHtmlWidget(
            cellText,
            textStyle: style,
            isSelectable: isSelectable,
          ),
        ),
      ),
    );

    if (backgroundColor != null) {
      return ColoredBox(color: backgroundColor, child: child);
    } else {
      return child;
    }
  }

  Widget _buildDropDownColumnHeader(
    EdgeInsetsGeometry padding,
    int width,
    TextStyle style, {
    required Color backgroundColor,
  }) {
    // Now we finally render [ColumnGroup]s as drop down menus.
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: padding,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            child: DropdownButton<KnowledgePanelTableColumn>(
              value: widget.cell.columnGroup!.currentColumn,
              items: widget.cell.columnGroup!.columns
                  .map((KnowledgePanelTableColumn column) {
                    return DropdownMenuItem<KnowledgePanelTableColumn>(
                      value: column,
                      child: SizedBox(
                        width: width.toDouble() - 21.0 - padding.horizontal,
                        child: Text(
                          column.textForSmallScreens ?? column.text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
              onChanged: (KnowledgePanelTableColumn? selectedColumn) {
                if (selectedColumn == null) {
                  return;
                }
                widget.cell.columnGroup!.currentColumn = selectedColumn;

                int i = 0;
                for (final KnowledgePanelTableColumn column
                    in widget.tableElement.columns) {
                  if (column.text == selectedColumn.text &&
                      column.textForSmallScreens ==
                          selectedColumn.textForSmallScreens &&
                      column.columnGroupId == selectedColumn.columnGroupId) {
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<bool>('expanded', widget.isInitiallyExpanded),
    );
  }
}

enum _TableCellType {
  TEXT(
    headerTextAlignment: AlignmentDirectional.centerStart,
    contentTextAlignment: AlignmentDirectional.centerStart,
  ),
  PERCENT(
    headerTextAlignment: AlignmentDirectional.center,
    contentTextAlignment: AlignmentDirectional.centerStart,
  ),
  PER_100G(
    headerTextAlignment: AlignmentDirectional.center,
    contentTextAlignment: AlignmentDirectional.center,
  );

  const _TableCellType({
    required this.headerTextAlignment,
    required this.contentTextAlignment,
  });

  final AlignmentDirectional headerTextAlignment;
  final AlignmentDirectional contentTextAlignment;
}
