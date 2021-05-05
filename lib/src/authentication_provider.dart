import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';

abstract class AuthenticationProvider {
  bool isLoggedIn();
  Future<AuthenticationResult> logIn(String username, String password);
  User? currentUser();
}
