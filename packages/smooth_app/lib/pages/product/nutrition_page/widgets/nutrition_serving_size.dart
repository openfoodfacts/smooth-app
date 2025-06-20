import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

/// A toggle to indicate whether a product has nutrition facts.
class NutritionServingSize extends StatelessWidget {
  const NutritionServingSize({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SliverPadding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: MEDIUM_SPACE),
      sliver: SliverToBoxAdapter(
        child: ListenableProvider<TextEditingController>(
          create: (_) => controller,
          dispose: (_, __) {},
          child: SmoothCardWithRoundedHeader(
            title: appLocalizations.nutrition_page_serving_size,
            leading: Consumer<TextEditingController>(
              builder:
                  (BuildContext context, TextEditingController controller, _) =>
                      ScaleAnimation(animated: controller.text.isNotEmpty),
            ),
            leadingIconSize: 21.0,
            leadingPadding: const EdgeInsetsDirectional.only(
              top: 3.5,
              start: 4.0,
              end: 4.0,
              bottom: 4.5,
            ),
            trailing: const _NutritionServingSizeExplanation(),
            contentPadding: const EdgeInsetsDirectional.only(
              start: MEDIUM_SPACE,
              end: MEDIUM_SPACE,
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
            ),
            child: SmoothTextFormField(
              controller: controller,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.nutrition_page_serving_size_hint,
              hintTextStyle: SmoothTextFormField.defaultHintTextStyle(context),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                final List<FocusNode> focusNodes = Provider.of<List<FocusNode>>(
                  context,
                  listen: false,
                );

                if (focusNodes.isNotEmpty) {
                  focusNodes[0].requestFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  bool hasOwnerField(Product product) =>
      product.getOwnerFieldTimestamp(OwnerField.productField(
        ProductField.SERVING_SIZE,
        ProductQuery.getLanguage(),
      )) !=
      null;
}

class _NutritionServingSizeExplanation extends StatelessWidget {
  const _NutritionServingSizeExplanation();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExplanationTitleIcon(
      title: appLocalizations.nutrition_page_serving_size_explanation_title,
      safeArea: false,
      child: Column(
        children: <Widget>[
          ExplanationBodyInfo(
            text:
                appLocalizations.nutrition_page_serving_size_explanation_info1,
            icon: false,
          ),
          ExplanationGoodExamplesContainer(
            items: <String>[
              appLocalizations
                  .nutrition_page_serving_size_explanation_good_example1,
              appLocalizations
                  .nutrition_page_serving_size_explanation_good_example2,
            ],
          ),
          ExplanationBadExamplesContainer(
            items: <String>[
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example1_example,
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example2_example,
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example3_example,
            ],
            explanations: <String>[
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example1_explanation,
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example2_explanation,
              appLocalizations
                  .nutrition_page_serving_size_explanation_bad_example3_explanation,
            ],
          ),
          const SizedBox(height: BALANCED_SPACE),
          ExplanationBodyInfo(
            text:
                appLocalizations.nutrition_page_serving_size_explanation_info2,
            icon: false,
            safeArea: true,
          ),
        ],
      ),
    );
  }
}
