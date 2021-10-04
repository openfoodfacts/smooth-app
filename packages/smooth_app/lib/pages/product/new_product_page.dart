import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/model/AttributeGroup.dart';
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
import 'package:smooth_app/helpers/product_compatibility_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage(this.product);

  final Product product;

  @override
  State<NewProductPage> createState() => _ProductPageState();
}

enum ProductPageMenuItem { WEB, REFRESH }

const List<String> _SCORE_ATTRIBUTE_IDS = <String>[
  Attribute.ATTRIBUTE_NUTRISCORE,
  Attribute.ATTRIBUTE_ECOSCORE
];

const List<String> _ATTRIBUTE_GROUP_ORDER = <String>[
  AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS,
  AttributeGroup.ATTRIBUTE_GROUP_INGREDIENT_ANALYSIS,
  AttributeGroup.ATTRIBUTE_GROUP_PROCESSING,
  AttributeGroup.ATTRIBUTE_GROUP_NUTRITIONAL_QUALITY,
  AttributeGroup.ATTRIBUTE_GROUP_LABELS,
];

const Widget _EMPTY_WIDGET = SizedBox.shrink();

class _ProductPageState extends State<NewProductPage> {
  late Product _product;
  late ProductPreferences _productPreferences;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _updateLocalDatabaseWithProductHistory(context, _product);
  }

  @override
  Widget build(BuildContext context) {
    // All watchers defined here:
    _productPreferences = context.watch<ProductPreferences>();
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final MaterialColor materialColor =
        SmoothTheme.getMaterialColor(themeProvider);
    return Scaffold(
      backgroundColor: SmoothTheme.getColor(
        colorScheme,
        materialColor,
        ColorDestination.SURFACE_BACKGROUND,
      ),
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
                  _refreshProduct(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: _buildProductBody(context),
    );
  }

  Future<void> _refreshProduct(BuildContext context) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
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
    await _updateLocalDatabaseWithProductHistory(context, _product);
  }

  Future<void> _updateLocalDatabaseWithProductHistory(
      BuildContext context, Product product) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    await DaoProductExtra(localDatabase).putLastSeen(product);
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
    final Size screenSize = MediaQuery.of(context).size;
    final double iconHeight =
        screenSize.width / 10; // TODO(monsieurtanuki): target size?
    final List<Attribute> scoreAttributes =
        AttributeListExpandable.getPopulatedAttributes(
            _product, _SCORE_ATTRIBUTE_IDS);

    final List<AttributeGroup> attributeGroupsToBeRendered =
        _getAttributeGroupsToBeRendered();
    final Widget attributesContainer = Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(children: <Widget>[
          for (final AttributeGroup group in attributeGroupsToBeRendered)
            _buildAttributeGroup(
              context,
              group,
              group == attributeGroupsToBeRendered.first,
            ),
        ]));

    final List<Widget> listItems = <Widget>[];
    listItems.add(Align(
      heightFactor: 0.7,
      alignment: Alignment.topLeft,
      child: _buildProductImagesCarousel(context),
    ));
    listItems.add(
      SmoothCard(
        margin: const EdgeInsets.only(
          right: 8.0,
          left: 8.0,
          top: 4.0,
          bottom: 20.0,
        ),
        padding: EdgeInsets.zero,
        header: _buildProductCompatibilityHeader(
          context,
          _productPreferences,
          _product,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(children: <Widget>[
            _buildProductTitleTile(context),
            for (final Attribute attribute in scoreAttributes)
              ScoreAttributeCard(
                attribute: attribute,
                iconHeight: iconHeight,
              ),
            attributesContainer,
          ]),
        ),
      ),
    );
    return ListView(children: listItems);
  }

  List<AttributeGroup> _getAttributeGroupsToBeRendered() {
    final List<AttributeGroup> attributeGroupsToBeRendered = <AttributeGroup>[];
    for (final String groupId in _ATTRIBUTE_GROUP_ORDER) {
      final Iterable<AttributeGroup> groupIterable = _product.attributeGroups!
          .where((AttributeGroup group) => group.id == groupId);
      if (groupIterable.isEmpty) {
        continue;
      }
      final AttributeGroup group = groupIterable.single;

      final bool containsImportantAttributes = group.attributes!.any(
          (Attribute attribute) =>
              _productPreferences.isAttributeImportant(attribute.id!) == true);
      if (containsImportantAttributes) {
        attributeGroupsToBeRendered.add(group);
      }
    }
    return attributeGroupsToBeRendered;
  }

  Widget _buildProductCompatibilityHeader(
    BuildContext context,
    ProductPreferences productPreferences,
    Product product,
  ) {
    final ProductCompatibility compatibility =
        getProductCompatibility(productPreferences, product);
    // NOTE: This is temporary and will be updated once the feature is supported
    // by the server.
    return Container(
      decoration: BoxDecoration(
        color: getProductCompatibilityHeaderBackgroundColor(compatibility),
        // Ensure that the header has the same circular radius as the SmoothCard.
        borderRadius: const BorderRadius.only(
          topLeft: SmoothCard.CIRCULAR_RADIUS,
          topRight: SmoothCard.CIRCULAR_RADIUS,
        ),
      ),
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          getProductCompatibilityHeaderTextWidget(
            context,
            compatibility,
          ),
          style:
              Theme.of(context).textTheme.subtitle1!.apply(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductTitleTile(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _getProductName(appLocalizations),
          style: themeData.textTheme.headline4,
        ),
        subtitle: Text(_product.brands ?? appLocalizations.unknownBrand),
        trailing: Text(
          _product.quantity ?? '',
          style: themeData.textTheme.headline3,
        ),
      ),
    );
  }

  /// Builds an AttributeGroup, if [isFirstGroup] is true the group doesn't get
  /// a divider header.
  Widget _buildAttributeGroup(
    BuildContext context,
    AttributeGroup group,
    bool isFirstGroup,
  ) {
    final List<Widget> attributeChips = <Widget>[];
    for (final Attribute attribute in group.attributes!) {
      final Widget? attributeChip = _buildAttributeChipForValidAttributes(
        attribute: attribute,
        returnNullIfStatusUnknown:
            group.id == AttributeGroup.ATTRIBUTE_GROUP_LABELS,
      );
      if (attributeChip != null) {
        attributeChips.add(attributeChip);
      }
    }
    if (attributeChips.isEmpty) {
      return _EMPTY_WIDGET;
    }
    return Column(
      children: <Widget>[
        _buildAttributeGroupHeader(context, group, isFirstGroup),
        Container(
          alignment: Alignment.topLeft,
          child: Wrap(
            runSpacing: 16,
            children: attributeChips,
          ),
        ),
      ],
    );
  }

  /// The attribute group header can either be group name or a divider depending
  /// upon the type of the group.
  Widget _buildAttributeGroupHeader(
    BuildContext context,
    AttributeGroup group,
    bool isFirstGroup,
  ) {
    if (group.id == AttributeGroup.ATTRIBUTE_GROUP_ALLERGENS) {
      return Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Text(
          group.name!,
          style:
              Theme.of(context).textTheme.bodyText2!.apply(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isFirstGroup
          ? _EMPTY_WIDGET
          : const Divider(
              color: Colors.black12,
            ),
    );
  }

  Widget? _buildAttributeChipForValidAttributes({
    required Attribute attribute,
    required bool returnNullIfStatusUnknown,
  }) {
    if (attribute.id == null || _SCORE_ATTRIBUTE_IDS.contains(attribute.id)) {
      // Score Attribute Ids have already been rendered.
      return null;
    }
    if (_productPreferences.isAttributeImportant(attribute.id!) != true) {
      // Not an important attribute.
      return null;
    }
    if (returnNullIfStatusUnknown &&
        attribute.status == Attribute.STATUS_UNKNOWN) {
      return null;
    }
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
                )),
              ]));
    });
  }

  String _getProductName(final AppLocalizations appLocalizations) =>
      _product.productName ?? appLocalizations.unknownProductName;
}
