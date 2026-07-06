part of '../price_add_product_action.dart';

class _PriceAddProductActionCategoryInput extends PriceAddProductAction {
  const _PriceAddProductActionCategoryInput();

  @override
  String label(AppLocalizations appLocalizations) =>
      appLocalizations.prices_category_enter;

  @override
  Widget icon(BuildContext context) => const icons.Ingredients();

  @override
  Future<void> execute(BuildContext context) async {
    final PriceMetaProduct? priceMetaProduct =
        await Navigator.push<PriceMetaProduct>(
          context,
          MaterialPageRoute<PriceMetaProduct>(
            builder: (BuildContext context) => const PriceCategoryInputPage(),
          ),
        );
    if (priceMetaProduct == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final PriceModel priceModel = Provider.of<PriceModel>(
      context,
      listen: false,
    );
    _addProductToList(priceModel, priceMetaProduct, context);
    priceModel.notifyListeners();
  }
}
