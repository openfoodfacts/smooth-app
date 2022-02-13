import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/scan/scan_page_helper.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';

class ScanHeader extends StatelessWidget {
  const ScanHeader({Key? key}) : super(key: key);

  static const Duration duration = Duration(milliseconds: 50);
  static const double visibleOpacity = 0.8;
  static const double invisibleOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();

    final ButtonStyle buttonStyle = ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );

    return AnimatedOpacity(
      opacity:
          model.getBarcodes().isNotEmpty ? visibleOpacity : invisibleOpacity,
      duration: duration,
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
}
