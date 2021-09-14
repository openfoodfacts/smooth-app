import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/data_cards/image_upload_card.dart';
import 'package:smooth_app/cards/data_cards/score_attribute_card.dart';
import 'package:smooth_app/cards/expandables/attribute_list_expandable.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/database/dao_product_extra.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/attributes_card_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage(this.product);

  final Product product;

  @override
  State<NewProductPage> createState() => _ProductPageState();
}

enum ProductPageMenuItem { WEB, REFRESH }

class _ProductPageState extends State<NewProductPage> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _updateHistory(context);
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SmoothTheme.COLOR_PRODUCT_PAGE_BACKGROUND,
      appBar: AppBar(
        title: Text(_getProductName(appLocalizations)),
        actions: <Widget>[
          PopupMenuButton<ProductPageMenuItem>(
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<ProductPageMenuItem>>[
              PopupMenuItem<ProductPageMenuItem>(
                value: ProductPageMenuItem.WEB,
                child: Text(appLocalizations.label_web),
              ),
              PopupMenuItem<ProductPageMenuItem>(
                value: ProductPageMenuItem.REFRESH,
                child: Text(appLocalizations.label_refresh),
              ),
            ],
            onSelected: (final ProductPageMenuItem value) async {
              switch (value) {
                case ProductPageMenuItem.WEB:
                  LaunchUrlHelper.launchURL(
                      'https://openfoodfacts.org/product/${_product.barcode}/',
                      false);
                  break;
                case ProductPageMenuItem.REFRESH:
                  _refreshProduct(localDatabase, context);
                  break;
                default:
                  throw UnimplementedError(
                      "$value Popup item isn't handled yet.");
              }
            },
          ),
        ],
      ),
      body: _buildProductBody(context),
    );
  }

  Future<void> _refreshProduct(
      LocalDatabase localDatabase, BuildContext context) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ProductDialogHelper productDialogHelper = ProductDialogHelper(
      barcode: _product.barcode!,
      context: context,
      localDatabase: localDatabase,
      refresh: true,
    );
    final Product? product =
        await productDialogHelper.openUniqueProductSearch();
    if (product == null) {
      productDialogHelper.openProductNotFoundDialog();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appLocalizations.product_refreshed),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _product = product;
    });
    await _updateHistory(context);
  }

  Future<void> _updateHistory(final BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductExtra(localDatabase).putLastSeen(widget.product);
    localDatabase.notifyListeners();
  }

  Widget _buildProductImagesCarousel(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final List<ImageUploadCard> carouselItems = <ImageUploadCard>[
      ImageUploadCard(
        product: _product,
        imageField: ImageField.FRONT,
        imageUrl: _product.imageFrontUrl,
        title: appLocalizations.product,
        buttonText: appLocalizations.front_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.INGREDIENTS,
        imageUrl: _product.imageIngredientsUrl,
        title: appLocalizations.ingredients,
        buttonText: appLocalizations.ingredients_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.NUTRITION,
        imageUrl: _product.imageNutritionUrl,
        title: appLocalizations.nutrition,
        buttonText: appLocalizations.nutrition_facts_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.PACKAGING,
        imageUrl: _product.imagePackagingUrl,
        title: appLocalizations.packaging_information,
        buttonText: appLocalizations.packaging_information_photo,
      ),
      ImageUploadCard(
        product: _product,
        imageField: ImageField.OTHER,
        imageUrl: null,
        title: appLocalizations.more_photos,
        buttonText: appLocalizations.more_photos,
      ),
    ];

    return SizedBox(
      height: 200,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: carouselItems
            .map(
              (ImageUploadCard item) => Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                decoration: const BoxDecoration(color: Colors.black12),
                child: item,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildProductBody(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double iconHeight =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    final List<String> scoreAttributeIds = <String>[
      Attribute.ATTRIBUTE_NUTRISCORE,
      Attribute.ATTRIBUTE_ECOSCORE
    ];
    final List<Attribute> scoreAttributes =
        AttributeListExpandable.getPopulatedAttributes(
            _product, scoreAttributeIds);

    List<String> importantAttributeIds =
        productPreferences.getOrderedImportantAttributeIds();
    importantAttributeIds = importantAttributeIds
        .where((String attributeId) => !scoreAttributeIds.contains(attributeId))
        .toList();
    final List<Attribute> importantAttributes =
        AttributeListExpandable.getPopulatedAttributes(
            _product, importantAttributeIds);
    final Widget attributesContainer = Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: Column(children: <Widget>[
          Wrap(runSpacing: 16, children: <Widget>[
            for (final Attribute attribute in importantAttributes)
              getAttributeChip(attribute, screenSize) ?? Container(),
          ])
        ]));

    final List<Widget> listItems = <Widget>[];
    listItems.add(Align(
        heightFactor: 0.7,
        alignment: Alignment.topLeft,
        child: _buildProductImagesCarousel(context)));
    listItems.add(
      SmoothCard(
        padding: const EdgeInsets.only(
          right: 8.0,
          left: 8.0,
          top: 4.0,
          bottom: 20.0,
        ),
        insets: const EdgeInsets.all(12.0),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _getProductName(appLocalizations),
                  style: themeData.textTheme.headline4,
                ),
                subtitle:
                    Text(_product.brands ?? appLocalizations.unknownBrand),
                trailing: Text(
                  _product.quantity ?? '',
                  style: themeData.textTheme.headline3,
                ),
              )),
          for (final Attribute attribute in scoreAttributes)
            ScoreAttributeCard(attribute: attribute, iconHeight: iconHeight),
          attributesContainer
        ]),
      ),
    );
    return ListView(children: listItems);
  }

  Widget? getAttributeChip(Attribute attribute, Size screenSize) {
    final String? attributeDisplayTitle = getDisplayTitle(attribute);
    final Widget attributeIcon = getAttributeDisplayIcon(attribute);
    if (attributeDisplayTitle == null) {
      return null;
    }
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
          width: constraints.maxWidth / 2,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                attributeIcon,
                Expanded(
                    child: Text(
                  attributeDisplayTitle,
                ))
              ]));
    });
  }

  String _getProductName(final AppLocalizations appLocalizations) =>
      _product.productName ?? appLocalizations.unknownProductName;
}
