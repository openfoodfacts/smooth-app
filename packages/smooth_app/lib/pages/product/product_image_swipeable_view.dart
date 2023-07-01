import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/up_to_date_manager.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
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
  }) : imageField = null;

  /// Version with only one main [ImageField].
  const ProductImageSwipeableView.imageField({
    super.key,
    required this.product,
    required this.imageField,
  }) : initialImageIndex = 0;

  final Product product;
  final int initialImageIndex;
  final ImageField? imageField;

  @override
  State<ProductImageSwipeableView> createState() =>
      _ProductImageSwipeableViewState();
}

class _ProductImageSwipeableViewState extends State<ProductImageSwipeableView> {
  late final UpToDateManager _upToDateManager;

  //Making use of [ValueNotifier] such that to avoid performance issues
  //while swiping between pages by making sure only [Text] widget for product title is rebuilt
  late final ValueNotifier<int> _currentImageDataIndex;
  late List<MapEntry<ProductImageData, ImageProvider?>> _selectedImages;
  late PageController _controller;
  late OpenFoodFactsLanguage _currentLanguage;

  @override
  void initState() {
    super.initState();
    _upToDateManager = UpToDateManager(
      widget.product,
      context.read<LocalDatabase>(),
    );
    _controller = PageController(
      initialPage: widget.initialImageIndex,
    );
    _currentImageDataIndex = ValueNotifier<int>(widget.initialImageIndex);
    _currentLanguage = ProductQuery.getLanguage();
  }

  @override
  void dispose() {
    _upToDateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _upToDateManager.refresh();
    _selectedImages = getSelectedImages(
      _upToDateManager.product,
      _currentLanguage,
    );
    if (widget.imageField != null) {
      _selectedImages.removeWhere(
        (
          final MapEntry<ProductImageData, ImageProvider<Object>?> element,
        ) =>
            element.key.imageField != widget.imageField,
      );
    }
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
            _selectedImages[index].key.imageField.getImagePageTitle(
                  appLocalizations,
                ),
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
        itemCount: _selectedImages.length,
        itemBuilder: (BuildContext context, int index) => ProductImageViewer(
          product: widget.product,
          imageField: _selectedImages[index].key.imageField,
          language: _currentLanguage,
          setLanguage: (final OpenFoodFactsLanguage? newLanguage) async {
            if (newLanguage == null || newLanguage == _currentLanguage) {
              return;
            }
            setState(() => _currentLanguage = newLanguage);
          },
        ),
      ),
    );
  }
}
