import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class PricesUserProfile extends StatelessWidget {
  const PricesUserProfile({required this.profile, super.key});
  final PriceUser profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              profile.userId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: Column(
              spacing: SMALL_SPACE,
              children: <Widget>[
                Row(
                  spacing: SMALL_SPACE,
                  children: <Widget>[
                    Expanded(
                      child: _profileStatsButton(
                        Icons.sell_outlined,
                        profile.priceCount ?? 0,
                        appLocalizations.prices_generic_title,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _profileStatsButton(
                        Icons.location_on,
                        profile.locationCount ?? 0,
                        appLocalizations.prices_stats_locations_section,
                        context,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: SMALL_SPACE,
                  children: <Widget>[
                    Expanded(
                      child: _profileStatsButton(
                        Icons.restaurant_menu,
                        profile.productCount ?? 0,
                        appLocalizations.settings_app_products,
                        context,
                      ),
                    ),
                    Expanded(
                      child: _profileStatsButton(
                        Icons.image,
                        profile.proofCount ?? 0,
                        appLocalizations.prices_proof_subtitle,
                        context,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStatsButton(
    IconData icon,
    int count,
    String label,
    BuildContext context,
  ) {
    final SmoothColorsThemeExtension themeExtension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Material(
      color: lightTheme
          ? themeExtension.primaryMedium
          : themeExtension.primaryDark,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: DEFAULT_ICON_SIZE,
                  color: lightTheme ? themeExtension.primaryDark : Colors.white,
                ),
                const SizedBox(width: VERY_SMALL_SPACE),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: lightTheme
                        ? themeExtension.primaryDark
                        : Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: lightTheme ? themeExtension.primaryDark : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
