import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/preferences_v2/cards/preference_card.dart';
import 'package:smooth_app/pages/preferences_v2/pages/licenses_page.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/url_preference_tile.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class LegalInformationRoot extends PreferencesRoot {
  const LegalInformationRoot({required super.title});

  @override
  List<PreferenceCard> getCards(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return <PreferenceCard>[
      PreferenceCard(
        tiles: <PreferenceTile>[
          _buildTermsOfUseTile(appLocalizations),
          _buildLegalMentionsTile(appLocalizations),
          _buildPrivacyPolicyTile(appLocalizations),
          _buildLicensesTile(context, appLocalizations),
        ],
      ),
    ];
  }

  @override
  WidgetBuilder? getHeader() =>
      (_) => const _LegalInformationHeader();

  // Legal Information section
  UrlPreferenceTile _buildTermsOfUseTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Document(),
      title: appLocalizations.preferences_terms_of_use,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/terms-of-use',
      ),
    );
  }

  UrlPreferenceTile _buildLegalMentionsTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Document(),
      title: appLocalizations.preferences_legal_mentions,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/legal',
      ),
    );
  }

  UrlPreferenceTile _buildPrivacyPolicyTile(AppLocalizations appLocalizations) {
    return UrlPreferenceTile(
      icon: const icons.Document(),
      title: appLocalizations.preferences_privacy_policy,
      url: ProductQuery.replaceSubdomain(
        'https://world.openfoodfacts.org/privacy',
      ),
    );
  }

  PreferenceTile _buildLicensesTile(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    return PreferenceTile(
      icon: const icons.Document(),
      title: appLocalizations.preferences_licenses,

      trailing: icons.Chevron.right(
        size: 14.0,
        color: context.lightTheme() ? theme.primaryDark : Colors.white,
      ),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LicensesPage(),
        ),
      ),
    );
  }
}

class _LegalInformationHeader extends StatelessWidget {
  const _LegalInformationHeader();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      borderRadius: ROUNDED_BORDER_RADIUS,
      elevation: 2.0,
      padding: EdgeInsetsDirectional.zero,
      margin: const EdgeInsetsDirectional.only(
        top: BALANCED_SPACE,
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lightTheme
                    ? extension.primaryBlack
                    : extension.primaryDark,
                borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: SMALL_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                child: SvgPicture.asset(
                  'assets/app/logo_text_white.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: MEDIUM_SPACE,
              start: LARGE_SPACE,
              end: LARGE_SPACE,
              bottom: LARGE_SPACE,
            ),
            child: TextWithBoldParts(
              text: AppLocalizations.of(context).preferences_legal_header,
              textStyle: const TextStyle(fontSize: 15.0),
            ),
          ),
        ],
      ),
    );
  }
}
