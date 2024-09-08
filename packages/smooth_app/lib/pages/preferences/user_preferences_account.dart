import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
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
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/prices_users_page.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserPreferencesAccount extends AbstractUserPreferences {
  UserPreferencesAccount({
    required final BuildContext context,
    required final UserPreferences userPreferences,
    required final AppLocalizations appLocalizations,
    required final ThemeData themeData,
  }) : super(
          context: context,
          userPreferences: userPreferences,
          appLocalizations: appLocalizations,
          themeData: themeData,
        );

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
        ),
        title: appLocalizations.user_search_contributor_title,
        iconData: Icons.add_circle_outline,
        context: context,
        localDatabase: localDatabase,
        myCount: _getMyCount(UserSearchType.CONTRIBUTOR),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.INFORMER,
        ),
        title: appLocalizations.user_search_informer_title,
        iconData: Icons.edit,
        context: context,
        localDatabase: localDatabase,
        myCount: _getMyCount(UserSearchType.INFORMER),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.PHOTOGRAPHER,
        ),
        title: appLocalizations.user_search_photographer_title,
        iconData: Icons.add_a_photo,
        context: context,
        localDatabase: localDatabase,
        myCount: _getMyCount(UserSearchType.PHOTOGRAPHER),
      ),
      _buildProductQueryTile(
        productQuery: PagedUserProductQuery(
          userId: userId,
          type: UserSearchType.TO_BE_COMPLETED,
        ),
        title: appLocalizations.user_search_to_be_completed_title,
        iconData: Icons.more_horiz,
        context: context,
        localDatabase: localDatabase,
        myCount: _getMyCount(UserSearchType.TO_BE_COMPLETED),
      ),
      _getListTile(
        PriceUserButton.showUserTitle(
          user: ProductQuery.getWriteUser().userId,
          context: context,
        ),
        () async => PriceUserButton.showUserPrices(
          user: ProductQuery.getWriteUser().userId,
          context: context,
        ),
        CupertinoIcons.money_dollar_circle,
        myCount: _getPricesCount(owner: ProductQuery.getWriteUser().userId),
      ),
      _getListTile(
        appLocalizations.user_search_proofs_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PricesProofsPage(),
          ),
        ),
        Icons.receipt,
      ),
      _getListTile(
        appLocalizations.prices_add_a_receipt,
        () async => ProductPriceAddPage.showProductPage(
          context: context,
          proofType: ProofType.receipt,
        ),
        Icons.add_shopping_cart,
      ),
      _getListTile(
        appLocalizations.prices_add_price_tags,
        () async => ProductPriceAddPage.showProductPage(
          context: context,
          proofType: ProofType.priceTag,
        ),
        Icons.add_shopping_cart,
      ),
      _getListTile(
        appLocalizations.all_search_prices_latest_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PricesPage(
              GetPricesModel(
                parameters: GetPricesParameters()
                  ..orderBy = <OrderBy<GetPricesOrderField>>[
                    const OrderBy<GetPricesOrderField>(
                      field: GetPricesOrderField.created,
                      ascending: false,
                    ),
                  ]
                  ..pageSize = GetPricesModel.pageSize
                  ..pageNumber = 1,
                displayOwner: true,
                displayProduct: true,
                uri: OpenPricesAPIClient.getUri(
                  path: 'app/prices',
                  uriHelper: ProductQuery.uriPricesHelper,
                ),
                title: appLocalizations.all_search_prices_latest_title,
              ),
            ),
          ),
        ),
        CupertinoIcons.money_dollar_circle,
        myCount: _getPricesCount(),
      ),
      _getListTile(
        appLocalizations.all_search_prices_top_user_title,
        () async => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const PricesUsersPage(),
          ),
        ),
        Icons.account_box,
      ),
      _getPriceListTile(
        appLocalizations.all_search_prices_top_location_title,
        'app/locations',
      ),
      _getPriceListTile(
        appLocalizations.all_search_prices_top_product_title,
        'app/products',
      ),
      _buildProductQueryTile(
        productQuery: PagedToBeCompletedProductQuery(),
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

  UserPreferencesItem _getPriceListTile(
    final String title,
    final String path,
  ) =>
      _getListTile(
        title,
        () async => LaunchUrlHelper.launchURL(
          OpenPricesAPIClient.getUri(
            path: path,
            uriHelper: ProductQuery.uriPricesHelper,
          ).toString(),
        ),
        Icons.open_in_new,
      );

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

  Future<int?> _getMyCount(
    final UserSearchType type,
  ) async {
    final User user = ProductQuery.getWriteUser();
    final ProductSearchQueryConfiguration configuration = type.getConfiguration(
      user.userId,
      1,
      1,
      ProductQuery.getLanguage(),
      // one field is enough as we want only the count
      // and we need at least one field (no field meaning all fields)
      <ProductField>[ProductField.BARCODE],
    );

    try {
      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        user,
        configuration,
        uriHelper: ProductQuery.uriProductHelper,
      );
      return result.count;
    } catch (e) {
      Logs.e(
        'Could not count the number of products for $type, ${user.userId}',
        ex: e,
      );
      return null;
    }
  }

  Future<int?> _getPricesCount({final String? owner}) async {
    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()
        ..owner = owner
        ..pageSize = 1,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    if (result.isError) {
      return null;
    }
    return result.value.total;
  }

  UserPreferencesItem _buildProductQueryTile({
    required final PagedProductQuery productQuery,
    required final String title,
    required final IconData iconData,
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    final Future<int?>? myCount,
  }) =>
      _getListTile(
        title,
        () async => ProductQueryPageHelper.openBestChoice(
          name: title,
          localDatabase: localDatabase,
          productQuery: productQuery,
          context: context,
          editableAppBarTitle: false,
        ),
        iconData,
        myCount: myCount,
      );

  UserPreferencesItem _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final Future<int?>? myCount,
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
            trailing: myCount == null
                ? null
                : FutureBuilder<int?>(
                    future: myCount,
                    builder:
                        (BuildContext context, AsyncSnapshot<int?> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const SizedBox(
                            height: LARGE_SPACE,
                            width: LARGE_SPACE,
                            child: CircularProgressIndicator.adaptive());
                      }
                      return snapshot.data == null
                          ? EMPTY_WIDGET
                          : Text(snapshot.data.toString());
                    },
                  ),
          ),
        ),
      );
}
