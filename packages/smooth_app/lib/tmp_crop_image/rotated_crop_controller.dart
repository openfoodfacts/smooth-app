import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image2;
import 'package:smooth_app/tmp_crop_image/rotated_crop_image.dart';
import 'package:smooth_app/tmp_crop_image/rotation.dart';

/// A controller to control the functionality of [RotatedCropImage].
class RotatedCropController extends ValueNotifier<RotatedCropControllerValue> {
  /// A controller for a [RotatedCropImage] widget.
  ///
  /// You can provide the required [aspectRatio] and the initial [defaultCrop].
  /// If [aspectRatio] is specified, the [defaultCrop] rect will be adjusted automatically.
  ///
  /// Remember to [dispose] of the [RotatedCropController] when it's no longer needed.
  /// This will ensure we discard any resources used by the object.
  RotatedCropController({
    double? aspectRatio,
    Rect defaultCrop = const Rect.fromLTWH(0, 0, 1, 1),
    Rotation rotation = Rotation.noon,
  })  : assert(aspectRatio != 0, 'aspectRatio cannot be zero'),
        assert(defaultCrop.left >= 0 && defaultCrop.left <= 1,
            'left should be 0..1'),
        assert(defaultCrop.right >= 0 && defaultCrop.right <= 1,
            'right should be 0..1'),
        assert(
            defaultCrop.top >= 0 && defaultCrop.top <= 1, 'top should be 0..1'),
        assert(defaultCrop.bottom >= 0 && defaultCrop.bottom <= 1,
            'bottom should be 0..1'),
        assert(defaultCrop.left < defaultCrop.right,
            'left must be less than right'),
        assert(defaultCrop.top < defaultCrop.bottom,
            'top must be less than bottom'),
        super(RotatedCropControllerValue(aspectRatio, defaultCrop, rotation));

  /// Creates a controller for a [RotatedCropImage] widget from an initial [RotatedCropControllerValue].
  RotatedCropController.fromValue(RotatedCropControllerValue value)
      : super(value);

  /// Aspect ratio of the image (width / height).
  ///
  /// The [crop] rectangle will be adjusted to fit this ratio.
  double? get aspectRatio => value.aspectRatio;

  set aspectRatio(double? newAspectRatio) {
    if (newAspectRatio != null) {
      value = value.copyWith(
          aspectRatio: newAspectRatio,
          crop: _adjustRatio(value.crop, newAspectRatio));
    } else {
      value = value.copyWith(aspectRatio: newAspectRatio);
    }
    notifyListeners();
  }

  /// Current crop rectangle of the image (percentage).
  ///
  /// [left] and [right] are normalized between 0 and 1 (full width).
  /// [top] and [bottom] are normalized between 0 and 1 (full height).
  ///
  /// If the [aspectRatio] was specified, the rectangle will be adjusted to fit that ratio.
  ///
  /// See also:
  ///
  ///  * [cropSize], which represents the same rectangle in pixels.
  Rect get crop => value.crop;

  set crop(Rect newCrop) {
    if (value.aspectRatio != null) {
      value = value.copyWith(crop: _adjustRatio(newCrop, value.aspectRatio!));
    } else {
      value = value.copyWith(crop: newCrop);
    }
    notifyListeners();
  }

  /// Current crop rectangle of the image (pixels).
  ///
  /// [left], [right], [top] and [bottom] are in pixels.
  ///
  /// If the [aspectRatio] was specified, the rectangle will be adjusted to fit that ratio.
  ///
  /// See also:
  ///
  ///  * [crop], which represents the same rectangle in percentage.

  set rotation(Rotation rotation) {
    value = value.copyWith(rotation: rotation);
    notifyListeners();
  }

  late ui.Image _bitmap;
  late Size _bitmapSize;

  //@internal
  set image(ui.Image newImage) {
    _bitmap = newImage;
    _bitmapSize = Size(newImage.width.toDouble(), newImage.height.toDouble());
    aspectRatio = aspectRatio; // force adjustment
    notifyListeners();
  }

  void rotateRight() {
    rotation = value.rotation.rotateRight;
    crop = Rect.fromCenter(
      center: Offset(1 - crop.center.dy, crop.center.dx),
      width: crop.height,
      height: crop.width,
    );
  }

