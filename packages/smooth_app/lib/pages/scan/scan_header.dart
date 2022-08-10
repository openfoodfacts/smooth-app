import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';

class ScanHeader extends StatefulWidget {
  const ScanHeader();

  @override
  State<ScanHeader> createState() => _ScanHeaderState();
}

class _ScanHeaderState extends State<ScanHeader> {
  static const double _visibleOpacity = 0.8;
  static const double _invisibleOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();

    final ButtonStyle buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
      ),
    );

    return AnimatedOpacity(
      opacity:
          model.getBarcodes().isNotEmpty ? _visibleOpacity : _invisibleOpacity,
      duration: SmoothAnimationsDuration.brief,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: VERY_SMALL_SPACE,
          horizontal: MEDIUM_SPACE,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.4,
                  ),
                  child: ElevatedButton.icon(
                    style: buttonStyle,
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: model.clearScanSession,
                    label: Text(appLocalizations.clear),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                  ),
                  child: ElevatedButton.icon(
                    style: buttonStyle,
                    icon:
                        const Icon(RankingFloatingActionButton.rankingIconData),
                    onPressed: () async {
                      final ContinuousScanModel model =
                          context.read<ContinuousScanModel>();
                      await model.refreshProductList();
                      if (!mounted) {
                        return;
                      }
                      await Navigator.push<Widget>(
                        context,
                        MaterialPageRoute<Widget>(
                          builder: (BuildContext context) =>
                              PersonalizedRankingPage(
                            barcodes: model.productList.barcodes,
                            title: ProductQueryPageHelper.getProductListLabel(
                              model.productList,
                              context,
                            ),
                          ),
                        ),
                      );
                    },
                    label: FittedBox(
                      child: Text(
                        appLocalizations.plural_compare_x_products(
                          model.getBarcodes().length,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
