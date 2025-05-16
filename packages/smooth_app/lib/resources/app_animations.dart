import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/component.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// Widget to inject in the hierarchy to have a single instance of the RiveFile
/// (assets/animations/off.riv)
class AnimationsLoader extends StatefulWidget {
  const AnimationsLoader({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AnimationsLoader> createState() => _AnimationsLoaderState();

  static RiveFile? of(BuildContext context) {
    return context.read<RiveFile>();
  }
}

class _AnimationsLoaderState extends State<AnimationsLoader> {
  RiveFile? _file;

  @override
  void initState() {
    super.initState();
    preload();
  }

  Future<void> preload() async {
    rootBundle.load('assets/animations/off.riv').then(
      (ByteData data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _file = RiveFile.import(data);
        });
      },
      onError: (dynamic error) => Logs.e(
        'Unable to load Rive file',
        ex: error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider<RiveFile?>.value(
      value: _file,
      child: widget.child,
    );
  }
}

class BarcodeAnimation extends StatelessWidget {
  const BarcodeAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RiveFile?>(
      builder: (BuildContext context, RiveFile? riveFile, _) {
        if (riveFile == null) {
          return EMPTY_WIDGET;
        }
        return RiveAnimation.direct(
          riveFile,
          artboard: 'Barcode',
          stateMachines: const <String>['StateMachine'],
        );
      },
    );
  }
}

class CloudUploadAnimation extends StatelessWidget {
  const CloudUploadAnimation({
    required this.size,
    this.color,
    super.key,
  }) : _circleColor = null;

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
      child: RiveAnimation.direct(
        AnimationsLoader.of(context)!,
        artboard: 'Cloud upload',
        animations: const <String>['Animation'],
        onInit: (Artboard artboard) {
          if (color != null) {
            artboard.forEachComponent(
              (Component child) {
                if (child is Stroke) {
                  child.paint.color = color!;
                } else if (child is SolidColor) {
                  child.color = color!;
                }
              },
            );
          }
        },
      ),
    );

    if (_circleColor != null) {
      widget = DecoratedBox(
        decoration: BoxDecoration(
          color: _circleColor,
          shape: BoxShape.circle,
        ),
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

    return SizedBox.square(
      dimension: size,
      child: widget,
    );
  }
}

class DoubleChevronAnimation extends StatefulWidget {
  const DoubleChevronAnimation.animate({
    this.size,
    super.key,
  }) : animated = true;

  const DoubleChevronAnimation.stopped({
    this.size,
    super.key,
  }) : animated = false;

  final double? size;
  final bool animated;

  @override
  State<DoubleChevronAnimation> createState() => _DoubleChevronAnimationState();
}

class _DoubleChevronAnimationState extends State<DoubleChevronAnimation> {
  StateMachineController? _controller;

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
      child: RiveAnimation.direct(
        AnimationsLoader.of(context)!,
        artboard: 'Double chevron',
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'Loop',
          );

