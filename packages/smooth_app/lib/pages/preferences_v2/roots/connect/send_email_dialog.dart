import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

class SendEmailDialog extends StatelessWidget {
  const SendEmailDialog({required this.recipient, super.key});

  final String recipient;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SmoothAlertDialog(
        title: appLocalizations.no_email_client_available_dialog_title,
        body: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(appLocalizations.please_send_us_an_email_to),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(recipient),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: appLocalizations.copy_email_to_clip_board,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: recipient));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appLocalizations.email_copied_to_clip_board,
                            textAlign: TextAlign.center,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        positiveAction: SmoothActionButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          text: appLocalizations.okay,
        ),
      ),
    );
  }
}
