import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';

class ConsentAnalytics extends StatelessWidget {
  const ConsentAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    const Color shadowColor = Color.fromARGB(144, 0, 0, 0);
    const String assetName = 'assets/onboarding/analytics.svg';
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
            width: size.width * 0.45,
            child: SvgPicture.asset(
              assetName,
              semanticsLabel: 'Analytics Icons',
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          Align(
            alignment: Alignment.center,
            child: Text(
              appLocalizations.consent_analytics_title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),

          SizedBox(height: size.height * 0.034),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              appLocalizations.consent_analytics_body1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),

          SizedBox(height: size.height * 0.03),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              appLocalizations.consent_analytics_body2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Authorize Button
          InkWell(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            onTap: () {
              _analyticsLogic(true, userPreferences, localDatabase, context);
            },
            child: Ink(
              height: size.height * 0.06,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                color: LIGHT_GREEN_COLOR,
                borderRadius: CIRCULAR_BORDER_RADIUS,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 3.0,
                    color: shadowColor,
                    offset: Offset(size.width * 0.004, size.height * 0.004),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    appLocalizations.authorize_button_label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WHITE_COLOR,
                        fontSize: size.height * 0.025),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02),
                    child: Icon(
                      Icons.check,
                      color: WHITE_COLOR,
                      size: size.height * 0.04,
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Refuse Button
          InkWell(
            borderRadius: CIRCULAR_BORDER_RADIUS,
            onTap: () {
              _analyticsLogic(false, userPreferences, localDatabase, context);
            },
            child: Ink(
              height: size.height * 0.06,
              width: size.width * 0.7,
              decoration: BoxDecoration(
                color: RED_COLOR,
                borderRadius: CIRCULAR_BORDER_RADIUS,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 3.0,
                    color: shadowColor,
                    offset: Offset(size.width * 0.004, size.height * 0.004),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    appLocalizations.refuse_button_label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WHITE_COLOR,
                        fontSize: size.height * 0.025),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.02),
                    child: Icon(
                      Icons.close,
                      color: WHITE_COLOR,
                      size: size.height * 0.04,
                    ),
                  )
                ],
              ),
            ),
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
  ) async {
    await userPreferences.setCrashReports(accept);
    await userPreferences.setAnalyticsReports(accept);
    await OnboardingLoader(localDatabase).runAtNextTime(
      OnboardingPage.CONSENT_PAGE,
      context,
    );
    OnboardingFlowNavigator(userPreferences).navigateToPage(
      context,
      OnboardingFlowNavigator.getNextPage(OnboardingPage.CONSENT_PAGE),
    );
  }
}
