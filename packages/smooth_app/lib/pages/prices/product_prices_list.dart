import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_sliver_list.dart';
import 'package:smooth_app/pages/prices/price_category_widget.dart';
import 'package:smooth_app/pages/prices/price_data_widget.dart';
import 'package:smooth_app/pages/prices/price_location_widget.dart';
import 'package:smooth_app/pages/prices/price_meta_product.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/pages/prices/price_proof_page.dart';
import 'package:smooth_app/pages/prices/price_user_button.dart';
import 'package:smooth_app/pages/prices/prices_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// List of the latest prices for a given model.
class ProductPricesList extends StatefulWidget {
  const ProductPricesList(this.model, {this.pricesResult});

  final GetPricesModel model;
  final GetPricesResult? pricesResult;

  @override
  State<ProductPricesList> createState() => _ProductPricesListState();
}

class _ProductPricesListState extends State<ProductPricesList>
    with TraceableClientMixin {
  late final _InfiniteScrollPriceManager _priceManager;

  @override
  void initState() {
    super.initState();
    _priceManager = _InfiniteScrollPriceManager(
      pricesResult: widget.pricesResult,
      model: widget.model,
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    return InfiniteScrollSliverList<Price>(manager: _priceManager);
  }
}

/// A manager for handling price data with infinite scrolling
class _InfiniteScrollPriceManager extends InfiniteScrollManager<Price> {
  _InfiniteScrollPriceManager({
    GetPricesResult? pricesResult,
    required this.model,
  }) : super(
         initialItems: pricesResult?.items,
         totalItems: pricesResult?.total,
         totalPages: pricesResult?.numberOfPages,
       );

  /// The model containing price query parameters
  final GetPricesModel model;

  @override
  Future<void> fetchData(int pageNumber) async {
    final GetPricesParameters parameters = model.parameters;
    parameters.pageNumber = pageNumber;

    final MaybeError<GetPricesResult> result =
        await OpenPricesAPIClient.getPrices(
          parameters,
          uriHelper: ProductQuery.uriPricesHelper,
        );

    if (result.isError) {
      throw result.detailError;
    }

    final GetPricesResult value = result.value;
    updateItems(
      newItems: value.items,
      pageNumber: value.pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({required BuildContext context, required Price item}) {
    final PriceProduct? priceProduct = item.product;

    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: model.displayEachProduct ? 16.0 : 8.0,
        end: model.displayEachProduct ? 16.0 : 8.0,
      ),
      padding: EdgeInsets.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        onTap: () => _showOptionsMenu(context, item),
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (model.displayEachProduct && priceProduct != null)
                PriceProductWidget(priceProduct)
              else if (model.displayEachProduct)
                PriceCategoryWidget(item),
              PriceDataWidget(
                item,
                model: model,
                showOptionsMenu: () => _showOptionsMenu(context, item),
                padding: model.displayEachProduct
                    ? const EdgeInsetsDirectional.only(
                        start: SMALL_SPACE,
                        end: SMALL_SPACE,
                        top: SMALL_SPACE,
                        bottom: VERY_SMALL_SPACE,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOptionsMenu(BuildContext context, Price price) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool hasProof = price.proof?.filePath != null;
    final bool hasCountButton = model.enableCountButton;

    final ProductPriceAction? res = await showSmoothListOfChoicesModalSheet(
      context: context,
      title: appLocalizations.prices_entry_menu_title(price.owner),
      labels: <String>[
        if (hasCountButton)
          appLocalizations.prices_entry_menu_open_product_prices,
        if (hasProof) appLocalizations.prices_entry_menu_open_proof,
        if (ProductQuery.getWriteUser().userId == price.owner)
          appLocalizations.prices_entry_menu_my_prices
        else
          appLocalizations.prices_entry_menu_author_prices,
        appLocalizations.prices_entry_menu_shop_prices,
      ],
      prefixIcons: <Widget>[
        if (hasCountButton) const icons.PriceTag(),
        if (hasProof) const Icon(Icons.document_scanner_rounded),
        const Icon(Icons.account_circle_rounded),
        const icons.Shop(),
      ],
      values: <ProductPriceAction>[
        if (hasCountButton) ProductPriceAction.VIEW_PRODUCT_PRICES,
        if (hasProof) ProductPriceAction.VIEW_PROOF,
        ProductPriceAction.VIEW_AUTHOR_PRICES,
        ProductPriceAction.VIEW_LOCATION_PRICES,
      ],
      addEndArrowToItems: true,
    );

    if (context.mounted == false || res == null) {
      return;
    }

    switch (res) {
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
}

enum ProductPriceAction {
  VIEW_PRODUCT_PRICES,
  VIEW_PROOF,
  VIEW_AUTHOR_PRICES,
  VIEW_LOCATION_PRICES,
}
