import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

/// Remover of HTML tags
class HtmlTagRemover extends TreeVisitor {
  String extract(String html) {
    _buffer.clear();
    final Document document = parse(html);
    visit(document);
    return _buffer.toString();
  }

  final StringBuffer _buffer = StringBuffer();

  @override
  void visitText(Text node) {
    final String trimmed = node.data.trim();
    // we want to remove empty strings...
    if (trimmed.isEmpty) {
      return;
    }
    // ... but keep spaces for "interesting" strings
    _buffer.write(node.data);
  }
}
