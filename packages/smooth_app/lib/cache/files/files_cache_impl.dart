// ignore_for_file: avoid_slow_async_io
part of 'files_cache.dart';

/// Implementation based on [getTemporaryDirectory]
class _ShortLivingFileCacheManagerImpl extends _FileCacheManagerImpl {
  _ShortLivingFileCacheManagerImpl._() : super._();

  @override
  Future<void> _init(String name) async {
    return _initCache(name, await getTemporaryDirectory());
  }
}

/// Implementation based on [getApplicationDocumentsDirectory]
class _LongLivingFilesCacheManagerImpl extends _FileCacheManagerImpl {
  _LongLivingFilesCacheManagerImpl._() : super._();

  @override
  Future<void> _init(String name) async {
    return _initCache(name, await getApplicationDocumentsDirectory());
  }
}

abstract class _FileCacheManagerImpl extends FileCache {
  factory _FileCacheManagerImpl(FileCacheType type) {
    switch (type) {
      case FileCacheType.shortLiving:
        return _ShortLivingFileCacheManagerImpl._();
      case FileCacheType.longLiving:
        return _LongLivingFilesCacheManagerImpl._();
    }
  }

  _FileCacheManagerImpl._() : super();

  late Directory _directory;

  Future<void> _init(String name);

  /// Please never call this method call directly, but use instead [_init].
  Future<void> _initCache(String name, Directory directory) async {
    _directory = Directory(
      join(
        directory.absolute.path,
        'files_cache',
        name,
      ),
    );

    await _directory.create(recursive: true);
  }

  File _getFilePath(String key) {
    return File(join(_directory.absolute.path, key));
  }

  @override
  Future<Uint8List?> get(String key) {
    final File file = _getFilePath(key);
    return file
        .exists()
        .then((bool exists) => exists ? file.readAsBytes() : null);
  }

  @override
  Future<bool> containsKey(String key) {
    return _getFilePath(key).exists();
  }

  @override
  Future<bool> put(
    String key,
    Uint8List item, {
    bool overrideExistingItem = true,
  }) async {
    if (await containsKey(key) && !overrideExistingItem) {
      return false;
    }

    // Will erase existing file
    final File file = _getFilePath(key);

    try {
      await file.writeAsBytes(
        item,
        mode: FileMode.writeOnly,
        flush: true,
      );
    } on FileSystemException {
      return false;
    }

    notifyListeners();
    return true;
  }

  @override
  Future<int> get length => _directory.list().length;

  @override
  Future<bool> remove(String key) async {
    if (await containsKey(key)) {
      await _getFilePath(key).delete();
      notifyListeners();
      return true;
    }

    return false;
  }

  @override
  Future<void> clear() async {
    // Only delete content, not the folder itself
    final List<FileSystemEntity> files =
        await _directory.list(recursive: true).toList();

    for (final FileSystemEntity file in files) {
      await file.delete();
    }

    notifyListeners();
  }
}
