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

  /// Elements that end a line or a block of text: without a separator, the
  /// texts around them would be glued together (eg: `<p>a</p><p>b</p>`).
  static const Set<String> _separators = <String>{
    'br',
    'p',
    'div',
    'li',
    'tr',
    'td',
    'th',
    'blockquote',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
  };

  @override
  void visitText(Text node) => _buffer.write(node.data);

  @override
  void visitElement(Element node) {
    final bool isSeparator = _separators.contains(node.localName);
    if (isSeparator) {
      _writeSeparator();
    }
    super.visitElement(node);
    if (isSeparator) {
      _writeSeparator();
    }
  }

  /// Adds a space, unless the text is empty or already ends with a whitespace.
  void _writeSeparator() {
    final String text = _buffer.toString();
    if (text.isNotEmpty && !text.endsWith(' ') && !text.endsWith('\n')) {
      _buffer.write(' ');
    }
  }
}
