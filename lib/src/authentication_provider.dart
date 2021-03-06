import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';

abstract class AuthenticationProvider {
  /// Determins if the current user is already authenticated
  Future<AuthenticationResult> isLoggedIn(User user);

  /// Logs in with a username and password
  Future<AuthenticationResult> logIn({
    required String username,
    required String password,
  });

  /// Registers a new user with a username, password and additional properties
  Future<AuthenticationResult> createUser({
    required String username,
    required String password,
    Map<String, String>? properties,
  });

  /// Resends the verification code to the email address that was just
  /// registered
  Future<AuthenticationResult> resendVerificationCode({
    required String username,
  });

  /// Verifies the user and code
  Future<AuthenticationResult> verifyUser({
    required String username,
    required String code,
  });

  /// Refreshes the current authenticated user session
  Future<AuthenticationResult> refreshSession({
    required User user,
  });

  /// Logs out the current user
  Future<AuthenticationResult> logOut();

  // Requests a password reset email
  Future<AuthenticationResult> requestPasswordReset({
    required String username,
  });

  // Asigns a new password via the password reset code
  Future<AuthenticationResult> setPassword({
    required User user,
    required String code,
    required String password,
  });

  /// Asigns a new password to a user. Both the oldPassword and the newPassword
  /// are required.
  Future<AuthenticationResult> changePassword({
    required User user,
    required String oldPassword,
    required String newPassword,
  });

  /// Fetches attributes for a user
  Future<AuthenticationAttributesResult> getUserAttributes();

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> getAttributeVerificationCode({
    required String attribute,
  });

  /// Verifies the attribute and code. This is used for verifying a
  /// phone number or email
  Future<AuthenticationAttributesResult> verifyAttribute({
    required String attribute,
    required String code,
  });

  /// Fetches a specific attribute's verification code
  Future<AuthenticationAttributesResult> updateAttributes({
    required Map<String, String> attributes,
  });
}
