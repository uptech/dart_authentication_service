import 'package:dart_authentication_service/dart_authentication_service.dart';
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

  void logIn(String username, String password, bool rememberMe) {
    try {
      auth?.logIn(username, password);
      if (rememberMe) {
        box?.put('username', username);
      } else {
        box?.put('username', null);
      }
    } catch (error) {}
  }

  User? currentUser() {
    return auth?.currentUser();
  }

  String? lastUsername() {
    return box?.get('username');
  }
}
