import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/border_radius_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/user_feedback_helper.dart';
import 'package:smooth_app/pages/app_review.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/bottom_cards/scan_bottom_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ScanAppReview extends StatelessWidget {
  const ScanAppReview({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ScanBottomCardContainer(
      title: appLocalizations.app_review_title,
      onClose: () => context.read<AppReviewProvider>().hide(),
      body: Row(
        children: <Widget>[
          Expanded(
            child: _AppReviewItem(
              asset: 'assets/misc/tagline_0.svg',
              text: appLocalizations.app_review_low,
              backgroundColor: const Color(0xFFD44C29),
              borderRadius: BorderRadiusHelper.fromDirectional(
                context: context,
                bottomStart: ScanBottomCardContainer.radius,
              ),
              onTap: () => _showUserFeedBackModalSheet(
                context,
                AppReviewResult.unsatisfied,
              ),
            ),
          ),
          Expanded(
            child: _AppReviewItem(
              asset: 'assets/misc/tagline_1.svg',
              text: appLocalizations.app_review_medium,
              backgroundColor: const Color(0xFFFF8C14),
              borderRadius: BorderRadius.zero,
              onTap: () => _showUserFeedBackModalSheet(
                context,
                AppReviewResult.neutral,
              ),
            ),
          ),
          Expanded(
            child: _AppReviewItem(
              asset: 'assets/misc/tagline_2.svg',
              text: appLocalizations.app_review_high,
              backgroundColor: const Color(0xFF6CB564),
              borderRadius: BorderRadiusHelper.fromDirectional(
                context: context,
                bottomEnd: ScanBottomCardContainer.radius,
              ),
              onTap: () async {
                final AppReviewProvider appReview =
                    context.read<AppReviewProvider>();
                await ApplicationStore.openAppReview();
                appReview.markAsReviewed(AppReviewResult.satisfied);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserFeedBackModalSheet(
    BuildContext context,
    AppReviewResult result,
  ) async {
    final SmoothColorsThemeExtension colors =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme(listen: false);

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final AppReviewProvider appReview = context.read<AppReviewProvider>();

    final bool? res = await showSmoothModalSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return SmoothModalSheet(
          title: appLocalizations.app_review_feedback_modal_title,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                TextWithBoldParts(
                  text: appLocalizations.app_review_feedback_modal_content,
                  textStyle: const TextStyle(fontSize: 14.0),
                ),
                const SizedBox(height: LARGE_SPACE),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: _AppReviewButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    text: appLocalizations.app_review_feedback_modal_open_form,
                    backgroundColor:
                        lightTheme ? colors.primaryBlack : colors.primaryLight,
                    foregroundColor:
                        lightTheme ? Colors.white : colors.primaryDark,
                    icon: DecoratedBox(
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        color: lightTheme ? Colors.white : colors.primaryDark,
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(
                          VERY_SMALL_SPACE,
                        ),
                        child: icons.Arrow.right(
                          size: 12.0,
                          color: lightTheme
                              ? colors.primaryBlack
                              : colors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SMALL_SPACE),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: _AppReviewButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    text: appLocalizations.app_review_feedback_modal_later,
                    backgroundColor:
                        lightTheme ? colors.primaryLight : colors.primaryDark,
                    foregroundColor:
                        lightTheme ? colors.primaryDark : colors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (context.mounted) {
      if (res == true) {
        appReview.markAsReviewed(AppReviewResult.unsatisfied);
        LaunchUrlHelper.launchURLInWebViewOrBrowser(
          context,
          UserFeedbackHelper.getFeedbackFormLink(),
        );
      } else {
        appReview.hide();
      }
    }
  }
}

class _AppReviewButton extends StatelessWidget {
  const _AppReviewButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BALANCED_SPACE,
          vertical: MEDIUM_SPACE,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          AutoSizeText(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
            maxLines: 1,
          ),
          if (icon != null) ...<Widget>[
            const SizedBox(width: SMALL_SPACE),
            FittedBox(
              child: icon,
            )
          ],
        ],
      ),
    );
  }
}

class _AppReviewItem extends StatelessWidget {
  const _AppReviewItem({
    required this.asset,
    required this.text,
    required this.backgroundColor,
    required this.borderRadius,
    required this.onTap,
  });

  final String asset;
  final String text;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 1.0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExcludeSemantics(
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: backgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                    child: SvgPicture.asset(asset),
                  ),
                ),
              ),
              const SizedBox(height: SMALL_SPACE),
              Text(
                '$text\n',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
