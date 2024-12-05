import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/account_deletion_webview.dart';
import 'package:smooth_app/pages/preferences/lazy_counter.dart';
import 'package:smooth_app/pages/preferences/lazy_counter_widget.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';

class UserPreferencesAccount extends AbstractUserPreferences {
  UserPreferencesAccount({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.ACCOUNT;

  String? _getUserId() => OpenFoodAPIConfiguration.globalUser?.userId;

  @override
  String getTitleString() {
    final String? userId = _getUserId();

    if (userId == null) {
      return appLocalizations.user_profile_title_guest;
    }
    if (userId.isEmail) {
      return appLocalizations.user_profile_title_id_email(userId);
    }
    return appLocalizations.user_profile_title_id_default(userId);
  }

  @override
  String getPageTitleString() => appLocalizations.myPreferences_profile_title;

  @override
  String getSubtitleString() => _isUserConnected()
      ? appLocalizations.myPreferences_profile_subtitle
      : appLocalizations.user_profile_subtitle_guest;

  @override
  List<String> getLabels() => <String>[
        ...super.getLabels(),
        if (_getUserId() == null) appLocalizations.sign_in,
      ];

  @override
  IconData getLeadingIconData() => Icons.face;

  // No arrow
  @override
  Icon? getForwardIcon() => _isUserConnected() ? super.getForwardIcon() : null;

  @override
  Future<void> runHeaderAction() async => _isUserConnected(readOnly: true)
      ? super.runHeaderAction()
      : _goToLoginPage();

  bool _isUserConnected({bool readOnly = false}) {
    // Ensure to be notified after a sign-in/sign-out
    if (!readOnly) {
      context.watch<UserManagementProvider>();
    }

    return OpenFoodAPIConfiguration.globalUser != null;
  }

  @override
  Widget? getAdditionalSubtitle() {
    if (_getUserId() != null) {
      // we are already connected: no "LOGIN" button
      return null;
    }
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.sizeOf(context);
    return Container(
      margin: EdgeInsets.only(
        left: size.width / 4,
        right: size.width / 4,
        bottom: SMALL_SPACE,
      ),
      child: SmoothSimpleButton(
        child: Text(
          appLocalizations.sign_in,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        onPressed: () async => _goToLoginPage(),
      ),
    );
  }

  Future<void> _goToLoginPage() async => Navigator.of(
        context,
        rootNavigator: true,
      ).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );

  @override
  List<UserPreferencesItem> getChildren() {
    if (OpenFoodAPIConfiguration.globalUser == null) {
      // No credentials
      final Size size = MediaQuery.sizeOf(context);
      return <UserPreferencesItem>[
        UserPreferencesItemSimple(
          labels: <String>[appLocalizations.sign_in],
          builder: (_) => Center(
            child: ElevatedButton(
              onPressed: () async => _goToLoginPage(),
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(
                  Size(size.width * 0.5, themeData.buttonTheme.height + 10),
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: CIRCULAR_BORDER_RADIUS,
                  ),
                ),
              ),
              child: Text(
                appLocalizations.sign_in,
                style: themeData.textTheme.bodyMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: themeData.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ];
    }

    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    // Credentials
    final String userId = ProductQuery.getWriteUser().userId;
    return <UserPreferencesItem>[
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.CONTRIBUTOR,
          // TODO(monsieurtanuki): only food?
          productType: ProductType.food,
        ),
        title: appLocalizations.user_search_contributor_title,
        iconData: Icons.add_circle_outline,
        context: context,
        localDatabase: localDatabase,
        lazyCounter: const LazyCounterUserSearch(UserSearchType.CONTRIBUTOR),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.INFORMER,
          productType: ProductType.food,
        ),
        title: appLocalizations.user_search_informer_title,
        iconData: Icons.edit,
        context: context,
        localDatabase: localDatabase,
        lazyCounter: const LazyCounterUserSearch(UserSearchType.INFORMER),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.PHOTOGRAPHER,
          productType: ProductType.food,
        ),
        title: appLocalizations.user_search_photographer_title,
        iconData: Icons.add_a_photo,
        context: context,
        localDatabase: localDatabase,
        lazyCounter: const LazyCounterUserSearch(UserSearchType.PHOTOGRAPHER),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.TO_BE_COMPLETED,
          productType: ProductType.food,
        ),
        title: appLocalizations.user_search_to_be_completed_title,
        iconData: Icons.more_horiz,
        context: context,
        localDatabase: localDatabase,
        lazyCounter:
            const LazyCounterUserSearch(UserSearchType.TO_BE_COMPLETED),
      ),
      _buildProductQueryTile(
        productQuery: PagedToBeCompletedProductQuery(
          productType: ProductType.food,
        ),
        title: appLocalizations.all_search_to_be_completed_title,
        iconData: Icons.more_outlined,
        context: context,
        localDatabase: localDatabase,
      ),
      _getListTile(
        appLocalizations.categorize_products_country_title,
        () async => LaunchUrlHelper.launchURL(
          'https://hunger.openfoodfacts.org/eco-score?cc=${ProductQuery.getCountry().offTag}',
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.view_profile,
        () async => LaunchUrlHelper.launchURL(
          ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/editor/$userId',
          ),
        ),
        Icons.open_in_new,
      ),
      _getListTile(
        appLocalizations.account_delete,
        () async => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AccountDeletionWebview(),
          ),
        ),
        Icons.delete,
      ),
      _getListTile(
        appLocalizations.sign_out,
        () async {
          if (await _confirmLogout() == true) {
            if (context.mounted) {
              await context.read<UserManagementProvider>().logout();
              AnalyticsHelper.trackEvent(AnalyticsEvent.logoutAction);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          }
        },
        Icons.clear,
      ),
    ];
  }

  Future<bool?> _confirmLogout() async => showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return SmoothAlertDialog(
            title: appLocalizations.sign_out,
            body: Text(
              appLocalizations.sign_out_confirmation,
            ),
            positiveAction: SmoothActionButton(
              text: appLocalizations.yes,
              onPressed: () async => Navigator.pop(context, true),
            ),
            negativeAction: SmoothActionButton(
              text: appLocalizations.no,
              onPressed: () => Navigator.pop(context, false),
            ),
          );
        },
      );

  UserPreferencesItem _buildProductQueryTile({
    required final PagedProductQuery productQuery,
    required final String title,
    required final IconData iconData,
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    final LazyCounter? lazyCounter,
  }) =>
      _getListTile(
        title,
        () async => ProductQueryPageHelper.openBestChoice(
          name: title,
          localDatabase: localDatabase,
          productQuery: productQuery,
          context: context,
          editableAppBarTitle: true,
        ),
        iconData,
        lazyCounter: lazyCounter,
      );

  UserPreferencesItem _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final LazyCounter? lazyCounter,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[title],
        builder: (_) => Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: Theme.of(context).cardColor,
          child: UserPreferencesListTile(
            title: Text(title),
            onTap: onTap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            leading: UserPreferencesListTile.getTintedIcon(leading, context),
            trailing:
                lazyCounter == null ? null : LazyCounterWidget(lazyCounter),
          ),
        ),
      );
}
