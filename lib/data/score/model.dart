class Score {

  Score({
    required this.username,
    required this.bestTime,
  });

  // Factory constructor to create a Score from a Firestore document map.
  factory Score.fromMap(Map<String, dynamic> data) {
    return Score(
      username: data['username'] as String? ?? '',
      bestTime: data['bestTime'] as int? ?? 0,
    );
  }
  final String username;
  final int bestTime;

  // Optionally, convert a Score back to a Map (if you need to write it back to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'bestTime': bestTime,
    };
  }
}
