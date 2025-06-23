import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Abstraction of a display for the preference pages.
abstract class AbstractUserPreferences {
  AbstractUserPreferences({
    required this.context,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  });

  final BuildContext context;
  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  /// Returns the type of the corresponding page if relevant, or else null.
  @protected
  PreferencePageType getPreferencePageType();

  /// Title of the preference page.
  String getPageTitleString() => getTitleString();

  /// Title of the header, always visible.
  String getTitleString();

  /// Title of the header, always visible.
  @protected
  Widget getTitle() => Text(
        getTitleString(),
        style: themeData.textTheme.displayMedium,
      );

  /// Subtitle of the header, always visible.
  @protected
  String? getSubtitleString() => null;

  /// Subtitle of the header, always visible.
  @protected
  Widget? getSubtitle() =>
      getSubtitleString() == null ? null : Text(getSubtitleString()!);

  List<String> getLabels() => <String>[
        getPageTitleString(),
        getTitleString(),
        if (getSubtitleString() != null) getSubtitleString()!,
      ];

  Widget getOnlyHeader() => InkWell(
        onTap: () async => runHeaderAction(),
        child: getHeaderHelper(false),
      );

  @protected
  Icon? getForwardIcon() => UserPreferencesListTile.getTintedIcon(
        ConstantIcons.forwardIcon,
        context,
      );

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
        trailing: collapsed != null ? getForwardIcon() : null,
        leading: UserPreferencesListTile.getTintedIcon(
            getLeadingIconData(), context),
      );

  @protected
  IconData getLeadingIconData();

  /// Body of the content.
  List<UserPreferencesItem> getChildren();

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

  /// Svg asset for the header.
  ///
  /// E.g.: `'assets/preferences/main.svg'`
  String? getHeaderAsset() => null;

  /// Color for the header.
  Color? getHeaderColor() => null;

  /// Additional subtitle, to be displayed outside a [UserPreferencesListTile].
  Widget? getAdditionalSubtitle() => null;
}
