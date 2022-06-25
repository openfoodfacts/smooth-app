import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/pages/scan/scan_flash_toggle.dart';

/// This Widget is a [StatefulWidget], as it uses a [GlobalKey] to allow an
/// external access
class ScannerVisorWidget extends StatefulWidget {
  const ScannerVisorWidget({
    super.key,
  });

  @override
  State<ScannerVisorWidget> createState() => ScannerVisorWidgetState();

  /// Returns the Size of the visor
  static Size getSize(BuildContext context) => Size(
        MediaQuery.of(context).size.width * 0.8,
        150.0,
      );
}

class ScannerVisorWidgetState extends State<ScannerVisorWidget> {
  @override
  Widget build(BuildContext context) {
    if (!CameraHelper.hasACamera) {
      return const SizedBox.shrink();
    }

    return Stack(
      key: Provider.of<GlobalKey<ScannerVisorWidgetState>>(context),
      children: <Widget>[
        SizedBox.fromSize(
          size: ScannerVisorWidget.getSize(context),
          child: CustomPaint(
            painter: ScanVisorPainter(),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/visor_icon.svg',
                width: 35.0,
                height: 32.0,
              ),
            ),
          ),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          end: 0.0,
          bottom: 0.0,
          child: const ScannerFlashToggleWidget(),
        )
      ],
    );
  }
}

class ScanVisorPainter extends CustomPainter {
  ScanVisorPainter();

  static const double strokeWidth = 3.0;
  static const double _fullCornerSize = 31.0;
  static const double _halfCornerSize = _fullCornerSize / 2;
  static const Radius _borderRadius = Radius.circular(_halfCornerSize);

  final Paint _paint = Paint()
    ..strokeWidth = strokeWidth
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
      bottomPosition = rect.bottom - strokeWidth;
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
