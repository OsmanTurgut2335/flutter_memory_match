import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/score/model.dart';
import 'package:mem_game/data/scoreboard/repository/scoreboard_repository.dart';

class ScoreboardNotifier extends StateNotifier<Score?> {

  ScoreboardNotifier(this.scoreboardRepository) : super(null);


  final  ScoreboardRepository scoreboardRepository ;

  Future<List<Score>> fetchLeaderboard() async {
    return scoreboardRepository.fetchLeaderboard();

  }

}
