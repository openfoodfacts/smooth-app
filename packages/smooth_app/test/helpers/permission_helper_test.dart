import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/query/product_query.dart';

import '../tests_utils/mocks.dart';

class _CameraScanner extends MockedScanner {
  const _CameraScanner();

  @override
  Future<bool> hasCamera({required bool front}) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  late PermissionStatus answer;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await mockMatomo();
    GlobalVars.barcodeScanner = const _CameraScanner();
    await CameraHelper.init();
    await ProductQuery.setCountry(
      await UserPreferences.getUserPreferences(),
      'fr',
    );
  });

  setUp(() {
    MatomoTracker.instance.dropActions();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          switch (call.method) {
            case 'shouldShowRequestPermissionRationale':
              return false;
            case 'requestPermissions':
              return <int, int>{Permission.camera.value: answer.index};
            case 'checkPermissionStatus':
              return answer.index;
            case 'openAppSettings':
              return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> ask(PermissionStatus status) {
    answer = status;
    return PermissionListener(permission: Permission.camera).askPermission();
  }

  test('a refused camera permission sends one event with the status', () async {
    for (final PermissionStatus status in <PermissionStatus>[
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied,
      PermissionStatus.restricted,
    ]) {
      MatomoTracker.instance.dropActions();

      await ask(status);

      final Map<String, String> event = MatomoTracker.instance.queue.single;
      expect(event['e_n'], 'cameraPermissionRefused');
      expect(event['e_c'], 'scanning');
      expect(event['e_a'], status.name);
    }
  });

  test('a refusal after a trip to the settings sends one event', () async {
    answer = PermissionStatus.permanentlyDenied;

    await PermissionListener(
      permission: Permission.camera,
    ).askPermission(onRationaleNotAvailable: () async => true);

    final Map<String, String> event = MatomoTracker.instance.queue.single;
    expect(event['e_n'], 'cameraPermissionRefused');
    expect(event['e_a'], 'permanentlyDenied');
  });

  test('a granted camera permission sends nothing', () async {
    await ask(PermissionStatus.granted);

    expect(MatomoTracker.instance.queue, isEmpty);
  });
}
