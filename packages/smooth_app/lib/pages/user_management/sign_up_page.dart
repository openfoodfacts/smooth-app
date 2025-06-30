import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sign Up Page. Pop's true if the sign up was successful.
class SignUpPage extends StatefulWidget {
  const SignUpPage();

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TraceableClientMixin {
  static const double space = 10;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _password1FocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

  bool _foodProducer = false;
  bool _agree = false;
  bool _subscribe = false;
  bool _disagreed = false;

  @override
  String get actionName => 'Opened sign_up_page';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.sizeOf(context);

    Color getCheckBoxColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return theme.colorScheme.onSurface;
      }
      // If light mode return the color of primary
      // else return the color of primaryDark
      if (theme.colorScheme.brightness == Brightness.light) {
        return theme.colorScheme.primary;
      } else {
        return theme.colorScheme.secondary;
      }
    }

    return SmoothScaffold(
      fixKeyboard: true,
      appBar: SmoothAppBar(
        title: Text(appLocalizations.sign_up_page_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AutofillGroup(
        child: Form(
          onChanged: () => setState(() {}),
          key: _formKey,
          child: Scrollbar(
            child: ListView(
              padding: EdgeInsetsDirectional.only(
                start: size.width * 0.05,
                end: size.width * 0.05,
                bottom: MediaQuery.viewInsetsOf(context).bottom * 0.25,
              ),
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
                      return appLocalizations
                          .sign_up_page_display_name_error_empty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: space),
                SmoothTextFormField(
                  textInputType: TextInputType.emailAddress,
                  type: TextFieldTypes.PLAIN_TEXT,
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  hintText: appLocalizations.sign_up_page_email_hint,
                  prefixIcon: const Icon(Icons.person),
                  autofillHints: const <String>[AutofillHints.email],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.sign_up_page_email_error_empty;
                    } else if (!UserManagementHelper.isEmailValid(
                      _emailController.trimmedText,
                    )) {
                      return appLocalizations.sign_up_page_email_error_invalid;
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: space),
                SmoothTextFormField(
                  type: TextFieldTypes.PLAIN_TEXT,
                  controller: _userController,
                  focusNode: _userFocusNode,
                  textInputAction: TextInputAction.next,
                  hintText: appLocalizations.sign_up_page_username_hint,
                  prefixIcon: const Icon(Icons.person),
                  autofillHints: const <String>[AutofillHints.newUsername],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.sign_up_page_username_error_empty;
                    }
                    if (!UserManagementHelper.isUsernameValid(
                      _userController.trimmedText,
                    )) {
                      return appLocalizations.sign_up_page_username_description;
                    }
                    if (!UserManagementHelper.isUsernameLengthValid(
                      _userController.trimmedText,
                    )) {
                      const int maxLength =
                          OpenFoodAPIClient.USER_NAME_MAX_LENGTH;
                      return appLocalizations
                          .sign_up_page_username_length_invalid(maxLength);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: space),
                SmoothTextFormField(
                  type: TextFieldTypes.PASSWORD,
                  controller: _password1Controller,
                  focusNode: _password1FocusNode,
                  textInputAction: TextInputAction.next,
                  hintText: appLocalizations.sign_up_page_password_hint,
                  maxLines: 1,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_password2FocusNode),
                  prefixIcon: const Icon(Icons.vpn_key),
                  autofillHints: const <String>[AutofillHints.newPassword],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.sign_up_page_password_error_empty;
                    } else if (!UserManagementHelper.isPasswordValid(value)) {
                      return appLocalizations
                          .sign_up_page_password_error_invalid;
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: space),
                SmoothTextFormField(
                  type: TextFieldTypes.PASSWORD,
                  controller: _password2Controller,
                  focusNode: _password2FocusNode,
                  textInputAction: TextInputAction.send,
                  hintText: appLocalizations.sign_up_page_confirm_password_hint,
                  maxLines: 1,
                  prefixIcon: const Icon(Icons.vpn_key),
                  autofillHints: const <String>[AutofillHints.newPassword],
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations
                          .sign_up_page_confirm_password_error_empty;
                    } else if (_password2Controller.text !=
                        _password1Controller.text) {
                      return appLocalizations
                          .sign_up_page_confirm_password_error_invalid;
                    } else {
                      return null;
                    }
                  },
                  onFieldSubmitted: (String password) {
                    if (password.isNotEmpty) {
                      _signUp();
                    } else {
                      _formKey.currentState!.validate();
                    }
                  },
                ),
                const SizedBox(height: space),
                _TermsOfUseCheckbox(
                  agree: _agree,
                  disagree: _disagreed,
                  checkboxColorResolver: getCheckBoxColor,
                  onCheckboxChanged: (bool checked) {
                    setState(() {
                      _agree = checked;
                    });
                  },
                ),
                const SizedBox(height: space),
                ListTile(
                  onTap: () {
                    setState(() => _foodProducer = !_foodProducer);
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: IgnorePointer(
                    ignoring: true,
                    child: Checkbox(
                      value: _foodProducer,
                      fillColor: WidgetStateProperty.resolveWith(
                        getCheckBoxColor,
                      ),
                      onChanged: (_) {},
                    ),
                  ),
                  title: Text(
                    appLocalizations.sign_up_page_producer_checkbox,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_foodProducer) ...<Widget>[
                  const SizedBox(height: space),
                  SmoothTextFormField(
                    type: TextFieldTypes.PLAIN_TEXT,
                    controller: _brandController,
                    textInputAction: TextInputAction.next,
                    hintText: appLocalizations.sign_up_page_producer_hint,
                    prefixIcon: const Icon(Icons.person),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations
                            .sign_up_page_producer_error_empty;
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: space),
                ListTile(
                  onTap: () {
                    setState(() => _subscribe = !_subscribe);
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: IgnorePointer(
                    ignoring: true,
                    child: Checkbox(
                      value: _subscribe,
                      fillColor: WidgetStateProperty.resolveWith(
                        getCheckBoxColor,
                      ),
                      onChanged: (_) {},
                    ),
                  ),
                  title: Text(
                    appLocalizations.sign_up_page_subscribe_checkbox,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: space),
                ElevatedButton(
                  onPressed: () async => _signUp(),
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
                    appLocalizations.sign_up_page_action_button,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 18.0,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: space),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    ///add and make complete onboarding false at signup.
    final AppLocalizations appLocalisations = AppLocalizations.of(context);
    _disagreed = !_agree;
    setState(() {});
    if (!_formKey.currentState!.validate() || _disagreed) {
      return;
    }
    final User user = User(
      userId: _userController.trimmedText,
      password: _password1Controller.text,
    );
    final bool prodUrl =
        context.read<UserPreferences>().getFlag(
          UserPreferencesDevMode.userPreferencesFlagProd,
        ) ??
        true;

    final SignUpStatus? status = await LoadingDialog.run<SignUpStatus>(
      context: context,
      future: OpenFoodAPIClient.register(
        user: user,
        name: _displayNameController.trimmedText,
        email: _emailController.trimmedText,
        newsletter: _subscribe,
        orgName: _foodProducer ? _brandController.trimmedText : null,
        country: ProductQuery.getCountry(),
        language: ProductQuery.getLanguage(),
        uriHelper: ProductQuery.getUriProductHelper(
          productType: prodUrl ? ProductType.food : null,
        ),
      ),
      title: appLocalisations.sign_up_page_action_doing_it,
    );
    if (status == null) {
      // probably the end user stopped the dialog
      return;
    }
    if (status.error != null) {
      String? errorMessage;

      // Highlight the field with the error
      if (status.statusErrors?.isNotEmpty == true) {
        if (status.statusErrors!.contains(
          SignUpStatusError.EMAIL_ALREADY_USED,
        )) {
          _emailFocusNode.requestFocus();
          errorMessage =
              '${_emailController.trimmedText} ${appLocalisations.sign_up_page_email_already_exists}';
        } else if (status.statusErrors!.contains(
              SignUpStatusError.INCORRECT_EMAIL,
            ) ||
            status.error!.contains('Invalid e-mail address')) {
          _emailFocusNode.requestFocus();
          errorMessage = appLocalisations.sign_up_page_provide_valid_email;
        } else if (status.statusErrors!.contains(
          SignUpStatusError.INVALID_PASSWORD,
        )) {
          _password1FocusNode.requestFocus();
          errorMessage = appLocalisations.sign_up_page_password_error_invalid;
        } else if (status.statusErrors!.contains(
          SignUpStatusError.INVALID_USERNAME,
        )) {
          _userFocusNode.requestFocus();
          errorMessage =
              '${appLocalisations.sign_up_page_username_description}  ${appLocalisations.sign_up_page_username_length_invalid}';
        } else if (status.statusErrors!.contains(
          SignUpStatusError.USERNAME_ALREADY_USED,
        )) {
          _userFocusNode.requestFocus();
          errorMessage = appLocalisations.sign_up_page_user_name_already_used;
        } else if (status.statusErrors!.contains(
          SignUpStatusError.SERVER_BUSY,
        )) {
          errorMessage = appLocalisations.sign_up_page_server_busy;
        } else {
          // Let's try to find the error in
          final Iterable<RegExpMatch> allMatches = RegExp(
            '(<li class="error">)(.*?)(</li>)',
          ).allMatches(status.error!);
          if (allMatches.isNotEmpty) {
            final StringBuffer buffer = StringBuffer();
            for (final RegExpMatch match in allMatches) {
              if (buffer.isNotEmpty) {
                buffer.write('\n\n');
              }

              buffer.write(match.group(2));
            }
            errorMessage = buffer.toString();
          } else {
            errorMessage = status.error;
          }
        }
      }

      if (mounted) {
        await LoadingDialog.error(
          context: context,
          title: errorMessage,
          shouldOpenNewIssue: status.shouldOpenNewIssue(),
        );
      }
      return;
    }
    AnalyticsHelper.trackEvent(AnalyticsEvent.registerAction);
    if (_foodProducer) {
      AnalyticsHelper.trackEvent(AnalyticsEvent.producerSignup);
    }
    if (!mounted) {
      return;
    }
    await context.read<UserManagementProvider>().putUser(user);
    if (!mounted) {
      return;
    }
    final UserPreferences userPreferences =
        await UserPreferences.getUserPreferences();
    userPreferences.resetOnboarding();
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Text(appLocalisations.sign_up_page_action_ok),
        positiveAction: SmoothActionButton(
          text: AppLocalizations.of(context).okay,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop<bool>(true);
  }
}

class _TermsOfUseCheckbox extends StatelessWidget {
  const _TermsOfUseCheckbox({
    required this.agree,
    required this.disagree,
    required this.onCheckboxChanged,
    required this.checkboxColorResolver,
  });

  final bool agree;
  final bool disagree;
  final WidgetPropertyResolver<Color?> checkboxColorResolver;
  final ValueChanged<bool> onCheckboxChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return InkWell(
      excludeFromSemantics: true,
      onTap: () {
        onCheckboxChanged(!agree);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                IgnorePointer(
                  ignoring: true,
                  child: Checkbox(
                    value: agree,
                    fillColor: WidgetStateProperty.resolveWith(
                      checkboxColorResolver,
                    ),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          // additional space needed because of the next text span
                          text: '${appLocalizations.sign_up_page_agree_text} ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.blue,
                          ),
                          text: appLocalizations.sign_up_page_terms_text,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _onTermsClicked(appLocalizations),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _onTermsClicked(appLocalizations),
                  customBorder: const CircleBorder(),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Icon(
                      semanticLabel: appLocalizations.termsOfUse,
                      Icons.info,
                      color: checkboxColorResolver(<WidgetState>{
                        WidgetState.selected,
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !disagree,
            child: Text(
              appLocalizations.sign_up_page_agree_error_invalid,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTermsClicked(AppLocalizations appLocalizations) async {
    final String url = appLocalizations.sign_up_page_agree_url;

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
    } catch (_) {}
  }
}
