import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:hive/hive.dart';

class Authentication {
  AuthenticationProvider? auth;
  Box? box;

  Future<void> init(AuthenticationProvider provider) async {
    this.auth = provider;
    Hive.init('authentication');
    this.box = await Hive.openBox('authentication');
  }

  bool isLoggedIn() {
    return auth?.isLoggedIn() ?? false;
  }

  Future<AuthenticationResult> logIn(
      {required String username,
      required String password,
      bool? rememberMe}) async {
    try {
      var result = await auth?.logIn(username: username, password: password);
      if (rememberMe ?? false) {
        box?.put('username', username);
      } else {
        box?.put('username', null);
      }
      return result ??
          AuthenticationResult(
              success: false, errors: [AuthenticationError.unknown]);
    } catch (error) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
  }

  Future<AuthenticationResult> createUser(
      {required String username,
      required String password,
      Map<String, dynamic>? properties}) async {
    try {
      var result = await auth?.createUser(
          username: username, password: password, properties: properties);

      return result ??
          AuthenticationResult(
              success: false, errors: [AuthenticationError.unknown]);
    } catch (error) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
  }

  Future<AuthenticationResult> verifyUser(
      {required User user, required String code, String? attribute}) async {
    try {
      var result =
          await auth?.verifyUser(user: user, code: code, attribute: attribute);

      return result ??
          AuthenticationResult(
              success: false, errors: [AuthenticationError.unknown]);
    } catch (error) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
  }

  Future<AuthenticationResult> refreshSession(User user) async {
    try {
      var result = await auth?.refreshSession(user: user);
      return result ??
          AuthenticationResult(
              success: false, errors: [AuthenticationError.unknown]);
    } catch (error) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
  }

  User? currentUser() {
    return auth?.currentUser();
  }

  String? lastUsername() {
    return box?.get('username');
  }
}
