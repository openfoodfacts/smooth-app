import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/nutrition_page/widgets/nutrition_container_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_dropdown.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

/// A toggle to indicate whether a product has nutrition facts.
class NutritionAvailabilityContainer extends StatelessWidget {
  const NutritionAvailabilityContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverPadding(
      padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      sliver: SliverToBoxAdapter(
        child: SmoothCardWithRoundedHeader(
          title: appLocalizations.nutrition_page_nutritional_info_title,
          leading: const icons.Milk.happy(),
          trailing: const _NutritionAvailabilityExplanation(),
          contentPadding: const EdgeInsetsDirectional.only(
            start: LARGE_SPACE,
            end: MEDIUM_SPACE,
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14.5),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    appLocalizations.nutrition_page_nutritional_info_label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Consumer<NutritionContainerHelper>(
                  builder:
                      (
                        BuildContext context,
                        NutritionContainerHelper helper,
                        _,
                      ) {
                        return SmoothDropdownButton<bool>(
                          value: !helper.noNutritionData,
                          items: <SmoothDropdownItem<bool>>[
                            SmoothDropdownItem<bool>(
                              value: true,
                              label: appLocalizations
                                  .nutrition_page_nutritional_info_value_positive,
                            ),
                            SmoothDropdownItem<bool>(
                              value: false,
                              label: appLocalizations
                                  .nutrition_page_nutritional_info_value_negative,
                            ),
                          ],
                          onChanged: (bool? value) {
                            if (value == null) {
                              return;
                            }

                            context
                                    .read<NutritionContainerHelper>()
                                    .noNutritionData =
                                !value;
                          },
                        );
                      },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionAvailabilityExplanation extends StatelessWidget {
  const _NutritionAvailabilityExplanation();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExplanationTitleIcon(
      title: appLocalizations.nutrition_page_nutritional_info_explanation_title,
      safeArea: false,
      child: Column(
        children: <Widget>[
          ExplanationBodyInfo(
            text: appLocalizations
                .nutrition_page_nutritional_info_explanation_info1,
            icon: false,
            safeArea: true,
          ),
        ],
      ),
    );
  }
}
