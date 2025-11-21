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
import 'package:smooth_app/pages/preferences/user_preferences_food.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Food Preferences page.
class UserPreferencesFoodPage extends StatefulWidget {
  const UserPreferencesFoodPage();

  static UserPreferencesFood getUserPreferences({
    required final UserPreferences userPreferences,
    required final BuildContext context,
  }) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    BackgroundTaskManager.runAgain(localDatabase);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final ProductPreferences productPreferences = context
        .read<ProductPreferences>();
    // TODO(monsieurtanuki): the following line is probably useless - get rid of it if possible
    context.read<UserManagementProvider>();

    return UserPreferencesFood(
      productPreferences: productPreferences,
      context: context,
      userPreferences: userPreferences,
      appLocalizations: appLocalizations,
      themeData: themeData,
    );
  }

  @override
  State<UserPreferencesFoodPage> createState() =>
      _UserPreferencesFoodPageState();
}

class _UserPreferencesFoodPageState extends State<UserPreferencesFoodPage>
    with TraceableClientMixin {
  final ScrollController _controller = ScrollController();

  @override
  String get actionName => 'Opened user_preferences_food_page';

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();

    final String appBarTitle;
    final List<Widget> children = <Widget>[];

    final String? headerAsset;
    final Color? headerColor;

    final UserPreferencesFood abstractUserPreferences =
        UserPreferencesFoodPage.getUserPreferences(
          userPreferences: userPreferences,
          context: context,
        );

    for (final UserPreferencesItem item
        in abstractUserPreferences.getChildren()) {
      children.add(item.builder(context));
    }
    appBarTitle = abstractUserPreferences.getTitleString();

    headerAsset = abstractUserPreferences.getHeaderAsset();
    headerColor = abstractUserPreferences.getHeaderColor();

    final EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(
      top: MEDIUM_SPACE,
      bottom: MediaQuery.viewPaddingOf(context).bottom,
    );
    final Widget list;
    list = ListView.builder(
      controller: _controller,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (BuildContext context, int position) => children[position],
    );

    if (headerAsset == null) {
      return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(appBarTitle, maxLines: 2),
          leading: const SmoothBackButton(),
        ),
        body: Scrollbar(controller: _controller, child: list),
      );
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundHeight = MediaQuery.heightOf(context) * 0.20;
    children.insert(
      0,
      Container(
        color: dark ? null : headerColor,
        padding: const EdgeInsetsDirectional.symmetric(vertical: SMALL_SPACE),
        child: SvgPicture.asset(
          headerAsset,
          height: backgroundHeight,
          package: AppHelper.APP_PACKAGE,
        ),
      ),
    );
    return SmoothScaffold(
      statusBarBackgroundColor: dark ? null : headerColor,
      contentBehindStatusBar: false,
      spaceBehindStatusBar: false,
      appBar: SmoothAppBar(
        title: Text(appBarTitle, maxLines: 2),
        actions: abstractUserPreferences.getActions(),
      ),
      body: ListView(controller: _controller, children: children),
    );
  }
}
