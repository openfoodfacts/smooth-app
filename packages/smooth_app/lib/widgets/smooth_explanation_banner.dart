import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class ExplanationTitleIcon extends StatelessWidget {
  const ExplanationTitleIcon({
    required this.title,
    required Widget child,
    this.margin,
    this.padding,
    this.safeArea = true,
  })  :
        // ignore: avoid_field_initializers_in_const_classes
        type = null,
        _child = child;

  ExplanationTitleIcon.text({
    required this.title,
    required String text,
  })  :
        // ignore: avoid_field_initializers_in_const_classes
        type = null,
        margin = null,
        padding = null,
        safeArea = true,
        _child = Text(text);

  ExplanationTitleIcon.type({
    required this.type,
    required String text,
  })  :
        // ignore: avoid_field_initializers_in_const_classes
        title = null,
        margin = null,
        padding = null,
        safeArea = true,
        _child = Text(text);

  final String? title;
  final String? type;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget _child;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final String title = this.title ??
        AppLocalizations.of(context).edit_product_form_item_help(type!);

    return SmoothCardHeaderButton(
      tooltip: title,
      child: const icons.Help(),
      onTap: () {
        showSmoothModalSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return SmoothModalSheet(
              title: title,
              prefixIndicator: true,
              headerBackgroundColor:
                  SmoothCardWithRoundedHeaderTop.getHeaderColor(
                context,
              ),
              bodyPadding: margin,
              body: SmoothModalSheetBodyContainer(
                padding: padding,
                safeArea: safeArea,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: _child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ExplanationBodyTitle extends StatelessWidget {
  const ExplanationBodyTitle({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: SMALL_SPACE,
        bottom: MEDIUM_SPACE,
      ),
      child: ColoredBox(
        color: extension.primaryLight,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: LARGE_SPACE,
              vertical: SMALL_SPACE,
            ),
            child: Row(
              children: <Widget>[
                SmoothModalSheetHeaderPrefixIndicator(
                  color: lightTheme
                      ? extension.primaryUltraBlack
                      : extension.primaryLight,
                ),
                const SizedBox(width: SMALL_SPACE),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
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

class ExplanationBodyInfo extends StatelessWidget {
  const ExplanationBodyInfo({
    required this.text,
    this.icon = true,
    this.safeArea = false,
  });

  final String text;
  final bool icon;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return ColoredBox(
      color: lightTheme ? extension.primaryMedium : extension.primaryTone,
      child: ClipRect(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: safeArea ? MediaQuery.viewPaddingOf(context).bottom : 0.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (icon)
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: icons.AppIconTheme(
                    color: lightTheme
                        ? extension.primaryNormal
                        : extension.primaryMedium,
                    child: Transform.translate(
                      offset: const Offset(-17.0, 09.0),
                      child: const icons.Info(size: 55.0),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: icon ? SMALL_SPACE : LARGE_SPACE,
                    end: LARGE_SPACE,
                    top: MEDIUM_SPACE,
                    bottom: MEDIUM_SPACE,
                  ),
                  child: TextWithBoldParts(
                    text: text,
                    textStyle: TextStyle(
                      color: lightTheme ? extension.primaryDark : Colors.white,
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

class ExplanationGoodExamplesContainer extends StatelessWidget {
  const ExplanationGoodExamplesContainer({required this.items, super.key})
      : assert(items.length > 0);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Column(
      children: <Widget>[
        _ExplanationContainerTitle(
          label: AppLocalizations.of(context).explanation_section_good_examples,
          foregroundColor: Colors.white,
          backgroundColor: extension.success,
        ),
        ...items.map(
          (String item) => _ExplanationBodyListItem(
            icon: const icons.Check(size: 11.0),
            iconBackgroundColor: extension.success,
            iconPadding: EdgeInsets.zero,
            example: item,
          ),
        ),
      ],
    );
  }
}

class ExplanationBadExamplesContainer extends StatelessWidget {
  const ExplanationBadExamplesContainer(
      {required this.items, required this.explanations, super.key})
      : assert(items.length > 0),
        assert(items.length == explanations.length);

  final List<String> items;
  final List<String> explanations;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Column(
      children: <Widget>[
        _ExplanationContainerTitle(
          label: AppLocalizations.of(context).explanation_section_bad_examples,
          foregroundColor: Colors.white,
          backgroundColor: extension.error,
        ),
        ...items.mapIndexed(
          (int position, String item) => _ExplanationBodyListItem(
            icon: const icons.Close(size: 11.0),
            iconBackgroundColor: extension.error,
            iconPadding: EdgeInsetsDirectional.zero,
            example: item,
            explanation: explanations[position],
          ),
        ),
      ],
    );
  }
}

class _ExplanationContainerTitle extends StatelessWidget {
  const _ExplanationContainerTitle({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: LARGE_SPACE,
        top: MEDIUM_SPACE,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: ANGULAR_BORDER_RADIUS,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          child: Row(
            children: <Widget>[
              SmoothModalSheetHeaderPrefixIndicator(
                color: foregroundColor,
              ),
              const SizedBox(width: LARGE_SPACE),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
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

class _ExplanationBodyListItem extends StatelessWidget {
  const _ExplanationBodyListItem({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconPadding,
    required this.example,
    this.explanation,
  });

  final Widget icon;
  final Color iconBackgroundColor;
  final EdgeInsetsGeometry iconPadding;
  final String example;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
        top: 10.0,
      ),
      child: Row(
        crossAxisAlignment: explanation == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox.square(
            dimension: 24.0,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: iconBackgroundColor,
              ),
              child: Padding(
                padding: iconPadding,
                child: icon,
              ),
            ),
          ),
          SizedBox(width: explanation != null ? 11.0 : 13.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (explanation != null) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2.0),
                  child: Text(
                    explanation!,
                    style: TextStyle(
                      color: lightTheme
                          ? extension.primaryDark
                          : extension.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: VERY_SMALL_SPACE),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  color: lightTheme
                      ? extension.primaryLight
                      : extension.primaryMedium,
                  borderRadius: ROUNDED_BORDER_RADIUS,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: MEDIUM_SPACE,
                    vertical: BALANCED_SPACE,
                  ),
                  child: TextWithBoldParts(
                    text: example,
                    textStyle: const TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
