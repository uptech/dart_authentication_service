import 'package:dart_authentication_service/dart_authentication_service.dart';
import 'package:dart_authentication_service/src/authentication_result.dart';
import 'package:dart_authentication_service/src/user_attribute.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'authentication_test.mocks.dart';

@GenerateMocks([CognitoProvider, Box])
main() async {
  Authentication authentication = Authentication();
  MockCognitoProvider cognitoProvider = MockCognitoProvider();

  await authentication.init(provider: cognitoProvider);
  group('isLoggedIn()', () {
    test('when user is not in memory it fetches from box', () async {
      MockBox box = MockBox();
      Authentication authWithMockBox = Authentication();

      authWithMockBox.user = null;
      authWithMockBox.box = box;

      // these stubs prove the test passes, i.e. if they weren't here it would fail
      when(box.get('username')).thenReturn('persisted_user');
      when(box.get('accessToken')).thenReturn('token');
      when(box.get('refreshToken')).thenReturn('token');

      when(cognitoProvider.isLoggedIn(any))
          .thenAnswer((_) async => AuthenticationResult(success: false));
      await authWithMockBox.isLoggedIn();
    });

    test('when user is in memory it does not fetch from box', () async {
      authentication.user = AuthenticationUser();

      when(cognitoProvider.isLoggedIn(any))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      await authentication.isLoggedIn();
    });

    test('calls the providers isLoggedIn method', () async {
      User user = AuthenticationUser();
      authentication.user = user;
      when(cognitoProvider.isLoggedIn(user))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.isLoggedIn();
      expect(result.success, true);
    });
  });

  group('logIn()', () {
    test('saves user when rememberMe is true', () async {
      when(cognitoProvider.logIn(username: 'myuser', password: 'password'))
          .thenAnswer((_) async => AuthenticationResult(
              success: true, user: AuthenticationUser(username: 'myuser')));
      await authentication.logIn(
          username: 'myuser', password: 'password', rememberMe: true);
      expect(authentication.lastUsername(), 'myuser');
    });

    test('does not save user when rememberMe is false', () async {
      when(cognitoProvider.logIn(username: 'myuser', password: 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      await authentication.logIn(
          username: 'myuser', password: 'password', rememberMe: false);
      expect(authentication.lastUsername(), null);
    });

    test('returns an authentication result object', () async {
      when(cognitoProvider.logIn(username: 'myuser', password: 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.logIn(
          username: 'myuser', password: 'password', rememberMe: false);
      expect(result.success, true);
    });
  });

  group('logOut()', () {
    setUp(() {
      when(cognitoProvider.logIn(
        username: 'myuser',
        password: 'password',
      )).thenAnswer(
        (_) async => AuthenticationResult(
          success: true,
          user: AuthenticationUser(username: 'myuser'),
        ),
      );

      when(cognitoProvider.logOut()).thenAnswer(
        (_) async => AuthenticationResult(
          success: true,
        ),
      );
    });

    test('currentUser should be nil', () async {
      await authentication.logIn(
        username: 'myuser',
        password: 'password',
        rememberMe: true,
      );
      expect(authentication.lastUsername(), 'myuser');
      expect(authentication.currentUser(), isNotNull);

      await authentication.logOut();
      expect(authentication.currentUser(), isNull);
      expect(authentication.lastUsername(), isNull);
    });
  });

  group('createUser()', () {
    test('returns an authentication result object', () async {
      when(cognitoProvider.createUser(username: 'myuser', password: 'password'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.createUser(
          username: 'myuser', password: 'password');
      expect(result.success, true);
    });
  });

  group('verifyUser()', () {
    test('returns an authentication result object', () async {
      var username = 'foo';
      when(cognitoProvider.verifyUser(username: username, code: '1234'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result =
          await authentication.verifyUser(username: username, code: '1234');
      expect(result.success, true);
    });
  });

  group('refreshSession()', () {
    test('returns an authentication result object', () async {
      var user = AuthenticationUser(username: 'foo');
      when(cognitoProvider.refreshSession(user: user))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.refreshSession(user);
      expect(result.success, true);
    });
  });

  group('resentVerificationCode()', () {
    test(
        'sends a new verification code and returns an authentication result object',
        () async {
      when(cognitoProvider.resendVerificationCode(username: 'foo@bar.com'))
          .thenAnswer((_) async => AuthenticationResult(success: true));
      var result =
          await authentication.resendVerificationCode(username: 'foo@bar.com');
      expect(result.success, true);
    });
  });

  group('changeUserPassword()', () {
    test('changes the current users password', () async {
      var user = AuthenticationUser(username: 'foo');
      when(cognitoProvider.changePassword(
        user: user,
        oldPassword: '000000',
        newPassword: '111222',
      )).thenAnswer((_) async => AuthenticationResult(success: true));
      var result = await authentication.changePassword(
        user: user,
        oldPassword: '000000',
        newPassword: '111222',
      );
      expect(result.success, true);
    });
  });

  group('userAttributes()', () {
    test('get user attributes', () async {
      when(cognitoProvider.getUserAttributes())
          .thenAnswer((_) async => AuthenticationAttributesResult(
                success: true,
                attributes: {"Test": "Value"},
              ));
      var result = await authentication.getUserAttributes();
      expect(result.success, true);
      expect(
        result.attributes?["Test"],
        UserAttribute(name: "Test", value: "Value").value,
      );
    });

    test('get attribute verification code', () async {
      when(cognitoProvider.getAttributeVerificationCode(
        attribute: 'email',
      )).thenAnswer((_) async => AuthenticationAttributesResult(
            success: true,
          ));
      var result = await authentication.getAttributeVerificationCode(
        attribute: 'email',
      );
      expect(result.success, true);
    });

    test('verify attribute', () async {
      when(cognitoProvider.verifyAttribute(
        attribute: 'email',
        code: '123456',
      )).thenAnswer((_) async => AuthenticationAttributesResult(
            success: true,
          ));
      var result = await authentication.verifyAttribute(
        attribute: 'email',
        code: '123456',
      );
      expect(result.success, true);
    });

    test('update user attributes', () async {
      when(cognitoProvider.updateAttributes(
        attributes: {'example:atrtribute': '1234567890'},
      )).thenAnswer((_) async => AuthenticationAttributesResult(
            success: true,
          ));
      var result = await authentication.updateAttributes(
        attributes: {'example:atrtribute': '1234567890'},
      );
      expect(result.success, true);
    });
  });
}
