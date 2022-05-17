import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.analytics,
                size: size.width * 0.4,
              ),
              SizedBox(height: size.height * 0.02),
              Center(
                child: Text(
                  appLocalizations.consent_analytics_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.8,
                ),
                child: Text(
                  appLocalizations.consent_analytics_body1,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.8,
                ),
                child: Text(
                  appLocalizations.consent_analytics_body2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(context, appLocalizations),
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

  BottomAppBar _buildBottomAppBar(
      BuildContext context, AppLocalizations appLocalizations) {
    return BottomAppBar(
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildButton(
            context,
            appLocalizations.refuse_button_label,
            const Icon(
              Icons.close_rounded,
            ),
            false,
          ),
          _buildButton(
            context,
            appLocalizations.authorize_button_label,
            const Icon(
              Icons.check_rounded,
            ),
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    Icon icon,
    bool isAccepted,
  ) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    return TextButton.icon(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(
                horizontal: VERY_LARGE_SPACE, vertical: SMALL_SPACE)),
      ),
      onPressed: () {
        _analyticsLogic(
          isAccepted,
          userPreferences,
          localDatabase,
          context,
        );
      },
      icon: icon,
      label: Text(label),
    );
  }
}
