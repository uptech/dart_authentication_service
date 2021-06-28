import 'package:dart_authentication_service/src/user.dart';
import 'package:dart_authentication_service/src/user_attribute.dart';

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

class AuthenticationAttributesResult {
  late bool success;
  List<AuthenticationError>? errors = [];
  List<UserAttribute>? attributes;

  AuthenticationAttributesResult(
      {required this.success, this.errors, this.attributes});
}
