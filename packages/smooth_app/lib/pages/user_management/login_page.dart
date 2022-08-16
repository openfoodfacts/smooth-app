import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/user_management/forgot_password_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
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
    final UserManagementProvider userManagementProvider =
        context.read<UserManagementProvider>();
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      AnalyticsHelper.trackLogin();
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
      extendBodyBehindAppBar: true,
      statusBarBackgroundColor: SmoothScaffold.semiTranslucentStatusBar,
      contentBehindStatusBar: true,
      appBar: AppBar(
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
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.15,
                vertical: size.width * 0.05,
              ),
              child: AutofillGroup(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(
                        height: LARGE_SPACE * 2,
                      ),

                      SvgPicture.asset(
                        'assets/preferences/login.svg',
                        height: MediaQuery.of(context).size.height * .15,
                      ),
                      Text(
                        appLocalizations.sign_in_text,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headline1?.copyWith(
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
                          color: Colors.red,
                          child: Text(appLocalizations.incorrect_credentials),
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
                        textInputAction: TextInputAction.done,
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
                        const CircularProgressIndicator()
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
                            style: theme.textTheme.bodyText2?.copyWith(
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
                            MaterialPageRoute<Widget>(
                              builder: (BuildContext context) =>
                                  const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          appLocalizations.forgot_password,
                          style: theme.textTheme.bodyText2?.copyWith(
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
                              style: theme.textTheme.bodyText2?.copyWith(
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
}
