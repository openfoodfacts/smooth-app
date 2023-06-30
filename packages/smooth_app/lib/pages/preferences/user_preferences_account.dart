import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/product/common/product_list_page.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

class UserPreferencesAccount extends AbstractUserPreferences {
  UserPreferencesAccount({
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

  @override
  List<Widget> getBody() {
    return <Widget>[
      UserPreferencesSection(
        userPreferences: userPreferences,
        appLocalizations: appLocalizations,
        themeData: themeData,
      ),
    ];
  }

  @override
  PreferencePageType? getPreferencePageType() => PreferencePageType.ACCOUNT;

  String? _getUserId() => OpenFoodAPIConfiguration.globalUser?.userId;

  @override
  Widget getTitle() {
    final String? userId = _getUserId();
    final String title;

    if (userId == null) {
      title = appLocalizations.user_profile_title_guest;
    } else if (userId.isEmail) {
      title = appLocalizations.user_profile_title_id_email(userId);
    } else {
      title = appLocalizations.user_profile_title_id_default(userId);
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.displayMedium,
    );
  }

  @override
  String getTitleString() {
    return appLocalizations.myPreferences_profile_title;
  }

  @override
  Widget? getSubtitle() {
    if (!_isUserConnected()) {
      return const _UserPreferencesAccountSubTitleSignOut();
    } else {
      return Text(appLocalizations.myPreferences_profile_subtitle);
    }
  }

  @override
  IconData getLeadingIconData() => Icons.face;

  // No arrow
  @override
  Icon? getForwardIcon() {
    if (_isUserConnected()) {
      return super.getForwardIcon();
    } else {
      return null;
    }
  }

  @override
  Future<void> runHeaderAction() async {
    if (_isUserConnected(readOnly: true)) {
      return super.runHeaderAction();
    } else {
      return Navigator.of(
        context,
        rootNavigator: true,
      ).push<dynamic>(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const LoginPage(),
        ),
      );
    }
  }

  bool _isUserConnected({bool readOnly = false}) {
    // Ensure to be notified after a sign-in/sign-out
    if (!readOnly) {
      context.watch<UserManagementProvider>();
    }

    return OpenFoodAPIConfiguration.globalUser != null;
  }

  @override
  Widget getAdditionalSubtitle() {
    if (_getUserId() != null) {
      // we are already connected: no "LOGIN" button
      return EMPTY_WIDGET;
    }
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width / 4),
      child: SmoothSimpleButton(
        child: Text(
          appLocalizations.sign_in,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        onPressed: () async {
          Navigator.of(
            context,
            rootNavigator: true,
          ).push<dynamic>(
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => const LoginPage(),
            ),
          );
        },
      ),
    );
  }
}

class _UserPreferencesAccountSubTitleSignOut extends StatelessWidget {
  const _UserPreferencesAccountSubTitleSignOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Text(appLocalizations.user_profile_subtitle_guest);
  }
}

// Put into it's own widget in order for provider.watch() to work
class UserPreferencesSection extends StatefulWidget {
  const UserPreferencesSection({
    Key? key,
    required this.userPreferences,
    required this.appLocalizations,
    required this.themeData,
  }) : super(key: key);

  final UserPreferences userPreferences;
  final AppLocalizations appLocalizations;
  final ThemeData themeData;

