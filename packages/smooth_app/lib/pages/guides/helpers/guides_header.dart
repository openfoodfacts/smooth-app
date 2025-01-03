import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/resources/app_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// A collapsing header with:
/// In the expanded state:
///   - A close button with the "Guide" text
///   - A title on multiple lines
///   - An illustration
/// In the minimized state:
///   - A close button (just an X)
///   - A title on a single line
class GuidesHeader extends StatelessWidget {
  const GuidesHeader({
    required this.title,
    required this.illustration,
    super.key,
  });

  static const double HEADER_HEIGHT = 250.0;

  final String title;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.white),
      child: SliverPadding(
        padding: const EdgeInsetsDirectional.only(
          bottom: BALANCED_SPACE,
        ),
        // Pinned = for the header to stay at the top of the screen
        sliver: SliverPersistentHeader(
          floating: false,
          pinned: true,
          delegate: _GuidesHeaderDelegate(
            title: title,
            illustration: illustration,
            topPadding: MediaQuery.viewPaddingOf(context).top,
          ),
        ),
      ),
    );
  }
}

class _GuidesHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _GuidesHeaderDelegate({
    required this.title,
    required this.illustration,
    required this.topPadding,
  })  : assert(title.length > 0),
        assert(topPadding >= 0.0);

  final String title;
  final Widget illustration;
  final double topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;
    final double progress =
        shrinkOffset.progressAndClamp(0.0, maxExtent - minExtent, 1.0);

    return Provider<double>.value(
      value: progress,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: HEADER_ROUNDED_RADIUS * (1 - progress),
            ),
          ),
          color: colors.primaryDark,
          shadows: <BoxShadow>[
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: progress.progressAndClamp(0.5, 1, 0.2)),
              offset: const Offset(0.5, 0.5),
              blurRadius: 2.0,
            ),
          ],
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: VERY_LARGE_SPACE,
        ),
        child: ClipRRect(
          child: CustomMultiChildLayout(
            delegate: _GuidesHeaderLayout(
              topPadding: topPadding,
            ),
            children: <Widget>[
              LayoutId(
                id: _GuidesHeaderLayoutId.expandedTitle,
                child: Opacity(
                  opacity: 1 - progress,
                  child: OverflowBox(
                    fit: OverflowBoxFit.deferToChild,
                    maxHeight: GuidesHeader.HEADER_HEIGHT -
                        10 -
                        _CloseButtonLayout._CLOSE_BUTTON_SIZE,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: BALANCED_SPACE),
                        child: AutoSizeText(
                          title,
                          maxLines: 4,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              LayoutId(
                id: _GuidesHeaderLayoutId.illustration,
                child: OverflowBox(
                  maxHeight: GuidesHeader.HEADER_HEIGHT - 33,
                  fit: OverflowBoxFit.deferToChild,
                  child: Offstage(
                    offstage: progress == 1.0,
                    child: Opacity(
                      opacity: 1 - progress,
                      child: illustration,
                    ),
                  ),
                ),
              ),
              LayoutId(
                id: _GuidesHeaderLayoutId.minimizedTitle,
                child: Offstage(
                  offstage: progress < 0.95,
                  child: Opacity(
                    opacity: progress.progressAndClamp(0.95, 1.0, 1.0),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              LayoutId(
                id: _GuidesHeaderLayoutId.closeButton,
                child: const _BackButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => GuidesHeader.HEADER_HEIGHT + topPadding;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _GuidesHeaderLayout extends MultiChildLayoutDelegate {
  _GuidesHeaderLayout({
    required this.topPadding,
  });

  final double topPadding;

  @override
  void performLayout(Size size) {
    final double topMargin = topPadding + BALANCED_SPACE;
    final double maxHeight = size.height - topPadding - (BALANCED_SPACE * 2);

    final Size closeButtonSize = layoutChild(
      _GuidesHeaderLayoutId.closeButton,
      BoxConstraints.loose(
        Size(
          size.width * 0.6,
          _CloseButtonLayout._CLOSE_BUTTON_SIZE,
        ),
      ),
    );

    layoutChild(
      _GuidesHeaderLayoutId.expandedTitle,
      BoxConstraints.loose(
        Size(
          size.width * 0.6,
          maxHeight - closeButtonSize.height,
        ),
      ),
    );

    final Size illustrationSize = layoutChild(
      _GuidesHeaderLayoutId.illustration,
      BoxConstraints.loose(
        Size(
          size.width * 0.4,
          maxHeight,
        ),
      ),
    );

    layoutChild(
      _GuidesHeaderLayoutId.minimizedTitle,
      BoxConstraints.loose(
        Size(
          size.width - _CloseButtonLayout._CLOSE_BUTTON_SIZE,
          _CloseButtonLayout._CLOSE_BUTTON_SIZE,
        ),
      ),
    );

    positionChild(_GuidesHeaderLayoutId.closeButton, Offset(0, topMargin));
    positionChild(
      _GuidesHeaderLayoutId.expandedTitle,
      Offset(0, closeButtonSize.height + topPadding),
    );
    positionChild(
      _GuidesHeaderLayoutId.illustration,
      Offset(size.width * 0.6,
          topPadding + (maxHeight - illustrationSize.height) + 5.0),
    );

    positionChild(
      _GuidesHeaderLayoutId.minimizedTitle,
      Offset(
        _CloseButtonLayout._CLOSE_BUTTON_SIZE + BALANCED_SPACE,
        topMargin + 5.0,
      ),
    );
  }

  @override
  bool shouldRelayout(_GuidesHeaderLayout oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }
}

enum _GuidesHeaderLayoutId {
  closeButton,
  expandedTitle,
  minimizedTitle,
  illustration,
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return SizedBox(
      height: _CloseButtonLayout._CLOSE_BUTTON_SIZE,
      child: Material(
        type: MaterialType.transparency,
        child: Consumer<double>(
          builder: (_, double progress, __) {
            return CustomMultiChildLayout(
              delegate: _CloseButtonLayout(
                progress: 1 - progress,
              ),
              children: <Widget>[
                LayoutId(
                  id: _CloseButtonLayoutId.text,
                  child: Offstage(
                    offstage: progress == 1.0,
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: BALANCED_SPACE,
                          end: 24.0,
                        ),
                        child: Opacity(
                          opacity: 1 - progress.progressAndClamp(0.0, 0.7, 1.0),
                          child: const Text(
                            'Guide',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                LayoutId(
                  id: _CloseButtonLayoutId.closeButton,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 36.0,
                      child: Close(
                        size: 16.0,
                        color: colors.primaryBlack,
                      ),
                    ),
                  ),
                ),
                LayoutId(
                  id: _CloseButtonLayoutId.background,
                  child: Tooltip(
                    message:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(true),
                      borderRadius: ROUNDED_BORDER_RADIUS,
                      child: Offstage(
                        offstage: progress == 1.0,
                        child: Container(
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.white,
                                width: 1.0,
                              ),
                              borderRadius: ROUNDED_BORDER_RADIUS,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CloseButtonLayout extends MultiChildLayoutDelegate {
  _CloseButtonLayout({required this.progress})
      : assert(progress >= 0.0 && progress <= 1.0);

  static const double _CLOSE_BUTTON_SIZE = 36.0;

  final double progress;

  @override
  void performLayout(Size size) {
    final Size closeButtonSize = layoutChild(
      _CloseButtonLayoutId.closeButton,
      const BoxConstraints.expand(
        width: _CLOSE_BUTTON_SIZE,
        height: _CLOSE_BUTTON_SIZE,
      ),
    );

    if (progress == 0.0) {
      layoutChild(
        _CloseButtonLayoutId.text,
        BoxConstraints.loose(Size.zero),
      );

      layoutChild(
        _CloseButtonLayoutId.background,
        BoxConstraints.expand(
          width: closeButtonSize.width,
          height: closeButtonSize.height,
        ),
      );

      return;
    }

    final Size textSize = layoutChild(
      _CloseButtonLayoutId.text,
      BoxConstraints.loose(size),
    );

    layoutChild(
      _CloseButtonLayoutId.background,
      BoxConstraints.expand(
        width: closeButtonSize.width + (textSize.width * progress),
        height: closeButtonSize.height,
      ),
    );

    positionChild(_CloseButtonLayoutId.closeButton, Offset.zero);
    positionChild(
      _CloseButtonLayoutId.text,
      Offset(
        _CLOSE_BUTTON_SIZE - ((textSize.width - 24.0) * (1 - progress)),
        ((_CLOSE_BUTTON_SIZE - textSize.height) / 2) - 1,
      ),
    );
    positionChild(_CloseButtonLayoutId.background, Offset.zero);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    if (progress == 0.0) {
      return const Size.square(_CLOSE_BUTTON_SIZE);
    } else {
      return Size(constraints.biggest.width, _CLOSE_BUTTON_SIZE);
    }
  }

  @override
  bool shouldRelayout(_CloseButtonLayout oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

enum _CloseButtonLayoutId {
  closeButton,
  text,
  background,
}
