enum AuthenticationError { invalidPassword, invalidUsername, unknown }

class AuthenticationResult {
  late bool success;
  List<AuthenticationError>? errors = [];

  AuthenticationResult({required this.success, this.errors});
}