  @override
  State<UserPreferencesSection> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesSection> {
  Future<bool?> _confirmLogout(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SmoothAlertDialog(
          title: localizations.sign_out,
          body: Text(
            localizations.sign_out_confirmation,
          ),
          positiveAction: SmoothActionButton(
            text: localizations.yes,
            onPressed: () async {
              context.read<UserManagementProvider>().logout();
              AnalyticsHelper.trackEvent(AnalyticsEvent.logoutAction);
              Navigator.pop(context, true);
            },
          ),
          negativeAction: SmoothActionButton(
            text: localizations.no,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We need to listen to reflect login's from outside of the preferences page
    // e.g. question card, ...
    context.watch<UserManagementProvider>();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();

    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;

    final List<Widget> result;

    if (OpenFoodAPIConfiguration.globalUser != null) {
      // Credentials
      final String userId = OpenFoodAPIConfiguration.globalUser!.userId;

      result = <Widget>[
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
        _buildProductQueryTile(
          productQuery: PagedToBeCompletedProductQuery(),
          title: appLocalizations.all_search_to_be_completed_title,
          iconData: Icons.more_outlined,
          context: context,
          localDatabase: localDatabase,
        ),
        _buildProductLocalTile(
          productList: ProductList.scanHistory(),
          iconData: Icons.history,
          context: context,
          localDatabase: localDatabase,
        ),
        _getListTile(
          appLocalizations.view_profile,
          () async => LaunchUrlHelper.launchURL(
            'https://openfoodfacts.org/editor/$userId',
            true,
          ),
          Icons.open_in_new,
        ),
        _getListTile(
          appLocalizations.account_delete,
          () async {
            final bool? delete = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => SmoothAlertDialog(
                title: appLocalizations.account_delete,
                body: const Text(
                    'In order to delete your account, you need to sign in on the website, go to your settings and click on the "delete account" button.\nWould you like to open the website in a new window now?'),
                actionsAxis: Axis.vertical,
                positiveAction: SmoothActionButton(
                  text: appLocalizations.yes,
                  onPressed: () async => Navigator.of(context).pop(true),
                ),
                negativeAction: SmoothActionButton(
                  text: appLocalizations.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            );
            if (delete == true) {
              return LaunchUrlHelper.launchURL(
                'https://openfoodfacts.org/cgi/session.pl',
                true,
              );
            }
          },
          Icons.delete,
        ),
        _getListTile(
          appLocalizations.sign_out,
          () async {
            // ignore: use_build_context_synchronously
            if (await _confirmLogout(context) == true) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            }
          },
          Icons.clear,
        ),
      ];
    } else {
      // No credentials
      result = <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.of(
                context,
                rootNavigator: true,
              ).push<dynamic>(
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => const LoginPage(),
                ),
              );
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(
                Size(size.width * 0.5, theme.buttonTheme.height + 10),
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                  borderRadius: CIRCULAR_BORDER_RADIUS,
                ),
              ),
            ),
            child: Text(
              appLocalizations.sign_in,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ];
    }

    return Column(children: result);
  }

  Future<int?> _getMyCount(
    final UserSearchType type,
  ) async {
    final User user = OpenFoodAPIConfiguration.globalUser!;
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
        queryType: OpenFoodAPIConfiguration.globalQueryType,
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

  Future<int?> _getMyLocalCount(
    final ProductList productList,
    final LocalDatabase localDatabase,
  ) async {
    await DaoProductList(localDatabase).get(productList);
    return productList.barcodes.length;
  }

  Widget _buildProductQueryTile({
    required final PagedProductQuery productQuery,
    required final String title,
    required final IconData iconData,
    required final BuildContext context,
    required final LocalDatabase localDatabase,
    final Future<int?>? myCount,
  }) =>
      _getListTile(
        title,
        () async => ProductQueryPageHelper().openBestChoice(
          name: title,
          localDatabase: localDatabase,
          productQuery: productQuery,
          context: context,
          editableAppBarTitle: false,
        ),
        iconData,
        myCount: myCount,
      );

  Widget _buildProductLocalTile({
    required final ProductList productList,
    required final IconData iconData,
    required final BuildContext context,
    required final LocalDatabase localDatabase,
  }) =>
      _getListTile(
        ProductQueryPageHelper.getProductListLabel(productList, context),
        () async {
          await DaoProductList(localDatabase).get(productList);
          if (!mounted) {
            return;
          }
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => ProductListPage(productList),
            ),
          );
        },
        iconData,
        myCount: _getMyLocalCount(productList, localDatabase),
      );

  Widget _getListTile(
    final String title,
    final VoidCallback onTap,
    final IconData leading, {
    final Future<int?>? myCount,
  }) =>
      Card(
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
      );
}
