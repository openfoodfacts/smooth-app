import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/svg_icon.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/attribute_first_row_widget.dart';
import 'package:smooth_app/pages/product/common/product_app_bar.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const String _SplitChar = ':';

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
            ProductAttributeNutritionFacts(
              product: upToDateProduct,
            ),
            ProductAtrributeIngredients(
              product: upToDateProduct,
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

class ProductAttributeNutritionFacts extends StatefulWidget {
  const ProductAttributeNutritionFacts({required this.product});

  final Product product;
  @override
  State<ProductAttributeNutritionFacts> createState() =>
      _ProductAttributeNutritionFactsState();
}

class _ProductAttributeNutritionFactsState
    extends State<ProductAttributeNutritionFacts> {
  List<String> _allNutrients = <String>[];

  @override
  void initState() {
    super.initState();
    _allNutrients.clear();

    widget.product.knowledgePanels?.panelIdToPanelMap['nutrition_facts_table']
        ?.elements
        ?.forEach((KnowledgePanelElement element) {
      element.tableElement?.rows.forEach((KnowledgePanelTableRowElement row) {
        final StringBuffer buffer = StringBuffer('');
        for (int i = 0; i < row.values.length - 1; i++) {
          buffer.write(row.values[i].text);
          if (i == 0) {
            buffer.write(_SplitChar);
          }
        }

        String nutrient = buffer.toString();

        if (nutrient.contains('<br>')) {
          final List<String> split = nutrient.split('<br>');
          nutrient = '${split[0]}${split[1]}';
        }
        _allNutrients.add(nutrient);
      });
    });

    _allNutrients = _allNutrients.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return AttributeFirstRowWidget(
      allTerms: _allNutrients,
      leading: const SvgIcon(
        'assets/cacheTintable/scale-balance.svg',
        dontAddColor: true,
      ),
      title: appLocalizations.nutrition_page_title,
      hasTrailing: true,
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(
          context,
          isLoggedInMandatory: true,
        )) {
          return;
        }
        AnalyticsHelper.trackProductEdit(
          AnalyticsEditEvents.nutrition_Facts,
          widget.product.barcode!,
        );

        if (!mounted) {
          return;
        }

        await NutritionPageLoaded.showNutritionPage(
          product: widget.product,
          isLoggedInMandatory: true,
          context: context,
        );
      },
    );
  }
}

class ProductAtrributeIngredients extends StatefulWidget {
  const ProductAtrributeIngredients({super.key, required this.product});

  final Product product;

  @override
  State<ProductAtrributeIngredients> createState() =>
      _ProductAtrributeIngredientsState();
}

class _ProductAtrributeIngredientsState
    extends State<ProductAtrributeIngredients> {
  final List<String> _allIngredients = <String>[];

  @override
  void initState() {
    _allIngredients.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.product.ingredients?.forEach((Ingredient element) {
      if (element.text != null) {
        _allIngredients.add(element.text!);
      }
    });
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return AttributeFirstRowWidget(
      allTerms: _allIngredients,
      leading: const SvgIcon('assets/cacheTintable/ingredients.svg',
          dontAddColor: true),
      title: appLocalizations.ingredients,
      onTap: () async => ProductFieldOcrIngredientEditor().edit(
        context: context,
        product: widget.product,
      ),
    );
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
  late final List<String> _localTerms;

  @override
  void initState() {
    super.initState();
    widget.helper.reInit(widget.product);
    _localTerms = List<String>.of(widget.helper.terms);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return AttributeFirstRowWidget(
      allTerms: _localTerms,
      leading: widget.helper.getIcon(),
      title: widget.helper.getTitle(appLocalizations),
      onTap: () async => ProductFieldSimpleEditor(widget.helper).edit(
        context: context,
        product: widget.product,
      ),
    );
  }
}
