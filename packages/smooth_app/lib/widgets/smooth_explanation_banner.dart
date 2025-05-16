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
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
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
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

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
              headerBackgroundColor: context.lightTheme(listen: false)
                  ? extension.primaryBlack
                  : extension.primarySemiDark,
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
    this.backgroundColor,
    this.safeArea = false,
  });

  final String text;
  final Color? backgroundColor;
  final bool icon;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return ColoredBox(
      color: backgroundColor ??
          (lightTheme ? extension.primaryMedium : Colors.white12),
      child: ClipRect(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: safeArea ? MediaQuery.viewPaddingOf(context).bottom : 0.0,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LARGE_SPACE,
                vertical: MEDIUM_SPACE,
              ),
              child: TextWithBoldParts(
                text: text,
                textStyle: TextStyle(
                  color: lightTheme ? extension.primaryDark : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExplanationTextContainer extends StatelessWidget {
  const ExplanationTextContainer({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<ExplanationTextContainerContent> items;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ExplanationContainerTitle(
          label: title,
          foregroundColor: Colors.white,
          backgroundColor:
              lightTheme ? extension.primarySemiDark : extension.primaryDark,
        ),
        ...items.mapIndexed(
          (int position, ExplanationTextContainerContent item) {
            return switch (item) {
              ExplanationTextContainerContentText() => Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: LARGE_SPACE,
                    end: LARGE_SPACE,
                    top: MEDIUM_SPACE,
                    bottom: VERY_SMALL_SPACE,
                  ),
                  child: TextWithBoldParts(
                    text: item.text,
                    textStyle: TextStyle(
                      color: lightTheme ? extension.primaryDark : Colors.white,
                    ),
                  ),
                ),
              ExplanationTextContainerContentItem() => Padding(
                  padding: item.padding ??
                      const EdgeInsetsDirectional.only(
                        top: SMALL_SPACE,
                      ),
                  child: _ExplanationBodyListItem(
                    icon: icons.Arrow.right(
                      size: 11.0,
                      color: lightTheme ? null : extension.primarySemiDark,
                    ),
                    iconBackgroundColor: lightTheme
                        ? extension.primarySemiDark
                        : extension.primaryLight,
                    iconPadding: EdgeInsets.zero,
                    title: item.text,
                    text: item.example,
                    visualExample: item.visualExample,
                    visualExamplePosition: item.visualExamplePosition,
                  ),
                ),
            };
          },
        ),
      ],
    );
  }
}

sealed class ExplanationTextContainerContent {}

class ExplanationTextContainerContentText
    extends ExplanationTextContainerContent {
  ExplanationTextContainerContentText({required this.text});

  final String text;
}

class ExplanationTextContainerContentItem
    extends ExplanationTextContainerContent {
  ExplanationTextContainerContentItem({
    required this.text,
    this.example,
    this.visualExample,
    this.visualExamplePosition,
    this.padding,
  });

  final String text;
  final String? example;
  final Widget? visualExample;
  final ExplanationVisualExamplePosition? visualExamplePosition;
  final EdgeInsetsGeometry? padding;
}

class ExplanationGoodExamplesContainer extends StatelessWidget {
  const ExplanationGoodExamplesContainer({
    required this.items,
    super.key,
  }) : assert(items.length > 0);

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
            text: item,
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
            text: item,
            title: explanations[position],
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
        bottom: VERY_SMALL_SPACE,
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
                    fontSize: 16.0,
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
    this.title,
    this.text,
    this.visualExample,
    this.visualExamplePosition = ExplanationVisualExamplePosition.afterExample,
  });

  final Widget icon;
  final Color iconBackgroundColor;
  final EdgeInsetsGeometry iconPadding;
  final String? text;
  final String? title;
  final Widget? visualExample;
  final ExplanationVisualExamplePosition? visualExamplePosition;

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
        crossAxisAlignment: title == null
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
          SizedBox(width: title != null ? 11.0 : 13.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 2.0),
                    child: TextWithBoldParts(
                      text: title!,
                      textStyle: TextStyle(
                        color: lightTheme
                            ? extension.primaryDark
                            : extension.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                      boldTextStyle: TextStyle(
                        color: lightTheme
                            ? extension.primaryUltraBlack
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: VERY_SMALL_SPACE),
                ],
                if (visualExample != null &&
                    visualExamplePosition ==
                        ExplanationVisualExamplePosition.afterTitle)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: VERY_SMALL_SPACE,
                      bottom: BALANCED_SPACE,
                    ),
                    child: visualExample,
                  ),
                if (text != null)
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
                        text: text!,
                        textStyle: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                if (visualExample != null &&
                    visualExamplePosition ==
                        ExplanationVisualExamplePosition
                            .afterExample) ...<Widget>[
                  const SizedBox(height: VERY_SMALL_SPACE),
                  visualExample!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ExplanationVisualExamplePosition {
  afterTitle,
  afterExample,
}
