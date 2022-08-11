import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  ImageProvider? _imageProvider;
  bool _updatingImage = false;
  bool _updatingText = false;
  late Product _product;
  late OcrHelper _helper;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _helper = widget.helper;
    _controller.text = _helper.getText(_product);
  }

  Future<void> _onSubmitField() async {
    setState(() => _updatingText = true);

    try {
      await _updateText(_controller.text);
    } catch (error) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      _showError(_helper.getError(appLocalizations));
    }

    setState(() => _updatingText = false);
  }

  Future<void> _onTapGetImage(bool isNewImage) async {
    setState(() => _updatingImage = true);

    try {
      await _getImage(isNewImage);
    } catch (error) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      _showError(_helper.getImageError(appLocalizations));
    }

    setState(() => _updatingImage = false);
  }

  // Show the given error message to the user in a SnackBar.
  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Get an image from the camera, run OCR on it, and update the product's
  // ingredients.
  //
  // Returns a Future that resolves successfully only if everything succeeds,
  // otherwise it will resolve with the relevant error.
  Future<void> _getImage(bool isNewImage) async {
    bool isUploaded = true;
    if (isNewImage) {
      final File? croppedImageFile =
          await startImageCropping(context, showOptionDialog: true);

      // If the user cancels.
      if (croppedImageFile == null) {
        return;
      }

      // Update the image to load the new image file.
      setState(() => _imageProvider = FileImage(croppedImageFile));
      if (!mounted) {
        return;
      }
      isUploaded = await uploadCapturedPicture(
        context,
        barcode: _product.barcode!,
        imageField: _helper.getImageField(),
        imageUri: croppedImageFile.uri,
      );

      croppedImageFile.delete();
    }

    if (!isUploaded) {
      throw Exception('Image could not be uploaded.');
    }

    final String? extractedText = await _helper.getExtractedText(_product);
    if (extractedText == null || extractedText.isEmpty) {
      throw Exception('Failed to detect text in image.');
    }

    // Save the product's ingredients if needed.
    if (_controller.text != extractedText) {
      setState(() => _controller.text = extractedText);
    }
  }

  Future<bool> _updateText(final String text) async {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    return ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: _helper.getMinimalistProduct(_product, text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final List<Widget> children = <Widget>[];

    if (_imageProvider != null) {
      children.add(
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildZoomableImage(_imageProvider!),
        ),
      );
    } else {
      final String? imageUrl = _helper.getImageUrl(_product);
      if (imageUrl != null) {
        children.add(
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: _buildZoomableImage(NetworkImage(imageUrl)),
          ),
        );
      } else {
        children.add(Container(color: Colors.white));
      }
    }

    if (_updatingImage) {
      children.add(
        const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      children.add(
        _OcrWidget(
          controller: _controller,
          onTapGetImage: _onTapGetImage,
          onSubmitField: _onSubmitField,
          updatingText: _updatingText,
          hasImageProvider: _imageProvider != null,
          product: _product,
          helper: _helper,
        ),
      );
    }

    final Scaffold scaffold = SmoothScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_helper.getTitle(appLocalizations)),
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
        children: children,
      ),
    );
    return Consumer<UpToDateProductProvider>(
      builder: (
        final BuildContext context,
        final UpToDateProductProvider provider,
        final Widget? child,
      ) {
        final Product? refreshedProduct = provider.get(_product);
        if (refreshedProduct != null) {
          _product = refreshedProduct;
        }
        return scaffold;
      },
    );
  }

  Widget _buildZoomableImage(ImageProvider imageSource) {
    return InteractiveViewer(
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
        image: imageSource,
      ),
    );
  }
}

class _OcrWidget extends StatelessWidget {
  const _OcrWidget({
    required this.controller,
    required this.onSubmitField,
    required this.onTapGetImage,
    required this.updatingText,
    required this.hasImageProvider,
    required this.product,
    required this.helper,
  });

  final TextEditingController controller;
  final bool updatingText;
  final Future<void> Function(bool) onTapGetImage;
  final Future<void> Function() onSubmitField;
  final bool hasImageProvider;
  final Product product;
  final OcrHelper helper;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: LARGE_SPACE,
                  start: LARGE_SPACE,
                  end: LARGE_SPACE,
                ),
                child: SmoothActionButtonsBar(
                  positiveAction: SmoothActionButton(
                    text: helper.getActionRefreshPhoto(appLocalizations),
                    onPressed: () => onTapGetImage(true),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: ANGULAR_RADIUS,
                      topRight: ANGULAR_RADIUS,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(LARGE_SPACE),
                  child: Column(
                    children: <Widget>[
                      if (hasImageProvider ||
                          helper.getImageUrl(product) != null)
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text: helper.getActionExtractText(appLocalizations),
                            onPressed: () => onTapGetImage(false),
                          ),
                        ),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        enabled: !updatingText,
                        controller: controller,
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: ANGULAR_BORDER_RADIUS,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => onSubmitField,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      ExplanationWidget(
                        helper.getInstructions(appLocalizations),
                      ),
                      const SizedBox(height: MEDIUM_SPACE),
                      SmoothActionButtonsBar(
                        negativeAction: SmoothActionButton(
                          text: appLocalizations.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        positiveAction: SmoothActionButton(
                          text: appLocalizations.save,
                          onPressed: () async {
                            await onSubmitField();
                            //ignore: use_build_context_synchronously
                            Navigator.pop(context, product);
                          },
                        ),
                      ),
                      const SizedBox(height: MEDIUM_SPACE),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
