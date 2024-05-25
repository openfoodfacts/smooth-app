import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_osm_location.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/pages/prices/product_price_add_page.dart';
import 'package:smooth_app/pages/prices/product_prices_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Card that displays buttons related to prices.
class PricesCard extends StatelessWidget {
  const PricesCard(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return buildProductSmoothCard(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).prices_generic_title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: SMALL_SPACE),
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_view_prices,
                icon: CupertinoIcons.tag_fill,
                onPressed: () async => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ProductPricesPage(product),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SMALL_SPACE),
              child: SmoothLargeButtonWithIcon(
                text: appLocalizations.prices_add_a_price,
                icon: Icons.add,
                onPressed: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(
                    context,
                    isLoggedInMandatory: true,
                  )) {
                    return;
                  }
                  if (!context.mounted) {
                    return;
                  }
                  final LocalDatabase localDatabase =
                      context.read<LocalDatabase>();
                  final List<OsmLocation> osmLocations =
                      await DaoOsmLocation(localDatabase).getAll();
                  if (!context.mounted) {
                    return;
                  }
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => ProductPriceAddPage(
                        product,
                        latestOsmLocations: osmLocations,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
