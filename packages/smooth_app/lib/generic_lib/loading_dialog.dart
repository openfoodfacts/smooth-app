import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

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
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return LoadingDialog<T>._()._run(
      context: context,
      future: future,
      title: title ?? appLocalizations!.loading_dialog_default_title,
      dismissible: dismissible ?? true,
    );
  }

  /// Shows an loading error dialog.
  ///
  /// Typical use-case: when the [run] call failed.
  static Future<void> error({
    required final BuildContext context,
    final String? title,
  }) async =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          final AppLocalizations? appLocalizations =
              AppLocalizations.of(context);
          return SmoothAlertDialog(
            body: ListTile(
              leading: const Icon(Icons.error),
              title: Text(
                title ?? appLocalizations!.loading_dialog_default_error_message,
              ),
            ),
            actions: <SmoothActionButton>[
              SmoothActionButton(
                text: appLocalizations!.close,
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
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
    Navigator.of(context, rootNavigator: true).pop(value);
  }

  /// Displayed dialog during future.
  Widget _getDialog(
    final BuildContext context,
    final String title,
    final Future<T> future,
  ) {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);
    return SmoothAlertDialog(
      body: FutureBuilder<T>(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Now it's either hasError or successful.
            // We cannot check hasData because data can be null or void.
            if (snapshot.hasError) {
              return ListTile(
                title: Text(appLocalizations!.error_occurred),
              );
            }
            _popDialog(context, snapshot.data);
            // whatever, anyway we've just pop'ed
            return Container();
          }
          return ListTile(
            leading: const CircularProgressIndicator(),
            title: Text(title),
          );
        },
      ),
      actions: <SmoothActionButton>[
        SmoothActionButton(
          text: appLocalizations!.stop,
          onPressed: () => _popDialog(context, null),
        ),
      ],
    );
  }
}
