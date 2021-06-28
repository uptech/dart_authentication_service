import 'package:dart_authentication_service/src/user.dart';

class CognitoUserImpl implements User {
  String? username;
  String? password;
  String? name;
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? customProperties;
}
