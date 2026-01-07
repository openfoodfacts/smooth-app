import 'package:flutter/material.dart';

class SmoothBarcodeScannerVisor extends StatelessWidget {
  const SmoothBarcodeScannerVisor({
    required this.icon,
    this.contentPadding,
    super.key,
  });

  static const double CORNER_PADDING = 26.0;
  static const double STROKE_WIDTH = 3.0;

  final Widget icon;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry contentPadding = _computePadding(context);

    return AnimatedPadding(
      padding: contentPadding,
      // The duration is twice the time required to hide the header
      duration: const Duration(milliseconds: 250),
      curve: contentPadding.horizontal > CORNER_PADDING * 2
          ? Curves.easeOutQuad
          : Curves.decelerate,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _ScanVisorPainter(),
          child: Center(
            child: IconTheme.merge(
              data: const IconThemeData(size: 35.0, color: Colors.white),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsetsGeometry _computePadding(BuildContext context) {
    final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
      top: MediaQuery.viewPaddingOf(context).top + CORNER_PADDING / 2,
      start: CORNER_PADDING,
      end: CORNER_PADDING,
      bottom: CORNER_PADDING,
    );

    if (contentPadding == null) {
      return padding;
    } else {
      return padding.add(contentPadding!);
    }
  }
}

class _ScanVisorPainter extends CustomPainter {
  _ScanVisorPainter();

  static const double _fullCornerSize = 31.0;
  static const double _halfCornerSize = _fullCornerSize / 2;
  static const Radius _borderRadius = Radius.circular(_halfCornerSize);

  final Paint _paint = Paint()
    ..strokeWidth = SmoothBarcodeScannerVisor.STROKE_WIDTH
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);

    final Path path = getPath(rect);

    _paint.maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      _convertRadiusToSigma(2.0),
    );
    _paint.color = Colors.black12;
    canvas.drawPath(path, _paint);

    _paint.maskFilter = null;
    _paint.color = Colors.white;
    canvas.drawPath(path, _paint);
  }

  static double _convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }

  /// Returns a path to draw the visor
  /// [includeLineBetweenCorners] will draw lines between each corner, instead
  /// of moving the cursor
  static Path getPath(Rect rect) {
    final double bottomPosition = rect.bottom;

    final Path path = Path()
      // Top left
      ..moveTo(rect.left, rect.top + _fullCornerSize)
      ..lineTo(rect.left, rect.top + _halfCornerSize)
      ..arcToPoint(
        Offset(rect.left + _halfCornerSize, rect.top),
        radius: _borderRadius,
      )
      ..lineTo(rect.left + _fullCornerSize, rect.top);

    // Top right
    path.moveTo(rect.right - _fullCornerSize, rect.top);

    path
      ..lineTo(rect.right - _halfCornerSize, rect.top)
      ..arcToPoint(Offset(rect.right, _halfCornerSize), radius: _borderRadius)
      ..lineTo(rect.right, rect.top + _fullCornerSize);

    // Bottom right
    path.moveTo(rect.right, bottomPosition - _fullCornerSize);

    path
      ..lineTo(rect.right, bottomPosition - _halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - _halfCornerSize, bottomPosition),
        radius: _borderRadius,
      )
      ..lineTo(rect.right - _fullCornerSize, bottomPosition);

    // Bottom left
    path.moveTo(rect.left + _fullCornerSize, bottomPosition);

    path
      ..lineTo(rect.left + _halfCornerSize, bottomPosition)
      ..arcToPoint(
        Offset(rect.left, bottomPosition - _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.left, bottomPosition - _fullCornerSize);

    return path;
  }

  @override
  bool shouldRepaint(_ScanVisorPainter oldDelegate) => false;
}

class VisorButton extends StatelessWidget {
  const VisorButton({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tooltip,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(
            Radius.circular(SmoothBarcodeScannerVisor.CORNER_PADDING),
          ),
          child: Tooltip(
            message: tooltip,
            enableFeedback: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12.0),
              child: IconTheme(
                data: const IconThemeData(
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0.5, 0.5),
                      blurRadius: 2.0,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
