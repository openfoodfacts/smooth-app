import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class SmoothScaffold2 extends StatefulWidget {
  const SmoothScaffold2({
    required this.children,
    this.topBar,
    this.bottomBar,
    this.backgroundColor,
    this.padding,
    this.brightness,
    this.injectPaddingInBody = true,
    this.floatingBottomBar,
    this.bottomSafeArea = true,
    super.key,
  });

  final SmoothTopBar2? topBar;
  final List<Widget> children;
  final Widget? bottomBar;
  final Widget? floatingBottomBar;
  final bool injectPaddingInBody;
  final bool bottomSafeArea;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Brightness? brightness;

  @override
  State<SmoothScaffold2> createState() => _SmoothScaffold2State();
}

class _SmoothScaffold2State extends State<SmoothScaffold2> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewPadding = MediaQuery.viewPaddingOf(context);

    return SmoothScaffold(
      backgroundColor: widget.backgroundColor,
      brightness: widget.brightness,
      body: PrimaryScrollController(
        controller: _controller,
        child: CustomMultiChildLayout(
          delegate: _SmoothScaffold2Layout(
            viewPadding: viewPadding,
            injectPaddingInBody: widget.injectPaddingInBody,
          ),
          children: <Widget>[
            LayoutId(
              id: _SmoothScaffold2Widget.body,
              child: CustomScrollView(
                controller: _controller,
                slivers: <Widget>[
                  if (widget.injectPaddingInBody)
                    SliverPadding(
                      padding: EdgeInsetsDirectional.only(
                        top: widget.topBar != null
                            ? HEADER_ROUNDED_RADIUS.x
                            : viewPadding.top,
                      ),
                    ),
                  if (widget.padding != null)
                    SliverPadding(
                      padding: widget.padding!,
                      sliver: MultiSliver(children: widget.children),
                    )
                  else
                    ...widget.children,
                  if (widget.bottomBar == null || widget.bottomSafeArea)
                    SliverPadding(
                      padding: EdgeInsetsDirectional.only(
                        bottom: viewPadding.bottom,
                      ),
                    )
                ],
              ),
            ),
            if (widget.topBar != null)
              LayoutId(
                id: _SmoothScaffold2Widget.topBar,
                child: widget.topBar!,
              ),
            if (widget.bottomBar != null)
              LayoutId(
                id: _SmoothScaffold2Widget.bottomBar,
                child: widget.bottomBar!,
              ),
            if (widget.floatingBottomBar != null)
              LayoutId(
                id: _SmoothScaffold2Widget.floattingBottomBar,
                child: widget.floatingBottomBar!,
              ),
          ],
        ),
      ),
    );
  }
}

enum _SmoothScaffold2Widget {
  topBar,
  body,
  bottomBar,
  floattingBottomBar,
}

class _SmoothScaffold2Layout extends MultiChildLayoutDelegate {
  _SmoothScaffold2Layout({
    required this.viewPadding,
    required this.injectPaddingInBody,
  });

  final EdgeInsets viewPadding;
  final bool injectPaddingInBody;

  @override
  void performLayout(Size size) {
    double topBarHeight;

    // Top bar
    if (hasChild(_SmoothScaffold2Widget.topBar)) {
      topBarHeight = layoutChild(
        _SmoothScaffold2Widget.topBar,
        BoxConstraints.loose(size),
      ).height;
    } else {
      topBarHeight = 0.0;
    }

    double bottomBarHeight;

    // Bottom bar
    if (hasChild(_SmoothScaffold2Widget.bottomBar)) {
      bottomBarHeight = layoutChild(
        _SmoothScaffold2Widget.bottomBar,
        BoxConstraints.loose(
          size,
        ),
      ).height;
    } else {
      bottomBarHeight = 0.0;
    }

    double floatingBottomBarHeight;

    // Floating Bottom bar
    if (hasChild(_SmoothScaffold2Widget.floattingBottomBar)) {
      floatingBottomBarHeight = layoutChild(
        _SmoothScaffold2Widget.floattingBottomBar,
        BoxConstraints.loose(
          size,
        ),
      ).height;
    } else {
      floatingBottomBarHeight = 0.0;
    }

    // Body
    final double bodyTopPosition = topBarHeight > 0.0
        ? topBarHeight - (injectPaddingInBody ? HEADER_ROUNDED_RADIUS.x : 0.0)
        : 0.0;
    layoutChild(
      _SmoothScaffold2Widget.body,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: 0.0,
        maxHeight: size.height - bodyTopPosition - bottomBarHeight,
      ),
    );

    positionChild(_SmoothScaffold2Widget.body, Offset(0.0, bodyTopPosition));

    if (topBarHeight > 0.0) {
      positionChild(_SmoothScaffold2Widget.topBar, Offset.zero);
    }
    if (bottomBarHeight > 0.0) {
      positionChild(
        _SmoothScaffold2Widget.bottomBar,
        Offset(0.0, size.height - bottomBarHeight),
      );
    }
    if (floatingBottomBarHeight > 0.0) {
      positionChild(
        _SmoothScaffold2Widget.floattingBottomBar,
        Offset(0.0, size.height - bottomBarHeight - floatingBottomBarHeight),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
