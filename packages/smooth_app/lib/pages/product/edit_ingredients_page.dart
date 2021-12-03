import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/model/OcrIngredientsResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
//import 'package:openfoodfacts/model/Product.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:provider/provider.dart';
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
    _controller.text = _getIngredientsString(widget.product.ingredients);
  }

  @override
  void didUpdateWidget(EditIngredientsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String productIngredients = _getIngredientsString(widget.product.ingredients);
    if (productIngredients != _controller.text) {
      _controller.text = productIngredients;
    }
  }

  // TODO(justinmc): Deduplicate this with image_upload_card.dart.
  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File? croppedImageFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        androidUiSettings: const AndroidUiSettings(
          lockAspectRatio: false,
          hideBottomControls: true,
        ),
      );

      if (croppedImageFile == null) {
        return;
      }

      final OpenFoodFactsLanguage language = LanguageHelper.fromJson(
          Localizations.localeOf(context).languageCode);
      final SendImage image = SendImage(
        lang: language,
        barcode: widget.barcode!, //Probably throws an error, but this is not a big problem when we got a product without a barcode
        imageField: ImageField.INGREDIENTS,
        imageUri: croppedImageFile.uri,
      );

      // a registered user login for https://world.openfoodfacts.org/ is required
      //ToDo: Add user
      const User myUser =
          User(userId: 'smoothie-app', password: 'strawberrybanana');

      // TODO(justinmc): This doesn't seem to update the product if I refetch it.
      // query the OpenFoodFacts API
      final Status result =
          await OpenFoodAPIClient.addProductImage(myUser, image);

      // TODO(justinmc): Refetch the product, if that's how addProductImage works.
      // Doesn't seem to work in image_upload_card either.

      if (result.status != 'status ok') {
        throw Exception(
            'image could not be uploaded: ${result.error} ${result.imageId.toString()}');
      }

      // Get the ingredients from the image.
      final OcrIngredientsResult ingredientsResult = await OpenFoodAPIClient
          .extractIngredients(myUser, widget.barcode!, language);

      final String? nextIngredients = ingredientsResult.ingredientsTextFromImage;
      // Save the product's ingredients if needed.
      if (nextIngredients != null
          && _getIngredientsString(widget.product.ingredients) != nextIngredients) {
        setState(() {
          print('justin ingredients $nextIngredients');
          _controller.text = nextIngredients;
        });
        // TODO(justinmc): How do I update the product's ingredients? Lots of
        // ingredient-related fields on Product. I only see the saveProduct API
        // method, is that for editing too?
      }
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
          if (widget.imageIngredientsUrl == null)
            Container(color: Colors.white),
          if (widget.imageIngredientsUrl != null)
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(widget.imageIngredientsUrl!),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _ActionButtons(
                        getImage: _getImage,
                        hasImage: widget.imageIngredientsUrl != null,
                      ),
                    ),
                  ),
                  Container(
                    // TODO(justinmc): Rather than hardcoded height, percentage of screen?
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
                              // TODO(justinmc): Implement editing of ingredients.
                              TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                ),
                                maxLines: null,
                              ),
                              const Text('TODO text here'),
                            ],
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
            // TODO(justinmc): Is editing the product image the same API call
            // to addProductImage?
            onPressed: getImage,
            child: const Icon(Icons.refresh),
          ),
        if (hasImage)
          const SizedBox(width: 12.0),
        if (hasImage)
          FloatingActionButton.small(
            tooltip: 'Confirm',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onPressed: () {
            },
            child: const Icon(Icons.check),
          ),
      ],
    );
  }
}
