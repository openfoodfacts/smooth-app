import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/personalized_search/matched_product_v2.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_compatibility_helper.dart';

class PersonalizedRankingPage extends StatefulWidget {
  const PersonalizedRankingPage({
    required this.products,
    required this.title,
  });

  final List<Product> products;
  final String title;

  @override
  State<PersonalizedRankingPage> createState() =>
      _PersonalizedRankingPageState();
}

class _PersonalizedRankingPageState extends State<PersonalizedRankingPage>
    with TraceableClientMixin {
  @override
  String get traceName =>
      'Opened personalized ranking page with ${widget.products.length} products'; // optional

  @override
  String get traceTitle => 'personalized_ranking_page';

  static const int _backgroundAlpha = 51;

  // TODO(monsieurtanuki): to be removed when we agree on a layout
  final bool _coloredBackground = false;
  final bool _withSubHeaders = true;
  final bool _coloredCard = true;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProductList daoProductList = DaoProductList(localDatabase);
    final List<MatchedProductV2> allProducts = MatchedProductV2.sort(
      widget.products,
      productPreferences,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    AnalyticsHelper.trackPersonalizedRanking();

    MatchedProductStatusV2? status;
    final List<_VirtualItem> list = <_VirtualItem>[];
    for (final MatchedProductV2 product in allProducts) {
      if (_withSubHeaders) {
        if (status == null || status != product.status) {
          status = product.status;
          list.add(_VirtualItem.status(status));
        }
      }
      list.add(_VirtualItem.product(product));
    }
    final bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.fade,
        ),
      ),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) => _buildItem(
          list[index],
          daoProductList,
          appLocalizations,
          darkMode,
        ),
      ),
    );
  }

  Widget _buildItem(
    final _VirtualItem item,
    final DaoProductList daoProductList,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) =>
      item.status != null
          ? _buildHeader(
              item.status!,
              appLocalizations,
              darkMode,
            )
          : _buildSmoothProductCard(
              item.product!,
              daoProductList,
              appLocalizations,
              darkMode,
            );

  Widget _buildHeader(
    final MatchedProductStatusV2 status,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) {
    final ProductCompatibilityHelper helper =
        ProductCompatibilityHelper.status(status);
    return Container(
      color: _coloredBackground
          ? helper
              .getHeaderBackgroundColor(darkMode)
              .withAlpha(_backgroundAlpha)
          : null,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: Text(
            helper.getHeaderText(appLocalizations),
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  color: _coloredBackground
                      ? helper.getHeaderForegroundColor(darkMode)
                      : null,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmoothProductCard(
    final MatchedProductV2 matchedProduct,
    final DaoProductList daoProductList,
    final AppLocalizations appLocalizations,
    final bool darkMode,
  ) =>
      Dismissible(
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.symmetric(vertical: 14),
          color: RED_COLOR,
          padding: const EdgeInsets.only(right: 30),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        key: Key(matchedProduct.product.barcode!),
        onDismissed: (final DismissDirection direction) async {
          final bool removed = widget.products.remove(matchedProduct.product);
          if (removed) {
            setState(() {});
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed
                    ? appLocalizations.product_removed_comparison
                    : appLocalizations.product_could_not_remove,
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          color: _coloredBackground
              ? _getBackgroundColor(matchedProduct.status, darkMode)
              : null,
          child: SmoothProductCardFound(
            heroTag: matchedProduct.product.barcode!,
            product: matchedProduct.product,
            elevation: 4.0,
            backgroundColor: _coloredCard
                ? _getBackgroundColor(matchedProduct.status, darkMode)
                : null,
          ),
        ),
      );

  Color? _getBackgroundColor(
    final MatchedProductStatusV2 status,
    final bool darkMode,
  ) =>
      ProductCompatibilityHelper.status(status)
          .getHeaderBackgroundColor(darkMode)
          .withAlpha(_backgroundAlpha);
}

/// Virtual item in the list: either a product or a status header
class _VirtualItem {
  const _VirtualItem.product(this.product) : status = null;
  const _VirtualItem.status(this.status) : product = null;
  final MatchedProductV2? product;
  final MatchedProductStatusV2? status;
}
