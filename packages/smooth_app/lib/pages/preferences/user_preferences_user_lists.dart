import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/all_user_product_list_page.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';

class UserPreferencesUserLists extends AbstractUserPreferences {
  UserPreferencesUserLists({
    required final Function(Function()) setState,
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

  @override
  List<Widget> getBody() {
    return <Widget>[];
  }

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.LISTS;

  @override
  Widget? getSubtitle() => null;

  @override
  String getTitleString() => appLocalizations.user_list_all_title;

  @override
  IconData getLeadingIconData() => Icons.playlist_add_check;

  @override
  Future<void> runHeaderAction() => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const AllUserProductList(),
        ),
      );
}
