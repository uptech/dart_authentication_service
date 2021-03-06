import 'dart:core';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dart_authentication_service/src/authentication_provider.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/extensions/first_where_null.dart';
import 'package:dart_authentication_service/src/providers/cognito_user.dart';
import 'package:dart_authentication_service/src/user.dart';
import 'package:jose/jose.dart';

class CognitoProvider implements AuthenticationProvider {
  CognitoProvider() {
    Amplify.addPlugin(AmplifyAuthCognito());
  }

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

  Future<AuthenticationResult> logIn({
    required String username,
    required String password,
  }) async {
    try {
      SignInResult signInResult = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      AuthSession authSessionResult = await Amplify.Auth.fetchAuthSession(
        options: CognitoSessionOptions(getAWSCredentials: true),
      );
      if (signInResult.isSignedIn && authSessionResult.isSignedIn) {
        final session = authSessionResult as CognitoAuthSession;
        CognitoUserImpl cognitoUser = _userFromSession(
          session: session,
          username: username,
        );
        return AuthenticationResult(success: true, user: cognitoUser);
      } else {
        return AuthenticationResult(
          success: false,
          errors: [AuthenticationError.couldNotSignIn],
        );
      }
    } on UserNotConfirmedException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.userNotConfirmed],
      );
    } on UsernameExistsException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.usernameExists],
      );
    } on UserNotFoundException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.userNotFound],
      );
    } catch (e) {
      print(e);
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.unknown],
      );
    }
  }

  Future<AuthenticationResult> createUser({
    required String username,
    required String password,
    Map<String, String>? properties,
  }) async {
    Map<CognitoUserAttributeKey, String> cognitoProperties = {};
    if (properties != null) {
      cognitoProperties = properties
          .map((key, value) => MapEntry(_findUserAttributeKey(key), value));
    }
    try {
      await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: CognitoSignUpOptions(userAttributes: cognitoProperties),
      );
      CognitoUserImpl user = CognitoUserImpl();
      user.username = username;
      return AuthenticationResult(success: true, user: user);
    } on UserNotConfirmedException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.userNotConfirmed],
      );
    } on UsernameExistsException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.usernameExists],
      );
    } on UserNotFoundException {
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.userNotFound],
      );
    } catch (e) {
      print(e);
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> resendVerificationCode({
    required String username,
  }) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: username);
      return AuthenticationResult(success: true);
    } catch (e) {
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> verifyUser({
    required String username,
    required String code,
  }) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: code,
      );
      return AuthenticationResult(success: true);
    } catch (e) {
      print(e);
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> refreshSession({
    required User user,
  }) async {
    try {
      AuthSession authSessionResult = await Amplify.Auth.fetchAuthSession(
        options: CognitoSessionOptions(getAWSCredentials: true),
      );
      if (authSessionResult.isSignedIn) {
        final session = authSessionResult as CognitoAuthSession;
        CognitoUserImpl cognitoUser = _userFromSession(
          session: session,
          username: user.username,
        );
        return AuthenticationResult(success: true, user: cognitoUser);
      } else {
        return AuthenticationResult(
          success: false,
          errors: [AuthenticationError.couldNotSignIn],
        );
      }
    } catch (e) {
      print(e);
      return AuthenticationResult(
        success: false,
        errors: [AuthenticationError.unknown],
      );
    }
  }

  Future<AuthenticationResult> logOut() async {
    try {
      await Amplify.Auth.signOut();
      return AuthenticationResult(success: true);
    } on AuthException catch (e) {
      print(e.message);
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> requestPasswordReset({
    required String username,
  }) async {
    try {
      await Amplify.Auth.resetPassword(username: username);
      CognitoUserImpl user = CognitoUserImpl();
      user.username = username;
      return AuthenticationResult(success: true, user: user);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationResult> setPassword({
    required User user,
    required String code,
    required String password,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: user.username ?? '',
        newPassword: password,
        confirmationCode: code,
      );
      return AuthenticationResult(success: true);
    } catch (e) {
      print(e);

      return AuthenticationResult(success: false);
    }
  }

  // Asigns a new password via the password reset code
  Future<AuthenticationResult> changePassword({
    required User user,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await Amplify.Auth.updatePassword(
        newPassword: newPassword,
        oldPassword: oldPassword,
      );
      return AuthenticationResult(success: true);
    } on AmplifyException catch (e) {
      print(e);
      return AuthenticationResult(success: false);
    }
  }

  Future<AuthenticationAttributesResult> getUserAttributes() async {
    try {
      List<AuthUserAttribute> result = await Amplify.Auth.fetchUserAttributes();
      Map<String, String> attributes = Map.fromIterable(
        result,
        key: (v) => v.userAttributeKey.toString(),
        value: (v) => v.value,
      );
      return AuthenticationAttributesResult(
        success: true,
        attributes: attributes,
      );
    } on AuthException catch (e) {
      print(e.message);
      return AuthenticationAttributesResult(
        success: false,
        errors: [AuthenticationError.unknown],
      );
    }
  }

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> getAttributeVerificationCode({
    required String attribute,
  }) async {
    try {
      var res = await Amplify.Auth.resendUserAttributeConfirmationCode(
        userAttributeKey: attribute as UserAttributeKey,
      );
      var destination = res.codeDeliveryDetails.destination;
      print('Confirmation code set to $destination');
      return AuthenticationAttributesResult(
        success: true,
      );
    } on AmplifyException catch (e) {
      print(e.message);
      return AuthenticationAttributesResult(
        success: false,
        errors: [AuthenticationError.unknown],
      );
    }
  }

  /// Verifies the attribute and code. This is used for verifying a
  /// phone number or email
  Future<AuthenticationAttributesResult> verifyAttribute({
    required String attribute,
    required String code,
  }) async {
    try {
      await Amplify.Auth.confirmUserAttribute(
        userAttributeKey: attribute as UserAttributeKey,
        confirmationCode: code,
      );
      return AuthenticationAttributesResult(success: true);
    } on AmplifyException catch (e) {
      print(e);
      return AuthenticationAttributesResult(
        success: false,
        errors: [AuthenticationError.unknown],
      );
    }
  }

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> updateAttributes({
    required Map<String, dynamic> attributes,
  }) async {
    final attributeList = attributes.entries
        .map((e) => AuthUserAttribute(
              userAttributeKey: _findUserAttributeKey(e.key),
              value: e.value,
            ))
        .toList();
    try {
      var res =
          await Amplify.Auth.updateUserAttributes(attributes: attributeList);
      String nextStep = res.entries
          .map((e) {
            if (e.value.nextStep.updateAttributeStep ==
                'CONFIRM_ATTRIBUTE_WITH_CODE') {
              var destination =
                  e.value.nextStep.codeDeliveryDetails?.destination;
              return 'Confirmation code sent to $destination for ${e.key}';
            } else {
              return 'Update completed for ${e.key}';
            }
          })
          .toList()
          .join(', ');
      return AuthenticationAttributesResult(
        success: true,
        nextStep: nextStep,
      );
    } on AmplifyException catch (e) {
      print(e.message);
      return AuthenticationAttributesResult(
        success: false,
      );
    }
  }

  CognitoUserImpl _userFromSession({
    required CognitoAuthSession session,
    String? username,
  }) {
    CognitoUserImpl user = CognitoUserImpl();
    user.username = username;
    user.refreshToken = session.userPoolTokens?.refreshToken;
    user.accessToken = session.userPoolTokens?.accessToken;
    user.idToken = session.userPoolTokens?.idToken;
    user.id = session.userSub;
    return user;
  }

  CognitoUserAttributeKey _findUserAttributeKey(String key) {
    return CognitoUserAttributeKey.values
            .firstWhereOrNull((e) => e.key == key) ??
        CognitoUserAttributeKey.custom(key);
  }
}
