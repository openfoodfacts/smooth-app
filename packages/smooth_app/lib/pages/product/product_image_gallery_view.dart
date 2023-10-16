import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
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
  late List<MapEntry<ProductImageData, ImageProvider?>> _selectedImages;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    context.watch<LocalDatabase>();
    refreshUpToDate();
    _selectedImages = getSelectedImages(
      upToDateProduct,
      ProductQuery.getLanguage(),
    );
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
            this,
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
          widget: this,
        ),
        child: ListView.builder(
          itemCount: _selectedImages.length,
          itemBuilder: (final BuildContext context, int index) {
            final MapEntry<ProductImageData, ImageProvider?> item =
                _selectedImages[index];

            return SmoothListTileCard.image(
              imageProvider: item.value,
              title: Text(
                item.key.imageField.getProductImageTitle(appLocalizations),
                style: theme.textTheme.headlineMedium,
              ),
              onTap: () => _openImage(
                imageData: item.key,
                initialImageIndex: index,
              ),
              heroTag: 'photo_${item.key.imageField.offTag}',
            );
          },
        ),
      ),
    );
  }

  Future<void> _openImage({
    required ProductImageData imageData,
    required int initialImageIndex,
  }) async =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView(
            initialImageIndex: initialImageIndex,
            product: upToDateProduct,
            isLoggedInMandatory: true,
          ),
        ),
      );
}
