class ApplicationException implements Exception {
  ApplicationException(this.message);

  final String message;

  @override
  String toString() => message;
}
