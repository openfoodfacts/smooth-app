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
                height: MediaQuery.of(context).size.height * .5,
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
  ) =>
      ProductQueryConfiguration(
        barcode,
        fields: ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        version: ProductQuery.productQueryVersion,
      );

  /// Returns the standard configuration for several barcodes product query.
  ProductSearchQueryConfiguration getBarcodeListQueryConfiguration(
    final List<String> barcodes, {
    final List<ProductField>? fields,
  }) =>
      ProductSearchQueryConfiguration(
        fields: fields ?? ProductQuery.fields,
        language: ProductQuery.getLanguage(),
        country: ProductQuery.getCountry(),
        parametersList: <Parameter>[
          BarcodeParameter.list(barcodes),
          PageSize(size: barcodes.length),
        ],
        version: ProductQuery.productQueryVersion,
      );

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// Silent version.
  Future<FetchedProduct> silentFetchAndRefresh({
    required final String barcode,
    required final LocalDatabase localDatabase,
  }) async =>
      _fetchAndRefresh(localDatabase, barcode);

  /// Fetches the products from the server and refreshes the local database.
  ///
  /// Silent version.
  Future<void> silentFetchAndRefreshList({
    required final List<String> barcodes,
    required final LocalDatabase localDatabase,
  }) async =>
      _fetchAndRefreshList(localDatabase, barcodes);

  /// Fetches the product from the server and refreshes the local database.
  ///
  /// With a waiting dialog.
  /// Returns true if successful.
  Future<bool> fetchAndRefresh({
    required final String barcode,
    required final State<StatefulWidget> widget,
  }) async {
    final LocalDatabase localDatabase = widget.context.read<LocalDatabase>();
    final AppLocalizations appLocalizations =
        AppLocalizations.of(widget.context);
    final FetchedProduct? fetchAndRefreshed =
        await LoadingDialog.run<FetchedProduct>(
      future: _fetchAndRefresh(localDatabase, barcode),
      context: widget.context,
      title: appLocalizations.refreshing_product,
    );
    if (fetchAndRefreshed == null) {
      // the user probably cancelled
      return false;
    }
    if (fetchAndRefreshed.product == null) {
      if (widget.mounted) {
        String getTitle(final FetchedProduct fetchedProduct) {
          switch (fetchAndRefreshed.status) {
            case FetchedProductStatus.ok:
              return 'Not supposed to happen...';
            case FetchedProductStatus.userCancelled:
              return 'Not supposed to happen either...';
            case FetchedProductStatus.internetNotFound:
              return appLocalizations.product_refresher_internet_not_found;
            case FetchedProductStatus.internetError:
              if (fetchAndRefreshed.connectivityResult ==
                  ConnectivityResult.none) {
                return appLocalizations
                    .product_refresher_internet_not_connected;
              }
              if (fetchAndRefreshed.failedPingedHost != null) {
                return appLocalizations.product_refresher_internet_no_ping(
                    fetchAndRefreshed.failedPingedHost);
              }
              return appLocalizations.product_refresher_internet_no_ping(
                  fetchAndRefreshed.exceptionString);
          }
        }

        await LoadingDialog.error(
          context: widget.context,
          title: getTitle(fetchAndRefreshed),
        );
      }
      return false;
    }
    if (widget.mounted) {
      ScaffoldMessenger.of(widget.context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.product_refreshed),
          duration: SnackBarDuration.short,
        ),
      );
    }
    return true;
  }

  Future<FetchedProduct> _fetchAndRefresh(
    final LocalDatabase localDatabase,
    final String barcode,
  ) async {
    try {
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        getBarcodeQueryConfiguration(barcode),
      );
      if (result.product != null) {
        await DaoProduct(localDatabase).put(result.product!);
        localDatabase.upToDate.setLatestDownloadedProduct(result.product!);
        localDatabase.notifyListeners();
        return FetchedProduct.found(result.product!);
      }
      return const FetchedProduct.internetNotFound();
    } catch (e) {
      Logs.e('Refresh from server error', ex: e);
      final ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return FetchedProduct.error(
          exceptionString: e.toString(),
          connectivityResult: connectivityResult,
        );
      }
      // TODO(monsieurtanuki): make things cleaner with off-dart
      final String host =
          OpenFoodAPIConfiguration.globalQueryType == QueryType.PROD
              ? OpenFoodAPIConfiguration.uriProdHost
              : OpenFoodAPIConfiguration.uriTestHost;
      final PingData result = await Ping(host, count: 1).stream.first;
      return FetchedProduct.error(
        exceptionString: e.toString(),
        connectivityResult: connectivityResult,
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
  ) async {
    try {
      final SearchResult searchResult = await OpenFoodAPIClient.searchProducts(
        ProductQuery.getUser(),
        getBarcodeListQueryConfiguration(barcodes),
      );
      if (searchResult.products == null) {
        return null;
      }
      await DaoProduct(localDatabase).putAll(searchResult.products!);
      localDatabase.upToDate
          .setLatestDownloadedProducts(searchResult.products!);
      localDatabase.notifyListeners();
      return searchResult.products!.length;
    } catch (e) {
      Logs.e('Refresh from server error', ex: e);
      return null;
    }
  }
}
