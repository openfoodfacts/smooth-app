import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

class ProductQuantityInputWidget extends StatelessWidget {
  const ProductQuantityInputWidget({
    required this.textController,
    required this.ownerField,
  });

  final TextEditingController textController;
  final bool ownerField;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothCardWithRoundedHeader(
      title: appLocalizations.quantity,
      leading: const icons.Scale.alt(),
      trailing: Row(
        children: <Widget>[
          if (ownerField) const OwnerFieldSmoothCardIcon(),
          const _ProductQuantityExplanation(),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
        child: SmoothTextFormField(
          controller: textController,
          type: TextFieldTypes.PLAIN_TEXT,
          hintText: appLocalizations.add_basic_details_quantity_hint,
          hintTextStyle: SmoothTextFormField.defaultHintTextStyle(context),
          allowEmojis: false,
          borderRadius: CIRCULAR_BORDER_RADIUS,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}

class _ProductQuantityExplanation extends StatelessWidget {
  const _ProductQuantityExplanation();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExplanationTitleIcon(
      title: appLocalizations.add_basic_details_product_quantity_help_title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ExplanationBodyInfo(
            text:
                appLocalizations.add_basic_details_product_quantity_help_info1,
            icon: false,
          ),
          ExplanationGoodExamplesContainer(
            items: <String>[
              appLocalizations
                  .add_basic_details_product_quantity_help_good_examples_1,
              appLocalizations
                  .add_basic_details_product_quantity_help_good_examples_2,
              appLocalizations
                  .add_basic_details_product_quantity_help_good_examples_3,
            ],
          ),
        ],
      ),
    );
  }
}
