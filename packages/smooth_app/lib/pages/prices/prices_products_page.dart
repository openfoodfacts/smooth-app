import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_controller.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_list.dart';
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
  static const int _pageSize = 10;
  late final InfiniteScrollController<PriceProduct, GetPriceProductsParameters>
      _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController =
        InfiniteScrollController<PriceProduct, GetPriceProductsParameters>(
      initialItems: const <PriceProduct>[],
      fetchItems: _fetchProducts,
      onError: (dynamic error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading products')),
        );
      },
    );
  }

  Future<(List<PriceProduct>, bool)> _fetchProducts(
    final GetPriceProductsParameters parameters,
    final int page,
  ) async {
    try {
      final MaybeError<GetPriceProductsResult> result =
          await OpenPricesAPIClient.getPriceProducts(
        parameters..pageNumber = page,
        uriHelper: ProductQuery.uriPricesHelper,
      );

      final List<PriceProduct> items = result.value.items ?? <PriceProduct>[];
      final bool hasMore = page < (result.value.numberOfPages ?? 1);

      // Update pagination info
      _scrollController.updatePaginationInfo(
        newTotalItems: result.value.total,
        newTotalPages: result.value.numberOfPages,
      );

      return (items, hasMore);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final GetPriceProductsParameters parameters = GetPriceProductsParameters()
      ..orderBy = <OrderBy<GetPriceProductsOrderField>>[
        const OrderBy<GetPriceProductsOrderField>(
          field: GetPriceProductsOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize;

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
      body: InfiniteScrollList<PriceProduct, GetPriceProductsParameters>(
        controller: _scrollController,
        parameters: parameters,
        headerBuilder: (final BuildContext context) {
          final int totalItems = _scrollController.totalItems ?? 0;

          final String title =
              appLocalizations.prices_products_list_length_many_pages(
            _pageSize,
            totalItems,
          );

          return SmoothCard(child: ListTile(title: Text(title)));
        },
        // Individual item builder
        itemBuilder: (
          final BuildContext context,
          final PriceProduct product,
        ) {
          return SmoothCard(
            child: PriceProductWidget(
              product,
              enableCountButton: true,
            ),
          );
        },
      ),
    );
  }
}
