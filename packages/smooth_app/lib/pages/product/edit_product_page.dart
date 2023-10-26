// ignore_for_file: use_build_context_synchronously

import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/add_other_details_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/simple_input_page.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_floating_message.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where we can indirectly edit all data about a product.
class EditProductPage extends StatefulWidget {
  const EditProductPage(this.product);

  final Product product;

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> with UpToDateMixin {
  final ScrollController _controller = ScrollController();
  bool _barcodeVisibleInAppbar = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _controller.addListener(_onScrollChanged);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    final ThemeData theme = Theme.of(context);
    final String productName = getProductName(
      upToDateProduct,
      appLocalizations,
    );
    final String productBrand =
        getProductBrands(upToDateProduct, appLocalizations);

    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Semantics(
          value: productName,
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(
                  '${productName.trim()}, ${productBrand.trim()}',
                  minFontSize:
                      theme.textTheme.titleLarge?.fontSize?.clamp(13.0, 17.0) ??
                          13.0,
                  maxLines: !_barcodeVisibleInAppbar ? 2 : 1,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (barcode.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: _barcodeVisibleInAppbar ? 14.0 : 0.0,
                    child: Text(
                      barcode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            value: appLocalizations.clipboard_barcode_copy,
            excludeSemantics: true,
            child: Builder(builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.copy),
                tooltip: appLocalizations.clipboard_barcode_copy,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: barcode),
                  );

                  SmoothFloatingMessage(
                    message: appLocalizations.clipboard_barcode_copied(barcode),
                  ).show(context, alignment: AlignmentDirectional.bottomCenter);
                },
              );
            }),
          )
        ],
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
            children: <Widget>[
              if (_ProductBarcode.isAValidBarcode(barcode))
                _ProductBarcode(product: upToDateProduct),
              _ListTitleItem(
                title: appLocalizations.edit_product_form_item_details_title,
                subtitle:
                    appLocalizations.edit_product_form_item_details_subtitle,
                onTap: () async => ProductFieldDetailsEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _ListTitleItem(
                leading: const Icon(Icons.add_a_photo_rounded),
                title: appLocalizations.edit_product_form_item_photos_title,
                subtitle:
                    appLocalizations.edit_product_form_item_photos_subtitle,
                onTap: () async {
                  AnalyticsHelper.trackProductEdit(
                    AnalyticsEditEvents.photos,
                    barcode,
                  );

                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ProductImageGalleryView(
                        product: upToDateProduct,
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
                onTap: () async => ProductFieldOcrIngredientEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _getSimpleListTileItem(SimpleInputPageCategoryHelper()),
              _ListTitleItem(
                  leading:
                      const _SvgIcon('assets/cacheTintable/scale-balance.svg'),
                  title: appLocalizations
                      .edit_product_form_item_nutrition_facts_title,
                  subtitle: appLocalizations
                      .edit_product_form_item_nutrition_facts_subtitle,
                  onTap: () async {
                    if (!await ProductRefresher().checkIfLoggedIn(
                      context,
                      isLoggedInMandatory: true,
                    )) {
                      return;
                    }
                    AnalyticsHelper.trackProductEdit(
                      AnalyticsEditEvents.nutrition_Facts,
                      barcode,
                    );
                    await NutritionPageLoaded.showNutritionPage(
                      product: upToDateProduct,
                      isLoggedInMandatory: true,
                      context: context,
                    );
                  }),
              _getSimpleListTileItem(SimpleInputPageLabelHelper()),
              _ListTitleItem(
                leading: const _SvgIcon('assets/cacheTintable/packaging.svg'),
                title: appLocalizations.edit_packagings_title,
                onTap: () async => ProductFieldPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
              ),
              _ListTitleItem(
                leading: const Icon(Icons.recycling),
                title: appLocalizations.edit_product_form_item_packaging_title,
                onTap: () async => ProductFieldOcrPackagingEditor().edit(
                  context: context,
                  product: upToDateProduct,
                ),
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
                  if (!await ProductRefresher().checkIfLoggedIn(
                    context,
                    isLoggedInMandatory: true,
                  )) {
                    return;
                  }
                  AnalyticsHelper.trackProductEdit(
                    AnalyticsEditEvents.otherDetails,
                    barcode,
                  );
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => AddOtherDetailsPage(upToDateProduct),
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
      onTap: () async => ProductFieldSimpleEditor(helper).edit(
        context: context,
        product: upToDateProduct,
      ),
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
        if (!await ProductRefresher().checkIfLoggedIn(
          context,
          isLoggedInMandatory: true,
        )) {
          return;
        }
        AnalyticsHelper.trackProductEdit(
          AnalyticsEditEvents.powerEditScreen,
          barcode,
        );
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleInputPage.multiple(
              helpers: helpers,
              product: upToDateProduct,
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
        colorFilter: ui.ColorFilter.mode(
          _iconColor(Theme.of(context)),
          ui.BlendMode.srcIn,
        ),
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
class _ProductBarcode extends StatefulWidget {
  _ProductBarcode({required this.product, Key? key})
      : assert(product.barcode?.isNotEmpty == true),
        assert(isAValidBarcode(product.barcode)),
        super(key: key);

  static const double _barcodeHeight = 120.0;

  final Product product;

  @override
  State<_ProductBarcode> createState() => _ProductBarcodeState();

  static bool isAValidBarcode(String? barcode) =>
      barcode != null && <int>[7, 8, 12, 13].contains(barcode.length);
}

class _ProductBarcodeState extends State<_ProductBarcode> {
  bool _isAnInvalidBarcode = false;

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
      data: widget.product.barcode!,
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
      errorBuilder: (final BuildContext context, String? _) {
        if (!_isAnInvalidBarcode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _isAnInvalidBarcode = true);
          });
        }

        return Text(
          '${appLocalizations.edit_product_form_item_barcode}\n'
          '${widget.product.barcode}',
          textAlign: TextAlign.center,
        );
      },
      height: _isAnInvalidBarcode ? null : _ProductBarcode._barcodeHeight,
    );
  }

  Barcode get _barcodeType {
    switch (widget.product.barcode!.length) {
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
}
