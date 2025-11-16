import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A wrapper widget for Rive animations that supports visibility detection.
class RiveAnimation extends StatefulWidget {
  const RiveAnimation({
    required this.artboard,
    this.stateMachine = 'State Machine',
    this.fit,
    this.alignment,
    this.onDataBindAvailable,
    this.colorChanger,
    this.autoBinding = true,
    this.width,
    this.height,
    super.key,
  }) : assert(artboard.length > 0),
       assert(stateMachine.length > 0);

  final String artboard;
  final String stateMachine;
  final Fit? fit;
  final Alignment? alignment;
  final double? width;
  final double? height;
  final RiveVMICallback? onDataBindAvailable;
  final RiveColorChanger? colorChanger;
  final bool autoBinding;

  @override
  State<RiveAnimation> createState() => _RiveAnimationState();
}

class _RiveAnimationState extends State<RiveAnimation> {
  // Auto-disposed by Rive
  RiveWidgetController? _controller;

  // Auto-disposed by us
  ViewModelInstance? _dataBind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: VisibilityDetector(
        key: Key(widget.artboard),
        onVisibilityChanged: (VisibilityInfo info) {
          try {
            _controller?.active = info.visibleFraction > 0.0;
          } catch (_) {}
        },
        child: RiveWidgetBuilder(
          fileLoader: context.read<FileLoader>(),
          artboardSelector: ArtboardNamed(widget.artboard),
          stateMachineSelector: StateMachineNamed(widget.stateMachine),
          builder: (BuildContext context, RiveState state) {
            switch (state) {
              case RiveLoading():
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );

              case RiveFailed():
                debugPrintStack(
                  stackTrace: state.stackTrace,
                  label: state.error.toString(),
                );
                return EMPTY_WIDGET;

              case RiveLoaded():
                if (_controller != state.controller ||
                    (_dataBind == null && widget.autoBinding)) {
                  _controller = state.controller;

                  if (widget.autoBinding) {
                    _dataBind = state.controller.dataBind(DataBind.auto());
                  }

                  if (widget.onDataBindAvailable != null) {
                    onNextFrame(
                      () => widget.onDataBindAvailable?.call(_dataBind!),
                    );
                  }

                  if (widget.colorChanger != null) {
                    for (final String key in widget.colorChanger!.keys) {
                      _dataBind!.color(key)!.value = widget.colorChanger![key]!;
                    }
                  }
                }

                return RiveWidget(
                  controller: state.controller,
                  fit: widget.fit ?? RiveDefaults.fit,
                  alignment: widget.alignment ?? RiveDefaults.alignment,
                );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataBind?.dispose();
    super.dispose();
  }
}

typedef RiveVMICallback = void Function(ViewModelInstance);
typedef RiveColorChanger = Map<String, Color>;

class RiveAnimationsLoader extends StatelessWidget {
  const RiveAnimationsLoader({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Provider<FileLoader>(
      create: (_) => FileLoader.fromAsset(
        'assets/animations/off.riv',
        riveFactory: Factory.rive,
      ),
      dispose: (_, FileLoader fileLoader) => fileLoader.dispose(),
      child: child,
    );
  }

  static FileLoader? of(BuildContext context, {bool listen = false}) {
    return Provider.of<FileLoader?>(context, listen: listen);
  }
}
