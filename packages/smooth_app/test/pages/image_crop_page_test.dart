import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../tests_utils/mocks.dart';

class _AlwaysHasCameraScanner extends MockedScanner {
  const _AlwaysHasCameraScanner();

  @override
  Future<bool> hasCamera({required bool front}) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserPreferences userPreferences;
  late SharedPreferences sharedPreferences;
  late ProductPreferences productPreferences;

  setUpAll(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    GlobalVars.barcodeScanner = const _AlwaysHasCameraScanner();
    await CameraHelper.init();
    debugDefaultTargetPlatformOverride = null;

    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    userPreferences = await UserPreferences.getUserPreferences();
    sharedPreferences = await SharedPreferences.getInstance();

    productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: userPreferences.setImportance,
        getImportance: userPreferences.getImportance,
        notify: () => productPreferences.notifyListeners(),
      ),
    );
    await productPreferences.init(PlatformAssetBundle());
    await userPreferences.init(productPreferences);
    await ProductQuery.initCountry(userPreferences);
  });

  setUp(() async {
    await userPreferences.clearUserPictureSource();
    await userPreferences.resetLastPictureSource();
  });

  Widget buildTestApp(WidgetBuilder builder) {
    return MockSmoothApp(
      userPreferences,
      UserManagementProvider(),
      productPreferences,
      ThemeProvider(userPreferences),
      TextContrastProvider(userPreferences),
      ColorProvider(userPreferences),
      Scaffold(body: Builder(builder: builder)),
    );
  }

  group('getUserPictureSource flow and persistence', () {
    testWidgets(
      'fresh install: prompts user, remembers selection, and reuses on subsequent call',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        UserPictureSource? firstResult;
        UserPictureSource? secondResult;

        // First call: prompt should show
        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                firstResult = await getUserPictureSource(context);
              },
              child: const Text('Add photo 1'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add photo 1'));
        await tester.pumpAndSettle();

        // Modal sheet should be visible with Camera and Gallery buttons
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);

        // User taps Camera
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();

        expect(firstResult, UserPictureSource.CAMERA);
        expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);
        expect(userPreferences.explicitUserPictureSource, isNull);
        expect(sharedPreferences.getString('lastPictureSource'), 'C');

        // Second call: must not show modal sheet, returns CAMERA directly
        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                secondResult = await getUserPictureSource(context);
              },
              child: const Text('Add photo 2'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add photo 2'));
        await tester.pumpAndSettle();

        // Sheet should NOT have appeared
        expect(find.byIcon(Icons.image), findsNothing);
        expect(secondResult, UserPictureSource.CAMERA);
      },
    );

    testWidgets(
      'remembered GALLERY is reused on subsequent call without prompt',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await userPreferences.setLastPictureSource(UserPictureSource.GALLERY);
        UserPictureSource? result;

        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                result = await getUserPictureSource(context);
              },
              child: const Text('Add photo'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add photo'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.camera_alt), findsNothing);
        expect(result, UserPictureSource.GALLERY);
      },
    );

    testWidgets('explicit preference takes precedence over last source', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      // Last source was CAMERA, but user explicitly configured GALLERY in settings
      await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);
      await userPreferences.setUserPictureSource(UserPictureSource.GALLERY);

      UserPictureSource? result;

      await tester.pumpWidget(
        buildTestApp((BuildContext context) {
          return ElevatedButton(
            onPressed: () async {
              result = await getUserPictureSource(context);
            },
            child: const Text('Add photo'),
          );
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();

      expect(result, UserPictureSource.GALLERY);
      expect(find.byIcon(Icons.camera_alt), findsNothing);
    });

    testWidgets(
      'explicit SELECT ("Ask each time") always prompts even if last source exists',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);
        await userPreferences.setUserPictureSource(UserPictureSource.SELECT);

        UserPictureSource? result;

        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                result = await getUserPictureSource(context);
              },
              child: const Text('Add photo'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add photo'));
        await tester.pumpAndSettle();

        // Modal sheet should appear because user explicitly chose "Ask each time"
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);

        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();

        expect(result, UserPictureSource.GALLERY);
        expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
        // Explicit preference remains SELECT
        expect(
          userPreferences.explicitUserPictureSource,
          UserPictureSource.SELECT,
        );
      },
    );

    testWidgets('checking "Remember my choice" saves explicit preference', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      UserPictureSource? result;

      await tester.pumpWidget(
        buildTestApp((BuildContext context) {
          return ElevatedButton(
            onPressed: () async {
              result = await getUserPictureSource(context);
            },
            child: const Text('Add photo'),
          );
        }),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();

      // Toggle "Remember my choice"
      await tester.tap(find.text('Remember my choice'));
      await tester.pumpAndSettle();

      // Tap Gallery
      await tester.tap(find.byIcon(Icons.image));
      await tester.pumpAndSettle();

      expect(result, UserPictureSource.GALLERY);
      expect(
        userPreferences.explicitUserPictureSource,
        UserPictureSource.GALLERY,
      );
      expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
      expect(sharedPreferences.getString('userPictureSource'), 'G');
      expect(sharedPreferences.getString('lastPictureSource'), 'G');
    });

    testWidgets(
      'pickImageFile with forcedSource does not overwrite lastPictureSource',
      (WidgetTester tester) async {
        const MethodChannel channel = MethodChannel(
          'plugins.flutter.io/image_picker',
        );
        int? lastRequestedSource;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'pickImage') {
                final Map<dynamic, dynamic>? args =
                    methodCall.arguments as Map<dynamic, dynamic>?;
                lastRequestedSource = args?['source'] as int?;
                return 'test/path/photo.jpg';
              }
              return null;
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        // User's remembered preference was CAMERA
        await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);

        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                // Forced call (e.g. PriceProofCard using Gallery)
                await pickImageFile(
                  context,
                  forcedSource: UserPictureSource.GALLERY,
                );
              },
              child: const Text('Add forced photo'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add forced photo'));
        await tester.pumpAndSettle();

        // 1 is ImageSource.gallery
        expect(lastRequestedSource, 1);
        // Crucial: lastPictureSource MUST remain CAMERA!
        expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);
        expect(sharedPreferences.getString('lastPictureSource'), 'C');
      },
    );

    testWidgets(
      'auto-opened source cancellation falls back to prompt so user can switch source',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);

        const MethodChannel channel = MethodChannel(
          'plugins.flutter.io/image_picker',
        );
        int? lastRequestedSource;
        String? nextResult;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'pickImage') {
                final Map<dynamic, dynamic>? args =
                    methodCall.arguments as Map<dynamic, dynamic>?;
                lastRequestedSource = args?['source'] as int?;
                return nextResult;
              }
              return null;
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        // Remembered source is CAMERA, but user has no explicit setting
        await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);
        expect(userPreferences.explicitUserPictureSource, isNull);

        // When CAMERA opens, user cancels it (returns null)
        nextResult = null;

        XFile? resultFile;

        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                resultFile = await pickImageFile(context);
              },
              child: const Text('Add photo'),
            );
          }),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add photo'));
        await tester.pumpAndSettle();

        // First attempt opened CAMERA (0) and was cancelled
        expect(lastRequestedSource, 0);

        // Because it was cancelled, the picker sheet MUST appear as an escape hatch
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);

        // User now selects GALLERY (1) to switch!
        nextResult = 'test/path/gallery_photo.jpg';
        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();

        expect(lastRequestedSource, 1);
        expect(resultFile?.path, 'test/path/gallery_photo.jpg');
        // Remembered source is now updated to GALLERY!
        expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
      },
    );
  });
}
