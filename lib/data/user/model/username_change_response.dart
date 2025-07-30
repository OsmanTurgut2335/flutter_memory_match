class UsernameChangeResponse {

  UsernameChangeResponse({required this.newUsername, required this.token});

  factory UsernameChangeResponse.fromJson(Map<String, dynamic> json) {
    return UsernameChangeResponse(
      newUsername: json['newUsername'] as String,
      token: json['token'] as String,
    );
  }
  final String newUsername;
  final String token;
}
