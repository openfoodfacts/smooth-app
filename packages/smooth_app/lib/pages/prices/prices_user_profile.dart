import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

class PricesUserProfile extends StatelessWidget {
  const PricesUserProfile({super.key, required this.profile});
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
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              _profileStatsButton(
                Icons.sell_outlined,
                profile.priceCount ?? 0,
                appLocalizations.prices_generic_title,
                context,
              ),
              _profileStatsButton(
                Icons.location_on,
                profile.locationCount ?? 0,
                'locations',
                context,
              ),
              _profileStatsButton(
                Icons.restaurant_menu,
                profile.productCount ?? 0,
                appLocalizations.settings_app_products,
                context,
              ),
              _profileStatsButton(
                Icons.image,
                profile.proofCount ?? 0,
                appLocalizations.prices_proof_subtitle,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileStatsButton(
    IconData icon,
    int count,
    String label,
    BuildContext context, {
    Color? color,
  }) {
    return SmoothCard(
      // color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
      child: Container(
        width: MediaQuery.sizeOf(context).width / 2 - 3 * LARGE_SPACE,
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: color, size: DEFAULT_ICON_SIZE),
                const SizedBox(width: VERY_SMALL_SPACE),
                Text(
                  count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
