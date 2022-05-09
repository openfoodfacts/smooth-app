import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/animations/smooth_animated_collapse_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/user_preferences_page.dart';
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
  @protected
  Widget getTitle() => Text(
        getTitleString(),
        style: themeData.textTheme.headline2,
      );

  /// Subtitle of the header, always visible.
  @protected
  Widget? getSubtitle();

  /// Should the expand/collapse icon be next to the title.
  @protected
  bool isCompactTitle() => false;

  Widget getOnlyHeader() => InkWell(
        onTap: () async => runHeaderAction(),
        child: _getHeaderWidget(false),
      );

  /// Returns the tappable header.
  @protected
  Widget getHeader() => InkWell(
        onTap: () async => runHeaderAction(),
        child: _getHeaderWidget(true),
      );

  Widget _getHeaderWidget(final bool? collapsed) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LARGE_SPACE,
          vertical: SMALL_SPACE,
        ),
        child: getHeaderHelper(collapsed),
      );

  /// Returns the header (helper) (no padding, no tapping).
  @protected
  Widget getHeaderHelper(final bool? collapsed) {
    final Widget title = Row(
      mainAxisAlignment: isCompactTitle()
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        getTitle(),
        if (isCompactTitle())
          SmoothAnimatedCollapseArrow(collapsed: collapsed!)
        else if (collapsed != null)
          Icon(ConstantIcons.instance.getForwardIcon())
      ],
    );
    final Widget? subtitle = getSubtitle();
    if (subtitle == null) {
      return title;
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: SMALL_SPACE,
          ),
          title,
          const SizedBox(
            height: VERY_SMALL_SPACE,
          ),
          subtitle
        ]);
  }

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

  /// Returns a slightly different version of [getContent] for the onboarding.
  List<Widget> getOnboardingContent() {
    final List<Widget> result = <Widget>[];
    result.add(_getHeaderWidget(null));
    result.addAll(getBody());
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
