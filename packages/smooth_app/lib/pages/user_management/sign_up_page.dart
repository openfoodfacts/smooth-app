import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sign Up Page. Pop's true if the sign up was successful.
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;

    // TODO(monsieurtanuki): translations
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.sign_up_page_title,
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: Form(
        onChanged: () => setState(() {}),
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          children: <Widget>[
            SmoothTextFormField(
              textInputType: TextInputType.name,
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              hintText: appLocalizations.sign_up_page_display_name_hint,
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.name],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.sign_up_page_display_name_error_empty;
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              textInputType: TextInputType.emailAddress,
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _emailController,
              textInputAction: TextInputAction.next,
              hintText: appLocalizations.sign_up_page_email_hint,
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.email],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.sign_up_page_email_error_empty;
                }
                if (!UserManagementHelper.isEmailValid(value)) {
                  return appLocalizations.sign_up_page_email_error_invalid;
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              type: TextFieldTypes.PLAIN_TEXT,
              controller: _userController,
              textInputAction: TextInputAction.next,
              hintText: appLocalizations.sign_up_page_username_hint,
              prefixIcon: const Icon(Icons.person),
              autofillHints: const <String>[AutofillHints.username],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.sign_up_page_username_error_empty;
                }
                if (!UserManagementHelper.isUsernameValid(value)) {
                  return appLocalizations.sign_up_page_username_description;
                }
                return null;
              },
            ),

            const SizedBox(height: space),

            SmoothTextFormField(
              type: TextFieldTypes.PASSWORD,
              controller: _password1Controller,
              textInputAction: TextInputAction.next,
              hintText: appLocalizations.sign_up_page_password_hint,
              prefixIcon: const Icon(Icons.vpn_key),
              autofillHints: const <String>[AutofillHints.password],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.sign_up_page_password_error_empty;
                }
                if (!UserManagementHelper.isPasswordValid(value)) {
                  return appLocalizations.sign_up_page_password_error_invalid;
                }
                return null;
              },
            ),
            const SizedBox(height: space),
            SmoothTextFormField(
              type: TextFieldTypes.PASSWORD,
              controller: _password2Controller,
              textInputAction: TextInputAction.next,
              hintText: appLocalizations.sign_up_page_confirm_password_hint,
              prefixIcon: const Icon(Icons.vpn_key),
              autofillHints: const <String>[
                AutofillHints.password,
              ],
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations
                      .sign_up_page_confirm_password_error_empty;
                }
                if (value != _password1Controller.text) {
                  return appLocalizations
                      .sign_up_page_confirm_password_error_invalid;
                }
                return null;
              },
            ),
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
                    // TODO(monsieurtanuki): refactor / translate
                    TextSpan(
                      text: 'I agree to the Open Food Facts ',
                      style: TextStyle(color: theme.colorScheme.onBackground),
                    ),
                    TextSpan(
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      text: 'terms of use and contribution',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final String url =
                              appLocalizations.sign_up_page_agree_url;
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
                      appLocalizations.sign_up_page_agree_error_invalid,
                      style: TextStyle(color: theme.errorColor),
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
              title: Text(appLocalizations.sign_up_page_producer_checkbox),
            ),
            if (_foodProducer) ...<Widget>[
              const SizedBox(height: space),
              SmoothTextFormField(
                type: TextFieldTypes.PLAIN_TEXT,
                controller: _brandController,
                textInputAction: TextInputAction.next,
                hintText: appLocalizations.sign_up_page_producer_hint,
                prefixIcon: const Icon(Icons.person),
                autofillHints: const <String>[AutofillHints.name],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.sign_up_page_producer_error_empty;
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
              title: Text(appLocalizations.sign_up_page_subscribe_checkbox),
            ),
            const SizedBox(height: space),
            ElevatedButton(
              onPressed: () async => _signUp(),
              child: Text(
                appLocalizations.sign_up_page_action_button,
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
            const SizedBox(height: space),
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
    final User user = User(
      userId: _userController.text,
      password: _password1Controller.text,
    );
    final Status? status = await LoadingDialog.run<Status>(
      context: context,
      future: OpenFoodAPIClient.register(
        user: user,
        name: _displayNameController.text,
        email: _emailController.text,
        newsletter: _subscribe,
        orgName: _foodProducer ? _brandController.text : null,
      ),
      title: AppLocalizations.of(context)!.sign_up_page_action_doing_it,
    );
    if (status == null) {
      // probably the end user stopped the dialog
      return;
    }
    if (status.error != null) {
      await LoadingDialog.error(context: context, title: status.error);
      return;
    }
    await context.read<UserManagementProvider>().putUser(user);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(AppLocalizations.of(context)!.sign_up_page_action_ok),
        actions: <SmoothActionButton>[
          SmoothActionButton(
              text: AppLocalizations.of(context)!.okay,
              onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
    Navigator.of(context).pop<bool>(true);
  }
}
