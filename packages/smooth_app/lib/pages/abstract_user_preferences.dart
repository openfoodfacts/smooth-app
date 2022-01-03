import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';

/// Abstraction of a collapsed/expanded display for the preferences page.
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

  /// Flag Key to store the collapsed/expanded status
  @protected
  String getPreferenceFlagKey();

  /// At init time, should we be collapsed?
  @protected
  bool isCollapsedByDefault();

  /// Title of the header, always visible.
  @protected
  Widget getTitle();

  /// Subtitle of the header, always visible.
  @protected
  Widget? getSubtitle();

  /// Returns the header.
  Widget _getHeader(final UserPreferences userPreferences) => ListTile(
        title: getTitle(),
        subtitle: getSubtitle(),
        trailing: Icon(
          _isCollapsed(userPreferences) ? Icons.expand_more : Icons.expand_less,
        ),
        onTap: () => _switchCollapsed(userPreferences),
      );

  /// Body of the content.
  @protected
  List<Widget> getBody();

  /// Returns the header, and the body if expanded.
  List<Widget> getContent() {
    final List<Widget> result = <Widget>[];
    result.add(_getHeader(userPreferences));
    if (!_isCollapsed(userPreferences)) {
      result.addAll(getBody());
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
