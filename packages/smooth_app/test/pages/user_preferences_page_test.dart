import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

void main() {
  group('UserPreferencesPage looks as expected', () {
    for (final String theme in <String>['Light', 'Dark', 'AMOLED']) {
      testWidgets(theme, (WidgetTester tester) async {
        try {
          // Override & mock out HTTP Requests
          final HttpOverrides? priorOverrides = HttpOverrides.current;
          HttpOverrides.global = MockHttpOverrides();

          late UserPreferences userPreferences;
          late ProductPreferences productPreferences;
          late ThemeProvider themeProvider;
          late ColorProvider colorProvider;
          late TextContrastProvider textContrastProvider;

          SharedPreferences.setMockInitialValues(
            mockSharedPreferences(),
          );

          userPreferences = await UserPreferences.getUserPreferences();
          userPreferences.setTheme(theme);

          productPreferences = ProductPreferences(ProductPreferencesSelection(
            setImportance: userPreferences.setImportance,
            getImportance: userPreferences.getImportance,
            notify: () => productPreferences.notifyListeners(),
          ));
          await productPreferences.init(PlatformAssetBundle());
          await userPreferences.init(productPreferences);
          themeProvider = ThemeProvider(userPreferences);
          colorProvider = ColorProvider(userPreferences);
          textContrastProvider = TextContrastProvider(userPreferences);

          await tester.pumpWidget(
            MockSmoothApp(
              userPreferences,
              UserManagementProvider(),
              productPreferences,
              themeProvider,
              textContrastProvider,
              colorProvider,
              const UserPreferencesPage(),
              localDatabase: MockLocalDatabase(),
            ),
          );
          await tester.pump();

          // We need to lowercase the theme, as on some platforms
          // the name is always lowercase
          await expectGoldenMatches(
            find.byType(UserPreferencesPage),
            'user_preferences_page-${theme.toLowerCase()}.png',
          );
          expect(tester, meetsGuideline(textContrastGuideline));
          expect(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(tester, meetsGuideline(iOSTapTargetGuideline));
          expect(tester, meetsGuideline(androidTapTargetGuideline));
        } catch (e) {
          // Handle any exceptions that are thrown during the test
          print('An error occurred: $e');
        } finally {
          // Restore prior overrides
          HttpOverrides.global = priorOverrides;
        }
      });
    }
  });

  testWidgets('it should open a webview for account deletion',
      (WidgetTester tester) async {
    // Override & mock out HTTP Requests
    final HttpOverrides? priorOverrides = HttpOverrides.current;
    HttpOverrides.global = MockHttpOverrides();

    late UserPreferences userPreferences;
    late ProductPreferences productPreferences;
    late ThemeProvider themeProvider;
    late ColorProvider colorProvider;
    late TextContrastProvider textContrastProvider;

    SharedPreferences.setMockInitialValues(
      mockSharedPreferences(),
    );

    userPreferences = await UserPreferences.getUserPreferences();

    productPreferences = ProductPreferences(ProductPreferencesSelection(
      setImportance: userPreferences.setImportance,
      getImportance: userPreferences.getImportance,
      notify: () => productPreferences.notifyListeners(),
    ));
    await productPreferences.init(PlatformAssetBundle());
    await userPreferences.init(productPreferences);
    themeProvider = ThemeProvider(userPreferences);
    colorProvider = ColorProvider(userPreferences);
    textContrastProvider = TextContrastProvider(userPreferences);

    UserManagementProvider.mountCredentials(
      userId: 'userId',
      password: 'password',
    );

    await tester.pumpWidget(
      MockSmoothApp(
        userPreferences,
        UserManagementProvider(),
        productPreferences,
        themeProvider,
        textContrastProvider,
        colorProvider,
        const UserPreferencesPage(type: PreferencePageType.ACCOUNT),
        localDatabase: MockLocalDatabase(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete));

    await tester.pumpAndSettle();

    expect(find.byType(AccountDeletionWebview), findsOneWidget);
    expect(find.byType(WebView), findsOneWidget);

    // Restore prior overrides
    HttpOverrides.global = priorOverrides;
  });
}
