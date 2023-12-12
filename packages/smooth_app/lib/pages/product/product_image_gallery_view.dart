import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image/product_image_gallery_other_view.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
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
}

class _ProductImageGalleryViewState extends State<ProductImageGalleryView>
    with UpToDateMixin {
  late OpenFoodFactsLanguage _language;
  bool _clickedOtherPictureButton = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _language = ProductQuery.getLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        title: Text(appLocalizations.edit_product_form_item_photos_title),
        subTitle: buildProductTitle(upToDateProduct, appLocalizations),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          AnalyticsHelper.trackProductEdit(
            AnalyticsEditEvents.photos,
            barcode,
            true,
          );
          await confirmAndUploadNewPicture(
            context,
            imageField: ImageField.OTHER,
            barcode: barcode,
            language: ProductQuery.getLanguage(),
            isLoggedInMandatory: true,
          );
        },
        label: Text(appLocalizations.add_photo_button_label),
        icon: const Icon(Icons.add_a_photo),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ProductRefresher().fetchAndRefresh(
          barcode: barcode,
          context: context,
        ),
        child: ListView(
          children: <Widget>[
            LanguageSelector(
              setLanguage: (final OpenFoodFactsLanguage? newLanguage) async {
                if (newLanguage == null || newLanguage == _language) {
                  return;
                }
                setState(() => _language = newLanguage);
              },
              displayedLanguage: _language,
              selectedLanguages: null,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 13.0,
                vertical: SMALL_SPACE,
              ),
            ),
            _ImageRow(row: 1, product: upToDateProduct, language: _language),
            _TextRow(row: 1, product: upToDateProduct, language: _language),
            _ImageRow(row: 2, product: upToDateProduct, language: _language),
            _TextRow(row: 2, product: upToDateProduct, language: _language),
            if (!_clickedOtherPictureButton)
              Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: SmoothLargeButtonWithIcon(
                  text: appLocalizations.view_more_photo_button,
                  icon: Icons.photo_camera_rounded,
                  onPressed: () => setState(
                    () => _clickedOtherPictureButton = true,
                  ),
                ),
              ),
            if (_clickedOtherPictureButton)
              Padding(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: Text(
                  appLocalizations.more_photos,
                  style: _getTextStyle(context),
                ),
              ),
            if (_clickedOtherPictureButton)
              ProductImageGalleryOtherView(product: upToDateProduct),
            const SizedBox(height: 2 * VERY_LARGE_SPACE),
          ],
        ),
      ),
    );
  }
}

abstract class _GenericRow extends StatelessWidget {
  const _GenericRow({
    required this.row,
    required this.product,
    required this.language,
  });

  /// Displayed row, starting from 1.
  final int row;
  final Product product;
  final OpenFoodFactsLanguage language;

  @protected
  int get index1 => (row - 1) * 2;

  @protected
  int get index2 => index1 + 1;

  @protected
  ImageField getImageField(final int index) =>
      ImageFieldSmoothieExtension.orderedMain[index];

  static const double _innerPadding = SMALL_SPACE;

  @protected
  double getSquareSize(final BuildContext context) =>
      (MediaQuery.of(context).size.width - _innerPadding) / 2;

  Future<void> _openImage({
    required BuildContext context,
    required int initialImageIndex,
  }) async =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView(
            initialImageIndex: initialImageIndex,
            product: product,
            isLoggedInMandatory: true,
            initialLanguage: language,
          ),
        ),
      );
}

class _ImageRow extends _GenericRow {
  const _ImageRow({
    required super.row,
    required super.product,
    required super.language,
  });

  TransientFile _getTransientFile(final ImageField imageField) =>
      TransientFile.fromProductImageData(
        getProductImageData(product, imageField, language),
        product.barcode!,
        language,
      );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _Image(
            squareSize: getSquareSize(context),
            imageProvider:
                _getTransientFile(getImageField(index1)).getImageProvider(),
            onTap: () => _openImage(
              context: context,
              initialImageIndex: index1,
            ),
          ),
          _Image(
            squareSize: getSquareSize(context),
            imageProvider:
                _getTransientFile(getImageField(index2)).getImageProvider(),
            onTap: () => _openImage(
              context: context,
              initialImageIndex: index2,
            ),
          ),
        ],
      );
}

class _TextRow extends _GenericRow {
  const _TextRow({
    required super.row,
    required super.product,
    required super.language,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
          top: SMALL_SPACE,
          bottom: LARGE_SPACE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _Text(
              squareSize: getSquareSize(context),
              imageField: getImageField(index1),
              onTap: () => _openImage(
                context: context,
                initialImageIndex: index1,
              ),
            ),
            _Text(
              squareSize: getSquareSize(context),
              imageField: getImageField(index2),
              onTap: () => _openImage(
                context: context,
                initialImageIndex: index2,
              ),
            ),
          ],
        ),
      );
}

class _Image extends StatelessWidget {
  const _Image({
    required this.squareSize,
    required this.imageProvider,
    required this.onTap,
  });

  final double squareSize;
  final ImageProvider? imageProvider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SmoothImage(
          width: squareSize,
          height: squareSize,
          imageProvider: imageProvider,
        ),
      );
}

class _Text extends StatelessWidget {
  const _Text({
    required this.squareSize,
    required this.imageField,
    required this.onTap,
  });

  final double squareSize;
  final ImageField imageField;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          width: squareSize,
          child: Center(
            child: Text(
              imageField.getProductImageTitle(AppLocalizations.of(context)),
              style: _getTextStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
}

TextStyle? _getTextStyle(final BuildContext context) =>
    Theme.of(context).textTheme.headlineMedium;
