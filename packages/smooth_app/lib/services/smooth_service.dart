/// Generic interface for a service (eg: logger, analytics…) containing
/// one or multiple implementations
abstract class SmoothService<T extends SmoothServiceImpl> {
  SmoothService() : _impls = <T>{};

  final Set<T> _impls;

  Future<bool> attach(T impl) async {
    if (!_impls.contains(impl)) {
      _impls.add(impl);
      await impl.init();
      return true;
    }

    return false;
  }

  bool detach(T impl) {
    return _impls.remove(impl);
  }

  Set<T> get impls => _impls;
}

/// Generic interface for a service implementation
abstract class SmoothServiceImpl {
  Future<void> init();
}
