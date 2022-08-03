import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/utils/OpenFoodAPIConfiguration.dart';
import 'package:openfoodfacts/utils/UserProductSearchQueryConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/product/common/product_query_page_helper.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/paged_product_query.dart';
import 'package:smooth_app/query/paged_to_be_completed_product_query.dart';
import 'package:smooth_app/query/paged_user_product_query.dart';

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
      style: Theme.of(context).textTheme.headline2,
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
  Widget? getAdditionalSubtitle() {
    if (_getUserId() != null) {
      // we are already connected: no "LOGIN" button
      return null;
    }
    final ThemeData theme = Theme.of(context);
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width / 4),
      child: SmoothSimpleButton(
        child: Text(
          appLocalizations.sign_in,
          style: theme.textTheme.bodyText2?.copyWith(
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
            type: UserProductSearchType.CONTRIBUTOR,
          ),
          title: appLocalizations.user_search_contributor_title,
          iconData: Icons.add_circle_outline,
          context: context,
          localDatabase: localDatabase,
        ),
        const UserPreferencesListItemDivider(),
        _buildProductQueryTile(
          productQuery: PagedUserProductQuery(
            userId: userId,
            type: UserProductSearchType.INFORMER,
          ),
          title: appLocalizations.user_search_informer_title,
          iconData: Icons.edit,
          context: context,
          localDatabase: localDatabase,
        ),
        const UserPreferencesListItemDivider(),
        _buildProductQueryTile(
          productQuery: PagedUserProductQuery(
            userId: userId,
            type: UserProductSearchType.PHOTOGRAPHER,
          ),
          title: appLocalizations.user_search_photographer_title,
          iconData: Icons.add_a_photo,
          context: context,
          localDatabase: localDatabase,
        ),
        const UserPreferencesListItemDivider(),
        _buildProductQueryTile(
          productQuery: PagedUserProductQuery(
            userId: userId,
            type: UserProductSearchType.TO_BE_COMPLETED,
          ),
          title: appLocalizations.user_search_to_be_completed_title,
          iconData: Icons.more_horiz,
          context: context,
          localDatabase: localDatabase,
        ),
        const UserPreferencesListItemDivider(),
        _buildProductQueryTile(
          productQuery: PagedToBeCompletedProductQuery(),
          title: appLocalizations.all_search_to_be_completed_title,
          iconData: Icons.more_outlined,
          context: context,
          localDatabase: localDatabase,
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          onTap: () async => LaunchUrlHelper.launchURL(
            'https://openfoodfacts.org/editor/$userId',
            true,
          ),
          title: Text(appLocalizations.view_profile),
          leading: const Icon(Icons.open_in_new),
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          onTap: () async {
            if (await _confirmLogout(context) == true) {
              Navigator.pop(context);
            }
          },
          title: Text(appLocalizations.sign_out),
          leading: const Icon(Icons.clear),
        ),
        const UserPreferencesListItemDivider(),
        ListTile(
          onTap: () async {
            final Email email = Email(
              body: appLocalizations.email_body_account_deletion(userId),
              subject: appLocalizations.email_subject_account_deletion,
              recipients: <String>['contact@openfoodfacts.org'],
            );

            await FlutterEmailSender.send(email);
          },
          title: Text(appLocalizations.account_delete),
          leading: const Icon(Icons.delete),
        ),
        const UserPreferencesListItemDivider(),
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
              style: theme.textTheme.bodyText2?.copyWith(
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

  Widget _buildProductQueryTile({
    required final PagedProductQuery productQuery,
    required final String title,
    required final IconData iconData,
    required final BuildContext context,
    required final LocalDatabase localDatabase,
  }) =>
      ListTile(
        onTap: () async => ProductQueryPageHelper().openBestChoice(
          name: title,
          localDatabase: localDatabase,
          productQuery: productQuery,
          context: context,
        ),
        title: Text(title),
        leading: Icon(iconData),
      );
}
