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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
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

          _buildTextHeader(
            context,
            appLocalizations.consent_analytics_title,
          ),

          SizedBox(height: size.height * 0.04),

          _buildTextBody(
            context,
            appLocalizations.consent_analytics_body1,
          ),

          SizedBox(height: size.height * 0.02),

          _buildTextBody(
            context,
            appLocalizations.consent_analytics_body2,
          ),

          SizedBox(height: size.height * 0.02),

          // Authorize Button
          _buildButton(
            context,
            Colors.green,
            appLocalizations.authorize_button_label,
            Icons.check,
            true,
          ),

          SizedBox(height: size.height * 0.01),

          // Reject button
          _buildButton(
            context,
            Colors.red,
            appLocalizations.refuse_button_label,
            Icons.close,
            false,
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

  Widget _buildButton(
    BuildContext context,
    Color btnColor,
    String label,
    IconData icon,
    bool isAccepted,
  ) {
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    const Color shadowColor = Color.fromARGB(144, 0, 0, 0);
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          size.width * 0.9,
          size.height * 0.05,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        primary: btnColor,
        shadowColor: shadowColor,
      ),
      onPressed: () {
        _analyticsLogic(
          isAccepted,
          userPreferences,
          localDatabase,
          context,
        );
      },
      icon: Icon(
        icon,
        color: WHITE_COLOR,
        size: size.height * 0.05,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: WHITE_COLOR,
          fontSize: size.height * 0.025,
        ),
      ),
    );
  }

  Widget _buildTextHeader(BuildContext context, String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  Widget _buildTextBody(BuildContext context, String title) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
