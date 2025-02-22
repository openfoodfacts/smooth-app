import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    String getLabel(Reason reason) {
      return switch (reason) {
        Reason.mismatching =>
          appLocalizations.report_product_reasons_photo_dont_match_product,
        Reason.inappropriate =>
          appLocalizations.report_product_reasons_photo_inappropriate,
        Reason.other => appLocalizations.report_product_reasons_photo_other,
      };
    }

    return SliverPadding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      sliver: SliverToBoxAdapter(
        child: SmoothCardWithRoundedHeader(
          title: appLocalizations.report_product_reason_title,
          leading: const icons.Flag(),
          contentPadding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < Reason.values.length; i++) ...<Widget>[
                ListTile(
                  title: Text(getLabel(Reason.values[i])),
                  trailing: Icon(
                    const icons.Chevron.right().icon,
                    size: 15.0,
                  ),
                  onTap: () {
                    print('Sélectionné : ${Reason.values[i]}');
                  },
                ),
                if (i < Reason.values.length - 1) const Divider(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum Reason {
  mismatching,
  inappropriate,
  other,
}
