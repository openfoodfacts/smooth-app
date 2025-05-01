import 'package:crop_image/crop_image.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth_app/pages/crop_helper.dart';

/// Model about the eraser tool: coordinate computations.
class EraserModel {
  EraserModel({
    this.rotation = CropRotation.up,
    final List<Offset>? offsets,
  }) : offsets = offsets ?? <Offset>[];

  CropRotation rotation;

  final List<Offset> offsets;

  Rect? cropRect;

  late double _imageWidth;
  late double _imageHeight;

  // Canvas size.
  set size(final Size value) {
    _imageWidth = value.width;
    _imageHeight = value.height;
  }

  // Full displayed image dimensions. For screen crop grid only.
  late double _fullWidth;
  late double _fullHeight;

  set _boxConstraints(final BoxConstraints value) {
    _fullWidth = value.maxWidth;
    _fullHeight = value.maxHeight;
  }

  double get _deltaX => (_fullWidth - _imageWidth) / 2;

  double get _deltaY => (_fullHeight - _imageHeight) / 2;

  Offset? _latestStart;
  Offset? _latestUpdate;

  bool get isEmpty => offsets.isEmpty;

  int get length => offsets.length ~/ 2;

  // From full image [0,1] to possibly cropped
  Offset _fromPct(final Offset offset) {
    final Rect rect = cropRect ?? CropHelper.fullImageCropRect;
    return switch (rotation) {
      CropRotation.down => Offset(
          (1 - offset.dx - rect.left) / rect.width * _imageWidth,
          (1 - offset.dy - rect.top) / rect.height * _imageHeight,
        ),
      CropRotation.left => Offset(
          (offset.dy - rect.left) / rect.width * _imageWidth,
          (1 - offset.dx - rect.top) / rect.height * _imageHeight,
        ),
      CropRotation.right => Offset(
          (1 - offset.dy - rect.left) / rect.width * _imageWidth,
          (offset.dx - rect.top) / rect.height * _imageHeight,
        ),
      CropRotation.up => Offset(
          (offset.dx - rect.left) / rect.width * _imageWidth,
          (offset.dy - rect.top) / rect.height * _imageHeight,
        ),
    };
  }

  // From screen offset to full image [0,1] offset
  Offset _toPct(final Offset offset) => switch (rotation) {
        CropRotation.down => Offset(
            (_imageWidth - (offset.dx - _deltaX)) / _imageWidth,
            (_imageHeight - (offset.dy - _deltaY)) / _imageHeight,
          ),
        CropRotation.left => Offset(
            (_imageHeight - (offset.dy - _deltaY)) / _imageHeight,
            (0 + (offset.dx - _deltaX)) / _imageWidth,
          ),
        CropRotation.right => Offset(
            (offset.dy - _deltaY) / _imageHeight,
            (_imageWidth - (offset.dx - _deltaX)) / _imageWidth,
          ),
        _ => Offset(
            (offset.dx - _deltaX) / _imageWidth,
            (offset.dy - _deltaY) / _imageHeight,
          ),
      };

  Offset getStart(final int index) => _fromPct(offsets[2 * index]);

  Offset getEnd(final int index) => _fromPct(offsets[2 * index + 1]);

  Offset? getCurrentStart() =>
      _latestStart == null ? null : _fromPct(_latestStart!);

  Offset? getCurrentEnd() =>
      _latestUpdate == null ? null : _fromPct(_latestUpdate!);

  void panStart(
    final Offset offset,
    final BoxConstraints constraints,
  ) {
    _boxConstraints = constraints;
    _latestStart = _latestUpdate = _toPct(offset);
  }

  void panUpdate(
    final Offset offset,
    final BoxConstraints constraints,
  ) {
    _boxConstraints = constraints;
    _latestUpdate = _toPct(offset);
  }

  void panEnd() {
    if (_latestStart != _latestUpdate) {
      if (_latestStart != null && _latestUpdate != null) {
        offsets.add(_latestStart!);
        offsets.add(_latestUpdate!);
      }
    }
    _latestStart = _latestUpdate = null;
  }

  void undo() {
    offsets.removeLast();
    offsets.removeLast();
  }
}
