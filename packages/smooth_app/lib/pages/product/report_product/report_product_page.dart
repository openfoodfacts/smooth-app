import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/report_product/report_product_header.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class ReportProductPage extends StatelessWidget {
  const ReportProductPage({
    required this.product,
    super.key,
  }) : image = null;

  const ReportProductPage.image({
    required this.product,
    required this.image,
    super.key,
  });

  final Product product;
  final ProductImage? image;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<Product>(
          create: (_) => product,
        ),
        Provider<ProductImage?>(
          create: (_) => image,
        ),
      ],
      child: SmoothScaffold2(
        topBar: SmoothTopBar2(
          title: image != null
              ? appLocalizations.report_product_photo_title
              : appLocalizations.report_product_title,
          leadingAction: SmoothTopBarLeadingAction.close,
        ),
        bottomBar: ProductBottomButtonsBar(
          onSave: () {
            // TODO: Envoyer la requête à Nutripatrol
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
        children: const <Widget>[
          ReportProductHeader(),
        ],
      ),
    );
  }
}
