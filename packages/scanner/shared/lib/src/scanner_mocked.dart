import 'package:app_store_shared/src/app_store.dart';

/// Empty implementation for an [AppStore]
class MockedScanner extends Scanner {
  const MockedScanner();


  // TODO(M123):
  @override
  Widget getScanner(Future<bool> Function(String) onScan);
}
