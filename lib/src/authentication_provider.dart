import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';

abstract class AuthenticationProvider {
  bool isLoggedIn();
  Future<AuthenticationResult> logIn(
      {required String username, required String password});

  Future<AuthenticationResult> createUser(
      {required String username,
      required String password,
      Map<String, dynamic>? properties});

  Future<AuthenticationResult> verifyUser(
      {required User user, required String code, String? attribute});

  Future<AuthenticationResult> refreshSession({required User user});

  User? currentUser();
}
