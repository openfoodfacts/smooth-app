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
import 'package:smooth_app/pages/onboarding/onboarding_bottom_bar.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/theme_provider.dart';

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
                  padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
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
                  padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                  child: AutoSizeText(
                    appLocalizations.consent_analytics_body1,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
                  child: AutoSizeText(
                    appLocalizations.consent_analytics_body2,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          OnboardingBottomBar(
            leftButton: _buildButton(
              context,
              appLocalizations.refuse_button_label,
              false,
              const Color(0xFFA08D84),
              Colors.white,
            ),
            rightButton: _buildButton(
              context,
              appLocalizations.authorize_button_label,
              true,
              Colors.white,
              Colors.black,
            ),
            backgroundColor: backgroundColor,
          ),
        ],
      ),
    );
  }

  Future<void> _analyticsLogic(
    bool accept,
    UserPreferences userPreferences,
    LocalDatabase localDatabase,
    BuildContext context,
    final ThemeProvider themeProvider,
  ) async {
    await userPreferences.setCrashReports(accept);
    AnalyticsHelper.setAnalyticsReports(accept);
    themeProvider.finishOnboarding();
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

  Widget _buildButton(
    final BuildContext context,
    final String label,
    final bool isAccepted,
    final Color backgroundColor,
    final Color foregroundColor,
  ) =>
      OnboardingBottomButton(
        onPressed: () async => _analyticsLogic(
          isAccepted,
          context.read<UserPreferences>(),
          context.read<LocalDatabase>(),
          context,
          context.read<ThemeProvider>(),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        label: label,
      );
}
