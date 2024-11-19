import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_app_logo.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/border_radius_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/product_image_gallery_other_view.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_photo_row.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_tabs.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/slivers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Display of the main 4 pictures of a product, with edit options.
class ProductImageGalleryView extends StatefulWidget {
  const ProductImageGalleryView({
    required this.product,
  });

  final Product product;

  @override
  State<ProductImageGalleryView> createState() =>
      _ProductImageGalleryViewState();

  static Future<File?> takePicture({
    required BuildContext context,
    required Product product,
    required ImageField imageField,
    required OpenFoodFactsLanguage language,
  }) async {
    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.photos,
      product,
      true,
    );

    final CropParameters? cropParameters = await confirmAndUploadNewPicture(
      context,
      imageField: imageField,
      barcode: product.barcode!,
      language: language,
      isLoggedInMandatory: true,
      productType: product.productType,
    );

    return cropParameters?.smallCroppedFile;
  }
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView>
    with UpToDateMixin {
  late OpenFoodFactsLanguage _language;
  late final List<ImageField> _mainImageFields;
  bool _clickedOtherPictureButton = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _language = ProductQuery.getLanguage();
    _mainImageFields = ImageFieldSmoothieExtension.getOrderedMainImageFields(
      widget.product.productType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();

    return MultiProvider(
      providers: <Provider<dynamic>>[
        Provider<Product>(
          create: (_) => upToDateProduct,
        ),
        Provider<OpenFoodFactsLanguage>.value(
          value: _language,
        ),
      ],
      child: Provider<Product>.value(
        value: upToDateProduct,
        child: SmoothSharedAnimationController(
          child: SmoothScaffold(
            appBar: buildEditProductAppBar(
              context: context,
              title: appLocalizations.edit_product_form_item_photos_title,
              product: upToDateProduct,
              bottom: ProductImageGalleryTabBar(
                onTabChanged: (final OpenFoodFactsLanguage language) =>
                    onNextFrame(
                  () => setState(() => _language = language),
                ),
                padding: const EdgeInsetsDirectional.only(start: 55.0),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async =>
                              ProductRefresher().fetchAndRefresh(
                            barcode: barcode,
                            context: context,
                          ),
                          child: CustomScrollView(
                            slivers: <Widget>[
                              SliverPadding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: VERY_SMALL_SPACE,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                    crossAxisCount: 2,
                                    height: (MediaQuery.sizeOf(context).width /
                                            2.15) +
                                        ImageGalleryPhotoRow.itemHeight,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: VERY_SMALL_SPACE,
                                          start: index.isOdd
                                              ? VERY_SMALL_SPACE / 2
                                              : VERY_SMALL_SPACE,
                                          end: index.isOdd
                                              ? VERY_SMALL_SPACE
                                              : VERY_SMALL_SPACE / 2,
                                        ),
                                        child: ImageGalleryPhotoRow(
                                          key: Key(
                                            '${_mainImageFields[index]}_${_language.offTag}}',
                                          ),
                                          position: index,
                                          imageField: _mainImageFields[index],
                                          language: _language,
                                        ),
                                      );
                                    },
                                    childCount: _mainImageFields.length,
                                    addAutomaticKeepAlives: false,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  vertical: MEDIUM_SPACE,
                                  horizontal: SMALL_SPACE,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    appLocalizations.more_photos,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                ),
                              ),
                              if (_shouldDisplayRawGallery())
                                ProductImageGalleryOtherView(
                                  product: upToDateProduct,
                                )
                              else
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(SMALL_SPACE),
                                    child: SmoothLargeButtonWithIcon(
                                      text: appLocalizations
                                          .view_more_photo_button,
                                      icon: Icons.photo_camera_rounded,
                                      onPressed: () => setState(
                                        () => _clickedOtherPictureButton = true,
                                      ),
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height:
                                      MediaQuery.viewPaddingOf(context).bottom +
                                          (VERY_LARGE_SPACE * 2.5),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  bottom: 0.0,
                  end: 0.0,
                  child: const _ProductImageGalleryFooterButton(),
                ),
              ],
            ),
            persistentFooterAlignment: AlignmentDirectional.bottomEnd,
          ),
        ),
      ),
    );
  }

  bool _shouldDisplayRawGallery() =>
      _clickedOtherPictureButton ||
      (upToDateProduct.getRawImages()?.isNotEmpty == true);
}

class _ProductImageGalleryFooterButton extends StatelessWidget {
  const _ProductImageGalleryFooterButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension theme =
        context.extension<SmoothColorsThemeExtension>();

    final BorderRadius borderRadius = BorderRadiusHelper.fromDirectional(
      context: context,
      topStart: ROUNDED_RADIUS,
    );

    return Semantics(
      button: true,
      label: appLocalizations.add_photo_button_label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              context.lightTheme() ? theme.primaryMedium : theme.primaryNormal,
          borderRadius: borderRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3),
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: () async => ProductImageGalleryView.takePicture(
              context: context,
              product: context.read<Product>(),
              imageField: ImageField.OTHER,
              language: context.read<OpenFoodFactsLanguage>(),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                top: LARGE_SPACE,
                start: LARGE_SPACE,
                end: LARGE_SPACE,
                bottom:
                    MediaQuery.viewPaddingOf(context).bottom + VERY_SMALL_SPACE,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const icons.Add(
                    color: Colors.black,
                  ),
                  const SizedBox(width: BALANCED_SPACE),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 2.0),
                    child: Text(
                      appLocalizations.add_photo_button_label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
