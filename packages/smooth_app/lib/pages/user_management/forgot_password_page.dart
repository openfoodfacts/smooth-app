import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage();

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TraceableClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userIdController = TextEditingController();

  bool _send = false;
  bool _runningQuery = false;
  String _message = '';

  Future<void> _resetPassword() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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
  String get traceTitle => 'forgot_password_page';

  @override
  String get traceName => 'Opened forgot_password_page';

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;

    return SmoothScaffold(
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
                  if (_runningQuery)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: () {
                        if (_send == false) {
                          _resetPassword();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(size.width * 0.5, theme.buttonTheme.height + 10),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: CIRCULAR_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      child: Text(
                        _send
                            ? appLocalizations.close
                            : appLocalizations.send_reset_password_mail,
                        style: theme.textTheme.bodyText2?.copyWith(
                          fontSize: 18.0,
                          color: theme.colorScheme.onPrimary,
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
