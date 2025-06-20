import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_account.dart';
import 'package:smooth_app/pages/preferences/user_preferences_connect.dart';
import 'package:smooth_app/pages/preferences/user_preferences_contribute.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/preferences/user_preferences_donation.dart';
import 'package:smooth_app/pages/preferences/user_preferences_faq.dart';
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_prices.dart';
import 'package:smooth_app/pages/preferences/user_preferences_settings.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

enum PreferencePageType {
  ACCOUNT('account'),
  FOOD('food'),
  DEV_MODE('dev_mode'),
  SETTINGS('settings'),
  CONTRIBUTE('contribute'),
  FAQ('faq'),
  DONATION('donation'),
  PRICES('prices'),
  CONNECT('connect');

  const PreferencePageType(this.tag);

  /// A tag used when opening a new screen
  /// eg: preferences/account
  final String tag;

  AbstractUserPreferences getUserPreferences({
    required final UserPreferences userPreferences,
    required final BuildContext context,
  }) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    BackgroundTaskManager.runAgain(localDatabase);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeProvider themeProvider = context.read<ThemeProvider>();
    final ThemeData themeData = Theme.of(context);
    final ProductPreferences productPreferences =
        context.read<ProductPreferences>();
    // TODO(monsieurtanuki): the following line is probably useless - get rid of it if possible
    context.read<UserManagementProvider>();

    switch (this) {
      case PreferencePageType.ACCOUNT:
        return UserPreferencesAccount(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.FOOD:
        return UserPreferencesFood(
          productPreferences: productPreferences,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.SETTINGS:
        return UserPreferencesSettings(
          themeProvider: themeProvider,
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.DEV_MODE:
        return UserPreferencesDevMode(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.CONTRIBUTE:
        return UserPreferencesContribute(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.FAQ:
        return UserPreferencesFaq(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.DONATION:
        return UserPreferencesDonation(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.PRICES:
        return UserPreferencesPrices(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
      case PreferencePageType.CONNECT:
        return UserPreferencesConnect(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );
    }
  }

  static List<PreferencePageType> getPreferencePageTypes(
    final UserPreferences userPreferences,
  ) =>
      <PreferencePageType>[
        PreferencePageType.ACCOUNT,
        PreferencePageType.FOOD,
        PreferencePageType.PRICES,
        PreferencePageType.DONATION,
        PreferencePageType.SETTINGS,
        PreferencePageType.CONTRIBUTE,
        PreferencePageType.FAQ,
        PreferencePageType.CONNECT,
        if (userPreferences.devMode > 0) PreferencePageType.DEV_MODE,
      ];
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
  final ScrollController _controller = ScrollController();

  @override
  String get actionName => 'Opened user_preferences_page';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final String appBarTitle;
    final List<Widget> children = <Widget>[];
    final bool addDividers;

    final String? headerAsset;
    final Color? headerColor;

    if (widget.type == null) {
      final List<PreferencePageType> items =
          PreferencePageType.getPreferencePageTypes(userPreferences);
      for (final PreferencePageType type in items) {
        final AbstractUserPreferences abstractUserPreferences =
            type.getUserPreferences(
          userPreferences: userPreferences,
          context: context,
        );
        children.add(abstractUserPreferences.getOnlyHeader());
        final Widget? additionalSubtitle =
            abstractUserPreferences.getAdditionalSubtitle();
        if (additionalSubtitle != null) {
          children.add(additionalSubtitle);
        }
      }

      headerAsset = 'assets/preferences/main.svg';
      headerColor = const Color(0xFFEBF1FF);

      appBarTitle = appLocalizations.myPreferences;
      addDividers = true;
    } else {
      final AbstractUserPreferences abstractUserPreferences =
          widget.type!.getUserPreferences(
        userPreferences: userPreferences,
        context: context,
      );

      for (final UserPreferencesItem item
          in abstractUserPreferences.getChildren()) {
        children.add(item.builder(context));
      }
      appBarTitle = abstractUserPreferences.getTitleString();
      addDividers = false;

      headerAsset = abstractUserPreferences.getHeaderAsset();
      headerColor = abstractUserPreferences.getHeaderColor();
    }

    final EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(
      top: MEDIUM_SPACE,
      bottom: MediaQuery.viewPaddingOf(context).bottom,
    );
    final ListView list;
    if (addDividers) {
      list = ListView.separated(
        controller: _controller,
        padding: padding,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int position) => children[position],
        separatorBuilder: (BuildContext context, int position) =>
            const UserPreferencesListItemDivider(),
      );
    } else {
      list = ListView.builder(
        controller: _controller,
        padding: padding,
        itemCount: children.length,
        itemBuilder: (BuildContext context, int position) => children[position],
      );
    }

    if (headerAsset == null) {
      return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(
            appBarTitle,
            maxLines: 2,
          ),
          leading: const SmoothBackButton(),
        ),
        body: Scrollbar(
          controller: _controller,
          child: list,
        ),
      );
    }
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundHeight = MediaQuery.sizeOf(context).height * .20;
    children.insert(
      0,
      Container(
        color: dark ? null : headerColor,
        padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
        child: SvgPicture.asset(
          headerAsset,
          height: backgroundHeight,
          package: AppHelper.APP_PACKAGE,
        ),
      ),
    );
    return SmoothScaffold(
      statusBarBackgroundColor: dark ? null : headerColor,
      brightness: Theme.of(context).brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      contentBehindStatusBar: false,
      spaceBehindStatusBar: false,
      appBar: SmoothAppBar(
        title: Text(
          appBarTitle,
          maxLines: 2,
        ),
      ),
      body: ListView(
        controller: _controller,
        children: children,
      ),
    );
  }
}
