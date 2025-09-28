import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/physics.dart';
import 'package:smooth_app/pages/guides/helpers/guides_header.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';
import 'package:vector_graphics/vector_graphics.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({
    required this.header,
    required this.body,
    required this.pageName,
    this.footer,
    super.key,
  }) : assert(pageName.length > 0);

  final Widget header;
  final List<Widget> body;
  final Widget? footer;

  // Page name for the Analytics event
  final String pageName;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      body: _GuidesPageBody(
        pageName: pageName,
        slivers: <Widget>[header, ...body, if (footer != null) footer!],
      ),
    );
  }
}

class _GuidesPageBody extends StatefulWidget {
  const _GuidesPageBody({required this.slivers, required this.pageName})
    : assert(pageName.length > 0);

  final List<Widget> slivers;
  final String pageName;

  @override
  State<_GuidesPageBody> createState() => _GuidesPageBodyState();
}

class _GuidesPageBodyState extends State<_GuidesPageBody>
    with TraceableClientMixin {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScrollController>(
      create: (_) => _controller,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          /// Snap to positions when the user stops scrolling.
          if (notification is ScrollEndNotification) {
            if (notification.dragDetails == null) {
              return true;
            }

            if (notification.metrics.pixels < 125) {
              Future<void>.delayed(Duration.zero, () {
                _controller.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              });
              return true;
            } else if (notification.metrics.pixels < 250) {
              Future<void>.delayed(Duration.zero, () {
                _controller.animateTo(
                  250 - kToolbarHeight,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              });
            }
            return true;
          }
          return false;
        },
        child: CustomScrollView(
          controller: _controller,
          physics: VerticalSnapScrollPhysics.get(
            lastStepBlocking: false,
            steps: const <double>[
              0,
              GuidesHeader.HEADER_HEIGHT - kToolbarHeight,
            ],
          ),
          slivers: widget.slivers,
        ),
      ),
    );
  }

  @override
  String get actionName => 'Opened ${widget.pageName}';
}

class GuidesParagraph extends StatelessWidget {
  const GuidesParagraph({
    required this.title,
    required this.content,
    super.key,
  });

  static const double _HORIZONTAL_PADDING = 20.0;

  final String title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: <Widget>[
        SliverPadding(
          padding: const EdgeInsetsDirectional.only(bottom: 8.0),
          sliver: SliverPinnedHeader(
            child: _GuidesParagraphTitle(title: title),
          ),
        ),
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 15.0, height: 1.75),
          child: AppIconTheme(
            size: 21.0,
            color: Colors.white,
            child: SliverPadding(
              padding: const EdgeInsetsDirectional.only(bottom: 15.0),
              sliver: SliverList.builder(
                itemCount: content.length,
                itemBuilder: (BuildContext context, int position) {
                  return content[position];
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuidesParagraphTitle extends StatelessWidget {
  const _GuidesParagraphTitle({required this.title}) : assert(title.length > 0);

  final String title;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    return Semantics(
      label: title,
      header: true,
      excludeSemantics: true,
      child: ColoredBox(
        color: colors.primaryDark,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: GuidesParagraph._HORIZONTAL_PADDING,
            vertical: BALANCED_SPACE,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            spacing: BALANCED_SPACE,
            children: <Widget>[
              const Padding(
                padding: EdgeInsetsDirectional.only(top: 3.3),
                child: _GuidesParagraphArrow(),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
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

class _GuidesParagraphArrow extends StatelessWidget {
  const _GuidesParagraphArrow();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    return SizedBox.square(
      dimension: 20.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.secondaryVibrant,
          shape: BoxShape.circle,
        ),
        child: const Arrow.right(color: Colors.white, size: 12.0),
      ),
    );
  }
}

class GuidesText extends StatelessWidget {
  const GuidesText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: BALANCED_SPACE,
        start: GuidesParagraph._HORIZONTAL_PADDING,
        end: GuidesParagraph._HORIZONTAL_PADDING,
      ),
      child: _GuidesFormattedText(text: text),
    );
  }
}

class _GuidesFormattedText extends StatelessWidget {
  const _GuidesFormattedText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TextWithBoldParts(text: text);
  }
}

class GuidesIllustratedText extends StatelessWidget {
  const GuidesIllustratedText({
    required this.text,
    required this.imagePath,
    required this.desiredWidthPercent,
    super.key,
  }) : assert(text.length > 0),
       assert(imagePath.length > 0);

  final String text;
  final String imagePath;
  final double? desiredWidthPercent;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();
    final int imageWidth =
        (desiredWidthPercent != null ? desiredWidthPercent! : 0.25) *
        100.0 ~/
        1;

    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: VERY_LARGE_SPACE),
        child: ColoredBox(
          color: colors.primaryMedium,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: 15.0,
              horizontal: GuidesParagraph._HORIZONTAL_PADDING,
            ),
            child: Row(
              spacing: 15.0,
              children: <Widget>[
                Expanded(
                  flex: imageWidth,
                  child: _ImageFromAssets(imagePath: imagePath),
                ),
                Expanded(
                  flex: 100 - imageWidth,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(color: Colors.black),
                    child: _GuidesFormattedText(text: text),
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

class GuidesTitleContainer extends StatelessWidget {
  const GuidesTitleContainer({
    required this.child,
    required this.icon,
    required this.title,
    super.key,
  }) : assert(title.length > 0);

  final Widget child;
  final AppIcon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 15.0,
        bottom: 15.0,
        start: GuidesParagraph._HORIZONTAL_PADDING - 2.0,
        end: GuidesParagraph._HORIZONTAL_PADDING - 2.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15.0,
        children: <Widget>[
          _GuidesTextTitle(title: title, icon: icon),
          child,
        ],
      ),
    );
  }
}

class GuidesTitleWithText extends StatelessWidget {
  const GuidesTitleWithText({
    required this.title,
    required this.icon,
    required this.text,
    super.key,
  });

  final String title;
  final AppIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GuidesTitleContainer(
      title: title,
      icon: icon,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: _GuidesFormattedText(text: text),
      ),
    );
  }
}

class GuidesTitleWithBulletPoints extends StatelessWidget {
  const GuidesTitleWithBulletPoints({
    required this.title,
    required this.icon,
    required this.bulletPoints,
    this.type = BulletPointType.arrow,
    super.key,
  });

