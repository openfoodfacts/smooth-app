import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Container to display a product image on a product card.
///
/// If [imageProvider] is null, [PictureNotFound] is displayed.
class SmoothImage extends StatelessWidget {
  const SmoothImage({
    this.imageProvider,
    this.height,
    this.width,
    this.color,
    this.decoration,
    this.fit = BoxFit.cover,
    this.rounded = true,
    this.heroTag,
    this.cacheWidth,
    this.cacheHeight,
  })  : assert(
          cacheWidth == null || imageProvider is NetworkImage,
          'cacheWidth requires a NetworkImage',
        ),
        assert(
          cacheHeight == null || imageProvider is NetworkImage,
          'cacheHeight requires a NetworkImage',
        );

  final ImageProvider? imageProvider;
  final double? height;
  final double? width;
  final Color? color;
  final Decoration? decoration;
  final BoxFit fit;
  final String? heroTag;
  final bool rounded;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    Widget child = switch (imageProvider) {
      NetworkImage(url: final String url) => Image.network(
          url,
          fit: fit,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        ),
      ImageProvider<Object>() => Image(
          image: imageProvider!,
          fit: fit,
          loadingBuilder: _loadingBuilder,
          errorBuilder: _errorBuilder,
        ),
      _ => const PictureNotFound(),
    };

    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }

    child = Container(
        decoration: decoration,
        width: width,
        height: height,
        color: color,
        child: child);

    if (rounded) {
      child = ClipRRect(
        borderRadius: ROUNDED_BORDER_RADIUS,
        child: child,
      );
    }

    return child;
  }

  Widget _loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? progress,
  ) {
    final ThemeData theme = Theme.of(context);

    return ExcludeSemantics(
      child: AnimatedCrossFade(
          crossFadeState: progress == null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: SmoothAnimationsDuration.long,
          firstChild: child,
          secondChild: Container(
            color: theme.primaryColor.withOpacity(0.1),
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.all(SMALL_SPACE),
            child: const _SmoothAnimatedLogo(
              opacityMax: 0.65,
              opacityMin: 0.2,
            ),
          ),
          layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild,
              Key bottomChildKey) {
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  key: bottomChildKey,
                  child: bottomChild,
                ),
                Positioned.fill(
                  key: topChildKey,
                  child: topChild,
                ),
              ],
            );
          }),
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object _,
    StackTrace? __,
  ) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: const EdgeInsets.all(SMALL_SPACE),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.grey.withOpacity(0.7),
          BlendMode.srcIn,
        ),
        child: const _SmoothAppLogo(),
      ),
    );
  }
}

/// An animated logo which can depend on [SmoothSharedAnimationController]
/// to ensure animations are synced
class _SmoothAnimatedLogo extends StatefulWidget {
  const _SmoothAnimatedLogo({
    required this.opacityMax,
    required this.opacityMin,
  });

  final double opacityMin;
  final double opacityMax;

  @override
  State<_SmoothAnimatedLogo> createState() => _SmoothAnimatedLogoState();
}

class _SmoothAnimatedLogoState extends State<_SmoothAnimatedLogo>
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
      child: const _SmoothAppLogo(),
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
    setState(() {});
  }

  @override
  void dispose() {
    _animation?.removeListener(_onAnimationChanged);
    _controller?.dispose();
    super.dispose();
  }
}

class _SmoothAppLogo extends StatelessWidget {
  const _SmoothAppLogo();

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();

    return SvgPicture.asset(
      !themeProvider.isDarkMode(context)
          ? 'assets/app/release_icon_transparent.svg'
          : 'assets/app/release_icon_dark_transparent_no_border.svg',
    );
  }
}

/// A shared [AnimationController] that can be used by multiple
/// [_SmoothAnimatedLogo] and ensure they are all perfectly synced.
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
