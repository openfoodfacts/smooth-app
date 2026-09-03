import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';
import 'package:smooth_app/widgets/table/smooth_table_cell.dart';

/// Extractor of an HTML table into a grid of cells.
class TableExtractor extends TreeVisitor {
  List<List<SmoothTableCell>> extract(String html) {
    _cells.clear();
    final Document document = parse(html);
    visit(document);
    return _cells;
  }

  final List<List<SmoothTableCell>> _cells = <List<SmoothTableCell>>[];

  late List<SmoothTableCell> _currentRow;

  bool _addTdText = false;

  bool _addThText = false;

  late bool _leftAlign;

  final StringBuffer _buffer = StringBuffer();

  @override
  void visitText(Text node) {
    if (_addTdText || _addThText) {
      _buffer.write(node.data.trim());
    }
  }

  @override
  void visitElement(Element node) {
    if (isVoidElement(node.localName)) {
      return;
    }
    final bool isTr = node.localName == 'tr';
    final bool isTd = node.localName == 'td';
    final bool isTh = node.localName == 'th';
    if (isTr) {
      _currentRow = <SmoothTableCell>[];
    }
    if (isTd) {
      _addTdText = true;
      _leftAlign = true;
      final String? style = node.attributes['style'];
      if (style != null && style.contains('text-align:right')) {
        _leftAlign = false;
      }
      _buffer.clear();
    }
    if (isTh) {
      _addThText = true;
      _buffer.clear();
    }
    visitChildren(node);
    if (isTr) {
      _cells.add(_currentRow);
    }
    if (isTd) {
      _addTdText = false;
      _currentRow.add(
        SmoothTableCell(
          text: _buffer.toString(),
          isHeader: false,
          leftAlign: _leftAlign,
        ),
      );
    }
    if (isTh) {
      _addThText = false;
      _currentRow.add(
        SmoothTableCell(
          text: _buffer.toString(),
          isHeader: true,
          leftAlign: true,
        ),
      );
    }
  }

  @override
  void visitChildren(Node node) => node.nodes.forEach(visit);
}
