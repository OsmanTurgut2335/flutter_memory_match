

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mem_game/data/score/model.dart';

class ScoreboardRepository {

  ScoreboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Fetches the leaderboard as a list of Score objects.
  Future<List<Score>> fetchLeaderboard() async {
    try {
      // Retrieve all documents in the "leaderboard" collection.
      final querySnapshot = await _firestore.collection('leaderboard').get();

      // Convert each document into a Score object.
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Score.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }
}




