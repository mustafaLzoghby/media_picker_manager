class SuperMediaValidationError implements Exception {
  final String code;
  final String message;
  final Object? item;

  const SuperMediaValidationError(this.code, this.message, {this.item});

  @override
  String toString() => 'SuperMediaValidationError($code): $message';
}
