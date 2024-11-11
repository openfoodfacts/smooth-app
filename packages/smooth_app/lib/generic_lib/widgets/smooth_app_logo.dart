import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _attachAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation?.value ?? widget.opacityMin,
      child: const SmoothAppLogo(),
    );
  }

  void _attachAnimation() {
    AnimationController? controller =
        _SmoothSharedAnimationControllerState.of(context);

    if (controller == null) {
      _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
      controller = _controller;
    }

    _animation = Tween<double>(begin: widget.opacityMin, end: widget.opacityMax)
        .animate(controller!)
      ..addListener(_onAnimationChanged);

    if (!controller.isAnimating) {
      controller.repeat(reverse: true);
    }
  }

  void _onAnimationChanged() {
    if (context.mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animation?.removeListener(_onAnimationChanged);
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

/// A shared [AnimationController] that can be used by multiple
/// [SmoothAnimatedLogo] and ensure they are all perfectly synced.
class SmoothSharedAnimationController extends StatefulWidget {
  const SmoothSharedAnimationController({
    required this.child,
  });

  final Widget child;

  @override
  State<SmoothSharedAnimationController> createState() =>
      _SmoothSharedAnimationControllerState();
}

class _SmoothSharedAnimationControllerState
    extends State<SmoothSharedAnimationController>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<_SmoothSharedAnimationControllerState>(
      create: (_) => this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static AnimationController? of(BuildContext context) {
    try {
      return Provider.of<_SmoothSharedAnimationControllerState>(
        context,
        listen: false,
      )._controller;
    } catch (_) {
      return null;
    }
  }
}
