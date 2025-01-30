import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ReportProductHeader extends StatelessWidget {
  const ReportProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.read<ProductImage?>() == null) {
      return const _ReportProductHeaderProduct();
    } else {
      return const _ReportProductHeaderPhoto();
    }
  }
}

class _ReportProductHeaderProduct extends StatelessWidget {
  const _ReportProductHeaderProduct();

  @override
  Widget build(BuildContext context) {
    // TODO(g123k): Implement this later
    return const SliverToBoxAdapter(
      child: EMPTY_WIDGET,
    );
  }
}

class _ReportProductHeaderPhoto extends StatelessWidget {
  const _ReportProductHeaderPhoto();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();
    final ProductImage image = context.read<ProductImage?>()!;

    return SliverToBoxAdapter(
      child: SmoothCardWithRoundedHeader(
        title: appLocalizations.report_product_header_title,
        leading: const icons.Flag(),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Row(
          children: <Widget>[
            ProductPicture.fromProduct(
              product: product,
              imageField: image.field!,
              size: const Size.square(90.0),
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              imageFoundBorder: 1.0,
              imageNotFoundBorder: 1.0,
            ),
            const SizedBox(width: SMALL_SPACE),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  image.field!.getImagePageTitle(appLocalizations),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: MEDIUM_SPACE),
                Text(
                  appLocalizations.report_product_header_contributor(
                      image.contributor ?? '-'),
                ),
                Text(
                  appLocalizations.report_product_header_date(
                    image.uploaded != null
                        ? DateFormat.yMMMMEEEEd().format(image.uploaded!)
                        : '-',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
