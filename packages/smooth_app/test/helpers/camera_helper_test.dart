import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';

/// Back camera query throws, front camera exists.
class _BackCameraThrowsScanner extends MockedScanner {
  const _BackCameraThrowsScanner();

  @override
  Future<bool> hasCamera({required bool front}) async {
    if (!front) {
      throw Exception('camera service unavailable');
    }
    return true;
  }
}

void main() {
  test('a throwing camera query counts as no camera', () async {
    GlobalVars.barcodeScanner = const _BackCameraThrowsScanner();

    await CameraHelper.init();

    expect(CameraHelper.hasACamera, isTrue);
    expect(CameraHelper.hasMoreThanOneCamera, isFalse);
  });
}
