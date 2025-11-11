import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/generic_lib/animations/rive_animation.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class BarcodeAnimation extends StatelessWidget {
  const BarcodeAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const RiveAnimation(artboard: 'Barcode', autoBinding: false);
  }
}

class CloudUploadAnimation extends StatelessWidget {
  const CloudUploadAnimation({required this.size, this.color, super.key})
    : _circleColor = null;

  const CloudUploadAnimation.circle({
    required this.size,
    this.color,
    Color? circleColor,
    super.key,
  }) : _circleColor = circleColor ?? Colors.black54;

  final double size;
  final Color? color;
  final Color? _circleColor;

  @override
  Widget build(BuildContext context) {
    Widget widget = SizedBox.square(
      dimension: size,
      child: const RiveAnimation(artboard: 'Cloud upload'),
    );

    if (_circleColor != null) {
      widget = DecoratedBox(
        decoration: BoxDecoration(color: _circleColor, shape: BoxShape.circle),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            top: size * 0.2,
            start: size * 0.2,
            end: size * 0.2,
            bottom: size * 0.13,
          ),
          child: widget,
        ),
      );
    }

    return SizedBox.square(dimension: size, child: widget);
  }
}

class DoubleChevronAnimation extends StatefulWidget {
  const DoubleChevronAnimation.animate({this.size, super.key})
    : animated = true;

  const DoubleChevronAnimation.stopped({this.size, super.key})
    : animated = false;

  final double? size;
  final bool animated;

  @override
  State<DoubleChevronAnimation> createState() => _DoubleChevronAnimationState();
}

class _DoubleChevronAnimationState extends State<DoubleChevronAnimation> {
  /// Disposed by [RiveAnimation]
  ViewModelInstance? _vmi;

  @override
  void didUpdateWidget(covariant DoubleChevronAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeAnimation(widget.animated);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation(
        artboard: 'Double chevron',
        onDataBindAvailable: (ViewModelInstance vmi) {
          _vmi = vmi;
          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    _vmi?.boolean('Loop')?.value = animated;
  }
}

class HintArrowAnimation extends StatelessWidget {
  const HintArrowAnimation({this.size, this.color, super.key});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double size = this.size ?? 70.0;

    return ExcludeSemantics(
      child: SizedBox(
        width: (122 / 72) * size,
        height: size,
        child: RiveAnimation(
          artboard: 'Hint arrow',
          colorChanger: color != null ? <String, Color>{'Color': color!} : null,
        ),
      ),
    );
  }
}

class OrangeErrorAnimation extends StatefulWidget {
  const OrangeErrorAnimation({this.sizeMultiplier = 1.0, super.key});

  final double sizeMultiplier;

  @override
  State<OrangeErrorAnimation> createState() => _OrangeErrorAnimationState();
}

class _OrangeErrorAnimationState extends State<OrangeErrorAnimation> {
  ViewModelInstance? _vmi;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 83.0 * widget.sizeMultiplier,
        height: 77.0 * widget.sizeMultiplier,
        child: GestureDetector(
          onTap: () {
            _vmi?.trigger('Trigger')!.trigger();
            SmoothHapticFeedback.click();
          },
          child: RiveAnimation(
            artboard: 'Orange error',
            onDataBindAvailable: (ViewModelInstance vmi) => _vmi = vmi,
          ),
        ),
      ),
    );
  }
}

class SearchEyeAnimation extends StatelessWidget {
  const SearchEyeAnimation({this.size, super.key});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final double size = this.size ?? IconTheme.of(context).size ?? 24.0;
    final bool lightTheme = context.lightTheme();

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: (80 / 87) * size,
        child: RiveAnimation(
          artboard: 'Search eye',
          colorChanger: <String, Color>{
            'MainColor': lightTheme ? Colors.black : Colors.white,
            'Eye1': lightTheme ? Colors.black : Colors.white,
            'Eye2': lightTheme ? Colors.white : const Color(0xFFACACAC),
          },
        ),
      ),
    );
  }
}

class SunAnimation extends StatelessWidget {
  const SunAnimation({required this.type, super.key});

  final SunAnimationType type;

  @override
  Widget build(BuildContext context) {
    return RiveAnimation(
      artboard: 'Success',
      stateMachine: type == SunAnimationType.loop ? 'Loop' : 'Animation',
      autoBinding: false,
    );
  }
}

enum SunAnimationType { loop, fullAnimation }

class TorchAnimation extends StatefulWidget {
  const TorchAnimation.on({this.size, super.key}) : isOn = true;

  const TorchAnimation.off({this.size, super.key}) : isOn = false;

  final bool isOn;
  final double? size;

  @override
  State<TorchAnimation> createState() => _TorchAnimationState();
}

class _TorchAnimationState extends State<TorchAnimation> {
  ViewModelInstance? _vmi;

  @override
  void didUpdateWidget(covariant TorchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeTorchValue(widget.isOn);
  }

  void _changeTorchValue(bool isOn) {
    _vmi?.boolean('Enable')?.value = isOn;
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation(
        artboard: 'Torch',
        fit: Fit.cover,
        onDataBindAvailable: (ViewModelInstance vmi) {
          _vmi = vmi;
          _changeTorchValue(widget.isOn);
        },
      ),
    );
  }
}

class ScaleAnimation extends StatefulWidget {
  const ScaleAnimation({required this.animated, this.size, super.key});

  final double? size;
  final bool animated;

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation> {
  ViewModelInstance? _vmi;

  @override
  void didUpdateWidget(covariant ScaleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeAnimation(widget.animated);
  }

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double size = widget.size ?? iconTheme.size ?? 24.0;
    final Color color = iconTheme.color!;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation(
        artboard: 'Scale',
        onDataBindAvailable: (ViewModelInstance vmi) {
          _vmi = vmi;
          _vmi!.color('Color')!.value = color;
          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    _vmi?.boolean('Anim')?.value = animated;
  }
}

class SparkleAnimation extends StatefulWidget {
  const SparkleAnimation({
    required this.type,
    required this.color,
    this.animated = true,
    this.size,
    super.key,
  });

  final SparkleAnimationType type;
  final Color color;
  final double? size;
  final bool animated;

  @override
  State<SparkleAnimation> createState() => _SparkleAnimationState();
}

class _SparkleAnimationState extends State<SparkleAnimation> {
  ViewModelInstance? _vmi;

  @override
  void didUpdateWidget(covariant SparkleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animated != widget.animated) {
      _changeAnimation(widget.animated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double size = widget.size ?? iconTheme.size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation(
        artboard: 'Sparkles',
        colorChanger: <String, Color>{'Color': widget.color},
        stateMachine: switch (widget.type) {
          SparkleAnimationType.glow => 'Glow',
          SparkleAnimationType.grow => 'Grow',
          SparkleAnimationType.scale => 'Scale',
        },
        onDataBindAvailable: (ViewModelInstance vmi) {
          _vmi = vmi;
          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    _vmi?.boolean('animate')?.value = animated;
  }
}

enum SparkleAnimationType { glow, grow, scale }
