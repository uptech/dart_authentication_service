import 'package:dart_authentication_service/src/authentication_provider.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/providers/cognito_user.dart';
import 'package:dart_authentication_service/src/user.dart';

class CognitoProvider implements AuthenticationProvider {
  CognitoUser? user;

  bool isLoggedIn() {
    return true;
  }

  AuthenticationResult logIn(String username, String password) {
    return AuthenticationResult(success: true);
  }

  User? currentUser() {
    return user;
  }
}
