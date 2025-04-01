import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

class GameNotifier extends StateNotifier<GameState?> {
  // Track pause state

  GameNotifier(this._repository) : super(null);
  final GameRepository _repository;
  Timer? _timer;
  int? _firstSelectedIndex;
  bool _busy = false;
  bool _isPaused = false;

  GameState? get gameState => state;

  Future<void> clearBestTime() async {
    await _repository.clearBestTime();
  }

  /// Initializes the game.
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
    return GameState(cards: _generateDummyCards());
  }

  Future<void> updateBestTimeIfNeeded() async {
    if (state != null) {
      await _repository.updateBestTimeIfNeeded(state!.currentTime);
    }
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

  /// Handles pausing the game
  void pauseGame() {
    _isPaused = true;
    _timer?.cancel();
    state = state?.copyWith(isPaused: true);
  }

  /// Handles resuming the game
  void resumeGame() {
    _isPaused = false;
    _startTimer();
    state = state?.copyWith(isPaused: false);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && state != null) {
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
    if (_busy || state == null || _isPaused) return;
    if (state!.cards[index].isMatched || state!.cards[index].isFaceUp) return;

    final updatedCards = List<MemoryCard>.from(state!.cards);
    updatedCards[index].isFaceUp = true;
    state = state!.copyWith(cards: updatedCards);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      state = state!.copyWith(moves: state!.moves + 1);
      final firstIndex = _firstSelectedIndex!;
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
        handleLose();

        return;
      }
    }

    //  Check for win condition
    if (checkWinCondition()) {
      handleWin();
    }
  }

  void handleWin() {
    _timer?.cancel(); // Stop the timer when the game is won

    // Call updateBestTimeIfNeeded to update the user's best time
    updateBestTimeIfNeeded();

    // Notify UI by copying the state (if needed)
    state = state!.copyWith();
  }

  void handleLose() {
    _timer?.cancel(); // Stop the timer when the game is won

    // Notify UI by copying the state (if needed)
    state = state!.copyWith();
  }

  /// **Checks if all cards are matched**
  bool checkWinCondition() {
    return state!.cards.every((card) => card.isMatched);
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
