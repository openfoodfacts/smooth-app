import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class SmoothFloatingMessage {
  SmoothFloatingMessage({
    required this.message,
  });

  final String message;

  OverlayEntry? _entry;
  Timer? _autoDismissMessage;

  /// Show the message during [duration].
  /// You can call [hide] if you want to dismiss it before
  void show(
    BuildContext context, {
    AlignmentGeometry? alignment,
    Duration? duration,
  }) {
    _entry?.remove();

    final double appBarHeight = Scaffold.maybeOf(context)?.hasAppBar == true
        ? (Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight)
        : MediaQuery.paddingOf(context).top;

    _entry = OverlayEntry(builder: (BuildContext context) {
      return _SmoothFloatingMessageView(
        message: message,
        alignment: alignment,
        margin: EdgeInsetsDirectional.only(
          top: appBarHeight,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
      );
    });

    Overlay.of(context).insert(_entry!);
    _autoDismissMessage = Timer(duration ?? const Duration(seconds: 5), () {
      hide();
    });
  }

  void hide() {
    _autoDismissMessage?.cancel();
    _entry?.remove();
  }
}

class _SmoothFloatingMessageView extends StatefulWidget {
  const _SmoothFloatingMessageView({
    required this.message,
    this.alignment,
    this.margin,
  });

  final String message;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  @override
  State<_SmoothFloatingMessageView> createState() =>
      _SmoothFloatingMessageViewState();
}

class _SmoothFloatingMessageViewState extends State<_SmoothFloatingMessageView>
    with SingleTickerProviderStateMixin {
  bool initial = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        initial = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final SnackBarThemeData snackBarTheme = Theme.of(context).snackBarTheme;

    return AnimatedOpacity(
      opacity: initial ? 0.0 : 1.0,
      duration: SmoothAnimationsDuration.short,
      child: SafeArea(
        top: false,
        child: Container(
          width: initial ? 0.0 : null,
          height: initial ? 0.0 : null,
          margin: widget.margin,
          alignment: widget.alignment ?? AlignmentDirectional.topCenter,
          child: Card(
            elevation: 4.0,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            color: snackBarTheme.backgroundColor,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: snackBarTheme.contentTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
