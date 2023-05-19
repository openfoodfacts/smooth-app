import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

class ProductLoaderPage extends StatefulWidget {
  const ProductLoaderPage({
    required this.barcode,
    Key? key,
  })  : assert(barcode != ''),
        super(key: key);

  final String barcode;

  @override
  State<ProductLoaderPage> createState() => _ProductLoaderPageState();
}

class _ProductLoaderPageState extends State<ProductLoaderPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    final AppNavigator navigator = AppNavigator.of(context);
    final Product? product = await ProductRefresher().silentFetchAndRefresh(
      barcode: widget.barcode,
      localDatabase: context.read<LocalDatabase>(),
    );

    if (product != null && mounted) {
      navigator.pushReplacement(
        AppRoutes.PRODUCT(widget.barcode),
        extra: product,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product?>(
        future: ProductRefresher().silentFetchAndRefresh(
          barcode: widget.barcode,
          localDatabase: context.read<LocalDatabase>(),
        ),
        builder: (BuildContext context, AsyncSnapshot<Product?> data) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}
