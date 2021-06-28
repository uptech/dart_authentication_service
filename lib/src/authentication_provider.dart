import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';

abstract class AuthenticationProvider {
  /// Determins if the current user is already authenticated
  Future<AuthenticationResult> isLoggedIn(User user);

  /// Logs in with a username and password
  Future<AuthenticationResult> logIn(
      {required String username, required String password});

  /// Registers a new user with a username, password and additional properties
  Future<AuthenticationResult> createUser(
      {required String username,
      required String password,
      Map<String, dynamic>? properties});

  /// Resends the verification code to the email address that was just
  /// registered
  Future<AuthenticationResult> resendVerificationCode({required String email});

  /// Verifies the user and code
  Future<AuthenticationResult> verifyUser(
      {required User user, required String code, String? attribute});

  /// Refreshes the current authenticated user session
  Future<AuthenticationResult> refreshSession({required User user});

  /// Logs out the current user
  Future<AuthenticationResult> logOut({User user});

  // Requests a password reset email
  Future<AuthenticationResult> requestPasswordReset({required String username});

  // Asigns a new password via the password reset code
  Future<AuthenticationResult> setPassword(
      {required User user, required String code, required String password});

  /// Fetches attributes for a user
  Future<AuthenticationAttributesResult> getUserAttributes({
    required User user,
  });

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> getAttributeVerificationCode({
    required User user,
    required String attribute,
  });

  /// Verifies the attribute and code. This is used for verifying a
  /// phone number or email
  Future<AuthenticationAttributesResult> verifyAttribute({
    required User user,
    required String attribute,
    required String code,
  });

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> updateAttributes({
    required User user,
    required Map<String, dynamic> attributes,
  });

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> deleteAttributes({
    required User user,
    required List<String> attributes,
  });
}
