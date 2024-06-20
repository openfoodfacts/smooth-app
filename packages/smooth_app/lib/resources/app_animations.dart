import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/services/smooth_services.dart';
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

  static RiveFile of(BuildContext context) {
    return context.read<_AnimationsLoaderState>()._file;
  }
}

class _AnimationsLoaderState extends State<AnimationsLoader> {
  late final RiveFile _file;

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
    return Provider<_AnimationsLoaderState>.value(
      value: this,
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
    return RiveAnimation.direct(
      AnimationsLoader.of(context),
      artboard: 'Barcode',
      stateMachines: const <String>['StateMachine'],
    );
  }
}

class CloudUploadAnimation extends StatelessWidget {
  const CloudUploadAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.direct(
      AnimationsLoader.of(context),
      artboard: 'Cloud upload',
      animations: const <String>['Animation'],
    );
  }
}

class ConsentAnimation extends StatelessWidget {
  const ConsentAnimation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.direct(
      AnimationsLoader.of(context),
      artboard: 'Consent',
      animations: const <String>['Loop'],
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
        AnimationsLoader.of(context),
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
        child: RiveAnimation.direct(AnimationsLoader.of(context),
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
        AnimationsLoader.of(context),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.direct(
      AnimationsLoader.of(context),
      artboard: 'Success',
      animations: const <String>['Timeline 1'],
    );
  }
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
