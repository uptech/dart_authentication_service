import 'package:dart_authentication_service/src/authentication_provider.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/providers/cognito_user.dart';
import 'package:dart_authentication_service/src/user.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class CognitoProvider implements AuthenticationProvider {
  CognitoUserImpl? user;
  String _userPoolId;
  String _clientId;

  CognitoProvider(this._userPoolId, this._clientId);

  bool isLoggedIn() {
    return true;
  }

  Future<AuthenticationResult> logIn(
      {required String username, required String password}) async {
    final userPool = CognitoUserPool(_userPoolId, _clientId);

    final cognitoUser = CognitoUser(username, userPool);
    final authDetails = AuthenticationDetails(
      username: username,
      password: password,
    );
    CognitoUserSession? session;
    try {
      session = await cognitoUser.authenticateUser(authDetails);
    } on CognitoClientException catch (e) {
      print(e);
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.invalidCredentials]);
    } catch (e) {
      return AuthenticationResult(
          success: false, errors: [AuthenticationError.unknown]);
    }
    CognitoUserImpl user = CognitoUserImpl();
    user.username = username;
    user.refreshToken = session?.getRefreshToken()?.getToken();
    user.accessToken = session?.getAccessToken().getJwtToken();
    return AuthenticationResult(success: true, user: user);
  }

  Future<AuthenticationResult> createUser(
      {required String username,
      required String password,
      Map<String, dynamic>? properties}) async {
    final userPool = CognitoUserPool(_userPoolId, _clientId);
    List<AttributeArg> userAttributes = [];
    properties?.forEach((key, value) {
      userAttributes.add(AttributeArg(name: key, value: value));
    });

    var data;
    try {
      data = await userPool.signUp(
        username,
        password,
        userAttributes: userAttributes,
      );
      return AuthenticationResult(success: true);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> verifyUser(
      {required User user, required String code, String? attribute}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);
      final cognitoUser = CognitoUser(user.username, userPool);
      final verified = await cognitoUser.verifyAttribute(attribute, code);
      print(verified);
      return AuthenticationResult(success: true, user: user);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> refreshSession({required User user}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);
      final refreshToken = CognitoRefreshToken(user.refreshToken);
      final cognitoUser = CognitoUser(user.username, userPool);
      final session = await cognitoUser.refreshSession(refreshToken);
      user.username = cognitoUser.username;
      user.refreshToken = session?.getRefreshToken()?.getToken();
      user.accessToken = session?.getAccessToken().getJwtToken();
      return AuthenticationResult(success: true, user: user);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  User? currentUser() {
    return user;
  }
}
