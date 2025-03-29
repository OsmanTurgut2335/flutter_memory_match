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

  GameNotifier(this._repository) : super(null) {
    // Initialize game state (for example, start with a new game by default)
    initializeGame(false);
  }

  /// Initializes the game state.
  /// If [resumeGame] is true, attempts to load a saved state from Hive;
  /// otherwise, creates a new game.
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

  /// Creates a new game state with default values.
  GameState _createNewGameState() {
    return GameState(
      cards: _generateDummyCards(),
      moves: 0,
      score: 0,
      currentTime: 0,
      health: 3,
    );
  }

  /// Generates a list of dummy memory cards.
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

  /// Starts a periodic timer to update the current time.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null) {
        state = state!.copyWith(currentTime: state!.currentTime + 1);
        _repository.saveGameState(state!);
      }
    });
  }

  /// Handles a tap on a card.
  /// - If no card is currently selected, flip the tapped card.
  /// - If one card is already flipped, flip the new card, compare both:
  ///   - If they match, mark them as matched and update the score.
  ///   - If they don't match, flip them back after a delay and decrease health.
  Future<void> onCardTap(int index) async {
    if (_busy || state == null) return;
    if (state!.cards[index].isMatched || state!.cards[index].isFaceUp) return;

    // Flip the tapped card.
    final updatedCards = List<MemoryCard>.from(state!.cards);
    updatedCards[index].isFaceUp = true;
    state = state!.copyWith(cards: updatedCards);

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      // Second card selected: increment moves.
      state = state!.copyWith(moves: state!.moves + 1);
      int firstIndex = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (state!.cards[firstIndex].content == state!.cards[index].content) {
        // Cards match: mark them as matched and update score.
        updatedCards[firstIndex].isMatched = true;
        updatedCards[index].isMatched = true;
        state = state!.copyWith(cards: updatedCards, score: state!.score + 10);
      } else {
        // Cards do not match: wait, then flip back and decrease health.
        _busy = true;
        await Future.delayed(const Duration(seconds: 1));
        updatedCards[firstIndex].isFaceUp = false;
        updatedCards[index].isFaceUp = false;
        state = state!.copyWith(cards: updatedCards, health: state!.health - 1);
        _busy = false;
      }
      await _repository.saveGameState(state!);
      // Check for game over.
      if (state!.health <= 0) {
        _timer?.cancel();
        // You might set a game over flag or notify the UI here.
      }
    }
  }

  /// Restarts the game.
  Future<void> restartGame() async {
    _timer?.cancel();
    state = _createNewGameState();
    await _repository.saveGameState(state!);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
