abstract class User {
  String? username;
  String? password;
  String? name;
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? customProperties;
}

class AuthenticationUser implements User {
  String? username;
  String? password;
  String? name;
  String? accessToken;
  String? refreshToken;
  Map<String, dynamic>? customProperties;

  AuthenticationUser(
      {this.username,
      this.password,
      this.name,
      this.accessToken,
      this.refreshToken,
      this.customProperties}) {}
}
