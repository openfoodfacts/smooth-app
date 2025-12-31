import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/food_preferences/food_preferences_controller.dart';
import 'package:smooth_app/pages/food_preferences/widgets/food_preferences_attribute_list_page.dart';

/// Page for selecting foods the user prefers to avoid.
class FoodsToAvoidPage extends StatelessWidget {
  const FoodsToAvoidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return FoodPreferencesAttributeListPage(
      pageType: FoodPreferencesPageType.foodsToAvoid,
      headerWidget: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Text(
          appLocalizations.food_preferences_page_description_foods_to_avoid,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
