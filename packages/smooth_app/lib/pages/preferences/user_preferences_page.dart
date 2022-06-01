import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_account.dart';
import 'package:smooth_app/pages/preferences/user_preferences_connect.dart';
import 'package:smooth_app/pages/preferences/user_preferences_contribute.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences/user_preferences_faq.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/pages/preferences/user_preferences_settings.dart';
import 'package:smooth_app/pages/preferences/user_preferences_user_lists.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/theme_provider.dart';

enum PreferencePageType {
  ACCOUNT,
  LISTS,
  FOOD,
  DEV_MODE,
  SETTINGS,
  CONTRIBUTE,
  FAQ,
  CONNECT,
}

/// Preferences page: main or detailed.
class UserPreferencesPage extends StatefulWidget {
  const UserPreferencesPage({this.type});

  /// Detailed page if not null, or else main page.
  final PreferencePageType? type;

  @override
  State<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage>
    with TraceableClientMixin {
  @override
  String get traceTitle => 'user_preferences_page';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.read<UserPreferences>();

    final String appBarTitle;
    final List<Widget> children = <Widget>[];
    final bool addDividers;

    final String? headerAsset;
    final Color? headerColor;
    if (widget.type == null) {
      final List<PreferencePageType> items = <PreferencePageType>[
        PreferencePageType.ACCOUNT,
        PreferencePageType.LISTS,
        PreferencePageType.FOOD,
        PreferencePageType.SETTINGS,
        PreferencePageType.CONTRIBUTE,
        PreferencePageType.FAQ,
        PreferencePageType.CONNECT,
        if (userPreferences.devMode > 0) PreferencePageType.DEV_MODE,
      ];

      for (final PreferencePageType type in items) {
        children.add(
          getUserPreferences(
            type: type,
            userPreferences: userPreferences,
          ).getOnlyHeader(),
        );
      }
      headerAsset = 'assets/preferences/main.svg';
      headerColor = const Color(0xFFEBF1FF);

      appBarTitle = appLocalizations.myPreferences;
      addDividers = true;
    } else {
      final AbstractUserPreferences abstractUserPreferences =
          getUserPreferences(
        type: widget.type!,
        userPreferences: userPreferences,
      );

      children.addAll(abstractUserPreferences.getContent(withHeader: false));
      appBarTitle = abstractUserPreferences.getTitleString();
      addDividers = false;

      headerAsset = abstractUserPreferences.getHeaderAsset();
      headerColor = abstractUserPreferences.getHeaderColor();
    }

    const EdgeInsets padding = EdgeInsets.only(top: MEDIUM_SPACE);
    final ListView list;
    if (addDividers) {
      list = ListView.separated(
        padding: padding,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int position) => children[position],
        separatorBuilder: (BuildContext context, int position) =>
            const UserPreferencesListItemDivider(),
      );
    } else {
      list = ListView.builder(
        padding: padding,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int position) => children[position],
      );
    }

    if (headerAsset == null) {
      return Scaffold(
        appBar: AppBar(title: Text(appBarTitle)),
        body: Scrollbar(child: list),
      );
    }
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    // TODO(monsieurtanuki): experimental - find a better value
    const double titleHeightInExpandedMode = 50;
    final double backgroundHeight = mediaQueryData.size.height * .20;
    // TODO(monsieurtanuki): get rid of explicit foregroundColor when appbartheme colors are correct
    final Color? foregroundColor = dark ? null : Colors.black;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            stretch: true,
            backgroundColor: dark ? null : headerColor,
            expandedHeight: backgroundHeight + titleHeightInExpandedMode,
            foregroundColor: foregroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                appBarTitle,
                style: TextStyle(color: foregroundColor),
              ),
              background: Padding(
                padding:
                    const EdgeInsets.only(bottom: titleHeightInExpandedMode),
                child: SvgPicture.asset(
                  headerAsset,
                  height: backgroundHeight,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) => children[index],
              childCount: children.length,
            ),
          ),
        ],
      ),
    );
  }

  AbstractUserPreferences getUserPreferences({
    required final PreferencePageType type,
    required final UserPreferences userPreferences,
  }) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();

    switch (type) {
      case PreferencePageType.ACCOUNT:
        return UserPreferencesAccount(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.LISTS:
        return UserPreferencesUserLists(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.FOOD:
        return UserPreferencesFood(
          productPreferences: productPreferences,
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.SETTINGS:
        return UserPreferencesSettings(
          themeProvider: themeProvider,
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.DEV_MODE:
        return UserPreferencesDevMode(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.CONTRIBUTE:
        return UserPreferencesContribute(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.FAQ:
        return UserPreferencesFaq(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.CONNECT:
        return UserPreferencesConnect(
          setState: setState,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
    }
  }
}
