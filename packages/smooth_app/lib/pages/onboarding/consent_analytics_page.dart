import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

class ConsentAnalytics extends StatelessWidget {
  const ConsentAnalytics(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/onboarding/analytics.svg',
                  width: screenSize.width * .50,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: SMALL_SPACE),
                  child: AutoSizeText(
                    appLocalizations.consent_analytics_title,
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .apply(color: const Color.fromARGB(255, 51, 51, 51)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: SMALL_SPACE),
                  child: AutoSizeText(
                    appLocalizations.consent_analytics_body1,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: SMALL_SPACE),
                  child: AutoSizeText(
                    appLocalizations.consent_analytics_body2,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          _buildBottomAppBar(context, appLocalizations),
        ],
      ),
    );
  }

  Future<void> _analyticsLogic(
    bool accept,
    UserPreferences userPreferences,
    LocalDatabase localDatabase,
    BuildContext context,
  ) async {
    await userPreferences.setCrashReports(accept);
    AnalyticsHelper.setAnalyticsReports(accept);
    //ignore: use_build_context_synchronously
    await OnboardingLoader(localDatabase).runAtNextTime(
      OnboardingPage.CONSENT_PAGE,
      context,
    );
    //ignore: use_build_context_synchronously
    OnboardingFlowNavigator(userPreferences).navigateToPage(
      context,
      OnboardingFlowNavigator.getNextPage(OnboardingPage.CONSENT_PAGE),
    );
  }

  Widget _buildBottomAppBar(
    final BuildContext context,
    final AppLocalizations appLocalizations,
  ) {
    final Size screenSize = MediaQuery.of(context).size;
    // Side padding is 8% of total width.
    final double sidePadding = screenSize.width * .08;
    return Column(
      children: <Widget>[
        Container(
          height: SMALL_SPACE,
          width: screenSize.width,
          color: LIGHT_GREY_COLOR,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: VERY_LARGE_SPACE,
            horizontal: sidePadding,
          ),
          width: screenSize.width,
          color: backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildButton(
                context,
                appLocalizations.refuse_button_label,
                false,
                const Color(0xFFA08D84),
                Colors.white,
              ),
              _buildButton(
                context,
                appLocalizations.authorize_button_label,
                true,
                Colors.white,
                Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    bool isAccepted,
    final Color backgroundColor,
    final Color foregroundColor,
  ) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: MINIMUM_TARGET_SIZE),
      child: ElevatedButton(
        onPressed: () {
          _analyticsLogic(
            isAccepted,
            userPreferences,
            localDatabase,
            context,
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .headline3
              ?.copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}
