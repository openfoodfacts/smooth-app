import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/color_extension.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_page/new_product_page.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_banner.dart';

class ProductPageLoadingIndicator extends StatelessWidget {
  const ProductPageLoadingIndicator({
    this.addSafeArea = false,
    super.key,
  });

  final bool addSafeArea;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final bool lightTheme = context.lightTheme();
    final Color color = context.watchSafe<ProductPageCompatibility>()?.color ??
        (lightTheme ? Colors.grey : Colors.grey[600]!);

    return SmoothBanner(
      icon: CloudUploadAnimation(
        size: MediaQuery.sizeOf(context).width * 0.10,
      ),
      iconAlignment: AlignmentDirectional.center,
      iconBackgroundColor: color,
      title: appLocalizations.product_page_pending_operations_banner_title,
      titleColor: lightTheme ? null : Colors.white,
      contentBackgroundColor:
          lightTheme ? color.lighten(0.6) : color.darken(0.3),
      contentColor: lightTheme ? null : Colors.grey[200],
      topShadow: true,
      content: appLocalizations.product_page_pending_operations_banner_message,
      addSafeArea: addSafeArea,
    );
  }
}
