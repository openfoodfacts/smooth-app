/*
import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_visor.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';

class SmoothBarcodeScannerAwesome extends StatelessWidget {
  SmoothBarcodeScannerAwesome(this.onScan);

  final Future<bool> Function(String) onScan;

  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: <BarcodeFormat>[
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      // probably not
      //qrCode,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.pdf417,
      BarcodeFormat.aztec,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      enableAudio: false,
      saveConfig: SaveConfig.photo(
        pathBuilder: () async {
          return 'just_needed_because.jpg';
        },
      ),
      onImageForAnalysis: (AnalysisImage img) => _processImageBarcode(img),
      imageAnalysisConfig: AnalysisConfig(
        outputFormat: InputAnalysisImageFormat.nv21,
        width: 1024,
        maxFramesPerSecond: 5,
      ),
      builder: (
        CameraState cameraState,
        PreviewSize previewSize,
        Rect previewRect,
      ) {
        // Return your UI (a Widget)
        return cameraState.when(
          onPreparingCamera: (PreparingCameraState state) =>
              const Center(child: CircularProgressIndicator()),
          onPhotoMode: (PhotoCameraState state) => _BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
          onVideoRecordingMode: (VideoRecordingCameraState state) =>
              _BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
          onVideoMode: (VideoCameraState state) => _BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
        ) as Widget;
      },
    );
  }

  Future<void> _processImageBarcode(AnalysisImage img) async {
    final Size imageSize = Size(img.width.toDouble(), img.height.toDouble());
    final InputImageRotation imageRotation =
        InputImageRotation.values.byName(img.rotation.name);

    final List<InputImagePlaneMetadata> planeData = img.planes.map(
      (ImagePlane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: img.height,
          width: img.width,
        );
      },
    ).toList();

    final InputImage inputImage;

    if (Platform.isIOS) {
      final InputImageData inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: _inputImageFormat(img.format),
        planeData: planeData,
      );

      final WriteBuffer allBytes = WriteBuffer();
      for (final ImagePlane plane in img.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final Uint8List bytes = allBytes.done().buffer.asUint8List();

      inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    } else {
      inputImage = InputImage.fromBytes(
        bytes: img.nv21Image!,
        inputImageData: InputImageData(
          imageRotation: imageRotation,
          inputImageFormat: InputImageFormat.nv21,
          planeData: planeData,
          size: Size(img.width.toDouble(), img.height.toDouble()),
        ),
      );
    }

    try {
      final List<Barcode> recognizedBarCodes =
          await _barcodeScanner.processImage(inputImage);
      for (final Barcode barcode in recognizedBarCodes) {
        debugPrint('Barcode: [${barcode.format}]: ${barcode.rawValue}');

        onScan(barcode.rawValue.toString());
      }
    } catch (error) {
      debugPrint('Camera awesome ml kit error $error');
      rethrow;
    }
  }

  InputImageFormat _inputImageFormat(InputAnalysisImageFormat format) {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}

// TODO(m123): Re-add camera switch
/// Barcode scanner based on MLKit.
class _BarcodeScannerViewWidget extends StatelessWidget {
  const _BarcodeScannerViewWidget({
    required this.onScan,
    required this.cameraState,
    required this.previewSize,
    required this.previewRect,
  });

  final Future<bool> Function(String) onScan;
  final CameraState cameraState;
  final PreviewSize previewSize;
  final Rect previewRect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              const Align(
                alignment: Alignment.topCenter,
                child: ScanHeader(),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: Text('Awesome', style: TextStyle(color: Colors.red)),
              ),
              Align(
                // 0: x axis center, -1 top 1 bottom of the screen
                alignment: const AlignmentDirectional(0, -0.6),
                child: ScannerVisorWidget(state: cameraState),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.5,
                    child: const SmoothProductCarousel(containSearchCard: true),
                  ),
                ),
              ),
            ],
          );
        },
      );
}
*/
