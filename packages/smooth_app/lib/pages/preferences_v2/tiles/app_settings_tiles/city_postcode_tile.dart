import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class CityPostcodeTile extends PreferenceTile {
  const CityPostcodeTile({required super.title});

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final String? cityOrPostcode = userPreferences.userCityOrPostcode;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return PreferenceTile(
      leading: const Icon(Icons.location_on_outlined),
      title: title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SMALL_SPACE,
        children: <Widget>[
          if (cityOrPostcode != null) Text(cityOrPostcode),
          Text(appLocalizations.preferences_city_or_postcode_privacy),
        ],
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => _editCityOrPostcode(context, userPreferences),
    );
  }

  Future<void> _editCityOrPostcode(
    BuildContext context,
    UserPreferences userPreferences,
  ) async {
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _CityPostcodeDialog(
        title: title,
        initialValue: userPreferences.userCityOrPostcode,
      ),
    );

    if (value != null && context.mounted) {
      await userPreferences.setUserCityOrPostcode(value);
    }
  }
}

class _CityPostcodeDialog extends StatefulWidget {
  const _CityPostcodeDialog({required this.title, required this.initialValue});

  final String title;
  final String? initialValue;

  @override
  State<_CityPostcodeDialog> createState() => _CityPostcodeDialogState();
}

class _CityPostcodeDialogState extends State<_CityPostcodeDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothAlertDialog(
      title: widget.title,
      close: true,
      body: Column(
        spacing: SMALL_SPACE,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(appLocalizations.preferences_city_or_postcode_privacy),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: appLocalizations.preferences_city_or_postcode_title,
              suffixIcon: IconButton(
                onPressed: _controller.clear,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: const Icon(Icons.clear),
              ),
            ),
            onSubmitted: (String value) => Navigator.of(context).pop(value),
          ),
        ],
      ),
      positiveAction: SmoothActionButton(
        text: appLocalizations.save,
        onPressed: () => Navigator.of(context).pop(_controller.text),
      ),
      negativeAction: SmoothActionButton(
        text: appLocalizations.cancel,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
