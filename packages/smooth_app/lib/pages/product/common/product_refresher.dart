import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/services/smooth_services.dart';

/// Refreshes a product on the BE then on the local database.
class ProductRefresher {
  /// Checks if the user is logged in and opens a "please log in" dialog if not.
  Future<bool> checkIfLoggedIn(
    final BuildContext context, {
    required bool isLoggedInMandatory,
  }) async {
    if (!isLoggedInMandatory) {
      return true;
    }
    if (ProductQuery.isLoggedIn()) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => SmoothAlertDialog(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SvgPicture.asset(
                'assets/onboarding/globe.svg',
                height: MediaQuery.sizeOf(context).height * .5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  appLocalizations.account_create_message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]),
        actionsAxis: Axis.vertical,
        positiveAction: SmoothActionButton(
          text: appLocalizations.join_us,
          onPressed: () async {
            Navigator.of(context).pop(); // remove dialog
            await Navigator.of(
              context,
              rootNavigator: true,
            ).push<dynamic>(
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const LoginPage(),
              ),
            );
          },
        ),
        negativeAction: SmoothActionButton(
          text: appLocalizations.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    return false;
  }

  /// Returns the standard configuration for barcode product query.
  ProductQueryConfiguration getBarcodeQueryConfiguration(
    final String barcode,
    final OpenFoodFactsLanguage language,
  ) =>
      ProductQueryConfiguration(
        barcode,
        fields: ProductQuery.fields,
        language: language,
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      );

  /// Returns the standard configuration for several barcodes product query.
  ProductSearchQueryConfiguration getBarcodeListQueryConfiguration(
    final List<String> barcodes,
    final OpenFoodFactsLanguage language, {
    final List<ProductField>? fields,
  }) =>
      ProductSearchQueryConfiguration(
        fields: fields ?? ProductQuery.fields,
        language: language,
        country: ProductQuery.getCountry(),
        parametersList: <Parameter>[
          BarcodeParameter.list(barcodes),
          PageSize(size: barcodes.length),
        ],
        version: ProductQuery.productQueryVersion,
      );

  /// Fetches the products from the server and refreshes the local database.
  ///
  /// Silent version.
  Future<void> silentFetchAndRefreshList({
    required final List<String> barcodes,
    required final LocalDatabase localDatabase,
    required final ProductType productType,
  }) async =>
      _fetchAndRefreshList(localDatabase, barcodes, productType);

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// With a waiting dialog.
  /// Returns true if successful.
  Future<bool> fetchAndRefresh({
    required final String barcode,
    required final BuildContext context,
  }) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FetchedProduct? fetchAndRefreshed =
        await LoadingDialog.run<FetchedProduct>(
      future: silentFetchAndRefresh(
        localDatabase: localDatabase,
        barcode: barcode,
      ),
      context: context,
      title: appLocalizations.refreshing_product,
    );
    if (fetchAndRefreshed == null) {
      // the user probably cancelled
      return false;
    }
    if (fetchAndRefreshed.product == null) {
      if (context.mounted) {
        await LoadingDialog.error(
          context: context,
          title: fetchAndRefreshed.getErrorTitle(appLocalizations),
        );
      }
      return false;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: SnackBarDuration.short,
        ),
      );
    }
    return true;
  }

  /// Returns the product type stored locally for that product.
  static Future<ProductType?> getCurrentProductType({
    required final LocalDatabase localDatabase,
    required final String barcode,
  }) async {
    final Product? localProduct = await DaoProduct(localDatabase).get(barcode);
    return localProduct?.productType;
  }

  /// Returns the list of types to use for that barcode.
  Future<List<ProductType>> getOrderedProductTypes({
    required final LocalDatabase localDatabase,
    required final String barcode,
  }) async {
    final List<ProductType> result = <ProductType>[];
    final ProductType? productType = await getCurrentProductType(
      localDatabase: localDatabase,
      barcode: barcode,
    );
    if (productType != null) {
      result.add(productType);
    }
    for (final ProductType value in ProductType.values) {
      if (!result.contains(value)) {
        result.add(value);
      }
    }
    return result;
  }

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// Silent version.
  Future<FetchedProduct> silentFetchAndRefresh({
    required final LocalDatabase localDatabase,
    required final String barcode,
  }) async {
    final List<ProductType> productTypes = await getOrderedProductTypes(
      localDatabase: localDatabase,
      barcode: barcode,
    );
    late UriProductHelper uriProductHelper;
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
    try {
      for (final ProductType productType in productTypes) {
        uriProductHelper = ProductQuery.getUriProductHelper(
          productType: productType,
        );
        final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
          getBarcodeQueryConfiguration(
            barcode,
            language,
          ),
          uriHelper: uriProductHelper,
          user: ProductQuery.getReadUser(),
        );
        if (result.product != null) {
          await DaoProduct(localDatabase).put(
            result.product!,
            language,
            productType: productType,
          );
          localDatabase.upToDate.setLatestDownloadedProduct(result.product!);
          return FetchedProduct.found(result.product!);
        }
      }
      return const FetchedProduct.internetNotFound();
    } catch (e) {
      Logs.e('Refresh from server error', ex: e);
      final ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return FetchedProduct.error(
          exceptionString: e.toString(),
          isConnected: false,
        );
      }
      final String host = uriProductHelper.host;
      final PingData result = await Ping(host, count: 1).stream.first;
      return FetchedProduct.error(
        exceptionString: e.toString(),
        isConnected: true,
        failedPingedHost: result.error == null ? null : host,
      );
    }
  }

  /// Gets up-to-date products from the server.
  ///
  /// Returns the number of products, or null if error.
  Future<int?> _fetchAndRefreshList(
    final LocalDatabase localDatabase,
    final List<String> barcodes,
    final ProductType productType,
  ) async {
    try {
      final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
      final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
        ProductQuery.getReadUser(),
        getBarcodeListQueryConfiguration(barcodes, language),
        uriHelper: ProductQuery.getUriProductHelper(productType: productType),
      );
      if (searchResult.products == null) {
        return null;
      }
      await DaoProduct(localDatabase).putAll(searchResult.products!, language);
      localDatabase.upToDate
          .setLatestDownloadedProducts(searchResult.products!);
      return searchResult.products!.length;
    } catch (e) {
      Logs.e('Refresh from server error', ex: e);
      return null;
    }
  }
}
