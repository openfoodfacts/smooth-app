import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class NutritionImageViewer extends StatelessWidget {
  const NutritionImageViewer({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return EMPTY_WIDGET;
    }

    return ExcludeSemantics(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.2,
        width: double.infinity,
        child: ColoredBox(
          color: context.lightTheme() ? Colors.grey[850]! : Colors.grey[800]!,
          child: InteractiveViewer(
            child: Image(
              image: TransientFile.fromProduct(
                context.watch<Product>(),
                ImageField.NUTRITION,
                ProductQuery.getLanguage(),
              ).getImageProvider()!,
            ),
          ),
        ),
      ),
    );
  }
}
