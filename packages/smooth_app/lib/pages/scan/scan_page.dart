import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';
import 'package:smooth_ui_library/widgets/smooth_toggle.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({
    required this.contributionMode,
    Key? key,
  }) : super(key: key);

  final bool contributionMode;

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    return FutureBuilder<ContinuousScanModel?>(
        future: ContinuousScanModel(
          contributionMode: contributionMode,
          languageCode: ProductQuery.getCurrentLanguageCode(context),
          countryCode: ProductQuery.getCurrentCountryCode(),
        ).load(localDatabase),
        builder: (BuildContext context,
            AsyncSnapshot<ContinuousScanModel?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final ContinuousScanModel? continuousScanModel = snapshot.data;
            if (continuousScanModel != null) {
              return ContinuousScanPage(continuousScanModel);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  static Widget getContributeChooseToggle(
          final ContinuousScanModel model, BuildContext context) =>
      SmoothToggle(
        value: model.contributionMode,
        textLeft: '${AppLocalizations.of(context)!.scan_contribute}   ',
        textRight: '     ${AppLocalizations.of(context)!.scan_choose}',
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
