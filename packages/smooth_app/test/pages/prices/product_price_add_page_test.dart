import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/pages/prices/price_model.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_expandable_floating_action_button.dart';

import '../../tests_utils/mocks.dart';

class _PendingPriceModel extends PriceModel {
  _PendingPriceModel()
    : super(
        proofType: ProofType.receipt,
        currency: Currency.EUR,
        multipleProducts: false,
      );

  final Completer<void> saved = Completer<void>();
  bool saveStarted = false;

  @override
  bool get hasChanged => true;

  @override
  String? checkParameters(final BuildContext context) => null;

  @override
  Future<void> addTask(
    final BuildContext context, {
    required final bool displaySnackbar,
  }) {
    saveStarted = true;
    return saved.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
  });

  for (final bool disposeBeforeSave in <bool>[false, true]) {
    testWidgets(
      disposeBeforeSave
          ? 'completing a save after disposal does not access the old context'
          : 'completing a save while mounted closes the price page',
      (final WidgetTester tester) async {
        final UserPreferences preferences =
            await UserPreferences.getUserPreferences();
        await preferences.setFlag(
          UserPreferences.TAG_PRICE_PRIVACY_WARNING,
          true,
        );
        final ProductPreferences productPreferences = ProductPreferences(
          ProductPreferencesSelection(
            setImportance: preferences.setImportance,
            getImportance: preferences.getImportance,
            notify: () {},
          ),
        );
        final _PendingPriceModel model = _PendingPriceModel();
        addTearDown(model.dispose);

        await tester.pumpWidget(
          MockSmoothApp(
            preferences,
            UserManagementProvider(),
            productPreferences,
            ThemeProvider(preferences),
            TextContrastProvider(preferences),
            ColorProvider(preferences),
            const Scaffold(body: Text('Home')),
          ),
        );
        final NavigatorState navigator = tester.state<NavigatorState>(
          find.byType(Navigator),
        );
        final MaterialPageRoute<void> route = MaterialPageRoute<void>(
          builder: (final BuildContext context) => ProductPriceAddPage(model),
        );
        unawaited(navigator.push(route));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SmoothExpandableFloatingActionButton));
        await tester.pump();
        expect(model.saveStarted, isTrue);

        if (disposeBeforeSave) {
          navigator.removeRoute(route);
          await tester.pumpAndSettle();
          expect(find.byType(ProductPriceAddPage), findsNothing);
        }

        model.saved.complete();
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(ProductPriceAddPage), findsNothing);
        expect(find.text('Home'), findsOneWidget);
      },
    );
  }
}
