import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class ProductPageExplanationBanner extends StatelessWidget {
  const ProductPageExplanationBanner({
    required this.title,
    required this.text,
    required this.shouldShowBanner,
    required this.hideBanner,
    this.textSpacing = VERY_SMALL_SPACE,
    this.onTap,
    super.key,
  });

  final String title;
  final List<String> text;
  final double textSpacing;
  final bool Function(UserPreferences) shouldShowBanner;
  final Future<void> Function(UserPreferences) hideBanner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConsumerFilter<UserPreferences>(
      buildWhen: (UserPreferences? old, UserPreferences prefs) {
        if (old == null) {
          return true;
        }

        return shouldShowBanner.call(old) != shouldShowBanner.call(prefs);
      },
      builder: (BuildContext context, UserPreferences prefs, _) {
        if (!shouldShowBanner(prefs)) {
          return EMPTY_WIDGET;
        }

        final SmoothColorsThemeExtension theme = context
            .extension<SmoothColorsThemeExtension>();
        final bool lightTheme = context.lightTheme();

        return Padding(
          padding: const EdgeInsetsDirectional.only(bottom: LARGE_SPACE),
          child: ClipRRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ExplanationCardTitle(
                  title: title,
                  onTap: () => hideBanner.call(prefs),
                ),
                InkWell(
                  onTap: onTap,
                  child: Ink(
                    color: lightTheme
                        ? theme.primaryLight
                        : theme.primaryUltraBlack,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SMALL_SPACE,
                      vertical: SMALL_SPACE,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: textSpacing,
                      children: <Widget>[
                        ...text.map(
                          (String txt) => TextWithBoldParts(
                            text: txt,
                            textStyle: TextStyle(
                              fontSize: 14.5,
                              color: lightTheme
                                  ? Colors.black87
                                  : theme.primaryLight,
                            ),
                          ),
                        ),
                        if (onTap != null)
                          const _ExplanationBannerLearnMoreButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExplanationCardTitle extends StatelessWidget {
  const _ExplanationCardTitle({required this.onTap, required this.title});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: ColoredBox(
          color: lightTheme ? theme.secondaryVibrant : theme.secondaryNormal,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 6.0),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsetsDirectional.symmetric(
                  vertical: SMALL_SPACE,
                ),
                child: SizedBox(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: BALANCED_SPACE,
                      end: BALANCED_SPACE,
                    ),
                    child: icons.Help(
                      color: theme.secondaryVibrant,
                      size: 21.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsetsDirectional.only(
                    start: SMALL_SPACE,
                    end: SMALL_SPACE,
                    top: SMALL_SPACE,
                    bottom: SMALL_SPACE + 1.0,
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: kMinInteractiveDimension,
                height: double.infinity,
                child: Tooltip(
                  message: MaterialLocalizations.of(context).closeButtonTooltip,
                  child: InkWell(
                    onTap: onTap,
                    child: const Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: BALANCED_SPACE + 1.0,
                        end: BALANCED_SPACE,
                        top: SMALL_SPACE,
                        bottom: SMALL_SPACE,
                      ),
                      child: icons.Close(size: 14.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationBannerLearnMoreButton extends StatelessWidget {
  const _ExplanationBannerLearnMoreButton();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: lightTheme ? Colors.white : theme.primaryDark,
            borderRadius: ANGULAR_BORDER_RADIUS,
            border: Border.all(
              color: lightTheme
                  ? theme.secondaryVibrant
                  : theme.secondaryNormal,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: LARGE_SPACE,
              end: LARGE_SPACE,
              top: VERY_SMALL_SPACE,
              bottom: VERY_SMALL_SPACE + 2.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: SMALL_SPACE,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 1.5),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).explanation_card_learn_more_button,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                icons.AppIconTheme(
                  size: 9.0,
                  child: icons.DoubleChevron.horizontalDirectional(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
