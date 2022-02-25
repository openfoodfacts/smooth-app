import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/OcrIngredientsResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
//import 'package:openfoodfacts/model/Product.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/picture_capture_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Page for editing the ingredients of a product and the image of the
/// ingredients.
class EditIngredientsPage extends StatefulWidget {
  const EditIngredientsPage({
    Key? key,
    this.imageIngredientsUrl,
    required this.product,
    this.barcode,
  }) : super(key: key);

  final String? barcode;
  final Product product;
  final String? imageIngredientsUrl;

  @override
  _EditIngredientsPageState createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  final TextEditingController _controller = TextEditingController();
  ImageProvider? _imageProvider;
  bool _updatingImage = false;
  bool _updatingIngredients = false;

  static String _getIngredientsString(List<Ingredient>? ingredients) {
    if (ingredients == null) {
      return '';
    }
    String string = '';
    for (int i = 0; i < ingredients.length; i += i) {
      final Ingredient ingredient = ingredients[i];
      if (i == ingredients.length - 1) {
        string += ingredient.toString();
      } else {
        string += ', $ingredient';
      }
    }
    return string;
  }

  @override
  void initState() {
    super.initState();
    // TODO(justinmc): This doesn't work because ingredients is always null
    // (same with ingredientsText). Even when the knowledge panel for this
    // product shows ingredients.
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
    } catch(error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // TODO(justinmc): Localize.
          content: Text('Failed to save the ingredients.'),
          duration: Duration(seconds: 3),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // TODO(justinmc): Localize.
          content: Text('Failed to get a new ingredients image.'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _updatingImage = false;
    });
  }

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
      barcode: widget.product
          .barcode!, //Probably throws an error, but this is not a big problem when we got a product without a barcode
      imageField: ImageField.INGREDIENTS,
      imageUri: croppedImageFile.uri,
    );
    croppedImageFile.delete();

    if (!isUploaded) {
      throw Exception('Image could not be uploaded.');
    }

    final OpenFoodFactsLanguage? language = ProductQuery.getLanguage();
    if (language == null) {
      throw Exception("Couldn't find language.");
    }

    final User user = ProductQuery.getUser();

    // Get the ingredients from the image.
    final OcrIngredientsResult ingredientsResult =
        await OpenFoodAPIClient.extractIngredients(
            user, widget.barcode!, ProductQuery.getLanguage()!);

    final String? nextIngredients =
        ingredientsResult.ingredientsTextFromImage;
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
    // TODO(justinmc): What is the right way to save the ingredients?
    widget.product.ingredientsText = ingredientsText;
    final Status status = await OpenFoodAPIClient.saveProduct(
        user, widget.product);
    if (status.error != null) {
      throw Exception("Couldn't save the product. ${status.error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData darkTheme = SmoothTheme.getThemeData(
      Brightness.dark,
      themeProvider.colorTag,
    );

    // TODO(justinmc): Localize text.
    //final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Log Food'),
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
          if (_imageProvider != null)
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Image(
                image: _imageProvider!,
                fit: BoxFit.cover,
              ),
            ),
          if (_imageProvider == null && widget.imageIngredientsUrl != null)
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(widget.imageIngredientsUrl!),
              ),
            ),
          if (_imageProvider == null && widget.imageIngredientsUrl == null)
            Container(color: Colors.white),
          if (_updatingImage)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!_updatingImage)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _ActionButtons(
                            getImage: _onTapGetImage,
                            hasImage: widget.imageIngredientsUrl != null,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        // TODO(justinmc): Any media query stuff to do here for
                        // different screen sizes?
                        height: 400.0,
                        color: Colors.black,
                        child: Theme(
                          // TODO(justinmc): Do we have a theme like this somewhere?
                          data: darkTheme,
                          child: DefaultTextStyle(
                            style: const TextStyle(color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  // TODO(justinmc): Implement editing of ingredients text.
                                  TextField(
                                    enabled: !_updatingIngredients,
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(3.0),
                                      ),
                                    ),
                                    maxLines: null,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: _onSubmitField,
                                  ),
                                  // TODO(justinmc): Get this real localized text.
                                  const Text('TODO localized text from the mock here'),
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
            ),
        ],
      ),
    );
  }
}

// The actions for the page in a row of FloatingActionButtons.
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (!hasImage)
          FloatingActionButton.small(
            tooltip: 'Take photo',
            // TODO(justinmc): Standardized/nicer way to style these buttons?
            // At least don't duplicate the colors.
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            onPressed: getImage,
            child: const Icon(Icons.camera_alt),
          ),
        if (hasImage)
          FloatingActionButton.small(
            tooltip: 'Retake photo',
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            onPressed: getImage,
            child: const Icon(Icons.refresh),
          ),
        if (hasImage) const SizedBox(width: 12.0),
        if (hasImage)
          FloatingActionButton.small(
            tooltip: 'Confirm',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onPressed: () {},
            child: const Icon(Icons.check),
          ),
      ],
    );
  }
}
