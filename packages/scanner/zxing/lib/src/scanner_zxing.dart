import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

// TODO(monsieurtanuki): obviously needs to be implemented.
/// Scanner implementation using ZXing
class ScannerZXing extends Scanner {
  const ScannerZXing();

  @override
  String getType() => 'ZXing';

  @override
  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(
      String msg,
      String category, {
      int? eventValue,
      String? barcode,
    })
    trackCustomEvent,
    required bool hasMoreThanOneCamera,
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _SmoothBarcodeScannerZXing(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      onCameraFlashError: onCameraFlashError,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
      toggleCameraModeTooltip: toggleCameraModeTooltip,
      toggleFlashModeTooltip: toggleFlashModeTooltip,
      barcodeScannerIcon: barcodeScannerIcon,
      torchOnIcon: torchOnIcon,
      torchOffIcon: torchOffIcon,
      contentPadding: contentPadding,
    );
  }
}

/// Barcode scanner based on ZXing.
class _SmoothBarcodeScannerZXing extends StatefulWidget {
  const _SmoothBarcodeScannerZXing({
    required this.onScan,
    required this.hapticFeedback,
    required this.onCameraFlashError,
    required this.hasMoreThanOneCamera,
    required this.barcodeScannerIcon,
    required this.torchOnIcon,
    required this.torchOffIcon,
    this.toggleCameraModeTooltip,
    this.toggleFlashModeTooltip,
    this.contentPadding,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

  final Widget barcodeScannerIcon;
  final Widget torchOnIcon;
  final Widget torchOffIcon;

  final EdgeInsetsGeometry? contentPadding;
  final String? toggleCameraModeTooltip;
  final String? toggleFlashModeTooltip;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerZXingState();
}

class _SmoothBarcodeScannerZXingState
    extends State<_SmoothBarcodeScannerZXing> {
  @override
  Widget build(BuildContext context) => VisibilityDetector(
    key: const ValueKey<String>('VisibilityDetector'),
    onVisibilityChanged: (final VisibilityInfo info) {},
    child: Stack(
      children: <Widget>[
        Center(
          child: SmoothBarcodeScannerVisor(
            icon: widget.barcodeScannerIcon,
            contentPadding: widget.contentPadding,
          ),
        ),
      ],
    ),
  );
}
