import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SmoothBarcodeScannerVisor extends StatelessWidget {
  const SmoothBarcodeScannerVisor({
    this.contentPadding,
    super.key,
  });

  static const double CORNER_PADDING = 26.0;
  static const double STROKE_WIDTH = 3.0;

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
            child: SvgPicture.asset(
              'assets/icons/visor_icon.svg',
              width: 35.0,
              height: 32.0,
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
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.drawPath(getPath(rect, false), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  /// Returns a path to draw the visor
  /// [includeLineBetweenCorners] will draw lines between each corner, instead
  /// of moving the cursor
  static Path getPath(Rect rect, bool includeLineBetweenCorners) {
    final double bottomPosition;
    if (includeLineBetweenCorners) {
      bottomPosition = rect.bottom - SmoothBarcodeScannerVisor.STROKE_WIDTH;
    } else {
      bottomPosition = rect.bottom;
    }

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
    if (includeLineBetweenCorners) {
      path.lineTo(rect.right - _fullCornerSize, rect.top);
    } else {
      path.moveTo(rect.right - _fullCornerSize, rect.top);
    }

    path
      ..lineTo(rect.right - _halfCornerSize, rect.top)
      ..arcToPoint(
        Offset(rect.right, _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.right, rect.top + _fullCornerSize);

    // Bottom right
    if (includeLineBetweenCorners) {
      path.lineTo(rect.right, bottomPosition - _fullCornerSize);
    } else {
      path.moveTo(rect.right, bottomPosition - _fullCornerSize);
    }

    path
      ..lineTo(rect.right, bottomPosition - _halfCornerSize)
      ..arcToPoint(
        Offset(rect.right - _halfCornerSize, bottomPosition),
        radius: _borderRadius,
      )
      ..lineTo(rect.right - _fullCornerSize, bottomPosition);

    // Bottom left
    if (includeLineBetweenCorners) {
      path.lineTo(rect.left + _fullCornerSize, bottomPosition);
    } else {
      path.moveTo(rect.left + _fullCornerSize, bottomPosition);
    }

    path
      ..lineTo(rect.left + _halfCornerSize, bottomPosition)
      ..arcToPoint(
        Offset(rect.left, bottomPosition - _halfCornerSize),
        radius: _borderRadius,
      )
      ..lineTo(rect.left, bottomPosition - _fullCornerSize);

    if (includeLineBetweenCorners) {
      path.lineTo(rect.left, rect.top + _halfCornerSize);
    }

    return path;
  }
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
            Radius.circular(
              SmoothBarcodeScannerVisor.CORNER_PADDING,
            ),
          ),
          child: Tooltip(
            message: tooltip,
            enableFeedback: true,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
