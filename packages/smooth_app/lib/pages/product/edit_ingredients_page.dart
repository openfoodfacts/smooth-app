import 'package:flutter/material.dart';
import 'package:openfoodfacts/model/Ingredient.dart';
//import 'package:openfoodfacts/model/Product.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Page for editing the ingredients of a product and the image of the
/// ingredients.
class EditIngredientsPage extends StatelessWidget {
  EditIngredientsPage({
    Key? key,
    required this.ingredients,
    this.imageProvider,
  }) : _controller = TextEditingController(text: _getIngredientsString(ingredients)),
       super(key: key);

  final TextEditingController _controller;

  final List<Ingredient> ingredients;
  final ImageProvider? imageProvider;

  static String _getIngredientsString(List<Ingredient> ingredients) {
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
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final ThemeData darkTheme = SmoothTheme.getThemeData(
      Brightness.dark,
      themeProvider.colorTag,
    );

    // TODO(justinmc): Localize text.
    //final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Food'),
      ),
      /*
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Image(
          fit: BoxFit.cover,
          image: imageProvider!,
        ),
      ),
      */
      body: Stack(
        children: <Widget>[
          if (imageProvider == null)
            Container(color: Colors.white),
          if (imageProvider != null)
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Image(
                fit: BoxFit.cover,
                image: imageProvider!,
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
                        hasImage: imageProvider != null,
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
  }) : super(key: key);

  final bool hasImage;

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
            onPressed: () {
            },
            child: const Icon(Icons.camera_alt),
          ),
        if (hasImage)
          FloatingActionButton.small(
            tooltip: 'Retake photo',
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            onPressed: () {
            },
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
