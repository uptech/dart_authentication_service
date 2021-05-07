import 'package:dart_authentication_service/src/user.dart';

enum AuthenticationError {
  invalidPassword,
  invalidUsername,
  invalidCredentials,
  unknown
}

class AuthenticationResult {
  late bool success;
  List<AuthenticationError>? errors = [];

  AuthenticationResult({required this.success, this.errors});
}
