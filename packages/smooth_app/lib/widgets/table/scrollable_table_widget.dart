import 'package:flutter/material.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/table/smooth_table_cell.dart';
import 'package:smooth_app/widgets/table/table_extractor.dart';

/// Scrollable table widget, roughly computed from an HTML table.
class ScrollableTableWidget extends StatefulWidget {
  const ScrollableTableWidget(this.html, {super.key});

  final String html;

  @override
  State<ScrollableTableWidget> createState() => _ScrollableTableWidgetState();
}

class _ScrollableTableWidgetState extends State<ScrollableTableWidget> {
  late final List<List<SmoothTableCell>> _rows;

  static const double _dividerSize = 1;
  static const double _padding = 2;

  @override
  void initState() {
    super.initState();
    _rows = TableExtractor().extract(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    final TextScaler textScaler = MediaQuery.of(context).textScaler;
    final TextStyle textStyle = DefaultTextStyle.of(context).style;
    final TextStyle headerTextStyle = textStyle.merge(
      const TextStyle(fontWeight: FontWeight.bold),
    );

    final List<double> widths = _computeWidths(
      textScaler,
      textStyle,
      headerTextStyle,
    );

    final List<List<Widget>> widgets = <List<Widget>>[];
    widgets.add(<Widget>[const SizedBox(height: _dividerSize)]);

    final bool lightTheme = context.lightTheme();

    for (int rowIndex = 0; rowIndex < _rows.length; rowIndex++) {
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
      final List<SmoothTableCell> row = _rows[rowIndex];
      final List<Widget> rowWidgets = <Widget>[];
      rowWidgets.add(const SizedBox(width: _dividerSize));
      int colIndex = 0;
      for (final SmoothTableCell cell in row) {
        rowWidgets.add(
          Container(
            width: widths[colIndex] + 2 * _padding,
            color: color,
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Text(
                cell.text,
                textAlign: cell.leftAlign ? TextAlign.left : TextAlign.right,
                style: rowIndex == 0 ? headerTextStyle : textStyle,
              ),
            ),
          ),
        );
        rowWidgets.add(const SizedBox(width: _dividerSize));

        colIndex++;
      }
      widgets.add(rowWidgets);
      widgets.add(<Widget>[const SizedBox(height: _dividerSize)]);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
  }

  // TODO(monsieurtanuki): add a max constraint, like "max column width is 30% of screen width"
  // TODO(monsieurtanuki): add a min constraint
  List<double> _computeWidths(
    TextScaler textScaler,
    TextStyle textStyle,
    TextStyle headerTextStyle,
  ) {
    final List<double> widths = <double>[];

    final int nbLines = _rows.length;
    final int nbCols = _rows.first.length;
    for (int i = 0; i < nbLines; i++) {
      for (int j = 0; j < nbCols; j++) {
        final String text = _rows[i][j].text;
        final double width = _computeTextSize(
          text,
          i == 0 ? headerTextStyle : textStyle,
          textScaler,
        ).width;
        if (i == 0) {
          widths.add(width);
        } else {
          final double previous = widths[j];
          if (previous < width) {
            widths[j] = width;
          }
        }
      }
    }
    return widths;
  }

  // cf. https://stackoverflow.com/questions/52659759/how-can-i-get-the-size-of-the-text-widget-in-flutter
  Size _computeTextSize(
    String text,
    TextStyle textStyle,
    TextScaler textScaler,
  ) => (TextPainter(
    text: TextSpan(text: text, style: textStyle),
    maxLines: 1,
    textScaler: textScaler,
    // TODO(monsieurtanuki): does it matter?
    textDirection: TextDirection.ltr,
  )..layout()).size;
}
