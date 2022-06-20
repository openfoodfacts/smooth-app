import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/ProductListQueryConfiguration.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/preferences/user_preferences_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class OfflineDataPage extends StatefulWidget {
  const OfflineDataPage();
  @override
  State<OfflineDataPage> createState() => _OfflineDataPageState();
}

int _length = 0;
double _size = 0;

// TODO(ashaman999): update all the applocalizations
class _OfflineDataPageState extends State<OfflineDataPage> {
  Future<void> _refreshDetails(DaoProduct daoProduct) async {
    _length = await daoProduct.getLength();
    _size = await daoProduct.getSize();
    setState(() {});
  }

  Future<String> _refreshLocalDatabase(DaoProduct daoproduct) async {
    final List<String> barcodes = await daoproduct.getAllKeys();
    if (barcodes.isEmpty) {
      return 'List is Empty,Nothing to Refresh';
    }
    try {
      final User user = ProductQuery.getUser();
      // TODO(ashaman999): find a better way to do this
      //Found that the max number of the barcodes i can query is 24
      final List<Product> productList = <Product>[];
      List<String> chunks = <String>[];
      for (int i = 0; i < barcodes.length; i += 24) {
        if (i + 24 < barcodes.length) {
          chunks = barcodes.sublist(i, i + 24);
        } else {
          chunks = barcodes.sublist(i, barcodes.length);
        }
        final ProductListQueryConfiguration configuration =
            ProductListQueryConfiguration(
          chunks,
          fields: ProductQuery.fields,
          language: ProductQuery.getLanguage(),
          country: ProductQuery.getCountry(),
        );
        final SearchResult products =
            await OpenFoodAPIClient.getProductList(user, configuration);
        productList.addAll(products.products!);
        chunks.clear();
      }
      await daoproduct.putAll(productList);
      return 'Refreshed ${productList.length} products';
    } catch (e) {
      return 'Refresh failed: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final DaoProduct daoProduct = DaoProduct(context.watch<LocalDatabase>());
    final DaoProductList daoProductList =
        DaoProductList(context.watch<LocalDatabase>());
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    const double titleHeightInExpandedMode = 50;
    final double backgroundHeight = mediaQueryData.size.height * .20;
    final Color? foregroundColor = dark ? null : Colors.black;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // just reload the screen

            await _refreshDetails(daoProduct);
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                snap: false,
                floating: false,
                stretch: true,
                backgroundColor: dark ? null : Colors.white,
                expandedHeight: backgroundHeight + titleHeightInExpandedMode,
                foregroundColor: foregroundColor,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Offline Mode',
                    style: TextStyle(color: foregroundColor),
                  ),
                  background: Padding(
                    padding: const EdgeInsets.only(
                        bottom: titleHeightInExpandedMode),
                    child: SvgPicture.asset(
                      // TODO(ashaman999): add a proper header image replacing this
                      'assets/preferences/main.svg',
                      height: backgroundHeight,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    UserPreferencesListTile(
                      title: const Text(
                        'Offline Product Data',
                      ),
                      subtitle: FutureBuilder<int>(
                        future: daoProduct.getLength(),
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data} products available for immediate scanning',
                            );
                          } else {
                            return Text(
                                '$_length products available for immediate scanning');
                          }
                        },
                      ),
                      trailing: FutureBuilder<double>(
                        future: daoProduct.getSize(),
                        builder: (BuildContext context,
                            AsyncSnapshot<double> snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data} MB',
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                    UserPreferencesListTile(
                      trailing: const Icon(Icons.refresh),
                      onTap: () async {
                        final String status = await LoadingDialog.run<String>(
                              context: context,
                              future: _refreshLocalDatabase(daoProduct),
                              title: 'Refreshing \n This may take a while',
                              dismissible: true,
                            ) ??
                            'Refresh Cancelled';
                        // TODO(ashaman999): dapproductlist.updateTimestamp();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(status),
                          ),
                        );
                      },
                      title: const Text(
                        'Update Offline Data',
                      ),
                      subtitle: const Text(
                        'Update the databse with the latest data from the server',
                      ),
                    ),
                    UserPreferencesListTile(
                      trailing: const Icon(Icons.delete),
                      onTap: () async {
                        await daoProductList.clearAll();
                        final int noOdDeletedProducts =
                            await daoProduct.clearAll();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '$noOdDeletedProducts products deleted, freed $_size Mb'),
                          ),
                        );
                        await _refreshDetails(daoProduct);
                      },
                      title: const Text(
                        'Clear Offline Data',
                      ),
                      subtitle: const Text(
                        'Clear All Offline Data and Free up space',
                      ),
                    ),
                    UserPreferencesListTile(
                      trailing: const Icon(Icons.info),
                      title: const Text(
                        'Know More ',
                      ),
                      subtitle: const Text(
                        'Click to know more about the offline mode',
                      ),
                      onTap: () {
                        // TODO(ashaman999): refrence the acutal link
                        // Or maybe show something as an alert dialog
                        launchUrl(
                          Uri.parse('https://openfoodfacts.org/'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
