import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Abstraction of a collapsed/expanded display for the preferences page.
abstract class AbstractUserPreferences {
  AbstractUserPreferences(this.setState);

  /// Function that refreshes the page.
  final Function(Function()) setState;

  /// Flag Key to store the collapsed/expanded status
  @protected
  String getPreferenceFlagKey();

  /// At init time, should we be collapsed?
  @protected
  bool isCollapsedByDefault();

  /// Title of the header, always visible.
  @protected
  String getTitle();

  /// Subtitle of the header, always visible.
  @protected
  String getSubtitle();

  /// Returns the header.
  Widget _getHeader(
    final UserPreferences userPreferences,
    final ThemeData themeData,
  ) {
    return ListTile(
      title: Text(getTitle(), style: themeData.textTheme.headline2),
      subtitle: Text(getSubtitle()),
      trailing: Icon(
        _isCollapsed(userPreferences) ? Icons.expand_more : Icons.expand_less,
      ),
      onTap: () => _switchCollapsed(userPreferences),
    );
  }

  /// Body of the content.
  @protected
  List<Widget> getBody(
    final BuildContext context,
    final AppLocalizations appLocalizations,
    final ThemeProvider themeProvider,
    final ThemeData themeData,
  );

  /// Returns the header, and the body if expanded.
  List<Widget> getContent(
    final BuildContext context,
    final UserPreferences userPreferences,
    final ThemeProvider themeProvider,
    final AppLocalizations appLocalizations,
    final ThemeData themeData,
  ) {
    final List<Widget> result = <Widget>[];
    result.add(_getHeader(userPreferences, themeData));
    if (!_isCollapsed(userPreferences)) {
      result.addAll(
        getBody(context, appLocalizations, themeProvider, themeData),
      );
    }
    return result;
  }

  /// Is the body collapsed?
  bool _isCollapsed(final UserPreferences userPreferences) =>
      userPreferences.getFlag(getPreferenceFlagKey()) ?? isCollapsedByDefault();

  /// Switches the collapsed/expanded status.
  Future<void> _switchCollapsed(final UserPreferences userPreferences) async {
    userPreferences.setFlag(
      getPreferenceFlagKey(),
      !_isCollapsed(userPreferences),
    );
    setState(() {});
  }
}
