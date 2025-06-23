import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Dialog with a stop button, while a future is running.
///
/// Typical use-case: wait during download.
class LoadingDialog<T> {
  LoadingDialog._();

  /// Is the dialog already pop'ed?
  bool _popEd = false;

  /// Runs a future while displaying a stoppable dialog.
  static Future<T?> run<T>({
    required final BuildContext context,
    required final Future<T> future,
    final String? title,
    final bool? dismissible,
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return LoadingDialog<T>._()._run(
      context: context,
      future: future,
      title: title ?? appLocalizations.loading_dialog_default_title,
      dismissible: dismissible ?? true,
    );
  }

  /// Shows an loading error dialog.
  ///
  /// Typical use-case: when the [run] call failed.
  static Future<void> error({
    required final BuildContext context,
    final String? title,
    final bool shouldOpenNewIssue = false,
  }) async =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            body: Column(
              children: <Widget>[
                SvgPicture.asset(
                  'assets/misc/error.svg',
                  width: MINIMUM_TOUCH_SIZE * 2,
                  package: AppHelper.APP_PACKAGE,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
                  child: Text(
                    shouldOpenNewIssue
                        ? appLocalizations.server_error_open_new_issue
                        : title ??
                            appLocalizations
                                .loading_dialog_default_error_message,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (shouldOpenNewIssue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MEDIUM_SPACE),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue,
                            ),
                        text: Status.openNewIssueUrl,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => LaunchUrlHelper.launchURL(
                                Status.openNewIssueUrl,
                              ),
                      ),
                    ),
                  ),
              ],
            ),
            positiveAction: SmoothActionButton(
              text: appLocalizations.close,
              onPressed: () => Navigator.maybePop(context),
            ),
          );
        },
      );

  /// Displays "downloading" dialog while actually downloading
  Future<T?> _run({
    required final BuildContext context,
    required final Future<T> future,
    required final String title,
    final bool? dismissible,
  }) async =>
      showDialog<T>(
        barrierDismissible: dismissible ?? true,
        context: context,
        builder: (BuildContext context) {
          return _getDialog(context, title, future);
        },
      );

  /// Closes the dialog if relevant, pop'ing the [value]
  void _popDialog(final BuildContext context, final T? value) {
    if (_popEd) {
      return;
    }
    _popEd = true;
    // Here we use the root navigator so that we can pop dialog while using multiple navigators.

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context, rootNavigator: true).pop(value);
    });
  }

  /// Displayed dialog during future.
  Widget _getDialog(
    final BuildContext context,
    final String title,
    final Future<T> future,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothAlertDialog(
      body: FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          if (snapshot.hasError || snapshot.hasData) {
            _popDialog(context, snapshot.data);
          }

          return ListTile(
            leading: const CircularProgressIndicator.adaptive(),
            title: Text(title),
          );
        },
      ),
      positiveAction: SmoothActionButton(
        text: appLocalizations.stop,
        onPressed: () => _popDialog(context, null),
      ),
    );
  }
}
