import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';

class CongratsWidget extends StatelessWidget {
  const CongratsWidget({
    required this.continueButtonLabel,
    required this.anonymousAnnotationList,
    this.onContinue,
  });

  final String? continueButtonLabel;
  final VoidCallback? onContinue;
  final Map<String, InsightAnnotation> anonymousAnnotationList;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserManagementProvider userManagementProvider =
        context.watch<UserManagementProvider>();

    return Center(
      child: SmoothCard(
        ignoreDefaultSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: SMALL_SPACE),
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
                child: SmoothSimpleButton(
                  child: Text(appLocalizations.close),
                  onPressed: () => Navigator.maybePop<Widget>(context),
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
                    // ignore: use_build_context_synchronously
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

class _Header extends StatefulWidget {
  const _Header();

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _star1;
  late AnimationController _controller2;
  late Animation<double> _star2;
  late AnimationController _controller3;
  late Animation<double> _star3;

  @override
  void initState() {
    super.initState();
    // We create a custom animation, to add a slight delay between each
    // apparition of a star

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _star1 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _star2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller2);

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _star3 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller3);

    _controller1.addListener(() {
      if (!_controller2.isAnimating && _controller1.value > 0.25) {
        _controller2.repeat();
        setState(() {});
      }
    });

    _controller2.addListener(() {
      if (!_controller3.isAnimating && _controller2.value > 0.25) {
        _controller3.repeat();
        setState(() {});
      }
    });

    _controller1.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Semantics(
      enabled: true,
      container: true,
      value: appLocalizations.thanks_for_contributing,
      excludeSemantics: true,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.scale(
                scale: 2.0,
                child: Lottie.asset(
                  'assets/animations/stars.json',
                  controller: _star1,
                  package: AppHelper.APP_PACKAGE,
                  height: 70.0,
                  width: 70.0,
                ),
              ),
              AnimatedOpacity(
                opacity: _controller2.isAnimating ? 1.0 : 0.0,
                duration: SmoothAnimationsDuration.short,
                child: Transform.scale(
                  scale: 2.0,
                  child: Lottie.asset(
                    'assets/animations/stars.json',
                    controller: _star2,
                    package: AppHelper.APP_PACKAGE,
                    height: 70.0,
                    width: 70.0,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: _controller3.isAnimating ? 1.0 : 0.0,
                duration: SmoothAnimationsDuration.short,
                child: Transform.scale(
                  scale: 2.0,
                  child: Lottie.asset(
                    'assets/animations/stars.json',
                    controller: _star3,
                    package: AppHelper.APP_PACKAGE,
                    height: 70.0,
                    width: 70.0,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
            child: Text(
              appLocalizations.thanks_for_contributing,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
}
