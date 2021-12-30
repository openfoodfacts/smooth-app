import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_ui_library/widgets/smooth_text_form_field.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sign Up Page
class SignUpPage extends StatefulWidget {
  const SignUpPage();

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const double space = 10;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  bool _foodProducer = false;
  bool _agree = false;
  bool _subscribe = false;
  bool _disagreed = false;
  late bool _popEd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;

    // TODO(monsieurtanuki): translations
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Form(
        onChanged: () {
          setState(() {});
        },
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          children: <Widget>[
            SmoothTextFormField(
              textInputType: TextInputType.name,
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _displayNameController,
              hintText: 'Display Name',
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.name],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the display name you want to use';
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              textInputType: TextInputType.emailAddress,
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _emailController,
              hintText: 'E-mail',
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.email],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the e-mail';
                }
                if (!UserManagementHelper.isEmailValid(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _userController,
              hintText: 'Username',
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.username],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              type: TextFieldTypes.PASSWORD,
              controller: _password1Controller,
              hintText: appLocalizations.password,
              prefixIcon: const Icon(Icons.vpn_key),
              autofillHints: const <String>[AutofillHints.password],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (!UserManagementHelper.isPasswordValid(value)) {
                  return 'Please enter a valid password (at least 6 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              type: TextFieldTypes.PASSWORD,
              controller: _password2Controller,
              hintText: 'Confirm Password',
              prefixIcon: const Icon(Icons.vpn_key),
              autofillHints: const <String>[
                AutofillHints.password,
              ],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm the password';
                }
                if (value != _password1Controller.text) {
                  return 'The passwords should be identical';
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            Text('Username cannot contains spaces, caps or special characters'),
            const SizedBox(height: space),
            // careful with CheckboxListTile and hyperlinks
            // cf. https://github.com/flutter/flutter/issues/31437
            ListTile(
              leading: Checkbox(
                value: _agree,
                onChanged: (final bool? value) {
                  if (value != null) {
                    setState(() => _agree = value);
                  }
                },
              ),
              title: RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'I agree to the Open Food Facts ',
                    ),
                    TextSpan(
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      text: 'terms of use and contribution',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final String url =
                              'https://world-en.openfoodfacts.org/terms-of-use';
                          if (await canLaunch(url)) {
                            await launch(
                              url,
                              forceSafariVC: false,
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),
              subtitle: !_disagreed
                  ? null
                  : Text(
                      'You have to agree my friend!',
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
            ),
            const SizedBox(height: space),
            ListTile(
              leading: Checkbox(
                value: _foodProducer,
                onChanged: (final bool? value) {
                  if (value != null) {
                    setState(() => _foodProducer = value);
                  }
                },
              ),
              title: Text('I am a food producer'),
            ),
            if (_foodProducer) ...<Widget>[
              const SizedBox(height: space),
              SmoothTextFormField(
                type: TextFieldTypes.PLAIN_TEXT,
                controller: _brandController,
                hintText: 'Producer/brand',
                prefixIcon: const Icon(Icons.person),
                autofillHints: const <String>[AutofillHints.name],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a producer or a brand name';
                  }
                  return null;
                },
              )
            ],
            const SizedBox(height: space),
            ListTile(
              leading: Checkbox(
                value: _subscribe,
                onChanged: (final bool? value) {
                  if (value != null) {
                    setState(() => _subscribe = value);
                  }
                },
              ),
              title: Text(
                  'I\'d like to subscribe to the Open Food Facts newsletter (Note: I can unsubscribe from it at all time)'),
            ),
            const SizedBox(height: space),
            ElevatedButton(
              onPressed: () async => _signUp(),
              child: Text(
                'Sign Up',
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
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    _disagreed = !_agree;
    setState(() {});
    if (!_formKey.currentState!.validate() || _disagreed) {
      return;
    }
    _popEd = false;
    await _openSigningUpDialog();
    // TODO(monsieurtanuki): then what?
  }

  Future<Status?> _openSigningUpDialog() async => showDialog<Status>(
        context: context,
        builder: (BuildContext context) {
          OpenFoodAPIClient.register(
            user: User(
              userId: _userController.text,
              password: _password1Controller.text,
            ),
            name: _displayNameController.text,
            email: _emailController.text,
            newsletter: _subscribe,
            orgName: _foodProducer ? _brandController.text : null,
          ).then<void>(
            (final Status status) => _popSigningUpDialog(status),
          );
          return _getSigningUpDialog();
        },
      );

  void _popSigningUpDialog(final Status? status) {
    if (_popEd) {
      return;
    }
    _popEd = true;
    // Here we use the root navigator so that we can pop dialog while using multiple navigators.
    Navigator.of(context, rootNavigator: true).pop(status);
  }

  Widget _getSigningUpDialog() => SmoothAlertDialog(
        close: false,
        body: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text('Signing up...'),
        ),
        actions: <SmoothSimpleButton>[
          SmoothSimpleButton(
            text: AppLocalizations.of(context)!.stop,
            onPressed: () => _popSigningUpDialog(null),
          ),
        ],
      );
}
