import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/smooth_ui_library/util/ui_helpers.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';

bool areButtonsRendered(ContinuousScanModel model) =>
    model.hasMoreThanOneProduct;

Future<void> openPersonalizedRankingPage(BuildContext context) async {
  final ContinuousScanModel model = context.read<ContinuousScanModel>();
  await model.refreshProductList();
  await Navigator.push<Widget>(
    context,
    MaterialPageRoute<Widget>(
      builder: (BuildContext context) => PersonalizedRankingPage(
        model.productList,
      ),
    ),
  );
  await model.refresh();
}

Widget buildButtonsRow(BuildContext context, ContinuousScanModel model) {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  final ButtonStyle buttonStyle = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
    ),
  );
  return AnimatedOpacity(
    opacity: areButtonsRendered(model) ? 0.8 : 0.0,
    duration: const Duration(milliseconds: 50),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: VERY_SMALL_SPACE,
        horizontal: MEDIUM_SPACE,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton.icon(
            style: buttonStyle,
            icon: const Icon(Icons.cancel_outlined),
            onPressed: model.clearScanSession,
            label: Text(appLocalizations.clear),
          ),
          ElevatedButton.icon(
            style: buttonStyle,
            icon: const Icon(RankingFloatingActionButton.rankingIconData),
            onPressed: () => openPersonalizedRankingPage(context),
            label: Text(
              appLocalizations.plural_compare_x_products(
                model.getBarcodes().length,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
