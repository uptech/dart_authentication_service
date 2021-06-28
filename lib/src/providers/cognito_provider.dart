import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:dart_authentication_service/src/authentication_provider.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/providers/cognito_user.dart';
import 'package:dart_authentication_service/src/user.dart';
import 'package:jose/jose.dart';

class CognitoProvider implements AuthenticationProvider {
  String _userPoolId;
  String _clientId;

  CognitoProvider(this._userPoolId, this._clientId);

  Future<AuthenticationResult> isLoggedIn(User user) async {
    if (_hasValidAccessToken(user)) {
      return AuthenticationResult(success: true, user: user);
    } else {
      return await refreshSession(user: user);
    }
  }

  bool _hasValidAccessToken(User user) {
    if (user.accessToken == null) {
      return false;
    } else {
      // we can use the unverified token here because the server should actually
      // verify and no data should be comprimised
      var jwt = JsonWebToken.unverified(user.accessToken!);
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
      if (e.code == 'LimitExceededException') {
        return AuthenticationResult(
            success: false, errors: [AuthenticationError.rateLimitExceeded]);
      } else if (e.code == 'UserNotFoundException') {
        return AuthenticationResult(
            success: false, errors: [AuthenticationError.invalidCredentials]);
      } else if (e.code == 'NotAuthorizedException') {
        return AuthenticationResult(
            success: false, errors: [AuthenticationError.invalidCredentials]);
      }
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
      CognitoUserImpl user = CognitoUserImpl();
      user.username = username;
      return AuthenticationResult(success: true, user: user);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> resendVerificationCode(
      {required String email}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);
      final cognitoUser = CognitoUser(email, userPool);
      await cognitoUser.resendConfirmationCode();
      return AuthenticationResult(success: true);
    } catch (e) {
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> verifyUser(
      {required User user, required String code, String? attribute}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);
      final cognitoUser = CognitoUser(user.username, userPool);
      await cognitoUser.confirmRegistration(code);
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
      CognitoUserImpl updatedUser = CognitoUserImpl();
      updatedUser.username = cognitoUser.username;
      updatedUser.refreshToken = session?.getRefreshToken()?.getToken();
      updatedUser.accessToken = session?.getAccessToken().getJwtToken();
      return AuthenticationResult(success: true, user: updatedUser);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> logOut({User? user}) async {
    return AuthenticationResult(success: false);
  }

  Future<AuthenticationResult> requestPasswordReset(
      {required String username}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);

      final cognitoUser = CognitoUser(username, userPool);
      await cognitoUser.forgotPassword();
      CognitoUserImpl user = CognitoUserImpl();
      user.username = username;
      return AuthenticationResult(success: true, user: user);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> setPassword(
      {required User user,
      required String code,
      required String password}) async {
    try {
      final userPool = CognitoUserPool(_userPoolId, _clientId);

      final cognitoUser = CognitoUser(user.username, userPool);
      final passwordConfirmed =
          await cognitoUser.confirmPassword(code, password);

      return AuthenticationResult(success: passwordConfirmed);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }
}
