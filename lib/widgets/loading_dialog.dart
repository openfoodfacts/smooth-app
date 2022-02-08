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
  }) async =>
      LoadingDialog<T>._()._run(
        context: context,
        future: future,
        title: title ?? 'Downloading data', // TODO(monsieurtanuki): localize
      );

  /// Shows an loading error dialog.
  ///
  /// Typical use-case: when the [run] call failed.
  static Future<void> error({
    required final BuildContext context,
    final String? title,
  }) async =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          close: false,
          body: ListTile(
            leading: const Icon(Icons.error),
            title: Text(title ??
                'Could not download data'), // TODO(monsieurtanuki): localize
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              text: AppLocalizations.of(context)!.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  /// Displays "downloading" dialog while actually downloading
  Future<T?> _run({
    required final BuildContext context,
    required final Future<T> future,
    required final String title,
  }) async =>
      showDialog<T>(
        context: context,
        builder: (BuildContext context) {
          future.then<void>(
            (final T value) => _popDialog(context, value),
          );
          // TODO(monsieurtanuki): is that safe? If the future finishes before the "return" call?
          return _getDialog(context, title);
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
  ) =>
      SmoothAlertDialog(
        close: false,
        body: ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(title),
        ),
        actions: <SmoothActionButton>[
          SmoothActionButton(
            text: AppLocalizations.of(context)!.stop,
            onPressed: () => _popDialog(context, null),
          ),
        ],
      );
}
