import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/tmp_crop_image/crop_grid.dart';
import 'package:smooth_app/tmp_crop_image/rotated_crop_controller.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';

/// Widget to crop images.
///
/// See also:
///
///  * [RotatedCropController] to control the functioning of this widget.
class RotatedCropImage extends StatefulWidget {
  const RotatedCropImage({
    Key? key,
    this.controller,
    required this.image,
    this.gridColor = Colors.white70,
    this.gridCornerSize = 25,
    this.gridThinWidth = 2,
    this.gridThickWidth = 5,
    this.scrimColor = Colors.black54,
    this.alwaysShowThirdLines = false,
    this.onCrop,
    this.minimumImageSize = 100,
  })  : assert(gridCornerSize > 0, 'gridCornerSize cannot be zero'),
        assert(gridThinWidth > 0, 'gridThinWidth cannot be zero'),
        assert(gridThickWidth > 0, 'gridThickWidth cannot be zero'),
        assert(minimumImageSize > 0, 'minimumImageSize cannot be zero'),
        super(key: key);

  /// Controls the crop values being applied.
  ///
  /// If null, this widget will create its own [RotatedCropController]. If you want to specify initial values of
  /// [aspectRatio] or [defaultCrop], you need to use your own [RotatedCropController].
  /// Otherwise, [aspectRatio] will not be enforced and the [defaultCrop] will be the full image.
  final RotatedCropController? controller;

  /// The image to be cropped.
  final ui.Image image;

  /// The crop grid color.
  ///
  /// Defaults to 70% white.
  final Color gridColor;

  /// The size of the corner of the crop grid.
  ///
  /// Defaults to 25.
  final double gridCornerSize;

  /// The width of the crop grid thin lines.
  ///
  /// Defaults to 2.
  final double gridThinWidth;

  /// The width of the crop grid thick lines.
  ///
  /// Defaults to 5.
  final double gridThickWidth;

  /// The crop grid scrim (outside area overlay) color.
  ///
  /// Defaults to 54% black.
  final Color scrimColor;

  /// True if third lines of the crop grid are always displayed.
  /// False if third lines are only displayed while the user manipulates the grid.
  ///
  /// Defaults to false.
  final bool alwaysShowThirdLines;

  /// Event called when the user changes the crop rectangle.
  ///
  /// The passed [Rect] is normalized between 0 and 1.
  ///
  /// See also:
  ///
  ///  * [RotatedCropController], which can be used to read this and other details of the crop rectangle.
  final ValueChanged<Rect>? onCrop;

  /// The minimum pixel size the crop rectangle can be shrunk to.
  ///
  /// Defaults to 100.
  final double minimumImageSize;

  @override
  State<RotatedCropImage> createState() => _RotatedCropImageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(DiagnosticsProperty<RotatedCropController>(
        'controller', controller,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ui.Image>('image', image));
    properties.add(DiagnosticsProperty<Color>('gridColor', gridColor));
    properties
        .add(DiagnosticsProperty<double>('gridCornerSize', gridCornerSize));
    properties.add(DiagnosticsProperty<double>('gridThinWidth', gridThinWidth));
    properties
        .add(DiagnosticsProperty<double>('gridThickWidth', gridThickWidth));
    properties.add(DiagnosticsProperty<Color>('scrimColor', scrimColor));
    properties.add(DiagnosticsProperty<bool>(
        'alwaysShowThirdLines', alwaysShowThirdLines));
    properties.add(DiagnosticsProperty<ValueChanged<Rect>>('onCrop', onCrop,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<double>('minimumImageSize', minimumImageSize));
  }
}

// ignore: constant_identifier_names
enum _CornerTypes { UpperLeft, UpperRight, LowerRight, LowerLeft, None, Move }

class _RotatedCropImageState extends State<RotatedCropImage> {
  late RotatedCropController controller;
  Rect currentCrop = Rect.zero;
  Size size = Size.zero;
  _TouchPoint? panStart;

  Map<_CornerTypes, Offset> get gridCorners => <_CornerTypes, Offset>{
        _CornerTypes.UpperLeft:
            controller.crop.topLeft.scale(size.width, size.height),
        _CornerTypes.UpperRight:
            controller.crop.topRight.scale(size.width, size.height),
        _CornerTypes.LowerRight:
            controller.crop.bottomRight.scale(size.width, size.height),
        _CornerTypes.LowerLeft:
            controller.crop.bottomLeft.scale(size.width, size.height),
      };

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? RotatedCropController();
    controller.addListener(onChange);
    currentCrop = controller.crop;

    controller.image = widget.image;
  }

