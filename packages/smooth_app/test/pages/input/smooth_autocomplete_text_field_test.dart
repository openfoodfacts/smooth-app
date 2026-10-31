import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/pages/product/autocomplete.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

import '../../tests_utils/mocks.dart';

class _FakeAutocompleter implements Autocompleter {
  @override
  Future<List<String>> getSuggestions(final String input) async =>
      List<String>.generate(15, (int i) => '$input $i');
}

void main() {
  const Key barKey = Key('bar');

  /// Returns the options box, for a field [top] pixels down the list.
  Future<Rect> showOptions(WidgetTester tester, final double top) async {
    SharedPreferences.setMockInitialValues(mockSharedPreferences());
    final UserPreferences prefs = await UserPreferences.getUserPreferences();
    final ThemeProvider themeProvider = ThemeProvider(prefs);
    final FocusNode focusNode = FocusNode();
    final TextEditingController controller = TextEditingController();
    addTearDown(focusNode.dispose);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: MaterialApp(
          theme: SmoothTheme.getThemeData(
            Brightness.light,
            themeProvider,
            () => ColorProvider(prefs),
            () => TextContrastProvider(prefs),
          ),
          home: Scaffold(
            body: ListView(
              children: <Widget>[
                SizedBox(height: top),
                LayoutBuilder(
                  builder: (_, BoxConstraints constraints) =>
                      SmoothAutocompleteTextField(
                        focusNode: focusNode,
                        controller: controller,
                        autocompleteKey: UniqueKey(),
                        hintText: 'category',
                        constraints: constraints,
                        manager: AutocompleteManager(_FakeAutocompleter()),
                      ),
                ),
              ],
            ),
            bottomNavigationBar: const SizedBox(key: barKey, height: 80.0),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'choc');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    final Finder options = find
        .descendant(
          of: find.byType(AutocompleteOptions<String>),
          matching: find.byType(Material),
        )
        .first;
    expect(options, findsOneWidget);
    return tester.getRect(options);
  }

  testWidgets('options do not cover the bottom bar', (
    WidgetTester tester,
  ) async {
    final Rect options = await showOptions(tester, 350.0);
    expect(
      options.bottom,
      lessThanOrEqualTo(tester.getRect(find.byKey(barKey)).top),
    );
  });

  testWidgets('options show two rows when the field is near the bar', (
    WidgetTester tester,
  ) async {
    final Rect options = await showOptions(tester, 440.0);
    expect(options.height, greaterThanOrEqualTo(MINIMUM_TOUCH_SIZE * 2));
  });
}
