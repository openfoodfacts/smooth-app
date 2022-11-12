import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';

class CongratsWidget extends StatelessWidget {
  const CongratsWidget({
    required this.shouldDisplayContinueButton,
    required this.anonymousAnnotationList,
    this.onContinue,
    super.key,
  });

  final bool shouldDisplayContinueButton;
  final VoidCallback? onContinue;
  final Map<String, InsightAnnotation> anonymousAnnotationList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserManagementProvider userManagementProvider =
        context.watch<UserManagementProvider>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.grade,
            color: Colors.amber,
            size: 100,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
            child: Text(
              appLocalizations.thanks_for_contributing,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          FutureBuilder<bool>(
              future: userManagementProvider.credentialsInStorage(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return EMPTY_WIDGET;
                }
                final bool isUserLoggedIn = snapshot.data!;
                if (isUserLoggedIn) {
                  // TODO(jasmeet): Show leaderboard button.
                  return EMPTY_WIDGET;
                } else {
                  return _buildSignInButton(context, appLocalizations);
                }
              }),
          if (shouldDisplayContinueButton)
            SmoothSimpleButton(
              onPressed: onContinue,
              child: Text(appLocalizations.robotoff_continue),
            )
          else
            EMPTY_WIDGET,
          TextButton(
            child: Text(appLocalizations.close),
            onPressed: () => Navigator.maybePop<Widget>(context),
          ),
        ],
      ),
    );
  }

  Column _buildSignInButton(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: <Widget>[
        SmoothActionButtonsBar.single(
          action: SmoothActionButton(
            text: appLocalizations.sign_in,
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const LoginPage(),
                ),
              );
              if (OpenFoodAPIConfiguration.globalUser != null) {
                LoadingDialog.run<void>(
                  context: context,
                  title: appLocalizations.saving_answer,
                  future: _postInsightAnnotations(
                    anonymousAnnotationList,
                  ),
                );
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
          child: Text(
            appLocalizations.question_sign_in_text,
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<List<bool>> _postInsightAnnotations(
    Map<String, InsightAnnotation> annotationList,
  ) async {
    final List<bool> results = <bool>[];

    for (final MapEntry<String, InsightAnnotation> annotation
        in annotationList.entries) {
      final Status status = await OpenFoodAPIClient.postInsightAnnotation(
        annotation.key,
        annotation.value,
        deviceId: OpenFoodAPIConfiguration.uuid,
        user: OpenFoodAPIConfiguration.globalUser,
      );

      results.add(status.status == 1);
    }

    return results;
  }
}
