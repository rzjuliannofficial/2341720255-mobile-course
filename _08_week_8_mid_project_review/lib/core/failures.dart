/// Base sealed failure hierarchy for typed domain error handling.
sealed class Failure {
  const Failure(this.message);

  /// User-facing error explanation without raw stack traces or exceptions.
  final String message;

  @override
  String toString() => message;
}

/// Failure originating from local persistence (SQLite or local preferences).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Failure caused by network connectivity, DNS, or timeouts.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure triggered when domain input violates business validation rules.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure returned by a remote API endpoint (4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
