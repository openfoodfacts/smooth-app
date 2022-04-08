import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/OcrIngredientsResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Page for editing the ingredients of a product and the image of the
/// ingredients.
class EditIngredientsPage extends StatefulWidget {
  const EditIngredientsPage({
    Key? key,
    this.imageIngredientsUrl,
    required this.product,
  }) : super(key: key);

  final Product product;
  final String? imageIngredientsUrl;

  @override
  State<EditIngredientsPage> createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  final TextEditingController _controller = TextEditingController();
  ImageProvider? _imageProvider;
  bool _updatingImage = false;
  bool _updatingIngredients = false;

  static String _getIngredientsString(List<Ingredient>? ingredients) {
    return ingredients == null ? '' : ingredients.join(', ');
  }

  @override
  void initState() {
    super.initState();
    _controller.text = _getIngredientsString(widget.product.ingredients);
  }

  @override
  void didUpdateWidget(EditIngredientsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String productIngredients =
        _getIngredientsString(widget.product.ingredients);
    if (productIngredients != _controller.text) {
      _controller.text = productIngredients;
    }
  }

  Future<void> _onSubmitField(String string) async {
    final User user = ProductQuery.getUser();

    setState(() {
      _updatingIngredients = true;
    });

    try {
      await _updateIngredientsText(string, user);
    } catch (error) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
      _showError(appLocalizations.ingredients_editing_error);
    }

    setState(() {
      _updatingIngredients = false;
    });
  }

  Future<void> _onTapGetImage() async {
    setState(() {
      _updatingImage = true;
    });

    try {
      await _getImage();
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
  Future<void> _getImage() async {
    final File? croppedImageFile = await startImageCropping(context);

    // If the user cancels.
    if (croppedImageFile == null) {
      return;
    }

    // Update the image to load the new image file.
    setState(() {
      _imageProvider = FileImage(croppedImageFile);
    });

    final bool isUploaded = await uploadCapturedPicture(
      context,
      barcode: widget.product.barcode!,
      imageField: ImageField.INGREDIENTS,
      imageUri: croppedImageFile.uri,
    );
    croppedImageFile.delete();

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

      await _updateIngredientsText(nextIngredients, user);
    }
  }

  Future<void> _updateIngredientsText(String ingredientsText, User user) async {
    widget.product.ingredientsText = ingredientsText;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final bool savedAndRefreshed = await ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: widget.product,
    );
    if (!savedAndRefreshed) {
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
      if (widget.imageIngredientsUrl != null) {
        children.add(ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildZoomableImage(NetworkImage(widget.imageIngredientsUrl!)),
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
        imageIngredientsUrl: widget.imageIngredientsUrl,
        onTapGetImage: _onTapGetImage,
        onSubmitField: _onSubmitField,
        updatingIngredients: _updatingIngredients,
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
  }) : super(key: key);

  final TextEditingController controller;
  final bool updatingIngredients;
  final String? imageIngredientsUrl;
  final Future<void> Function() onTapGetImage;
  final Future<void> Function(String) onSubmitField;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData darkTheme = SmoothTheme.getThemeData(
      Brightness.dark,
      themeProvider.colorTag,
    );
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: LARGE_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: LARGE_SPACE),
                  child: _ActionButtons(
                    getImage: onTapGetImage,
                    hasImage: imageIngredientsUrl != null,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                color: Colors.black,
                child: Theme(
                  data: darkTheme,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(LARGE_SPACE),
                      child: Column(
                        children: <Widget>[
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
                            onSubmitted: onSubmitField,
                          ),
                          Text(appLocalizations
                              .ingredients_editing_instructions),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The actions for the page in a row of FloatingActionButtons.
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    Key? key,
    required this.hasImage,
    required this.getImage,
  }) : super(key: key);

  final bool hasImage;
  final VoidCallback getImage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).buttonTheme.colorScheme!;
    final List<Widget> children = hasImage
        ? <Widget>[
            FloatingActionButton.small(
              tooltip: 'Retake photo',
              backgroundColor: colorScheme.background,
              foregroundColor: colorScheme.onBackground,
              onPressed: getImage,
              child: const Icon(Icons.refresh),
            ),
            const SizedBox(width: MEDIUM_SPACE),
            FloatingActionButton.small(
              tooltip: 'Confirm',
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.check),
            ),
          ]
        : <Widget>[
            FloatingActionButton.small(
              tooltip: 'Take photo',
              backgroundColor: colorScheme.background,
              foregroundColor: colorScheme.onBackground,
              onPressed: getImage,
              child: const Icon(Icons.camera_alt),
            ),
          ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }
}
