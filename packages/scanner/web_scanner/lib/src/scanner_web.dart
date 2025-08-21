import 'package:flutter/material.dart';
import 'package:scanner_shared/scanner_shared.dart';

/// Web-compatible scanner implementation
/// This is a placeholder implementation for experimental web deployment
/// 
/// TODO: Integrate with ZXingJS for camera-based scanning:
/// - Add js interop for ZXingJS library
/// - Implement camera access using html.window.navigator.mediaDevices
/// - Add proper error handling for camera permissions
/// - Support multiple camera selection
/// - Add flash/torch control where available
/// - Maintain API compatibility with mobile scanners
class ScannerWeb extends Scanner {
  const ScannerWeb();

  @override
  String getType() => 'Web';

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
    }) trackCustomEvent,
    required bool hasMoreThanOneCamera,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return _WebScannerPlaceholder(
      onScan: onScan,
    );
  }
}

/// Placeholder scanner widget for web
/// TODO: Integrate with ZXingJS or a web-compatible barcode scanner
class _WebScannerPlaceholder extends StatefulWidget {
  const _WebScannerPlaceholder({
    required this.onScan,
  });

  final Future<bool> Function(String) onScan;

  @override
  State<_WebScannerPlaceholder> createState() => _WebScannerPlaceholderState();
}

class _WebScannerPlaceholderState extends State<_WebScannerPlaceholder> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Web Scanner (Experimental)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Enter a barcode manually for testing:\n(Try: 3017620422003 for Nutella)',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter barcode (e.g., 3017620422003)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) async {
              final barcode = value.trim();
              if (barcode.isNotEmpty) {
                await widget.onScan(barcode);
                _controller.clear();
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final barcode = _controller.text.trim();
              if (barcode.isNotEmpty) {
                await widget.onScan(barcode);
                _controller.clear();
              }
            },
            child: const Text('Scan Barcode'),
          ),
          const SizedBox(height: 20),
          Text(
            'Camera scanning will be available in future updates\nwith ZXingJS integration.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}