import 'package:dart_authentication_service/src/authentication_provider.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/providers/cognito_user.dart';
import 'package:dart_authentication_service/src/user.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:jose/jose.dart';

class CognitoProvider implements AuthenticationProvider {
  CognitoUserImpl? _user;
  String _userPoolId;
  String _clientId;

  CognitoProvider(this._userPoolId, this._clientId);

  bool isLoggedIn() {
    if (_user == null || _user?.accessToken == null) {
      return false;
    } else {
      // we can use the unverified token here because the server should actually
      // verify and no data should be comprimised
      var jwt = JsonWebToken.unverified(_user!.accessToken!);
      if (jwt.claims.expiry != null) {
        if (jwt.claims.expiry!.isAfter(DateTime.now())) {
          return true;
        }
      } else {
        return false;
      }
    }
    return false;
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
    _user = CognitoUserImpl();
    _user!.username = username;
    _user!.refreshToken = session?.getRefreshToken()?.getToken();
    _user!.accessToken = session?.getAccessToken().getJwtToken();
    return AuthenticationResult(success: true);
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
      _user = CognitoUserImpl();
      _user!.username = username;
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
      final verified = await cognitoUser.confirmRegistration(code);
      return AuthenticationResult(success: true);
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
      _user = CognitoUserImpl();
      _user!.username = cognitoUser.username;
      _user!.refreshToken = session?.getRefreshToken()?.getToken();
      _user!.accessToken = session?.getAccessToken().getJwtToken();
      return AuthenticationResult(success: true);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  User? currentUser() {
    return _user;
  }
}
