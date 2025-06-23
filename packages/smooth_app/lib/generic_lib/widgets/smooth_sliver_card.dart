import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/widgets/widget_height.dart';

class SliverCardWithRoundedHeader extends StatefulWidget {
  const SliverCardWithRoundedHeader({
    required this.title,
    required this.child,
    this.leading,
    this.leadingIconSize,
    this.leadingPadding,
    this.trailing,
    this.titleTextStyle,
    this.titlePadding,
    this.contentPadding,
    this.titleBackgroundColor,
    this.contentBackgroundColor,
    this.borderRadius,
    this.banner,
    super.key,
  });

  final String title;
  final Widget? leading;
  final double? leadingIconSize;
  final EdgeInsetsGeometry? leadingPadding;
  final Widget? trailing;
  final Widget child;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? titleBackgroundColor;
  final Color? contentBackgroundColor;
  final BorderRadius? borderRadius;
  final Widget? banner;

  @override
  State<SliverCardWithRoundedHeader> createState() =>
      _SliverCardWithRoundedHeaderState();
}

class _SliverCardWithRoundedHeaderState
    extends State<SliverCardWithRoundedHeader> {
  double? _height;
  double? _bannerHeight;

  @override
  void didUpdateWidget(SliverCardWithRoundedHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.banner != null && widget.banner == null) {
      if (_height != null && _bannerHeight != null) {
        _height = _height! - _bannerHeight!;
        _bannerHeight = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = SmoothCardWithRoundedHeaderTop(
      title: widget.title,
      titleBackgroundColor: widget.titleBackgroundColor,
      leading: widget.leading,
      leadingIconSize: widget.leadingIconSize,
      leadingPadding: widget.leadingPadding,
      trailing: widget.trailing,
      titleTextStyle: widget.titleTextStyle,
      titlePadding: widget.titlePadding,
      borderRadius: widget.borderRadius,
      banner: widget.banner,
    );

    if (_height == null) {
      return SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            if (widget.banner != null)
              MeasureSize(
                onChange: (Size size) =>
                    setState(() => _bannerHeight = size.height),
                child: widget.banner!,
              ),
            MeasureSize(
              onChange: (Size size) => setState(() => _height = size.height),
              child: Opacity(opacity: 0.0, child: child),
            ),
          ],
        ),
      );
    }

    return MultiSliver(
      children: <Widget>[
        SliverPersistentHeader(
          delegate: _SliverCardWithRoundedHeaderDelegate(
            height: _height!,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: child,
          ),
          floating: true,
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: SmoothCardWithRoundedHeaderBody(
            contentBackgroundColor: widget.contentBackgroundColor,
            contentPadding: widget.contentPadding,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class _SliverCardWithRoundedHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  _SliverCardWithRoundedHeaderDelegate({
    required this.height,
    required this.color,
    required this.child,
  });

  final double height;
  final Color color;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        /// Top padding
        /// We draw a color on this space to avoid the content to be visible
        CustomPaint(
          foregroundPainter: shrinkOffset > 0.0 || overlapsContent
              ? _SliverCardWithRoundedHeaderClipPainter(
                  color: color,
                  radius: ROUNDED_RADIUS,
                )
              : null,
          child: const SizedBox(height: MEDIUM_SPACE, width: double.infinity),
        ),
        SmoothCardWithRoundedHeaderTopShadowProvider(
          shadow: shrinkOffset.progressAndClamp(0.0, 30.0, 1.0),
          child: child,
        ),
      ],
    );
  }

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => height + MEDIUM_SPACE;

  @override
  bool shouldRebuild(_SliverCardWithRoundedHeaderDelegate oldDelegate) =>
      oldDelegate.color != color;
}

class _SliverCardWithRoundedHeaderClipPainter extends CustomPainter {
  _SliverCardWithRoundedHeaderClipPainter({
    required Color color,
    required this.radius,
  }) : _paint = Paint()..color = color;

  final Radius radius;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0.0)
      ..lineTo(0, size.height + radius.y)
      ..arcToPoint(
        Offset(radius.x, size.height),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(size.width - radius.x, size.height)
      ..arcToPoint(
        Offset(size.width, size.height + radius.y),
        radius: radius,
        clockwise: true,
      )
      ..lineTo(size.width, 0.0)
      ..lineTo(0.0, 0)
      ..close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_SliverCardWithRoundedHeaderClipPainter oldDelegate) =>
      oldDelegate._paint.color != _paint.color;

  @override
  bool shouldRebuildSemantics(
    _SliverCardWithRoundedHeaderClipPainter oldDelegate,
  ) => false;
}
