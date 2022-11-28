import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

///Widget to display swipeable product images of particular category,
///Opens product image with [initialImageIndex].
class ProductImageSwipeableView extends StatefulWidget {
  const ProductImageSwipeableView({
    super.key,
    required this.product,
    required this.initialImageIndex,
  });
  final Product product;
  final int initialImageIndex;
  @override
  State<ProductImageSwipeableView> createState() =>
      _ProductImageSwipeableViewState();
}

class _ProductImageSwipeableViewState extends State<ProductImageSwipeableView> {
  late final LocalDatabase _localDatabase;
  //Making use of [ValueNotifier] such that to avoid performance issues
  //while swipping between pages by making sure only [Text] widget for product title is rebuilt
  final ValueNotifier<int> _currentImageDataIndex = ValueNotifier<int>(0);
  late Map<ProductImageData, ImageProvider?> _selectedImages;
  late List<ProductImageData> _imageDataList;
  late PageController _controller;
  late final Product _initialProduct;
  late Product _product;

  ImageProvider? _provideImage(ProductImageData imageData) =>
      TransientFile.getImageProvider(imageData, _barcode);

  String get _barcode => _initialProduct.barcode!;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_barcode);
    _controller = PageController(
      initialPage: widget.initialImageIndex,
    );
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_barcode);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final List<ProductImageData> allProductImagesData =
        getProductMainImagesData(_product, includeOther: false);
    _selectedImages = Map<ProductImageData, ImageProvider?>.fromIterables(
      allProductImagesData,
      allProductImagesData.map(_provideImage),
    );
    _imageDataList = List<ProductImageData>.from(_selectedImages.keys);
    return SmoothScaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: _currentImageDataIndex,
          builder: (_, int index, __) => Text(getImagePageTitle(
            appLocalizations,
            _imageDataList[index].imageField,
          )),
        ),
        leading: SmoothBackButton(
          iconColor: Colors.white,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: PageView.builder(
        onPageChanged: (int index) {
          _currentImageDataIndex.value = index;
        },
        controller: _controller,
        itemCount: _selectedImages.keys.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductImageViewer(
            product: widget.product,
            imageField: _imageDataList[index].imageField,
          );
        },
      ),
    );
  }
}
