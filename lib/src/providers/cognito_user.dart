import 'package:dart_authentication_service/src/user.dart';

class CognitoUser implements User {
  String? email;
  String? password;
  String? name;
  String? accessToken;
}
