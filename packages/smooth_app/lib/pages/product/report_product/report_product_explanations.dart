import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

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

    return SliverPadding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: MEDIUM_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      sliver: SliverToBoxAdapter(
        child: SmoothCardWithRoundedHeader(
          title: appLocalizations.report_product_explanations_title,
          leading: const icons.Flag(),
          contentPadding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      appLocalizations.report_product_explanations_main_text,
                    ),
                    const SizedBox(
                      height: LARGE_SPACE,
                    ),
                    Text(
                      appLocalizations
                          .report_product_explanations_secondary_text,
                    ),
                  ],
                ),
              ),
              _ExplanationInkWell(
                icon: const icons.Camera.filled(size: 15.0),
                text: appLocalizations.report_product_explanations_take_picture,
                onTap: () {},
              ),
              const Divider(
                color: Color(0x26000000),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: ROUNDED_RADIUS,
                ),
                child: _ExplanationInkWell(
                  icon: const icons.Edit(size: 15.0),
                  text: appLocalizations.report_product_explanations_report,
                  onTap: () {},
                ),
              ),
            ],
          ),
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
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.red,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: MEDIUM_SPACE,
          ),
          color: context.extension<SmoothColorsThemeExtension>().greyLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              icon,
              const SizedBox(width: BALANCED_SPACE),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
