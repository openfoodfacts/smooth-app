import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';

class DefaultPreferencesRoot extends PreferencesRoot {
  const DefaultPreferencesRoot({
    super.key,
    super.title,
    super.customAppBar,
    required this.cards,
  });

  final List<PreferenceCard> cards;

  @override
  List<PreferenceCard> getCards(BuildContext context) => cards;
}
