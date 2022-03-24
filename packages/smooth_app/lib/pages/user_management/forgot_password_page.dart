import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _devModeCounter = 0;

  static Color _textFieldBackgroundColor = const Color.fromARGB(
    255,
    240,
    240,
    240,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();

  bool _send = false;
  bool _runningQuery = false;
  String _message = '';

  Future<void> _resetPassword() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _runningQuery = true);

    Status? status;
    try {
      status = await OpenFoodAPIClient.resetPassword(_userIdController.text);
    } catch (e) {
      status = null;
    }
    if (status == null) {
      _message = appLocalizations.error;
    } else if (status.status == 200) {
      _send = true;
      _message = appLocalizations.reset_password_done;
    } else if (status.status == 400) {
      _message = appLocalizations.incorrect_credentials;
    } else {
      _message = appLocalizations.error;
    }
    setState(() => _runningQuery = false);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final Size size = MediaQuery.of(context).size;
    final bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    // Needs to be changed
    if (isDarkMode) {
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
                  if (_message != '') ...<Widget>[
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
                      controller: _userIdController,
                      hintText: appLocalizations.username_or_email,
                      hintTextFontSize: 15.0,
                      textColor: Colors.grey,
                      backgroundColor: _textFieldBackgroundColor,
                      enabled: !_runningQuery,
                      prefixIcon: const Icon(Icons.email),
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          _devModeCounter++;
                          if (_devModeCounter >= 10) {
                            if (userPreferences.devMode == 0) {
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Ready for the dev mode?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(appLocalizations.yes),
                                      onPressed: () async {
                                        await userPreferences.setDevMode(1);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: Text(appLocalizations.no),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ),
                              );
                            }
                          }
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
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      _send
                          ? appLocalizations.close
                          : appLocalizations.send_reset_password_mail,
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
