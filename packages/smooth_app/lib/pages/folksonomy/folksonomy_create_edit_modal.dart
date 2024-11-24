import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyCreateEditModal extends StatefulWidget {
  const FolksonomyCreateEditModal({
    required this.provider,
    this.oldKey,
    this.oldValue,
  });

  final FolksonomyProvider provider;
  final String? oldKey;
  final String? oldValue;

  @override
  FolksonomyCreateEditModalState createState() =>
      FolksonomyCreateEditModalState();
}

class FolksonomyCreateEditModalState extends State<FolksonomyCreateEditModal> {
  static const String regexString = r'^[a-z0-9_-]+(:[a-z0-9_-]+)*$';
  late TextEditingController keyController;
  late TextEditingController valueController;
  bool isValidKey = true;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController(text: widget.oldKey);
    valueController = TextEditingController(text: widget.oldValue);
    isValidKey = RegExp(regexString).hasMatch(keyController.text);

    keyController.addListener(() {
      setState(() {
        isValidKey = RegExp(regexString).hasMatch(keyController.text);
      });
    });
  }

  @override
  void dispose() {
    keyController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.oldKey == null
          ? appLocalizations.add_tag
          : appLocalizations.edit_tag),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: keyController,
            decoration: InputDecoration(
              labelText: appLocalizations.tag_key,
              errorText:
                  isValidKey ? null : appLocalizations.invalid_key_format,
            ),
            enabled: widget.oldKey == null,
          ),
          TextField(
            controller: valueController,
            decoration: InputDecoration(labelText: appLocalizations.tag_value),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: isValidKey
              ? () async {
                  if (widget.oldKey == null) {
                    await widget.provider
                        .addTag(keyController.text, valueController.text);
                  } else {
                    await widget.provider
                        .editTag(widget.oldKey!, valueController.text);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}