          artboard.addController(_controller!);
          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    final SMIBool toggle = _controller!.findInput<bool>('loop')! as SMIBool;
    if (toggle.value != animated) {
      toggle.value = animated;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class OrangeErrorAnimation extends StatefulWidget {
  const OrangeErrorAnimation({
    this.sizeMultiplier = 1.0,
    super.key,
  });

  final double sizeMultiplier;

  @override
  State<OrangeErrorAnimation> createState() => _OrangeErrorAnimationState();
}

class _OrangeErrorAnimationState extends State<OrangeErrorAnimation> {
  final SimpleAnimation _controller = SimpleAnimation('Animation');

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 83.0 * widget.sizeMultiplier,
        height: 77.0 * widget.sizeMultiplier,
        child: Consumer<RiveFile?>(
          builder: (BuildContext context, RiveFile? riveFile, _) {
            if (riveFile == null) {
              return EMPTY_WIDGET;
            }
            return GestureDetector(
              onTap: () {
                _controller.reset();
                _controller.isActive = true;
                SmoothHapticFeedback.click();
              },
              child: ClipRect(
                child: RiveAnimation.direct(
                  riveFile,
                  artboard: 'Orange error',
                  controllers: <RiveAnimationController<dynamic>>[_controller],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SearchEyeAnimation extends StatefulWidget {
  const SearchEyeAnimation({
    this.size,
    super.key,
  });

  final double? size;

  @override
  State<SearchEyeAnimation> createState() => _SearchEyeAnimationState();
}

class _SearchEyeAnimationState extends State<SearchEyeAnimation> {
  StateMachineController? _controller;

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;
    final bool lightTheme = !context.watch<ThemeProvider>().isDarkMode(context);

    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: (80 / 87) * size,
        child: RiveAnimation.direct(AnimationsLoader.of(context)!,
            artboard: 'Search eye', onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'LoopMachine',
          );

          artboard.addController(_controller!);
          _controller!.findInput<bool>('light')?.value = !lightTheme;
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class SearchAnimation extends StatefulWidget {
  const SearchAnimation({
    super.key,
    this.type = SearchAnimationType.search,
    this.size,
  });

  final double? size;
  final SearchAnimationType type;

  @override
  State<SearchAnimation> createState() => _SearchAnimationState();
}

class _SearchAnimationState extends State<SearchAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(SearchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeAnimation(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation.direct(
        AnimationsLoader.of(context)!,
        artboard: 'Search icon',
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'StateMachine',
          );

          artboard.addController(_controller!);
          if (widget.type != SearchAnimationType.search) {
            _changeAnimation(widget.type);
          }
        },
      ),
    );
  }

  void _changeAnimation(SearchAnimationType type) {
    final SMINumber step = _controller!.findInput<double>('step')! as SMINumber;
    step.change(type.step.toDouble());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

enum SearchAnimationType {
  search(0),
  cancel(1),
  edit(2);

  const SearchAnimationType(this.step);

  final int step;
}

class SunAnimation extends StatelessWidget {
  const SunAnimation({
    required this.type,
    super.key,
  });

  final SunAnimationType type;

  @override
  Widget build(BuildContext context) {
    return Consumer<RiveFile?>(
      builder: (BuildContext context, RiveFile? riveFile, _) {
        if (riveFile == null) {
          return EMPTY_WIDGET;
        }
        return RiveAnimation.direct(
          riveFile,
          artboard: 'Success',
          stateMachines: <String>[
            if (type == SunAnimationType.loop) 'Loop' else 'Animation'
          ],
        );
      },
    );
  }
}

enum SunAnimationType {
  loop,
  fullAnimation,
}

class TorchAnimation extends StatefulWidget {
  const TorchAnimation.on({
    this.size,
    super.key,
  }) : isOn = true;

  const TorchAnimation.off({
    this.size,
    super.key,
  }) : isOn = false;

  final bool isOn;
  final double? size;

  @override
  State<TorchAnimation> createState() => _TorchAnimationState();
}

class _TorchAnimationState extends State<TorchAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(covariant TorchAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeTorchValue(widget.isOn);
  }

  void _changeTorchValue(bool isOn) {
    final SMIBool toggle = _controller!.findInput<bool>('enable')! as SMIBool;
    if (toggle.value != isOn) {
      toggle.value = isOn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size ?? IconTheme.of(context).size ?? 24.0;

    return SizedBox.square(
      dimension: size,
      child: RiveAnimation.asset(
        'assets/animations/off.riv',
        artboard: 'Torch',
        fit: BoxFit.cover,
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'Switch',
          );

          artboard.addController(_controller!);
          _changeTorchValue(widget.isOn);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class ScaleAnimation extends StatefulWidget {
  const ScaleAnimation({
    required this.animated,
    this.size,
    super.key,
  });

  final double? size;
  final bool animated;

  @override
  State<ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<ScaleAnimation> {
  StateMachineController? _controller;

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
      child: RiveAnimation.direct(
        AnimationsLoader.of(context)!,
        artboard: 'Scale',
        onInit: (Artboard artboard) {
          _controller = StateMachineController.fromArtboard(
            artboard,
            'State Machine',
          );

          artboard.addController(_controller!);

          _controller!.artboard!.forEachComponent((Component child) {
            if (child is RuntimeNestedArtboard) {
              child.sourceArtboard!.forEachComponent(
                (Component nestedChild) {
                  if (nestedChild is SolidColor) {
                    nestedChild.colorValue = color.intValue;
                  }
                },
              );
            }
          });

          _changeAnimation(widget.animated);
        },
      ),
    );
  }

  void _changeAnimation(bool animated) {
    final SMIBool toggle = _controller!.findInput<bool>('anim')! as SMIBool;
    if (toggle.value != animated) {
      toggle.value = animated;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
  StateMachineController? _controller;

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
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          widget.color,
          BlendMode.srcIn,
        ),
        child: RiveAnimation.direct(
          AnimationsLoader.of(context)!,
          artboard: 'sparkles',
          onInit: (Artboard artboard) {
            _controller = StateMachineController.fromArtboard(
              artboard,
              switch (widget.type) {
                SparkleAnimationType.glow => 'Glow',
                SparkleAnimationType.grow => 'Grow',
                SparkleAnimationType.scale => 'Scale',
              },
            );

            artboard.addController(_controller!);
            _changeAnimation(widget.animated);
          },
        ),
      ),
    );
  }

  void _changeAnimation(bool animated) {
    final SMIBool toggle = _controller!.findInput<bool>('animate')! as SMIBool;
    if (toggle.value != animated) {
      toggle.value = animated;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

enum SparkleAnimationType { glow, grow, scale }

class NutriScoreAnimation extends StatefulWidget {
  factory NutriScoreAnimation({
    required NutriScoreValue value,
    Size? size,
    Key? key,
  }) {
    return switch (value) {
      NutriScoreValue.a => NutriScoreAnimation.A(size: size, key: key),
      NutriScoreValue.b => NutriScoreAnimation.B(size: size, key: key),
      NutriScoreValue.c => NutriScoreAnimation.C(size: size, key: key),
      NutriScoreValue.d => NutriScoreAnimation.D(size: size, key: key),
      NutriScoreValue.e => NutriScoreAnimation.E(size: size, key: key),
      _ => NutriScoreAnimation.unknown(size: size, key: key),
    };
  }

  const NutriScoreAnimation.unknown({
    this.size,
    super.key,
  }) : level = -1;

  const NutriScoreAnimation.A({
    this.size,
    super.key,
  }) : level = 0;

  const NutriScoreAnimation.B({
    this.size,
    super.key,
  }) : level = 1;

  const NutriScoreAnimation.C({
    this.size,
    super.key,
  }) : level = 2;

  const NutriScoreAnimation.D({
    this.size,
    super.key,
  }) : level = 3;

  const NutriScoreAnimation.E({
    this.size,
    super.key,
  }) : level = 4;

  final int level;
  final Size? size;

  @override
  State<NutriScoreAnimation> createState() => _NutriScoreAnimationState();
}

class _NutriScoreAnimationState extends State<NutriScoreAnimation> {
  StateMachineController? _controller;

  @override
  void didUpdateWidget(covariant NutriScoreAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _changeNutriScoreState(widget.level);
  }

  /// -1 is the initial value (= no NutriScore)
  /// 0 : NutriScore A
  /// 1 : NutriScore B
  /// 2 : NutriScore C
  /// 3 : NutriScore D
  /// 4 : NutriScore E
  /// You can test it here [https://rive.app/s/aSxao_1Mwkixud5Z2GbA5A/]
  void _changeNutriScoreState(int nutriScoreValue) {
    assert(nutriScoreValue >= -1 && nutriScoreValue <= 4);
    final SMINumber currentValue = _controller!.getNumberInput('value')!;
    if (currentValue.value != nutriScoreValue) {
      currentValue.value = nutriScoreValue.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Semantics(
      // TODO(g123k): Update with V2 once the animation is ready
      label: switch (widget.level) {
        0 => localizations.nutriscore_a,
        1 => localizations.nutriscore_b,
        2 => localizations.nutriscore_c,
        3 => localizations.nutriscore_d,
        4 => localizations.nutriscore_e,
        _ => localizations.nutriscore_unknown,
      },
      image: true,
      child: SizedBox.fromSize(
        size: widget.size ??
            Size.fromHeight(
              IconTheme.of(context).size ?? 24.0,
            ),
        child: AspectRatio(
          aspectRatio: 176 / 94,
          child: RiveAnimation.asset(
            'assets/animations/nutriscore.riv',
            artboard: 'Nutriscore',
            fit: BoxFit.contain,
            onInit: (Artboard artboard) {
              _controller = StateMachineController.fromArtboard(
                artboard,
                'Nutriscore',
              );

              artboard.addController(_controller!);
              _changeNutriScoreState(widget.level);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
