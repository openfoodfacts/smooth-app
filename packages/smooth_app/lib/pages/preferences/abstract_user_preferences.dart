import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Abstraction of a display for the preference pages.
abstract class AbstractUserPreferences {
  AbstractUserPreferences({
    required this.setState,
    required this.context,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  });

  /// Function that refreshes the page.
  final Function(Function()) setState;

  final BuildContext context;
  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  /// Returns the type of the corresponding page if relevant, or else null.
  PreferencePageType? getPreferencePageType();

  /// Title of the header, always visible.
  String getTitleString();

  /// Title of the header, always visible.
  ///
  /// With [Flexible] for overflow management.
  @protected
  Widget getTitle() => Flexible(
        child: Text(
          getTitleString(),
          style: themeData.textTheme.headline2,
        ),
      );

  /// Subtitle of the header, always visible.
  @protected
  Widget? getSubtitle();

  Widget getOnlyHeader() => InkWell(
        onTap: () async => runHeaderAction(),
        child: getHeaderHelper(false),
      );

  Icon getForwardIcon() => Icon(ConstantIcons.instance.getForwardIcon());

  /// Returns the tappable header.
  @protected
  Widget getHeader() => InkWell(
        onTap: () async => runHeaderAction(),
        child: getHeaderHelper(true),
      );

  /// Returns the header (helper) (no padding, no tapping).
  @protected
  Widget getHeaderHelper(final bool? collapsed) => UserPreferencesListTile(
        title: getTitle(),
        subtitle: getSubtitle(),
        isCompactTitle: false,
        icon: collapsed != null ? getForwardIcon() : null,
      );

  /// Body of the content.
  @protected
  List<Widget> getBody();

  /// Returns possibly the header and the body.
  List<Widget> getContent({
    final bool withHeader = true,
    final bool withBody = true,
  }) {
    final List<Widget> result = <Widget>[];
    if (withHeader) {
      result.add(getHeader());
    }
    if (withBody) {
      result.addAll(getBody());
    }
    return result;
  }

  /// Returns the action when we tap on the header.
  @protected
  Future<void> runHeaderAction() async => Navigator.push<Widget>(
        context,
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => UserPreferencesPage(
            type: getPreferencePageType(),
          ),
        ),
      );
}
