// ignore_for_file: use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/add_other_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ingredients_page.dart';
import 'package:smooth_app/pages/product/edit_new_packagings.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/ocr_ingredients_helper.dart';
import 'package:smooth_app/pages/product/ocr_packaging_helper.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final ScrollController _controller = ScrollController();
  bool _barcodeVisibleInAppbar = false;
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;

  String get _barcode => _initialProduct.barcode!;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_barcode);
    _controller.addListener(_onScrollChanged);
  }

  @override
  Widget build(BuildContext context) {
    BackgroundTaskManager(_localDatabase).run(); // no await
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final ThemeData theme = Theme.of(context);

    return SmoothScaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutoSizeText(
              getProductName(_product, appLocalizations),
              minFontSize: (theme.primaryTextTheme.titleLarge?.fontSize
                      ?.clamp(13.0, 17.0)) ??
                  13.0,
              maxLines: !_barcodeVisibleInAppbar ? 2 : 1,
              style: theme.primaryTextTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            if (_barcode.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _barcodeVisibleInAppbar ? 13.0 : 0.0,
                child: Text(
                  _barcode,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: appLocalizations.clipboard_barcode_copy,
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: _barcode),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appLocalizations.clipboard_barcode_copied(_barcode),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ProductRefresher().fetchAndRefresh(
          barcode: _barcode,
          widget: this,
        ),
        child: Scrollbar(
          child: ListView(
            controller: _controller,
            children: <Widget>[
              if (_ProductBarcode.isAValidBarcode(_product.barcode))
                _ProductBarcode(product: _product),
              _ListTitleItem(
                title: appLocalizations.edit_product_form_item_details_title,
                subtitle:
                    appLocalizations.edit_product_form_item_details_subtitle,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(context)) {
                    return;
                  }
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AddBasicDetailsPage(_product),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              _ListTitleItem(
                leading: const Icon(Icons.add_a_photo_rounded),
                title: appLocalizations.edit_product_form_item_photos_title,
                subtitle:
                    appLocalizations.edit_product_form_item_photos_subtitle,
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ProductImageGalleryView(
                        product: _product,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              _getMultipleListTileItem(
                <AbstractSimpleInputPageHelper>[
                  SimpleInputPageLabelHelper(),
                  SimpleInputPageStoreHelper(),
                  SimpleInputPageOriginHelper(),
                  SimpleInputPageEmbCodeHelper(),
                  SimpleInputPageCountryHelper(),
                  SimpleInputPageCategoryHelper(),
                ],
              ),
              _ListTitleItem(
                leading: const _SvgIcon('assets/cacheTintable/ingredients.svg'),
                title:
                    appLocalizations.edit_product_form_item_ingredients_title,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(context)) {
                    return;
                  }
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => EditOcrPage(
                        product: _product,
                        helper: OcrIngredientsHelper(),
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              _getSimpleListTileItem(SimpleInputPageCategoryHelper()),
              _ListTitleItem(
                leading:
                    const _SvgIcon('assets/cacheTintable/scale-balance.svg'),
                title: appLocalizations
                    .edit_product_form_item_nutrition_facts_title,
                subtitle: appLocalizations
                    .edit_product_form_item_nutrition_facts_subtitle,
                onTap: () async => NutritionPageLoaded.showNutritionPage(
                  product: _product,
                  isLoggedInMandatory: true,
                  widget: this,
                ),
              ),
              _getSimpleListTileItem(SimpleInputPageLabelHelper()),
              _ListTitleItem(
                leading: const _SvgIcon('assets/cacheTintable/packaging.svg'),
                title: appLocalizations.edit_packagings_title,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(context)) {
                    return;
                  }
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => EditNewPackagings(
                        product: _product,
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              _ListTitleItem(
                leading: const Icon(Icons.recycling),
                title: appLocalizations.edit_product_form_item_packaging_title,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(context)) {
                    return;
                  }
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => EditOcrPage(
                        product: _product,
                        helper: OcrPackagingHelper(),
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
              _getSimpleListTileItem(SimpleInputPageStoreHelper()),
              _getSimpleListTileItem(SimpleInputPageOriginHelper()),
              _getSimpleListTileItem(SimpleInputPageEmbCodeHelper()),
              _getSimpleListTileItem(SimpleInputPageCountryHelper()),
              _ListTitleItem(
                title:
                    appLocalizations.edit_product_form_item_other_details_title,
                subtitle: appLocalizations
                    .edit_product_form_item_other_details_subtitle,
                onTap: () async {
                  if (!await ProductRefresher().checkIfLoggedIn(context)) {
                    return;
                  }
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AddOtherDetailsPage(_product),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSimpleListTileItem(final AbstractSimpleInputPageHelper helper) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _ListTitleItem(
      leading: helper.getIcon(),
      title: helper.getTitle(appLocalizations),
      subtitle: helper.getSubtitle(appLocalizations),
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(context)) {
          return;
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleInputPage(
              helper: helper,
              product: _product,
            ),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }

  Widget _getMultipleListTileItem(
    final List<AbstractSimpleInputPageHelper> helpers,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<String> titles = <String>[];
    for (final AbstractSimpleInputPageHelper element in helpers) {
      titles.add(element.getTitle(appLocalizations));
    }
    return _ListTitleItem(
      leading: const Icon(Icons.interests),
      title: titles.join(', '),
      onTap: () async {
        if (!await ProductRefresher().checkIfLoggedIn(context)) {
          return;
        }
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleInputPage.multiple(
              helpers: helpers,
              product: _product,
            ),
            fullscreenDialog: true,
          ),
        );
      },
    );
  }

  void _onScrollChanged() {
    final bool visibleBarcode =
        _controller.offset > _ProductBarcode._barcodeHeight;

    if (visibleBarcode != _barcodeVisibleInAppbar) {
      setState(() {
        _barcodeVisibleInAppbar = visibleBarcode;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScrollChanged);
    _controller.dispose();
    _localDatabase.upToDate.loseInterest(_barcode);
    super.dispose();
  }
}

class _ListTitleItem extends SmoothListTileCard {
  _ListTitleItem({
    Widget? leading,
    String? title,
    String? subtitle,
    void Function()? onTap,
    Key? key,
  }) : super.icon(
          title: title == null
              ? null
              : Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          onTap: onTap,
          key: key,
          icon: leading,
          subtitle: subtitle == null ? null : Text(subtitle),
        );
}

/// SVG that looks like a ListTile icon.
class _SvgIcon extends StatelessWidget {
  const _SvgIcon(this.assetName);

  final String assetName;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        assetName,
        height: DEFAULT_ICON_SIZE,
        width: DEFAULT_ICON_SIZE,
        color: _iconColor(Theme.of(context)),
        package: AppHelper.APP_PACKAGE,
      );

  /// Returns the standard icon color in a [ListTile].
  ///
  /// Simplified version from [ListTile], which was anyway not kind enough
  /// to make it public.
  Color _iconColor(ThemeData theme) {
    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return Colors.white;
    }
  }
}

/// Barcodes only allowed have a length of 7, 8, 12 or 13 characters
class _ProductBarcode extends StatelessWidget {
  _ProductBarcode({required this.product, Key? key})
      : assert(product.barcode?.isNotEmpty == true),
        assert(isAValidBarcode(product.barcode)),
        super(key: key);

  static const double _barcodeHeight = 120.0;

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Brightness brightness = Theme.of(context).brightness;
    final Size screenSize = MediaQuery.of(context).size;

    return BarcodeWidget(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width / 4,
        vertical: SMALL_SPACE,
      ),
      barcode: _barcodeType,
      data: product.barcode!,
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
      errorBuilder: (final BuildContext context, String? _) => Text(
        '${appLocalizations.edit_product_form_item_barcode}\n'
        '${product.barcode}',
        textAlign: TextAlign.center,
      ),
      height: _barcodeHeight,
    );
  }

  Barcode get _barcodeType {
    switch (product.barcode!.length) {
      case 7:
      case 8:
        return Barcode.ean8();
      case 12:
      case 13:
        return Barcode.ean13();
      default:
        throw Exception('Unknown barcode type!');
    }
  }

  static bool isAValidBarcode(String? barcode) =>
      barcode != null && <int>[7, 8, 12, 13].contains(barcode.length);
}
