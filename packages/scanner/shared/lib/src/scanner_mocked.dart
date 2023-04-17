import 'package:flutter/material.dart';

import 'package:scanner_shared/app_store_shared.dart';

/// Empty implementation for an [AppStore]
class MockedScanner extends Scanner {
  const MockedScanner();

  // TODO(m123): Add mocked scanner
  @override
  Widget getScanner(Future<bool> Function(String) onScan) => Container();
}
