import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
    await sharedPreferences.remove('userPictureSource');
    await sharedPreferences.remove('lastPictureSource');
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
      'fresh install prompts user, remembers selection, and reuses on subsequent call',
      (WidgetTester tester) async {
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

        // 1st call: prompt appears
        await tester.tap(find.text('Add photo'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);

        // Tap Camera
        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();
        expect(result, UserPictureSource.CAMERA);
        expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);
        expect(userPreferences.explicitUserPictureSource, isNull);
        expect(sharedPreferences.getString('lastPictureSource'), 'C');

        // 2nd call: reused without modal sheet
        await tester.tap(find.text('Add photo'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.image), findsNothing);
        expect(result, UserPictureSource.CAMERA);
      },
    );

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

        // Modal sheet should appear because user explicitly configured "Ask each time"
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);
        expect(find.byIcon(Icons.image), findsOneWidget);

        await tester.tap(find.byIcon(Icons.image));
        await tester.pumpAndSettle();

        expect(result, UserPictureSource.GALLERY);
        expect(userPreferences.lastPictureSource, UserPictureSource.GALLERY);
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

      // Toggle "Remember my choice" and select Gallery
      await tester.tap(find.text('Remember my choice'));
      await tester.pumpAndSettle();
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
      'pickImageFile with forcedSource respects source and preserves remembered preference',
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

        await userPreferences.setLastPictureSource(UserPictureSource.CAMERA);

        await tester.pumpWidget(
          buildTestApp((BuildContext context) {
            return Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => pickImageFile(
                    context,
                    forcedSource: UserPictureSource.GALLERY,
                  ),
                  child: const Text('Forced Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => pickImageFile(
                    context,
                    forcedSource: UserPictureSource.SELECT,
                  ),
                  child: const Text('Forced Select'),
                ),
              ],
            );
          }),
        );
        await tester.pumpAndSettle();

        // 1. Forced GALLERY uses gallery (1) and does NOT overwrite lastPictureSource
        await tester.tap(find.text('Forced Gallery'));
        await tester.pumpAndSettle();
        expect(lastRequestedSource, 1);
        expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);

        // 2. Forced SELECT delegates to getUserPictureSource, reusing remembered CAMERA (0)
        await tester.tap(find.text('Forced Select'));
        await tester.pumpAndSettle();
        expect(lastRequestedSource, 0);
        expect(userPreferences.lastPictureSource, UserPictureSource.CAMERA);
      },
    );
  });
}
