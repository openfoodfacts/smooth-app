import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/query/product_query.dart';

class PricesDashboardWidget extends StatefulWidget {
  const PricesDashboardWidget({super.key, required this.userProfile});
  final PriceUser userProfile;
  @override
  State<PricesDashboardWidget> createState() => _PricesDashboardWidgetState();
}

class _PricesDashboardWidgetState extends State<PricesDashboardWidget> {
  String selectedCategory = 'consumption';
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
        _categorySwitch(),
        const SizedBox(height: SMALL_SPACE),
        _priceProofButton(widget.userProfile, appLocalizations),
        FutureBuilder<MaybeError<GetPricesResult?>>(
          future: pricesFuture,
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
                    path: 'users/${widget.userProfile.userId}',
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
        ..kind = selectedCategory == 'consumption'
            ? ContributionKind.consumption
            : ContributionKind.community,
      uriHelper: ProductQuery.uriPricesHelper,
    );
    return prices;
  }

  /// Toggle between "My Consumption" and "Other Contributions"
  Widget _categorySwitch() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(VERY_LARGE_SPACE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: customToggleButton(
                  'consumption',
                  Icons.shopping_cart,
                  appLocalizations.prices_dashboard_receipts_and_gdpr_requests,
                  () => setState(() {
                        selectedCategory = 'consumption';
                        pricesFuture = _getUserPrices();
                      }))),
          Expanded(
            flex: 1,
            child: customToggleButton('community', Icons.people,
                appLocalizations.prices_dashboard_price_labels, () {
              setState(() {
                selectedCategory = 'community';
                pricesFuture = _getUserPrices();
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget customToggleButton(
      String category, IconData icon, String label, VoidCallback onTap) {
    final Color selectedColor = Theme.of(context).colorScheme.onSurface;
    final Color unselectedColor = selectedColor.withAlpha(128);
    final bool isSelected = selectedCategory == category;
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

  Widget _priceProofButton(
      PriceUser profile, AppLocalizations appLocalizations) {
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
              title: Text(selectedCategory == 'consumption'
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
              title: Text(selectedCategory == 'consumption'
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
