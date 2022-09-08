import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/model/parameter/BarcodeParameter.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/query/product_query.dart';

class OfflineDataPage extends StatefulWidget {
  const OfflineDataPage({Key? key}) : super(key: key);

  @override
  State<OfflineDataPage> createState() => _OfflineDataPageState();
}

Future<int> updateLocalDatabaseFromServer(BuildContext context) async {
  final LocalDatabase localDatabase = context.read<LocalDatabase>();
  final DaoProduct daoProduct = DaoProduct(localDatabase);
  final List<String> barcodes = await daoProduct.getAllKeys();
  final List<String> productsWithoutKnowledgePanel = <String>[];
  final List<String> completeProducts = <String>[];
// We seperate the products into two lists, one for products that have a knowledge panel
// and one for products that don't have a knowledge panel
  for (int i = 0; i < barcodes.length; i++) {
    final Product? productFromDb = await daoProduct.get(barcodes[i]);
    if (productFromDb != null && productFromDb.knowledgePanels == null) {
      productsWithoutKnowledgePanel.add(barcodes[i]);
    } else {
      completeProducts.add(barcodes[i]);
    }
  }
  final List<ProductField> fieldsForCompleteProducts = ProductQuery.fields;
  final List<ProductField> fieldsForProductsWithoutKnowledgePanel =
      ProductQuery.fields;
  fieldsForProductsWithoutKnowledgePanel.remove(ProductField.KNOWLEDGE_PANELS);
// Config for the products that don't have a knowledge panel
  final ProductSearchQueryConfiguration productSearchQueryConfiguration =
      ProductSearchQueryConfiguration(
    language: ProductQuery.getLanguage(),
    country: ProductQuery.getCountry(),
    fields: fieldsForProductsWithoutKnowledgePanel,
    parametersList: <Parameter>[
      BarcodeParameter.list(productsWithoutKnowledgePanel),
    ],
  );

  final SearchResult result = await OpenFoodAPIClient.searchProducts(
    ProductQuery.getUser(),
    productSearchQueryConfiguration,
  );
  if (result.products != null) {
    daoProduct.putAll(result.products!);
  }

// Config for the complete products
  final ProductSearchQueryConfiguration
      productSearchQueryConfigurationForFullProducts =
      ProductSearchQueryConfiguration(
    language: ProductQuery.getLanguage(),
    country: ProductQuery.getCountry(),
    fields: fieldsForCompleteProducts,
    parametersList: <Parameter>[
      BarcodeParameter.list(completeProducts),
    ],
  );

  final SearchResult resultForFullProducts =
      await OpenFoodAPIClient.searchProducts(
    ProductQuery.getUser(),
    productSearchQueryConfigurationForFullProducts,
  );
  if (resultForFullProducts.products != null) {
    daoProduct.putAll(resultForFullProducts.products!);
  }
  return barcodes.length;
}

class _OfflineDataPageState extends State<OfflineDataPage> {
  @override
  Widget build(BuildContext context) {
    const String headerAsset = 'assets/preferences/main.svg';
    const Color headerColor = Color(0xFFEBF1FF);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundHeight = MediaQuery.of(context).size.height * .20;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Data'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          children: <Widget>[
            Container(
              color: dark ? null : headerColor,
              padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
              child: SvgPicture.asset(headerAsset, height: backgroundHeight),
            ),
            _buildStatsWidget(context, daoProduct),
            _buildListTile(
              context,
              title: 'Update Offline Product Data',
              subtitle:
                  'Update the local product database with the latest data from server',
              trailing: const Icon(Icons.refresh),
              onTap: () async {
                final int newlyAddedProducts = await LoadingDialog.run<int>(
                      title: 'Downloading data\nThis may take a while',
                      context: context,
                      future: updateLocalDatabaseFromServer(context),
                    ) ??
                    0;
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$newlyAddedProducts products updated',
                      ),
                      duration: SnackBarDuration.brief,
                    ),
                  );
                }
              },
            ),
            _buildListTile(
              context,
              title: 'Clear Offline Product Data',
              subtitle:
                  'Clear all local product data from your app to free up space',
              trailing: const Icon(Icons.delete),
              onTap: () async {
                final int totalProductsDeleted = await daoProduct.deleteAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$totalProductsDeleted products deleted'),
                      duration: SnackBarDuration.brief,
                    ),
                  );
                }
                setState(() {});
              },
            ),
            _buildListTile(
              context,
              title: 'Know More',
              subtitle: 'Click to know more about offline data',
              trailing: const Icon(Icons.info),
              // ignore: avoid_returning_null_for_void
              onTap: () => null,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStatsWidget(BuildContext context, DaoProduct daoProduct) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
    child: ListTile(
      title: const Text('Offline Product Data'),
      subtitle: FutureBuilder<int>(
        future: daoProduct.getTotalNoOfProducts(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return Text(
                '${snapshot.data} products available for immediate scaning');
          } else {
            return const Text('0 products available for immediate scaning');
          }
        },
      ),
      trailing: FutureBuilder<double>(
        future: daoProduct.getTotalSizeInMB(),
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            return Text('${snapshot.data} MB');
          } else {
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    ),
  );
}

Widget _buildListTile(
  BuildContext context, {
  required String title,
  required String subtitle,
  required Widget trailing,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
    child: ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    ),
  );
}
