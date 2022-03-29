import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/user_management/forgot_password_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/themes/theme_provider.dart';

// TODO(M123-dev): Handle colors better

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _customGrey = Colors.grey;
  static Color _textFieldBackgroundColor =
      const Color.fromARGB(255, 240, 240, 240);

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
      Navigator.pop(context);
    } else {
      setState(() {
        _runningQuery = false;
        _wrongCredentials = true;
      });
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;

    // Needs to be changed
    if (themeProvider.darkTheme) {
      _textFieldBackgroundColor = Colors.white10;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: size.width * 0.7,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(flex: 4),

                  Text(
                    appLocalizations.sign_in_text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline1?.copyWith(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const Spacer(flex: 8),

                  if (_wrongCredentials) ...<Widget>[
                    SmoothCard(
                      padding: const EdgeInsets.all(10.0),
                      color: Colors.red,
                      child: Text(appLocalizations.incorrect_credentials),
                    ),
                    const Spacer(
                      flex: 1,
                    )
                  ],

                  //Login
                  SmoothTextFormField(
                    type: TextFieldTypes.PLAIN_TEXT,
                    controller: userIdController,
                    hintText: appLocalizations.username_or_email,
                    textColor: _customGrey,
                    backgroundColor: _textFieldBackgroundColor,
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
                        return appLocalizations.login_page_username_or_email;
                      }
                      return null;
                    },
                  ),

                  const Spacer(flex: 1),

                  //Password
                  SmoothTextFormField(
                    type: TextFieldTypes.PASSWORD,
                    controller: passwordController,
                    hintText: appLocalizations.password,
                    textColor: _customGrey,
                    backgroundColor: _textFieldBackgroundColor,
                    prefixIcon: const Icon(Icons.vpn_key),
                    enabled: !_runningQuery,
                    textInputAction: TextInputAction.done, // Hides the keyboard
                    autofillHints: const <String>[
                      AutofillHints.password,
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.login_page_password_error_empty;
                      }
                      return null;
                    },
                  ),

                  const Spacer(flex: 6),

                  //Sign in button
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text(
                      appLocalizations.sign_in,
                      style: theme.textTheme.bodyText2?.copyWith(
                        fontSize: 18.0,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(
                        Size(size.width * 0.5, theme.buttonTheme.height + 10),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: CIRCULAR_BORDER_RADIUS,
                        ),
                      ),
                    ),
                  ),

                  //Forgot password
                  TextButton(
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

                  const Spacer(flex: 4),

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
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        appLocalizations.create_account,
                        style: theme.textTheme.bodyText2?.copyWith(
                          fontSize: 18.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      style: ButtonStyle(
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(
                              color: theme.colorScheme.primary, width: 2.0),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(size.width * 0.5, theme.buttonTheme.height),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: CIRCULAR_BORDER_RADIUS,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
