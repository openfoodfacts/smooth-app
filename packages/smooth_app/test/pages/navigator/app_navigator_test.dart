import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/user_management/forgot_password_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/local_database_mock.dart';
import '../../tests_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    await ProductQuery.initCountry(await UserPreferences.getUserPreferences());
    mockMatomo();
  });

  group('AppNavigator deep-link resolution', () {
    test('captures /cgi/reset_password.pl without token', () {
      final Uri uri = Uri.parse(
        'https://world.openfoodfacts.org/cgi/reset_password.pl',
      );
      expect(
        AppNavigator.resolveExternalDeepLink(
          Uri(path: uri.path, queryParameters: uri.queryParameters),
        ),
        equals(AppRoutes.FORGOT_PASSWORD()),
      );
    });

    test('captures /cgi/reset_password.pl with email query parameter', () {
      final Uri uri = Uri.parse(
        'https://fr.openfoodfacts.org/cgi/reset_password.pl?email=user%40example.com',
      );
      expect(
        AppNavigator.resolveExternalDeepLink(
          Uri(path: uri.path, queryParameters: uri.queryParameters),
        ),
        equals(AppRoutes.FORGOT_PASSWORD(email: 'user@example.com')),
      );
    });

    test(
      'falls back to external browser when reset token or code is present',
      () {
        final Uri withCode = Uri.parse('/cgi/reset_password.pl?code=abc123');
        expect(
          AppNavigator.resolveExternalDeepLink(withCode),
          equals(AppRoutes.EXTERNAL('cgi/reset_password.pl?code=abc123')),
        );

        final Uri withToken = Uri.parse('/cgi/reset_password.pl?token=xyz');
        expect(
          AppNavigator.resolveExternalDeepLink(withToken),
          equals(AppRoutes.EXTERNAL('cgi/reset_password.pl?token=xyz')),
        );
      },
    );

    test(
      'keeps existing product, edit, guide, and signup deep links intact',
      () {
        expect(
          AppNavigator.resolveExternalDeepLink(
            Uri.parse('/product/3017620422003/nutella'),
          ),
          equals(AppRoutes.PRODUCT_LOADER('3017620422003')),
        );
        expect(
          AppNavigator.resolveExternalDeepLink(
            Uri.parse('/cgi/product.pl?type=edit&code=3017620422003'),
          ),
          equals(AppRoutes.PRODUCT_LOADER('3017620422003', edit: true)),
        );
        expect(
          AppNavigator.resolveExternalDeepLink(Uri.parse('/signup')),
          equals(AppRoutes.SIGNUP),
        );
        expect(
          AppNavigator.resolveExternalDeepLink(Uri.parse('/nutriscore-v2')),
          equals(AppRoutes.GUIDE_NUTRISCORE_V2),
        );
      },
    );
  });

  group('ForgotPasswordPage route rendering', () {
    testWidgets('renders ForgotPasswordPage with prefilled email', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(mockSharedPreferences());
      final UserPreferences userPreferences =
          await UserPreferences.getUserPreferences();
      late ProductPreferences productPreferences;
      productPreferences = ProductPreferences(
        ProductPreferencesSelection(
          setImportance: userPreferences.setImportance,
          getImportance: userPreferences.getImportance,
          notify: () => productPreferences.notifyListeners(),
        ),
      );
      await productPreferences.init(PlatformAssetBundle());
      await userPreferences.init(productPreferences);

      await tester.pumpWidget(
        MockSmoothApp(
          userPreferences,
          UserManagementProvider(),
          productPreferences,
          ThemeProvider(userPreferences),
          TextContrastProvider(userPreferences),
          ColorProvider(userPreferences),
          const ForgotPasswordPage(initialEmail: 'user@example.com'),
          localDatabase: MockLocalDatabase(),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
    });
  });
}
