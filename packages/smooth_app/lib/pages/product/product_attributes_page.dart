import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/atrribute_first_row_helper.dart';
import 'package:smooth_app/pages/product/attribute_first_row_widget.dart';
import 'package:smooth_app/pages/product/common/product_app_bar.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ProductAttributesPage extends StatefulWidget {
  const ProductAttributesPage(this.product);

  final Product product;

  @override
  State<ProductAttributesPage> createState() => _ProductAttributesPageState();
}

class _ProductAttributesPageState extends State<ProductAttributesPage>
    with UpToDateMixin {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return SmoothScaffold(
      appBar: ProductAppBar(
        product: upToDateProduct,
        barcodeVisibleInAppbar: true,
      ),
      body: Scrollbar(
        controller: _controller,
        child: ListView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            AttributeItems(
              helper: SimpleInputPageCategoryHelper(),
              product: upToDateProduct,
            ),
            AttributeItems(
              helper: SimpleInputPageLabelHelper(),
              product: upToDateProduct,
            ),
            AttributeFirstRowWidget(
              helper:
                  AttributeFirstRowNutritionHelper(product: upToDateProduct),
              onTap: () async {
                if (!await ProductRefresher().checkIfLoggedIn(
                  context,
                  isLoggedInMandatory: true,
                )) {
                  return;
                }
                AnalyticsHelper.trackProductEdit(
                  AnalyticsEditEvents.nutrition_Facts,
                  upToDateProduct.barcode!,
                );

                if (!mounted) {
                  return;
                }

                await NutritionPageLoaded.showNutritionPage(
                  product: upToDateProduct,
                  isLoggedInMandatory: true,
                  context: context,
                );
              },
            ),
            AttributeFirstRowWidget(
              helper:
                  AttributeFirstRowIngredientsHelper(product: upToDateProduct),
              onTap: () async => ProductFieldOcrIngredientEditor().edit(
                context: context,
                product: upToDateProduct,
              ),
            ),
            AttributeItems(
              helper: SimpleInputPageCountryHelper(),
              product: upToDateProduct,
            ),
            AttributeItems(
              helper: SimpleInputPageStoreHelper(),
              product: upToDateProduct,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AttributeItems extends StatefulWidget {
  const AttributeItems({required this.helper, required this.product});
  final AbstractSimpleInputPageHelper helper;
  final Product product;

  @override
  State<AttributeItems> createState() => _AttributeItemsState();
}

class _AttributeItemsState extends State<AttributeItems> {
  @override
  Widget build(BuildContext context) {
    return AttributeFirstRowWidget(
      helper: AttributeFirstRowSimpleHelper(helper: widget.helper),
      onTap: () async => ProductFieldSimpleEditor(widget.helper).edit(
        context: context,
        product: widget.product,
      ),
    );
  }
}
