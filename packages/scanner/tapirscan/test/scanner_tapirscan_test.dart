import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_tapirscan/src/scanner_tapirscan.dart';
import 'package:tapirscan/tapirscan.dart' as ts;

void main() {
  test('decodes a padded camera Y plane with the scanner options', () async {
    final ts.Scanner scanner = ts.Scanner(tapirscanOptions);
    addTearDown(scanner.dispose);
    const int width = 480, height = 180, stride = 512;
    final Uint8List plane = _paddedEan13(width, height, stride);
    final ts.ScanResult result = await scanner.scan(
      ts.PixelImage(plane, width: width, height: height, stride: stride),
    );
    expect(result.best?.text, '4006381333931');
  });
}

/// EAN-13 4006381333931 as a Y plane: rows padded to [stride] and a last row
/// that ends at [width], as Android camera buffers may be.
Uint8List _paddedEan13(int width, int height, int stride) {
  const List<String> l = <String>[
    '0001101', '0011001', '0010011', '0111101', '0100011', //
    '0110001', '0101111', '0111011', '0110111', '0001011',
  ];
  const List<String> g = <String>[
    '0100111', '0110011', '0011011', '0100001', '0011101', //
    '0111001', '0000101', '0010001', '0001001', '0010111',
  ];
  const String text = '4006381333931';
  final StringBuffer bits = StringBuffer('101');
  for (int i = 0; i < 6; i++) {
    bits.write(('LGLLGG'[i] == 'L' ? l : g)[int.parse(text[i + 1])]);
  }
  bits.write('01010');
  for (int i = 7; i < 13; i++) {
    bits.write(
      l[int.parse(text[i])]
          .split('')
          .map((String b) => b == '0' ? '1' : '0')
          .join(),
    );
  }
  bits.write('101');
  final String pattern = bits.toString();
  final Uint8List plane = Uint8List((height - 1) * stride + width)
    ..fillRange(0, (height - 1) * stride + width, 255);
  for (int y = 30; y < 150; y++) {
    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] == '1') {
        plane.fillRange(y * stride + 50 + i * 4, y * stride + 54 + i * 4, 0);
      }
    }
  }
  return plane;
}
