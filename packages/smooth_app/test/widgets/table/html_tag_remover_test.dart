import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/widgets/table/html_tag_remover.dart';

void main() {
  group('HtmlTagRemover - existing behavior', () {
    final HtmlTagRemover remover = HtmlTagRemover();

    test('inline tags do not add or remove spaces', () {
      expect(
        remover.extract('<b>Take a photo</b> of the ingredients').trim(),
        'Take a photo of the ingredients',
      );
    });

    test('entities are decoded', () {
      expect(remover.extract('Fish &amp; chips').trim(), 'Fish & chips');
      expect(remover.extract('&eacute;clair').trim(), 'éclair');
    });

    test('empty or whitespace-only input gives an empty string', () {
      expect(remover.extract('<br>').trim(), '');
      expect(remover.extract('   \n\t  ').trim(), '');
    });
  });

  group('HtmlTagRemover - text boundaries', () {
    final HtmlTagRemover remover = HtmlTagRemover();

    test('adjacent paragraphs are separated', () {
      expect(
        remover.extract('<p>Take a photo</p><p>of the ingredients</p>').trim(),
        'Take a photo of the ingredients',
      );
    });

    test('a line break between texts is a separator', () {
      expect(
        remover.extract('Take a photo<br>of the ingredients').trim(),
        'Take a photo of the ingredients',
      );
      expect(
        remover.extract('Take a photo<br/>of the ingredients').trim(),
        'Take a photo of the ingredients',
      );
    });

    test('other block elements are separated', () {
      expect(remover.extract('<div>one</div><div>two</div>').trim(), 'one two');
      expect(
        remover.extract('<ul><li>one</li><li>two</li></ul>').trim(),
        'one two',
      );
    });

    test('table cells and quotes are separated', () {
      expect(
        remover.extract('<table><tr><td>one</td><td>two</td></tr></table>'),
        contains('one two'),
      );
      expect(
        remover
            .extract('<blockquote>one</blockquote><blockquote>two</blockquote>')
            .trim(),
        'one two',
      );
    });

    test('inline tags are not separated', () {
      expect(remover.extract('<b>Take</b><i>away</i>').trim(), 'Takeaway');
    });
  });
}
