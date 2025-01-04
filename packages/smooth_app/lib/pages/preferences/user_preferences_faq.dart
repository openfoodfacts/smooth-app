import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/pages/guides/guide/guide_nutriscore_v2.dart';
import 'package:smooth_app/pages/preferences/abstract_user_preferences.dart';
import 'package:smooth_app/pages/preferences/user_preferences_item.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/query/product_query.dart';

/// Display of "FAQ" for the preferences page.
class UserPreferencesFaq extends AbstractUserPreferences {
  UserPreferencesFaq({
    required super.context,
    required super.userPreferences,
    required super.appLocalizations,
    required super.themeData,
  });

  @override
  PreferencePageType getPreferencePageType() => PreferencePageType.FAQ;

  @override
  String getTitleString() => appLocalizations.faq;

  @override
  IconData getLeadingIconData() => Icons.question_mark;

  @override
  String? getHeaderAsset() => 'assets/preferences/faq.svg';

  @override
  Color? getHeaderColor() => const Color(0xFFDFF7E8);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  List<UserPreferencesItem> getChildren() => <UserPreferencesItem>[
        _getListTile(
          title: appLocalizations.faq,
          leadingIconData: Icons.question_mark,
          url: 'https://support.openfoodfacts.org/help',
        ),
        _getNutriListTile(
          title: appLocalizations.nutriscore_generic,
          url: 'https://world.openfoodfacts.org/nutriscore',
          svg: SvgCache.getAssetsCacheForNutriscore(
            NutriScoreValue.b,
            false,
          ),
        ),
        _getListTile(
          title: appLocalizations.faq_nutriscore_nutriscore,
          leadingSvg: SvgCache.getAssetsCacheForNutriscore(
            NutriScoreValue.b,
            true,
          ),
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const GuideNutriscoreV2(),
            ),
          ),

