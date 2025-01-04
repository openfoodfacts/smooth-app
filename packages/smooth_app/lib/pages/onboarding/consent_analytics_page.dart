import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_bottom_bar.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ConsentAnalyticsPage extends StatelessWidget {
  const ConsentAnalyticsPage(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        bottom: Platform.isAndroid,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/onboarding/analytics.svg',
                        width: screenSize.width * .50,
                        package: AppHelper.APP_PACKAGE,
                      ),
                      const SizedBox(height: LARGE_SPACE),
                      AutoSizeText(
                        appLocalizations.consent_analytics_title,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.displayLarge!.apply(
                            color: const Color.fromARGB(255, 51, 51, 51)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      AutoSizeText(
                        appLocalizations.consent_analytics_body1,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      AutoSizeText(
                        appLocalizations.consent_analytics_body2,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
                      ),
                    ],
                  ),
                ),
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
              semanticsHorizontalOrder: false,
            ),
          ],
        ),
      ),
    );
  }

  static const OnboardingPage _onboardingPage = OnboardingPage.CONSENT_PAGE;

  Future<void> _analyticsLogic(
    bool accept,
    UserPreferences userPreferences,
    LocalDatabase localDatabase,
    BuildContext context,
    final ThemeProvider themeProvider,
  ) async {
    await userPreferences.setCrashReports(accept);
    await userPreferences.setUserTracking(accept);

    themeProvider.finishOnboarding();
    if (!context.mounted) {
      return;
    }
    await OnboardingLoader(localDatabase).runAtNextTime(
      _onboardingPage,
      context,
    );

    if (!context.mounted) {
      return;
    }
    await OnboardingFlowNavigator(userPreferences).navigateToPage(
      context,
      _onboardingPage.getNextPage(),
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
