class User {
  final String login;
  final String password;
  final String email;

  User({required this.login, required this.password, required this.email});

  Map<String, dynamic> toJson() => {
        'login': login,
        'password': password,
        'email': email,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        login: json['login'],
        password: json['password'],
        email: json['email'],
      );
}
