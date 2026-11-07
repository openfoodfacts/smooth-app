import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/table/scrollable_table_widget.dart';
import 'package:smooth_app/widgets/table/smooth_table.dart';
import 'package:smooth_app/widgets/table/smooth_table_cell.dart';
import 'package:smooth_app/widgets/table/table_extractor.dart';

class _TestThemeProvider extends ChangeNotifier implements ThemeProvider {
  @override
  bool isDarkMode(final BuildContext context) => false;

  @override
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  SmoothTableCell cell(final String text) =>
      SmoothTableCell(text: text, isHeader: false);

  Future<void> pumpTable(
    final WidgetTester tester,
    final SmoothTable table,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: _TestThemeProvider(),
        child: MaterialApp(home: Scaffold(body: ScrollableTableWidget(table))),
      ),
    );
  }

  List<Row> renderedRows(final WidgetTester tester) {
    final Finder table = find.byType(ScrollableTableWidget);
    final Column column = tester.widget<Column>(
      find.descendant(of: table, matching: find.byType(Column)).first,
    );
    return column.children.whereType<Row>().toList();
  }

  testWidgets('renders a headerless HTML table', (WidgetTester tester) async {
    await pumpTable(
      tester,
      TableExtractor().extract(
        '<table><tr><td>first</td><td>second</td></tr></table>',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('first'), findsOneWidget);
    expect(find.byTooltip('second'), findsOneWidget);
  });

  testWidgets('renders a table containing an empty row', (
    WidgetTester tester,
  ) async {
    await pumpTable(
      tester,
      TableExtractor().extract(
        '<table><tr></tr><tr><td>value</td></tr></table>',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('value'), findsOneWidget);
  });

  testWidgets('renders cells beyond the length of the first row', (
    WidgetTester tester,
  ) async {
    await pumpTable(
      tester,
      SmoothTable(<List<SmoothTableCell>>[
        <SmoothTableCell>[cell('first')],
        <SmoothTableCell>[cell('second'), cell('extra')],
      ]),
    );

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('extra'), findsOneWidget);
  });

  testWidgets('pads shorter rows to preserve column alignment', (
    WidgetTester tester,
  ) async {
    await pumpTable(
      tester,
      SmoothTable(<List<SmoothTableCell>>[
        <SmoothTableCell>[cell('first'), cell('second')],
        <SmoothTableCell>[cell('short')],
      ]),
    );

    expect(tester.takeException(), isNull);
    final List<Row> rows = renderedRows(tester);
    expect(rows[1].children.length, rows[3].children.length);
  });
}
