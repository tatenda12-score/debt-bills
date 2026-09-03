class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;
  
  ValidationException(String message, this.errors) : super(message, 422);
}

class AuthException extends ApiException {
  AuthException(String message) : super(message, 401);
}
