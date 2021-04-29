import 'package:dart_authentication_service/dart_authentication_service.dart';

abstract class AuthenticationProvider {
  bool isLoggedIn();
  void logIn(String username, String password);
  User? currentUser();
}
