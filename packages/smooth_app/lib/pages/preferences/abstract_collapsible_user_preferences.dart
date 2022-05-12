import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';

/// Abstraction of a collapsed/expanded display for the preference pages.
abstract class AbstractCollapsibleUserPreferences
    extends AbstractUserPreferences {
  AbstractCollapsibleUserPreferences({
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

  /// Flag Key to store the collapsed/expanded status
  @protected
  String getPreferenceFlagKey();

  @override
  bool isCompactTitle() => true;

  @override
  List<Widget> getContent({
    final bool withHeader = true,
    final bool withBody = true,
  }) =>
      super.getContent(
        withHeader: withHeader,
        withBody: !_isCollapsed(),
      );

  @override
  Widget getHeaderHelper(final bool? collapsed) =>
      super.getHeaderHelper(_isCollapsed());

  bool _isCollapsed() =>
      userPreferences.getFlag(getPreferenceFlagKey()) ?? false;

  /// Switches the collapsed/expanded status.
  @override
  Future<void> runHeaderAction() async {
    userPreferences.setFlag(getPreferenceFlagKey(), !_isCollapsed());
    setState(() {});
  }
}
