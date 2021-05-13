import 'package:dart_authentication_service/src/user.dart';

enum AuthenticationError {
  invalidPassword,
  invalidUsername,
  invalidCredentials,
  rateLimitExceeded,
  unknown
}

class AuthenticationResult {
  late bool success;
  List<AuthenticationError>? errors = [];
  User? user;

  AuthenticationResult({required this.success, this.errors, this.user});
}
