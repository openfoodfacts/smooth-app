import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ReportProductReason extends StatelessWidget {
  const ReportProductReason({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportProductReason();
  }
}

class _ReportProductReason extends StatelessWidget {
  const _ReportProductReason();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    String getLabel(Reason reason) {
      switch (reason) {
        case Reason.missmatching:
          return appLocalizations
              .report_product_reasons_photo_dont_match_product;
        case Reason.inappropriate:
          return appLocalizations.report_product_reasons_photo_inappropriate;
        case Reason.other:
          return appLocalizations.report_product_reasons_photo_other;
        default:
          return "";
      }
    }

    return SliverToBoxAdapter(
      child: SmoothCardWithRoundedHeader(
        title: appLocalizations.report_product_reason_title,
        leading: const icons.Flag(),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Column(
          children: [
            for (int i = 0; i < Reason.values.length; i++) ...[
              ListTile(
                title: Text(getLabel(Reason.values[i])),
                trailing: Icon(
                  const icons.Chevron.right().icon,
                  size: 15.0,
                ),
                onTap: () {
                  print("Sélectionné : ${Reason.values[i]}");
                },
              ),
              if (i < Reason.values.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}

enum Reason {
  missmatching,
  inappropriate,
  other,
}