  Rect _adjustRatio(Rect rect, double aspectRatio) {
    final double width = rect.width * _bitmapSize.width;
    final double height = rect.height * _bitmapSize.height;
    if (width / height > aspectRatio) {
      final double w = height * aspectRatio / _bitmapSize.width;
      return Rect.fromLTWH(rect.center.dx - w / 2, rect.top, w, rect.height);
    } else {
      final double h = width / aspectRatio / _bitmapSize.height;
      return Rect.fromLTWH(rect.left, rect.center.dy - h / 2, rect.width, h);
    }
  }

  /// Returns the bitmap cropped with the current crop rectangle.
  ///
  /// You can provide the [quality] used in the resizing operation.
  /// Returns an [image2.Image] asynchronously.
  Future<image2.Image?> croppedBitmap({
    final ui.FilterQuality quality = FilterQuality.high,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final bool tilted = value.rotation.isTilted;
    final double cropWidth;
    final double cropHeight;
    if (tilted) {
      cropWidth = crop.width * _bitmapSize.height;
      cropHeight = crop.height * _bitmapSize.width;
    } else {
      cropWidth = crop.width * _bitmapSize.width;
      cropHeight = crop.height * _bitmapSize.height;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cropWidth, cropHeight),
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    final Offset cropCenter = value.rotation.getRotatedOffset(
      value.crop.center,
      _bitmapSize.width,
      _bitmapSize.height,
    );

    final double alternateWidth = tilted ? cropHeight : cropWidth;
    final double alternateHeight = tilted ? cropWidth : cropHeight;
    if (value.rotation != Rotation.noon) {
      canvas.save();
      final double x = alternateWidth / 2;
      final double y = alternateHeight / 2;
      canvas.translate(x, y);
      canvas.rotate(value.rotation.radians);
      if (value.rotation == Rotation.threeOClock) {
        // TODO(monsieurtanuki): put in class Rotation?
        canvas.translate(
          -y,
          -cropWidth + x,
        );
      } else if (value.rotation == Rotation.nineOClock) {
        canvas.translate(
          y - cropHeight,
          -x,
        );
      } else if (value.rotation == Rotation.sixOClock) {
        canvas.translate(-x, -y);
      }
    }

    canvas.drawImageRect(
      _bitmap,
      Rect.fromCenter(
        center: cropCenter,
        width: alternateWidth,
        height: alternateHeight,
      ),
      Rect.fromLTWH(
        0,
        0,
        alternateWidth,
        alternateHeight,
      ),
      Paint(),
    );

    if (value.rotation != Rotation.noon) {
      canvas.restore();
    }

    final ui.Image img = await pictureRecorder.endRecording().toImage(
          cropWidth.round(),
          cropHeight.round(),
        );

    // Probably not too slow as it's the fastest format.
    final ByteData? rawData =
        await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (rawData == null) {
      return null;
    }
    // TODO(monsieurtanuki): perhaps a bit slow, which would call for a isolate/compute
    return image2.Image.fromBytes(
      cropWidth.round(),
      cropHeight.round(),
      rawData.buffer.asUint8List(),
    );
  }
}

@immutable
class RotatedCropControllerValue {
  const RotatedCropControllerValue(
    this.aspectRatio,
    this.crop,
    this.rotation,
  );

  final double? aspectRatio;
  final Rect crop;
  final Rotation rotation;

  RotatedCropControllerValue copyWith({
    double? aspectRatio,
    Rect? crop,
    Rotation? rotation,
  }) =>
      RotatedCropControllerValue(
        aspectRatio ?? this.aspectRatio,
        crop ?? this.crop,
        rotation ?? this.rotation,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is RotatedCropControllerValue &&
        other.aspectRatio == aspectRatio &&
        other.crop == crop &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(
        aspectRatio.hashCode,
        crop.hashCode,
        rotation.hashCode,
      );
}

////@internal
extension RectExtensions on Rect {
  ////@internal
  Rect multiply(Size size) => Rect.fromLTRB(
        left * size.width,
        top * size.height,
        right * size.width,
        bottom * size.height,
      );

  ////@internal
  Rect divide(Size size) => Rect.fromLTRB(
        left / size.width,
        top / size.height,
        right / size.width,
        bottom / size.height,
      );
}
