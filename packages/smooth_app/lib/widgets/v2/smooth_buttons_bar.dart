import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/keyboard_helper.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothButtonsBar2 extends StatefulWidget {
  const SmoothButtonsBar2({
    required this.positiveButton,
    this.negativeButton,
    this.backgroundColor,
    this.addViewPadding = true,
    this.animate = false,
    super.key,
  });

  final SmoothActionButton2 positiveButton;
  final SmoothActionButton2? negativeButton;
  final Color? backgroundColor;
  final bool addViewPadding;
  final bool animate;

  @override
  State<SmoothButtonsBar2> createState() => _SmoothButtonsBar2State();
}

class _SmoothButtonsBar2State extends State<SmoothButtonsBar2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animate ? SmoothAnimationsDuration.brief : Duration.zero,
      vsync: this,
    )..addListener(() => setState(() {}));

    _controller.drive(Tween<double>(begin: 0.0, end: 1.0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double viewPadding = widget.addViewPadding
        ? MediaQuery.viewPaddingOf(context).bottom
        : 0.0;
    final SmoothColorsThemeExtension? colors = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>();

    final Widget positiveButtonWidget = _SmoothPositiveButton2(
      data: widget.positiveButton,
    );

    final Widget child;
    if (widget.negativeButton != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(child: _SmoothNegativeButton2(data: widget.negativeButton!)),
          const SizedBox(width: SMALL_SPACE),
          Expanded(child: positiveButtonWidget),
        ],
      );
    } else {
      child = FractionallySizedBox(
        widthFactor: 0.75,
        child: positiveButtonWidget,
      );
    }

    return Opacity(
      opacity: _controller.value,
      child: Container(
        transform: Matrix4.translationValues(
          0.0,
          (15.0 + viewPadding + MEDIUM_SPACE + BALANCED_SPACE * 2) *
              (1.0 - _controller.value),
          0.0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              widget.backgroundColor ??
              (context.lightTheme() ? Colors.white : colors!.primaryUltraBlack),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0.0, -4.0),
            ),
          ],
        ),
        padding: EdgeInsetsDirectional.only(
          start: BALANCED_SPACE,
          end: BALANCED_SPACE,
          top: MEDIUM_SPACE,
          bottom: _bottomPadding + viewPadding,
        ),
        child: child,
      ),
    );
  }

  double get _bottomPadding {
    final double padding;
    if (Platform.isIOS) {
      padding = 0.0;
    } else if (Platform.isAndroid) {
      padding = VERY_SMALL_SPACE;
    } else {
      padding = MEDIUM_SPACE;
    }

    return padding + (context.keyboardVisible ? BALANCED_SPACE : 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SmoothActionButton2 {
  SmoothActionButton2({required this.text, required this.onPressed, this.icon})
    : assert(text.isNotEmpty);

  final String text;
  final Widget? icon;
  final VoidCallback? onPressed;
}

class _SmoothPositiveButton2 extends StatelessWidget {
  const _SmoothPositiveButton2({required this.data});

  final SmoothActionButton2 data;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return _SmoothBaseButton2(
      data: data,
      backgroundColor: lightTheme ? colors.primaryBlack : colors.primaryLight,
      foregroundColor: lightTheme ? Colors.white : colors.primaryDark,
    );
  }
}

class _SmoothNegativeButton2 extends StatelessWidget {
  const _SmoothNegativeButton2({required this.data});

  final SmoothActionButton2 data;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors = context
        .extension<SmoothColorsThemeExtension>();

    final bool lightTheme = context.lightTheme();

    return _SmoothBaseButton2(
      data: data,
      backgroundColor: lightTheme ? colors.primaryMedium : colors.primaryDark,
      foregroundColor: lightTheme ? colors.primaryDark : colors.primaryLight,
    );
  }
}

class _SmoothBaseButton2 extends StatelessWidget {
  const _SmoothBaseButton2({
    required this.data,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final SmoothActionButton2 data;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: CIRCULAR_BORDER_RADIUS,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BALANCED_SPACE,
          vertical: MEDIUM_SPACE,
        ),
      ),
      onPressed: data.onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          AutoSizeText(
            data.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            maxLines: 1,
          ),
          if (data.icon != null) ...<Widget>[
            const SizedBox(width: SMALL_SPACE),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 0.5),
              child: SizedBox(height: 13.0, child: FittedBox(child: data.icon)),
            ),
          ],
        ],
      ),
    );
  }
}
