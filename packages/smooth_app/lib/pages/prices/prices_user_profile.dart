import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/data_models/users_profile_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';

class PricesUserProfile extends StatelessWidget {
  const PricesUserProfile({super.key, required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothCard(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person, size: DEFAULT_ICON_SIZE * 2),
            title: Text(
              profile.userId,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              profileStatsButton(
                Icons.sell_outlined,
                profile.priceCount,
                appLocalizations.prices_generic_title,
                context,
              ),
              profileStatsButton(
                Icons.location_on,
                profile.locationCount,
                'locations',
                context,
              ),
              profileStatsButton(
                Icons.restaurant_menu,
                profile.productCount,
                appLocalizations.settings_app_products,
                context,
              ),
              profileStatsButton(
                Icons.image,
                profile.proofCount,
                appLocalizations.prices_proof_subtitle,
                context,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget profileStatsButton(
      IconData icon, int count, String label, BuildContext context,
      {Color? color}) {
    return SmoothCard(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(24),
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
                Text(count.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text(label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}
