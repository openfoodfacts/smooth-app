import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

/// Display of "Donation" for the preferences page.
class UserPreferencesDonation extends AbstractUserPreferences {
  UserPreferencesDonation({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.DONATION;

  @override
  String getTitleString() => appLocalizations.contribute_donate_title;

  @override
  String getSubtitleString() => appLocalizations.contribute_donate_header;

  @override
  IconData getLeadingIconData() => Icons.volunteer_activism;

  @override
  Icon? getForwardIcon() =>
      UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context);

  @override
  Future<void> runHeaderAction() async =>
      LaunchUrlHelper.launchURL(appLocalizations.donate_url);

  @override
  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[];
}
