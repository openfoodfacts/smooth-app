import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/alternative_continuous_scan_page.dart';
import 'package:smooth_app/pages/continuous_scan_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';
import 'package:smooth_app/database/product_query.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({
    @required this.contributionMode,
    @required this.mlKit,
  });

  final bool contributionMode;
  final bool mlKit;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    return FutureBuilder<ContinuousScanModel>(
        future: ContinuousScanModel(
          contributionMode: contributionMode,
          languageCode: ProductQuery.getCurrentLanguageCode(context),
          countryCode: ProductQuery.getCurrentCountryCode(),
        ).load(localDatabase),
        builder: (BuildContext context,
            AsyncSnapshot<ContinuousScanModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final ContinuousScanModel continuousScanModel = snapshot.data;
            if (continuousScanModel != null) {
              return mlKit
                  ? ContinuousScanPage(continuousScanModel)
                  : AlternativeContinuousScanPage(continuousScanModel);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  static Widget getContributeChooseToggle(final ContinuousScanModel model) =>
      SmoothToggle(
        value: model.contributionMode,
        textLeft: '  CONTRIBUTE',
        textRight: 'CHOOSE      ',
        colorLeft: Colors.black.withAlpha(160),
        colorRight: Colors.black.withAlpha(160),
        iconLeft: SvgPicture.asset('assets/ikonate_bold/add.svg'),
        iconRight: SvgPicture.asset('assets/ikonate_bold/search.svg'),
        textSize: 12.0,
        animationDuration: const Duration(milliseconds: 320),
        width: 150.0,
        height: 50.0,
        onChanged: (bool value) => model.contributionModeSwitch(value),
      );

  static Widget getHero(final Size screenSize) => Hero(
        tag: 'action_button',
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.black,
          child: Center(
            child: SvgPicture.asset(
              'assets/actions/scanner_alt_2.svg',
              width: 60.0,
              height: 60.0,
              color: Colors.white,
            ),
          ),
        ),
      );
}
