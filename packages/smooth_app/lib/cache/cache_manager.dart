import 'package:flutter/foundation.dart';

/// Abstract class defining a cache containing items of type [T] and accessible
/// via a unique key of type [K]
abstract class CacheManager<K, T> extends ChangeNotifier {
  /// Save an item
  /// Returns [true] if the item was saved
  Future<bool> save(
    K key,
    T item, {
    bool overrideExistingItem = true,
  });

  /// Get an item by its key
  /// Returns [null] if it doesn't exist
  Future<T?> get(K key);

  /// Returns if an item is available in the cache
  Future<bool> has(K key);

  /// Returns the number of items
  Future<int> get count;

  /// Remove an item by its key
  /// Returns [true] if the item existed and is now removed
  Future<bool> remove(K key);

  /// Remove all items
  Future<void> clear();
}
