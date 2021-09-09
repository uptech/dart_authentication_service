import 'package:dart_authentication_service/src/user.dart';

enum AuthenticationError {
  invalidPassword,
  invalidUsername,
  couldNotSignIn,
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
  late String? nextStep;
  List<AuthenticationError>? errors = [];
  Map<String, String>? attributes;

  AuthenticationAttributesResult({
    required this.success,
    this.nextStep,
    this.errors,
    this.attributes,
  });
}
