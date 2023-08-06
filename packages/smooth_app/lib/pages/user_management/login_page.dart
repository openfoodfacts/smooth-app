import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/pages/user_management/forgot_password_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TraceableClientMixin {
  bool _runningQuery = false;
  bool _wrongCredentials = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final UserManagementProvider userManagementProvider =
        context.read<UserManagementProvider>();

    setState(() {
      _runningQuery = true;
      _wrongCredentials = false;
    });

    final bool login = await userManagementProvider.login(
      User(
        userId: userIdController.text,
        password: passwordController.text,
      ),
    );

    if (login) {
      AnalyticsHelper.trackEvent(AnalyticsEvent.loginAction);
      if (!mounted) {
        return;
      }

      await showInAppReviewIfNecessary(context);

      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } else {
      setState(() {
        _runningQuery = false;
        _wrongCredentials = true;
      });
    }
  }

  @override
  String get traceTitle => 'login_page';

  @override
  String get traceName => 'Opened login_page';

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;

    return SmoothScaffold(
      statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
      contentBehindStatusBar: true,
      fixKeyboard: true,
      appBar: SmoothAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              width: double.infinity,
              padding: EdgeInsetsDirectional.only(
                start: size.width * 0.15,
                end: size.width * 0.15,
                bottom: size.width * 0.05,
              ),
              child: AutofillGroup(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/preferences/login.svg',
                        height: MediaQuery.of(context).size.height * .15,
                        package: AppHelper.APP_PACKAGE,
                      ),
                      Text(
                        appLocalizations.sign_in_text,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: VERY_LARGE_SPACE,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: LARGE_SPACE * 3,
                      ),

                      if (_wrongCredentials) ...<Widget>[
                        SmoothCard(
                          padding: const EdgeInsets.all(10.0),
                          color: const Color(0xFFFF4446),
                          child: Text(
                            appLocalizations.incorrect_credentials,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 18.0,
                              color: const Color(0xFF000000),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: LARGE_SPACE * 2,
                        ),
                      ],
                      //Login
                      SmoothTextFormField(
                        type: TextFieldTypes.PLAIN_TEXT,
                        textInputType: TextInputType.name,
                        controller: userIdController,
                        hintText: appLocalizations.username_or_email,
                        prefixIcon: const Icon(Icons.person),
                        enabled: !_runningQuery,
                        // Moves focus to the next field
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations
                                .login_page_username_or_email;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                        height: LARGE_SPACE * 2,
                      ),

                      //Password
                      SmoothTextFormField(
                        type: TextFieldTypes.PASSWORD,
                        textInputType: TextInputType.text,
                        controller: passwordController,
                        hintText: appLocalizations.password,
                        prefixIcon: const Icon(Icons.vpn_key),
                        enabled: !_runningQuery,
                        textInputAction: TextInputAction.send,
                        // Hides the keyboard
                        autofillHints: const <String>[
                          AutofillHints.password,
                        ],
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations
                                .login_page_password_error_empty;
                          }
                          return null;
                        },
                        onFieldSubmitted: (String value) {
                          if (value.isNotEmpty) {
                            _login(context);
                          }
                        },
                      ),

                      const SizedBox(
                        height: LARGE_SPACE * 2,
                      ),

                      //Sign in button
                      if (_runningQuery)
                        const CircularProgressIndicator.adaptive()
                      else
                        ElevatedButton(
                          onPressed: () => _login(context),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(size.width * 0.5,
                                  theme.buttonTheme.height + 10),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: CIRCULAR_BORDER_RADIUS,
                              ),
                            ),
                          ),
                          child: Text(
                            appLocalizations.sign_in,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),

                      const SizedBox(
                        height: LARGE_SPACE * 2,
                      ),

                      //Forgot password
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: VERY_LARGE_SPACE,
                            ),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: CIRCULAR_BORDER_RADIUS,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          appLocalizations.forgot_password,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 18.0,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: LARGE_SPACE * 2,
                      ),

                      //Open register page
                      SizedBox(
                        height: size.height * 0.06,
                        child: OutlinedButton(
                          onPressed: () async {
                            // TODO(monsieurtanuki): we probably don't need the returned value and could check the "logged in?" question differently
                            // TODO(monsieurtanuki): careful, waiting for pop'ed value
                            final bool? registered = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (BuildContext context) =>
                                    const SignUpPage(),
                              ),
                            );
                            if (registered == true) {
                              if (!mounted) {
                                return;
                              }
                              Navigator.of(context).pop();
                            }
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(
                                  color: theme.colorScheme.primary, width: 2.0),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(size.width * 0.5, theme.buttonTheme.height),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: CIRCULAR_BORDER_RADIUS,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(bottom: 2.0),
                            child: Text(
                              appLocalizations.create_account,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: VERY_LARGE_SPACE,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showInAppReviewIfNecessary(BuildContext context) async {
    final UserPreferences preferences = context.read<UserPreferences>();
    if (!preferences.inAppReviewAlreadyAsked) {
      assert(mounted);
      final bool? enjoyingApp = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);

          return SmoothAlertDialog(
            body: Text(appLocalizations.app_rating_dialog_title_enjoying_app),
            positiveAction: SmoothActionButton(
              text: appLocalizations
                  .app_rating_dialog_title_enjoying_positive_actions,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            negativeAction: SmoothActionButton(
              text: appLocalizations.not_really,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          );
        },
      );
      if (enjoyingApp != null && !enjoyingApp) {
        // ignore: use_build_context_synchronously
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);

            return SmoothAlertDialog(
              body: Text(
                  appLocalizations.app_rating_dialog_title_not_enjoying_app),
              positiveAction: SmoothActionButton(
                text: appLocalizations.okay,
                onPressed: () async {
                  final String formLink =
                      UserFeedbackHelper.getFeedbackFormLink();
                  LaunchUrlHelper.launchURL(formLink, false);
                  Navigator.of(context).pop();
                },
              ),
              negativeAction: SmoothActionButton(
                text: appLocalizations.not_really,
                onPressed: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      }
      bool? userRatedApp;
      if (enjoyingApp != null && enjoyingApp) {
        // ignore: use_build_context_synchronously
        userRatedApp = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final AppLocalizations appLocalizations =
                AppLocalizations.of(context);

            return SmoothAlertDialog(
              body: Text(appLocalizations.app_rating_dialog_title),
              positiveAction: SmoothActionButton(
                text: appLocalizations.app_rating_dialog_positive_action,
                onPressed: () async => Navigator.of(context).pop(
                  await ApplicationStore.openAppReview(),
                ),
              ),
              negativeAction: SmoothActionButton(
                text: appLocalizations.ask_me_later_button_label,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            );
          },
        );
      }
      if (userRatedApp != null && userRatedApp) {
        await preferences.markInAppReviewAsShown();
      }
    }
  }
}
