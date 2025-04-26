import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/users_profile_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/query/product_query.dart';

class PricesDashboardWidget extends StatefulWidget {
  const PricesDashboardWidget({super.key, required this.userProfile});
  final UserProfile? userProfile;
  @override
  State<PricesDashboardWidget> createState() => _PricesDashboardWidgetState();
}

class _PricesDashboardWidgetState extends State<PricesDashboardWidget> {
  int selectedIndex = 0;
  late Future<MaybeError<GetPricesResult?>> pricesFuture = _getUserPrices();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: MEDIUM_SPACE,
      children: <Widget>[
        categorySwitch(),
        const SizedBox(height: SMALL_SPACE),
        priceProofButton(widget.userProfile!, appLocalizations),
        FutureBuilder<MaybeError<GetPricesResult?>>(
          future: _getUserPrices(),
          builder: (BuildContext context,
              AsyncSnapshot<MaybeError<GetPricesResult?>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            return Expanded(
              child: ProductPricesList(
                GetPricesModel(
                  title: appLocalizations.prices_generic_title,
                  parameters: GetPricesParameters(),
                  uri: OpenPricesAPIClient.getUri(
                    path: 'users/${widget.userProfile!.userId}',
                    uriHelper: ProductQuery.uriPricesHelper,
                  ),
                ),
                pricesResult: snapshot.data!.value,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<MaybeError<GetPricesResult?>> _getUserPrices() async {
    final MaybeError<GetPricesResult?> prices =
        await OpenPricesAPIClient.getPrices(
      GetPricesParameters()
        ..owner = OpenFoodAPIConfiguration.globalUser?.userId
        ..kind = selectedIndex == 0
            ? ContributionKind.consumption
            : ContributionKind.community,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    return prices;
  }

  /// Toggle between "My Consumption" and "Other Contributions"
  Widget categorySwitch() {
    return Padding(
      padding: const EdgeInsets.all(VERY_LARGE_SPACE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: customToggleButton(
                  0,
                  Icons.shopping_cart,
                  'Receipts & GDPR requests',
                  () => setState(() {
                        selectedIndex = 0;
                        pricesFuture = _getUserPrices();
                      }))),
          Expanded(
            flex: 1,
            child: customToggleButton(1, Icons.people, 'Price labels', () {
              setState(() {
                selectedIndex = 1;
                pricesFuture = _getUserPrices();
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget customToggleButton(
      int index, IconData icon, String label, VoidCallback onTap) {
    final Color selectedColor = Theme.of(context).colorScheme.onSurface;
    final Color unselectedColor = selectedColor.withAlpha(128);
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: VERY_SMALL_SPACE,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: isSelected ? selectedColor : unselectedColor),
              const SizedBox(width: VERY_SMALL_SPACE),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (isSelected)
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: VERY_SMALL_SPACE,
              color: selectedColor,
            )
          else
            const SizedBox(height: VERY_SMALL_SPACE),
        ],
      ),
    );
  }

  Widget priceProofButton(
      UserProfile profile, AppLocalizations appLocalizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SmoothCard(
            child: ListTile(
              onTap: () {
                PriceUserButton.showUserPrices(
                  user: profile.userId,
                  context: context,
                );
              },
              subtitle: Text(appLocalizations.prices_generic_title),
              title: Text(selectedIndex == 0
                  ? profile.priceKindConsumptionCount.toString()
                  : profile.priceKindCommunityCount.toString()),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SmoothCard(
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const PricesProofsPage(selectProof: false),
                  ),
                );
              },
              subtitle: Text(appLocalizations.prices_proof_subtitle),
              title: Text(selectedIndex == 0
                  ? profile.proofKindConsumptionCount.toString()
                  : profile.proofKindCommunityCount.toString()),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ],
    );
  }
}
