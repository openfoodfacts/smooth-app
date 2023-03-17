import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/pages/scan/scan_header.dart';
import 'package:smooth_app/pages/scan/scan_visor.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';

class SmoothBarcodeScannerAwesome extends StatelessWidget {
  const SmoothBarcodeScannerAwesome(this.onScan);

  final Future<bool> Function(String) onScan;

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      enableAudio: false,
      saveConfig: SaveConfig.photo(
        pathBuilder: () async {
          return 'just_needed_because.jpg';
        },
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
          onPhotoMode: (PhotoCameraState state) => BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
          onVideoRecordingMode: (VideoRecordingCameraState state) =>
              BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
          onVideoMode: (VideoCameraState state) => BarcodeScannerViewWidget(
            onScan: onScan,
            cameraState: cameraState,
            previewSize: previewSize,
            previewRect: previewRect,
          ),
        ) as Widget;
      },
    );
  }
}

// TODO(m123): Re-add camera switch
/// Barcode scanner based on MLKit.
class BarcodeScannerViewWidget extends StatelessWidget {
  const BarcodeScannerViewWidget({
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