  final String title;
  final AppIcon icon;
  final List<String> bulletPoints;
  final BulletPointType type;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    return GuidesTitleContainer(
      title: title,
      icon: icon,
      child: Column(
        children: bulletPoints
            .mapIndexed(
              (int position, String item) => Padding(
                padding: EdgeInsetsDirectional.only(
                  start: LARGE_SPACE,
                  end: LARGE_SPACE,
                  top: type == BulletPointType.arrow ? 8.0 : 0.0,
                ),
                child: Row(
                  spacing: 10.0,
                  children: <Widget>[
                    switch (type) {
                      BulletPointType.arrow => icons.CircledArrow.right(
                        type: CircledArrowType.normal,
                        circleColor: colors.primarySemiDark,
                      ),
                      BulletPointType.number => Container(
                        decoration: BoxDecoration(
                          color: colors.primarySemiDark,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
                        child: Text(
                          (position + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    },
                    Expanded(child: _GuidesFormattedText(text: item)),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

enum BulletPointType { arrow, number }

class _GuidesTextTitle extends StatelessWidget {
  const _GuidesTextTitle({required this.title, required this.icon})
    : assert(title.length > 0);

  final String title;
  final AppIcon icon;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: colors.secondaryVibrant,
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 14.0),
          icon,
          const SizedBox(width: 11.0),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: colors.primarySemiDark,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 14.0,
                  end: 14.0,
                  top: 5.0,
                  bottom: 6.0,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GuidesContainer extends StatelessWidget {
  const GuidesContainer({
    required this.child,
    this.color,
    this.margin,
    this.padding,
    super.key,
  });

  final Widget child;

  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    return Padding(
      padding:
          margin ??
          const EdgeInsetsDirectional.only(
            top: BALANCED_SPACE,
            start: GuidesParagraph._HORIZONTAL_PADDING,
            end: GuidesParagraph._HORIZONTAL_PADDING,
          ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              color ??
              (context.lightTheme()
                  ? colors.primaryMedium
                  : colors.primaryUltraBlack),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding:
              padding ??
              const EdgeInsetsDirectional.only(
                top: 14.0,
                bottom: SMALL_SPACE,
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
              ),
          child: child,
        ),
      ),
    );
  }
}

class GuidesGrid extends StatelessWidget {
  const GuidesGrid({
    required this.items,
    this.columns,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.itemAssetHeight,
    super.key,
  });

  final List<GuidesGridItem> items;
  final double? itemAssetHeight;
  final double? horizontalSpacing;
  final double? verticalSpacing;
  final int? columns;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final double spacing = horizontalSpacing ?? 0.0;
    final int columns = this.columns ?? 3;

    return GuidesContainer(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: SMALL_SPACE,
        horizontal: BALANCED_SPACE,
      ),
      margin: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
      color: lightTheme ? null : colors.primaryTone,
      child: SizedBox(
        width: double.infinity,
        child: LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            return Wrap(
              spacing: spacing,
              runSpacing: verticalSpacing ?? 0.0,
              children: items
                  .map(
                    (GuidesGridItem item) => SizedBox(
                      width:
                          constraints.maxWidth / columns -
                          (spacing * (columns - 1) / columns),
                      child: Material(
                        color: lightTheme
                            ? colors.primaryLight
                            : colors.primaryUltraBlack,
                        borderRadius: BorderRadius.circular(15.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: SMALL_SPACE,
                            vertical: BALANCED_SPACE,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: MEDIUM_SPACE,
                            children: <Widget>[
                              SizedBox(
                                height: 30.0,
                                child: Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: _ImageFromAssets(
                                    imagePath: item.asset,
                                  ),
                                ),
                              ),
                              AutoSizeText(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}

@immutable
class GuidesGridItem {
  const GuidesGridItem({required this.asset, required this.label});

  final String asset;
  final String label;
}

class GuidesCaptionContainer extends StatelessWidget {
  const GuidesCaptionContainer({
    required this.caption,
    required this.child,
    super.key,
  }) : assert(caption.length > 0);

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: caption,
      image: true,
      excludeSemantics: true,
      child: GuidesContainer(
        child: Column(
          spacing: 5.0,
          children: <Widget>[
            child,
            Text(
              caption,
              style: TextStyle(
                fontSize: 13.0,
                fontStyle: FontStyle.italic,
                color: context.lightTheme() ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuidesImage extends StatelessWidget {
  const GuidesImage({
    required this.imagePath,
    required this.caption,
    this.desiredWidthPercent,
    this.desiredHeightPercent,
    super.key,
  }) : assert(caption.length > 0),
       assert(
         desiredWidthPercent == null ||
             desiredWidthPercent >= 0.0 && desiredWidthPercent <= 1.0,
       ),
       assert(
         desiredHeightPercent == null ||
             desiredHeightPercent >= 0.0 && desiredHeightPercent <= 1.0,
       );

  final String imagePath;
  final double? desiredWidthPercent;
  final double? desiredHeightPercent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return GuidesCaptionContainer(
      caption: caption,
      child: _ImageFromAssets(
        imagePath: imagePath,
        desiredWidthPercent: desiredWidthPercent,
        desiredHeightPercent: desiredHeightPercent,
      ),
    );
  }
}

class _ImageFromAssets extends StatelessWidget {
  const _ImageFromAssets({
    required this.imagePath,
    this.desiredWidthPercent,
    this.desiredHeightPercent,
  }) : assert(
         desiredWidthPercent == null ||
             desiredWidthPercent >= 0.0 && desiredWidthPercent <= 1.0,
       ),
       assert(
         desiredHeightPercent == null ||
             desiredHeightPercent >= 0.0 && desiredHeightPercent <= 1.0,
       );

  final String imagePath;
  final double? desiredWidthPercent;
  final double? desiredHeightPercent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        if (imagePath.endsWith('.svg')) {
          return SvgPicture.asset(
            imagePath,
            width: desiredWidthPercent != null
                ? constraints.maxWidth * desiredWidthPercent!
                : null,
            height: desiredHeightPercent != null
                ? constraints.maxHeight * desiredHeightPercent!
                : null,
          );
        } else if (imagePath.endsWith('.vec')) {
          return SvgPicture(
            AssetBytesLoader(imagePath),
            width: desiredWidthPercent != null
                ? constraints.maxWidth * desiredWidthPercent!
                : null,
            height: desiredHeightPercent != null
                ? constraints.maxHeight * desiredHeightPercent!
                : null,
          );
        } else {
          return Image.asset(
            imagePath,
            width: desiredWidthPercent != null
                ? constraints.maxWidth * desiredWidthPercent!
                : null,
            height: desiredHeightPercent != null
                ? constraints.maxHeight * desiredHeightPercent!
                : null,
          );
        }
      },
    );
  }
}
