import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// A [Scanner] without camera: barcodes are typed or picked from a list.
/// Meant for development (desktop, simulators) only.
class MockedScanner extends Scanner {
  const MockedScanner();

  @override
  String getType() => 'Mocked';

  @override
  CustomScannerController getController() => _MockedScannerController();

  @override
  Future<bool> hasCamera({required bool front}) async => true;

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
  }) => _MockedScannerView(
    onScan: onScan,
    contentPadding: contentPadding ?? EdgeInsets.zero,
  );
}

class _MockedScannerController implements CustomScannerController {
  @override
  bool get isStarted => false;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void onPause() {}

  @override
  void toggleCamera() {}

  @override
  Listenable get hasTorchState => ChangeNotifier();

  @override
  bool get hasTorch => false;

  @override
  bool get isTorchOn => false;

  @override
  void turnTorchOn() {}

  @override
  void turnTorchOff() {}

  @override
  Widget buildCameraView({required void Function(String barcode) onScan}) =>
      _MockedScannerView(
        onScan: (String barcode) async {
          onScan(barcode);
          return true;
        },
      );
}

const List<String> _sampleBarcodes = <String>[
  '3017620422003',
  '5449000000996',
  '8076800195057',
  '3256540000667',
];

class _MockedScannerView extends StatefulWidget {
  const _MockedScannerView({
    required this.onScan,
    this.contentPadding = EdgeInsets.zero,
  });

  final Future<bool> Function(String) onScan;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<_MockedScannerView> createState() => _MockedScannerViewState();
}

class _MockedScannerViewState extends State<_MockedScannerView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String barcode) {
    final String value = barcode.trim();
    if (value.isNotEmpty) {
      widget.onScan(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black87,
      child: SafeArea(
        child: Padding(
          padding: widget.contentPadding,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Mocked scanner (dev)',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Barcode',
                        hintStyle: const TextStyle(color: Colors.white38),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () => _submit(_controller.text),
                        ),
                      ),
                      onSubmitted: _submit,
                    ),
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      children: <Widget>[
                        for (final String barcode in _sampleBarcodes)
                          ActionChip(
                            label: Text(barcode),
                            onPressed: () => _submit(barcode),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
