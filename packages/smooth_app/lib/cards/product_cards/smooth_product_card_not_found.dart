import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/product/add_new_product_page.dart';

class SmoothProductCardNotFound extends StatelessWidget {
  const SmoothProductCardNotFound({
    required this.barcode,
    this.callback,
    this.elevation = 0.0,
  });

  final VoidCallback? callback;
  final double elevation;
  final String barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SmoothCard(
        elevation: elevation,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: constraints.maxHeight * 0.25,
            horizontal: constraints.maxWidth * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                appLocalizations.missing_product,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2,
              ),
              Text(
                appLocalizations.add_product_take_photos,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Padding(
                padding: const EdgeInsets.only(top: LARGE_SPACE),
                child: SmoothLargeButtonWithIcon(
                  text: appLocalizations.add_product_information_button_label,
                  icon: Icons.add,
                  padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                  onPressed: () {
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) =>
                            AddNewProductPage(barcode),
                      ),
                    );
                    if (callback != null) {
                      callback!();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
