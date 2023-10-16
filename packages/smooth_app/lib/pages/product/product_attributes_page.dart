import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_app_bar.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product_page.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const String splitChar = ':';

class ProductAttributesPage extends StatefulWidget {
  const ProductAttributesPage(this.product);

  final Product product;

  @override
  State<ProductAttributesPage> createState() => _ProductAttributesPageState();
}

class _ProductAttributesPageState extends State<ProductAttributesPage>
    with UpToDateMixin {
  final ScrollController _controller = ScrollController();
  // OrderedNutrientsCache? cache;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    final String productName = getProductName(
      upToDateProduct,
      appLocalizations,
    );
    final String productBrand =
        getProductBrands(upToDateProduct, appLocalizations);

    return SmoothScaffold(
      appBar: ProductAppBar(
        barcode: barcode,
        barcodeVisibleInAppbar: true,
        productBrand: productBrand,
        productName: productName,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ProductRefresher().fetchAndRefresh(
          barcode: barcode,
          widget: this,
        ),
        child: Scrollbar(
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
              NutritionFacts(
                product: upToDateProduct,
              ),
              Ingredients(
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class NutritionFacts extends StatefulWidget {
  const NutritionFacts({required this.product});

  final Product product;
  @override
  State<NutritionFacts> createState() => _NutritionFactsState();
}

class _NutritionFactsState extends State<NutritionFacts> {
  List<String> allTerms = <String>[];

  @override
  Widget build(BuildContext context) {
    widget.product.knowledgePanels?.panelIdToPanelMap['nutrition_facts_table']
        ?.elements
        ?.forEach((KnowledgePanelElement element) {
      element.tableElement?.rows.forEach((KnowledgePanelTableRowElement row) {
        String term = '';
        for (int i = 0; i < row.values.length - 1; i++) {
          term += row.values[i].text;
          if (i == 0) {
            term += splitChar;
          }
        }
        if (term.contains('<br>')) {
          final List<String> split = term.split('<br>');
          term = '${split[0]}${split[1]}';
        }
        allTerms.add(term);
      });
    });

    allTerms = allTerms.toSet().toList();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _ListTile(
      allTerms: allTerms,
      leading: const SvgIcon('assets/cacheTintable/scale-balance.svg',
          dontAddColor: true),
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

class Ingredients extends StatefulWidget {
  const Ingredients({super.key, required this.product});

  final Product product;

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  List<String> allIngredients = <String>[];
  @override
  Widget build(BuildContext context) {
    widget.product.ingredients?.forEach((Ingredient element) {
      if (element.text != null) {
        allIngredients.add(element.text!);
      }
    });
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ListTile(
      allTerms: allIngredients,
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
    return _ListTile(
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

class _ListTile extends StatefulWidget {
  const _ListTile({
    required this.allTerms,
    required this.leading,
    required this.title,
    this.hasTrailing = false,
    required this.onTap,
  });

  final Widget? leading;
  final String title;
  final List<String> allTerms;
  final bool hasTrailing;
  final Function()? onTap;

  @override
  State<_ListTile> createState() => __ListTileState();
}

class __ListTileState extends State<_ListTile> {
  bool showAllTerms = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool hasMoreThanFourTerms = widget.allTerms.length > 4;
    final List<String> firstFourItems = widget.allTerms.take(4).toList();
    if (firstFourItems.isEmpty) {
      firstFourItems.add(appLocalizations.no_data_available);
    }
    return Column(
      children: <Widget>[
        ListTile(
          leading: widget.leading,
          title: Text(widget.title),
          trailing: const Icon(Icons.edit),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
            color: theme.primaryColor,
          ),
          iconColor: theme.primaryColor,
          tileColor: theme.colorScheme.secondary,
          onTap: widget.onTap,
        ),
        _termsList(
          firstFourItems,
          hasTrailing: widget.hasTrailing,
          borderFlag: !hasMoreThanFourTerms,
        ),
        Column(
          children: [
            if (hasMoreThanFourTerms) ...<Widget>[
              if (showAllTerms) ...<Widget>[
                _termsList(
                  widget.allTerms.skip(firstFourItems.length).toList(),
                  hasTrailing: widget.hasTrailing,
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: ExpansionTile(
                  onExpansionChanged: (bool value) => setState(() {
                    showAllTerms = value;
                  }),
                  title: const Text(
                    'Expand',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ]
          ],
        )
      ],
    );
  }

  Widget _termsList(List<String> terms,
      {bool hasTrailing = false, bool borderFlag = false}) {
    return ListView.builder(
        padding: const EdgeInsets.only(left: 100.0),
        itemCount: terms.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (_, int index) {
          return ListTile(
            key: UniqueKey(),
            title: Text(
              terms[index].split(splitChar)[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: (index == terms.length - 1 && borderFlag)
                ? null
                : const Border(
                    bottom: BorderSide(),
                  ),
            trailing:
                hasTrailing ? Text(terms[index].split(splitChar)[1]) : null,
          );
        });
  }
}
