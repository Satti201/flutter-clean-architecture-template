class DataException implements Exception {
  final String message;
  final String? code;

  const DataException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}