          /// Hide the icon
          icon: const Icon(
            Icons.info,
            size: 0.0,
          ),
        ),
        _getNutriListTile(
          title: appLocalizations.environmental_score_generic,
          url: 'https://world.openfoodfacts.org/ecoscore',
          svg: 'assets/cache/green-score-b.svg',
        ),
        _getNutriListTile(
          title: appLocalizations.nova_group_generic,
          url: 'https://world.openfoodfacts.org/nova',
          svg: 'assets/cache/nova-group-4.svg',
        ),
        _getNutriListTile(
          title: appLocalizations.nutrition_facts,
          url: 'https://world.openfoodfacts.org/traffic-lights',
          svg: 'assets/cache/low.svg',
          leadingSvgWidth: 1.5 * DEFAULT_ICON_SIZE,
        ),
        _getListTile(
          title: appLocalizations.discover,
          leadingIconData: Icons.travel_explore,
          url: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/discover',
          ),
        ),
        _getListTile(
          title: appLocalizations.how_to_contribute,
          leadingIconData: Icons.volunteer_activism,
          url: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/contribute',
          ),
        ),
        _getListTile(
          title: appLocalizations.feed_back,
          leadingIconData: Icons.add_comment,
          url: UserFeedbackHelper.getFeedbackFormLink(),
        ),
        _getListTile(
          title: appLocalizations.faq_title_partners,
          leadingIconData: Icons.handshake_outlined,
          url: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/partners',
          ),
        ),
        _getListTile(
          title: appLocalizations.faq_title_vision,
          leadingIconData: Icons.remove_red_eye_outlined,
          url: ProductQuery.replaceSubdomain(
            'https://world.openfoodfacts.org/open-food-facts-vision-mission-values-and-programs',
          ),
        ),
        if (Platform.isAndroid || Platform.isIOS)
          _getListTile(
            title: appLocalizations.faq_title_install_beauty,
            // for the record those svg files were edited, because svg flutter
            // does not support the styles
            // eg. <style>.b{fill:#008c8c;}.c{fill:#fff;}</style> is not taken into account
            // and the initial rect creates a background we don't need
            leadingSvg: _isDark
                ? 'assets/app/RVB_ICON_BLACK_BG_OBF.svg'
                : 'assets/app/RVB_ICON_WHITE_BG_OBF.svg',
            url: Platform.isAndroid
                ? 'https://play.google.com/store/apps/details?id=org.openbeautyfacts.scanner&hl=${ProductQuery.getLanguage().offTag}'
                : 'https://apps.apple.com/${ProductQuery.getLanguage().offTag}/app/open-beauty-facts/id1122926380',
          ),
        if (Platform.isAndroid)
          _getListTile(
            title: appLocalizations.faq_title_install_pet,
            leadingSvg: _isDark
                ? 'assets/app/RVB_ICON_BLACK_BG_OPFF.svg'
                : 'assets/app/RVB_ICON_WHITE_BG_OPFF.svg',
            url:
                'https://play.google.com/store/apps/details?id=org.openpetfoodfacts.scanner&hl=${ProductQuery.getLanguage().offTag}',
          ),
        if (Platform.isAndroid)
          _getListTile(
            title: appLocalizations.faq_title_install_product,
            leadingSvg: _isDark
                ? 'assets/app/RVB_ICON_BLACK_BG_OPF.svg'
                : 'assets/app/RVB_ICON_WHITE_BG_OPF.svg',
            url:
                'https://play.google.com/store/apps/details?id=org.openpetfoodfacts.scanner&hl=${ProductQuery.getLanguage().offTag}',
          ),
        _getListTile(
          title: appLocalizations.about_this_app,
          leadingIconData: Icons.info,
          onTap: () async => _about(),
          icon: getForwardIcon(),
        ),
      ];

  UserPreferencesItem _getListTile({
    required final String title,
    final IconData? leadingIconData,
    final String? leadingSvg,
    final double? leadingSvgWidth,
    final String? url,
    final VoidCallback? onTap,
    final Icon? icon,
  }) =>
      UserPreferencesItemSimple(
        labels: <String>[title],
        builder: (_) => UserPreferencesListTile(
          title: Text(title),
          onTap: onTap ?? () async => LaunchUrlHelper.launchURL(url!),
          trailing: icon ??
              UserPreferencesListTile.getTintedIcon(Icons.open_in_new, context),
          leading: SizedBox(
            width: 2 * DEFAULT_ICON_SIZE,
            height: 2 * DEFAULT_ICON_SIZE,
            child: Center(
              child: leadingIconData != null
                  ? UserPreferencesListTile.getTintedIcon(
                      leadingIconData, context)
                  : leadingSvg == null
                      ? null
                      : SvgPicture.asset(
                          leadingSvg,
                          width: leadingSvgWidth ?? 2 * DEFAULT_ICON_SIZE,
                          package: AppHelper.APP_PACKAGE,
                        ),
            ),
          ),
          externalLink: url != null,
        ),
      );

  UserPreferencesItem _getNutriListTile({
    required final String title,
    required final String url,
    required final String svg,
    final double? leadingSvgWidth,
  }) =>
      _getListTile(
        title: title,
        leadingSvg: svg,
        leadingSvgWidth: leadingSvgWidth,
        url: ProductQuery.replaceSubdomain(url),
      );

  static const String _iconLightAssetPath =
      'assets/app/release_icon_light_transparent_no_border.svg';
  static const String _iconDarkAssetPath =
      'assets/app/release_icon_dark_transparent_no_border.svg';

  Future<void> _about() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!context.mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final String logo = Theme.of(context).brightness == Brightness.light
            ? _iconLightAssetPath
            : _iconDarkAssetPath;

        return SmoothAlertDialog(
          body: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SvgPicture.asset(
                    logo,
                    width: MediaQuery.sizeOf(context).width * 0.1,
                    package: AppHelper.APP_PACKAGE,
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FittedBox(
                          child: Text(
                            packageInfo.appName,
                            style: themeData.textTheme.displayLarge,
                          ),
                        ),
                        Text(
                          '${packageInfo.version}+${packageInfo.buildNumber}-${GlobalVars.scannerLabel.name}-${GlobalVars.storeLabel.name}',
                          style: themeData.textTheme.titleSmall,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: VERY_LARGE_SPACE),
              SingleChildScrollView(
                child: IconTheme(
                  data: const IconThemeData(size: 16.0),
                  child: Column(
                    children: <Widget>[
                      FractionallySizedBox(
                        widthFactor: 0.9,
                        child: Text(appLocalizations.whatIsOff),
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      SmoothAlertContentButton(
                        onPressed: () async => LaunchUrlHelper.launchURL(
                          ProductQuery.replaceSubdomain(
                            'https://world.openfoodfacts.org/who-we-are',
                          ),
                        ),
                        label: appLocalizations.learnMore,
                        icon: Icons.open_in_new,
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      SmoothAlertContentButton(
                        onPressed: () async => LaunchUrlHelper.launchURL(
                          ProductQuery.replaceSubdomain(
                            'https://world.openfoodfacts.org/terms-of-use',
                          ),
                        ),
                        label: appLocalizations.termsOfUse,
                        icon: Icons.open_in_new,
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      SmoothAlertContentButton(
                        onPressed: () async => LaunchUrlHelper.launchURL(
                          ProductQuery.replaceSubdomain(
                            'https://world.openfoodfacts.org/legal',
                          ),
                        ),
                        label: appLocalizations.legalNotices,
                        icon: Icons.open_in_new,
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      SmoothAlertContentButton(
                        onPressed: () => LaunchUrlHelper.launchURL(
                          ProductQuery.replaceSubdomain(
                            'https://world.openfoodfacts.org/privacy',
                          ),
                        ),
                        label: appLocalizations.privacy_policy,
                        icon: Icons.open_in_new,
                      ),
                      const SizedBox(height: VERY_SMALL_SPACE),
                      SmoothAlertContentButton(
                        onPressed: () => showLicensePage(
                          context: context,
                          applicationName: packageInfo.appName,
                          applicationVersion: packageInfo.version,
                          applicationIcon: SvgPicture.asset(
                            logo,
                            height: MediaQuery.sizeOf(context).height * 0.1,
                          ),
                        ),
                        label: appLocalizations.licenses,
                        icon: Icons.info,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                    ],
                  ),
                ),
              ),
            ],
          ),
          negativeAction: SmoothActionButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            text: appLocalizations.close,
          ),
        );
      },
    );
  }
}
