import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/resources/app_animations.dart';

typedef AnonymousAnnotationList = Map<String, InsightAnnotation>;

class CongratsWidget extends StatelessWidget {
  const CongratsWidget({
    required this.continueButtonLabel,
    required this.anonymousAnnotationList,
    this.onContinue,
  });

  final String? continueButtonLabel;
  final VoidCallback? onContinue;
  final AnonymousAnnotationList anonymousAnnotationList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserManagementProvider userManagementProvider =
        context.watch<UserManagementProvider>();

    return Center(
      child: SmoothCard(
        ignoreDefaultSemantics: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: MEDIUM_SPACE,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.only(top: SMALL_SPACE),
                child: _Header(),
              ),
              FractionallySizedBox(
                child: FutureBuilder<bool>(
                    future: userManagementProvider.credentialsInStorage(),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
              ),
              if (continueButtonLabel != null)
                SmoothSimpleButton(
                  onPressed: onContinue,
                  child: Text(continueButtonLabel!),
                ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: MEDIUM_SPACE),
                  child: SmoothSimpleButton(
                    child: Text(appLocalizations.close),
                    onPressed: () => Navigator.maybePop<Widget>(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildSignInButton(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Column(
      children: <Widget>[
        const SizedBox(height: MEDIUM_SPACE),
        Semantics(
          value: appLocalizations.question_sign_in_text,
          button: true,
          excludeSemantics: true,
          container: true,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: SmoothActionButtonsBar.single(
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
                    if (!context.mounted) {
                      return;
                    }
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
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        ExcludeSemantics(
          child: Text(
            appLocalizations.question_sign_in_text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE * 3),
      ],
    );
  }

  Future<List<bool>> _postInsightAnnotations(
    Map<String, InsightAnnotation> annotationList,
  ) async {
    final List<bool> results = <bool>[];

    for (final MapEntry<String, InsightAnnotation> annotation
        in annotationList.entries) {
      final Status status = await RobotoffAPIClient.postInsightAnnotation(
        annotation.key,
        annotation.value,
        deviceId: OpenFoodAPIConfiguration.uuid,
      );

      results.add(status.status == 1);
    }

    return results;
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double multiplier =
        math.min(350, MediaQuery.sizeOf(context).height * 0.3) / 235;

    return Semantics(
      enabled: true,
      container: true,
      value: appLocalizations.thanks_for_contributing,
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: SMALL_SPACE,
            ),
            child: SizedBox(
              width: 230 * multiplier,
              height: 235 * multiplier,
              child: const SunAnimation(type: SunAnimationType.fullAnimation),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: MEDIUM_SPACE,
            ),
            child: Text(
              appLocalizations.thanks_for_contributing,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
