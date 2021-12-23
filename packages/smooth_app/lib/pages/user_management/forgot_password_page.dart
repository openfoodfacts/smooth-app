import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:smooth_ui_library/widgets/smooth_text_form_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color customGrey = Colors.grey;
  static Color textFieldBackgroundColor = const Color.fromARGB(
    255,
    240,
    240,
    240,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController userIdController = TextEditingController();

  bool _send = false;
  bool _runningQuery = false;
  late String _message;

  Future<void> _resetPassword() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _runningQuery = true);

    final Status status;
    try {
      status = await OpenFoodAPIClient.resetPassword(userIdController.text);
    } catch (e) {
      throw Exception(e);
    }

    if (status.status == 200) {
      _send = true;
      _message = appLocalizations.reset_password_done;
    } else if (status.status == 400) {
      _message = appLocalizations.incorrect_credentials;
    } else {
      _message = appLocalizations.error;
    }
    setState(() => _runningQuery = false);
  }

  // Checks and returns right String if opening mail app is possible
  String _getSubmitButtonText() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    if (!_send) {
      return appLocalizations.send_reset_password_mail;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return appLocalizations.open_mail_app;
    } else {
      return appLocalizations.okay;
    }
  }

  // Opens mail app if possible otherwise pops page
  Future<void> _openMailOrPop() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
      final OpenMailAppResult result = await OpenMailApp.openMailApp();

      // If no mail apps found, show error
      if (!result.didOpen && !result.canOpen) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.no_email_app),
            action: SnackBarAction(
              label: appLocalizations.okay,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );

        // iOS: if multiple mail apps found, show dialog to select.
        // There is no native intent/default app system in iOS so
        // you have to do it yourself.
      } else if (!result.didOpen && result.canOpen) {
        showDialog<Widget>(
          context: context,
          builder: (_) {
            return MailAppPickerDialog(
              mailApps: result.options,
            );
          },
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
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
      textFieldBackgroundColor = Colors.white10;
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
                    appLocalizations.reset_password,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline1?.copyWith(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(flex: 1),
                  if (!_send)
                    Text(
                      appLocalizations.reset_password_explanation_text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyText2,
                    ),
                  const Spacer(flex: 2),
                  if (_message != 'Error') ...<Widget>[
                    SmoothCard(
                      padding: const EdgeInsets.all(10.0),
                      color: _send ? Colors.green : Colors.red,
                      child: Text(_message),
                    ),
                    const Spacer(
                      flex: 1,
                    )
                  ],
                  if (!_send)
                    SmoothTextFormField(
                      type: TextFieldTypes.PLAIN_TEXT,
                      controller: userIdController,
                      hintText: appLocalizations.username_or_email,
                      hintTextFontSize: 15.0,
                      textColor: customGrey,
                      backgroundColor: textFieldBackgroundColor,
                      enabled: !_runningQuery,
                      prefixIcon: const Icon(Icons.email),
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.enter_some_text;
                        }
                        return null;
                      },
                    ),
                  const Spacer(flex: 4),
                  ElevatedButton(
                    onPressed: () {
                      if (_send == false) {
                        _resetPassword();
                      } else {
                        _openMailOrPop();
                      }
                    },
                    child: Text(
                      _getSubmitButtonText(),
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
