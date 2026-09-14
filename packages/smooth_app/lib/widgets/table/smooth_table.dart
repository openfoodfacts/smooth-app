import 'dart:math';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_table_cell_width_computer.dart';
import 'package:smooth_app/widgets/table/smooth_table_cell.dart';

/// A grid of [SmoothTableCell]s.
class SmoothTable {
  SmoothTable(this.cells);

  factory SmoothTable.fromKP(final KnowledgePanelTableElement tableElement) {
    String cleanHtml(final String text) => text.replaceAll('<br>', ' ');

    final List<List<SmoothTableCell>> result = <List<SmoothTableCell>>[];
    result.add(<SmoothTableCell>[]);
    for (final KnowledgePanelTableColumn column in tableElement.columns) {
      final String text = column.text;
      result[0].add(SmoothTableCell(text: cleanHtml(text), isHeader: true));
    }
    for (final KnowledgePanelTableRowElement row in tableElement.rows) {
      result.add(<SmoothTableCell>[]);
      for (final KnowledgePanelTableCell cell in row.values) {
        result[result.length - 1].add(
          SmoothTableCell(
            text: cleanHtml(cell.text),
            color: getTextColorFromKnowledgePanelElementEvaluation(
              cell.evaluation ?? Evaluation.UNKNOWN,
            ),
            isHeader: false,
            iconUrl: cell.iconUrl,
            percent: cell.percent,
          ),
        );
      }
    }
    return SmoothTable(result);
  }

  final List<List<SmoothTableCell>> cells;

  List<double> getColumnsMaxLength(
    final KnowledgePanelTableCellWidthComputer computer,
  ) {
    final List<double> columnsMaxLength = <double>[];
    for (final List<SmoothTableCell> row in cells) {
      int index = 0;
      for (final SmoothTableCell cell in row) {
        if (cell.isHeader) {
          columnsMaxLength.add(0);
        }
        columnsMaxLength[index] = max(
          columnsMaxLength[index],
          cell.getWidth(computer),
        );
        index++;
      }
    }
    return columnsMaxLength;
  }

  static List<double> clampWidths(
    final List<double> values, {
    required double maxColWidth,
    required double minColWidth,
    required double colPadding,
  }) {
    final List<double> result = <double>[];
    for (final double value in values) {
      double best = value + 2 * colPadding;
      if (best < minColWidth) {
        best = minColWidth;
      }
      if (best > maxColWidth) {
        best = maxColWidth;
      }
      result.add(best);
    }
    return result;
  }
}
