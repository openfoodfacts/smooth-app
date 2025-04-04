import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// An animated logo which can depend on [SmoothSharedAnimationController]
/// to ensure animations are synced
class SmoothAnimatedLogo extends StatefulWidget {
  const SmoothAnimatedLogo({
    this.opacityMax = 0.65,
    this.opacityMin = 0.2,
  });

  final double opacityMin;
  final double opacityMax;

  @override
  State<SmoothAnimatedLogo> createState() => _SmoothAnimatedLogoState();
}

class _SmoothAnimatedLogoState extends State<SmoothAnimatedLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _controller ??= AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(_onAnimationChanged);

    _animation = Tween<double>(begin: widget.opacityMin, end: widget.opacityMax)
        .animate(_controller!);

    _controller!.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation?.value ?? widget.opacityMin,
      child: const SmoothAppLogo(),
    );
  }

  void _onAnimationChanged() {
    if (context.mounted && _controller!.isAnimating) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class SmoothAppLogo extends StatelessWidget {
  const SmoothAppLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      context.lightTheme()
          ? 'assets/app/release_icon_transparent.svg'
          : 'assets/app/release_icon_dark_transparent_no_border.svg',
    );
  }
}
