import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'authentication_test.mocks.dart';

@GenerateMocks([CognitoProvider])
main() async {
  Authentication authentication = Authentication();
  MockCognitoProvider cognitoProvider = MockCognitoProvider();

  await authentication.init(cognitoProvider);
  group('isLoggedIn()', () {
    test('calls the providers isLoggedIn method', () {
      when(cognitoProvider.isLoggedIn()).thenReturn(true);
      expect(authentication.isLoggedIn(), true);
    });
  });

  group('currentUser()', () {
    test('returns the user when set', () {
      CognitoUser user = CognitoUser();
      when(cognitoProvider.currentUser()).thenReturn(user);
      expect(authentication.currentUser(), user);
    });

    test('returns null when not set', () {
      when(cognitoProvider.currentUser()).thenReturn(null);
      expect(authentication.currentUser(), null);
    });
  });

  group('logIn()', () {
    test('saves user when rememberMe is true', () async {
      when(cognitoProvider.logIn('myuser', 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      await authentication.logIn('myuser', 'password', true);
      expect(authentication.lastUsername(), 'myuser');
    });

    test('does not save user when rememberMe is false', () async {
      when(cognitoProvider.logIn('myuser', 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      await authentication.logIn('myuser', 'password', false);
      expect(authentication.lastUsername(), null);
    });

    test('returns an authentication object', () async {
      when(cognitoProvider.logIn('myuser', 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.logIn('myuser', 'password', false);
      expect(result.success, true);
    });
  });
}
