/// Describes why a selected media item could not be accepted.
class SuperMediaValidationError implements Exception {
  /// A stable machine-readable identifier such as `max_items`.
  final String code;

  /// A developer-readable explanation of the validation failure.
  final String message;

  /// The media value associated with the failure, when available.
  final Object? item;

  /// Creates a validation error with a stable [code] and [message].
  const SuperMediaValidationError(this.code, this.message, {this.item});

  @override
  String toString() => 'SuperMediaValidationError($code): $message';
}
