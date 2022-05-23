import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/animations/smooth_reveal_animation.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_view_finder.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/pages/scan/scan_visor.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';

/// This builds all the essential widgets which are displayed above the camera
/// preview, like the [SmoothProductCarousel], the [SmoothViewFinder] and the
/// clear and compare buttons row.
///
/// The camera preview should be passed to [backgroundChild].
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    required this.topChild,
    this.backgroundChild,
  });

  final Widget? backgroundChild;
  final Widget topChild;

  static const double carouselHeightPct = 0.55;
  static const double carouselBottomPadding = 10.0;
  static const double scannerWidthPct = 0.6;
  static const double scannerHeightPct = 0.33;
  static const double buttonRowHeightPx = 48;

  @override
  Widget build(BuildContext context) {
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();

    return CustomMultiChildLayout(
      delegate: _ScannerOverlayDelegate(
        devicePadding: MediaQuery.of(context).padding,
        visibleActions: model.getBarcodes().isNotEmpty,
        hasVisor: _topItem is ScannerVisorWidget,
      ),
      children: <Widget>[
        _background,
        _topItem,
        _actions,
        _carousel,
      ],
    );
  }

  Widget get _background {
    if (backgroundChild == null) {
      return const ColoredBox(color: Colors.black);
    }

    return LayoutId(
      id: _LayoutIds.background,
      child: SmoothRevealAnimation(
        delay: 400,
        startOffset: Offset.zero,
        animationCurve: Curves.easeInOutBack,
        child: backgroundChild!,
      ),
    );
  }

  /// Visor or message (eg: permission not granted)
  Widget get _topItem {
    return LayoutId(
      id: _LayoutIds.topItem,
      child: SmoothRevealAnimation(
        delay: 400,
        startOffset: const Offset(0.0, 0.1),
        animationCurve: Curves.easeInOutBack,
        child: Center(child: topChild),
      ),
    );
  }

  Widget get _actions {
    return LayoutId(
      id: _LayoutIds.actions,
      child: const SmoothRevealAnimation(
        delay: 400,
        startOffset: Offset(0.0, -0.1),
        animationCurve: Curves.easeInOutBack,
        child: ScanHeader(),
      ),
    );
  }

  Widget get _carousel {
    return LayoutId(
      id: _LayoutIds.carousel,
      child: const SmoothRevealAnimation(
        delay: 400,
        startOffset: Offset(0.0, -0.1),
        animationCurve: Curves.easeInOutBack,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: carouselBottomPadding,
          ),
          child: SmoothProductCarousel(
            containSearchCard: true,
          ),
        ),
      ),
    );
  }
}

enum _LayoutIds { background, actions, topItem, carousel }

class _ScannerOverlayDelegate extends MultiChildLayoutDelegate {
  _ScannerOverlayDelegate({
    required this.devicePadding,
    required this.visibleActions,
    required this.hasVisor,
  });

  final EdgeInsets devicePadding;
  final bool visibleActions;
  final bool hasVisor;

  @override
  void performLayout(Size size) {
    _layoutBackground(size);
    final double carouselHeight = _layoutAndPositionCarousel(size);
    final double actionsHeight = _layoutAndPositionActions(size);

    if (hasVisor) {
      _layoutAndPositionVisor(size, carouselHeight, actionsHeight);
    } else {
      _layoutAndPositionTopItem(size, carouselHeight);
    }
  }

  /// Background: Take the full width
  void _layoutBackground(Size size) {
    layoutChild(
      _LayoutIds.background,
      BoxConstraints(
        maxWidth: size.width,
        maxHeight: size.height,
      ),
    );
  }

  /// Product carousel: bottom of the screen
  /// Will return the height of the carousel
  double _layoutAndPositionCarousel(Size size) {
    final double carouselHeight =
        size.height * ScannerOverlay.carouselHeightPct;

    layoutChild(
      _LayoutIds.carousel,
      BoxConstraints.tightFor(
        width: size.width,
        height: carouselHeight,
      ),
    );

    positionChild(_LayoutIds.carousel, Offset(0, size.height - carouselHeight));
    return carouselHeight;
  }

  /// Visor: between the bottom of the  status bar (or the actions if there is
  /// not enough space) and the carousel
  void _layoutAndPositionVisor(
    Size size,
    double carouselHeight,
    double actionsHeight,
  ) {
    layoutChild(
      _LayoutIds.topItem,
      BoxConstraints.tightFor(
        width: size.width,
        height: size.height - carouselHeight - devicePadding.top,
      ),
    );
  }

  /// Top item: below the status bar
  void _layoutAndPositionTopItem(
    Size size,
    double carouselHeight,
  ) {
    layoutChild(
      _LayoutIds.topItem,
      BoxConstraints.tightFor(
        width: size.width,
        height: size.height - carouselHeight - devicePadding.top,
      ),
    );

    positionChild(
      _LayoutIds.topItem,
      Offset(
        0,
        devicePadding.top,
      ),
    );
  }

  /// Actions: top of the screen and limit the height
  /// Returns the height
  double _layoutAndPositionActions(Size size) {
    final Size actionsSize = layoutChild(
      _LayoutIds.actions,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height * 0.2,
      ),
    );

    positionChild(
      _LayoutIds.actions,
      Offset(
        0,
        devicePadding.top,
      ),
    );

    return actionsSize.height;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) =>
      oldDelegate != this;
}
