import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ReportProductComment extends StatelessWidget {
  const ReportProductComment({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportProductComment();
  }
}

class _ReportProductComment extends StatelessWidget {
  const _ReportProductComment();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Product product = context.read<Product>();

    return SliverToBoxAdapter(
      child: SmoothCardWithRoundedHeader(
        title: appLocalizations.report_product_comment_title,
        leading: const icons.Flag(),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 200.0,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12.0,
                  ),
                  hintText: appLocalizations.report_product_comment_hint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
