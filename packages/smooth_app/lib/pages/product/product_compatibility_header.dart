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
    required this.isSettingVisible,
  });

  final Product product;
  final ProductPreferences productPreferences;
  final bool isSettingVisible;

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
        color: helper.getColor(context),
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
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: isSettingVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isSettingVisible,
              child: InkWell(
                borderRadius: const BorderRadius.only(topRight: ROUNDED_RADIUS),
                onTap: isSettingVisible
                    ? () => AppNavigator.of(context).push(
                          AppRoutes.PREFERENCES(PreferencePageType.FOOD),
                        )
                    : null,
                child: Tooltip(
                  message: appLocalizations.open_food_preferences_tooltip,
                  triggerMode: isSettingVisible
                      ? TooltipTriggerMode.longPress
                      : TooltipTriggerMode.tap,
                  child: const SizedBox.square(
                    dimension: kMinInteractiveDimension,
                    child: Icon(Icons.settings),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
