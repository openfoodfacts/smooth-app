import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/util/ui_helpers.dart';

import 'package:provider/provider.dart';

class AddNewProductPage extends StatelessWidget {
  const AddNewProductPage(
    this.barcode,
  );

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
          top: VERY_LARGE_SPACE,
          left: VERY_LARGE_SPACE,
          right: VERY_LARGE_SPACE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalizations.new_product,
            style: themeData.textTheme.headline1!
                .apply(color: themeData.colorScheme.onSurface),
          ),
          const Padding(
            padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
          ),
          Text(
            appLocalizations.add_product_take_photos_descriptive,
            style: themeData.textTheme.bodyText1!
                .apply(color: themeData.colorScheme.onSurface),
          ),
          _buildButton(
              context, appLocalizations.front_packaging_photo_button_label),
          _buildButton(
              context, appLocalizations.ingredients_photo_button_label),
          _buildButton(
              context, appLocalizations.nutritional_facts_photo_button_label),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.only(top: VERY_LARGE_SPACE),
      child: SmoothSimpleButton(
        text: text,
        minWidth: double.infinity,
        borderRadius: const BorderRadius.all(Radius.circular(SMALL_SPACE)),
        buttonColor:
            themeProvider.darkTheme ? Colors.grey : const Color(0xffeaf5fb),
        textColor: themeProvider.darkTheme
            ? Theme.of(context).colorScheme.onPrimary
            : Colors.blue,
        icon: Icon(
          Icons.camera_alt,
          color: themeProvider.darkTheme
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.blue,
        ),
        onPressed: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) =>
                  const AddNewProductPage('barcode'),
            ),
          );
        },
      ),
    );
  }
}
