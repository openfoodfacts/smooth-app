import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:vector_graphics/vector_graphics.dart';

/// Relies on [UserPreferences.getUserPreferencesSync().latestProductType]
class ProductTypeSearchSelector extends StatelessWidget {
  const ProductTypeSearchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductType latestProductType = context
        .watch<UserPreferences>()
        .latestProductType;

    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return Material(
      borderRadius: MAX_BORDER_RADIUS,
      color: theme.primaryMedium,
      child: InkWell(
        borderRadius: MAX_BORDER_RADIUS,
        onTap: () => unawaited(_showOxFPicker(context, latestProductType)),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MEDIUM_SPACE,
          ),
          child: Row(
            spacing: 6.0,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              latestProductType.getIcon(),
              const icons.Chevron.down(size: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOxFPicker(
    BuildContext context,
    ProductType currentType,
  ) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final ProductType? productType =
        await showSmoothListOfChoicesModalSheet<ProductType>(
          context: context,
          title: appLocalizations.search_filter,
          prefixIcons: ProductType.values.map(
            (ProductType type) => Icon(
              type == currentType
                  ? Icons.radio_button_checked_outlined
                  : Icons.radio_button_unchecked_outlined,
            ),
          ),
          labels: ProductType.values.map(
            (ProductType type) => type.getLabel(appLocalizations),
          ),
          subtitles: ProductType.values.map(
            (ProductType type) => type.getSubtitle(appLocalizations),
          ),
          suffixIcons: ProductType.values.map(
            (ProductType type) => Padding(
              padding: const EdgeInsetsDirectional.only(top: 25.0),
              child: SvgPicture(
                AssetBytesLoader(type.getIllustration()),
                width: 40.0,
              ),
            ),
          ),
          values: ProductType.values,
          safeArea: true,
        );

    if (context.mounted && productType != null) {
      context.read<UserPreferences>().latestProductType = productType;
    }
  }
}
