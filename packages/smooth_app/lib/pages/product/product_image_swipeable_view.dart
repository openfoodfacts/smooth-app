import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/product/product_image_viewer.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Widget to display swipeable product images of particular category.
class ProductImageSwipeableView extends StatefulWidget {
  /// Version with the 4 main [ImageField].
  const ProductImageSwipeableView({
    super.key,
    required this.product,
    required this.initialImageIndex,
    required this.isLoggedInMandatory,
    this.initialLanguage,
  }) : imageField = null;

  /// Version with only one main [ImageField].
  const ProductImageSwipeableView.imageField({
    super.key,
    required this.product,
    required this.imageField,
    required this.isLoggedInMandatory,
    this.initialLanguage,
  }) : initialImageIndex = 0;

  final Product product;
  final int initialImageIndex;
  final ImageField? imageField;
  final bool isLoggedInMandatory;
  final OpenFoodFactsLanguage? initialLanguage;

  @override
  State<ProductImageSwipeableView> createState() =>
      _ProductImageSwipeableViewState();
}

class _ProductImageSwipeableViewState extends State<ProductImageSwipeableView>
    with UpToDateMixin {
  //Making use of [ValueNotifier] such that to avoid performance issues
  //while swiping between pages by making sure only [Text] widget for product title is rebuilt
  late final ValueNotifier<int> _currentImageDataIndex;
  late List<ImageField> _imageFields;
  late PageController _controller;
  late OpenFoodFactsLanguage _currentLanguage;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _controller = PageController(
      initialPage: widget.initialImageIndex,
    );
    _currentImageDataIndex = ValueNotifier<int>(widget.initialImageIndex);
    _currentLanguage = widget.initialLanguage ?? ProductQuery.getLanguage();
    if (widget.imageField != null) {
      _imageFields = <ImageField>[widget.imageField!];
    } else {
      _imageFields = ImageFieldSmoothieExtension.getOrderedMainImageFields(
        widget.product.productType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    context.watch<LocalDatabase>();
    refreshUpToDate();
    return SmoothScaffold(
      backgroundColor: Colors.black,
      appBar: SmoothAppBar(
        backgroundColor: Colors.black,
        foregroundColor: WHITE_COLOR,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        centerTitle: false,
        title: ValueListenableBuilder<int>(
          valueListenable: _currentImageDataIndex,
          builder: (_, int index, __) => Text(
            _imageFields[index].getImagePageTitle(appLocalizations),
            maxLines: 2,
          ),
        ),
        leading: SmoothBackButton(
          iconColor: Colors.white,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: PageView.builder(
        onPageChanged: (int index) => _currentImageDataIndex.value = index,
        controller: _controller,
        itemCount: _imageFields.length,
        itemBuilder: (BuildContext context, int index) => ProductImageViewer(
          product: widget.product,
          imageField: _imageFields[index],
          isInitialImageViewed: widget.initialImageIndex == index,
          language: _currentLanguage,
          setLanguage: (final OpenFoodFactsLanguage? newLanguage) async {
            if (newLanguage == null || newLanguage == _currentLanguage) {
              return;
            }
            setState(() => _currentLanguage = newLanguage);
          },
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      ),
    );
  }
}
