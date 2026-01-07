import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/filters/product_for_me_collection.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/filters/product_for_me_collection_evaluation.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/filters/product_for_me_collection_importance.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/attributes/product_for_me_attributes_group.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_segmented_control.dart';

class ProductForMeAttributes extends StatelessWidget {
  const ProductForMeAttributes({super.key});

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ConsumerFilter<UserPreferences>(
      buildWhen:
          (UserPreferences? previousValue, UserPreferences currentValue) =>
              previousValue?.forMeAttributesFilterType !=
              currentValue.forMeAttributesFilterType,
      builder: (BuildContext context, UserPreferences prefs, _) {
        final ForMeAttributesFilterType filterType =
            prefs.forMeAttributesFilterType ??
            ForMeAttributesFilterType.defaultValue;

        return Column(
          spacing: SMALL_SPACE,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: 0.7,
              child: SmoothSegmentedControl<ForMeAttributesFilterType>(
                currentValue: filterType,
                values: ForMeAttributesFilterType.values,
                labels: <String>[
                  appLocalizations
                      .product_page_for_me_attributes_order_importance,
                  appLocalizations
                      .product_page_for_me_attributes_order_evaluation,
                ],
                onValueChanged: (ForMeAttributesFilterType value) {
                  prefs.setForMeAttributesFilterType(value);
                },
                backgroundColor: lightTheme
                    ? theme.primaryNormal
                    : theme.primaryTone,
                selectedTextColor: lightTheme
                    ? theme.primaryDark
                    : theme.primaryUltraBlack,
                unselectedTextColor: Colors.white,
              ),
            ),

            _ProductForMeAttributesList(filterType),
          ],
        );
      },
    );
  }
}

class _ProductForMeAttributesList extends StatelessWidget {
  const _ProductForMeAttributesList(this.filterType);

  final ForMeAttributesFilterType filterType;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences prefs = context.watch<ProductPreferences>();

    return ConsumerFilter<Product>(
      buildWhen: (Product? previousValue, Product currentValue) =>
          previousValue?.attributeGroups != currentValue.attributeGroups,
      builder: (BuildContext context, Product product, Widget? child) {
        final List<AttributeGroup>? attributeGroups = product.attributeGroups;
        if (attributeGroups == null || attributeGroups.isEmpty) {
          return EMPTY_WIDGET;
        }

        final ForMeAttributesFilter groups = switch (filterType) {
          ForMeAttributesFilterType.importance => AttributesImportanceCollector(
            prefs,
          ),
          ForMeAttributesFilterType.evaluation =>
            AttributesEvaluationCollector(),
        };

        for (final AttributeGroup group in attributeGroups) {
          if (group.attributes == null) {
            continue;
          }
          for (final Attribute attribute in group.attributes!) {
            final String importance = prefs.getImportanceIdForAttributeId(
              attribute.id!,
            );
            if (importance == PreferenceImportance.ID_NOT_IMPORTANT) {
              continue;
            }

            groups.add(attribute);
          }
        }

        final SmoothColorsThemeExtension theme = context
            .extension<SmoothColorsThemeExtension>();
        final AppLocalizations appLocalizations = AppLocalizations.of(context);

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: SMALL_SPACE,
          children: groups
              .sortedGroups(appLocalizations, theme)
              .map<Widget>((ForMeAttributesCollection group) {
                return ProductForMeAttributesGroup(
                  groupName: group.name,
                  attributes: group.attributes,
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}
