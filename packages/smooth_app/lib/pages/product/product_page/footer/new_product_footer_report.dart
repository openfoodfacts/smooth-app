import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/footer/new_product_footer.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ProductFooterReportButton extends StatelessWidget {
  const ProductFooterReportButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ProductFooterButton(
      label: appLocalizations.edit_product_label_short,
      semanticsLabel: appLocalizations.edit_product_label,
      icon: const icons.Edit(),
      onTap: () {
        // TODO(g123): Implement Nutripatrol
      },
    );
  }
}
