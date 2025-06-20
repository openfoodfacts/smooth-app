import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the top prices products with infinite scrolling.
class PricesProductsPage extends StatefulWidget {
  const PricesProductsPage();

  @override
  State<PricesProductsPage> createState() => _PricesProductsPageState();
}

class _PricesProductsPageState extends State<PricesProductsPage>
    with TraceableClientMixin {
  final _InfiniteScrollProductManager _productManager =
      _InfiniteScrollProductManager();

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          appLocalizations.all_search_prices_top_product_title,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async => LaunchUrlHelper.launchURL(
              OpenPricesAPIClient.getUri(
                path: 'products',
                uriHelper: ProductQuery.uriPricesHelper,
              ).toString(),
            ),
          ),
        ],
      ),
      body: InfiniteScrollList<PriceProduct>(
        manager: _productManager,
      ),
    );
  }
}

/// A manager for handling product data with infinite scrolling
class _InfiniteScrollProductManager
    extends InfiniteScrollManager<PriceProduct> {
  static const int _pageSize = 10;

  static const List<OrderBy<GetPriceProductsOrderField>> _orderBy =
      <OrderBy<GetPriceProductsOrderField>>[
    OrderBy<GetPriceProductsOrderField>(
      field: GetPriceProductsOrderField.priceCount,
      ascending: false,
    ),
  ];

  @override
  Future<void> fetchData(final int pageNumber) async {
    final MaybeError<GetPriceProductsResult> result =
        await OpenPricesAPIClient.getPriceProducts(
      GetPriceProductsParameters()
        ..pageNumber = pageNumber
        ..pageSize = _pageSize
        ..orderBy = _orderBy,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (result.isError) {
      throw result.detailError;
    }

    final GetPriceProductsResult value = result.value;
    updateItems(
      newItems: value.items,
      pageNumber: value.pageNumber,
      totalItems: value.total,
      totalPages: value.numberOfPages,
    );
  }

  @override
  Widget buildItem({
    required BuildContext context,
    required PriceProduct item,
  }) {
    return SmoothCard(
      child: PriceProductWidget(
        item,
        enableCountButton: true,
      ),
    );
  }
}
