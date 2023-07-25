import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

/// Header showing the product compatibility (color + text).
class ProductCompatibilityHeader extends StatelessWidget {
  const ProductCompatibilityHeader({
    required this.product,
    required this.productPreferences,
    required this.isSettingClickable,
  });

  final Product product;
  final ProductPreferences productPreferences;
  final bool isSettingClickable;

  @override
  Widget build(BuildContext context) {
    final MatchedProductV2 matchedProduct = MatchedProductV2(
      product,
      productPreferences,
    );
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.product(matchedProduct);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final bool isDarkMode = themeData.colorScheme.brightness == Brightness.dark;

    return Ink(
      decoration: BoxDecoration(
        color: helper.getHeaderBackgroundColor(isDarkMode),
        // Ensure that the header has the same circular radius as the SmoothCard.
        borderRadius: const BorderRadiusDirectional.only(
          topStart: ROUNDED_RADIUS,
          topEnd: ROUNDED_RADIUS,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Fake icon
          const SizedBox(width: kMinInteractiveDimension),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: Text(
                  helper.getHeaderText(appLocalizations),
                  style: themeData.textTheme.titleMedium?.copyWith(
                    color: helper.getHeaderForegroundColor(isDarkMode),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.only(topRight: ROUNDED_RADIUS),
            onTap: isSettingClickable
                ? () => AppNavigator.of(context).push(
                      AppRoutes.PREFERENCES(PreferencePageType.FOOD),
                    )
                : null,
            child: Tooltip(
              message: appLocalizations.open_food_preferences_tooltip,
              triggerMode: isSettingClickable
                  ? TooltipTriggerMode.longPress
                  : TooltipTriggerMode.tap,
              child: const SizedBox.square(
                dimension: kMinInteractiveDimension,
                child: Icon(Icons.settings),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
