import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
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

        return DividerTheme(
          data: const DividerThemeData(
            color: Colors.black,
            space: 1.0,
            thickness: 1.0,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: VERY_SMALL_SPACE,
              bottom: SMALL_SPACE,
            ),
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
                    child: Padding(
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
                              textStyle: const TextStyle(
                                fontSize: 14.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (onTap != null)
                            const _ExplanationBannerLearnMoreButton(),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
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

    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.black),
            ),
          ),
          child: ColoredBox(
            color: theme.greyLight,
            child: Row(
              children: <Widget>[
                ColoredBox(
                  color: theme.greyDark,
                  child: const SizedBox(
                    height: double.infinity,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: BALANCED_SPACE,
                        end: BALANCED_SPACE + 1.0,
                      ),
                      child: icons.Help(color: Colors.white, size: 21.0),
                    ),
                  ),
                ),
                const VerticalDivider(),
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
                        color: Colors.black,
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
                    message: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    child: InkWell(
                      onTap: onTap,
                      child: const Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: BALANCED_SPACE + 1.0,
                          end: BALANCED_SPACE,
                          top: SMALL_SPACE,
                          bottom: SMALL_SPACE,
                        ),
                        child: icons.Close(size: 14.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    final TextDirection textDirection = Directionality.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: SMALL_SPACE,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 2.0),
          child: Text(
            AppLocalizations.of(context).explanation_card_learn_more_button,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
        ),
        icons.AppIconTheme(
          size: 10.0,
          child: switch (textDirection) {
            TextDirection.ltr => const icons.DoubleChevron.right(),
            TextDirection.rtl => const icons.DoubleChevron.left(),
          },
        ),
      ],
    );
  }
}
