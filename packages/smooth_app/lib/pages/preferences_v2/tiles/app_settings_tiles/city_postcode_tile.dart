import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/value_edition_preference_tile.dart';

class CityPostcodeTile extends PreferenceTile {
  const CityPostcodeTile({required super.title});

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final String? cityOrPostcode = userPreferences.userCityOrPostcode;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Widget privacyText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SMALL_SPACE,
      children: <Widget>[
        Text(appLocalizations.preferences_city_or_postcode_privacy),
      ],
    );

    return ValueEditionPreferenceTile(
      title: title,
      icon: const Icon(Icons.location_on_outlined),
      dialogAction: appLocalizations.save,
      value: cityOrPostcode,
      hint: appLocalizations.preferences_city_or_postcode_title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SMALL_SPACE,
        children: <Widget>[
          if (cityOrPostcode != null) Text(cityOrPostcode),
          privacyText,
        ],
      ),
      dialogDescription: privacyText,
      onNewValue: (String value) =>
          userPreferences.setUserCityOrPostcode(value),
    );
  }
}