  @override
  void dispose() {
    controller.removeListener(onChange);
    controller.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(RotatedCropImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      controller = RotatedCropController.fromValue(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      controller.dispose();
    }
  }

  final double maxWidthPct = 1;
  final double maxHeightPct = .75;

  double _getWidth(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxWidth = screenSize.width * maxWidthPct;
    final double maxHeight = screenSize.height * maxHeightPct;
    double imageRatio = widget.image.width / widget.image.height;
    final double screenRatio = maxWidth / maxHeight;
    if (widget.controller!.value.rotation.isTilted) {
      imageRatio = 1 / imageRatio;
    }
    if (imageRatio > screenRatio) {
      return maxWidth;
    }
    return maxHeight * imageRatio;
  }

  double _getHeight(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxWidth = screenSize.width * maxWidthPct;
    final double maxHeight = screenSize.height * maxHeightPct;
    double imageRatio = widget.image.width / widget.image.height;
    final double screenRatio = maxWidth / maxHeight;
    if (widget.controller!.value.rotation.isTilted) {
      imageRatio = 1 / imageRatio;
    }
    if (imageRatio < screenRatio) {
      return maxHeight;
    }
    return maxWidth / imageRatio;
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          //Container(color: Colors.red),
          SizedBox(
            width: _getWidth(context),
            height: _getHeight(context),
            child: CustomPaint(
              painter: ImageCustomPainter(
                widget.image,
                widget.controller!.value.rotation,
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: CropGrid(
                crop: currentCrop,
                gridColor: widget.gridColor,
                cornerSize: widget.gridCornerSize,
                thinWidth: widget.gridThinWidth,
                thickWidth: widget.gridThickWidth,
                scrimColor: widget.scrimColor,
                alwaysShowThirdLines: widget.alwaysShowThirdLines,
                isMoving: panStart != null,
                onSize: (final Size size) => this.size = size,
              ),
            ),
          )
        ],
      );

  void onPanStart(DragStartDetails details) {
    if (panStart == null) {
      final _CornerTypes type = hitTest(details.localPosition);
      if (type != _CornerTypes.None) {
        final Offset basePoint = gridCorners[
            (type == _CornerTypes.Move) ? _CornerTypes.UpperLeft : type]!;
        setState(() {
          panStart = _TouchPoint(type, details.localPosition - basePoint);
        });
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (panStart != null) {
      if (panStart!.type == _CornerTypes.Move) {
        moveArea(details.localPosition - panStart!.offset);
      } else {
        moveCorner(panStart!.type, details.localPosition - panStart!.offset);
      }
      widget.onCrop?.call(controller.crop);
    }
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      panStart = null;
    });
  }

  void onChange() {
    setState(() {
      currentCrop = controller.crop;
    });
  }

  _CornerTypes hitTest(Offset point) {
    for (final MapEntry<_CornerTypes, Offset> gridCorner
        in gridCorners.entries) {
      final Rect area = Rect.fromCenter(
          center: gridCorner.value,
          width: 2 * widget.gridCornerSize,
          height: 2 * widget.gridCornerSize);
      if (area.contains(point)) {
        return gridCorner.key;
      }
    }

    final Rect area = Rect.fromPoints(gridCorners[_CornerTypes.UpperLeft]!,
        gridCorners[_CornerTypes.LowerRight]!);
    return area.contains(point) ? _CornerTypes.Move : _CornerTypes.None;
  }

  void moveArea(Offset point) {
    final Rect crop = controller.crop.multiply(size);
    controller.crop = Rect.fromLTWH(
      point.dx.clamp(0, size.width - crop.width),
      point.dy.clamp(0, size.height - crop.height),
      crop.width,
      crop.height,
    ).divide(size);
  }

  void moveCorner(_CornerTypes type, Offset point) {
    final Rect crop = controller.crop.multiply(size);
    double left = crop.left;
    double top = crop.top;
    double right = crop.right;
    double bottom = crop.bottom;

    // TODO(monsieurtanuki): problematic as it sends exception when the clamp window is impossible (e.g left > right). Suggestion: catch exception and ignore movement
    switch (type) {
      case _CornerTypes.UpperLeft:
        left = point.dx.clamp(0, right - widget.minimumImageSize);
        top = point.dy.clamp(0, bottom - widget.minimumImageSize);
        break;
      case _CornerTypes.UpperRight:
        right = point.dx.clamp(left + widget.minimumImageSize, size.width);
        top = point.dy.clamp(0, bottom - widget.minimumImageSize);
        break;
      case _CornerTypes.LowerRight:
        right = point.dx.clamp(left + widget.minimumImageSize, size.width);
        bottom = point.dy.clamp(top + widget.minimumImageSize, size.height);
        break;
      case _CornerTypes.LowerLeft:
        left = point.dx.clamp(0, right - widget.minimumImageSize);
        bottom = point.dy.clamp(top + widget.minimumImageSize, size.height);
        break;
      default:
        assert(false);
    }

    if (controller.aspectRatio != null) {
      final double width = right - left;
      final double height = bottom - top;
      if (width / height > controller.aspectRatio!) {
        switch (type) {
          case _CornerTypes.UpperLeft:
          case _CornerTypes.LowerLeft:
            left = right - height * controller.aspectRatio!;
            break;
          case _CornerTypes.UpperRight:
          case _CornerTypes.LowerRight:
            right = left + height * controller.aspectRatio!;
            break;
          default:
            assert(false);
        }
      } else {
        switch (type) {
          case _CornerTypes.UpperLeft:
          case _CornerTypes.UpperRight:
            top = bottom - width / controller.aspectRatio!;
            break;
          case _CornerTypes.LowerRight:
          case _CornerTypes.LowerLeft:
            bottom = top + width / controller.aspectRatio!;
            break;
          default:
            assert(false);
        }
      }
    }

    controller.crop = Rect.fromLTRB(left, top, right, bottom).divide(size);
  }
}

class _TouchPoint {
  _TouchPoint(this.type, this.offset);

  final _CornerTypes type;
  final Offset offset;
}

class ImageCustomPainter extends CustomPainter {
  ImageCustomPainter(this.image, this.rotation);

  final ui.Image image;
  final Rotation rotation;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    double targetWidth = size.width;
    double targetHeight = size.height;
    double offset = 0;
    if (rotation != Rotation.noon) {
      if (rotation.isTilted) {
        final double tmp = targetHeight;
        targetHeight = targetWidth;
        targetWidth = tmp;
        offset = (targetWidth - targetHeight) / 2;
        if (rotation == Rotation.nineOClock) {
          offset = -offset;
        }
      }
      canvas.save();
      canvas.translate(targetWidth / 2, targetHeight / 2);
      canvas.rotate(rotation.radians);
      canvas.translate(-targetWidth / 2, -targetHeight / 2);
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offset, offset, targetWidth, targetHeight),
      _paint,
    );
    if (rotation != Rotation.noon) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
