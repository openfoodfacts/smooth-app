import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/ocr_widget.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

// TODO(monsieurtanuki): rename file as `edit_ocr_page.dart`
/// Editing with OCR a product field and the corresponding image.
///
/// Typical use-cases: ingredients and packaging.
class EditOcrPage extends StatefulWidget {
  const EditOcrPage({
    required this.product,
    required this.helper,
  });

  final Product product;
  final OcrHelper helper;

  @override
  State<EditOcrPage> createState() => _EditOcrPageState();
}

class _EditOcrPageState extends State<EditOcrPage> {
  final TextEditingController _controller = TextEditingController();
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;

  OcrHelper get _helper => widget.helper;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_initialProduct.barcode!);
    _controller.text = _helper.getText(_initialProduct);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_product.barcode!);
    super.dispose();
  }

  Future<void> _onSubmitField(ImageField imageField) async =>
      _updateText(_controller.text, imageField);

  /// Opens a page to upload a new image.
  Future<void> _newImage() async => confirmAndUploadNewPicture(
        this,
        barcode: _product.barcode!,
        imageField: _helper.getImageField(),
      );

  /// Extracts data with OCR from the image stored on the server.
  ///
  /// When done, populates the related page field.
  Future<void> _extractData() async {
    // TODO(monsieurtanuki): hide the "extract" button while extracting, or display a loading dialog on top
    try {
      final String? extractedText = await _helper.getExtractedText(_product);
      if (!mounted) {
        return;
      }

      if (extractedText == null || extractedText.isEmpty) {
        await LoadingDialog.error(
          context: context,
          title: AppLocalizations.of(context).edit_ocr_extract_failed,
        );
        return;
      }

      if (_controller.text != extractedText) {
        setState(() => _controller.text = extractedText);
      }
    } catch (e) {
      //
    }
  }

  /// Updates the product field on the server.
  Future<void> _updateText(
    final String text,
    final ImageField imageField,
  ) async =>
      BackgroundTaskDetails.addTask(
        _helper.getMinimalistProduct(Product(barcode: _product.barcode), text),
        widget: this,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final ProductImageData productImageData =
        getProductImageData(_product, _helper.getImageField());

    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      appBar: SmoothAppBar(
        title: Text(_helper.getTitle(appLocalizations)),
        subTitle: _product.productName != null
            ? Text(
                _product.productName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _getImageWidget(productImageData),
          OcrWidget(
            controller: _controller,
            onTapNewImage: _newImage,
            onTapExtractData: _extractData,
            onSubmitField: _onSubmitField,
            productImageData: productImageData,
            product: _product,
            helper: _helper,
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(final ProductImageData productImageData) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      productImageData,
      _initialProduct.barcode!,
    );

    if (imageProvider != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.only(
            left: VERY_LARGE_SPACE,
            top: 10,
            right: VERY_LARGE_SPACE,
            bottom: 200,
          ),
          minScale: 0.1,
          maxScale: 5,
          child: Image(
            fit: BoxFit.contain,
            image: imageProvider,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: size.height * 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.image_not_supported,
            size: size.height / 4,
          ),
          Text(
            appLocalizations.ocr_image_upload_instruction,
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
