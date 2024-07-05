/// Product loading status.
enum ProductLoadingStatus {
  /// Loading product from local database.
  LOADING,

  /// Product loaded.
  LOADED,

  /// Error.
  ERROR,

  /// Downloading product from back-end.
  DOWNLOADING,
}
