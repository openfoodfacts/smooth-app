import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/num_utils.dart';
import 'package:smooth_app/pages/homepage/camera/peak_view/peak_view.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class HomePageExpandableView extends StatelessWidget {
  const HomePageExpandableView({
    required this.controller,
    required this.height,
    super.key,
  });

  final CustomScannerController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) async {
        final HomePageState screenController = HomePage.of(context);

        if (screenController.isExpanded) {
          screenController.collapseCamera();
          return;
        }
      },
      child: SliverPersistentHeader(delegate: _Delegate(controller, height)),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  const _Delegate(this.controller, this.height);

  static const double MIN_PEAK = 0.2;

  final CustomScannerController controller;
  final double height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    final double progress = shrinkOffset / maxExtent;
    final BorderRadius borderRadius = _computeBorderRadius(progress);

    return ColoredBox(
      color: borderRadius.bottomLeft.x == 0
          ? Colors.transparent
          : lightTheme
          ? theme.primaryMedium
          : theme.primaryUltraBlack,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            Positioned.fill(
              child: HomePageCameraView(
                controller: controller,
                progress: progress,
                onClosed: () {
                  HomePage.of(context).collapseCamera();
                },
              ),
            ),
            PositionedDirectional(
              bottom: 0.0,
              start: 0.0,
              end: 0.0,
              child: HomePageScannerPeakView(
                progress: progress,
                opacity: _computePeakOpacity(progress),
                onTap: () => HomePage.of(context).expandCamera(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _computeBorderRadius(double progress) {
    if (progress >= 1 - HomePage.CAMERA_PEAK) {
      return const BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS),
      );
    } else if (progress <= MIN_PEAK) {
      return BorderRadius.zero;
    } else {
      final double value = progress.progress(
        MIN_PEAK,
        1 - HomePage.CAMERA_PEAK,
      );

      return BorderRadius.vertical(
        bottom: Radius.circular(HomePage.BORDER_RADIUS * value),
      );
    }
  }

  double _computePeakOpacity(double progress) {
    if (progress >= 1 - HomePage.CAMERA_PEAK) {
      return 1.0;
    } else if (progress <= MIN_PEAK) {
      return 0.0;
    } else {
      return progress.progress(MIN_PEAK, 1 - HomePage.CAMERA_PEAK);
    }
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height * 0.2;

  @override
  bool shouldRebuild(covariant _Delegate oldDelegate) =>
      height != oldDelegate.height;
}
