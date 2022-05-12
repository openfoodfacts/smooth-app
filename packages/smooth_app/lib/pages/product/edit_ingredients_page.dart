import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/OcrIngredientsResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

/// Page for editing the ingredients of a product and the image of the
/// ingredients.
class EditIngredientsPage extends StatefulWidget {
  const EditIngredientsPage({
    Key? key,
    required this.product,
    this.refreshProductCallback,
  }) : super(key: key);

  final Product product;
  final Function(BuildContext)? refreshProductCallback;

  @override
  State<EditIngredientsPage> createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  final TextEditingController _controller = TextEditingController();
  ImageProvider? _imageProvider;
  bool _updatingImage = false;
  bool _updatingIngredients = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.product.ingredientsText ?? '';
  }

  Future<void> _onSubmitField() async {
    setState(() {
      _updatingIngredients = true;
    });

    try {
      await _updateIngredientsText(_controller.text);
    } catch (error) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
      _showError(appLocalizations.ingredients_editing_error);
    }

    setState(() {
      _updatingIngredients = false;
    });
  }

  Future<void> _onTapGetImage(bool isNewImage) async {
    setState(() {
      _updatingImage = true;
    });

    try {
      await _getImage(isNewImage);
    } catch (error) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
      _showError(appLocalizations.ingredients_editing_image_error);
    }

    setState(() {
      _updatingImage = false;
    });
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
      final File? croppedImageFile = await startImageCropping(context);

      // If the user cancels.
      if (croppedImageFile == null) {
        return;
      }

      // Update the image to load the new image file.
      setState(() {
        _imageProvider = FileImage(croppedImageFile);
      });

      isUploaded = await uploadCapturedPicture(
        context,
        barcode: widget.product.barcode!,
        imageField: ImageField.INGREDIENTS,
        imageUri: croppedImageFile.uri,
      );

      croppedImageFile.delete();
    }

    if (!isUploaded) {
      throw Exception('Image could not be uploaded.');
    }

    final OpenFoodFactsLanguage? language = ProductQuery.getLanguage();

    final User user = ProductQuery.getUser();

    // Get the ingredients from the image.
    final OcrIngredientsResult ingredientsResult =
        await OpenFoodAPIClient.extractIngredients(
            user, widget.product.barcode!, language!);

    final String? nextIngredients = ingredientsResult.ingredientsTextFromImage;
    if (nextIngredients == null || nextIngredients.isEmpty) {
      throw Exception('Failed to detect ingredients text in image.');
    }

    // Save the product's ingredients if needed.
    if (_controller.text != nextIngredients) {
      setState(() {
        _controller.text = nextIngredients;
      });
    }
  }

  Future<void> _updateIngredientsText(String ingredientsText) async {
    widget.product.ingredientsText = ingredientsText;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool savedAndRefreshed = await ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: widget.product,
    );
    if (savedAndRefreshed) {
      await widget.refreshProductCallback?.call(context);
    } else {
      throw Exception("Couldn't save the product.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final List<Widget> children = <Widget>[];

    if (_imageProvider != null) {
      children.add(
        ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildZoomableImage(_imageProvider!),
        ),
      );
    } else {
      if (widget.product.imageIngredientsUrl != null) {
        children.add(ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildZoomableImage(
              NetworkImage(widget.product.imageIngredientsUrl!)),
        ));
      } else {
        children.add(Container(color: Colors.white));
      }
    }

    if (_updatingImage) {
      children.add(const Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      children.add(_EditIngredientsBody(
        controller: _controller,
        imageIngredientsUrl: widget.product.imageIngredientsUrl,
        onTapGetImage: _onTapGetImage,
        onSubmitField: _onSubmitField,
        updatingIngredients: _updatingIngredients,
        hasImageProvider: _imageProvider != null,
      ));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(appLocalizations.ingredients_editing_title),
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
  }

  Widget _buildZoomableImage(ImageProvider imageSource) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.fromLTRB(20, 10, 20, 200),
      minScale: 0.1,
      maxScale: 5,
      child: Image(fit: BoxFit.contain, image: imageSource),
    );
  }
}

class _EditIngredientsBody extends StatelessWidget {
  const _EditIngredientsBody({
    Key? key,
    required this.controller,
    required this.imageIngredientsUrl,
    required this.onSubmitField,
    required this.onTapGetImage,
    required this.updatingIngredients,
    required this.hasImageProvider,
  }) : super(key: key);

  final TextEditingController controller;
  final bool updatingIngredients;
  final String? imageIngredientsUrl;
  final Future<void> Function(bool) onTapGetImage;
  final Future<void> Function() onSubmitField;
  final bool hasImageProvider;

  Widget _getExtraitIngredientsBtn(AppLocalizations appLocalizations) {
    if (hasImageProvider || imageIngredientsUrl != null) {
      return SmoothActionButton(
        text: appLocalizations.edit_ingredients_extrait_ingredients_btn_text,
        onPressed: () => onTapGetImage(false),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: LARGE_SPACE, right: SMALL_SPACE),
                child: SmoothActionButton(
                  text:
                      appLocalizations.edit_ingredients_refresh_photo_btn_text,
                  onPressed: () => onTapGetImage(true),
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
                      _getExtraitIngredientsBtn(appLocalizations),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        enabled: !updatingIngredients,
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: ANGULAR_BORDER_RADIUS,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => onSubmitField,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      Text(appLocalizations.ingredients_editing_instructions,
                          style: Theme.of(context).textTheme.caption),
                      const SizedBox(height: MEDIUM_SPACE),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SmoothActionButton(
                              text: appLocalizations.cancel,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: LARGE_SPACE),
                            SmoothActionButton(
                              text: appLocalizations.save,
                              onPressed: () async {
                                await onSubmitField();
                                Navigator.pop(context);
                              },
                            ),
                          ]),
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
