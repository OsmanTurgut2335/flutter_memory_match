import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';
import 'package:mem_game/data/gamestate/repository/game_repository.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

class GameNotifier extends StateNotifier<GameState?> {
  final GameRepository _repository;
  Timer? _timer;
  int? _firstSelectedIndex;
  bool _busy = false;

   GameNotifier(this._repository) : super(null);
  
  /// Public method to initialize the game.
  Future<void> initializeGame(bool resumeGame) async {
    if (resumeGame) {
      final savedState = await _repository.loadGameState();
      if (savedState != null) {
        state = savedState;
        _startTimer();
        return;
      }
    }
    state = _createNewGameState();
    await _repository.saveGameState(state!);
    _startTimer();
  }

  GameState _createNewGameState() {
    return GameState(
      cards: _generateDummyCards(),
    
    );
  }
  // To pause the game:
void pauseGame() {
  _timer?.cancel();
}

// To resume the game:
void resumeGame() {
  _startTimer(); 
}


  List<MemoryCard> _generateDummyCards() {
    return [
      MemoryCard(id: 0, content: 'A'),
      MemoryCard(id: 1, content: 'B'),
      MemoryCard(id: 2, content: 'C'),
      MemoryCard(id: 3, content: 'D'),
      MemoryCard(id: 4, content: 'A'),
      MemoryCard(id: 5, content: 'B'),
      MemoryCard(id: 6, content: 'C'),
      MemoryCard(id: 7, content: 'D'),
    ];
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null) {
        state = state!.copyWith(currentTime: state!.currentTime + 1);
        _repository.saveGameState(state!);
      }
    });
  }
Future<void> saveCurrentState() async {
  if (state != null) {
    await _repository.saveGameState(state!);
  }
}

  Future<void> onCardTap(int index) async {
    if (_busy || state == null) return;
    if (state!.cards[index].isMatched || state!.cards[index].isFaceUp) return;

    final updatedCards = List<MemoryCard>.from(state!.cards);
    updatedCards[index].isFaceUp = true;
    state = state!.copyWith(cards: updatedCards);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      state = state!.copyWith(moves: state!.moves + 1);
      int firstIndex = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (state!.cards[firstIndex].content == state!.cards[index].content) {
        updatedCards[firstIndex].isMatched = true;
        updatedCards[index].isMatched = true;
        state = state!.copyWith(cards: updatedCards, score: state!.score + 10);
      } else {
        _busy = true;
        await Future.delayed(const Duration(seconds: 1));
        updatedCards[firstIndex].isFaceUp = false;
        updatedCards[index].isFaceUp = false;
        state = state!.copyWith(cards: updatedCards, health: state!.health - 1);
        _busy = false;
      }
      await _repository.saveGameState(state!);
      if (state!.health <= 0) {
        _timer?.cancel();
        // Call game over handling here (if needed).
      }
    }
  }

  Future<void> restartGame() async {
    _timer?.cancel();
    state = _createNewGameState();
    await _repository.saveGameState(state!);
    _startTimer();
  }

  /// Exits the game: cancels the timer, deletes the game state, and resets the state.
  Future<void> exitGame() async {
    _timer?.cancel();
    await _repository.deleteGameState();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
