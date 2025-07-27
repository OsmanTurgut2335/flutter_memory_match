class AuthResponse {

  AuthResponse({required this.token, required this.username});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      username: json['username'] as String ,
    );
  }
  final String token;
  final String username;
}
