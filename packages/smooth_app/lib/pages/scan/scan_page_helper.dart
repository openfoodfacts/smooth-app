import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/widgets/ranking_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';
import 'package:smooth_ui_library/widgets/smooth_view_finder.dart';

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

List<Widget> getScannerWidgets(
  BuildContext context,
  BoxConstraints constraints,
  ContinuousScanModel model,
) {
  final Size screenSize = MediaQuery.of(context).size;
  final Size scannerSize = Size(
    screenSize.width * 0.6,
    screenSize.width * 0.33,
  );
  final double carouselHeight =
      constraints.maxHeight / 1.81; // roughly 55% of the available height
  final double buttonRowHeight = areButtonsRendered(model) ? 48 : 0;
  final double availableScanHeight =
      constraints.maxHeight - carouselHeight - buttonRowHeight;
  // Padding for the qr code scanner. This ensures the scanner has equal spacing between buttons and carousel.
  final EdgeInsets qrScannerPadding = EdgeInsets.only(
      top: (availableScanHeight - scannerSize.height) / 2 + buttonRowHeight);

  return <Widget>[
    Container(
      alignment: Alignment.center,
      color: Colors.black,
      child: Padding(
        padding: qrScannerPadding,
        child: SvgPicture.asset(
          'assets/actions/scanner_alt_2.svg',
          width: scannerSize.width,
          height: scannerSize.height,
          color: Colors.white,
        ),
      ),
    ),
    SmoothRevealAnimation(
      delay: 400,
      startOffset: const Offset(0.0, 0.1),
      animationCurve: Curves.easeInOutBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: qrScannerPadding,
            child: SmoothViewFinder(
              boxSize: scannerSize,
              lineLength: screenSize.width * 0.8,
            ),
          ),
        ],
      ),
    ),
    SmoothRevealAnimation(
      delay: 400,
      startOffset: const Offset(0.0, -0.1),
      animationCurve: Curves.easeInOutBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildButtonsRow(context, model),
          const Spacer(),
          SmoothProductCarousel(
            showSearchCard: true,
            height: carouselHeight,
          ),
        ],
      ),
    ),
  ];
}
