/// Abstract class defining a cache containing items of type [T] and accessible
/// via a unique key of type [K]
abstract class CacheMap<K, T> {
  /// Saves an item
  /// Returns [true] if the item was saved
  Future<bool> put(
    K key,
    T item, {
    bool overrideExistingItem = true,
  });

  /// Gets an item by its key
  /// Returns [null] if it doesn't exist
  Future<T?> get(K key);

  /// Returns if an item is available in the cache by giving its [key]
  Future<bool> containsKey(K key);

  /// Returns the number of items
  Future<int> get length;

  /// Removes an item by its key
  /// Returns [true] if the item existed and is now removed
  Future<bool> remove(K key);

  /// Removes all items
  Future<void> clear();
}
