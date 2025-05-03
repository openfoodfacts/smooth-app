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
  late final InfiniteScrollController<PriceProduct, GetPriceProductsParameters,
      MaybeError<GetPriceProductsResult>> _scrollController;

  late final GetPriceProductsParameters _parameters;

  @override
  void initState() {
    super.initState();
    _scrollController = InfiniteScrollController<PriceProduct,
        GetPriceProductsParameters, MaybeError<GetPriceProductsResult>>(
      initialItems: const <PriceProduct>[],
      fetchResult: _fetchPriceProductsResult,
      extractItems: _extractProductsFromResult,
    );

    _parameters = GetPriceProductsParameters()
      ..orderBy = <OrderBy<GetPriceProductsOrderField>>[
        const OrderBy<GetPriceProductsOrderField>(
          field: GetPriceProductsOrderField.priceCount,
          ascending: false,
        ),
      ]
      ..pageSize = _pageSize;
  }

  Future<MaybeError<GetPriceProductsResult>> _fetchPriceProductsResult(
      final GetPriceProductsParameters parameters, final int page,
      {Function(int? totalItems, int? totalPages)? onPageInfoUpdated}) async {
    final MaybeError<GetPriceProductsResult> result =
        await OpenPricesAPIClient.getPriceProducts(
      parameters..pageNumber = page,
      uriHelper: ProductQuery.uriPricesHelper,
    );

    if (onPageInfoUpdated != null) {
      onPageInfoUpdated(result.value.total, result.value.numberOfPages);
    }

    return result;
  }

  List<PriceProduct> _extractProductsFromResult(
      MaybeError<GetPriceProductsResult> result) {
    return result.value.items ?? <PriceProduct>[];
  }

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
      body: InfiniteScrollList<PriceProduct, GetPriceProductsParameters,
          MaybeError<GetPriceProductsResult>>(
        controller: _scrollController,
        parameters: _parameters,
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
