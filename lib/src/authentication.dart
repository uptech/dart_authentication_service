import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:hive/hive.dart';

class Authentication {
  AuthenticationProvider? auth;
  User? user;
  bool persistUser = false;
  Box? box;
  final String usernameKey = 'username';
  final String accessTokenKey = 'accessToken';
  final String refreshTokenKey = 'refreshToken';

  Future<void> init(AuthenticationProvider provider) async {
    this.auth = provider;
    Hive.init('authentication');
    this.box = await Hive.openBox('authentication');
  }

  Future<AuthenticationResult> isLoggedIn() async {
    // if the user is null, try and grab the properties from box
    if (user == null) {
      var username = box?.get(usernameKey);
      var accessToken = box?.get(accessTokenKey);
      var refreshToken = box?.get(refreshTokenKey);

      // if we have all of the properties, then create a user to use later
      if (username != null && accessToken != null && refreshToken != null) {
        persistUser =
            true; // we found the user in storage, so let's flag it as such
        user = AuthenticationUser(
            username: username,
            accessToken: accessToken,
            refreshToken: refreshToken);
      }
    }

    // since we have a user, we can ask the provider if they are logged in
    if (user != null) {
      AuthenticationResult result =
          await auth?.isLoggedIn(user!) ?? AuthenticationResult(success: false);
      // update the local user
      if (result.success) {
        user = result.user;
        if (persistUser) {
          _persistUser();
        }
      }
      return result;
    }
    return AuthenticationResult(success: false);
  }

  Future<AuthenticationResult> logIn(
      {required String username,
      required String password,
      bool? rememberMe}) async {
    try {
      var result = await auth?.logIn(username: username, password: password);
      user = result?.user;
      if (rememberMe ?? false) {
        _persistUser();
      } else {
        _removePersistedUser();
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

      // cache the user so it can be used in the verifyUser step
      if (result?.success ?? false) {
        user = result?.user;
      }

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

  Future<AuthenticationResult> logOut() async {
    try {
      AuthenticationResult? result;
      if (user != null) {
        result = await auth?.logOut(user: user!);
      } else {
        result = await auth?.logOut();
      }
      _removePersistedUser();
      user = null;
      return result ??
          AuthenticationResult(
              success: false, errors: [AuthenticationError.unknown]);
    } catch (error) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
  }

  User? currentUser() {
    return user;
  }

  String? lastUsername() {
    return box?.get(usernameKey);
  }

  void _persistUser() {
    persistUser = true;
    box?.put(usernameKey, user?.username);
    box?.put(accessTokenKey, user?.accessToken);
    box?.put(refreshTokenKey, user?.refreshToken);
  }

  void _removePersistedUser() {
    persistUser = false;
    box?.put(usernameKey, null);
    box?.put(accessTokenKey, null);
    box?.put(refreshTokenKey, null);
  }
}
