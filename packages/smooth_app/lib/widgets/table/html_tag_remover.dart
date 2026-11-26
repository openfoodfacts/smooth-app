import 'package:html/dom.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/parser.dart';

/// Remover of HTML tags
class HtmlTagRemover extends TreeVisitor {
  String extract(String html) {
    _buffer.clear();
    _needsSeparator = false;
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

  /// Whether the text written so far ends with something else than a space or
  /// a line break (so that a separator is needed).
  bool _needsSeparator = false;

  @override
  void visitText(Text node) {
    final String data = node.data;
    if (data.isEmpty) {
      return;
    }
    _buffer.write(data);
    final String last = data[data.length - 1];
    _needsSeparator = last != ' ' && last != '\n';
  }

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
    if (_needsSeparator) {
      _buffer.write(' ');
      _needsSeparator = false;
    }
  }
}
