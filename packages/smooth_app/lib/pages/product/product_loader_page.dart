import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/fetched_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// A page to show when a [Product] is not in the database
/// This page shouldn't be opened directly, it's only for deep links
class ProductLoaderPage extends StatefulWidget {
  const ProductLoaderPage({
    required this.barcode,
    required this.mode,
    super.key,
  }) : assert(barcode != '');

  final String barcode;
  final ProductLoaderMode mode;

  @override
  State<ProductLoaderPage> createState() => _ProductLoaderPageState();
}

class _ProductLoaderPageState extends State<ProductLoaderPage> {
  _ProductLoaderState _state = _ProductLoaderState.loading;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    final AppNavigator navigator = AppNavigator.of(context);
    setState(() {
      _state = _ProductLoaderState.loading;
    });

    final FetchedProduct fetchedProduct = await ProductRefresher()
        .silentFetchAndRefresh(
          barcode: widget.barcode,
          localDatabase: context.read<LocalDatabase>(),
        );

    if (mounted) {
      if (fetchedProduct.product != null) {
        if (widget.mode == ProductLoaderMode.viewProduct) {
          navigator.pushReplacement(
            AppRoutes.PRODUCT(
              widget.barcode,
              heroTag: 'product_${widget.barcode}',
            ),
            extra: fetchedProduct.product,
          );
        } else if (widget.mode == ProductLoaderMode.editProduct) {
          navigator.pushReplacement(
            AppRoutes.PRODUCT_EDITOR(widget.barcode),
            extra: fetchedProduct.product,
          );
        }
        return;
      }
      if (fetchedProduct.status == FetchedProductStatus.internetNotFound) {
        setState(() {
          _state = _ProductLoaderState.productNotFound;
        });
        return;
      }
      setState(() {
        // TODO(monsieurtanuki): put more details from FetchedProduct?
        _state = _ProductLoaderState.serverError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    switch (_state) {
      case _ProductLoaderState.loading:
        child = const _ProductLoaderLoadingState();
        break;
      case _ProductLoaderState.productNotFound:
        child = _ProductLoaderNotFoundState(barcode: widget.barcode);
        break;
      case _ProductLoaderState.serverError:
        child = _ProductLoaderNetworkErrorState(onRetry: () => _loadProduct());
        break;
    }

    return Scaffold(body: Center(child: child));
  }
}

class _ProductLoaderLoadingState extends StatelessWidget {
  const _ProductLoaderLoadingState();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator.adaptive();
  }
}

class _ProductLoaderNotFoundState extends StatelessWidget {
  const _ProductLoaderNotFoundState({required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset('assets/misc/error.svg'),
          const SizedBox(height: VERY_LARGE_SPACE),
          Text(
            localizations.product_loader_not_found_title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: LARGE_SPACE),
          Text(
            localizations.product_loader_not_found_message(barcode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: VERY_LARGE_SPACE * 2),
          SmoothLargeButtonWithIcon(
            text: localizations.add_product_information_button_label,
            leadingIcon: const Icon(Icons.add),
            padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
            onPressed: () {
              AppNavigator.of(
                context,
              ).pushReplacement(AppRoutes.PRODUCT_CREATOR(barcode));
            },
          ),
        ],
      ),
    );
  }
}

class _ProductLoaderNetworkErrorState extends StatelessWidget {
  const _ProductLoaderNetworkErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset('assets/misc/error.svg'),
          const SizedBox(height: VERY_LARGE_SPACE),
          Text(
            localizations.product_loader_network_error_title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: LARGE_SPACE),
          Text(
            localizations.product_loader_network_error_message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: VERY_LARGE_SPACE * 2),
          SmoothLargeButtonWithIcon(
            text: localizations.retry_button_label,
            leadingIcon: const Icon(Icons.sync),
            padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

enum _ProductLoaderState { loading, productNotFound, serverError }

enum ProductLoaderMode { viewProduct, editProduct }
