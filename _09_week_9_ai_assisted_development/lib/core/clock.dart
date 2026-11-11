/// Pure Dart clock abstraction for deterministic timestamps and testability.
abstract interface class AppClock {
  /// Returns the current point in time.
  DateTime now();
}

/// Production clock backed by the system wall clock.
class SystemClock implements AppClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Fixed clock implementation for deterministic unit and widget tests.
class FixedClock implements AppClock {
  const FixedClock(this.fixedNow);

  final DateTime fixedNow;

  @override
  DateTime now() => fixedNow;
}
