abstract class User {
  String? username;
  String? password;
  String? name;
  String? accessToken;
  String? refreshToken;
}

class AuthenticationUser implements User {
  String? username;
  String? password;
  String? name;
  String? accessToken;
  String? refreshToken;
  AuthenticationUser(
      {this.username,
      this.password,
      this.name,
      this.accessToken,
      this.refreshToken}) {}
}
