class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class FirestoreException extends AppException {
  const FirestoreException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
  });
}
