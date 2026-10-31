import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/price_data_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/pages/prices/price_proof_page.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/pages/prices/prices_proofs_page.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class PricesDashboardWidget extends StatefulWidget {
  const PricesDashboardWidget({required this.userProfile, super.key});
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
      children: <Widget>[
        _categorySwitch(),
        const SizedBox(height: SMALL_SPACE),
        _priceProofButton(widget.userProfile, appLocalizations),
        FutureBuilder<MaybeError<GetPricesResult?>>(
          future: pricesFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<MaybeError<GetPricesResult?>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (snapshot.data == null) {
                  return Center(
                    child: Text(
                      appLocalizations.prices_not_found,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }

                final MaybeError<GetPricesResult?> result = snapshot.data!;
                if (result.isError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(LARGE_SPACE),
                      child: Text(
                        result.error ?? appLocalizations.error_occurred,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }

                final GetPricesResult? pricesResult = result.value;
                if (pricesResult?.items == null ||
                    pricesResult!.items!.isEmpty) {
                  return Center(child: Text(appLocalizations.prices_not_found));
                }
                final List<Price> prices = pricesResult.items!;

                final GetPricesModel model = GetPricesModel(
                  title: appLocalizations.prices_generic_title,
                  parameters: GetPricesParameters()
                    ..owner = widget.userProfile.userId
                    ..kind = selectedCategory == 'consumption'
                        ? ContributionKind.consumption
                        : ContributionKind.community,
                  uri: OpenPricesAPIClient.getUri(
                    path: 'users/${widget.userProfile.userId}',
                    uriHelper: ProductQuery.uriPricesHelper,
                  ),
                );
                return Column(
                  children: prices.map((Price item) {
                    final PriceProduct? priceProduct = item.product;
                    return SmoothCard(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (model.displayEachProduct && priceProduct != null)
                            PriceProductWidget(priceProduct),
                          PriceDataWidget(
                            item,
                            model: model,
                            showOptionsMenu: () =>
                                _showOptionsMenu(context, item),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
        ),
      ],
    );
  }

  Future<MaybeError<GetPricesResult?>> _getUserPrices() async {
    return OpenPricesAPIClient.getPrices(
      GetPricesParameters()
        ..owner = widget.userProfile.userId
        ..kind = selectedCategory == 'consumption'
            ? ContributionKind.consumption
            : ContributionKind.community,
      uriHelper: ProductQuery.uriPricesHelper,
    );
  }

  Future<void> _showOptionsMenu(BuildContext context, Price price) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool hasProof = price.proof?.filePath != null;
    final bool hasProduct = price.product != null;

    final ProductPriceAction? res = await showSmoothListOfChoicesModalSheet(
      context: context,
      title: appLocalizations.prices_entry_menu_title(price.owner),
      labels: <String>[
        if (hasProduct) appLocalizations.prices_entry_menu_open_product,
        if (hasProduct) appLocalizations.prices_entry_menu_open_product_prices,
        if (hasProof) appLocalizations.prices_entry_menu_open_proof,
        if (ProductQuery.getWriteUser().userId == price.owner)
          appLocalizations.prices_entry_menu_my_prices
        else
          appLocalizations.prices_entry_menu_author_prices,
        appLocalizations.prices_entry_menu_shop_prices,
      ],
      prefixIcons: <Widget>[
        if (hasProduct) const icons.Milk.happy(),
        if (hasProduct) const icons.PriceTag(),
        if (hasProof) const icons.PriceReceipt(),
        const icons.Profile(),
        const icons.Shop(),
      ],
      values: <ProductPriceAction>[
        if (hasProduct) .VIEW_PRODUCT,
        if (hasProduct) .VIEW_PRODUCT_PRICES,
        if (hasProof) .VIEW_PROOF,
        .VIEW_AUTHOR_PRICES,
        .VIEW_LOCATION_PRICES,
      ],
      addEndArrowToItems: true,
    );

    if (context.mounted == false || res == null) {
      return;
    }

    switch (res) {
      case ProductPriceAction.VIEW_PRODUCT:
        AppNavigator.of(
          context,
        ).push(AppRoutes.PRODUCT_LOADER(price.product!.code));
      case ProductPriceAction.VIEW_PROOF:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PriceProofPage(price.proof!),
          ),
        );
      case ProductPriceAction.VIEW_AUTHOR_PRICES:
        PriceUserButton.showUserPrices(context: context, user: price.owner);
      case ProductPriceAction.VIEW_LOCATION_PRICES:
        PriceLocationWidget.showLocationPrices(
          locationId: price.locationId!,
          context: context,
        );
      case ProductPriceAction.VIEW_PRODUCT_PRICES:
        final LocalDatabase localDatabase = context.read<LocalDatabase>();
        final Product? newProduct = await DaoProduct(
          localDatabase,
        ).get(price.product!.code);
        if (!context.mounted) {
          return;
        }
        return Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => PricesPage(
              GetPricesModel.product(
                product: newProduct != null
                    ? PriceMetaProduct.product(newProduct)
                    : PriceMetaProduct.priceProduct(price.product!),
                context: context,
              ),
            ),
          ),
        );
    }
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
            child: _categoryToggleButton(
              'consumption',
              Icons.shopping_cart,
              appLocalizations.prices_dashboard_receipts_and_gdpr_requests,
              () => setState(() {
                selectedCategory = 'consumption';
                pricesFuture = _getUserPrices();
              }),
            ),
          ),
          Expanded(
            flex: 1,
            child: _categoryToggleButton(
              'community',
              Icons.people,
              appLocalizations.prices_dashboard_price_labels,
              () {
                setState(() {
                  selectedCategory = 'community';
                  pricesFuture = _getUserPrices();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryToggleButton(
    String category,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
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
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? selectedColor : unselectedColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
    PriceUser profile,
    AppLocalizations appLocalizations,
  ) {
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
              title: Text(
                selectedCategory == 'consumption'
                    ? profile.priceKindConsumptionCount.toString()
                    : profile.priceKindCommunityCount.toString(),
              ),
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
              title: Text(
                selectedCategory == 'consumption'
                    ? profile.proofKindConsumptionCount.toString()
                    : profile.proofKindCommunityCount.toString(),
              ),
              trailing: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ],
    );
  }
}
