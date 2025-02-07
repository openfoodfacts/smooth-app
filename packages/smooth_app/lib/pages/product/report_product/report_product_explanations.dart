import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ReportProductExplanations extends StatelessWidget {
  const ReportProductExplanations({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportProductExplanations();
  }
}

class _ReportProductExplanations extends StatelessWidget {
  const _ReportProductExplanations();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    return SliverToBoxAdapter(
      child: SmoothCardWithRoundedHeader(
        title: appLocalizations.report_product_explanations_title,
        leading: const icons.Flag(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
              ),
              child:
                  Text(appLocalizations.report_product_explanations_main_text),
            ),
            const SizedBox(
              height: LARGE_SPACE,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
                vertical: SMALL_SPACE,
              ),
              child: Text(
                  appLocalizations.report_product_explanations_secondary_text),
            ),
            _ExplanationInkWell(
              icon: const icons.Camera.filled(size: 15.0),
              text: appLocalizations.report_product_explanations_take_picture,
              onTap: () {},
            ),
            _ExplanationInkWell(
              icon: const icons.Edit(size: 15.0),
              text: appLocalizations.report_product_explanations_report,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationInkWell extends StatelessWidget {
  const _ExplanationInkWell({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final Widget icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: SMALL_SPACE,
        ),
        color: LIGHT_GREY_COLOR,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            icon,
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }
}
