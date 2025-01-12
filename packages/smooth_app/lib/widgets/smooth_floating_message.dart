import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';

class SmoothFloatingMessage {
  SmoothFloatingMessage({
    required this.message,
    this.header,
    this.type = SmoothFloatingMessageType.success,
  });

  SmoothFloatingMessage.loading({
    required this.message,
    this.type = SmoothFloatingMessageType.success,
  }) : header = const Padding(
          padding: EdgeInsetsDirectional.only(top: SMALL_SPACE),
          child: CloudUploadAnimation(size: 50.0),
        );

  final String message;
  final Widget? header;
  final SmoothFloatingMessageType type;

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
        header: header,
        type: type,
        onTap: hide,
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
    required this.type,
    required this.onTap,
    this.header,
    this.alignment,
    this.margin,
  });

  final String message;
  final SmoothFloatingMessageType type;
  final Widget? header;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;
  final VoidCallback onTap;

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

    onNextFrame(() {
      if (widget.type == SmoothFloatingMessageType.error) {
        SmoothHapticFeedback.error();
      }

      setState(() {
        initial = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final SnackBarThemeData snackBarTheme = Theme.of(context).snackBarTheme;

    Widget child = Text(
      widget.message,
      textAlign: TextAlign.center,
      style: (snackBarTheme.contentTextStyle ?? const TextStyle()).copyWith(
        color: Colors.white,
      ),
    );

    if (widget.header != null) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          widget.header!,
          const SizedBox(height: SMALL_SPACE),
          child,
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedOpacity(
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
              shape: const RoundedRectangleBorder(
                borderRadius: ROUNDED_BORDER_RADIUS,
              ),
              color: _getColor(extension),
              child: Container(
                padding: const EdgeInsets.all(SMALL_SPACE),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(SmoothColorsThemeExtension theme) => switch (widget.type) {
        SmoothFloatingMessageType.success => theme.success,
        SmoothFloatingMessageType.error => theme.error,
        SmoothFloatingMessageType.warning => theme.warning,
      };
}

enum SmoothFloatingMessageType {
  success,
  error,
  warning,
}
