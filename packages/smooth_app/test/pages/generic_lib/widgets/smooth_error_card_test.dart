import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

import '../../../tests_utils/mocks.dart';

void main() {
  const String errorMessageTest = 'error message test';
  const String smoothErrorCardTitle = 'There was an error';
  const String tryAgainButtonTitle = 'Try Again';
  const String learnMoreButtonTitle = 'Learn more';
  late void Function() tryAgainFunctionTest;

  Finder findTitleSmoothErrorCard() {
    return find.text(smoothErrorCardTitle);
  }

  Finder findTryAgainButton() {
    return find.widgetWithText(SmoothSimpleButton, tryAgainButtonTitle);
  }

  Finder findLearnMoreButton() {
    return find.widgetWithText(SmoothSimpleButton, learnMoreButtonTitle);
  }

  Finder findErrorMessageText() {
    return find.text(errorMessageTest);
  }

  Future<void> clickLearnMoreButton(WidgetTester tester) {
    return tester.tap(findLearnMoreButton());
  }

  Future<int> forceUpdateSmoothCardError(WidgetTester tester) {
    return tester.pumpAndSettle();
  }

  setUp(() {
    tryAgainFunctionTest = () {};
  });

  Future<void> pumpSmoothErrorCardOnScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());

    final UserPreferences prefs = await UserPreferences.getUserPreferences();

    return tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(prefs),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: SmoothScaffold(
            body: SmoothErrorCard(
              errorMessage: errorMessageTest,
              tryAgainFunction: tryAgainFunctionTest,
            ),
          ),
        ),
      ),
    );
  }

  group(SmoothErrorCard, () {
    testWidgets('exist', (WidgetTester tester) async {
      await pumpSmoothErrorCardOnScreen(tester);
      final Finder cardTitleWidget = findTitleSmoothErrorCard();
      final Finder tryAgainButtonWidget = findTryAgainButton();
      final Finder learnMoreButtonWidget = findLearnMoreButton();

      expect(cardTitleWidget, findsOneWidget);
      expect(tryAgainButtonWidget, findsOneWidget);
      expect(learnMoreButtonWidget, findsOneWidget);
    });

    testWidgets('doesnt find the error message', (WidgetTester tester) async {
      await pumpSmoothErrorCardOnScreen(tester);

      await forceUpdateSmoothCardError(tester);

      final Finder errorMessageWidget = findErrorMessageText();

      expect(errorMessageWidget, findsNWidgets(0));
    });

    testWidgets('find error message', (WidgetTester tester) async {
      await pumpSmoothErrorCardOnScreen(tester);
      await clickLearnMoreButton(tester);
      await forceUpdateSmoothCardError(tester);

      final Finder errorMessageWidget = findErrorMessageText();

      expect(errorMessageWidget, findsOneWidget);
    });
  });
}
