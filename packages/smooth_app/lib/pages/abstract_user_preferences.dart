import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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

  /// Should the expand/collapse icon be next to the title.
  @protected
  bool isCompactTitle() => false;

  /// Returns the header.
  Widget _getHeader(final UserPreferences userPreferences) => InkWell(
        onTap: () => _switchCollapsed(userPreferences),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: _getHeaderHelper(userPreferences),
        ),
      );

  /// Returns the header (helper) (no padding, no tapping).
  Widget _getHeaderHelper(final UserPreferences userPreferences) {
    final Widget title = Row(
      mainAxisAlignment: isCompactTitle()
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        getTitle(),
        Icon(
          _isCollapsed(userPreferences) ? Icons.expand_more : Icons.expand_less,
        ),
      ],
    );
    final Widget? subtitle = getSubtitle();
    if (subtitle == null) {
      return title;
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[title, subtitle]);
  }

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
