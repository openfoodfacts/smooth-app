import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/price_product_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the top prices products.
class PricesProductsPage extends StatefulWidget {
  const PricesProductsPage();

  @override
  State<PricesProductsPage> createState() => _PricesProductsPageState();
}

class _PricesProductsPageState extends State<PricesProductsPage>
    with TraceableClientMixin {
  late final Future<MaybeError<GetPriceProductsResult>> _products =
      _showTopProducts();

  // In this specific page, let's never try to go beyond the top 10.
  // cf. https://github.com/openfoodfacts/smooth-app/pull/5383#issuecomment-2171117141
  static const int _pageSize = 10;

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<MaybeError<GetPriceProductsResult>>(
        future: _products,
        builder: (
          final BuildContext context,
          final AsyncSnapshot<MaybeError<GetPriceProductsResult>> snapshot,
        ) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error!.toString());
          }
          // highly improbable
          if (!snapshot.hasData) {
            return const Text('no data');
          }
          if (snapshot.data!.isError) {
            return Text(snapshot.data!.error!);
          }
          final GetPriceProductsResult result = snapshot.data!.value;
          // highly improbable
          if (result.items == null) {
            return const Text('empty list');
          }
          final List<Widget> children = <Widget>[];

          for (final PriceProduct item in result.items!) {
            children.add(
              SmoothCard(
                child: PriceProductWidget(
                  item,
                  enableCountButton: true,
                ),
              ),
            );
          }
          final AppLocalizations appLocalizations =
              AppLocalizations.of(context);
          final String title =
              appLocalizations.prices_products_list_length_many_pages(
            _pageSize,
            result.total!,
          );
          children.insert(
            0,
            SmoothCard(child: ListTile(title: Text(title))),
          );
          // so that the last content gets not hidden by the FAB
          children.add(
            const SizedBox(height: 2 * MINIMUM_TOUCH_SIZE),
          );
          return ListView(
            children: children,
          );
        },
      ),
    );
  }

  static Future<MaybeError<GetPriceProductsResult>> _showTopProducts() async =>
      OpenPricesAPIClient.getPriceProducts(
        GetPriceProductsParameters()
          ..orderBy = <OrderBy<GetPriceProductsOrderField>>[
            const OrderBy<GetPriceProductsOrderField>(
              field: GetPriceProductsOrderField.priceCount,
              ascending: false,
            ),
          ]
          ..pageSize = _pageSize
          ..pageNumber = 1,
        uriHelper: ProductQuery.uriPricesHelper,
      );
}
