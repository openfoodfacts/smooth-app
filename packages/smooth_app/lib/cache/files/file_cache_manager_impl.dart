import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:smooth_app/cache/files/file_cache_manager.dart';

/// A FileCache implementation where files are stored in
/// [rootDirectory]/files_cache/[subFolderName]
class FileCacheImpl extends FileCache {
  FileCacheImpl({
    required this.rootDirectory,
    required this.subFolderName,
  }) : assert(subFolderName.isNotEmpty);

  final Future<Directory> rootDirectory;
  final String subFolderName;

  /// This field will be lazily assigned after a call to [initCache]
  Directory? _directory;

  @protected
  Future<void> initCache() async {
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
      await initCache();
    }
  }

  Future<File> _getFilePath(String key) async {
    await _ensureInitialized();
    return File(join(_directory!.absolute.path, key));
  }

  @override
  Future<Uint8List?> get(String key) async {
    final File file = await _getFilePath(key);

    if (file.existsSync()) {
      return file.readAsBytes();
    } else {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) {
    return _getFilePath(key).then((File file) => file.existsSync());
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

    return true;
  }

  @override
  Future<int> get length => _ensureInitialized().then(
        (_) => _directory!.list().length,
      );

  @override
  Future<bool> remove(String key) async {
    if (await containsKey(key)) {
      await _getFilePath(key).then((File file) => file.delete());
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
  }
}
