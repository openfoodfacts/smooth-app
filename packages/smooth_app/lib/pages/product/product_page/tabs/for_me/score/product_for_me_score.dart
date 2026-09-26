import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/tabs/for_me/score/product_for_me_score_graph.dart';
import 'package:smooth_app/pages/product/product_page/widgets/product_page_title.dart';

class ProductForMeScore extends StatelessWidget {
  const ProductForMeScore({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ProductPageTitle(
          label: appLocalizations.product_page_for_me_compatibility_score_title,
        ),
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          child: ProductForMeScoreGraph(),
        ),
      ],
    );
  }
}
