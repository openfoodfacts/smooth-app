// ignore_for_file: avoid_slow_async_io
part of 'files_cache.dart';

/// Implementation based on [getTemporaryDirectory]
class _ShortLivingFileCacheManagerImpl extends _FileCacheManagerImpl {
  _ShortLivingFileCacheManagerImpl({
    required String subFolderName,
  }) : super._(
          rootDirectory: getTemporaryDirectory(),
          subFolderName: subFolderName,
        );
}

/// Implementation based on [getApplicationDocumentsDirectory]
class _LongLivingFilesCacheManagerImpl extends _FileCacheManagerImpl {
  _LongLivingFilesCacheManagerImpl({
    required String subFolderName,
  }) : super._(
          rootDirectory: getApplicationDocumentsDirectory(),
          subFolderName: subFolderName,
        );
}

class _FileCacheManagerImpl extends FileCache {
  _FileCacheManagerImpl._({
    required this.rootDirectory,
    required this.subFolderName,
  }) : assert(subFolderName.isNotEmpty);

  final Future<Directory> rootDirectory;
  final String subFolderName;

  /// This field will be lazily assigned after a call to [_initCache]
  Directory? _directory;

  @protected
  Future<void> _initCache() async {
    if (_directory == null) {
      _directory = Directory(
        join(
          await rootDirectory.then((Directory d) => d.absolute.path),
          'files_cache',
          subFolderName,
        ),
      );
      await _directory!.create(recursive: true);
    }
  }

  Future<void> _ensureInitialized() async {
    if (_directory == null) {
      await _initCache();
    }
  }

  Future<File> _getFilePath(String key) async {
    await _ensureInitialized();
    return File(join(_directory!.absolute.path, key));
  }

  @override
  Future<Uint8List?> get(String key) async {
    final File file = await _getFilePath(key);
    return file
        .exists()
        .then((bool exists) => exists ? file.readAsBytes() : null);
  }

  @override
  Future<bool> containsKey(String key) {
    return _getFilePath(key).then((File file) => file.exists());
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
    final File file = await _getFilePath(key);

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
  Future<int> get length => _directory!.list().length;

  @override
  Future<bool> remove(String key) async {
    if (await containsKey(key)) {
      await _getFilePath(key).then((File file) => file.delete());
      notifyListeners();
      return true;
    }

    return false;
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();

    // Only delete content, not the folder itself
    final List<FileSystemEntity> files =
        await _directory!.list(recursive: true).toList();

    for (final FileSystemEntity file in files) {
      await file.delete();
    }

    notifyListeners();
  }
}
