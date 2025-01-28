import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/login_result.dart';
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
  LoginResult? _loginResult;

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
      _loginResult = null;
    });

    _loginResult = await userManagementProvider.login(
      User(
        userId: userIdController.text,
        password: passwordController.text,
      ),
    );
    if (!context.mounted) {
      return;
    }
    setState(() => _runningQuery = false);

    if (_loginResult!.type != LoginResultType.successful) {
      return;
    }

    AnalyticsHelper.trackEvent(AnalyticsEvent.loginAction);
    await _showInAppReviewIfNecessary(context);
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  String get actionName => 'Opened login_page';

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
    final Size size = MediaQuery.sizeOf(context);

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
                        height: MediaQuery.sizeOf(context).height * .15,
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

                      if (_loginResult != null &&
                          _loginResult!.type != LoginResultType.successful)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: BALANCED_SPACE + LARGE_SPACE * 2,
                          ),
                          child: SmoothCard(
                            padding: const EdgeInsets.all(BALANCED_SPACE),
                            color: const Color(0xFFEB0004),
                            child: Text(
                              _loginResult!.getErrorMessage(appLocalizations),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 18.0,
                                color: const Color(0xFF000000),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      //Login
                      SmoothTextFormField(
                        type: TextFieldTypes.PLAIN_TEXT,
                        textInputType: TextInputType.emailAddress,
                        controller: userIdController,
                        hintText: appLocalizations.username_or_email,
                        prefixIcon: const Icon(Icons.person),
                        enabled: !_runningQuery,
                        // Moves focus to the next field
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
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
                        maxLines: 1,
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
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size(size.width * 0.5,
                                  theme.buttonTheme.height + 10),
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
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
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                              vertical: BALANCED_SPACE,
                              horizontal: VERY_LARGE_SPACE,
                            ),
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius: CIRCULAR_BORDER_RADIUS,
                            ),
                          ),
                        ),
                        onPressed: () async => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const ForgotPasswordPage(),
                          ),
                        ),
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
                              if (!context.mounted) {
                                return;
                              }
                              Navigator.of(context).pop();
                            }
                          },
                          style: ButtonStyle(
                            side: WidgetStateProperty.all<BorderSide>(
                              BorderSide(
                                  color: theme.colorScheme.primary, width: 2.0),
                            ),
                            minimumSize: WidgetStateProperty.all<Size>(
                              Size(size.width * 0.5, theme.buttonTheme.height),
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
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

  Future<void> _showInAppReviewIfNecessary(BuildContext context) async {
    final UserPreferences preferences = context.read<UserPreferences>();
    if (preferences.inAppReviewAlreadyAsked) {
      return;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool? enjoyingApp = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.app_rating_dialog_title_enjoying_app,
        body: const SizedBox.shrink(),
        close: true,
        actionsAxis: Axis.vertical,
        positiveAction: SmoothActionButton(
          text: appLocalizations.tagline_app_review_button_positive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.tagline_app_review_button_negative,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        neutralAction: SmoothActionButton(
          text: appLocalizations.tagline_app_review_button_later,
          onPressed: () => Navigator.of(context).pop(null),
        ),
      ),
    );
    if (enjoyingApp == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    if (!enjoyingApp) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: Text(appLocalizations.app_rating_dialog_title_not_enjoying_app),
          positiveAction: SmoothActionButton(
            text: appLocalizations.okay,
            onPressed: () async {
              final String formLink = UserFeedbackHelper.getFeedbackFormLink();
              LaunchUrlHelper.launchURL(formLink);
              Navigator.of(context).pop();
            },
          ),
          negativeAction: SmoothActionButton(
            text: appLocalizations.not_really,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
      return;
    }

    final bool? userRatedApp = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalizations.app_rating_dialog_title),
        positiveAction: SmoothActionButton(
          text: appLocalizations.app_rating_dialog_positive_action,
          onPressed: () async => Navigator.of(context).pop(
            await ApplicationStore.openAppReview(),
          ),
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.ask_me_later_button_label,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (userRatedApp == true) {
      await preferences.markInAppReviewAsShown();
    }
  }
}
