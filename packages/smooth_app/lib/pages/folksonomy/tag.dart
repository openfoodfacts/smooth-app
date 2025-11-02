import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_product_tag_extension.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class Tag extends StatelessWidget {
  const Tag({required this.productTag});

  final ProductTag productTag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool isAnUrl = productTag.isAnUrl();
    final Widget result = Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: VERY_SMALL_SPACE,
          horizontal: SMALL_SPACE,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          '${productTag.key}${appLocalizations.sep}: ${productTag.value}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isAnUrl
                ? Colors.blue
                : context.darkTheme()
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
    if (!isAnUrl) {
      return result;
    }
    return InkWell(
      onTap: () async => productTag.visitUrl(context),
      child: result,
    );
  }
}
