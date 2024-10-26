import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';

class ScanHeader extends StatefulWidget {
  const ScanHeader({super.key});

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
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).colorScheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    );

    final bool compareFeatureAvailable = model.compareFeatureAvailable;

    return AnimatedOpacity(
      opacity:
          model.compareFeatureEnabled ? _visibleOpacity : _invisibleOpacity,
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
                  child: Tooltip(
                    message: appLocalizations.scan_header_clear_button_tooltip,
                    child: ElevatedButton.icon(
                      style: buttonStyle,
                      icon: const Icon(Icons.clear_all),
                      onPressed: model.clearScanSession,
                      label: Text(appLocalizations.clear),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.6,
                  ),
                  child: Tooltip(
                    message: compareFeatureAvailable
                        ? appLocalizations
                            .scan_header_compare_button_valid_state_tooltip
                        : appLocalizations
                            .scan_header_compare_button_invalid_state_tooltip,
                    child: AnimatedOpacity(
                      opacity: compareFeatureAvailable ? 1.0 : 0.5,
                      duration: SmoothAnimationsDuration.brief,
                      child: ElevatedButton.icon(
                        style: buttonStyle,
                        icon: const Icon(Icons.compare_arrows),
                        onPressed: compareFeatureAvailable
                            ? () async {
                                final ContinuousScanModel model =
                                    context.read<ContinuousScanModel>();
                                await model.refreshProductList();
                                if (!context.mounted) {
                                  return;
                                }
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        PersonalizedRankingPage(
                                      barcodes: model
                                          .getAvailableBarcodes()
                                          .toList(growable: false),
                                      title: ProductQueryPageHelper
                                          .getProductListLabel(
                                        model.productList,
                                        appLocalizations,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        label: FittedBox(
                          child: Text(
                            appLocalizations.plural_compare_x_products(
                              model.getAvailableBarcodes().length,
                            ),
                            maxLines: 1,
                          ),
                        ),
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
