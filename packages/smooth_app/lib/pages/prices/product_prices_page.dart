import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the latest prices for a given product.
class ProductPricesPage extends StatefulWidget {
  const ProductPricesPage(this.product);

  final Product product;

  @override
  State<ProductPricesPage> createState() => _ProductPricesPageState();
}

class _ProductPricesPageState extends State<ProductPricesPage>
    with UpToDateMixin {
  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          getProductNameAndBrands(upToDateProduct, appLocalizations),
          maxLines: 2,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: appLocalizations.prices_app_button,
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final UriProductHelper uriProductHelper =
                  ProductQuery.uriProductHelper;
              final Uri uri = Uri(
                scheme: uriProductHelper.scheme,
                host: uriProductHelper.getHost('prices'),
                path: 'app/products/${upToDateProduct.barcode!}',
              );
              return LaunchUrlHelper.launchURL(uri.toString());
            },
          ),
        ],
      ),
      body: ProductPricesList(barcode),
    );
  }
}
