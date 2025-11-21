import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with TraceableClientMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _userIdController;

  bool _send = false;
  bool _runningQuery = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: widget.initialEmail);
  }

  Future<void> _resetPassword() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _runningQuery = true);

    try {
      final Status status = await OpenFoodAPIClient.resetPassword(
        _userIdController.text,
        country: ProductQuery.getCountry(),
        language: ProductQuery.getLanguage(),
        uriHelper: ProductQuery.getUriProductHelper(
          productType: ProductType.food,
        ),
      );
      if (status.status == 200) {
        _send = true;
        _message = appLocalizations.reset_password_done;
      } else if (status.status == 400) {
        _message = appLocalizations.password_lost_incorrect_credentials;
      } else if (status.status as int >= 500) {
        _message = appLocalizations.password_lost_server_unavailable;
      } else {
        _message = '${appLocalizations.error} (${status.status})';
      }
    } catch (exception) {
      _message = '${appLocalizations.error} ($exception)';
    }

    setState(() => _runningQuery = false);
  }

  @override
  String get actionName => 'Opened forgot_password_page';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.sizeOf(context);

    return SmoothScaffold(
      appBar: SmoothAppBar(title: Text(appLocalizations.reset_password)),
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
                  const Spacer(flex: 1),
                  if (!_send)
                    Text(
                      appLocalizations.reset_password_explanation_text,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  const Spacer(flex: 2),
                  if (_message != '') ...<Widget>[
                    SmoothCard(
                      padding: const EdgeInsetsDirectional.all(BALANCED_SPACE),
                      color: _send ? Colors.green : Colors.red,
                      child: Text(_message),
                    ),
                    const Spacer(flex: 1),
                  ],
                  if (!_send)
                    SmoothTextFormField(
                      type: TextFieldTypes.PLAIN_TEXT,
                      controller: _userIdController,
                      hintText: appLocalizations.username_or_email,
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
                    const CircularProgressIndicator.adaptive()
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
                        minimumSize: WidgetStateProperty.all<Size>(
                          Size(size.width * 0.5, theme.buttonTheme.height + 10),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: CIRCULAR_BORDER_RADIUS,
                          ),
                        ),
                      ),
                      child: Text(
                        _send
                            ? appLocalizations.close
                            : appLocalizations.send_reset_password_mail,
                        style: theme.textTheme.bodyMedium?.copyWith(
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

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }
}
